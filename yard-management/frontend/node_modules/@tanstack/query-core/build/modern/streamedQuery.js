// src/streamedQuery.ts
import { addConsumeAwareSignal, addToEnd } from "./utils.js";
function streamedQuery({
  streamFn,
  refetchMode = "reset",
  reducer = (items, chunk) => addToEnd(items, chunk),
  initialValue = []
}) {
  return async (context) => {
    const query = context.client.getQueryCache().find({ queryKey: context.queryKey, exact: true });
    const isRefetch = !!query && query.isFetched();
    if (isRefetch && refetchMode === "reset") {
      query.setState({
        ...query.resetState,
        fetchStatus: "fetching"
      });
    }
    let result = initialValue;
    let cancelled = false;
    const streamFnContext = addConsumeAwareSignal(
      {
        client: context.client,
        meta: context.meta,
        queryKey: context.queryKey,
        pageParam: context.pageParam,
        direction: context.direction
      },
      () => context.signal,
      () => cancelled = true
    );
    const stream = await streamFn(streamFnContext);
    const isReplaceRefetch = isRefetch && refetchMode === "replace";
    for await (const chunk of stream) {
      if (cancelled) {
        break;
      }
      if (isReplaceRefetch) {
        result = reducer(result, chunk);
      } else {
        context.client.setQueryData(
          context.queryKey,
          (prev) => reducer(prev === void 0 ? initialValue : prev, chunk)
        );
      }
    }
    if (isReplaceRefetch && !cancelled) {
      context.client.setQueryData(context.queryKey, result);
    }
    return context.client.getQueryData(context.queryKey) ?? initialValue;
  };
}
export {
  streamedQuery
};
//# sourceMappingURL=streamedQuery.js.map