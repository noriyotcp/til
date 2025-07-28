import { Suspense, lazy } from 'react'

// 動的インポートでReactコンポーネントを遅延読み込み
const LazyErrorBoundary = lazy(() => import('./ErrorBoundary'))

// 汎用的なローディングコンポーネント
export const ComponentSkeleton = ({ height = 'h-20' }: { height?: string }) => (
  <div className={`${height} bg-accent/5 rounded-lg animate-pulse flex items-center justify-center`}>
    <div className="text-accent/40 text-sm">Loading...</div>
  </div>
)

// 動的ErrorBoundaryラッパー
export const DynamicErrorBoundary = ({
  children,
  fallback
}: {
  children: React.ReactNode
  fallback?: React.ReactNode
}) => (
  <Suspense fallback={<ComponentSkeleton />}>
    <LazyErrorBoundary fallback={fallback}>
      {children}
    </LazyErrorBoundary>
  </Suspense>
)

export default {
  ErrorBoundary: DynamicErrorBoundary,
  Skeleton: ComponentSkeleton,
}
