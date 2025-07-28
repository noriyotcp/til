# Test Suite Documentation

This directory contains comprehensive tests for the Astro site's core functionality.

## Test Structure

### Components Tests (`/components/`)
- **ErrorBoundary.test.tsx**: Tests React error boundary component
  - Error handling and fallback UI rendering
  - Custom fallback support
  - Development mode error details
  - Console error logging

- **ReactGithubCalendar.test.tsx**: Tests GitHub calendar component
  - Username prop handling
  - Theme configuration
  - CSS class application

### Content Tests (`/content/`)
- **schema.test.ts**: Tests content collection schemas
  - Posts schema validation (title, date, tags, etc.)
  - Home schema validation (avatar, GitHub calendar)
  - Date field normalization
  - Default value application
  - Error handling for invalid data

### Integration Tests (`/integration/`)
- **search.test.ts**: Tests search functionality
  - Modal open/close behavior
  - Keyboard shortcuts (Ctrl/Cmd+K)
  - Click outside to close
  - Event listener management
  - Error handling for missing DOM elements

- **hotkeys.test.ts**: Tests hotkey navigation system
  - Navigation shortcuts (g h, g t, g a, etc.)
  - Post navigation (j/k keys)
  - Page detection (individual vs listing)
  - Focus management and styling
  - Pagination shortcuts
  - Help modal display

## Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with UI
npm run test:ui
```

## Test Coverage

The test suite covers:
- ✅ React component error boundaries
- ✅ GitHub calendar integration
- ✅ Content collection schema validation
- ✅ Search modal functionality
- ✅ Hotkey navigation system
- ✅ Keyboard shortcuts
- ✅ DOM event handling
- ✅ Error handling and fallbacks

## Test Configuration

- **Framework**: Vitest
- **Environment**: jsdom
- **Testing Library**: @testing-library/react
- **Setup**: `src/test/setup.ts` contains global mocks and configuration

## Mocking Strategy

The tests use comprehensive mocking for:
- Astro-specific imports (`astro:content`, `astro-icon/components`)
- Pagefind search library
- DOM APIs and browser globals
- Import.meta.env environment variables

This ensures tests run reliably in the Node.js environment while accurately testing component behavior.
