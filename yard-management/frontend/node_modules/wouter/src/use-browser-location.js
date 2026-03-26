import { useSyncExternalStore } from "./react-deps.js";

/**
 * History API docs @see https://developer.mozilla.org/en-US/docs/Web/API/History
 */
const eventPopstate = "popstate";
const eventPushState = "pushState";
const eventReplaceState = "replaceState";
const eventHashchange = "hashchange";
const events = [
  eventPopstate,
  eventPushState,
  eventReplaceState,
  eventHashchange,
];

const subscribeToLocationUpdates = (callback) => {
  for (const event of events) {
    addEventListener(event, callback);
  }
  return () => {
    for (const event of events) {
      removeEventListener(event, callback);
    }
  };
};

export const useLocationProperty = (fn, ssrFn) =>
  useSyncExternalStore(subscribeToLocationUpdates, fn, ssrFn);

const currentSearch = () => location.search;

export const useSearch = ({ ssrSearch } = {}) =>
  useLocationProperty(
    currentSearch,
    // != null checks for both null and undefined, but allows empty string ""
    // This allows proper hydration: server renders with ssrSearch="?foo",
    // client hydrates with just <Router /> and reads from location.search
    ssrSearch != null ? () => ssrSearch : currentSearch
  );

const currentPathname = () => location.pathname;

export const usePathname = ({ ssrPath } = {}) =>
  useLocationProperty(
    currentPathname,
    // != null checks for both null and undefined, but allows empty string ""
    // This allows proper hydration: server renders with ssrPath="/foo",
    // client hydrates with just <Router /> and reads from location.pathname
    ssrPath != null ? () => ssrPath : currentPathname
  );

const currentHistoryState = () => history.state;
export const useHistoryState = () =>
  useLocationProperty(currentHistoryState, () => null);

export const navigate = (to, { replace = false, state = null } = {}) =>
  history[replace ? eventReplaceState : eventPushState](state, "", to);

// the 2nd argument of the `useBrowserLocation` return value is a function
// that allows to perform a navigation.
export const useBrowserLocation = (opts = {}) => [usePathname(opts), navigate];

const patchKey = Symbol.for("wouter_v3");

// While History API does have `popstate` event, the only
// proper way to listen to changes via `push/replaceState`
// is to monkey-patch these methods.
//
// See https://stackoverflow.com/a/4585031
if (typeof history !== "undefined" && typeof window[patchKey] === "undefined") {
  for (const type of [eventPushState, eventReplaceState]) {
    const original = history[type];
    // TODO: we should be using unstable_batchedUpdates to avoid multiple re-renders,
    // however that will require an additional peer dependency on react-dom.
    // See: https://github.com/reactwg/react-18/discussions/86#discussioncomment-1567149
    history[type] = function () {
      const result = original.apply(this, arguments);
      const event = new Event(type);
      event.arguments = arguments;

      dispatchEvent(event);
      return result;
    };
  }

  // patch history object only once
  // See: https://github.com/molefrog/wouter/issues/167
  Object.defineProperty(window, patchKey, { value: true });
}
