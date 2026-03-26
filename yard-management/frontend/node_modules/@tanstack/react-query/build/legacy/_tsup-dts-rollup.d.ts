import { AnyDataTag } from '@tanstack/query-core';
import { CancelledError } from '@tanstack/query-core';
import { CancelOptions } from '@tanstack/query-core';
import { DataTag } from '@tanstack/query-core';
import { dataTagErrorSymbol } from '@tanstack/query-core';
import { dataTagSymbol } from '@tanstack/query-core';
import { DefaultedInfiniteQueryObserverOptions } from '@tanstack/query-core';
import { DefaultedQueryObserverOptions } from '@tanstack/query-core';
import { DefaultError } from '@tanstack/query-core';
import { DefaultOptions } from '@tanstack/query-core';
import { defaultScheduler } from '@tanstack/query-core';
import { defaultShouldDehydrateMutation } from '@tanstack/query-core';
import { defaultShouldDehydrateQuery } from '@tanstack/query-core';
import { DefinedInfiniteQueryObserverResult } from '@tanstack/query-core';
import { DefinedQueryObserverResult } from '@tanstack/query-core';
import { dehydrate } from '@tanstack/query-core';
import { DehydratedState } from '@tanstack/query-core';
import { DehydrateOptions } from '@tanstack/query-core';
import { DistributiveOmit } from '@tanstack/query-core';
import { Enabled } from '@tanstack/query-core';
import { EnsureInfiniteQueryDataOptions } from '@tanstack/query-core';
import { EnsureQueryDataOptions } from '@tanstack/query-core';
import { environmentManager } from '@tanstack/query-core';
import { experimental_streamedQuery } from '@tanstack/query-core';
import { FetchInfiniteQueryOptions } from '@tanstack/query-core';
import { FetchNextPageOptions } from '@tanstack/query-core';
import { FetchPreviousPageOptions } from '@tanstack/query-core';
import { FetchQueryOptions } from '@tanstack/query-core';
import { FetchStatus } from '@tanstack/query-core';
import { focusManager } from '@tanstack/query-core';
import { GetNextPageParamFunction } from '@tanstack/query-core';
import { GetPreviousPageParamFunction } from '@tanstack/query-core';
import { hashKey } from '@tanstack/query-core';
import { hydrate } from '@tanstack/query-core';
import { HydrateOptions } from '@tanstack/query-core';
import { InferDataFromTag } from '@tanstack/query-core';
import { InferErrorFromTag } from '@tanstack/query-core';
import { InfiniteData } from '@tanstack/query-core';
import { InfiniteQueryObserver } from '@tanstack/query-core';
import { InfiniteQueryObserverBaseResult } from '@tanstack/query-core';
import { InfiniteQueryObserverLoadingErrorResult } from '@tanstack/query-core';
import { InfiniteQueryObserverLoadingResult } from '@tanstack/query-core';
import { InfiniteQueryObserverOptions } from '@tanstack/query-core';
import { InfiniteQueryObserverPendingResult } from '@tanstack/query-core';
import { InfiniteQueryObserverPlaceholderResult } from '@tanstack/query-core';
import { InfiniteQueryObserverRefetchErrorResult } from '@tanstack/query-core';
import { InfiniteQueryObserverResult } from '@tanstack/query-core';
import { InfiniteQueryObserverSuccessResult } from '@tanstack/query-core';
import { InfiniteQueryPageParamsOptions } from '@tanstack/query-core';
import { InitialDataFunction } from '@tanstack/query-core';
import { InitialPageParam } from '@tanstack/query-core';
import { InvalidateOptions } from '@tanstack/query-core';
import { InvalidateQueryFilters } from '@tanstack/query-core';
import { isCancelledError } from '@tanstack/query-core';
import { isServer } from '@tanstack/query-core';
import { JSX } from 'react/jsx-runtime';
import { keepPreviousData } from '@tanstack/query-core';
import { ManagedTimerId } from '@tanstack/query-core';
import { matchMutation } from '@tanstack/query-core';
import { matchQuery } from '@tanstack/query-core';
import { MutateFunction } from '@tanstack/query-core';
import { MutateOptions } from '@tanstack/query-core';
import { Mutation } from '@tanstack/query-core';
import { MutationCache } from '@tanstack/query-core';
import { MutationCacheNotifyEvent } from '@tanstack/query-core';
import { MutationFilters } from '@tanstack/query-core';
import { MutationFunction } from '@tanstack/query-core';
import { MutationFunctionContext } from '@tanstack/query-core';
import { MutationKey } from '@tanstack/query-core';
import { MutationMeta } from '@tanstack/query-core';
import { MutationObserver as MutationObserver_2 } from '@tanstack/query-core';
import { MutationObserverBaseResult } from '@tanstack/query-core';
import { MutationObserverErrorResult } from '@tanstack/query-core';
import { MutationObserverIdleResult } from '@tanstack/query-core';
import { MutationObserverLoadingResult } from '@tanstack/query-core';
import { MutationObserverOptions } from '@tanstack/query-core';
import { MutationObserverResult } from '@tanstack/query-core';
import { MutationObserverSuccessResult } from '@tanstack/query-core';
import { MutationOptions } from '@tanstack/query-core';
import { MutationScope } from '@tanstack/query-core';
import { MutationState } from '@tanstack/query-core';
import { MutationStatus } from '@tanstack/query-core';
import { NetworkMode } from '@tanstack/query-core';
import { NoInfer as NoInfer_2 } from '@tanstack/query-core';
import { NonUndefinedGuard } from '@tanstack/query-core';
import { noop } from '@tanstack/query-core';
import { NotifyEvent } from '@tanstack/query-core';
import { NotifyEventType } from '@tanstack/query-core';
import { notifyManager } from '@tanstack/query-core';
import { NotifyOnChangeProps } from '@tanstack/query-core';
import { OmitKeyof } from '@tanstack/query-core';
import { onlineManager } from '@tanstack/query-core';
import { Override } from '@tanstack/query-core';
import { partialMatchKey } from '@tanstack/query-core';
import { PlaceholderDataFunction } from '@tanstack/query-core';
import { QueriesObserver } from '@tanstack/query-core';
import { QueriesObserverOptions } from '@tanstack/query-core';
import { QueriesPlaceholderDataFunction } from '@tanstack/query-core';
import { Query } from '@tanstack/query-core';
import { QueryCache } from '@tanstack/query-core';
import { QueryCacheNotifyEvent } from '@tanstack/query-core';
import { QueryClient } from '@tanstack/query-core';
import { QueryClientConfig } from '@tanstack/query-core';
import { QueryFilters } from '@tanstack/query-core';
import { QueryFunction } from '@tanstack/query-core';
import { QueryFunctionContext } from '@tanstack/query-core';
import { QueryKey } from '@tanstack/query-core';
import { QueryKeyHashFunction } from '@tanstack/query-core';
import { QueryMeta } from '@tanstack/query-core';
import { QueryObserver } from '@tanstack/query-core';
import { QueryObserverBaseResult } from '@tanstack/query-core';
import { QueryObserverLoadingErrorResult } from '@tanstack/query-core';
import { QueryObserverLoadingResult } from '@tanstack/query-core';
import { QueryObserverOptions } from '@tanstack/query-core';
import { QueryObserverPendingResult } from '@tanstack/query-core';
import { QueryObserverPlaceholderResult } from '@tanstack/query-core';
import { QueryObserverRefetchErrorResult } from '@tanstack/query-core';
import { QueryObserverResult } from '@tanstack/query-core';
import { QueryObserverSuccessResult } from '@tanstack/query-core';
import { QueryOptions } from '@tanstack/query-core';
import { QueryPersister } from '@tanstack/query-core';
import { QueryState } from '@tanstack/query-core';
import { QueryStatus } from '@tanstack/query-core';
import * as React_2 from 'react';
import { RefetchOptions } from '@tanstack/query-core';
import { RefetchQueryFilters } from '@tanstack/query-core';
import { Register } from '@tanstack/query-core';
import { replaceEqualDeep } from '@tanstack/query-core';
import { ResetOptions } from '@tanstack/query-core';
import { ResultOptions } from '@tanstack/query-core';
import { SetDataOptions } from '@tanstack/query-core';
import { shouldThrowError } from '@tanstack/query-core';
import { SkipToken } from '@tanstack/query-core';
import { skipToken } from '@tanstack/query-core';
import { StaleTime } from '@tanstack/query-core';
import { StaleTimeFunction } from '@tanstack/query-core';
import { ThrowOnError } from '@tanstack/query-core';
import { TimeoutCallback } from '@tanstack/query-core';
import { timeoutManager } from '@tanstack/query-core';
import { TimeoutProvider } from '@tanstack/query-core';
import { UnsetMarker } from '@tanstack/query-core';
import { unsetMarker } from '@tanstack/query-core';
import { Updater } from '@tanstack/query-core';
import { WithRequired } from '@tanstack/query-core';

export { AnyDataTag }

declare type AnyUseBaseQueryOptions = UseBaseQueryOptions<any, any, any, any, any>;
export { AnyUseBaseQueryOptions }
export { AnyUseBaseQueryOptions as AnyUseBaseQueryOptions_alias_1 }

declare type AnyUseInfiniteQueryOptions = UseInfiniteQueryOptions<any, any, any, any, any>;
export { AnyUseInfiniteQueryOptions }
export { AnyUseInfiniteQueryOptions as AnyUseInfiniteQueryOptions_alias_1 }

declare type AnyUseMutationOptions = UseMutationOptions<any, any, any, any>;
export { AnyUseMutationOptions }
export { AnyUseMutationOptions as AnyUseMutationOptions_alias_1 }

declare type AnyUseQueryOptions = UseQueryOptions<any, any, any, any>;
export { AnyUseQueryOptions }
export { AnyUseQueryOptions as AnyUseQueryOptions_alias_1 }

declare type AnyUseSuspenseInfiniteQueryOptions = UseSuspenseInfiniteQueryOptions<any, any, any, any, any>;
export { AnyUseSuspenseInfiniteQueryOptions }
export { AnyUseSuspenseInfiniteQueryOptions as AnyUseSuspenseInfiniteQueryOptions_alias_1 }

declare type AnyUseSuspenseQueryOptions = UseSuspenseQueryOptions<any, any, any, any>;
export { AnyUseSuspenseQueryOptions }
export { AnyUseSuspenseQueryOptions as AnyUseSuspenseQueryOptions_alias_1 }

export { CancelledError }

export { CancelOptions }

export { DataTag }

export { dataTagErrorSymbol }

export { dataTagSymbol }

export { DefaultedInfiniteQueryObserverOptions }

export { DefaultedQueryObserverOptions }

export { DefaultError }

export { DefaultOptions }

export { defaultScheduler }

export { defaultShouldDehydrateMutation }

export { defaultShouldDehydrateQuery }

export declare const defaultThrowOnError: <TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(_error: TError, query: Query<TQueryFnData, TError, TData, TQueryKey>) => boolean;

export { DefinedInfiniteQueryObserverResult }

declare type DefinedInitialDataInfiniteOptions<TQueryFnData, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown> = UseInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam> & {
    initialData: NonUndefinedGuard<InfiniteData<TQueryFnData, TPageParam>> | (() => NonUndefinedGuard<InfiniteData<TQueryFnData, TPageParam>>) | undefined;
};
export { DefinedInitialDataInfiniteOptions }
export { DefinedInitialDataInfiniteOptions as DefinedInitialDataInfiniteOptions_alias_1 }

declare type DefinedInitialDataOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> = Omit<UseQueryOptions<TQueryFnData, TError, TData, TQueryKey>, 'queryFn'> & {
    initialData: NonUndefinedGuard<TQueryFnData> | (() => NonUndefinedGuard<TQueryFnData>);
    queryFn?: QueryFunction<TQueryFnData, TQueryKey>;
};
export { DefinedInitialDataOptions }
export { DefinedInitialDataOptions as DefinedInitialDataOptions_alias_1 }

export { DefinedQueryObserverResult }

declare type DefinedUseInfiniteQueryResult<TData = unknown, TError = DefaultError> = DefinedInfiniteQueryObserverResult<TData, TError>;
export { DefinedUseInfiniteQueryResult }
export { DefinedUseInfiniteQueryResult as DefinedUseInfiniteQueryResult_alias_1 }

declare type DefinedUseQueryResult<TData = unknown, TError = DefaultError> = DefinedQueryObserverResult<TData, TError>;
export { DefinedUseQueryResult }
export { DefinedUseQueryResult as DefinedUseQueryResult_alias_1 }

export { dehydrate }

export { DehydratedState }

export { DehydrateOptions }

export { DistributiveOmit }

export { Enabled }

export { EnsureInfiniteQueryDataOptions }

export declare const ensurePreventErrorBoundaryRetry: <TQueryFnData, TError, TData, TQueryData, TQueryKey extends QueryKey>(options: DefaultedQueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>, errorResetBoundary: QueryErrorResetBoundaryValue, query: Query<TQueryFnData, TError, TQueryData, TQueryKey> | undefined) => void;

export { EnsureQueryDataOptions }

export declare const ensureSuspenseTimers: (defaultedOptions: DefaultedQueryObserverOptions<any, any, any, any, any>) => void;

export { environmentManager }

export { experimental_streamedQuery }

export { FetchInfiniteQueryOptions }

export { FetchNextPageOptions }

export declare const fetchOptimistic: <TQueryFnData, TError, TData, TQueryData, TQueryKey extends QueryKey>(defaultedOptions: DefaultedQueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>, observer: QueryObserver<TQueryFnData, TError, TData, TQueryData, TQueryKey>, errorResetBoundary: QueryErrorResetBoundaryValue) => Promise<void | QueryObserverResult<TData, TError>>;

export { FetchPreviousPageOptions }

export { FetchQueryOptions }

export { FetchStatus }

export { focusManager }

declare type GetDefinedOrUndefinedQueryResult<T, TData, TError = unknown> = T extends {
    initialData?: infer TInitialData;
} ? unknown extends TInitialData ? UseQueryResult<TData, TError> : TInitialData extends TData ? DefinedUseQueryResult<TData, TError> : TInitialData extends () => infer TInitialDataResult ? unknown extends TInitialDataResult ? UseQueryResult<TData, TError> : TInitialDataResult extends TData ? DefinedUseQueryResult<TData, TError> : UseQueryResult<TData, TError> : UseQueryResult<TData, TError> : UseQueryResult<TData, TError>;

export declare const getHasError: <TData, TError, TQueryFnData, TQueryData, TQueryKey extends QueryKey>({ result, errorResetBoundary, throwOnError, query, suspense, }: {
    result: QueryObserverResult<TData, TError>;
    errorResetBoundary: QueryErrorResetBoundaryValue;
    throwOnError: ThrowOnError<TQueryFnData, TError, TQueryData, TQueryKey>;
    query: Query<TQueryFnData, TError, TQueryData, TQueryKey> | undefined;
    suspense: boolean | undefined;
}) => boolean | undefined;

export { GetNextPageParamFunction }

export { GetPreviousPageParamFunction }

declare type GetUseQueryOptionsForUseQueries<T> = T extends {
    queryFnData: infer TQueryFnData;
    error?: infer TError;
    data: infer TData;
} ? UseQueryOptionsForUseQueries<TQueryFnData, TError, TData> : T extends {
    queryFnData: infer TQueryFnData;
    error?: infer TError;
} ? UseQueryOptionsForUseQueries<TQueryFnData, TError> : T extends {
    data: infer TData;
    error?: infer TError;
} ? UseQueryOptionsForUseQueries<unknown, TError, TData> : T extends [infer TQueryFnData, infer TError, infer TData] ? UseQueryOptionsForUseQueries<TQueryFnData, TError, TData> : T extends [infer TQueryFnData, infer TError] ? UseQueryOptionsForUseQueries<TQueryFnData, TError> : T extends [infer TQueryFnData] ? UseQueryOptionsForUseQueries<TQueryFnData> : T extends {
    queryFn?: QueryFunction<infer TQueryFnData, infer TQueryKey> | SkipTokenForUseQueries;
    select?: (data: any) => infer TData;
    throwOnError?: ThrowOnError<any, infer TError, any, any>;
} ? UseQueryOptionsForUseQueries<TQueryFnData, unknown extends TError ? DefaultError : TError, unknown extends TData ? TQueryFnData : TData, TQueryKey> : UseQueryOptionsForUseQueries;

declare type GetUseQueryResult<T> = T extends {
    queryFnData: any;
    error?: infer TError;
    data: infer TData;
} ? GetDefinedOrUndefinedQueryResult<T, TData, TError> : T extends {
    queryFnData: infer TQueryFnData;
    error?: infer TError;
} ? GetDefinedOrUndefinedQueryResult<T, TQueryFnData, TError> : T extends {
    data: infer TData;
    error?: infer TError;
} ? GetDefinedOrUndefinedQueryResult<T, TData, TError> : T extends [any, infer TError, infer TData] ? GetDefinedOrUndefinedQueryResult<T, TData, TError> : T extends [infer TQueryFnData, infer TError] ? GetDefinedOrUndefinedQueryResult<T, TQueryFnData, TError> : T extends [infer TQueryFnData] ? GetDefinedOrUndefinedQueryResult<T, TQueryFnData> : T extends {
    queryFn?: QueryFunction<infer TQueryFnData, any> | SkipTokenForUseQueries;
    select?: (data: any) => infer TData;
    throwOnError?: ThrowOnError<any, infer TError, any, any>;
} ? GetDefinedOrUndefinedQueryResult<T, unknown extends TData ? TQueryFnData : TData, unknown extends TError ? DefaultError : TError> : UseQueryResult;

declare type GetUseSuspenseQueryOptions<T> = T extends {
    queryFnData: infer TQueryFnData;
    error?: infer TError;
    data: infer TData;
} ? UseSuspenseQueryOptions<TQueryFnData, TError, TData> : T extends {
    queryFnData: infer TQueryFnData;
    error?: infer TError;
} ? UseSuspenseQueryOptions<TQueryFnData, TError> : T extends {
    data: infer TData;
    error?: infer TError;
} ? UseSuspenseQueryOptions<unknown, TError, TData> : T extends [infer TQueryFnData, infer TError, infer TData] ? UseSuspenseQueryOptions<TQueryFnData, TError, TData> : T extends [infer TQueryFnData, infer TError] ? UseSuspenseQueryOptions<TQueryFnData, TError> : T extends [infer TQueryFnData] ? UseSuspenseQueryOptions<TQueryFnData> : T extends {
    queryFn?: QueryFunction<infer TQueryFnData, infer TQueryKey> | SkipTokenForUseQueries_2;
    select?: (data: any) => infer TData;
    throwOnError?: ThrowOnError<any, infer TError, any, any>;
} ? UseSuspenseQueryOptions<TQueryFnData, TError, TData, TQueryKey> : T extends {
    queryFn?: QueryFunction<infer TQueryFnData, infer TQueryKey> | SkipTokenForUseQueries_2;
    throwOnError?: ThrowOnError<any, infer TError, any, any>;
} ? UseSuspenseQueryOptions<TQueryFnData, TError, TQueryFnData, TQueryKey> : UseSuspenseQueryOptions;

declare type GetUseSuspenseQueryResult<T> = T extends {
    queryFnData: any;
    error?: infer TError;
    data: infer TData;
} ? UseSuspenseQueryResult<TData, TError> : T extends {
    queryFnData: infer TQueryFnData;
    error?: infer TError;
} ? UseSuspenseQueryResult<TQueryFnData, TError> : T extends {
    data: infer TData;
    error?: infer TError;
} ? UseSuspenseQueryResult<TData, TError> : T extends [any, infer TError, infer TData] ? UseSuspenseQueryResult<TData, TError> : T extends [infer TQueryFnData, infer TError] ? UseSuspenseQueryResult<TQueryFnData, TError> : T extends [infer TQueryFnData] ? UseSuspenseQueryResult<TQueryFnData> : T extends {
    queryFn?: QueryFunction<infer TQueryFnData, any> | SkipTokenForUseQueries_2;
    select?: (data: any) => infer TData;
    throwOnError?: ThrowOnError<any, infer TError, any, any>;
} ? UseSuspenseQueryResult<unknown extends TData ? TQueryFnData : TData, unknown extends TError ? DefaultError : TError> : T extends {
    queryFn?: QueryFunction<infer TQueryFnData, any> | SkipTokenForUseQueries_2;
    throwOnError?: ThrowOnError<any, infer TError, any, any>;
} ? UseSuspenseQueryResult<TQueryFnData, unknown extends TError ? DefaultError : TError> : UseSuspenseQueryResult;

export { hashKey }

export { hydrate }

export { HydrateOptions }

declare const HydrationBoundary: ({ children, options, state, queryClient, }: HydrationBoundaryProps) => React_2.ReactElement;
export { HydrationBoundary }
export { HydrationBoundary as HydrationBoundary_alias_1 }

declare interface HydrationBoundaryProps {
    state: DehydratedState | null | undefined;
    options?: OmitKeyof<HydrateOptions, 'defaultOptions'> & {
        defaultOptions?: OmitKeyof<Exclude<HydrateOptions['defaultOptions'], undefined>, 'mutations'>;
    };
    children?: React_2.ReactNode;
    queryClient?: QueryClient;
}
export { HydrationBoundaryProps }
export { HydrationBoundaryProps as HydrationBoundaryProps_alias_1 }

export { InferDataFromTag }

export { InferErrorFromTag }

export { InfiniteData }

export { InfiniteQueryObserver }

export { InfiniteQueryObserverBaseResult }

export { InfiniteQueryObserverLoadingErrorResult }

export { InfiniteQueryObserverLoadingResult }

export { InfiniteQueryObserverOptions }

export { InfiniteQueryObserverPendingResult }

export { InfiniteQueryObserverPlaceholderResult }

export { InfiniteQueryObserverRefetchErrorResult }

export { InfiniteQueryObserverResult }

export { InfiniteQueryObserverSuccessResult }

declare function infiniteQueryOptions<TQueryFnData, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: DefinedInitialDataInfiniteOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>): DefinedInitialDataInfiniteOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam> & {
    queryKey: DataTag<TQueryKey, InfiniteData<TQueryFnData>, TError>;
};

declare function infiniteQueryOptions<TQueryFnData, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: UnusedSkipTokenInfiniteOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>): UnusedSkipTokenInfiniteOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam> & {
    queryKey: DataTag<TQueryKey, InfiniteData<TQueryFnData>, TError>;
};

declare function infiniteQueryOptions<TQueryFnData, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: UndefinedInitialDataInfiniteOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>): UndefinedInitialDataInfiniteOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam> & {
    queryKey: DataTag<TQueryKey, InfiniteData<TQueryFnData>, TError>;
};
export { infiniteQueryOptions }
export { infiniteQueryOptions as infiniteQueryOptions_alias_1 }

export { InfiniteQueryPageParamsOptions }

export { InitialDataFunction }

export { InitialPageParam }

export { InvalidateOptions }

export { InvalidateQueryFilters }

export { isCancelledError }

declare const IsRestoringProvider: React_2.Provider<boolean>;
export { IsRestoringProvider }
export { IsRestoringProvider as IsRestoringProvider_alias_1 }

export { isServer }

export { keepPreviousData }

export { ManagedTimerId }

export { matchMutation }

export { matchQuery }

declare type MAXIMUM_DEPTH = 20;

declare type MAXIMUM_DEPTH_2 = 20;

export { MutateFunction }

export { MutateOptions }

export { Mutation }

export { MutationCache }

export { MutationCacheNotifyEvent }

export { MutationFilters }

export { MutationFunction }

export { MutationFunctionContext }

export { MutationKey }

export { MutationMeta }

export { MutationObserver_2 as MutationObserver }

export { MutationObserverBaseResult }

export { MutationObserverErrorResult }

export { MutationObserverIdleResult }

export { MutationObserverLoadingResult }

export { MutationObserverOptions }

export { MutationObserverResult }

export { MutationObserverSuccessResult }

export { MutationOptions }

declare function mutationOptions<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown>(options: WithRequired<UseMutationOptions<TData, TError, TVariables, TOnMutateResult>, 'mutationKey'>): WithRequired<UseMutationOptions<TData, TError, TVariables, TOnMutateResult>, 'mutationKey'>;

declare function mutationOptions<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown>(options: Omit<UseMutationOptions<TData, TError, TVariables, TOnMutateResult>, 'mutationKey'>): Omit<UseMutationOptions<TData, TError, TVariables, TOnMutateResult>, 'mutationKey'>;
export { mutationOptions }
export { mutationOptions as mutationOptions_alias_1 }

export { MutationScope }

export { MutationState }

declare type MutationStateOptions<TResult = MutationState> = {
    filters?: MutationFilters;
    select?: (mutation: Mutation) => TResult;
};

export { MutationStatus }

export { NetworkMode }

export { NoInfer_2 as NoInfer }

export { NonUndefinedGuard }

export { noop }

export { NotifyEvent }

export { NotifyEventType }

export { notifyManager }

export { NotifyOnChangeProps }

export { OmitKeyof }

export { onlineManager }

export { Override }

export { partialMatchKey }

export { PlaceholderDataFunction }

export { QueriesObserver }

export { QueriesObserverOptions }

/**
 * QueriesOptions reducer recursively unwraps function arguments to infer/enforce type param
 */
declare type QueriesOptions<T extends Array<any>, TResults extends Array<any> = [], TDepth extends ReadonlyArray<number> = []> = TDepth['length'] extends MAXIMUM_DEPTH ? Array<UseQueryOptionsForUseQueries> : T extends [] ? [] : T extends [infer Head] ? [...TResults, GetUseQueryOptionsForUseQueries<Head>] : T extends [infer Head, ...infer Tails] ? QueriesOptions<[
...Tails
], [
...TResults,
GetUseQueryOptionsForUseQueries<Head>
], [
...TDepth,
1
]> : ReadonlyArray<unknown> extends T ? T : T extends Array<UseQueryOptionsForUseQueries<infer TQueryFnData, infer TError, infer TData, infer TQueryKey>> ? Array<UseQueryOptionsForUseQueries<TQueryFnData, TError, TData, TQueryKey>> : Array<UseQueryOptionsForUseQueries>;
export { QueriesOptions }
export { QueriesOptions as QueriesOptions_alias_1 }

export { QueriesPlaceholderDataFunction }

/**
 * QueriesResults reducer recursively maps type param to results
 */
declare type QueriesResults<T extends Array<any>, TResults extends Array<any> = [], TDepth extends ReadonlyArray<number> = []> = TDepth['length'] extends MAXIMUM_DEPTH ? Array<UseQueryResult> : T extends [] ? [] : T extends [infer Head] ? [...TResults, GetUseQueryResult<Head>] : T extends [infer Head, ...infer Tails] ? QueriesResults<[
...Tails
], [
...TResults,
GetUseQueryResult<Head>
], [
...TDepth,
1
]> : {
    [K in keyof T]: GetUseQueryResult<T[K]>;
};
export { QueriesResults }
export { QueriesResults as QueriesResults_alias_1 }

export { Query }

export { QueryCache }

export { QueryCacheNotifyEvent }

export { QueryClient }

export { QueryClientConfig }

declare const QueryClientContext: React_2.Context<QueryClient | undefined>;
export { QueryClientContext }
export { QueryClientContext as QueryClientContext_alias_1 }

declare const QueryClientProvider: ({ client, children, }: QueryClientProviderProps) => React_2.JSX.Element;
export { QueryClientProvider }
export { QueryClientProvider as QueryClientProvider_alias_1 }

declare type QueryClientProviderProps = {
    client: QueryClient;
    children?: React_2.ReactNode;
};
export { QueryClientProviderProps }
export { QueryClientProviderProps as QueryClientProviderProps_alias_1 }

declare type QueryErrorClearResetFunction = () => void;
export { QueryErrorClearResetFunction }
export { QueryErrorClearResetFunction as QueryErrorClearResetFunction_alias_1 }

declare type QueryErrorIsResetFunction = () => boolean;
export { QueryErrorIsResetFunction }
export { QueryErrorIsResetFunction as QueryErrorIsResetFunction_alias_1 }

declare const QueryErrorResetBoundary: ({ children, }: QueryErrorResetBoundaryProps) => JSX.Element;
export { QueryErrorResetBoundary }
export { QueryErrorResetBoundary as QueryErrorResetBoundary_alias_1 }

declare type QueryErrorResetBoundaryFunction = (value: QueryErrorResetBoundaryValue) => React_2.ReactNode;
export { QueryErrorResetBoundaryFunction }
export { QueryErrorResetBoundaryFunction as QueryErrorResetBoundaryFunction_alias_1 }

declare interface QueryErrorResetBoundaryProps {
    children: QueryErrorResetBoundaryFunction | React_2.ReactNode;
}
export { QueryErrorResetBoundaryProps }
export { QueryErrorResetBoundaryProps as QueryErrorResetBoundaryProps_alias_1 }

export declare interface QueryErrorResetBoundaryValue {
    clearReset: QueryErrorClearResetFunction;
    isReset: QueryErrorIsResetFunction;
    reset: QueryErrorResetFunction;
}

declare type QueryErrorResetFunction = () => void;
export { QueryErrorResetFunction }
export { QueryErrorResetFunction as QueryErrorResetFunction_alias_1 }

export { QueryFilters }

export { QueryFunction }

export { QueryFunctionContext }

export { QueryKey }

export { QueryKeyHashFunction }

export { QueryMeta }

export { QueryObserver }

export { QueryObserverBaseResult }

export { QueryObserverLoadingErrorResult }

export { QueryObserverLoadingResult }

export { QueryObserverOptions }

export { QueryObserverPendingResult }

export { QueryObserverPlaceholderResult }

export { QueryObserverRefetchErrorResult }

export { QueryObserverResult }

export { QueryObserverSuccessResult }

export { QueryOptions }

declare function queryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(options: DefinedInitialDataOptions<TQueryFnData, TError, TData, TQueryKey>): DefinedInitialDataOptions<TQueryFnData, TError, TData, TQueryKey> & {
    queryKey: DataTag<TQueryKey, TQueryFnData, TError>;
};

declare function queryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(options: UnusedSkipTokenOptions<TQueryFnData, TError, TData, TQueryKey>): UnusedSkipTokenOptions<TQueryFnData, TError, TData, TQueryKey> & {
    queryKey: DataTag<TQueryKey, TQueryFnData, TError>;
};

declare function queryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(options: UndefinedInitialDataOptions<TQueryFnData, TError, TData, TQueryKey>): UndefinedInitialDataOptions<TQueryFnData, TError, TData, TQueryKey> & {
    queryKey: DataTag<TQueryKey, TQueryFnData, TError>;
};
export { queryOptions }
export { queryOptions as queryOptions_alias_1 }

export { QueryPersister }

export { QueryState }

export { QueryStatus }

export { RefetchOptions }

export { RefetchQueryFilters }

export { Register }

export { replaceEqualDeep }

export { ResetOptions }

export { ResultOptions }

export { SetDataOptions }

export declare const shouldSuspend: (defaultedOptions: DefaultedQueryObserverOptions<any, any, any, any, any> | undefined, result: QueryObserverResult<any, any>) => boolean | undefined;

export { shouldThrowError }

export { SkipToken }

export { skipToken }

declare type SkipTokenForUseQueries = symbol;

declare type SkipTokenForUseQueries_2 = symbol;

export { StaleTime }

export { StaleTimeFunction }

/**
 * SuspenseQueriesOptions reducer recursively unwraps function arguments to infer/enforce type param
 */
declare type SuspenseQueriesOptions<T extends Array<any>, TResults extends Array<any> = [], TDepth extends ReadonlyArray<number> = []> = TDepth['length'] extends MAXIMUM_DEPTH_2 ? Array<UseSuspenseQueryOptions> : T extends [] ? [] : T extends [infer Head] ? [...TResults, GetUseSuspenseQueryOptions<Head>] : T extends [infer Head, ...infer Tails] ? SuspenseQueriesOptions<[
...Tails
], [
...TResults,
GetUseSuspenseQueryOptions<Head>
], [
...TDepth,
1
]> : Array<unknown> extends T ? T : T extends Array<UseSuspenseQueryOptions<infer TQueryFnData, infer TError, infer TData, infer TQueryKey>> ? Array<UseSuspenseQueryOptions<TQueryFnData, TError, TData, TQueryKey>> : Array<UseSuspenseQueryOptions>;
export { SuspenseQueriesOptions }
export { SuspenseQueriesOptions as SuspenseQueriesOptions_alias_1 }

/**
 * SuspenseQueriesResults reducer recursively maps type param to results
 */
declare type SuspenseQueriesResults<T extends Array<any>, TResults extends Array<any> = [], TDepth extends ReadonlyArray<number> = []> = TDepth['length'] extends MAXIMUM_DEPTH_2 ? Array<UseSuspenseQueryResult> : T extends [] ? [] : T extends [infer Head] ? [...TResults, GetUseSuspenseQueryResult<Head>] : T extends [infer Head, ...infer Tails] ? SuspenseQueriesResults<[
...Tails
], [
...TResults,
GetUseSuspenseQueryResult<Head>
], [
...TDepth,
1
]> : {
    [K in keyof T]: GetUseSuspenseQueryResult<T[K]>;
};
export { SuspenseQueriesResults }
export { SuspenseQueriesResults as SuspenseQueriesResults_alias_1 }

export { ThrowOnError }

export { TimeoutCallback }

export { timeoutManager }

export { TimeoutProvider }

declare type UndefinedInitialDataInfiniteOptions<TQueryFnData, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown> = UseInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam> & {
    initialData?: undefined | NonUndefinedGuard<InfiniteData<TQueryFnData, TPageParam>> | InitialDataFunction<NonUndefinedGuard<InfiniteData<TQueryFnData, TPageParam>>>;
};
export { UndefinedInitialDataInfiniteOptions }
export { UndefinedInitialDataInfiniteOptions as UndefinedInitialDataInfiniteOptions_alias_1 }

declare type UndefinedInitialDataOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> = UseQueryOptions<TQueryFnData, TError, TData, TQueryKey> & {
    initialData?: undefined | InitialDataFunction<NonUndefinedGuard<TQueryFnData>> | NonUndefinedGuard<TQueryFnData>;
};
export { UndefinedInitialDataOptions }
export { UndefinedInitialDataOptions as UndefinedInitialDataOptions_alias_1 }

export { UnsetMarker }

export { unsetMarker }

declare type UnusedSkipTokenInfiniteOptions<TQueryFnData, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown> = OmitKeyof<UseInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>, 'queryFn'> & {
    queryFn?: Exclude<UseInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>['queryFn'], SkipToken | undefined>;
};
export { UnusedSkipTokenInfiniteOptions }
export { UnusedSkipTokenInfiniteOptions as UnusedSkipTokenInfiniteOptions_alias_1 }

declare type UnusedSkipTokenOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> = OmitKeyof<UseQueryOptions<TQueryFnData, TError, TData, TQueryKey>, 'queryFn'> & {
    queryFn?: Exclude<UseQueryOptions<TQueryFnData, TError, TData, TQueryKey>['queryFn'], SkipToken | undefined>;
};
export { UnusedSkipTokenOptions }
export { UnusedSkipTokenOptions as UnusedSkipTokenOptions_alias_1 }

export { Updater }

declare type UseBaseMutationResult<TData = unknown, TError = DefaultError, TVariables = unknown, TOnMutateResult = unknown> = Override<MutationObserverResult<TData, TError, TVariables, TOnMutateResult>, {
    mutate: UseMutateFunction<TData, TError, TVariables, TOnMutateResult>;
}> & {
    mutateAsync: UseMutateAsyncFunction<TData, TError, TVariables, TOnMutateResult>;
};
export { UseBaseMutationResult }
export { UseBaseMutationResult as UseBaseMutationResult_alias_1 }

export declare function useBaseQuery<TQueryFnData, TError, TData, TQueryData, TQueryKey extends QueryKey>(options: UseBaseQueryOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey>, Observer: typeof QueryObserver, queryClient?: QueryClient): QueryObserverResult<TData, TError>;

declare interface UseBaseQueryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> extends QueryObserverOptions<TQueryFnData, TError, TData, TQueryData, TQueryKey> {
    /**
     * Set this to `false` to unsubscribe this observer from updates to the query cache.
     * Defaults to `true`.
     */
    subscribed?: boolean;
}
export { UseBaseQueryOptions }
export { UseBaseQueryOptions as UseBaseQueryOptions_alias_1 }

declare type UseBaseQueryResult<TData = unknown, TError = DefaultError> = QueryObserverResult<TData, TError>;
export { UseBaseQueryResult }
export { UseBaseQueryResult as UseBaseQueryResult_alias_1 }

export declare const useClearResetErrorBoundary: (errorResetBoundary: QueryErrorResetBoundaryValue) => void;

declare function useInfiniteQuery<TQueryFnData, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: DefinedInitialDataInfiniteOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>, queryClient?: QueryClient): DefinedUseInfiniteQueryResult<TData, TError>;

declare function useInfiniteQuery<TQueryFnData, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: UndefinedInitialDataInfiniteOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>, queryClient?: QueryClient): UseInfiniteQueryResult<TData, TError>;

declare function useInfiniteQuery<TQueryFnData, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: UseInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>, queryClient?: QueryClient): UseInfiniteQueryResult<TData, TError>;
export { useInfiniteQuery }
export { useInfiniteQuery as useInfiniteQuery_alias_1 }

declare interface UseInfiniteQueryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown> extends OmitKeyof<InfiniteQueryObserverOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>, 'suspense'> {
    /**
     * Set this to `false` to unsubscribe this observer from updates to the query cache.
     * Defaults to `true`.
     */
    subscribed?: boolean;
}
export { UseInfiniteQueryOptions }
export { UseInfiniteQueryOptions as UseInfiniteQueryOptions_alias_1 }

declare type UseInfiniteQueryResult<TData = unknown, TError = DefaultError> = InfiniteQueryObserverResult<TData, TError>;
export { UseInfiniteQueryResult }
export { UseInfiniteQueryResult as UseInfiniteQueryResult_alias_1 }

declare function useIsFetching(filters?: QueryFilters, queryClient?: QueryClient): number;
export { useIsFetching }
export { useIsFetching as useIsFetching_alias_1 }

declare function useIsMutating(filters?: MutationFilters, queryClient?: QueryClient): number;
export { useIsMutating }
export { useIsMutating as useIsMutating_alias_1 }

declare const useIsRestoring: () => boolean;
export { useIsRestoring }
export { useIsRestoring as useIsRestoring_alias_1 }

declare type UseMutateAsyncFunction<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> = MutateFunction<TData, TError, TVariables, TOnMutateResult>;
export { UseMutateAsyncFunction }
export { UseMutateAsyncFunction as UseMutateAsyncFunction_alias_1 }

declare type UseMutateFunction<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> = (...args: Parameters<MutateFunction<TData, TError, TVariables, TOnMutateResult>>) => void;
export { UseMutateFunction }
export { UseMutateFunction as UseMutateFunction_alias_1 }

declare function useMutation<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown>(options: UseMutationOptions<TData, TError, TVariables, TOnMutateResult>, queryClient?: QueryClient): UseMutationResult<TData, TError, TVariables, TOnMutateResult>;
export { useMutation }
export { useMutation as useMutation_alias_1 }

declare interface UseMutationOptions<TData = unknown, TError = DefaultError, TVariables = void, TOnMutateResult = unknown> extends OmitKeyof<MutationObserverOptions<TData, TError, TVariables, TOnMutateResult>, '_defaulted'> {
}
export { UseMutationOptions }
export { UseMutationOptions as UseMutationOptions_alias_1 }

declare type UseMutationResult<TData = unknown, TError = DefaultError, TVariables = unknown, TOnMutateResult = unknown> = UseBaseMutationResult<TData, TError, TVariables, TOnMutateResult>;
export { UseMutationResult }
export { UseMutationResult as UseMutationResult_alias_1 }

declare function useMutationState<TResult = MutationState>(options?: MutationStateOptions<TResult>, queryClient?: QueryClient): Array<TResult>;
export { useMutationState }
export { useMutationState as useMutationState_alias_1 }

declare function usePrefetchInfiniteQuery<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: FetchInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>, queryClient?: QueryClient): void;
export { usePrefetchInfiniteQuery }
export { usePrefetchInfiniteQuery as usePrefetchInfiniteQuery_alias_1 }

declare function usePrefetchQuery<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(options: UsePrefetchQueryOptions<TQueryFnData, TError, TData, TQueryKey>, queryClient?: QueryClient): void;
export { usePrefetchQuery }
export { usePrefetchQuery as usePrefetchQuery_alias_1 }

declare interface UsePrefetchQueryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> extends OmitKeyof<FetchQueryOptions<TQueryFnData, TError, TData, TQueryKey>, 'queryFn'> {
    queryFn?: Exclude<FetchQueryOptions<TQueryFnData, TError, TData, TQueryKey>['queryFn'], SkipToken>;
}
export { UsePrefetchQueryOptions }
export { UsePrefetchQueryOptions as UsePrefetchQueryOptions_alias_1 }

declare function useQueries<T extends Array<any>, TCombinedResult = QueriesResults<T>>({ queries, ...options }: {
    queries: readonly [...QueriesOptions<T>] | readonly [...{
        [K in keyof T]: GetUseQueryOptionsForUseQueries<T[K]>;
    }];
    combine?: (result: QueriesResults<T>) => TCombinedResult;
    subscribed?: boolean;
}, queryClient?: QueryClient): TCombinedResult;
export { useQueries }
export { useQueries as useQueries_alias_1 }

declare function useQuery<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(options: DefinedInitialDataOptions<TQueryFnData, TError, TData, TQueryKey>, queryClient?: QueryClient): DefinedUseQueryResult<NoInfer_2<TData>, TError>;

declare function useQuery<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(options: UndefinedInitialDataOptions<TQueryFnData, TError, TData, TQueryKey>, queryClient?: QueryClient): UseQueryResult<NoInfer_2<TData>, TError>;

declare function useQuery<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(options: UseQueryOptions<TQueryFnData, TError, TData, TQueryKey>, queryClient?: QueryClient): UseQueryResult<NoInfer_2<TData>, TError>;
export { useQuery }
export { useQuery as useQuery_alias_1 }

declare const useQueryClient: (queryClient?: QueryClient) => QueryClient;
export { useQueryClient }
export { useQueryClient as useQueryClient_alias_1 }

declare const useQueryErrorResetBoundary: () => QueryErrorResetBoundaryValue;
export { useQueryErrorResetBoundary }
export { useQueryErrorResetBoundary as useQueryErrorResetBoundary_alias_1 }

declare interface UseQueryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> extends OmitKeyof<UseBaseQueryOptions<TQueryFnData, TError, TData, TQueryFnData, TQueryKey>, 'suspense'> {
}
export { UseQueryOptions }
export { UseQueryOptions as UseQueryOptions_alias_1 }

declare type UseQueryOptionsForUseQueries<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> = OmitKeyof<UseQueryOptions<TQueryFnData, TError, TData, TQueryKey>, 'placeholderData' | 'subscribed'> & {
    placeholderData?: TQueryFnData | QueriesPlaceholderDataFunction<TQueryFnData>;
};

declare type UseQueryResult<TData = unknown, TError = DefaultError> = UseBaseQueryResult<TData, TError>;
export { UseQueryResult }
export { UseQueryResult as UseQueryResult_alias_1 }

declare function useSuspenseInfiniteQuery<TQueryFnData, TError = DefaultError, TData = InfiniteData<TQueryFnData>, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown>(options: UseSuspenseInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>, queryClient?: QueryClient): UseSuspenseInfiniteQueryResult<TData, TError>;
export { useSuspenseInfiniteQuery }
export { useSuspenseInfiniteQuery as useSuspenseInfiniteQuery_alias_1 }

declare interface UseSuspenseInfiniteQueryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey, TPageParam = unknown> extends OmitKeyof<UseInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>, 'queryFn' | 'enabled' | 'throwOnError' | 'placeholderData'> {
    queryFn?: Exclude<UseInfiniteQueryOptions<TQueryFnData, TError, TData, TQueryKey, TPageParam>['queryFn'], SkipToken>;
}
export { UseSuspenseInfiniteQueryOptions }
export { UseSuspenseInfiniteQueryOptions as UseSuspenseInfiniteQueryOptions_alias_1 }

declare type UseSuspenseInfiniteQueryResult<TData = unknown, TError = DefaultError> = OmitKeyof<DefinedInfiniteQueryObserverResult<TData, TError>, 'isPlaceholderData' | 'promise'>;
export { UseSuspenseInfiniteQueryResult }
export { UseSuspenseInfiniteQueryResult as UseSuspenseInfiniteQueryResult_alias_1 }

declare function useSuspenseQueries<T extends Array<any>, TCombinedResult = SuspenseQueriesResults<T>>(options: {
    queries: readonly [...SuspenseQueriesOptions<T>] | readonly [...{
        [K in keyof T]: GetUseSuspenseQueryOptions<T[K]>;
    }];
    combine?: (result: SuspenseQueriesResults<T>) => TCombinedResult;
}, queryClient?: QueryClient): TCombinedResult;

declare function useSuspenseQueries<T extends Array<any>, TCombinedResult = SuspenseQueriesResults<T>>(options: {
    queries: readonly [...SuspenseQueriesOptions<T>];
    combine?: (result: SuspenseQueriesResults<T>) => TCombinedResult;
}, queryClient?: QueryClient): TCombinedResult;
export { useSuspenseQueries }
export { useSuspenseQueries as useSuspenseQueries_alias_1 }

declare function useSuspenseQuery<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey>(options: UseSuspenseQueryOptions<TQueryFnData, TError, TData, TQueryKey>, queryClient?: QueryClient): UseSuspenseQueryResult<TData, TError>;
export { useSuspenseQuery }
export { useSuspenseQuery as useSuspenseQuery_alias_1 }

declare interface UseSuspenseQueryOptions<TQueryFnData = unknown, TError = DefaultError, TData = TQueryFnData, TQueryKey extends QueryKey = QueryKey> extends OmitKeyof<UseQueryOptions<TQueryFnData, TError, TData, TQueryKey>, 'queryFn' | 'enabled' | 'throwOnError' | 'placeholderData'> {
    queryFn?: Exclude<UseQueryOptions<TQueryFnData, TError, TData, TQueryKey>['queryFn'], SkipToken>;
}
export { UseSuspenseQueryOptions }
export { UseSuspenseQueryOptions as UseSuspenseQueryOptions_alias_1 }

declare type UseSuspenseQueryResult<TData = unknown, TError = DefaultError> = DistributiveOmit<DefinedQueryObserverResult<TData, TError>, 'isPlaceholderData' | 'promise'>;
export { UseSuspenseQueryResult }
export { UseSuspenseQueryResult as UseSuspenseQueryResult_alias_1 }

export declare const willFetch: (result: QueryObserverResult<any, any>, isRestoring: boolean) => boolean;

export { WithRequired }

export { }
