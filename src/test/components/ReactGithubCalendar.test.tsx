import { render, screen } from '@testing-library/react'
import { describe, it, expect, vi } from 'vitest'
import ReactGithubCalendar from '../../components/ReactGithubCalendar'

// Mock the react-github-calendar component
vi.mock('react-github-calendar', () => ({
  default: ({ username, theme }: { username: string; theme: any }) => (
    <div data-testid="github-calendar" data-username={username} data-theme={JSON.stringify(theme)}>
      GitHub Calendar for {username}
    </div>
  ),
}))

describe('ReactGithubCalendar', () => {
  it('renders GitHub calendar with correct username', () => {
    const username = 'testuser'

    render(<ReactGithubCalendar username={username} />)

    const calendar = screen.getByTestId('github-calendar')
    expect(calendar).toBeInTheDocument()
    expect(calendar).toHaveAttribute('data-username', username)
    expect(screen.getByText(`GitHub Calendar for ${username}`)).toBeInTheDocument()
  })

  it('applies correct theme configuration', () => {
    const username = 'testuser'

    render(<ReactGithubCalendar username={username} />)

    const calendar = screen.getByTestId('github-calendar')
    const themeData = JSON.parse(calendar.getAttribute('data-theme') || '{}')

    expect(themeData).toEqual({
      light: ["var(--theme-background)", "var(--theme-accent)"],
      dark: ["var(--theme-background)", "var(--theme-accent)"]
    })
  })

  it('has correct CSS classes applied', () => {
    const username = 'testuser'

    render(<ReactGithubCalendar username={username} />)

    const container = screen.getByTestId('github-calendar').parentElement
    expect(container).toHaveClass('github-calendar', 'my-6')
  })
})
