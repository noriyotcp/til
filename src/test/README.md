# Test Suite Documentation

This directory contains comprehensive tests for the Astro site's core functionality.

## Test Structure

### Components Tests (`/components/`)

- **Error Boundary Component**
  - Error handling and fallback UI rendering
  - Custom fallback support
  - Development mode error details
  - Console error logging

- **GitHub Calendar Component**
  - Username prop handling
  - Theme configuration
  - CSS class application

### Content Tests (`/content/`)

- **Content Collection Schemas**
  - Posts schema validation (title, date, tags, etc.)
  - Home schema validation (avatar, GitHub calendar)
  - Date field normalization
  - Default value application
  - Error handling for invalid data

### Integration Tests (`/integration/`)

- **Search Functionality**
  - Modal open/close behavior
  - Keyboard shortcuts (Ctrl/Cmd+K)
  - Click outside to close
  - Event listener management
  - Error handling for missing DOM elements

- **Hotkey Navigation System**
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

- ✅ Error boundary components with fallback UI
- ✅ GitHub calendar integration with theming
- ✅ Content collection schema validation
- ✅ Search modal functionality with keyboard shortcuts
- ✅ Hotkey navigation system for site navigation
- ✅ Post navigation and focus management
- ✅ DOM event handling and cleanup
- ✅ Error handling and graceful fallbacks

## Test Configuration

- **Framework**: Vitest
- **Environment**: jsdom
- **Testing Library**: @testing-library/react
- **Setup**: `src/test/setup.ts` contains global mocks and configuration

## Mocking Strategy

The tests use comprehensive mocking for:

- Astro-specific imports and components
- Pagefind search library
- DOM APIs and browser globals
- Environment variables and build-time constants

This ensures tests run reliably in the Node.js environment while accurately testing component behavior.
