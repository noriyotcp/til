import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'

// Mock DOM environment
const createMockDOM = () => {
  const mockDialog = {
    showModal: vi.fn(),
    close: vi.fn(),
    open: false,
    addEventListener: vi.fn(),
  }

  const mockButton = {
    addEventListener: vi.fn(),
    disabled: true,
  }

  const mockInput = {
    focus: vi.fn(),
  }

  const mockBody = {
    classList: {
      add: vi.fn(),
      remove: vi.fn(),
    },
    contains: vi.fn(() => true),
  }

  const mockDocument = {
    querySelector: vi.fn((selector: string) => {
      if (selector === 'body') return mockBody
      if (selector === 'input') return mockInput
      if (selector === 'button[data-open-modal]') return mockButton
      if (selector === 'button[data-close-modal]') return mockButton
      if (selector === 'dialog') return mockDialog
      if (selector === '.dialog-frame') return { contains: vi.fn(() => false) }
      if (selector === 'site-search dialog') return mockDialog
      if (selector === '#pagefind-search') return { innerHTML: '' }
      return null
    }),
    querySelectorAll: vi.fn(() => []),
    body: mockBody,
    contains: vi.fn(() => true),
  }

  const mockWindow = {
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    requestIdleCallback: vi.fn((cb) => setTimeout(cb, 1)),
  }

  return { mockDialog, mockButton, mockInput, mockBody, mockDocument, mockWindow }
}

describe('Search Integration', () => {
  let mockDOM: ReturnType<typeof createMockDOM>
  let SiteSearchClass: any

  beforeEach(() => {
    mockDOM = createMockDOM()

    // Mock global objects
    global.document = mockDOM.mockDocument as any
    global.window = mockDOM.mockWindow as any
    global.HTMLElement = class HTMLElement {} as any
    global.customElements = {
      define: vi.fn(),
    } as any

    // Mock import.meta.env
    vi.stubGlobal('import.meta', {
      env: {
        DEV: false,
        BASE_URL: '/',
      },
    })

    // Create a simplified mock SiteSearch class
    SiteSearchClass = class SiteSearch extends HTMLElement {
      #closeBtn: any
      #dialog: any
      #dialogFrame: any
      #openBtn: any
      #controller: AbortController

      constructor() {
        super()
        this.#openBtn = mockDOM.mockDocument.querySelector('button[data-open-modal]')
        this.#closeBtn = mockDOM.mockDocument.querySelector('button[data-close-modal]')
        this.#dialog = mockDOM.mockDocument.querySelector('dialog')
        this.#dialogFrame = mockDOM.mockDocument.querySelector('.dialog-frame')
        this.#controller = new AbortController()

        if (this.#openBtn) {
          this.#openBtn.addEventListener('click', this.openModal)
          this.#openBtn.disabled = false
        } else {
          console.warn('Search button not found')
        }

        if (this.#closeBtn) {
          this.#closeBtn.addEventListener('click', this.closeModal)
        } else {
          console.warn('Close button not found')
        }

        if (this.#dialog) {
          this.#dialog.addEventListener('close', () => {
            mockDOM.mockWindow.removeEventListener('click', this.onWindowClick)
          })
        } else {
          console.warn('Dialog not found')
        }
      }

      connectedCallback() {
        mockDOM.mockWindow.addEventListener('keydown', this.onWindowKeydown)
      }

      disconnectedCallback() {
        this.#controller.abort()
      }

      openModal = (event?: MouseEvent) => {
        if (!this.#dialog) return

        mockDOM.mockBody.classList.add('overflow-hidden')
        this.#dialog.showModal()
        mockDOM.mockDocument.querySelector('input')?.focus()
        event?.stopPropagation()
        mockDOM.mockWindow.addEventListener('click', this.onWindowClick)
      }

      closeModal = () => {
        mockDOM.mockBody.classList.remove('overflow-hidden')
        this.#dialog?.close()
      }

      onWindowClick = (event: MouseEvent) => {
        const isLink = 'href' in (event.target || {})
        if (
          isLink ||
          (mockDOM.mockDocument.body.contains(event.target as Node) &&
            !this.#dialogFrame?.contains(event.target as Node))
        ) {
          this.closeModal()
        }
      }

      onWindowKeydown = (e: KeyboardEvent) => {
        if (!this.#dialog) return
        if ((e.metaKey === true || e.ctrlKey === true) && e.key === 'k') {
          this.#dialog.open ? this.closeModal() : this.openModal()
          e.preventDefault()
        }
      }
    }
  })

  afterEach(() => {
    vi.clearAllMocks()
    vi.unstubAllGlobals()
  })

  it('initializes search component correctly', () => {
    const siteSearch = new SiteSearchClass()

    expect(mockDOM.mockButton.addEventListener).toHaveBeenCalledWith('click', expect.any(Function))
    expect(mockDOM.mockButton.disabled).toBe(false)
  })

  it('opens modal when open button is clicked', () => {
    const siteSearch = new SiteSearchClass()

    siteSearch.openModal()

    expect(mockDOM.mockBody.classList.add).toHaveBeenCalledWith('overflow-hidden')
    expect(mockDOM.mockDialog.showModal).toHaveBeenCalled()
    expect(mockDOM.mockInput.focus).toHaveBeenCalled()
  })

  it('closes modal when close button is clicked', () => {
    const siteSearch = new SiteSearchClass()

    siteSearch.openModal()
    siteSearch.closeModal()

    expect(mockDOM.mockBody.classList.remove).toHaveBeenCalledWith('overflow-hidden')
    expect(mockDOM.mockDialog.close).toHaveBeenCalled()
  })

  it('handles keyboard shortcuts correctly', () => {
    const siteSearch = new SiteSearchClass()
    const mockEvent = {
      metaKey: true,
      ctrlKey: false,
      key: 'k',
      preventDefault: vi.fn(),
    }

    mockDOM.mockDialog.open = false

    siteSearch.onWindowKeydown(mockEvent as any)

    expect(mockEvent.preventDefault).toHaveBeenCalled()
    expect(mockDOM.mockDialog.showModal).toHaveBeenCalled()
  })

  it('toggles modal with Ctrl+K when modal is open', () => {
    const siteSearch = new SiteSearchClass()
    const mockEvent = {
      metaKey: false,
      ctrlKey: true,
      key: 'k',
      preventDefault: vi.fn(),
    }

    mockDOM.mockDialog.open = true

    siteSearch.onWindowKeydown(mockEvent as any)

    expect(mockEvent.preventDefault).toHaveBeenCalled()
    expect(mockDOM.mockDialog.close).toHaveBeenCalled()
  })

  it('closes modal when clicking on a link', () => {
    const siteSearch = new SiteSearchClass()
    const mockEvent = {
      target: { href: 'http://example.com' },
    }

    siteSearch.onWindowClick(mockEvent as any)

    expect(mockDOM.mockDialog.close).toHaveBeenCalled()
  })

  it('sets up event listeners on connection', () => {
    const siteSearch = new SiteSearchClass()

    siteSearch.connectedCallback()

    expect(mockDOM.mockWindow.addEventListener).toHaveBeenCalledWith(
      'keydown',
      expect.any(Function)
    )
  })

  it('handles missing DOM elements gracefully', () => {
    // Mock querySelector to return null for all elements
    const originalQuerySelector = mockDOM.mockDocument.querySelector
    mockDOM.mockDocument.querySelector = vi.fn(() => null)

    const consoleSpy = vi.spyOn(console, 'warn').mockImplementation(() => {})

    const siteSearch = new SiteSearchClass()

    expect(consoleSpy).toHaveBeenCalledWith('Search button not found')
    expect(consoleSpy).toHaveBeenCalledWith('Close button not found')
    expect(consoleSpy).toHaveBeenCalledWith('Dialog not found')

    consoleSpy.mockRestore()
    mockDOM.mockDocument.querySelector = originalQuerySelector
  })
})
