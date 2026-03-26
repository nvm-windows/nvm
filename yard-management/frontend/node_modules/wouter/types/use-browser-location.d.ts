import { Path, SearchString } from "./location-hook.js";

type Primitive = string | number | bigint | boolean | null | undefined | symbol;
export const useLocationProperty: <S extends Primitive>(
  fn: () => S,
  ssrFn?: () => S
) => S;

export type BrowserSearchHook = (options?: {
  ssrSearch?: SearchString;
}) => SearchString;

export const useSearch: BrowserSearchHook;

export const usePathname: (options?: { ssrPath?: Path }) => Path;

export const useHistoryState: <T = any>() => T;

export const navigate: <S = any>(
  to: string | URL,
  options?: { replace?: boolean; state?: S; transition?: boolean }
) => void;

/*
 * Default `useLocation`
 */

// The type of the default `useLocation` hook that wouter uses.
// It operates on current URL using History API, supports base path and can
// navigate with `pushState` or `replaceState`.
export type BrowserLocationHook = (options?: {
  ssrPath?: Path;
}) => [Path, typeof navigate];

export const useBrowserLocation: BrowserLocationHook;
