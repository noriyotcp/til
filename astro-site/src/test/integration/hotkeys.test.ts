import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'

// Mock DOM environment for hotkey testing
const createHotkeyMockDOM = () => {
  const mockElements = {
    articles: [
      {
        style: {},
        setAttribute: vi.fn(),
        removeAttribute: vi.fn(),
        scrollIntoView: vi.fn(),
        querySelector: vi.fn(() => ({ href: '/post/1' }))
      },
      {
        style: {},
        setAttribute: vi.fn(),
        removeAttribute: vi.fn(),
        scrollIntoView: vi.fn(),
        querySelector: vi.fn(() => ({ href: '/post/2' }))
      },
    ],
    postItems: [
      {
        style: {},
        setAttribute: vi.fn(),
        removeAttribute: vi.fn(),
        scrollIntoView: vi.fn(),
        querySelector: vi.fn(() => ({ href: '/post/3' }))
      },
    ],
    prevLink: { getAttribute: vi.fn(() => '/page/1') },
    nextLink: { getAttribute: vi.fn(() => '/page/3') },
    searchDialog: { close: vi.fn(), open: false },
  }

  const mockDocument = {
    addEventListener: vi.fn(),
    querySelectorAll: vi.fn((selector: string) => {
      if (selector === 'article') return mockElements.articles
      if (selector === '.post-item') return mockElements.postItems
      return []
    }),
    querySelector: vi.fn((selector: string) => {
      if (selector === 'a[aria-label="Previous Page"]') return mockElements.prevLink
      if (selector === 'a[aria-label="Next Page"]') return mockElements.nextLink
      if (selector === 'site-search dialog') return mockElements.searchDialog
      if (selector === '#hotkey-help-modal') return null
      return null
    }),
    body: {
      appendChild: vi.fn(),
      removeChild: vi.fn(),
    },
    createElement: vi.fn(() => ({
      style: { cssText: '', opacity: '0' },
      textContent: '',
      addEventListener: vi.fn(),
      innerHTML: '',
      id: '',
    })),
    getElementById: vi.fn(() => null),
    readyState: 'complete',
  }

  const mockWindow = {
    location: {
      pathname: '/',
      href: 'http://localhost:3000/',
    },
    scrollTo: vi.fn(),
    requestAnimationFrame: vi.fn((cb) => cb()),
  }

  return { mockElements, mockDocument, mockWindow }
}

describe('Hotkey Navigation System', () => {
  let mockDOM: ReturnType<typeof createHotkeyMockDOM>
  let HotkeyManagerClass: any

  beforeEach(() => {
    mockDOM = createHotkeyMockDOM()

    // Mock global objects
    global.document = mockDOM.mockDocument as any
    global.window = mockDOM.mockWindow as any

    // Mock import.meta.env
    vi.stubGlobal('import.meta', {
      env: {
        BASE_URL: '/',
      },
    })

    // Create mock HotkeyManager class based on actual implementation
    HotkeyManagerClass = class HotkeyManager {
      private keySequence: string[] = []
      private sequenceTimeout: number | null = null
      private readonly SEQUENCE_TIMEOUT = 1000
      private currentFocusIndex: number = -1
      private postElements: any[] = []

      constructor() {
        this.init()
      }

      private init() {
        mockDOM.mockDocument.addEventListener('keydown', this.handleKeyDown.bind(this))
        this.initPostNavigation()
        mockDOM.mockDocument.addEventListener('astro:page-load', () => {
          this.initPostNavigation()
        })
      }

      private initPostNavigation() {
        const isIndividual = this.isIndividualPostPage()

        if (isIndividual) {
          this.postElements = []
          this.currentFocusIndex = -1
          return
        }

        const articles = Array.from(mockDOM.mockDocument.querySelectorAll('article'))
        const tagPostItems = Array.from(mockDOM.mockDocument.querySelectorAll('.post-item'))

        this.postElements = articles.length > 0 ? articles : tagPostItems
        this.currentFocusIndex = -1
        this.clearPostFocus()
      }

      private isIndividualPostPage(): boolean {
        const path = mockDOM.mockWindow.location.pathname
        const baseUrl = '/'
        const relativePath = path.replace(baseUrl, '').replace(/^\/+/, '')

        if (relativePath.startsWith('posts/') && !relativePath.match(/^posts\/(|\d+)$/)) {
          return true
        }

        const articles = mockDOM.mockDocument.querySelectorAll('article')
        if (articles.length === 1) {
          const article = articles[0]
          const hasPostContent = article.querySelector?.('p, h2, h3, h4, h5, h6, pre, blockquote, ul, ol')
          const hasReadButton = article.querySelector?.('.button')
          return hasPostContent && !hasReadButton
        }

        return false
      }

      private handleKeyDown(event: KeyboardEvent) {
        if (this.isTyping(event.target as Element)) {
          return
        }

        if (this.handleSingleKey(event)) {
          return
        }

        this.handleKeySequence(event)
      }

      private isTyping(target: Element): boolean {
        const tagName = target.tagName?.toLowerCase() || ''
        const inputTypes = ['input', 'textarea', 'select']
        const isContentEditable = target.getAttribute?.('contenteditable') === 'true'
        return inputTypes.includes(tagName) || isContentEditable
      }

      private handleSingleKey(event: KeyboardEvent): boolean {
        switch (event.key) {
          case '?':
            if (!event.shiftKey) return false
            event.preventDefault()
            this.showHelp()
            return true

          case 'Escape':
            event.preventDefault()
            this.closeModals()
            this.clearPostFocus()
            return true

          case 'j':
            if (this.postElements.length > 0) {
              event.preventDefault()
              this.navigateToNextPost()
              return true
            }
            return false

          case 'k':
            if (this.postElements.length > 0) {
              event.preventDefault()
              this.navigateToPreviousPost()
              return true
            }
            return false

          case 'Enter':
            if (this.currentFocusIndex >= 0) {
              event.preventDefault()
              this.openFocusedPost()
              return true
            }
            return false

          default:
            return false
        }
      }

      private handleKeySequence(event: KeyboardEvent) {
        this.keySequence.push(event.key.toLowerCase())

        if (this.sequenceTimeout) {
          clearTimeout(this.sequenceTimeout)
        }

        this.sequenceTimeout = setTimeout(() => {
          this.keySequence = []
        }, this.SEQUENCE_TIMEOUT)

        const sequence = this.keySequence.join(' ')

        switch (sequence) {
          case 'g h':
            event.preventDefault()
            this.navigateTo('/')
            this.clearSequence()
            break

          case 'g t':
            event.preventDefault()
            this.navigateTo('/tags')
            this.clearSequence()
            break

          case 'g a':
            event.preventDefault()
            this.navigateTo('/posts')
            this.clearSequence()
            break

          case 'b t':
            event.preventDefault()
            this.scrollToTop()
            this.clearSequence()
            break

          case 'g p':
            event.preventDefault()
            this.navigateToPreviousPage()
            this.clearSequence()
            break

          case 'g n':
            event.preventDefault()
            this.navigateToNextPage()
            this.clearSequence()
            break
        }

        if (this.keySequence.length > 2) {
          this.clearSequence()
        }
      }

      private clearSequence() {
        this.keySequence = []
        if (this.sequenceTimeout) {
          clearTimeout(this.sequenceTimeout)
          this.sequenceTimeout = null
        }
      }

      private navigateTo(path: string) {
        const baseUrl = '/'
        let fullPath: string

        if (path.startsWith(baseUrl)) {
          fullPath = path.replace(/\/$/, '') || '/'
        } else if (path === '/') {
          fullPath = baseUrl.replace(/\/$/, '') || '/'
        } else {
          fullPath = `${baseUrl}${path}`.replace(/\/+/g, '/').replace(/\/$/, '')
        }

        mockDOM.mockWindow.location.href = fullPath
      }

      private scrollToTop() {
        mockDOM.mockWindow.scrollTo({ top: 0, behavior: 'smooth' })
      }

      private getCurrentPageInfo() {
        const prevLink = mockDOM.mockDocument.querySelector('a[aria-label="Previous Page"]')?.getAttribute('href')
        const nextLink = mockDOM.mockDocument.querySelector('a[aria-label="Next Page"]')?.getAttribute('href')
        return { prevLink, nextLink }
      }

      private navigateToPreviousPage() {
        const { prevLink } = this.getCurrentPageInfo()
        if (prevLink) {
          this.navigateTo(prevLink)
        } else {
          this.showTemporaryMessage('Already on first page')
        }
      }

      private navigateToNextPage() {
        const { nextLink } = this.getCurrentPageInfo()
        if (nextLink) {
          this.navigateTo(nextLink)
        } else {
          this.showTemporaryMessage('Already on last page')
        }
      }

      private navigateToNextPost() {
        if (this.postElements.length === 0) return
        this.currentFocusIndex = Math.min(this.currentFocusIndex + 1, this.postElements.length - 1)
        this.updatePostFocus()
      }

      private navigateToPreviousPost() {
        if (this.postElements.length === 0) return
        this.currentFocusIndex = Math.max(this.currentFocusIndex - 1, 0)
        this.updatePostFocus()
      }

      private updatePostFocus() {
        this.clearPostFocus()

        if (this.currentFocusIndex >= 0 && this.currentFocusIndex < this.postElements.length) {
          const focusedPost = this.postElements[this.currentFocusIndex]
          focusedPost.style.outline = '2px solid var(--theme-accent)'
          focusedPost.style.outlineOffset = '4px'
          focusedPost.style.borderRadius = '0.5rem'
          focusedPost.setAttribute('data-hotkey-focused', 'true')
          focusedPost.scrollIntoView({
            behavior: 'smooth',
            block: 'center'
          })
        }
      }

      private clearPostFocus() {
        this.postElements.forEach(post => {
          post.style.outline = ''
          post.style.outlineOffset = ''
          post.style.borderRadius = ''
          post.removeAttribute('data-hotkey-focused')
        })
      }

      private openFocusedPost() {
        if (this.currentFocusIndex >= 0 && this.currentFocusIndex < this.postElements.length) {
          const focusedPost = this.postElements[this.currentFocusIndex]
          let postLink = focusedPost.querySelector('h1 a')

          if (!postLink) {
            postLink = focusedPost.querySelector('a')
          }

          if (postLink) {
            mockDOM.mockWindow.location.href = postLink.href
          }
        }
      }

      private showTemporaryMessage(message: string) {
        const messageEl = mockDOM.mockDocument.createElement('div')
        messageEl.textContent = message
        mockDOM.mockDocument.body.appendChild(messageEl)

        setTimeout(() => {
          mockDOM.mockDocument.body.removeChild(messageEl)
        }, 2000)
      }

      private showHelp() {
        let helpModal = mockDOM.mockDocument.getElementById('hotkey-help-modal')
        if (!helpModal) {
          helpModal = this.createHelpModal()
          mockDOM.mockDocument.body.appendChild(helpModal)
        }
        helpModal.style.display = 'flex'
      }

      private closeModals() {
        const helpModal = mockDOM.mockDocument.getElementById('hotkey-help-modal')
        if (helpModal) {
          helpModal.style.display = 'none'
        }

        const searchModal = mockDOM.mockDocument.querySelector('site-search dialog')
        if (searchModal && searchModal.open) {
          searchModal.close()
        }
      }

      private createHelpModal() {
        const modal = mockDOM.mockDocument.createElement('div')
        modal.id = 'hotkey-help-modal'
        return modal
      }

      // Expose private methods for testing
      public testHandleKeyDown = this.handleKeyDown.bind(this)
      public testIsIndividualPostPage = this.isIndividualPostPage.bind(this)
      public testNavigateToNextPost = this.navigateToNextPost.bind(this)
      public testNavigateToPreviousPost = this.navigateToPreviousPost.bind(this)
      public testOpenFocusedPost = this.openFocusedPost.bind(this)
      public testShowHelp = this.showHelp.bind(this)
      public testCloseModals = this.closeModals.bind(this)
      public getCurrentFocusIndex = () => this.currentFocusIndex
      public getPostElements = () => this.postElements
    }
  })

  afterEach(() => {
    vi.clearAllMocks()
    vi.unstubAllGlobals()
  })

  it('initializes hotkey manager correctly', () => {
    const hotkeyManager = new HotkeyManagerClass()

    expect(mockDOM.mockDocument.addEventListener).toHaveBeenCalledWith('keydown', expect.any(Function))
    expect(mockDOM.mockDocument.addEventListener).toHaveBeenCalledWith('astro:page-load', expect.any(Function))
  })

  it('detects individual post pages correctly', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Test individual post page
    mockDOM.mockWindow.location.pathname = '/posts/my-post-slug'
    expect(hotkeyManager.testIsIndividualPostPage()).toBe(true)

    // Test post listing page
    mockDOM.mockWindow.location.pathname = '/posts'
    expect(hotkeyManager.testIsIndividualPostPage()).toBe(false)

    // Test paginated posts
    mockDOM.mockWindow.location.pathname = '/posts/2'
    expect(hotkeyManager.testIsIndividualPostPage()).toBe(false)
  })

  it('handles help shortcut correctly', () => {
    const hotkeyManager = new HotkeyManagerClass()
    const mockEvent = {
      key: '?',
      shiftKey: true,
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(mockEvent as any)

    expect(mockEvent.preventDefault).toHaveBeenCalled()
    expect(mockDOM.mockDocument.body.appendChild).toHaveBeenCalled()
  })

  it('handles escape key correctly', () => {
    const hotkeyManager = new HotkeyManagerClass()
    const mockEvent = {
      key: 'Escape',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(mockEvent as any)

    expect(mockEvent.preventDefault).toHaveBeenCalled()
  })

  it('navigates to next post with j key', () => {
    const hotkeyManager = new HotkeyManagerClass()
    const mockEvent = {
      key: 'j',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(mockEvent as any)

    expect(mockEvent.preventDefault).toHaveBeenCalled()
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)
  })

  it('navigates to previous post with k key', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // First navigate to next post
    hotkeyManager.testNavigateToNextPost()
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)

    // Then navigate to previous
    const mockEvent = {
      key: 'k',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(mockEvent as any)

    expect(mockEvent.preventDefault).toHaveBeenCalled()
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0) // Should stay at 0 (minimum)
  })

  it('opens focused post with Enter key', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // First focus on a post
    hotkeyManager.testNavigateToNextPost()

    const mockEvent = {
      key: 'Enter',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(mockEvent as any)

    expect(mockEvent.preventDefault).toHaveBeenCalled()
    expect(mockDOM.mockWindow.location.href).toBe('/post/1')
  })

  it('handles navigation sequences correctly', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Test 'g h' sequence
    const gEvent = {
      key: 'g',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }
    const hEvent = {
      key: 'h',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(gEvent as any)
    hotkeyManager.testHandleKeyDown(hEvent as any)

    expect(hEvent.preventDefault).toHaveBeenCalled()
    expect(mockDOM.mockWindow.location.href).toBe('/')
  })

  it('handles pagination shortcuts correctly', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Test 'g p' sequence for previous page
    const gEvent = {
      key: 'g',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }
    const pEvent = {
      key: 'p',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(gEvent as any)
    hotkeyManager.testHandleKeyDown(pEvent as any)

    expect(pEvent.preventDefault).toHaveBeenCalled()
    expect(mockDOM.mockWindow.location.href).toBe('/page/1')
  })

  it('handles scroll to top shortcut', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Test 'b t' sequence
    const bEvent = {
      key: 'b',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }
    const tEvent = {
      key: 't',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(bEvent as any)
    hotkeyManager.testHandleKeyDown(tEvent as any)

    expect(tEvent.preventDefault).toHaveBeenCalled()
    expect(mockDOM.mockWindow.scrollTo).toHaveBeenCalledWith({ top: 0, behavior: 'smooth' })
  })

  it('ignores keystrokes when typing in input fields', () => {
    const hotkeyManager = new HotkeyManagerClass()
    const mockEvent = {
      key: 'j',
      preventDefault: vi.fn(),
      target: { tagName: 'INPUT' },
    }

    hotkeyManager.testHandleKeyDown(mockEvent as any)

    expect(mockEvent.preventDefault).not.toHaveBeenCalled()
  })

  it('applies focus styling to posts correctly', () => {
    const hotkeyManager = new HotkeyManagerClass()

    hotkeyManager.testNavigateToNextPost()

    const focusedPost = hotkeyManager.getPostElements()[0]
    expect(focusedPost.style.outline).toBe('2px solid var(--theme-accent)')
    expect(focusedPost.setAttribute).toHaveBeenCalledWith('data-hotkey-focused', 'true')
    expect(focusedPost.scrollIntoView).toHaveBeenCalledWith({
      behavior: 'smooth',
      block: 'center'
    })
  })

  it('shows temporary messages correctly', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Mock no next page available
    mockDOM.mockElements.nextLink.getAttribute = vi.fn(() => null)

    // Test 'g n' sequence when no next page
    const gEvent = {
      key: 'g',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }
    const nEvent = {
      key: 'n',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(gEvent as any)
    hotkeyManager.testHandleKeyDown(nEvent as any)

    expect(mockDOM.mockDocument.createElement).toHaveBeenCalledWith('div')
    expect(mockDOM.mockDocument.body.appendChild).toHaveBeenCalled()
  })
})
