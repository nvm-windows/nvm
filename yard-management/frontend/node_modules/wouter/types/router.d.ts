import {
  Path,
  SearchString,
  BaseLocationHook,
  BaseSearchHook,
  HrefsFormatter,
} from "./location-hook.js";

export type Parser = (
  route: Path,
  loose?: boolean
) => { pattern: RegExp; keys: string[] };

// Standard navigation options supported by all built-in location hooks
export type NavigateOptions<S = any> = {
  replace?: boolean;
  state?: S;
  /** Enable view transitions for this navigation (used with aroundNav) */
  transition?: boolean;
};

// Function that wraps navigate calls, useful for view transitions
export type AroundNavHandler = (
  navigate: (to: Path, options?: NavigateOptions) => void,
  to: Path,
  options?: NavigateOptions
) => void;

// the object returned from `useRouter`
export interface RouterObject {
  readonly hook: BaseLocationHook;
  readonly searchHook: BaseSearchHook;
  readonly base: Path;
  readonly ownBase: Path;
  readonly parser: Parser;
  readonly ssrPath?: Path;
  readonly ssrSearch?: SearchString;
  readonly ssrContext?: SsrContext;
  readonly hrefs: HrefsFormatter;
  readonly aroundNav: AroundNavHandler;
}

// state captured during SSR render
export type SsrContext = {
  // if a redirect was encountered, this will be populated with the path
  redirectTo?: Path;
  // HTTP status code to set for SSR response
  statusCode?: number;
};

// basic options to construct a router
export type RouterOptions = {
  hook?: BaseLocationHook;
  searchHook?: BaseSearchHook;
  base?: Path;
  parser?: Parser;
  ssrPath?: Path;
  ssrSearch?: SearchString;
  ssrContext?: SsrContext;
  hrefs?: HrefsFormatter;
  aroundNav?: AroundNavHandler;
};
