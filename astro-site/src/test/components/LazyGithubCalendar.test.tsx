import { render, screen, waitFor } from '@testing-library/react'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import LazyGithubCalendar from '../../components/LazyGithubCalendar'

// Mock react-github-calendar
vi.mock('react-github-calendar', () => ({
  default: ({ username, theme }: { username: string; theme: any }) => (
    <div
      data-testid="github-calendar"
      data-username={username}
      data-theme={JSON.stringify(theme)}
    >
      GitHub Calendar for {username}
    </div>
  ),
}))

// Mock Intersection Observer
const mockIntersectionObserver = vi.fn()
mockIntersectionObserver.mockReturnValue({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
})

beforeEach(() => {
  vi.clearAllMocks()
  global.IntersectionObserver = mockIntersectionObserver
})

describe('LazyGithubCalendar', () => {
  it('renders skeleton initially', () => {
    render(<LazyGithubCalendar username="testuser" />)

    expect(screen.getByText('Loading GitHub activity...')).toBeInTheDocument()
    expect(screen.queryByTestId('github-calendar')).not.toBeInTheDocument()
  })

  it('sets up intersection observer correctly', () => {
    render(<LazyGithubCalendar username="testuser" />)

    expect(mockIntersectionObserver).toHaveBeenCalledWith(
      expect.any(Function),
      expect.objectContaining({
        rootMargin: '100px',
        threshold: 0.1,
      }),
    )
  })

  it('renders GitHub calendar when visible', async () => {
    let intersectionCallback: ((entries: any[]) => void) | undefined

    mockIntersectionObserver.mockImplementation((callback) => {
      intersectionCallback = callback
      return {
        observe: vi.fn(),
        unobserve: vi.fn(),
        disconnect: vi.fn(),
      }
    })

    render(<LazyGithubCalendar username="testuser" />)

    // Simulate intersection
    intersectionCallback!([{ isIntersecting: true }])

    await waitFor(() => {
      expect(screen.getByTestId('github-calendar')).toBeInTheDocument()
    })

    expect(screen.getByText('GitHub Calendar for testuser')).toBeInTheDocument()
  })

  it('applies correct theme to GitHub calendar', async () => {
    let intersectionCallback: ((entries: any[]) => void) | undefined

    mockIntersectionObserver.mockImplementation((callback) => {
      intersectionCallback = callback
      return {
        observe: vi.fn(),
        unobserve: vi.fn(),
        disconnect: vi.fn(),
      }
    })

    render(<LazyGithubCalendar username="testuser" />)

    // Simulate intersection
    intersectionCallback!([{ isIntersecting: true }])

    await waitFor(() => {
      const calendar = screen.getByTestId('github-calendar')
      const themeData = JSON.parse(calendar.getAttribute('data-theme') || '{}')

      expect(themeData).toEqual({
        light: ['var(--theme-background)', 'var(--theme-accent)'],
        dark: ['var(--theme-background)', 'var(--theme-accent)'],
      })
    })
  })

  it('disconnects observer when component unmounts', () => {
    const mockDisconnect = vi.fn()

    mockIntersectionObserver.mockReturnValue({
      observe: vi.fn(),
      unobserve: vi.fn(),
      disconnect: mockDisconnect,
    })

    const { unmount } = render(<LazyGithubCalendar username="testuser" />)

    unmount()

    expect(mockDisconnect).toHaveBeenCalled()
  })
})
