export declare type Action<TData, TError, TVariables, TOnMutateResult> = ContinueAction_2 | ErrorAction_2<TError> | FailedAction_2<TError> | PendingAction<TVariables, TOnMutateResult> | PauseAction_2 | SuccessAction_2<TData>;

export declare type Action_alias_1<TData, TError> = ContinueAction | ErrorAction<TError> | FailedAction<TError> | FetchAction | InvalidateAction | PauseAction | SetStateAction<TData, TError> | SuccessAction<TData>;

export declare function addConsumeAwareSignal<T>(object: T, getSignal: () => AbortSignal, onCancelled: VoidFunction): T & {
    signal: AbortSignal;
};

export declare function addToEnd<T>(items: Array<T>, item: T, max?: number): Array<T>;

export declare function addToStart<T>(items: Array<T>, item: T, max?: number): Array<T>;

declare type AnyDataTag = {
    [dataTagSymbol]: any;
    [dataTagErrorSymbol]: any;
};
export { AnyDataTag }
export { AnyDataTag as AnyDataTag_alias_1 }

declare type BaseStreamedQueryParams<TQueryFnData, TQueryKey extends QueryKey> = {
    streamFn: (context: QueryFunctionContext<TQueryKey>) => AsyncIterable<TQueryFnData> | Promise<AsyncIterable<TQueryFnData>>;
    refetchMode?: 'append' | 'reset' | 'replace';
};

declare type BatchCallsCallback<T extends Array<unknown>> = (...args: T) => void;

declare type BatchNotifyFunction = (callback: () => void) => void;

declare class CancelledError extends Error {
    revert?: boolean;
    silent?: boolean;
    constructor(options?: CancelOptions);
}
export { CancelledError }
export { CancelledError as CancelledError_alias_1 }

declare interface CancelOptions {
    revert?: boolean;
    silent?: boolean;
}
export { CancelOptions }
export { CancelOptions as CancelOptions_alias_1 }

export declare function canFetch(networkMode: NetworkMode | undefined): boolean;

declare type CombineFn<TCombinedResult> = (result: Array<QueryObserverResult>) => TCombinedResult;

declare interface ContinueAction {
    type: 'continue';
}

declare interface ContinueAction_2 {
    type: 'continue';
}

export declare function createNotifyManager(): {
    readonly batch: <T>(callback: () => T) => T;
    /**
     * All calls to the wrapped function will be batched.
     */
    readonly batchCalls: <T extends Array<unknown>>(callback: BatchCallsCallback<T>) => BatchCallsCallback<T>;
    readonly schedule: (callback: NotifyCallback) => void;
    /**
     * Use this method to set a custom notify function.
     * This can be used to for example wrap notifications with `React.act` while running tests.
     */
    readonly setNotifyFunction: (fn: NotifyFunction) => void;
    /**
     * Use this method to set a custom function to batch notifications together into a single tick.
     * By default React Query will use the batch function provided by ReactDOM or React Native.
     */
    readonly setBatchNotifyFunction: (fn: BatchNotifyFunction) => void;
    readonly setScheduler: (fn: ScheduleFunction) => void;
};

export declare function createRetryer<TData = unknown, TError = DefaultError>(config: RetryerConfig<TData, TError>): Retryer<TData>;

declare type DataTag<TType, TValue, TError = UnsetMarker> = TType extends AnyDataTag ? TType : TType & {
    [dataTagSymbol]: TValue;
    [dataTagErrorSymbol]: TError;
};
export { DataTag }
export { DataTag as DataTag_alias_1 }

declare const dataTagErrorSymbol: unique symbol;

declare type dataTagErrorSymbol = typeof dataTagErrorSymbol;
export { dataTagErrorSymbol }
export { dataTagErrorSymbol as dataTagErrorSymbol_alias_1 }

declare const dataTagSymbol: unique symbol;

declare type dataTagSymbol = typeof dataTagSymbol;
export { dataTagSymbol }
export { dataTagSymbol as dataTagSymbol_alias_1 }

declare type DefaultedInfiniteQueryObserverOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown> = WithRequired<InfiniteQueryObserverOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>, 'throwOnError' | 'refetchOnReconnect' | 'queryHash'>;
export { DefaultedInfiniteQueryObserverOptions }
export { DefaultedInfiniteQueryObserverOptions as DefaultedInfiniteQueryObserverOptions_alias_1 }

declare type DefaultedQueryObserverOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> = WithRequired<QueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>, 'throwOnError' | 'refetchOnReconnect' | 'queryHash'>;
export { DefaultedQueryObserverOptions }
export { DefaultedQueryObserverOptions as DefaultedQueryObserverOptions_alias_1 }

declare type DefaultError = Register extends {
    defaultError: infer TError;
} ? TError : Error;
export { DefaultError }
export { DefaultError as DefaultError_alias_1 }

declare interface DefaultOptions<TError = DefaultError> {
    queries?: OmitKeyof<QueryObserverOptions<unknown, TError>, 'suspense' | 'queryKey'>;
    mutations?: MutationObserverOptions<unknown, TError, unknown, unknown>;
    hydrate?: HydrateOptions['defaultOptions'];
    dehydrate?: DehydrateOptions;
}
export { DefaultOptions }
export { DefaultOptions as DefaultOptions_alias_1 }

declare const defaultScheduler: ScheduleFunction;
export { defaultScheduler }
export { defaultScheduler as defaultScheduler_alias_1 }

declare function defaultShouldDehydrateMutation(mutation: Mutation): boolean;
export { defaultShouldDehydrateMutation }
export { defaultShouldDehydrateMutation as defaultShouldDehydrateMutation_alias_1 }

declare function defaultShouldDehydrateQuery(query: Query): boolean;
export { defaultShouldDehydrateQuery }
export { defaultShouldDehydrateQuery as defaultShouldDehydrateQuery_alias_1 }

export declare const defaultTimeoutProvider: TimeoutProvider;

declare type DefinedInfiniteQueryObserverResult<TData = unknown, TError = DefaultError> = InfiniteQueryObserverRefetchErrorResult<TData, TError> | InfiniteQueryObserverSuccessResult<TData, TError>;
export { DefinedInfiniteQueryObserverResult }
export { DefinedInfiniteQueryObserverResult as DefinedInfiniteQueryObserverResult_alias_1 }

declare type DefinedQueryObserverResult<TData = unknown, TError = DefaultError> = QueryObserverRefetchErrorResult<TData, TError> | QueryObserverSuccessResult<TData, TError>;
export { DefinedQueryObserverResult }
export { DefinedQueryObserverResult as DefinedQueryObserverResult_alias_1 }

declare function dehydrate(client: QueryClient, options?: DehydrateOptions): DehydratedState;
export { dehydrate }
export { dehydrate as dehydrate_alias_1 }

declare interface DehydratedMutation {
    mutationKey?: MutationKey;
    state: MutationState;
    meta?: MutationMeta;
    scope?: MutationScope;
}

declare interface DehydratedQuery {
    queryHash: string;
    queryKey: QueryKey;
    state: QueryState;
    promise?: Promise<unknown>;
    meta?: QueryMeta;
    dehydratedAt?: number;
}

declare interface DehydratedState {
    mutations: Array<DehydratedMutation>;
    queries: Array<DehydratedQuery>;
}
export { DehydratedState }
export { DehydratedState as DehydratedState_alias_1 }

declare interface DehydrateOptions {
    serializeData?: TransformerFn;
    shouldDehydrateMutation?: (mutation: Mutation) => boolean;
    shouldDehydrateQuery?: (query: Query) => boolean;
    shouldRedactErrors?: (error: unknown) => boolean;
}
export { DehydrateOptions }
export { DehydrateOptions as DehydrateOptions_alias_1 }

declare type DistributiveOmit<TObject, TKey extends keyof TObject> = TObject extends any ? Omit<TObject, TKey> : never;
export { DistributiveOmit }
export { DistributiveOmit as DistributiveOmit_alias_1 }

declare type DropLast<T extends ReadonlyArray<unknown>> = T extends readonly [
...infer R,
unknown
] ? readonly [...R] : never;

declare type Enabled<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> = boolean | ((query: Query<TQueryFnData, TError, TData, TQueryKey>) => boolean);
export { Enabled }
export { Enabled as Enabled_alias_1 }

declare type EnsureInfiniteQueryDataOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown> = FetchInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam> & {
    revalidateIfStale?: boolean;
};
export { EnsureInfiniteQueryDataOptions }
export { EnsureInfiniteQueryDataOptions as EnsureInfiniteQueryDataOptions_alias_1 }

declare interface EnsureQueryDataOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = never> extends FetchQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam> {
    revalidateIfStale?: boolean;
}
export { EnsureQueryDataOptions }
export { EnsureQueryDataOptions as EnsureQueryDataOptions_alias_1 }

export declare function ensureQueryFn<TQueryFnData = unknown, TQueryKey extends QueryKey = QueryKey>(options: {
    queryFn?: QueryFunction<TQueryFnData, TQueryKey> | SkipToken;
    queryHash?: string;
}, fetchOptions?: FetchOptions<TQueryFnData>): QueryFunction<TQueryFnData, TQueryKey>;

/**
 * Manages environment detection used by TanStack Query internals.
 */
declare const environmentManager: {
    /**
     * Returns whether the current runtime should be treated as a server environment.
     */
    isServer(): boolean;
    /**
     * Overrides the server check globally.
     */
    setIsServer(isServerValue: IsServerValue): void;
};
export { environmentManager }
export { environmentManager as environmentManager_alias_1 }

declare interface ErrorAction<TError> {
    type: 'error';
    error: TError;
}

declare interface ErrorAction_2<TError> {
    type: 'error';
    error: TError;
}

declare interface FailedAction<TError> {
    type: 'failed';
    failureCount: number;
    error: TError;
}

declare interface FailedAction_2<TError> {
    type: 'failed';
    failureCount: number;
    error: TError | null;
}

declare interface FetchAction {
    type: 'fetch';
    meta?: FetchMeta;
}

export declare interface FetchContext<TQueryFnData, TError, TData, TQueryKey extends QueryKey = QueryKey> {
    fetchFn: () => unknown | Promise<unknown>;
    fetchOptions?: FetchOptions;
    signal: AbortSignal;
    options: QueryOptions<TQueryFnData, TError, TData, any>;
    client: QueryClient;
    queryKey: TQueryKey;
    state: QueryState<TData, TError>;
}

export declare type FetchDirection = 'forward' | 'backward';

declare type FetchInfiniteQueryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown> = Omit<FetchQueryOptions<TQueryFnData, TError, InfiniteData<TData, TPageParam>, TQueryKey, TPageParam>, 'initialPageParam'> & InitialPageParam<TPageParam> & FetchInfiniteQueryPages<TQueryFnData, TPageParam>;
export { FetchInfiniteQueryOptions }
export { FetchInfiniteQueryOptions as FetchInfiniteQueryOptions_alias_1 }

declare type FetchInfiniteQueryPages<TQueryFnData = unknown, TPageParam = unknown> = {
    pages?: never;
} | {
    pages: number;
    getNextPageParam: GetNextPageParamFunction<TPageParam, TQueryFnData>;
};

export declare interface FetchMeta {
    fetchMore?: {
        direction: FetchDirection;
    };
}

declare interface FetchNextPageOptions extends ResultOptions {
    /**
     * If set to `true`, calling `fetchNextPage` repeatedly will invoke `queryFn` every time,
     * whether the previous invocation has resolved or not. Also, the result from previous invocations will be ignored.
     *
     * If set to `false`, calling `fetchNextPage` repeatedly won't have any effect until the first invocation has resolved.
     *
     * Defaults to `true`.
     */
    cancelRefetch?: boolean;
}
export { FetchNextPageOptions }
export { FetchNextPageOptions as FetchNextPageOptions_alias_1 }

export declare interface FetchOptions<TData = unknown> {
    cancelRefetch?: boolean;
    meta?: FetchMeta;
    initialPromise?: Promise<TData>;
}

declare interface FetchPreviousPageOptions extends ResultOptions {
    /**
     * If set to `true`, calling `fetchPreviousPage` repeatedly will invoke `queryFn` every time,
     * whether the previous invocation has resolved or not. Also, the result from previous invocations will be ignored.
     *
     * If set to `false`, calling `fetchPreviousPage` repeatedly won't have any effect until the first invocation has resolved.
     *
     * Defaults to `true`.
     */
    cancelRefetch?: boolean;
}
export { FetchPreviousPageOptions }
export { FetchPreviousPageOptions as FetchPreviousPageOptions_alias_1 }

declare interface FetchQueryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = never> extends WithRequired<QueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>, 'queryKey'> {
    initialPageParam?: never;
    /**
     * The time in milliseconds after data is considered stale.
     * If the data is fresh it will be returned from the cache.
     */
    staleTime?: StaleTimeFunction<TQueryFnData, TError, TData, TQueryKey>;
}
export { FetchQueryOptions }
export { FetchQueryOptions as FetchQueryOptions_alias_1 }

export declare function fetchState<TQueryFnData, TError, TData, TQueryKey extends QueryKey>(data: TData | undefined, options: QueryOptions<TQueryFnData, TError, TData, TQueryKey>): {
    readonly error?: null | undefined;
    readonly status?: "pending" | undefined;
    readonly fetchFailureCount: 0;
    readonly fetchFailureReason: null;
    readonly fetchStatus: "fetching" | "paused";
};

declare type FetchStatus = 'fetching' | 'paused' | 'idle';
export { FetchStatus }
export { FetchStatus as FetchStatus_alias_1 }

export declare class FocusManager extends Subscribable<Listener> {
    #private;
    constructor();
    protected onSubscribe(): void;
    protected onUnsubscribe(): void;
    setEventListener(setup: SetupFn): void;
    setFocused(focused?: boolean): void;
    onFocus(): void;
    isFocused(): boolean;
}

declare const focusManager: FocusManager;
export { focusManager }
export { focusManager as focusManager_alias_1 }

/**
 * Thenable types which matches React's types for promises
 *
 * React seemingly uses `.status`, `.value` and `.reason` properties on a promises to optimistically unwrap data from promises
 *
 * @see https://github.com/facebook/react/blob/main/packages/shared/ReactTypes.js#L112-L138
 * @see https://github.com/facebook/react/blob/4f604941569d2e8947ce1460a0b2997e835f37b9/packages/react-debug-tools/src/ReactDebugHooks.js#L224-L227
 */
declare interface Fulfilled<T> {
    status: 'fulfilled';
    value: T;
}

export declare type FulfilledThenable<T> = Promise<T> & Fulfilled<T>;

export declare function functionalUpdate<TInput, TOutput>(updater: Updater<TInput, TOutput>, input: TInput): TOutput;

export declare function getDefaultState<TData, TError, TVariables, TOnMutateResult>(): MutationState<TData, TError, TVariables, TOnMutateResult>;

declare type GetNextPageParamFunction<TPageParam, TQueryFnData = unknown> = (lastPage: TQueryFnData, allPages: Array<TQueryFnData>, lastPageParam: TPageParam, allPageParams: Array<TPageParam>) => TPageParam | undefined | null;
export { GetNextPageParamFunction }
export { GetNextPageParamFunction as GetNextPageParamFunction_alias_1 }

declare type GetPreviousPageParamFunction<TPageParam, TQueryFnData = unknown> = (firstPage: TQueryFnData, allPages: Array<TQueryFnData>, firstPageParam: TPageParam, allPageParams: Array<TPageParam>) => TPageParam | undefined | null;
export { GetPreviousPageParamFunction }
export { GetPreviousPageParamFunction as GetPreviousPageParamFunction_alias_1 }

/**
 * Default query & mutation keys hash function.
 * Hashes the value into a stable hash.
 */
declare function hashKey(queryKey: QueryKey | MutationKey): string;
export { hashKey }
export { hashKey as hashKey_alias_1 }

export declare function hashQueryKeyByOptions<TQueryKey extends QueryKey = QueryKey>(queryKey: TQueryKey, options?: Pick<QueryOptions<any, any, any, any>, 'queryKeyHashFn'>): string;

/**
 * Checks if there is a next page.
 */
export declare function hasNextPage(options: InfiniteQueryPageParamsOptions<any, any>, data?: InfiniteData<unknown>): boolean;

/**
 * Checks if there is a previous page.
 */
export declare function hasPreviousPage(options: InfiniteQueryPageParamsOptions<any, any>, data?: InfiniteData<unknown>): boolean;

declare function hydrate(client: QueryClient, dehydratedState: unknown, options?: HydrateOptions): void;
export { hydrate }
export { hydrate as hydrate_alias_1 }

declare interface HydrateOptions {
    defaultOptions?: {
        deserializeData?: TransformerFn;
        queries?: QueryOptions;
        mutations?: MutationOptions<unknown, DefaultError, unknown, unknown>;
    };
}
export { HydrateOptions }
export { HydrateOptions as HydrateOptions_alias_1 }

declare type InferDataFromTag<TQueryFnData, TTaggedQueryKey extends QueryKey> = TTaggedQueryKey extends DataTag<unknown, infer TaggedValue, unknown> ? TaggedValue : TQueryFnData;
export { InferDataFromTag }
export { InferDataFromTag as InferDataFromTag_alias_1 }

declare type InferErrorFromTag<TError, TTaggedQueryKey extends QueryKey> = TTaggedQueryKey extends DataTag<unknown, unknown, infer TaggedError> ? TaggedError extends UnsetMarker ? TError : TaggedError : TError;
export { InferErrorFromTag }
export { InferErrorFromTag as InferErrorFromTag_alias_1 }

declare interface InfiniteData<TData, TPageParam = unknown> {
    pages: Array<TData>;
    pageParams: Array<TPageParam>;
}
export { InfiniteData }
export { InfiniteData as InfiniteData_alias_1 }

export declare function infiniteQueryBehavior<TQueryFnData, TError, TData, TPageParam>(pages?: number): QueryBehavior<TQueryFnData, TError, InfiniteData<TData, TPageParam>>;

declare class InfiniteQueryObserver<TQueryFnData = unknown, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown> extends QueryObserver<TQueryFnData, TError, TData, InfiniteData<TQueryFnData, TPageParam>, TQueryKey> {
    subscribe: Subscribable<InfiniteQueryObserverListener<TData, TError>>['subscribe'];
    getCurrentResult: ReplaceReturnType<QueryObserver<TQueryFnData, TError, TData, InfiniteData<TQueryFnData, TPageParam>, TQueryKey>['getCurrentResult'], InfiniteQueryObserverResult<TData, TError>>;
    protected fetch: ReplaceReturnType<QueryObserver<TQueryFnData, TError, TData, InfiniteData<TQueryFnData, TPageParam>, TQueryKey>['fetch'], Promise<InfiniteQueryObserverResult<TData, TError>>>;
    constructor(client: QueryClient, options: InfiniteQueryObserverOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>);
    protected bindMethods(): void;
    setOptions(options: InfiniteQueryObserverOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>): void;
    getOptimisticResult(options: DefaultedInfiniteQueryObserverOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>): InfiniteQueryObserverResult<TData, TError>;
    fetchNextPage(options?: FetchNextPageOptions): Promise<InfiniteQueryObserverResult<TData, TError>>;
    fetchPreviousPage(options?: FetchPreviousPageOptions): Promise<InfiniteQueryObserverResult<TData, TError>>;
    protected createResult(query: Query<TQueryFnData, TError, InfiniteData<TQueryFnData, TPageParam>, TQueryKey>, options: InfiniteQueryObserverOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>): InfiniteQueryObserverResult<TData, TError>;
}
export { InfiniteQueryObserver }
export { InfiniteQueryObserver as InfiniteQueryObserver_alias_1 }

declare interface InfiniteQueryObserverBaseResult<TData = unknown, TError = DefaultError> extends QueryObserverBaseResult<TData, TError> {
    /**
     * This function allows you to fetch the next "page" of results.
     */
    fetchNextPage: (options?: FetchNextPageOptions) => Promise<InfiniteQueryObserverResult<TData, TError>>;
    /**
     * This function allows you to fetch the previous "page" of results.
     */
    fetchPreviousPage: (options?: FetchPreviousPageOptions) => Promise<InfiniteQueryObserverResult<TData, TError>>;
    /**
     * Will be `true` if there is a next page to be fetched (known via the `getNextPageParam` option).
     */
    hasNextPage: boolean;
    /**
     * Will be `true` if there is a previous page to be fetched (known via the `getPreviousPageParam` option).
     */
    hasPreviousPage: boolean;
    /**
     * Will be `true` if the query failed while fetching the next page.
     */
    isFetchNextPageError: boolean;
    /**
     * Will be `true` while fetching the next page with `fetchNextPage`.
     */
    isFetchingNextPage: boolean;
    /**
     * Will be `true` if the query failed while fetching the previous page.
     */
    isFetchPreviousPageError: boolean;
    /**
     * Will be `true` while fetching the previous page with `fetchPreviousPage`.
     */
    isFetchingPreviousPage: boolean;
}
export { InfiniteQueryObserverBaseResult }
export { InfiniteQueryObserverBaseResult as InfiniteQueryObserverBaseResult_alias_1 }

declare type InfiniteQueryObserverListener<TData, TError> = (result: InfiniteQueryObserverResult<TData, TError>) => void;

declare interface InfiniteQueryObserverLoadingErrorResult<TData = unknown, TError = DefaultError> extends InfiniteQueryObserverBaseResult<TData, TError> {
    data: undefined;
    error: TError;
    isError: true;
    isPending: false;
    isLoading: false;
    isLoadingError: true;
    isRefetchError: false;
    isFetchNextPageError: false;
    isFetchPreviousPageError: false;
    isSuccess: false;
    isPlaceholderData: false;
    status: 'error';
}
export { InfiniteQueryObserverLoadingErrorResult }
export { InfiniteQueryObserverLoadingErrorResult as InfiniteQueryObserverLoadingErrorResult_alias_1 }

declare interface InfiniteQueryObserverLoadingResult<TData = unknown, TError = DefaultError> extends InfiniteQueryObserverBaseResult<TData, TError> {
    data: undefined;
    error: null;
    isError: false;
    isPending: true;
    isLoading: true;
    isLoadingError: false;
    isRefetchError: false;
    isFetchNextPageError: false;
    isFetchPreviousPageError: false;
    isSuccess: false;
    isPlaceholderData: false;
    status: 'pending';
}
export { InfiniteQueryObserverLoadingResult }
export { InfiniteQueryObserverLoadingResult as InfiniteQueryObserverLoadingResult_alias_1 }

declare interface InfiniteQueryObserverOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown> extends QueryObserverOptions<TQueryFnData, TError, TData, InfiniteData<TQueryFnData, TPageParam>, TQueryKey, TPageParam>, InfiniteQueryPageParamsOptions<TQueryFnData, TPageParam> {
}
export { InfiniteQueryObserverOptions }
export { InfiniteQueryObserverOptions as InfiniteQueryObserverOptions_alias_1 }

declare interface InfiniteQueryObserverPendingResult<TData = unknown, TError = DefaultError> extends InfiniteQueryObserverBaseResult<TData, TError> {
    data: undefined;
    error: null;
    isError: false;
    isPending: true;
    isLoadingError: false;
    isRefetchError: false;
    isFetchNextPageError: false;
    isFetchPreviousPageError: false;
    isSuccess: false;
    isPlaceholderData: false;
    status: 'pending';
}
export { InfiniteQueryObserverPendingResult }
export { InfiniteQueryObserverPendingResult as InfiniteQueryObserverPendingResult_alias_1 }

declare interface InfiniteQueryObserverPlaceholderResult<TData = unknown, TError = DefaultError> extends InfiniteQueryObserverBaseResult<TData, TError> {
    data: TData;
    isError: false;
    error: null;
    isPending: false;
    isLoading: false;
    isLoadingError: false;
    isRefetchError: false;
    isSuccess: true;
    isPlaceholderData: true;
    isFetchNextPageError: false;
    isFetchPreviousPageError: false;
    status: 'success';
}
export { InfiniteQueryObserverPlaceholderResult }
export { InfiniteQueryObserverPlaceholderResult as InfiniteQueryObserverPlaceholderResult_alias_1 }

declare interface InfiniteQueryObserverRefetchErrorResult<TData = unknown, TError = DefaultError> extends InfiniteQueryObserverBaseResult<TData, TError> {
    data: TData;
    error: TError;
    isError: true;
    isPending: false;
    isLoading: false;
    isLoadingError: false;
    isRefetchError: true;
    isSuccess: false;
    isPlaceholderData: false;
    status: 'error';
}
export { InfiniteQueryObserverRefetchErrorResult }
export { InfiniteQueryObserverRefetchErrorResult as InfiniteQueryObserverRefetchErrorResult_alias_1 }

declare type InfiniteQueryObserverResult<TData = unknown, TError = DefaultError> = DefinedInfiniteQueryObserverResult<TData, TError> | InfiniteQueryObserverLoadingErrorResult<TData, TError> | InfiniteQueryObserverLoadingResult<TData, TError> | InfiniteQueryObserverPendingResult<TData, TError> | InfiniteQueryObserverPlaceholderResult<TData, TError>;
export { InfiniteQueryObserverResult }
export { InfiniteQueryObserverResult as InfiniteQueryObserverResult_alias_1 }

declare interface InfiniteQueryObserverSuccessResult<TData = unknown, TError = DefaultError> extends InfiniteQueryObserverBaseResult<TData, TError> {
    data: TData;
    error: null;
    isError: false;
    isPending: false;
    isLoading: false;
    isLoadingError: false;
    isRefetchError: false;
    isFetchNextPageError: false;
    isFetchPreviousPageError: false;
    isSuccess: true;
    isPlaceholderData: false;
    status: 'success';
}
export { InfiniteQueryObserverSuccessResult }
export { InfiniteQueryObserverSuccessResult as InfiniteQueryObserverSuccessResult_alias_1 }

declare interface InfiniteQueryPageParamsOptions<TQueryFnData = unknown, TPageParam = unknown> extends InitialPageParam<TPageParam> {
    /**
     * This function can be set to automatically get the previous cursor for infinite queries.
     * The result will also be used to determine the value of `hasPreviousPage`.
     */
    getPreviousPageParam?: GetPreviousPageParamFunction<TPageParam, TQueryFnData>;
    /**
     * This function can be set to automatically get the next cursor for infinite queries.
     * The result will also be used to determine the value of `hasNextPage`.
     */
    getNextPageParam: GetNextPageParamFunction<TPageParam, TQueryFnData>;
}
export { InfiniteQueryPageParamsOptions }
export { InfiniteQueryPageParamsOptions as InfiniteQueryPageParamsOptions_alias_1 }

declare type InitialDataFunction<T> = () => T | undefined;
export { InitialDataFunction }
export { InitialDataFunction as InitialDataFunction_alias_1 }

declare interface InitialPageParam<TPageParam = unknown> {
    initialPageParam: TPageParam;
}
export { InitialPageParam }
export { InitialPageParam as InitialPageParam_alias_1 }

declare interface InvalidateAction {
    type: 'invalidate';
}

declare interface InvalidateOptions extends RefetchOptions {
}
export { InvalidateOptions }
export { InvalidateOptions as InvalidateOptions_alias_1 }

declare interface InvalidateQueryFilters<TQueryKey extends QueryKey = QueryKey> extends QueryFilters<TQueryKey> {
    refetchType?: QueryTypeFilter | 'none';
}
export { InvalidateQueryFilters }
export { InvalidateQueryFilters as InvalidateQueryFilters_alias_1 }

/**
 * @deprecated Use instanceof `CancelledError` instead.
 */
declare function isCancelledError(value: any): value is CancelledError;
export { isCancelledError }
export { isCancelledError as isCancelledError_alias_1 }

export declare function isPlainArray(value: unknown): value is Array<unknown>;

export declare function isPlainObject(o: any): o is Record<PropertyKey, unknown>;

/** @deprecated
 * use `environmentManager.isServer()` instead.
 */
declare const isServer: boolean;
export { isServer }
export { isServer as isServer_alias_1 }

export declare type IsServerValue = () => boolean;

export declare function isValidTimeout(value: unknown): value is number;

declare function keepPreviousData<T>(previousData: T | undefined): T | undefined;
export { keepPreviousData }
export { keepPreviousData as keepPreviousData_alias_1 }

declare type Listener = (focused: boolean) => void;

declare type Listener_2 = (online: boolean) => void;

/**
 * Wrapping `setTimeout` is awkward from a typing perspective because platform
 * typings may extend the return type of `setTimeout`. For example, NodeJS
 * typings add `NodeJS.Timeout`; but a non-default `timeoutManager` may not be
 * able to return such a type.
 */
declare type ManagedTimerId = number | {
    [Symbol.toPrimitive]: () => number;
};
export { ManagedTimerId }
export { ManagedTimerId as ManagedTimerId_alias_1 }

declare function matchMutation(filters: MutationFilters, mutation: Mutation<any, any>): boolean;
export { matchMutation }
export { matchMutation as matchMutation_alias_1 }

declare function matchQuery(filters: QueryFilters, query: Query<any, any, any, any>): boolean;
export { matchQuery }
export { matchQuery as matchQuery_alias_1 }

declare type MutateFunction<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> = (variables: TVariables, options?: MutateOptions<TData, TError, TVariables, TOnMutateResult>) => Promise<TData>;
export { MutateFunction }
export { MutateFunction as MutateFunction_alias_1 }

declare interface MutateOptions<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> {
    onSuccess?: (data: TData, variables: TVariables, onMutateResult: TOnMutateResult | undefined, context: MutationFunctionContext) => void;
    onError?: (error: TError, variables: TVariables, onMutateResult: TOnMutateResult | undefined, context: MutationFunctionContext) => void;
    onSettled?: (data: TData | undefined, error: TError | null, variables: TVariables, onMutateResult: TOnMutateResult | undefined, context: MutationFunctionContext) => void;
}
export { MutateOptions }
export { MutateOptions as MutateOptions_alias_1 }

declare class Mutation<TData = unknown, TError = DefaultError, TVariables = unknown, TOnMutateResult = unknown> extends Removable {
    #private;
    state: MutationState<TData, TError, TVariables, TOnMutateResult>;
    options: MutationOptions<TData, TError, TVariables, TOnMutateResult>;
    readonly mutationId: number;
    constructor(config: MutationConfig<TData, TError, TVariables, TOnMutateResult>);
    setOptions(options: MutationOptions<TData, TError, TVariables, TOnMutateResult>): void;
    get meta(): MutationMeta | undefined;
    addObserver(observer: MutationObserver_2<any, any, any, any>): void;
    removeObserver(observer: MutationObserver_2<any, any, any, any>): void;
    protected optionalRemove(): void;
    continue(): Promise<unknown>;
    execute(variables: TVariables): Promise<TData>;
}
export { Mutation }
export { Mutation as Mutation_alias_1 }

declare class MutationCache extends Subscribable<MutationCacheListener> {
    #private;
    config: MutationCacheConfig;
    constructor(config?: MutationCacheConfig);
    build<TData, TError, TVariables, TOnMutateResult>(client: QueryClient, options: MutationOptions<TData, TError, TVariables, TOnMutateResult>, state?: MutationState<TData, TError, TVariables, TOnMutateResult>): Mutation<TData, TError, TVariables, TOnMutateResult>;
    add(mutation: Mutation<any, any, any, any>): void;
    remove(mutation: Mutation<any, any, any, any>): void;
    canRun(mutation: Mutation<any, any, any, any>): boolean;
    runNext(mutation: Mutation<any, any, any, any>): Promise<unknown>;
    clear(): void;
    getAll(): Array<Mutation>;
    find<TData = unknown, TError = DefaultError, TVariables = any, TOnMutateResult = unknown>(filters: MutationFilters): Mutation<TData, TError, TVariables, TOnMutateResult> | undefined;
    findAll(filters?: MutationFilters): Array<Mutation>;
    notify(event: MutationCacheNotifyEvent): void;
    resumePausedMutations(): Promise<unknown>;
}
export { MutationCache }
export { MutationCache as MutationCache_alias_1 }

declare interface MutationCacheConfig {
    onError?: (error: DefaultError, variables: unknown, onMutateResult: unknown, mutation: Mutation<unknown, unknown, unknown>, context: MutationFunctionContext) => Promise<unknown> | unknown;
    onSuccess?: (data: unknown, variables: unknown, onMutateResult: unknown, mutation: Mutation<unknown, unknown, unknown>, context: MutationFunctionContext) => Promise<unknown> | unknown;
    onMutate?: (variables: unknown, mutation: Mutation<unknown, unknown, unknown>, context: MutationFunctionContext) => Promise<unknown> | unknown;
    onSettled?: (data: unknown | undefined, error: DefaultError | null, variables: unknown, onMutateResult: unknown, mutation: Mutation<unknown, unknown, unknown>, context: MutationFunctionContext) => Promise<unknown> | unknown;
}

declare type MutationCacheListener = (event: MutationCacheNotifyEvent) => void;

declare type MutationCacheNotifyEvent = NotifyEventMutationAdded | NotifyEventMutationRemoved | NotifyEventMutationObserverAdded | NotifyEventMutationObserverRemoved | NotifyEventMutationObserverOptionsUpdated | NotifyEventMutationUpdated;
export { MutationCacheNotifyEvent }
export { MutationCacheNotifyEvent as MutationCacheNotifyEvent_alias_1 }

declare interface MutationConfig<TData, TError, TVariables, TOnMutateResult> {
    client: QueryClient;
    mutationId: number;
    mutationCache: MutationCache;
    options: MutationOptions<TData, TError, TVariables, TOnMutateResult>;
    state?: MutationState<TData, TError, TVariables, TOnMutateResult>;
}

declare interface MutationFilters<TData = unknown, TError = DefaultError, TVariables = unknown, TOnMutateResult = unknown> {
    /**
     * Match mutation key exactly
     */
    exact?: boolean;
    /**
     * Include mutations matching this predicate function
     */
    predicate?: (mutation: Mutation<TData, TError, TVariables, TOnMutateResult>) => boolean;
    /**
     * Include mutations matching this mutation key
     */
    mutationKey?: TuplePrefixes<MutationKey>;
    /**
     * Filter by mutation status
     */
    status?: MutationStatus;
}
export { MutationFilters }
export { MutationFilters as MutationFilters_alias_1 }

declare type MutationFunction<TData = unknown, TVariables = unknown> = (variables: TVariables, context: MutationFunctionContext) => Promise<TData>;
export { MutationFunction }
export { MutationFunction as MutationFunction_alias_1 }

declare type MutationFunctionContext = {
    client: QueryClient;
    meta: MutationMeta | undefined;
    mutationKey?: MutationKey;
};
export { MutationFunctionContext }
export { MutationFunctionContext as MutationFunctionContext_alias_1 }

declare type MutationKey = Register extends {
    mutationKey: infer TMutationKey;
} ? TMutationKey extends ReadonlyArray<unknown> ? TMutationKey : TMutationKey extends Array<unknown> ? TMutationKey : ReadonlyArray<unknown> : ReadonlyArray<unknown>;
export { MutationKey }
export { MutationKey as MutationKey_alias_1 }

declare type MutationMeta = Register extends {
    mutationMeta: infer TMutationMeta;
} ? TMutationMeta extends Record<string, unknown> ? TMutationMeta : Record<string, unknown> : Record<string, unknown>;
export { MutationMeta }
export { MutationMeta as MutationMeta_alias_1 }

declare class MutationObserver_2<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> extends Subscribable<MutationObserverListener<TData, TError, TVariables, TOnMutateResult>> {
    #private;
    options: MutationObserverOptions<TData, TError, TVariables, TOnMutateResult>;
    constructor(client: QueryClient, options: MutationObserverOptions<TData, TError, TVariables, TOnMutateResult>);
    protected bindMethods(): void;
    setOptions(options: MutationObserverOptions<TData, TError, TVariables, TOnMutateResult>): void;
    protected onUnsubscribe(): void;
    onMutationUpdate(action: Action<TData, TError, TVariables, TOnMutateResult>): void;
    getCurrentResult(): MutationObserverResult<TData, TError, TVariables, TOnMutateResult>;
    reset(): void;
    mutate(variables: TVariables, options?: MutateOptions<TData, TError, TVariables, TOnMutateResult>): Promise<TData>;
}
export { MutationObserver_2 as MutationObserver }
export { MutationObserver_2 as MutationObserver_alias_1 }

declare interface MutationObserverBaseResult<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> extends MutationState<TData, TError, TVariables, TOnMutateResult> {
    /**
     * The last successfully resolved data for the mutation.
     */
    data: TData | undefined;
    /**
     * The variables object passed to the `mutationFn`.
     */
    variables: TVariables | undefined;
    /**
     * The error object for the mutation, if an error was encountered.
     * - Defaults to `null`.
     */
    error: TError | null;
    /**
     * A boolean variable derived from `status`.
     * - `true` if the last mutation attempt resulted in an error.
     */
    isError: boolean;
    /**
     * A boolean variable derived from `status`.
     * - `true` if the mutation is in its initial state prior to executing.
     */
    isIdle: boolean;
    /**
     * A boolean variable derived from `status`.
     * - `true` if the mutation is currently executing.
     */
    isPending: boolean;
    /**
     * A boolean variable derived from `status`.
     * - `true` if the last mutation attempt was successful.
     */
    isSuccess: boolean;
    /**
     * The status of the mutation.
     * - Will be:
     *   - `idle` initial status prior to the mutation function executing.
     *   - `pending` if the mutation is currently executing.
     *   - `error` if the last mutation attempt resulted in an error.
     *   - `success` if the last mutation attempt was successful.
     */
    status: MutationStatus;
    /**
     * The mutation function you can call with variables to trigger the mutation and optionally hooks on additional callback options.
     * @param variables - The variables object to pass to the `mutationFn`.
     * @param options.onSuccess - This function will fire when the mutation is successful and will be passed the mutation's result.
     * @param options.onError - This function will fire if the mutation encounters an error and will be passed the error.
     * @param options.onSettled - This function will fire when the mutation is either successfully fetched or encounters an error and be passed either the data or error.
     * @remarks
     * - If you make multiple requests, `onSuccess` will fire only after the latest call you've made.
     * - All the callback functions (`onSuccess`, `onError`, `onSettled`) are void functions, and the returned value will be ignored.
     */
    mutate: MutateFunction<TData, TError, TVariables, TOnMutateResult>;
    /**
     * A function to clean the mutation internal state (i.e., it resets the mutation to its initial state).
     */
    reset: () => void;
}
export { MutationObserverBaseResult }
export { MutationObserverBaseResult as MutationObserverBaseResult_alias_1 }

declare interface MutationObserverErrorResult<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> extends MutationObserverBaseResult<TData, TError, TVariables, TOnMutateResult> {
    data: undefined;
    error: TError;
    variables: TVariables;
    isError: true;
    isIdle: false;
    isPending: false;
    isSuccess: false;
    status: 'error';
}
export { MutationObserverErrorResult }
export { MutationObserverErrorResult as MutationObserverErrorResult_alias_1 }

declare interface MutationObserverIdleResult<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> extends MutationObserverBaseResult<TData, TError, TVariables, TOnMutateResult> {
    data: undefined;
    variables: undefined;
    error: null;
    isError: false;
    isIdle: true;
    isPending: false;
    isSuccess: false;
    status: 'idle';
}
export { MutationObserverIdleResult }
export { MutationObserverIdleResult as MutationObserverIdleResult_alias_1 }

declare type MutationObserverListener<TData, TError, TVariables, TOnMutateResult> = (result: MutationObserverResult<TData, TError, TVariables, TOnMutateResult>) => void;

declare interface MutationObserverLoadingResult<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> extends MutationObserverBaseResult<TData, TError, TVariables, TOnMutateResult> {
    data: undefined;
    variables: TVariables;
    error: null;
    isError: false;
    isIdle: false;
    isPending: true;
    isSuccess: false;
    status: 'pending';
}
export { MutationObserverLoadingResult }
export { MutationObserverLoadingResult as MutationObserverLoadingResult_alias_1 }

declare interface MutationObserverOptions<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> extends MutationOptions<TData, TError, TVariables, TOnMutateResult> {
    throwOnError?: boolean | ((error: TError) => boolean);
}
export { MutationObserverOptions }
export { MutationObserverOptions as MutationObserverOptions_alias_1 }

declare type MutationObserverResult<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> = MutationObserverIdleResult<TData, TError, TVariables, TOnMutateResult> | MutationObserverLoadingResult<TData, TError, TVariables, TOnMutateResult> | MutationObserverErrorResult<TData, TError, TVariables, TOnMutateResult> | MutationObserverSuccessResult<TData, TError, TVariables, TOnMutateResult>;
export { MutationObserverResult }
export { MutationObserverResult as MutationObserverResult_alias_1 }

declare interface MutationObserverSuccessResult<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> extends MutationObserverBaseResult<TData, TError, TVariables, TOnMutateResult> {
    data: TData;
    error: null;
    variables: TVariables;
    isError: false;
    isIdle: false;
    isPending: false;
    isSuccess: true;
    status: 'success';
}
export { MutationObserverSuccessResult }
export { MutationObserverSuccessResult as MutationObserverSuccessResult_alias_1 }

declare interface MutationOptions<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> {
    mutationFn?: MutationFunction<TData, TVariables>;
    mutationKey?: MutationKey;
    onMutate?: (variables: TVariables, context: MutationFunctionContext) => Promise<TOnMutateResult> | TOnMutateResult;
    onSuccess?: (data: TData, variables: TVariables, onMutateResult: TOnMutateResult, context: MutationFunctionContext) => Promise<unknown> | unknown;
    onError?: (error: TError, variables: TVariables, onMutateResult: TOnMutateResult | undefined, context: MutationFunctionContext) => Promise<unknown> | unknown;
    onSettled?: (data: TData | undefined, error: TError | null, variables: TVariables, onMutateResult: TOnMutateResult | undefined, context: MutationFunctionContext) => Promise<unknown> | unknown;
    retry?: RetryValue<TError>;
    retryDelay?: RetryDelayValue<TError>;
    networkMode?: NetworkMode;
    gcTime?: number;
    _defaulted?: boolean;
    meta?: MutationMeta;
    scope?: MutationScope;
}
export { MutationOptions }
export { MutationOptions as MutationOptions_alias_1 }

declare type MutationScope = {
    id: string;
};
export { MutationScope }
export { MutationScope as MutationScope_alias_1 }

declare interface MutationState<TData = unknown, TError = DefaultError, TVariables = unknown, TOnMutateResult = unknown> {
    context: TOnMutateResult | undefined;
    data: TData | undefined;
    error: TError | null;
    failureCount: number;
    failureReason: TError | null;
    isPaused: boolean;
    status: MutationStatus;
    variables: TVariables | undefined;
    submittedAt: number;
}
export { MutationState }
export { MutationState as MutationState_alias_1 }

declare type MutationStatus = 'idle' | 'pending' | 'success' | 'error';
export { MutationStatus }
export { MutationStatus as MutationStatus_alias_1 }

declare type NetworkMode = 'online' | 'always' | 'offlineFirst';
export { NetworkMode }
export { NetworkMode as NetworkMode_alias_1 }

declare type NoInfer_2<T> = [T][T extends any ? 0 : never];
export { NoInfer_2 as NoInfer }
export { NoInfer_2 as NoInfer_alias_1 }

declare type NonFunctionGuard<T> = T extends Function ? never : T;

declare type NonUndefinedGuard<T> = T extends undefined ? never : T;
export { NonUndefinedGuard }
export { NonUndefinedGuard as NonUndefinedGuard_alias_1 }

declare function noop(): void;

declare function noop(): undefined;
export { noop }
export { noop as noop_alias_1 }

declare type NotifyCallback = () => void;

declare interface NotifyEvent {
    type: NotifyEventType;
}
export { NotifyEvent }
export { NotifyEvent as NotifyEvent_alias_1 }

declare interface NotifyEventMutationAdded extends NotifyEvent {
    type: 'added';
    mutation: Mutation<any, any, any, any>;
}

declare interface NotifyEventMutationObserverAdded extends NotifyEvent {
    type: 'observerAdded';
    mutation: Mutation<any, any, any, any>;
    observer: MutationObserver_2<any, any, any>;
}

declare interface NotifyEventMutationObserverOptionsUpdated extends NotifyEvent {
    type: 'observerOptionsUpdated';
    mutation?: Mutation<any, any, any, any>;
    observer: MutationObserver_2<any, any, any, any>;
}

declare interface NotifyEventMutationObserverRemoved extends NotifyEvent {
    type: 'observerRemoved';
    mutation: Mutation<any, any, any, any>;
    observer: MutationObserver_2<any, any, any>;
}

declare interface NotifyEventMutationRemoved extends NotifyEvent {
    type: 'removed';
    mutation: Mutation<any, any, any, any>;
}

declare interface NotifyEventMutationUpdated extends NotifyEvent {
    type: 'updated';
    mutation: Mutation<any, any, any, any>;
    action: Action<any, any, any, any>;
}

declare interface NotifyEventQueryAdded extends NotifyEvent {
    type: 'added';
    query: Query<any, any, any, any>;
}

declare interface NotifyEventQueryObserverAdded extends NotifyEvent {
    type: 'observerAdded';
    query: Query<any, any, any, any>;
    observer: QueryObserver<any, any, any, any, any>;
}

declare interface NotifyEventQueryObserverOptionsUpdated extends NotifyEvent {
    type: 'observerOptionsUpdated';
    query: Query<any, any, any, any>;
    observer: QueryObserver<any, any, any, any, any>;
}

declare interface NotifyEventQueryObserverRemoved extends NotifyEvent {
    type: 'observerRemoved';
    query: Query<any, any, any, any>;
    observer: QueryObserver<any, any, any, any, any>;
}

declare interface NotifyEventQueryObserverResultsUpdated extends NotifyEvent {
    type: 'observerResultsUpdated';
    query: Query<any, any, any, any>;
}

declare interface NotifyEventQueryRemoved extends NotifyEvent {
    type: 'removed';
    query: Query<any, any, any, any>;
}

declare interface NotifyEventQueryUpdated extends NotifyEvent {
    type: 'updated';
    query: Query<any, any, any, any>;
    action: Action_alias_1<any, any>;
}

declare type NotifyEventType = 'added' | 'removed' | 'updated' | 'observerAdded' | 'observerRemoved' | 'observerResultsUpdated' | 'observerOptionsUpdated';
export { NotifyEventType }
export { NotifyEventType as NotifyEventType_alias_1 }

declare type NotifyFunction = (callback: () => void) => void;

declare const notifyManager: {
    readonly batch: <T>(callback: () => T) => T;
    /**
     * All calls to the wrapped function will be batched.
     */
    readonly batchCalls: <T extends Array<unknown>>(callback: BatchCallsCallback<T>) => BatchCallsCallback<T>;
    readonly schedule: (callback: NotifyCallback) => void;
    /**
     * Use this method to set a custom notify function.
     * This can be used to for example wrap notifications with `React.act` while running tests.
     */
    readonly setNotifyFunction: (fn: NotifyFunction) => void;
    /**
     * Use this method to set a custom function to batch notifications together into a single tick.
     * By default React Query will use the batch function provided by ReactDOM or React Native.
     */
    readonly setBatchNotifyFunction: (fn: BatchNotifyFunction) => void;
    readonly setScheduler: (fn: ScheduleFunction) => void;
};
export { notifyManager }
export { notifyManager as notifyManager_alias_1 }

declare type NotifyOnChangeProps = Array<keyof InfiniteQueryObserverResult> | 'all' | undefined | (() => Array<keyof InfiniteQueryObserverResult> | 'all' | undefined);
export { NotifyOnChangeProps }
export { NotifyOnChangeProps as NotifyOnChangeProps_alias_1 }

declare interface ObserverFetchOptions extends FetchOptions {
    throwOnError?: boolean;
}

declare type OmitKeyof<TObject, TKey extends TStrictly extends 'safely' ? keyof TObject | (string & Record<never, never>) | (number & Record<never, never>) | (symbol & Record<never, never>) : keyof TObject, TStrictly extends 'strictly' | 'safely' = 'strictly'> = Omit<TObject, TKey>;
export { OmitKeyof }
export { OmitKeyof as OmitKeyof_alias_1 }

export declare class OnlineManager extends Subscribable<Listener_2> {
    #private;
    constructor();
    protected onSubscribe(): void;
    protected onUnsubscribe(): void;
    setEventListener(setup: SetupFn_2): void;
    setOnline(online: boolean): void;
    isOnline(): boolean;
}

declare const onlineManager: OnlineManager;
export { onlineManager }
export { onlineManager as onlineManager_alias_1 }

declare type Override<TTargetA, TTargetB> = {
    [AKey in keyof TTargetA]: AKey extends keyof TTargetB ? TTargetB[AKey] : TTargetA[AKey];
};
export { Override }
export { Override as Override_alias_1 }

/**
 * Checks if key `b` partially matches with key `a`.
 */
declare function partialMatchKey(a: QueryKey, b: QueryKey): boolean;
export { partialMatchKey }
export { partialMatchKey as partialMatchKey_alias_1 }

declare interface PauseAction {
    type: 'pause';
}

declare interface PauseAction_2 {
    type: 'pause';
}

declare interface Pending<T> {
    status: 'pending';
    /**
     * Resolve the promise with a value.
     * Will remove the `resolve` and `reject` properties from the promise.
     */
    resolve: (value: T) => void;
    /**
     * Reject the promise with a reason.
     * Will remove the `resolve` and `reject` properties from the promise.
     */
    reject: (reason: unknown) => void;
}

declare interface PendingAction<TVariables, TOnMutateResult> {
    type: 'pending';
    isPaused: boolean;
    variables?: TVariables;
    context?: TOnMutateResult;
}

export declare type PendingThenable<T> = Promise<T> & Pending<T>;

export declare function pendingThenable<T>(): PendingThenable<T>;

declare type PlaceholderDataFunction<TQueryFnData = unknown, TError = DefaultError, TQueryData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> = (previousData: TQueryData | undefined, previousQuery: Query<TQueryFnData, TError, TQueryData, TQueryKey> | undefined) => TQueryData | undefined;
export { PlaceholderDataFunction }
export { PlaceholderDataFunction as PlaceholderDataFunction_alias_1 }

declare class QueriesObserver<TCombinedResult = Array<QueryObserverResult>> extends Subscribable<QueriesObserverListener> {
    #private;
    constructor(client: QueryClient, queries: Array<QueryObserverOptions<any, any, any, any, any>>, options?: QueriesObserverOptions<TCombinedResult>);
    protected onSubscribe(): void;
    protected onUnsubscribe(): void;
    destroy(): void;
    setQueries(queries: Array<QueryObserverOptions>, options?: QueriesObserverOptions<TCombinedResult>): void;
    getCurrentResult(): Array<QueryObserverResult>;
    getQueries(): Query<unknown, Error, unknown, readonly unknown[]>[];
    getObservers(): QueryObserver<unknown, Error, unknown, unknown, readonly unknown[]>[];
    getOptimisticResult(queries: Array<QueryObserverOptions>, combine: CombineFn<TCombinedResult> | undefined): [
    rawResult: Array<QueryObserverResult>,
    combineResult: (r?: Array<QueryObserverResult>) => TCombinedResult,
    trackResult: () => Array<QueryObserverResult>
    ];
}
export { QueriesObserver }
export { QueriesObserver as QueriesObserver_alias_1 }

declare type QueriesObserverListener = (result: Array<QueryObserverResult>) => void;

declare interface QueriesObserverOptions<TCombinedResult = Array<QueryObserverResult>> {
    combine?: CombineFn<TCombinedResult>;
}
export { QueriesObserverOptions }
export { QueriesObserverOptions as QueriesObserverOptions_alias_1 }

declare type QueriesPlaceholderDataFunction<TQueryData> = (previousData: undefined, previousQuery: undefined) => TQueryData | undefined;
export { QueriesPlaceholderDataFunction }
export { QueriesPlaceholderDataFunction as QueriesPlaceholderDataFunction_alias_1 }

declare class Query<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> extends Removable {
    #private;
    queryKey: TQueryKey;
    queryHash: string;
    options: QueryOptions<TQueryFnData, TError, TData, TQueryKey>;
    state: QueryState<TData, TError>;
    observers: Array<QueryObserver<any, any, any, any, any>>;
    constructor(config: QueryConfig<TQueryFnData, TError, TData, TQueryKey>);
    get meta(): QueryMeta | undefined;
    get promise(): Promise<TData> | undefined;
    setOptions(options?: QueryOptions<TQueryFnData, TError, TData, TQueryKey>): void;
    protected optionalRemove(): void;
    setData(newData: TData, options?: SetDataOptions & {
        manual: boolean;
    }): TData;
    setState(state: Partial<QueryState<TData, TError>>, setStateOptions?: SetStateOptions): void;
    cancel(options?: CancelOptions): Promise<void>;
    destroy(): void;
    get resetState(): QueryState<TData, TError>;
    reset(): void;
    isActive(): boolean;
    isDisabled(): boolean;
    isFetched(): boolean;
    isStatic(): boolean;
    isStale(): boolean;
    isStaleByTime(staleTime?: StaleTime): boolean;
    onFocus(): void;
    onOnline(): void;
    addObserver(observer: QueryObserver<any, any, any, any, any>): void;
    removeObserver(observer: QueryObserver<any, any, any, any, any>): void;
    getObserversCount(): number;
    invalidate(): void;
    fetch(options?: QueryOptions<TQueryFnData, TError, TData, TQueryKey>, fetchOptions?: FetchOptions<TQueryFnData>): Promise<TData>;
}
export { Query }
export { Query as Query_alias_1 }

export declare interface QueryBehavior<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> {
    onFetch: (context: FetchContext<TQueryFnData, TError, TData, TQueryKey>, query: Query) => void;
}

declare class QueryCache extends Subscribable<QueryCacheListener> {
    #private;
    config: QueryCacheConfig;
    constructor(config?: QueryCacheConfig);
    build<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(client: QueryClient, options: WithRequired<QueryOptions<TQueryFnData, TError, TData, TQueryKey>, 'queryKey'>, state?: QueryState<TData, TError>): Query<TQueryFnData, TError, TData, TQueryKey>;
    add(query: Query<any, any, any, any>): void;
    remove(query: Query<any, any, any, any>): void;
    clear(): void;
    get<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(queryHash: string): Query<TQueryFnData, TError, TData, TQueryKey> | undefined;
    getAll(): Array<Query>;
    find<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData>(filters: WithRequired<QueryFilters, 'queryKey'>): Query<TQueryFnData, TError, TData> | undefined;
    findAll(filters?: QueryFilters<any>): Array<Query>;
    notify(event: QueryCacheNotifyEvent): void;
    onFocus(): void;
    onOnline(): void;
}
export { QueryCache }
export { QueryCache as QueryCache_alias_1 }

declare interface QueryCacheConfig {
    onError?: (error: DefaultError, query: Query<unknown, unknown, unknown>) => void;
    onSuccess?: (data: unknown, query: Query<unknown, unknown, unknown>) => void;
    onSettled?: (data: unknown | undefined, error: DefaultError | null, query: Query<unknown, unknown, unknown>) => void;
}

declare type QueryCacheListener = (event: QueryCacheNotifyEvent) => void;

declare type QueryCacheNotifyEvent = NotifyEventQueryAdded | NotifyEventQueryRemoved | NotifyEventQueryUpdated | NotifyEventQueryObserverAdded | NotifyEventQueryObserverRemoved | NotifyEventQueryObserverResultsUpdated | NotifyEventQueryObserverOptionsUpdated;
export { QueryCacheNotifyEvent }
export { QueryCacheNotifyEvent as QueryCacheNotifyEvent_alias_1 }

declare class QueryClient {
    #private;
    constructor(config?: QueryClientConfig);
    mount(): void;
    unmount(): void;
    isFetching<TQueryFilters extends QueryFilters<any> = QueryFilters>(filters?: TQueryFilters): number;
    isMutating<TMutationFilters extends MutationFilters<any, any> = MutationFilters>(filters?: TMutationFilters): number;
    /**
     * Imperative (non-reactive) way to retrieve data for a QueryKey.
     * Should only be used in callbacks or functions where reading the latest data is necessary, e.g. for optimistic updates.
     *
     * Hint: Do not use this function inside a component, because it won't receive updates.
     * Use `useQuery` to create a `QueryObserver` that subscribes to changes.
     */
    getQueryData<TQueryFnData = unknown, TTaggedQueryKey extends QueryKey = QueryKey, TInferredQueryFnData = InferDataFromTag<TQueryFnData, TTaggedQueryKey>>(queryKey: TTaggedQueryKey): TInferredQueryFnData | undefined;
    ensureQueryData<TQueryFnData, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(options: EnsureQueryDataOptions<TQueryFnData, TError, TData, TQueryKey>): Promise<TData>;
    getQueriesData<TQueryFnData = unknown, TQueryFilters extends QueryFilters<any> = QueryFilters>(filters: TQueryFilters): Array<[QueryKey, TQueryFnData | undefined]>;
    setQueryData<TQueryFnData = unknown, TTaggedQueryKey extends QueryKey = QueryKey, TInferredQueryFnData = InferDataFromTag<TQueryFnData, TTaggedQueryKey>>(queryKey: TTaggedQueryKey, updater: Updater<NoInfer_2<TInferredQueryFnData> | undefined, NoInfer_2<TInferredQueryFnData> | undefined>, options?: SetDataOptions): NoInfer_2<TInferredQueryFnData> | undefined;
    setQueriesData<TQueryFnData, TQueryFilters extends QueryFilters<any> = QueryFilters>(filters: TQueryFilters, updater: Updater<NoInfer_2<TQueryFnData> | undefined, NoInfer_2<TQueryFnData> | undefined>, options?: SetDataOptions): Array<[QueryKey, TQueryFnData | undefined]>;
    getQueryState<TQueryFnData = unknown, TError = DefaultError, TTaggedQueryKey extends QueryKey = QueryKey, TInferredQueryFnData = InferDataFromTag<TQueryFnData, TTaggedQueryKey>, TInferredError = InferErrorFromTag<TError, TTaggedQueryKey>>(queryKey: TTaggedQueryKey): QueryState<TInferredQueryFnData, TInferredError> | undefined;
    removeQueries<TTaggedQueryKey extends QueryKey = QueryKey>(filters?: QueryFilters<TTaggedQueryKey>): void;
    resetQueries<TTaggedQueryKey extends QueryKey = QueryKey>(filters?: QueryFilters<TTaggedQueryKey>, options?: ResetOptions): Promise<void>;
    cancelQueries<TTaggedQueryKey extends QueryKey = QueryKey>(filters?: QueryFilters<TTaggedQueryKey>, cancelOptions?: CancelOptions): Promise<void>;
    invalidateQueries<TTaggedQueryKey extends QueryKey = QueryKey>(filters?: InvalidateQueryFilters<TTaggedQueryKey>, options?: InvalidateOptions): Promise<void>;
    refetchQueries<TTaggedQueryKey extends QueryKey = QueryKey>(filters?: RefetchQueryFilters<TTaggedQueryKey>, options?: RefetchOptions): Promise<void>;
    fetchQuery<TQueryFnData, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = never>(options: FetchQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>): Promise<TData>;
    prefetchQuery<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(options: FetchQueryOptions<TQueryFnData, TError, TData, TQueryKey>): Promise<void>;
    fetchInfiniteQuery<TQueryFnData, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: FetchInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>): Promise<InfiniteData<TData, TPageParam>>;
    prefetchInfiniteQuery<TQueryFnData, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: FetchInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>): Promise<void>;
    ensureInfiniteQueryData<TQueryFnData, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: EnsureInfiniteQueryDataOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>): Promise<InfiniteData<TData, TPageParam>>;
    resumePausedMutations(): Promise<unknown>;
    getQueryCache(): QueryCache;
    getMutationCache(): MutationCache;
    getDefaultOptions(): DefaultOptions;
    setDefaultOptions(options: DefaultOptions): void;
    setQueryDefaults<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryData = TQueryFnData>(queryKey: QueryKey, options: Partial<OmitKeyof<QueryObserverOptions<TQueryFnData, TError, TData, TQueryData>, 'queryKey'>>): void;
    getQueryDefaults(queryKey: QueryKey): OmitKeyof<QueryObserverOptions<any, any, any, any, any>, 'queryKey'>;
    setMutationDefaults<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown>(mutationKey: MutationKey, options: OmitKeyof<MutationObserverOptions<TData, TError, TVariables, TOnMutateResult>, 'mutationKey'>): void;
    getMutationDefaults(mutationKey: MutationKey): OmitKeyof<MutationObserverOptions<any, any, any, any>, 'mutationKey'>;
    defaultQueryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = never>(options: QueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey, TPageParam> | DefaultedQueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>): DefaultedQueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>;
    defaultMutationOptions<T extends MutationOptions<any, any, any, any>>(options?: T): T;
    clear(): void;
}
export { QueryClient }
export { QueryClient as QueryClient_alias_1 }

declare interface QueryClientConfig {
    queryCache?: QueryCache;
    mutationCache?: MutationCache;
    defaultOptions?: DefaultOptions;
}
export { QueryClientConfig }
export { QueryClientConfig as QueryClientConfig_alias_1 }

declare interface QueryConfig<TQueryFnData, TError, TData, TQueryKey extends QueryKey = QueryKey> {
    client: QueryClient;
    queryKey: TQueryKey;
    queryHash: string;
    options?: QueryOptions<TQueryFnData, TError, TData, TQueryKey>;
    defaultOptions?: QueryOptions<TQueryFnData, TError, TData, TQueryKey>;
    state?: QueryState<TData, TError>;
}

declare interface QueryFilters<TQueryKey extends QueryKey = QueryKey> {
    /**
     * Filter to active queries, inactive queries or all queries
     */
    type?: QueryTypeFilter;
    /**
     * Match query key exactly
     */
    exact?: boolean;
    /**
     * Include queries matching this predicate function
     */
    predicate?: (query: Query) => boolean;
    /**
     * Include queries matching this query key
     */
    queryKey?: TQueryKey | TuplePrefixes<TQueryKey>;
    /**
     * Include or exclude stale queries
     */
    stale?: boolean;
    /**
     * Include queries matching their fetchStatus
     */
    fetchStatus?: FetchStatus;
}
export { QueryFilters }
export { QueryFilters as QueryFilters_alias_1 }

declare type QueryFunction<T = unknown, TQueryKey extends QueryKey = QueryKey, TPageParam = never> = (context: QueryFunctionContext<TQueryKey, TPageParam>) => T | Promise<T>;
export { QueryFunction }
export { QueryFunction as QueryFunction_alias_1 }

declare type QueryFunctionContext<TQueryKey extends QueryKey = QueryKey, TPageParam = never> = [TPageParam] extends [never] ? {
    client: QueryClient;
    queryKey: TQueryKey;
    signal: AbortSignal;
    meta: QueryMeta | undefined;
    pageParam?: unknown;
    /**
     * @deprecated
     * if you want access to the direction, you can add it to the pageParam
     */
    direction?: unknown;
} : {
    client: QueryClient;
    queryKey: TQueryKey;
    signal: AbortSignal;
    pageParam: TPageParam;
    /**
     * @deprecated
     * if you want access to the direction, you can add it to the pageParam
     */
    direction: FetchDirection;
    meta: QueryMeta | undefined;
};
export { QueryFunctionContext }
export { QueryFunctionContext as QueryFunctionContext_alias_1 }

declare type QueryKey = Register extends {
    queryKey: infer TQueryKey;
} ? TQueryKey extends ReadonlyArray<unknown> ? TQueryKey : TQueryKey extends Array<unknown> ? TQueryKey : ReadonlyArray<unknown> : ReadonlyArray<unknown>;
export { QueryKey }
export { QueryKey as QueryKey_alias_1 }

declare type QueryKeyHashFunction<TQueryKey extends QueryKey> = (queryKey: TQueryKey) => string;
export { QueryKeyHashFunction }
export { QueryKeyHashFunction as QueryKeyHashFunction_alias_1 }

declare type QueryMeta = Register extends {
    queryMeta: infer TQueryMeta;
} ? TQueryMeta extends Record<string, unknown> ? TQueryMeta : Record<string, unknown> : Record<string, unknown>;
export { QueryMeta }
export { QueryMeta as QueryMeta_alias_1 }

declare class QueryObserver<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> extends Subscribable<QueryObserverListener<TData, TError>> {
    #private;
    options: QueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>;
    constructor(client: QueryClient, options: QueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>);
    protected bindMethods(): void;
    protected onSubscribe(): void;
    protected onUnsubscribe(): void;
    shouldFetchOnReconnect(): boolean;
    shouldFetchOnWindowFocus(): boolean;
    destroy(): void;
    setOptions(options: QueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>): void;
    getOptimisticResult(options: DefaultedQueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>): QueryObserverResult<TData, TError>;
    getCurrentResult(): QueryObserverResult<TData, TError>;
    trackResult(result: QueryObserverResult<TData, TError>, onPropTracked?: (key: keyof QueryObserverResult) => void): QueryObserverResult<TData, TError>;
    trackProp(key: keyof QueryObserverResult): void;
    getCurrentQuery(): Query<TQueryFnData, TError, TQueryData, TQueryKey>;
    refetch({ ...options }?: RefetchOptions): Promise<QueryObserverResult<TData, TError>>;
    fetchOptimistic(options: QueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>): Promise<QueryObserverResult<TData, TError>>;
    protected fetch(fetchOptions: ObserverFetchOptions): Promise<QueryObserverResult<TData, TError>>;
    protected createResult(query: Query<TQueryFnData, TError, TQueryData, TQueryKey>, options: QueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>): QueryObserverResult<TData, TError>;
    updateResult(): void;
    onQueryUpdate(): void;
}
export { QueryObserver }
export { QueryObserver as QueryObserver_alias_1 }

declare interface QueryObserverBaseResult<TData = unknown, TError = DefaultError> {
    /**
     * The last successfully resolved data for the query.
     */
    data: TData | undefined;
    /**
     * The timestamp for when the query most recently returned the `status` as `"success"`.
     */
    dataUpdatedAt: number;
    /**
     * The error object for the query, if an error was thrown.
     * - Defaults to `null`.
     */
    error: TError | null;
    /**
     * The timestamp for when the query most recently returned the `status` as `"error"`.
     */
    errorUpdatedAt: number;
    /**
     * The failure count for the query.
     * - Incremented every time the query fails.
     * - Reset to `0` when the query succeeds.
     */
    failureCount: number;
    /**
     * The failure reason for the query retry.
     * - Reset to `null` when the query succeeds.
     */
    failureReason: TError | null;
    /**
     * The sum of all errors.
     */
    errorUpdateCount: number;
    /**
     * A derived boolean from the `status` variable, provided for convenience.
     * - `true` if the query attempt resulted in an error.
     */
    isError: boolean;
    /**
     * Will be `true` if the query has been fetched.
     */
    isFetched: boolean;
    /**
     * Will be `true` if the query has been fetched after the component mounted.
     * - This property can be used to not show any previously cached data.
     */
    isFetchedAfterMount: boolean;
    /**
     * A derived boolean from the `fetchStatus` variable, provided for convenience.
     * - `true` whenever the `queryFn` is executing, which includes initial `pending` as well as background refetch.
     */
    isFetching: boolean;
    /**
     * Is `true` whenever the first fetch for a query is in-flight.
     * - Is the same as `isFetching && isPending`.
     */
    isLoading: boolean;
    /**
     * Will be `pending` if there's no cached data and no query attempt was finished yet.
     */
    isPending: boolean;
    /**
     * Will be `true` if the query failed while fetching for the first time.
     */
    isLoadingError: boolean;
    /**
     * @deprecated `isInitialLoading` is being deprecated in favor of `isLoading`
     * and will be removed in the next major version.
     */
    isInitialLoading: boolean;
    /**
     * A derived boolean from the `fetchStatus` variable, provided for convenience.
     * - The query wanted to fetch, but has been `paused`.
     */
    isPaused: boolean;
    /**
     * Will be `true` if the data shown is the placeholder data.
     */
    isPlaceholderData: boolean;
    /**
     * Will be `true` if the query failed while refetching.
     */
    isRefetchError: boolean;
    /**
     * Is `true` whenever a background refetch is in-flight, which _does not_ include initial `pending`.
     * - Is the same as `isFetching && !isPending`.
     */
    isRefetching: boolean;
    /**
     * Will be `true` if the data in the cache is invalidated or if the data is older than the given `staleTime`.
     */
    isStale: boolean;
    /**
     * A derived boolean from the `status` variable, provided for convenience.
     * - `true` if the query has received a response with no errors and is ready to display its data.
     */
    isSuccess: boolean;
    /**
     * `true` if this observer is enabled, `false` otherwise.
     */
    isEnabled: boolean;
    /**
     * A function to manually refetch the query.
     */
    refetch: (options?: RefetchOptions) => Promise<QueryObserverResult<TData, TError>>;
    /**
     * The status of the query.
     * - Will be:
     *   - `pending` if there's no cached data and no query attempt was finished yet.
     *   - `error` if the query attempt resulted in an error.
     *   - `success` if the query has received a response with no errors and is ready to display its data.
     */
    status: QueryStatus;
    /**
     * The fetch status of the query.
     * - `fetching`: Is `true` whenever the queryFn is executing, which includes initial `pending` as well as background refetch.
     * - `paused`: The query wanted to fetch, but has been `paused`.
     * - `idle`: The query is not fetching.
     * - See [Network Mode](https://tanstack.com/query/latest/docs/framework/react/guides/network-mode) for more information.
     */
    fetchStatus: FetchStatus;
    /**
     * A stable promise that will be resolved with the data of the query.
     * Requires the `experimental_prefetchInRender` feature flag to be enabled.
     * @example
     *
     * ### Enabling the feature flag
     * ```ts
     * const client = new QueryClient({
     *   defaultOptions: {
     *     queries: {
     *       experimental_prefetchInRender: true,
     *     },
     *   },
     * })
     * ```
     *
     * ### Usage
     * ```tsx
     * import { useQuery } from '@tanstack/react-query'
     * import React from 'react'
     * import { fetchTodos, type Todo } from './api'
     *
     * function TodoList({ query }: { query: UseQueryResult<Todo[], Error> }) {
     *   const data = React.use(query.promise)
     *
     *   return (
     *     <ul>
     *       {data.map(todo => (
     *         <li key={todo.id}>{todo.title}</li>
     *       ))}
     *     </ul>
     *   )
     * }
     *
     * export function App() {
     *   const query = useQuery({ queryKey: ['todos'], queryFn: fetchTodos })
     *
     *   return (
     *     <>
     *       <h1>Todos</h1>
     *       <React.Suspense fallback={<div>Loading...</div>}>
     *         <TodoList query={query} />
     *       </React.Suspense>
     *     </>
     *   )
     * }
     * ```
     */
    promise: Promise<TData>;
}
export { QueryObserverBaseResult }
export { QueryObserverBaseResult as QueryObserverBaseResult_alias_1 }

declare type QueryObserverListener<TData, TError> = (result: QueryObserverResult<TData, TError>) => void;

declare interface QueryObserverLoadingErrorResult<TData = unknown, TError = DefaultError> extends QueryObserverBaseResult<TData, TError> {
    data: undefined;
    error: TError;
    isError: true;
    isPending: false;
    isLoading: false;
    isLoadingError: true;
    isRefetchError: false;
    isSuccess: false;
    isPlaceholderData: false;
    status: 'error';
}
export { QueryObserverLoadingErrorResult }
export { QueryObserverLoadingErrorResult as QueryObserverLoadingErrorResult_alias_1 }

declare interface QueryObserverLoadingResult<TData = unknown, TError = DefaultError> extends QueryObserverBaseResult<TData, TError> {
    data: undefined;
    error: null;
    isError: false;
    isPending: true;
    isLoading: true;
    isLoadingError: false;
    isRefetchError: false;
    isSuccess: false;
    isPlaceholderData: false;
    status: 'pending';
}
export { QueryObserverLoadingResult }
export { QueryObserverLoadingResult as QueryObserverLoadingResult_alias_1 }

declare interface QueryObserverOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = never> extends WithRequired<QueryOptions<TQueryFnData, TError, TQueryData, TQueryKey, TPageParam>, 'queryKey'> {
    /**
     * Set this to `false` or a function that returns `false` to disable automatic refetching when the query mounts or changes query keys.
     * To refetch the query, use the `refetch` method returned from the `useQuery` instance.
     * Accepts a boolean or function that returns a boolean.
     * Defaults to `true`.
     */
    enabled?: Enabled<TQueryFnData, TError, TQueryData, TQueryKey>;
    /**
     * The time in milliseconds after data is considered stale.
     * If set to `Infinity`, the data will never be considered stale.
     * If set to a function, the function will be executed with the query to compute a `staleTime`.
     * Defaults to `0`.
     */
    staleTime?: StaleTimeFunction<TQueryFnData, TError, TQueryData, TQueryKey>;
    /**
     * If set to a number, the query will continuously refetch at this frequency in milliseconds.
     * If set to a function, the function will be executed with the latest data and query to compute a frequency
     * Defaults to `false`.
     */
    refetchInterval?: number | false | ((query: Query<TQueryFnData, TError, TQueryData, TQueryKey>) => number | false | undefined);
    /**
     * If set to `true`, the query will continue to refetch while their tab/window is in the background.
     * Defaults to `false`.
     */
    refetchIntervalInBackground?: boolean;
    /**
     * If set to `true`, the query will refetch on window focus if the data is stale.
     * If set to `false`, the query will not refetch on window focus.
     * If set to `'always'`, the query will always refetch on window focus.
     * If set to a function, the function will be executed with the latest data and query to compute the value.
     * Defaults to `true`.
     */
    refetchOnWindowFocus?: boolean | 'always' | ((query: Query<TQueryFnData, TError, TQueryData, TQueryKey>) => boolean | 'always');
    /**
     * If set to `true`, the query will refetch on reconnect if the data is stale.
     * If set to `false`, the query will not refetch on reconnect.
     * If set to `'always'`, the query will always refetch on reconnect.
     * If set to a function, the function will be executed with the latest data and query to compute the value.
     * Defaults to the value of `networkOnline` (`true`)
     */
    refetchOnReconnect?: boolean | 'always' | ((query: Query<TQueryFnData, TError, TQueryData, TQueryKey>) => boolean | 'always');
    /**
     * If set to `true`, the query will refetch on mount if the data is stale.
     * If set to `false`, will disable additional instances of a query to trigger background refetch.
     * If set to `'always'`, the query will always refetch on mount.
     * If set to a function, the function will be executed with the latest data and query to compute the value
     * Defaults to `true`.
     */
    refetchOnMount?: boolean | 'always' | ((query: Query<TQueryFnData, TError, TQueryData, TQueryKey>) => boolean | 'always');
    /**
     * If set to `false`, the query will not be retried on mount if it contains an error.
     * Defaults to `true`.
     */
    retryOnMount?: boolean;
    /**
     * If set, the component will only re-render if any of the listed properties change.
     * When set to `['data', 'error']`, the component will only re-render when the `data` or `error` properties change.
     * When set to `'all'`, the component will re-render whenever a query is updated.
     * When set to a function, the function will be executed to compute the list of properties.
     * By default, access to properties will be tracked, and the component will only re-render when one of the tracked properties change.
     */
    notifyOnChangeProps?: NotifyOnChangeProps;
    /**
     * Whether errors should be thrown instead of setting the `error` property.
     * If set to `true` or `suspense` is `true`, all errors will be thrown to the error boundary.
     * If set to `false` and `suspense` is `false`, errors are returned as state.
     * If set to a function, it will be passed the error and the query, and it should return a boolean indicating whether to show the error in an error boundary (`true`) or return the error as state (`false`).
     * Defaults to `false`.
     */
    throwOnError?: ThrowOnError<TQueryFnData, TError, TQueryData, TQueryKey>;
    /**
     * This option can be used to transform or select a part of the data returned by the query function.
     */
    select?: (data: TQueryData) => TData;
    /**
     * If set to `true`, the query will suspend when `status === 'pending'`
     * and throw errors when `status === 'error'`.
     * Defaults to `false`.
     */
    suspense?: boolean;
    /**
     * If set, this value will be used as the placeholder data for this particular query observer while the query is still in the `loading` data and no initialData has been provided.
     */
    placeholderData?: NonFunctionGuard<TQueryData> | PlaceholderDataFunction<NonFunctionGuard<TQueryData>, TError, NonFunctionGuard<TQueryData>, TQueryKey>;
    _optimisticResults?: 'optimistic' | 'isRestoring';
    /**
     * Enable prefetching during rendering
     */
    experimental_prefetchInRender?: boolean;
}
export { QueryObserverOptions }
export { QueryObserverOptions as QueryObserverOptions_alias_1 }

declare interface QueryObserverPendingResult<TData = unknown, TError = DefaultError> extends QueryObserverBaseResult<TData, TError> {
    data: undefined;
    error: null;
    isError: false;
    isPending: true;
    isLoadingError: false;
    isRefetchError: false;
    isSuccess: false;
    isPlaceholderData: false;
    status: 'pending';
}
export { QueryObserverPendingResult }
export { QueryObserverPendingResult as QueryObserverPendingResult_alias_1 }

declare interface QueryObserverPlaceholderResult<TData = unknown, TError = DefaultError> extends QueryObserverBaseResult<TData, TError> {
    data: TData;
    isError: false;
    error: null;
    isPending: false;
    isLoading: false;
    isLoadingError: false;
    isRefetchError: false;
    isSuccess: true;
    isPlaceholderData: true;
    status: 'success';
}
export { QueryObserverPlaceholderResult }
export { QueryObserverPlaceholderResult as QueryObserverPlaceholderResult_alias_1 }

declare interface QueryObserverRefetchErrorResult<TData = unknown, TError = DefaultError> extends QueryObserverBaseResult<TData, TError> {
    data: TData;
    error: TError;
    isError: true;
    isPending: false;
    isLoading: false;
    isLoadingError: false;
    isRefetchError: true;
    isSuccess: false;
    isPlaceholderData: false;
    status: 'error';
}
export { QueryObserverRefetchErrorResult }
export { QueryObserverRefetchErrorResult as QueryObserverRefetchErrorResult_alias_1 }

declare type QueryObserverResult<TData = unknown, TError = DefaultError> = DefinedQueryObserverResult<TData, TError> | QueryObserverLoadingErrorResult<TData, TError> | QueryObserverLoadingResult<TData, TError> | QueryObserverPendingResult<TData, TError> | QueryObserverPlaceholderResult<TData, TError>;
export { QueryObserverResult }
export { QueryObserverResult as QueryObserverResult_alias_1 }

declare interface QueryObserverSuccessResult<TData = unknown, TError = DefaultError> extends QueryObserverBaseResult<TData, TError> {
    data: TData;
    error: null;
    isError: false;
    isPending: false;
    isLoading: false;
    isLoadingError: false;
    isRefetchError: false;
    isSuccess: true;
    isPlaceholderData: false;
    status: 'success';
}
export { QueryObserverSuccessResult }
export { QueryObserverSuccessResult as QueryObserverSuccessResult_alias_1 }

declare interface QueryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = never> {
    /**
     * If `false`, failed queries will not retry by default.
     * If `true`, failed queries will retry infinitely., failureCount: num
     * If set to an integer number, e.g. 3, failed queries will retry until the failed query count meets that number.
     * If set to a function `(failureCount, error) => boolean` failed queries will retry until the function returns false.
     */
    retry?: RetryValue<TError>;
    retryDelay?: RetryDelayValue<TError>;
    networkMode?: NetworkMode;
    /**
     * The time in milliseconds that unused/inactive cache data remains in memory.
     * When a query's cache becomes unused or inactive, that cache data will be garbage collected after this duration.
     * When different garbage collection times are specified, the longest one will be used.
     * Setting it to `Infinity` will disable garbage collection.
     */
    gcTime?: number;
    queryFn?: QueryFunction<TQueryFnData, TQueryKey, TPageParam> | SkipToken;
    persister?: QueryPersister<NoInfer_2<TQueryFnData>, NoInfer_2<TQueryKey>, NoInfer_2<TPageParam>>;
    queryHash?: string;
    queryKey?: TQueryKey;
    queryKeyHashFn?: QueryKeyHashFunction<TQueryKey>;
    initialData?: TData | InitialDataFunction<TData>;
    initialDataUpdatedAt?: number | (() => number | undefined);
    behavior?: QueryBehavior<TQueryFnData, TError, TData, TQueryKey>;
    /**
     * Set this to `false` to disable structural sharing between query results.
     * Set this to a function which accepts the old and new data and returns resolved data of the same type to implement custom structural sharing logic.
     * Defaults to `true`.
     */
    structuralSharing?: boolean | ((oldData: unknown | undefined, newData: unknown) => unknown);
    _defaulted?: boolean;
    /**
     * Additional payload to be stored on each query.
     * Use this property to pass information that can be used in other places.
     */
    meta?: QueryMeta;
    /**
     * Maximum number of pages to store in the data of an infinite query.
     */
    maxPages?: number;
}
export { QueryOptions }
export { QueryOptions as QueryOptions_alias_1 }

declare type QueryPersister<T = unknown, TQueryKey extends QueryKey = QueryKey, TPageParam = never> = [TPageParam] extends [never] ? (queryFn: QueryFunction<T, TQueryKey, never>, context: QueryFunctionContext<TQueryKey>, query: Query) => T | Promise<T> : (queryFn: QueryFunction<T, TQueryKey, TPageParam>, context: QueryFunctionContext<TQueryKey>, query: Query) => T | Promise<T>;
export { QueryPersister }
export { QueryPersister as QueryPersister_alias_1 }

declare interface QueryState<TData = unknown, TError = DefaultError> {
    data: TData | undefined;
    dataUpdateCount: number;
    dataUpdatedAt: number;
    error: TError | null;
    errorUpdateCount: number;
    errorUpdatedAt: number;
    fetchFailureCount: number;
    fetchFailureReason: TError | null;
    fetchMeta: FetchMeta | null;
    isInvalidated: boolean;
    status: QueryStatus;
    fetchStatus: FetchStatus;
}
export { QueryState }
export { QueryState as QueryState_alias_1 }

declare type QueryStatus = 'pending' | 'error' | 'success';
export { QueryStatus }
export { QueryStatus as QueryStatus_alias_1 }

export declare interface QueryStore {
    has: (queryHash: string) => boolean;
    set: (queryHash: string, query: Query) => void;
    get: (queryHash: string) => Query | undefined;
    delete: (queryHash: string) => void;
    values: () => IterableIterator<Query>;
}

export declare type QueryTypeFilter = 'all' | 'active' | 'inactive';

declare type ReducibleStreamedQueryParams<TQueryFnData, TData, TQueryKey extends QueryKey> = BaseStreamedQueryParams<TQueryFnData, TQueryKey> & {
    reducer: (acc: TData, chunk: TQueryFnData) => TData;
    initialValue: TData;
};

declare interface RefetchOptions extends ResultOptions {
    /**
     * If set to `true`, a currently running request will be cancelled before a new request is made
     *
     * If set to `false`, no refetch will be made if there is already a request running.
     *
     * Defaults to `true`.
     */
    cancelRefetch?: boolean;
}
export { RefetchOptions }
export { RefetchOptions as RefetchOptions_alias_1 }

declare interface RefetchQueryFilters<TQueryKey extends QueryKey = QueryKey> extends QueryFilters<TQueryKey> {
}
export { RefetchQueryFilters }
export { RefetchQueryFilters as RefetchQueryFilters_alias_1 }

declare interface Register {
}
export { Register }
export { Register as Register_alias_1 }

declare interface Rejected {
    status: 'rejected';
    reason: unknown;
}

export declare type RejectedThenable<T> = Promise<T> & Rejected;

export declare abstract class Removable {
    #private;
    gcTime: number;
    destroy(): void;
    protected scheduleGc(): void;
    protected updateGcTime(newGcTime: number | undefined): void;
    protected clearGcTimeout(): void;
    protected abstract optionalRemove(): void;
}

export declare function replaceData<TData, TOptions extends QueryOptions<any, any, any, any>>(prevData: TData | undefined, data: TData, options: TOptions): TData;

/**
 * This function returns `a` if `b` is deeply equal.
 * If not, it will replace any deeply equal children of `b` with those of `a`.
 * This can be used for structural sharing between JSON values for example.
 */
declare function replaceEqualDeep<T>(a: unknown, b: T, depth?: number): T;
export { replaceEqualDeep }
export { replaceEqualDeep as replaceEqualDeep_alias_1 }

declare type ReplaceReturnType<TFunction extends (...args: Array<any>) => unknown, TReturn> = (...args: Parameters<TFunction>) => TReturn;

declare interface ResetOptions extends RefetchOptions {
}
export { ResetOptions }
export { ResetOptions as ResetOptions_alias_1 }

export declare function resolveEnabled<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(enabled: undefined | Enabled<TQueryFnData, TError, TData, TQueryKey>, query: Query<TQueryFnData, TError, TData, TQueryKey>): boolean | undefined;

export declare function resolveStaleTime<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(staleTime: undefined | StaleTimeFunction<TQueryFnData, TError, TData, TQueryKey>, query: Query<TQueryFnData, TError, TData, TQueryKey>): StaleTime | undefined;

declare interface ResultOptions {
    throwOnError?: boolean;
}
export { ResultOptions }
export { ResultOptions as ResultOptions_alias_1 }

declare type RetryDelayFunction<TError = DefaultError> = (failureCount: number, error: TError) => number;

export declare type RetryDelayValue<TError> = number | RetryDelayFunction<TError>;

export declare interface Retryer<TData = unknown> {
    promise: Promise<TData>;
    cancel: (cancelOptions?: CancelOptions) => void;
    continue: () => Promise<unknown>;
    cancelRetry: () => void;
    continueRetry: () => void;
    canStart: () => boolean;
    start: () => Promise<TData>;
    status: () => 'pending' | 'resolved' | 'rejected';
}

declare interface RetryerConfig<TData = unknown, TError = DefaultError> {
    fn: () => TData | Promise<TData>;
    initialPromise?: Promise<TData>;
    onCancel?: (error: TError) => void;
    onFail?: (failureCount: number, error: TError) => void;
    onPause?: () => void;
    onContinue?: () => void;
    retry?: RetryValue<TError>;
    retryDelay?: RetryDelayValue<TError>;
    networkMode: NetworkMode | undefined;
    canRun: () => boolean;
}

export declare type RetryValue<TError> = boolean | number | ShouldRetryFunction<TError>;

declare type ScheduleFunction = (callback: () => void) => void;

declare interface SetDataOptions {
    updatedAt?: number;
}
export { SetDataOptions }
export { SetDataOptions as SetDataOptions_alias_1 }

declare interface SetStateAction<TData, TError> {
    type: 'setState';
    state: Partial<QueryState<TData, TError>>;
    setStateOptions?: SetStateOptions;
}

export declare interface SetStateOptions {
    meta?: any;
}

declare type SetupFn = (setFocused: (focused?: boolean) => void) => (() => void) | undefined;

declare type SetupFn_2 = (setOnline: Listener_2) => (() => void) | undefined;

/**
 * Shallow compare objects.
 */
export declare function shallowEqualObjects<T extends Record<string, any>>(a: T, b: T | undefined): boolean;

declare type ShouldRetryFunction<TError = DefaultError> = (failureCount: number, error: TError) => boolean;

declare function shouldThrowError<T extends (...args: Array<any>) => boolean>(throwOnError: boolean | T | undefined, params: Parameters<T>): boolean;
export { shouldThrowError }
export { shouldThrowError as shouldThrowError_alias_1 }

declare type SimpleStreamedQueryParams<TQueryFnData, TQueryKey extends QueryKey> = BaseStreamedQueryParams<TQueryFnData, TQueryKey> & {
    reducer?: never;
    initialValue?: never;
};

declare type SkipToken = typeof skipToken;
export { SkipToken }
export { SkipToken as SkipToken_alias_1 }

declare const skipToken: unique symbol;
export { skipToken }
export { skipToken as skipToken_alias_1 }

export declare function sleep(timeout: number): Promise<void>;

declare type StaleTime = number | 'static';
export { StaleTime }
export { StaleTime as StaleTime_alias_1 }

declare type StaleTimeFunction<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> = StaleTime | ((query: Query<TQueryFnData, TError, TData, TQueryKey>) => StaleTime);
export { StaleTimeFunction }
export { StaleTimeFunction as StaleTimeFunction_alias_1 }

/**
 * This is a helper function to create a query function that streams data from an AsyncIterable.
 * Data will be an Array of all the chunks received.
 * The query will be in a 'pending' state until the first chunk of data is received, but will go to 'success' after that.
 * The query will stay in fetchStatus 'fetching' until the stream ends.
 * @param queryFn - The function that returns an AsyncIterable to stream data from.
 * @param refetchMode - Defines how re-fetches are handled.
 * Defaults to `'reset'`, erases all data and puts the query back into `pending` state.
 * Set to `'append'` to append new data to the existing data.
 * Set to `'replace'` to write all data to the cache once the stream ends.
 * @param reducer - A function to reduce the streamed chunks into the final data.
 * Defaults to a function that appends chunks to the end of the array.
 * @param initialValue - Initial value to be used while the first chunk is being fetched, and returned if the stream yields no values.
 */
declare function streamedQuery<TQueryFnData = unknown, TData = Array<TQueryFnData>, TQueryKey extends QueryKey = QueryKey>({ streamFn, refetchMode, reducer, initialValue, }: StreamedQueryParams<TQueryFnData, TData, TQueryKey>): QueryFunction<TData, TQueryKey>;
export { streamedQuery as experimental_streamedQuery }
export { streamedQuery }

declare type StreamedQueryParams<TQueryFnData, TData, TQueryKey extends QueryKey> = SimpleStreamedQueryParams<TQueryFnData, TQueryKey> | ReducibleStreamedQueryParams<TQueryFnData, TData, TQueryKey>;

export declare class Subscribable<TListener extends Function> {
    protected listeners: Set<TListener>;
    constructor();
    subscribe(listener: TListener): () => void;
    hasListeners(): boolean;
    protected onSubscribe(): void;
    protected onUnsubscribe(): void;
}

declare interface SuccessAction<TData> {
    data: TData | undefined;
    type: 'success';
    dataUpdatedAt?: number;
    manual?: boolean;
}

declare interface SuccessAction_2<TData> {
    type: 'success';
    data: TData;
}

/**
 * In many cases code wants to delay to the next event loop tick; this is not
 * mediated by {@link timeoutManager}.
 *
 * This function is provided to make auditing the `tanstack/query-core` for
 * incorrect use of system `setTimeout` easier.
 */
export declare function systemSetTimeoutZero(callback: TimeoutCallback): void;

export declare type Thenable<T> = FulfilledThenable<T> | RejectedThenable<T> | PendingThenable<T>;

declare type ThrowOnError<TQueryFnData, TError, TQueryData, TQueryKey extends QueryKey> = boolean | ((error: TError, query: Query<TQueryFnData, TError, TQueryData, TQueryKey>) => boolean);
export { ThrowOnError }
export { ThrowOnError as ThrowOnError_alias_1 }

/**
 * {@link TimeoutManager} does not support passing arguments to the callback.
 *
 * `(_: void)` is the argument type inferred by TypeScript's default typings for
 * `setTimeout(cb, number)`.
 * If we don't accept a single void argument, then
 * `new Promise(resolve => timeoutManager.setTimeout(resolve, N))` is a type error.
 */
declare type TimeoutCallback = (_: void) => void;
export { TimeoutCallback }
export { TimeoutCallback as TimeoutCallback_alias_1 }

/**
 * Allows customization of how timeouts are created.
 *
 * @tanstack/query-core makes liberal use of timeouts to implement `staleTime`
 * and `gcTime`. The default TimeoutManager provider uses the platform's global
 * `setTimeout` implementation, which is known to have scalability issues with
 * thousands of timeouts on the event loop.
 *
 * If you hit this limitation, consider providing a custom TimeoutProvider that
 * coalesces timeouts.
 */
export declare class TimeoutManager implements Omit<TimeoutProvider, 'name'> {
    #private;
    setTimeoutProvider<TTimerId extends ManagedTimerId>(provider: TimeoutProvider<TTimerId>): void;
    setTimeout(callback: TimeoutCallback, delay: number): ManagedTimerId;
    clearTimeout(timeoutId: ManagedTimerId | undefined): void;
    setInterval(callback: TimeoutCallback, delay: number): ManagedTimerId;
    clearInterval(intervalId: ManagedTimerId | undefined): void;
}

declare const timeoutManager: TimeoutManager;
export { timeoutManager }
export { timeoutManager as timeoutManager_alias_1 }

/**
 * Backend for timer functions.
 */
declare type TimeoutProvider<TTimerId extends ManagedTimerId = ManagedTimerId> = {
    readonly setTimeout: (callback: TimeoutCallback, delay: number) => TTimerId;
    readonly clearTimeout: (timeoutId: TTimerId | undefined) => void;
    readonly setInterval: (callback: TimeoutCallback, delay: number) => TTimerId;
    readonly clearInterval: (intervalId: TTimerId | undefined) => void;
};
export { TimeoutProvider }
export { TimeoutProvider as TimeoutProvider_alias_1 }

export declare function timeUntilStale(updatedAt: number, staleTime?: number): number;

declare type TransformerFn = (data: any) => any;

/**
 * This function takes a Promise-like input and detects whether the data
 * is synchronously available or not.
 *
 * It does not inspect .status, .value or .reason properties of the promise,
 * as those are not always available, and the .status of React's promises
 * should not be considered part of the public API.
 */
export declare function tryResolveSync(promise: Promise<unknown> | Thenable<unknown>): {
    data: {} | null;
} | undefined;

declare type TuplePrefixes<T extends ReadonlyArray<unknown>> = T extends readonly [] ? readonly [] : TuplePrefixes<DropLast<T>> | T;

declare type UnsetMarker = typeof unsetMarker;
export { UnsetMarker }
export { UnsetMarker as UnsetMarker_alias_1 }

declare const unsetMarker: unique symbol;
export { unsetMarker }
export { unsetMarker as unsetMarker_alias_1 }

declare type Updater<TInput, TOutput> = TOutput | ((input: TInput) => TOutput);
export { Updater }
export { Updater as Updater_alias_1 }

declare type WithRequired<TTarget, TKey extends keyof TTarget> = TTarget & {
    [_ in TKey]: {};
};
export { WithRequired }
export { WithRequired as WithRequired_alias_1 }

export { }
