//! nvm-upgrader.exe — Elevated one-time cleanup helper for NVM for Windows v1 → v2 migration.
//!
//! Usage (all flags are optional; missing flags skip the corresponding step):
//!   nvm-upgrader.exe [--install-dir <path>] [--symlink-path <path>] [--new-nvm <path>]
//!
//! The embedded manifest declares requireAdministrator so Windows auto-elevates via UAC.
//! The installer calls this once for all privileged cleanup, then EnsureNvmPathPriority
//! writes the new v2 NVM_HOME back into HKCU immediately afterwards.

const std = @import("std");
const windows = std.os.windows;

// ── Win32 types ───────────────────────────────────────────────────────────────

const HKEY = windows.HKEY;
const DWORD = u32;
const LSTATUS = i32;
const REGSAM = DWORD;
const BOOL = windows.BOOL;
/// Read-only null-terminated wide string.
const LPCWSTR = [*:0]const u16;
/// Writable wide-char buffer (output parameters).
const LPWSTR = [*]u16;

const KEY_READ: REGSAM = 0x20019;
const KEY_WRITE: REGSAM = 0x20006;
const REG_SZ: DWORD = 1;
const REG_EXPAND_SZ: DWORD = 2;
const FILE_ATTRIBUTE_REPARSE_POINT: DWORD = 0x0400;
const INVALID_FILE_ATTRIBUTES: DWORD = 0xFFFFFFFF;
const ERROR_SUCCESS: LSTATUS = 0;
const ERROR_NO_MORE_ITEMS: LSTATUS = 259;
const CREATE_NO_WINDOW: DWORD = 0x08000000;
const INFINITE: DWORD = 0xFFFFFFFF;

// ── Win32 imports ─────────────────────────────────────────────────────────────

extern "advapi32" fn RegOpenKeyExW(
    hKey: HKEY,
    lpSubKey: LPCWSTR,
    ulOptions: DWORD,
    samDesired: REGSAM,
    phkResult: *HKEY,
) callconv(.winapi) LSTATUS;

extern "advapi32" fn RegCloseKey(hKey: HKEY) callconv(.winapi) LSTATUS;

extern "advapi32" fn RegDeleteValueW(
    hKey: HKEY,
    lpValueName: LPCWSTR,
) callconv(.winapi) LSTATUS;

extern "advapi32" fn RegQueryValueExW(
    hKey: HKEY,
    lpValueName: LPCWSTR,
    lpReserved: ?*DWORD,
    lpType: ?*DWORD,
    lpData: ?[*]u8,
    lpcbData: *DWORD,
) callconv(.winapi) LSTATUS;

extern "advapi32" fn RegSetValueExW(
    hKey: HKEY,
    lpValueName: LPCWSTR,
    Reserved: DWORD,
    dwType: DWORD,
    lpData: [*]const u8,
    cbData: DWORD,
) callconv(.winapi) LSTATUS;

extern "advapi32" fn RegEnumKeyExW(
    hKey: HKEY,
    dwIndex: DWORD,
    lpName: LPWSTR,
    lpcchName: *DWORD,
    lpReserved: ?*DWORD,
    lpClass: ?LPWSTR,
    lpcchClass: ?*DWORD,
    lpftLastWriteTime: ?*anyopaque,
) callconv(.winapi) LSTATUS;

/// Recursively delete a registry key and all its subkeys.
extern "shlwapi" fn SHDeleteKeyW(hkey: HKEY, pszSubKey: LPCWSTR) callconv(.winapi) LSTATUS;

extern "kernel32" fn GetFileAttributesW(lpFileName: LPCWSTR) callconv(.winapi) DWORD;
extern "kernel32" fn RemoveDirectoryW(lpPathName: LPCWSTR) callconv(.winapi) BOOL;

const STARTUPINFOW = extern struct {
    cb: DWORD,
    lpReserved: ?LPWSTR,
    lpDesktop: ?LPWSTR,
    lpTitle: ?LPWSTR,
    dwX: DWORD,
    dwY: DWORD,
    dwXSize: DWORD,
    dwYSize: DWORD,
    dwXCountChars: DWORD,
    dwYCountChars: DWORD,
    dwFillAttribute: DWORD,
    dwFlags: DWORD,
    wShowWindow: u16,
    cbReserved2: u16,
    lpReserved2: ?[*]u8,
    hStdInput: ?windows.HANDLE,
    hStdOutput: ?windows.HANDLE,
    hStdError: ?windows.HANDLE,
};

const PROCESS_INFORMATION = extern struct {
    hProcess: windows.HANDLE,
    hThread: windows.HANDLE,
    dwProcessId: DWORD,
    dwThreadId: DWORD,
};

extern "kernel32" fn CreateProcessW(
    lpApplicationName: ?LPCWSTR,
    lpCommandLine: LPWSTR,
    lpProcessAttributes: ?*anyopaque,
    lpThreadAttributes: ?*anyopaque,
    bInheritHandles: BOOL,
    dwCreationFlags: DWORD,
    lpEnvironment: ?*anyopaque,
    lpCurrentDirectory: ?LPCWSTR,
    lpStartupInfo: *STARTUPINFOW,
    lpProcessInformation: *PROCESS_INFORMATION,
) callconv(.winapi) BOOL;

extern "kernel32" fn WaitForSingleObject(
    hHandle: windows.HANDLE,
    dwMilliseconds: DWORD,
) callconv(.winapi) DWORD;

extern "kernel32" fn CloseHandle(hObject: windows.HANDLE) callconv(.winapi) BOOL;

// ── Upgrade log ───────────────────────────────────────────────────────────────
// A best-effort in-memory log that is flushed to <install_dir>\upgrade.log
// only when at least one error is recorded.

var g_log_buf: std.ArrayListUnmanaged(u8) = .{};
var g_log_alloc: std.mem.Allocator = undefined;
var g_has_errors: bool = false;

fn logMsg(comptime fmt: []const u8, args: anytype) void {
    const line = std.fmt.allocPrint(g_log_alloc, fmt ++ "\r\n", args) catch return;
    defer g_log_alloc.free(line);
    g_log_buf.appendSlice(g_log_alloc, line) catch {};
}

fn logError(comptime fmt: []const u8, args: anytype) void {
    g_has_errors = true;
    logMsg("[ERROR] " ++ fmt, args);
}

fn flushUpgradeLog(install_dir: []const u8) void {
    if (!g_has_errors) return;
    if (g_log_buf.items.len == 0) return;
    const log_path = std.fmt.allocPrint(g_log_alloc, "{s}\\upgrade.log", .{install_dir}) catch return;
    defer g_log_alloc.free(log_path);
    const file = std.fs.createFileAbsolute(log_path, .{ .truncate = true }) catch return;
    defer file.close();
    file.writeAll(g_log_buf.items) catch {};
}

// ── String helpers ────────────────────────────────────────────────────────────

/// Heap-allocate a null-terminated UTF-16LE copy of a UTF-8 string.
fn toW(alloc: std.mem.Allocator, s: []const u8) ![:0]u16 {
    return std.unicode.utf8ToUtf16LeAllocZ(alloc, s);
}

/// Return a heap-allocated, lowercased copy of `path` with:
///   - forward slashes replaced by backslashes
///   - trailing backslash stripped (unless a bare root like "c:\")
fn normPath(alloc: std.mem.Allocator, path: []const u8) ![]u8 {
    const trimmed = std.mem.trim(u8, path, " \t\r\n");
    // Determine final length (strip trailing backslash for non-root paths).
    var end = trimmed.len;
    while (end > 3 and trimmed[end - 1] == '\\') end -= 1;
    while (end > 3 and trimmed[end - 1] == '/') end -= 1;
    const result = try alloc.alloc(u8, end);
    @memcpy(result, trimmed[0..end]);
    std.mem.replaceScalar(u8, result, '/', '\\');
    for (result) |*c| c.* = std.ascii.toLower(c.*);
    return result;
}

// ── Registry helpers ──────────────────────────────────────────────────────────

/// Open a registry key. Returns null on failure; caller must RegCloseKey the result.
fn openKey(alloc: std.mem.Allocator, root: HKEY, sub: []const u8, write: bool) ?HKEY {
    const sub_w = toW(alloc, sub) catch return null;
    defer alloc.free(sub_w);
    const access = if (write) KEY_READ | KEY_WRITE else KEY_READ;
    var hk: HKEY = undefined;
    if (RegOpenKeyExW(root, sub_w.ptr, 0, access, &hk) != ERROR_SUCCESS) return null;
    return hk;
}

/// Delete a named value from a registry key path. Errors are ignored.
fn deleteRegValue(alloc: std.mem.Allocator, root: HKEY, sub: []const u8, name: []const u8) void {
    const hk = openKey(alloc, root, sub, true) orelse return;
    defer _ = RegCloseKey(hk);
    const name_w = toW(alloc, name) catch return;
    defer alloc.free(name_w);
    _ = RegDeleteValueW(hk, name_w.ptr);
}

const RegString = struct { value: []u8, reg_type: DWORD };

/// Read a REG_SZ / REG_EXPAND_SZ value. Caller owns the returned .value slice.
fn readRegString(alloc: std.mem.Allocator, hk: HKEY, name: []const u8) !RegString {
    const name_w = try toW(alloc, name);
    defer alloc.free(name_w);

    var reg_type: DWORD = REG_SZ;
    var size_bytes: DWORD = 0;
    // Query size and type (lpData = null is allowed).
    _ = RegQueryValueExW(hk, name_w.ptr, null, &reg_type, null, &size_bytes);
    if (size_bytes == 0) return .{ .value = try alloc.dupe(u8, ""), .reg_type = reg_type };

    // Allocate aligned u16 buffer and read the data.
    const wchar_count = (size_bytes + 1) / 2;
    const buf = try alloc.alloc(u16, wchar_count);
    defer alloc.free(buf);

    var actual: DWORD = size_bytes;
    if (RegQueryValueExW(hk, name_w.ptr, null, null, @ptrCast(buf.ptr), &actual) != ERROR_SUCCESS)
        return error.ReadFailed;

    // Strip trailing null terminators before converting.
    var len = actual / 2;
    while (len > 0 and buf[len - 1] == 0) len -= 1;

    const utf8 = try std.unicode.utf16LeToUtf8Alloc(alloc, buf[0..len]);
    return .{ .value = utf8, .reg_type = reg_type };
}

/// Write a string value back, preserving the original REG type. Errors are ignored.
fn writeRegString(alloc: std.mem.Allocator, hk: HKEY, name: []const u8, value: []const u8, reg_type: DWORD) void {
    const name_w = toW(alloc, name) catch return;
    defer alloc.free(name_w);
    const val_w = toW(alloc, value) catch return;
    defer alloc.free(val_w);
    // Byte count includes the null terminator.
    const byte_size: DWORD = @intCast((val_w.len + 1) * 2);
    _ = RegSetValueExW(hk, name_w.ptr, 0, reg_type, @as([*]const u8, @ptrCast(val_w.ptr)), byte_size);
}

// ── Core cleanup operations ───────────────────────────────────────────────────

/// Remove the old v1 symlink/junction directory (only if it is a reparse point).
fn removeJunction(alloc: std.mem.Allocator, path: []const u8) void {
    const path_w = toW(alloc, path) catch return;
    defer alloc.free(path_w);
    const attrs = GetFileAttributesW(path_w.ptr);
    if (attrs == INVALID_FILE_ATTRIBUTES) return; // does not exist — nothing to do
    if (attrs & FILE_ATTRIBUTE_REPARSE_POINT == 0) {
        logError("Symlink path exists but is not a junction/symlink, skipping removal: {s}", .{path});
        return;
    }
    if (RemoveDirectoryW(path_w.ptr) == 0) {
        logError("Failed to remove junction/symlink: {s}", .{path});
    }
}

/// Return true if a PATH segment should be removed during v1 cleanup.
/// Removes segments that:
///   - expand to nothing (empty/whitespace)
///   - contain %NVM_HOME% or %NVM_SYMLINK% references (case-insensitive)
///   - match install_norm or symlink_norm exactly (case-insensitive, normalized)
fn shouldRemoveSegment(
    alloc: std.mem.Allocator,
    seg: []const u8,
    install_norm: ?[]const u8,
    symlink_norm: ?[]const u8,
) bool {
    const trimmed = std.mem.trim(u8, seg, " \t");
    if (trimmed.len == 0) return true;
    const seg_norm = normPath(alloc, trimmed) catch return false;
    defer alloc.free(seg_norm);
    if (std.mem.indexOf(u8, seg_norm, "%nvm_home%") != null) return true;
    if (std.mem.indexOf(u8, seg_norm, "%nvm_symlink%") != null) return true;
    if (install_norm) |n| if (std.mem.eql(u8, seg_norm, n)) return true;
    if (symlink_norm) |n| if (std.mem.eql(u8, seg_norm, n)) return true;
    return false;
}

/// Remove v1 NVM entries from the "Path" value in the given registry key.
fn cleanPath(
    alloc: std.mem.Allocator,
    root: HKEY,
    sub: []const u8,
    install_norm: ?[]const u8,
    symlink_norm: ?[]const u8,
) void {
    const hk = openKey(alloc, root, sub, true) orelse return;
    defer _ = RegCloseKey(hk);

    const rs = readRegString(alloc, hk, "Path") catch return;
    defer alloc.free(rs.value);

    var kept: std.ArrayListUnmanaged([]const u8) = .{};
    defer kept.deinit(alloc);

    var it = std.mem.splitScalar(u8, rs.value, ';');
    while (it.next()) |seg| {
        if (!shouldRemoveSegment(alloc, seg, install_norm, symlink_norm))
            kept.append(alloc, seg) catch {};
    }

    const new_path = std.mem.join(alloc, ";", kept.items) catch return;
    defer alloc.free(new_path);

    if (!std.mem.eql(u8, new_path, rs.value))
        writeRegString(alloc, hk, "Path", new_path, rs.reg_type);
}

/// Read a string value from a subkey beneath an already-opened key.
/// Used to inspect UninstallString / DisplayIcon for uninstall-entry matching.
fn readSubkeyString(alloc: std.mem.Allocator, parent_hk: HKEY, subkey_name: []const u8, value_name: []const u8) ?[]u8 {
    const sub_w = toW(alloc, subkey_name) catch return null;
    defer alloc.free(sub_w);
    var sub_hk: HKEY = undefined;
    if (RegOpenKeyExW(parent_hk, sub_w.ptr, 0, KEY_READ, &sub_hk) != ERROR_SUCCESS) return null;
    defer _ = RegCloseKey(sub_hk);
    const rs = readRegString(alloc, sub_hk, value_name) catch return null;
    return rs.value;
}

/// Return true if the given uninstall subkey's UninstallString or DisplayIcon
/// contains install_norm as a substring (case-insensitive, backslash-normalised).
fn uninstallEntryMatchesDir(
    alloc: std.mem.Allocator,
    parent_hk: HKEY,
    subkey_name: []const u8,
    install_norm: []const u8,
) bool {
    for ([_][]const u8{ "UninstallString", "DisplayIcon" }) |field| {
        const raw = readSubkeyString(alloc, parent_hk, subkey_name, field) orelse continue;
        defer alloc.free(raw);
        const norm = normPath(alloc, raw) catch continue;
        defer alloc.free(norm);
        if (std.mem.indexOf(u8, norm, install_norm) != null) return true;
    }
    return false;
}

/// Attempt to delete one uninstall key (key_name under uninstall_base) from root.
fn tryDeleteUninstallKey(
    alloc: std.mem.Allocator,
    root: HKEY,
    uninstall_base: []const u8,
    key_name: []const u8,
) void {
    const full = std.fmt.allocPrint(alloc, "{s}\\{s}", .{ uninstall_base, key_name }) catch return;
    defer alloc.free(full);
    const full_w = toW(alloc, full) catch return;
    defer alloc.free(full_w);
    _ = SHDeleteKeyW(root, full_w.ptr);
}

/// Remove nvm v1 uninstall entries from one hive + subkey combination.
fn removeUninstallFromHive(
    alloc: std.mem.Allocator,
    root: HKEY,
    base: []const u8,
    install_norm: ?[]const u8,
) void {
    // Always attempt the canonical nvm_is1 key name directly.
    tryDeleteUninstallKey(alloc, root, base, "nvm_is1");

    // If we know the old install dir, also scan for any other matching entries.
    const idir = install_norm orelse return;
    const base_hk = openKey(alloc, root, base, false) orelse return;
    defer _ = RegCloseKey(base_hk);

    // Snapshot subkey names before deleting (enumeration invalidates indices).
    var names: std.ArrayListUnmanaged([]u8) = .{};
    defer {
        for (names.items) |n| alloc.free(n);
        names.deinit(alloc);
    }

    var idx: DWORD = 0;
    var name_buf: [256]u16 = undefined;
    while (true) {
        var name_len: DWORD = @intCast(name_buf.len);
        const rc = RegEnumKeyExW(base_hk, idx, &name_buf, &name_len, null, null, null, null);
        if (rc == ERROR_NO_MORE_ITEMS) break;
        if (rc != ERROR_SUCCESS) break;
        const name_utf8 = std.unicode.utf16LeToUtf8Alloc(alloc, name_buf[0..name_len]) catch {
            idx += 1;
            continue;
        };
        names.append(alloc, name_utf8) catch {
            alloc.free(name_utf8);
        };
        idx += 1;
    }

    for (names.items) |name| {
        // nvm_is1 already handled above.
        if (std.ascii.eqlIgnoreCase(name, "nvm_is1")) continue;
        if (uninstallEntryMatchesDir(alloc, base_hk, name, idir))
            tryDeleteUninstallKey(alloc, root, base, name);
    }
}

/// Remove v1 uninstall registry entries from HKCU, HKLM, and HKLM\WOW6432Node.
fn removeUninstallEntries(alloc: std.mem.Allocator, install_norm: ?[]const u8) void {
    const base = "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall";
    const base_wow = "Software\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall";
    removeUninstallFromHive(alloc, windows.HKEY_CURRENT_USER, base, install_norm);
    removeUninstallFromHive(alloc, windows.HKEY_LOCAL_MACHINE, base, install_norm);
    removeUninstallFromHive(alloc, windows.HKEY_LOCAL_MACHINE, base_wow, install_norm);
}

/// Recursively delete a directory tree.
fn removeTree(path: []const u8) void {
    std.fs.deleteTreeAbsolute(path) catch |err| {
        logError("Failed to remove directory tree '{s}': {}", .{ path, err });
    };
}

fn fileExistsAbsolute(path: []const u8) bool {
    std.fs.accessAbsolute(path, .{}) catch return false;
    return true;
}

fn normalizeNodeExecutableInDir(alloc: std.mem.Allocator, install_path: []const u8) void {
    const node_path = std.fmt.allocPrint(alloc, "{s}\\node.exe", .{install_path}) catch return;
    defer alloc.free(node_path);
    const node64_path = std.fmt.allocPrint(alloc, "{s}\\node64.exe", .{install_path}) catch return;
    defer alloc.free(node64_path);
    const node32_path = std.fmt.allocPrint(alloc, "{s}\\node32.exe", .{install_path}) catch return;
    defer alloc.free(node32_path);

    const has_node = fileExistsAbsolute(node_path);
    const has_node64 = fileExistsAbsolute(node64_path);
    const has_node32 = fileExistsAbsolute(node32_path);

    if (has_node and has_node64) {
        std.fs.deleteFileAbsolute(node_path) catch |err| {
            logError("Failed to delete existing node.exe before promoting node64.exe in '{s}': {}", .{ install_path, err });
            return;
        };
        std.fs.renameAbsolute(node64_path, node_path) catch |err| {
            logError("Failed to rename node64.exe to node.exe in '{s}': {}", .{ install_path, err });
            return;
        };
        logMsg("Promoted node64.exe to node.exe in '{s}'", .{install_path});
    } else if (!has_node and has_node64) {
        std.fs.renameAbsolute(node64_path, node_path) catch |err| {
            logError("Failed to rename node64.exe to node.exe in '{s}': {}", .{ install_path, err });
            return;
        };
        logMsg("Renamed node64.exe to node.exe in '{s}'", .{install_path});
    }

    if (fileExistsAbsolute(node_path) and has_node32) {
        std.fs.deleteFileAbsolute(node32_path) catch |err| {
            logError("Failed to delete node32.exe in '{s}': {}", .{ install_path, err });
            return;
        };
        logMsg("Removed node32.exe in '{s}'", .{install_path});
    }
}

fn normalizeInstalledNodeExecutables(alloc: std.mem.Allocator, nvm_path: []const u8) void {
    const parent = std.fs.path.dirname(nvm_path) orelse {
        logError("normalize-installed-node-executables: could not determine parent directory of: {s}", .{nvm_path});
        return;
    };
    const installs_dir = std.fmt.allocPrint(alloc, "{s}\\installs", .{parent}) catch return;
    defer alloc.free(installs_dir);

    var dir = std.fs.openDirAbsolute(installs_dir, .{ .iterate = true }) catch |err| {
        logError("Failed to open installs directory '{s}': {}", .{ installs_dir, err });
        return;
    };
    defer dir.close();

    var iter = dir.iterate();
    while (iter.next() catch |err| {
        logError("Failed to enumerate installs directory '{s}': {}", .{ installs_dir, err });
        return;
    }) |entry| {
        if (entry.kind != .directory) continue;
        const install_path = std.fmt.allocPrint(alloc, "{s}\\{s}", .{ installs_dir, entry.name }) catch continue;
        defer alloc.free(install_path);
        normalizeNodeExecutableInDir(alloc, install_path);
    }
}

/// Launch `nvm_path --register-eventlog` with no console window and wait for exit.
fn runEventLogRegistration(alloc: std.mem.Allocator, nvm_path: []const u8) void {
    const cmd = std.fmt.allocPrint(alloc, "\"{s}\" --register-eventlog", .{nvm_path}) catch return;
    defer alloc.free(cmd);
    // CreateProcessW may modify the command-line buffer; use a mutable copy.
    const cmd_w = toW(alloc, cmd) catch return;
    defer alloc.free(cmd_w);

    var si = std.mem.zeroes(STARTUPINFOW);
    si.cb = @sizeOf(STARTUPINFOW);
    var pi = std.mem.zeroes(PROCESS_INFORMATION);

    if (CreateProcessW(null, cmd_w.ptr, null, null, 0, CREATE_NO_WINDOW, null, null, &si, &pi) == 0) {
        logError("Failed to launch nvm --register-eventlog: {s}", .{nvm_path});
        return;
    }
    _ = WaitForSingleObject(pi.hProcess, INFINITE);
    _ = CloseHandle(pi.hProcess);
    _ = CloseHandle(pi.hThread);
}

/// Launch `reshim.exe --force` from the utils\ sibling directory of nvm.exe.
fn reshim(alloc: std.mem.Allocator, nvm_path: []const u8) void {
    // Derive the utils\ dir from the nvm.exe path: strip the filename, append utils\reshim.exe.
    const parent = std.fs.path.dirname(nvm_path) orelse {
        logError("reshim: could not determine parent directory of: {s}", .{nvm_path});
        return;
    };
    const reshim_path = std.fmt.allocPrint(alloc, "{s}\\utils\\reshim.exe", .{parent}) catch return;
    defer alloc.free(reshim_path);

    const cmd = std.fmt.allocPrint(alloc, "\"{s}\" --force", .{reshim_path}) catch return;
    defer alloc.free(cmd);
    const cmd_w = toW(alloc, cmd) catch return;
    defer alloc.free(cmd_w);

    var si = std.mem.zeroes(STARTUPINFOW);
    si.cb = @sizeOf(STARTUPINFOW);
    var pi = std.mem.zeroes(PROCESS_INFORMATION);

    if (CreateProcessW(null, cmd_w.ptr, null, null, 0, CREATE_NO_WINDOW, null, null, &si, &pi) == 0) {
        logError("reshim: failed to launch reshim.exe --force: {s}", .{reshim_path});
        return;
    }
    _ = WaitForSingleObject(pi.hProcess, INFINITE);
    _ = CloseHandle(pi.hProcess);
    _ = CloseHandle(pi.hThread);
}

// ── Entry point ───────────────────────────────────────────────────────────────

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Initialise the global log state.
    g_log_alloc = alloc;
    defer g_log_buf.deinit(alloc);

    const args = std.process.argsAlloc(alloc) catch return;
    defer std.process.argsFree(alloc, args);

    var install_dir: ?[]const u8 = null;
    var symlink_path: ?[]const u8 = null;
    var new_nvm: ?[]const u8 = null;

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--install-dir") and i + 1 < args.len) {
            i += 1;
            install_dir = args[i];
        } else if (std.mem.eql(u8, args[i], "--symlink-path") and i + 1 < args.len) {
            i += 1;
            symlink_path = args[i];
        } else if (std.mem.eql(u8, args[i], "--new-nvm") and i + 1 < args.len) {
            i += 1;
            new_nvm = args[i];
        }
    }

    // Log header with Unix timestamp and invocation arguments.
    logMsg("=== nvm-upgrader v1->v2 migration log (ts:{d}) ===", .{std.time.timestamp()});
    logMsg("  --install-dir  : {s}", .{install_dir orelse "(not provided)"});
    logMsg("  --symlink-path : {s}", .{symlink_path orelse "(not provided)"});
    logMsg("  --new-nvm      : {s}", .{new_nvm orelse "(not provided)"});
    logMsg("", .{});

    // Pre-compute normalized (lowercase, no trailing backslash) paths for comparisons.
    const install_norm: ?[]u8 = if (install_dir) |d| normPath(alloc, d) catch null else null;
    defer if (install_norm) |n| alloc.free(n);
    const symlink_norm: ?[]u8 = if (symlink_path) |s| normPath(alloc, s) catch null else null;
    defer if (symlink_norm) |n| alloc.free(n);

    const user_env = "Environment";
    const system_env = "SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment";

    // 1. Remove the v1 symlink/junction directory.
    logMsg("[STEP 1] Remove v1 symlink/junction", .{});
    if (symlink_path) |sp| removeJunction(alloc, sp);

    // 2–3. Delete NVM_SYMLINK from both user and system environment.
    logMsg("[STEP 2] Delete NVM_SYMLINK registry values", .{});
    deleteRegValue(alloc, windows.HKEY_CURRENT_USER, user_env, "NVM_SYMLINK");
    deleteRegValue(alloc, windows.HKEY_LOCAL_MACHINE, system_env, "NVM_SYMLINK");

    // 4–5. Delete NVM_HOME from both user and system environment.
    //      The installer's EnsureNvmPathPriority re-creates HKCU NVM_HOME for v2 immediately after.
    logMsg("[STEP 3] Delete NVM_HOME registry values", .{});
    deleteRegValue(alloc, windows.HKEY_CURRENT_USER, user_env, "NVM_HOME");
    deleteRegValue(alloc, windows.HKEY_LOCAL_MACHINE, system_env, "NVM_HOME");

    // 6–7. Strip v1 path entries from user and system PATH values.
    logMsg("[STEP 4] Clean v1 entries from PATH", .{});
    cleanPath(alloc, windows.HKEY_CURRENT_USER, user_env, install_norm, symlink_norm);
    cleanPath(alloc, windows.HKEY_LOCAL_MACHINE, system_env, install_norm, symlink_norm);

    // 8. Remove the v1 "installed application" uninstall registry entries.
    logMsg("[STEP 5] Remove v1 uninstall registry entries", .{});
    removeUninstallEntries(alloc, install_norm);

    // 9. Remove the old v1 installation directory (e.g. %AppData%\Roaming\nvm).
    logMsg("[STEP 6] Remove v1 installation directory", .{});
    if (install_dir) |dir| removeTree(dir);

    // 10. Register the Windows Event Log source in the new nvm.exe binary.
    logMsg("[STEP 7] Register Windows Event Log source", .{});
    if (new_nvm) |nvm| runEventLogRegistration(alloc, nvm);

    // 11. Normalize legacy node*.exe names inside each installed Node version directory.
    logMsg("[STEP 8] Normalize installed node executables", .{});
    if (new_nvm) |nvm| normalizeInstalledNodeExecutables(alloc, nvm);

    // 12. Rebuild the .shim hardlinks for every installed Node version.
    logMsg("[STEP 9] Rebuild module shims (reshim --force)", .{});
    if (new_nvm) |nvm| reshim(alloc, nvm);

    logMsg("", .{});
    if (g_has_errors) {
        logMsg("Migration completed with errors (see above).", .{});
    } else {
        logMsg("Migration completed successfully.", .{});
    }

    // Write upgrade.log to install_dir only when errors were recorded.
    if (install_dir) |dir| flushUpgradeLog(dir);
}
