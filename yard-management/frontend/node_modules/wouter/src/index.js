import { parse as parsePattern } from "regexparam";

import {
  useBrowserLocation,
  useSearch as useBrowserSearch,
} from "./use-browser-location.js";

import {
  useRef,
  useContext,
  createContext,
  isValidElement,
  cloneElement,
  createElement as h,
  Fragment,
  forwardRef,
  useIsomorphicLayoutEffect,
  useEvent,
  useMemo,
} from "./react-deps.js";
import { absolutePath, relativePath, sanitizeSearch } from "./paths.js";

/*
 * Router and router context. Router is a lightweight object that represents the current
 * routing options: how location is managed, base path etc.
 *
 * There is a default router present for most of the use cases, however it can be overridden
 * via the <Router /> component.
 */

const defaultRouter = {
  hook: useBrowserLocation,
  searchHook: useBrowserSearch,
  parser: parsePattern,
  base: "",
  // this option is used to override the current location during SSR
  ssrPath: undefined,
  ssrSearch: undefined,
  // optional context to track render state during SSR
  ssrContext: undefined,
  // customizes how `href` props are transformed for <Link />
  hrefs: (x) => x,
  // wraps navigate calls, useful for view transitions
  aroundNav: (n, t, o) => n(t, o),
};

const RouterCtx = createContext(defaultRouter);

// gets the closest parent router from the context
export const useRouter = () => useContext(RouterCtx);

/**
 * Parameters context. Used by `useParams()` to get the
 * matched params from the innermost `Route` component.
 */

const Params0 = {},
  ParamsCtx = createContext(Params0);

export const useParams = () => useContext(ParamsCtx);

/*
 * Part 1, Hooks API: useRoute and useLocation
 */

// Internal version of useLocation to avoid redundant useRouter calls

const useLocationFromRouter = (router) => {
  const [location, navigate] = router.hook(router);

  // the function reference should stay the same between re-renders, so that
  // it can be passed down as an element prop without any performance concerns.
  // (This is achieved via `useEvent`.)
  return [
    relativePath(router.base, location),
    useEvent((to, opts) =>
      router.aroundNav(navigate, absolutePath(to, router.base), opts)
    ),
  ];
};

export const useLocation = () => useLocationFromRouter(useRouter());

export const useSearch = () => {
  const router = useRouter();
  return sanitizeSearch(router.searchHook(router));
};

export const matchRoute = (parser, route, path, loose) => {
  // if the input is a regexp, skip parsing
  const { pattern, keys } =
    route instanceof RegExp
      ? { keys: false, pattern: route }
      : parser(route || "*", loose);

  // array destructuring loses keys, so this is done in two steps
  const result = pattern.exec(path) || [];

  // when parser is in "loose" mode, `$base` is equal to the
  // first part of the route that matches the pattern
  // (e.g. for pattern `/a/:b` and path `/a/1/2/3` the `$base` is `a/1`)
  // we use this for route nesting
  const [$base, ...matches] = result;

  return $base !== undefined
    ? [
        true,

        (() => {
          // for regex paths, `keys` will always be false

          // an object with parameters matched, e.g. { foo: "bar" } for "/:foo"
          // we "zip" two arrays here to construct the object
          // ["foo"], ["bar"] → { foo: "bar" }
          const groups =
            keys !== false
              ? Object.fromEntries(keys.map((key, i) => [key, matches[i]]))
              : result.groups;

          // convert the array to an instance of object
          // this makes it easier to integrate with the existing param implementation
          let obj = { ...matches };

          // merge named capture groups with matches array
          groups && Object.assign(obj, groups);

          return obj;
        })(),

        // the third value if only present when parser is in "loose" mode,
        // so that we can extract the base path for nested routes
        ...(loose ? [$base] : []),
      ]
    : [false, null];
};

export const useRoute = (pattern) =>
  matchRoute(useRouter().parser, pattern, useLocation()[0]);

/*
 * Part 2, Low Carb Router API: Router, Route, Link, Switch
 */

export const Router = ({ children, ...props }) => {
  // the router we will inherit from - it is the closest router in the tree,
  // unless the custom `hook` is provided (in that case it's the default one)
  const parent_ = useRouter();
  const parent = props.hook ? defaultRouter : parent_;

  // holds to the context value: the router object
  let value = parent;

  // when `ssrPath` contains a `?` character, we can extract the search from it.
  // also, ensure ssrSearch is always defined when ssrPath is provided, so that
  // useSearch behavior matches usePathname (proper SSR hydration when client
  // renders <Router> without props after server rendered with ssrPath/ssrSearch)
  const [path, search = props.ssrSearch ?? ""] =
    props.ssrPath?.split("?") ?? [];
  if (path) (props.ssrSearch = search), (props.ssrPath = path);

  // hooks can define their own `href` formatter (e.g. for hash location)
  props.hrefs = props.hrefs ?? props.hook?.hrefs;

  // hooks can define their own search hook (e.g. for memory location)
  props.searchHook = props.searchHook ?? props.hook?.searchHook;

  // what is happening below: to avoid unnecessary rerenders in child components,
  // we ensure that the router object reference is stable, unless there are any
  // changes that require reload (e.g. `base` prop changes -> all components that
  // get the router from the context should rerender, even if the component is memoized).
  // the expected behaviour is:
  //
  //   1) when the resulted router is no different from the parent, use parent
  //   2) if the custom `hook` prop is provided, we always inherit from the
  //      default router instead. this resets all previously overridden options.
  //   3) when the router is customized here, it should stay stable between renders
  let ref = useRef({}),
    prev = ref.current,
    next = prev;

  for (let k in parent) {
    const option =
      k === "base"
        ? /* base is special case, it is appended to the parent's base */
          parent[k] + (props[k] ?? "")
        : props[k] ?? parent[k];

    if (prev === next && option !== next[k]) {
      ref.current = next = { ...next };
    }

    next[k] = option;

    // the new router is no different from the parent or from the memoized value, use parent
    if (option !== parent[k] || option !== value[k]) value = next;
  }

  return h(RouterCtx.Provider, { value, children });
};

const h_route = ({ children, component }, params) => {
  // React-Router style `component` prop
  if (component) return h(component, { params });

  // support render prop or plain children
  return typeof children === "function" ? children(params) : children;
};

// Cache params object between renders if values are shallow equal
const useCachedParams = (value) => {
  let prev = useRef(Params0);
  const curr = prev.current;
  return (prev.current =
    // Update cache if number of params changed or any value changed
    Object.keys(value).length !== Object.keys(curr).length ||
    Object.entries(value).some(([k, v]) => v !== curr[k])
      ? value // Return new value if there are changes
      : curr); // Return cached value if nothing changed
};

export function useSearchParams() {
  const [location, navigate] = useLocation();

  const search = useSearch();
  const searchParams = useMemo(() => new URLSearchParams(search), [search]);

  // cached value before next render, so you can call setSearchParams multiple times
  let tempSearchParams = searchParams;

  const setSearchParams = useEvent((nextInit, options) => {
    tempSearchParams = new URLSearchParams(
      typeof nextInit === "function" ? nextInit(tempSearchParams) : nextInit
    );
    navigate(location + "?" + tempSearchParams, options);
  });

  return [searchParams, setSearchParams];
}

export const Route = ({ path, nest, match, ...renderProps }) => {
  const router = useRouter();
  const [location] = useLocationFromRouter(router);

  const [matches, routeParams, base] =
    // `match` is a special prop to give up control to the parent,
    // it is used by the `Switch` to avoid double matching
    match ?? matchRoute(router.parser, path, location, nest);

  // when `routeParams` is `null` (there was no match), the argument
  // below becomes {...null} = {}, see the Object Spread specs
  // https://tc39.es/proposal-object-rest-spread/#AbstractOperations-CopyDataProperties
  const params = useCachedParams({ ...useParams(), ...routeParams });

  if (!matches) return null;

  const children = base
    ? h(Router, { base }, h_route(renderProps, params))
    : h_route(renderProps, params);

  return h(ParamsCtx.Provider, { value: params, children });
};

export const Link = forwardRef((props, ref) => {
  const router = useRouter();
  const [currentPath, navigate] = useLocationFromRouter(router);

  const {
    to = "",
    href: targetPath = to,
    onClick: _onClick,
    asChild,
    children,
    className: cls,
    /* eslint-disable no-unused-vars */
    replace /* ignore nav props */,
    state /* ignore nav props */,
    transition /* ignore nav props */,
    /* eslint-enable no-unused-vars */

    ...restProps
  } = props;

  const onClick = useEvent((event) => {
    // ignores the navigation when clicked using right mouse button or
    // by holding a special modifier key: ctrl, command, win, alt, shift
    if (
      event.ctrlKey ||
      event.metaKey ||
      event.altKey ||
      event.shiftKey ||
      event.button !== 0
    )
      return;

    _onClick?.(event);
    if (!event.defaultPrevented) {
      event.preventDefault();
      navigate(targetPath, props);
    }
  });

  // handle nested routers and absolute paths
  const href = router.hrefs(
    targetPath[0] === "~" ? targetPath.slice(1) : router.base + targetPath,
    router // pass router as a second argument for convinience
  );

  return asChild && isValidElement(children)
    ? cloneElement(children, { onClick, href })
    : h("a", {
        ...restProps,
        onClick,
        href,
        // `className` can be a function to apply the class if this link is active
        className: cls?.call ? cls(currentPath === targetPath) : cls,
        children,
        ref,
      });
});

const flattenChildren = (children) =>
  Array.isArray(children)
    ? children.flatMap((c) =>
        flattenChildren(c && c.type === Fragment ? c.props.children : c)
      )
    : [children];

export const Switch = ({ children, location }) => {
  const router = useRouter();
  const [originalLocation] = useLocationFromRouter(router);

  for (const element of flattenChildren(children)) {
    let match = 0;

    if (
      isValidElement(element) &&
      // we don't require an element to be of type Route,
      // but we do require it to contain a truthy `path` prop.
      // this allows to use different components that wrap Route
      // inside of a switch, for example <AnimatedRoute />.
      (match = matchRoute(
        router.parser,
        element.props.path,
        location || originalLocation,
        element.props.nest
      ))[0]
    )
      return cloneElement(element, { match });
  }

  return null;
};

export const Redirect = (props) => {
  const { to, href = to } = props;
  const router = useRouter();
  const [, navigate] = useLocationFromRouter(router);
  const redirect = useEvent(() => navigate(to || href, props));
  const { ssrContext } = router;

  // redirect is guaranteed to be stable since it is returned from useEvent
  useIsomorphicLayoutEffect(() => {
    redirect();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  if (ssrContext) {
    ssrContext.redirectTo = to;
  }

  return null;
};
