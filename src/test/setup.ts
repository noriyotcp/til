import '@testing-library/jest-dom'
import { vi } from 'vitest'

// Mock environment variables
vi.stubGlobal('import.meta', {
  env: {
    DEV: false,
    PROD: true,
    BASE_URL: '/',
  },
})

// Mock Astro components and utilities
vi.mock('astro:content', () => ({
  getCollection: vi.fn(),
  getEntry: vi.fn(),
}))

vi.mock('astro-icon/components', () => ({
  Icon: ({ name, class: className }: { name: string; class?: string }) =>
    `<svg class="${className}" data-icon="${name}"></svg>`,
}))

// Mock Pagefind
vi.mock('@pagefind/default-ui', () => ({
  PagefindUI: vi.fn().mockImplementation(() => ({
    init: vi.fn(),
  })),
}))

// Setup DOM globals
global.requestIdleCallback = global.requestIdleCallback || ((cb) => setTimeout(cb, 1))
global.cancelIdleCallback = global.cancelIdleCallback || ((id) => clearTimeout(id))

// Mock window.location
Object.defineProperty(window, 'location', {
  value: {
    href: 'http://localhost:3000/',
    pathname: '/',
    search: '',
    hash: '',
  },
  writable: true,
})
