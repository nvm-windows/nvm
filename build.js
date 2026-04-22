// This is a deno helper script to locally build the installer using Inno Setup
// Yeah, I know  it's not Node, but we need to compile this and Node SEAs on Win32 are a PITA.

// SHA-256 integrity manifest for Inno Setup build tool binaries.
// These hashes MUST match before any binary is executed.
// To update after an intentional upgrade, recompute with: sha256sum assets/buildtools/*
const BUILDTOOLS_CHECKSUMS = {
  'ISCmplr.dll':          'c2b1072fc64c7fefbf6ff409d529b3ebcc15b905169a0eb88750e4945cc9ded2',
  'ISPP.dll':             '07942d760809cea368541b872839682bd1979ebb1088280e3635ddc5febd521a',
  'islzma.dll':           '0b2e19e473a47e10578b05a2f3b43ad96603f3ee1e397c06a280c3b7458a76e2',
  'iscc.exe':             'e0d28a77aa6cba5c0e4e4a36cb5f6872112e53a69000aabf434d823e88881a27',
  'Setup.e32':            'e2bb346abf79ed6469d843ce4da057693690a41a42e2be7f449d21f061d34e0a',
  'SetupLdr.e32':         '7fc32e16574fa3142cc238e5ca46c8c871ffb79c9dcbe1cca0cbb45f8b82cf03',
  'Default.isl':          '0d37b0839caaf3ad97a11781f109f3a70403c08105da4bb4e9e40650dff76124',
  'ISPPBuiltins.iss':     'e4304ed8474ffc1de7f8ccd9015898b7fe49c334e9ed872807bbc97287d911f0',
  'WizModernImage.bmp':   'd148dc2569e9abc4b4da650b1920ef1ffdc10bbd6bc2e20a97ce44b1f9f78aea',
  'WizModernSmallImage.bmp': 'a7e560d419e85daf80cce980baa124ef7c73197d0f51a59a19f1866ee8edfe8c',
}

// Verify all build tool files match their expected SHA-256 hashes before execution.
// This guards against supply-chain attacks where a binary is silently replaced.
console.log('Verifying build tool integrity...')
for (const [filename, expectedHash] of Object.entries(BUILDTOOLS_CHECKSUMS)) {
  const filePath = `./assets/buildtools/${filename}`
  let fileBytes
  try {
    fileBytes = await Deno.readFile(filePath)
  } catch (e) {
    console.error(`INTEGRITY ERROR: Cannot read ${filePath}: ${e.message}`)
    Deno.exit(1)
  }
  const hashBuffer = await crypto.subtle.digest('SHA-256', fileBytes)
  const actualHash = Array.from(new Uint8Array(hashBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('')
  if (actualHash !== expectedHash) {
    console.error(`INTEGRITY ERROR: ${filename} hash mismatch!`)
    console.error(`  Expected: ${expectedHash}`)
    console.error(`  Actual:   ${actualHash}`)
    console.error('Build aborted. A build tool binary may have been tampered with.')
    console.error('If this is an intentional upgrade, update the hashes in build.js.')
    Deno.exit(1)
  }
}
console.log('Build tool integrity verified.')

const content = await Deno.readTextFile('./nvm.iss')
const data = JSON.parse(await Deno.readTextFile('./src/manifest.json'))
const {version} = data
const output = content.replaceAll('{{VERSION}}', version)
await Deno.writeTextFile('./.tmp.iss', output)

console.log('Viewing /.tmp.iss')
output.split("\n").forEach((line, num) => {
  let n = `${num+1}`
  while (n.length < 3) {
    n = ' ' + n
  }

  console.log(`${n} | ${line}`)
})

const command = await new Deno.Command('.\\assets\\buildtools\\iscc.exe', {
  args: ['.\\.tmp.iss'],
  stdout: 'piped',
  stderr: 'piped',
})

const process = command.spawn();

// Stream stdout
(async () => {
  const decoder = new TextDecoder();
  for await (const chunk of process.stdout) {
    console.log(decoder.decode(chunk));
  }
})();

// Stream stderr
(async () => {
  const decoder = new TextDecoder();
  for await (const chunk of process.stderr) {
    console.error(decoder.decode(chunk));
  }
})();

// Wait for completion
const status = await process.status;
Deno.remove('.\\.tmp.iss');
if (!status.success) {
  Deno.exit(status.code);
}
