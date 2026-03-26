import { QueryClient } from '@tanstack/react-query'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000, // 1 minute
      gcTime: 10 * 60 * 1000, // 10 minutes (previously cacheTime)
      retry: 1,
    },
    mutations: {
      retry: 1,
    },
  },
})
