import { Suspense, lazy, useState, useEffect } from 'react'
import ErrorBoundary from './ErrorBoundary'

// 動的インポートでGitHubカレンダーを遅延読み込み
const GitHubCalendar = lazy(() => import('react-github-calendar'))

interface LazyGithubCalendarProps {
  username: string
}

// ローディングコンポーネント
const CalendarSkeleton = () => (
  <div className="github-calendar my-6 animate-pulse">
    <div className="h-32 bg-accent/10 rounded-lg flex items-center justify-center">
      <div className="text-accent/60 text-sm">Loading GitHub activity...</div>
    </div>
  </div>
)

// Intersection Observer を使用してビューポートに入った時に読み込み
const LazyGithubCalendar = ({ username }: LazyGithubCalendarProps) => {
  const [isVisible, setIsVisible] = useState(false)
  const [containerRef, setContainerRef] = useState<HTMLDivElement | null>(null)

  useEffect(() => {
    if (!containerRef) return

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true)
          observer.disconnect()
        }
      },
      {
        rootMargin: '100px', // 100px手前で読み込み開始
        threshold: 0.1,
      }
    )

    observer.observe(containerRef)

    return () => observer.disconnect()
  }, [containerRef])

  const themeFromColorscheme = ["var(--theme-background)", "var(--theme-accent)"]
  const theme = { light: themeFromColorscheme, dark: themeFromColorscheme }

  return (
    <div ref={setContainerRef} className="min-h-32">
      {isVisible ? (
        <ErrorBoundary fallback={<CalendarSkeleton />}>
          <Suspense fallback={<CalendarSkeleton />}>
            <div className="github-calendar my-6">
              <GitHubCalendar username={username} theme={theme} />
            </div>
          </Suspense>
        </ErrorBoundary>
      ) : (
        <CalendarSkeleton />
      )}
    </div>
  )
}

export default LazyGithubCalendar
