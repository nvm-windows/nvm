import {
  BaseLocationHook,
  BaseSearchHook,
  Path,
  SearchString,
} from "./location-hook.js";

type Navigate<S = any> = (
  to: Path,
  options?: { replace?: boolean; state?: S; transition?: boolean }
) => void;

type HookReturnValue = {
  hook: BaseLocationHook;
  searchHook: BaseSearchHook;
  navigate: Navigate;
};
type StubHistory = { history: Path[]; reset: () => void };

export function memoryLocation(options?: {
  path?: Path;
  searchPath?: SearchString;
  static?: boolean;
  record?: false;
}): HookReturnValue;
export function memoryLocation(options?: {
  path?: Path;
  searchPath?: SearchString;
  static?: boolean;
  record: true;
}): HookReturnValue & StubHistory;
