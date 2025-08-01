import React, { Component } from 'react'
import type { ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    // Update state so the next render will show the fallback UI
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Log error to console in development
    console.error('ErrorBoundary caught an error:', error, errorInfo)

    // In production, you might want to log this to an error reporting service
    // Example: logErrorToService(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      // Render custom fallback UI or use provided fallback
      return (
        this.props.fallback || (
          <div className="error-boundary p-4 border border-red-300 rounded-md bg-red-50 text-red-800">
            <h3 className="font-semibold mb-2">Something went wrong</h3>
            <p className="text-sm">
              This component encountered an error and couldn't be displayed.
            </p>
            {process.env.NODE_ENV === 'development' && this.state.error && (
              <details className="mt-2">
                <summary className="cursor-pointer text-xs">
                  Error details (dev only)
                </summary>
                <pre className="mt-1 text-xs overflow-auto">
                  {this.state.error.toString()}
                </pre>
              </details>
            )}
          </div>
        )
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary
