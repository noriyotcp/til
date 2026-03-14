import { vi } from 'vitest'

// ===== Mock DOM Factories =====

export const createHotkeyMockDOM = () => {
  const titleLink1 = { href: '/post/1', focus: vi.fn() }
  const titleLink2 = { href: '/post/2', focus: vi.fn() }
  const titleLink3 = { href: '/post/3', focus: vi.fn() }

  const mockElements = {
    articles: [
      {
        style: {},
        setAttribute: vi.fn(),
        removeAttribute: vi.fn(),
        scrollIntoView: vi.fn(),
        contains: vi.fn((el: any) => el === titleLink1),
        querySelector: vi.fn((selector: string) => {
          if (selector === 'h1 a') return titleLink1
          if (selector === 'a') return titleLink1
          return null
        }),
      },
      {
        style: {},
        setAttribute: vi.fn(),
        removeAttribute: vi.fn(),
        scrollIntoView: vi.fn(),
        contains: vi.fn((el: any) => el === titleLink2),
        querySelector: vi.fn((selector: string) => {
          if (selector === 'h1 a') return titleLink2
          if (selector === 'a') return titleLink2
          return null
        }),
      },
    ],
    titleLinks: [titleLink1, titleLink2, titleLink3],
    postItems: [
      {
        style: {},
        setAttribute: vi.fn(),
        removeAttribute: vi.fn(),
        scrollIntoView: vi.fn(),
        contains: vi.fn((el: any) => el === titleLink3),
        querySelector: vi.fn((selector: string) => {
          if (selector === 'h1 a') return titleLink3
          if (selector === 'a') return titleLink3
          return null
        }),
      },
    ],
    prevLink: { getAttribute: vi.fn(() => '/page/1') },
    nextLink: { getAttribute: vi.fn(() => '/page/3') },
    searchDialog: { close: vi.fn(), open: false },
  }

  const mockBody = {
    appendChild: vi.fn(),
    removeChild: vi.fn(),
  }

  const mockDocument = {
    addEventListener: vi.fn(),
    activeElement: mockBody as any,
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
    body: mockBody,
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

export const createTagsPageMockDOM = () => {
  const tagLink1 = { href: '/tags/Books', focus: vi.fn() }
  const postLink1 = { href: '/post/1', focus: vi.fn() }
  const postLink2 = { href: '/post/2', focus: vi.fn() }
  const moreLink1 = { href: '/tags/Books', focus: vi.fn() }
  const tagLink2 = { href: '/tags/Coding', focus: vi.fn() }
  const postLink3 = { href: '/post/3', focus: vi.fn() }

  const tagHeading1 = {
    tagName: 'H2',
    scrollIntoView: vi.fn(),
    querySelector: vi.fn((selector: string) => {
      if (selector === 'h1 a') return null
      if (selector === 'a') return tagLink1
      return null
    }),
  }
  const postItem1 = {
    tagName: 'DIV',
    scrollIntoView: vi.fn(),
    querySelector: vi.fn((selector: string) => {
      if (selector === 'h1 a') return null
      if (selector === 'a') return postLink1
      return null
    }),
  }
  const postItem2 = {
    tagName: 'DIV',
    scrollIntoView: vi.fn(),
    querySelector: vi.fn((selector: string) => {
      if (selector === 'h1 a') return null
      if (selector === 'a') return postLink2
      return null
    }),
  }
  const morePostsItem1 = {
    tagName: 'DIV',
    scrollIntoView: vi.fn(),
    querySelector: vi.fn((selector: string) => {
      if (selector === 'h1 a') return null
      if (selector === 'a') return moreLink1
      return null
    }),
  }
  const tagHeading2 = {
    tagName: 'H2',
    scrollIntoView: vi.fn(),
    querySelector: vi.fn((selector: string) => {
      if (selector === 'h1 a') return null
      if (selector === 'a') return tagLink2
      return null
    }),
  }
  const postItem3 = {
    tagName: 'DIV',
    scrollIntoView: vi.fn(),
    querySelector: vi.fn((selector: string) => {
      if (selector === 'h1 a') return null
      if (selector === 'a') return postLink3
      return null
    }),
  }

  const tagPosts1 = {
    children: [postItem1, postItem2, morePostsItem1],
  }
  const tagPosts2 = {
    children: [postItem3],
  }
  const tagItem1 = {
    querySelector: vi.fn((selector: string) => {
      if (selector === 'h2') return tagHeading1
      if (selector === '.tag-posts') return tagPosts1
      return null
    }),
    querySelectorAll: vi.fn((selector: string) => {
      if (selector === '.post-item') return [postItem1, postItem2]
      return []
    }),
  }
  const tagItem2 = {
    querySelector: vi.fn((selector: string) => {
      if (selector === 'h2') return tagHeading2
      if (selector === '.tag-posts') return tagPosts2
      return null
    }),
    querySelectorAll: vi.fn((selector: string) => {
      if (selector === '.post-item') return [postItem3]
      return []
    }),
  }

  const mockBody = {
    appendChild: vi.fn(),
    removeChild: vi.fn(),
  }

  const mockDocument = {
    addEventListener: vi.fn(),
    activeElement: mockBody as any,
    querySelectorAll: vi.fn((selector: string) => {
      if (selector === 'article') return []
      if (selector === '.tag-item') return [tagItem1, tagItem2]
      if (selector === '.post-item') return [postItem1, postItem2, postItem3]
      return []
    }),
    querySelector: vi.fn((selector: string) => {
      if (selector === '#hotkey-help-modal') return null
      if (selector === 'site-search dialog') return null
      return null
    }),
    body: mockBody,
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
    location: { pathname: '/tags', href: 'http://localhost:3000/tags' },
    scrollTo: vi.fn(),
    requestAnimationFrame: vi.fn((cb: any) => cb()),
  }

  return {
    mockDocument,
    mockWindow,
    tagLinks: [tagLink1, tagLink2],
    postLinks: [postLink1, postLink2, postLink3],
    moreLinks: [moreLink1],
    elements: { tagHeading1, postItem1, postItem2, morePostsItem1, tagHeading2, postItem3 },
  }
}

// ===== HotkeyManager Mock Factory =====

export interface MockDOMInterface {
  mockDocument: any
  mockWindow: any
}

export interface HotkeyManagerMockOptions {
  mockDOM: MockDOMInterface
  enableKeySequences?: boolean
  enableHelp?: boolean
  enableEscape?: boolean
  enableTagHeadings?: boolean
  enableIsIndividualPostPage?: boolean
  enableAstroPageLoad?: boolean
}

export function createHotkeyManagerMock(options: HotkeyManagerMockOptions) {
  const {
    mockDOM,
    enableKeySequences = false,
    enableHelp = false,
    enableEscape = false,
    enableTagHeadings = false,
    enableIsIndividualPostPage = false,
    enableAstroPageLoad = false,
  } = options

  return class HotkeyManager {
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
      if (enableAstroPageLoad) {
        mockDOM.mockDocument.addEventListener('astro:page-load', () => {
          this.initPostNavigation()
        })
      }
    }

    private initPostNavigation() {
      if (enableIsIndividualPostPage) {
        const isIndividual = this.isIndividualPostPage()
        if (isIndividual) {
          this.postElements = []
          this.currentFocusIndex = -1
          return
        }
      }

      const articles = Array.from(mockDOM.mockDocument.querySelectorAll('article'))

      if (articles.length > 0) {
        this.postElements = articles
      } else {
        const tagItems = mockDOM.mockDocument.querySelectorAll('.tag-item')
        const elements: any[] = []
        tagItems.forEach((tagItem: any) => {
          const heading = tagItem.querySelector('h2')
          if (heading) elements.push(heading)
          const tagPosts = tagItem.querySelector('.tag-posts')
          if (tagPosts) {
            Array.from(tagPosts.children).forEach((child: any) => {
              elements.push(child)
            })
          }
        })
        this.postElements = elements.length > 0
          ? elements
          : Array.from(mockDOM.mockDocument.querySelectorAll('.post-item'))
      }
      this.currentFocusIndex = -1
      this.clearPostFocus()
    }

    private isIndividualPostPage(): boolean {
      if (!enableIsIndividualPostPage) return false

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

      if (enableKeySequences) {
        this.handleKeySequence(event)
      }
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
          if (!enableHelp || !event.shiftKey) return false
          event.preventDefault()
          this.showHelp()
          return true

        case 'Escape':
          if (!enableEscape) return false
          event.preventDefault()
          this.closeModals()
          this.clearPostFocus()
          this.currentFocusIndex = -1
          if (mockDOM.mockDocument.activeElement?.blur) {
            mockDOM.mockDocument.activeElement.blur()
          }
          return true

        case 'J':
          if (!enableTagHeadings || !this.hasTagHeadings()) return false
          event.preventDefault()
          this.navigateToNextTagHeading()
          return true

        case 'K':
          if (!enableTagHeadings || !this.hasTagHeadings()) return false
          event.preventDefault()
          this.navigateToPreviousTagHeading()
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
            const focusedArticle = this.postElements[this.currentFocusIndex]
            const titleLink =
              focusedArticle.querySelector('h1 a') ||
              focusedArticle.querySelector('a')
            if (
              mockDOM.mockDocument.activeElement === mockDOM.mockDocument.body ||
              mockDOM.mockDocument.activeElement === titleLink
            ) {
              event.preventDefault()
              this.openFocusedPost()
              return true
            }
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
      this.currentFocusIndex = -1
      if (mockDOM.mockDocument.activeElement?.blur) {
        mockDOM.mockDocument.activeElement.blur()
      }
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

    private hasTagHeadings(): boolean {
      return this.postElements.some((el: any) => el.tagName === 'H2')
    }

    private navigateToNextTagHeading() {
      this.syncFocusIndex()
      for (let i = this.currentFocusIndex + 1; i < this.postElements.length; i++) {
        if (this.postElements[i].tagName === 'H2') {
          this.currentFocusIndex = i
          this.updatePostFocus()
          return
        }
      }
    }

    private navigateToPreviousTagHeading() {
      this.syncFocusIndex()
      const start = this.currentFocusIndex < 0 ? this.postElements.length - 1 : this.currentFocusIndex - 1
      for (let i = start; i >= 0; i--) {
        if (this.postElements[i].tagName === 'H2') {
          this.currentFocusIndex = i
          this.updatePostFocus()
          return
        }
      }
    }

    private syncFocusIndex() {
      const active = mockDOM.mockDocument.activeElement
      if (!active || active === mockDOM.mockDocument.body) return

      for (let i = 0; i < this.postElements.length; i++) {
        if (this.postElements[i].contains?.(active)) {
          this.currentFocusIndex = i
          return
        }
      }
    }

    private navigateToNextPost() {
      if (this.postElements.length === 0) return
      this.syncFocusIndex()
      this.currentFocusIndex = Math.min(this.currentFocusIndex + 1, this.postElements.length - 1)
      this.updatePostFocus()
    }

    private navigateToPreviousPost() {
      if (this.postElements.length === 0) return
      this.syncFocusIndex()
      this.currentFocusIndex = Math.max(this.currentFocusIndex - 1, 0)
      this.updatePostFocus()
    }

    private updatePostFocus() {
      this.clearPostFocus()

      if (this.currentFocusIndex >= 0 && this.currentFocusIndex < this.postElements.length) {
        const focusedPost = this.postElements[this.currentFocusIndex]

        const titleLink = focusedPost.querySelector('h1 a') || focusedPost.querySelector('a')
        if (titleLink) {
          titleLink.focus({ preventScroll: true })
          mockDOM.mockDocument.activeElement = titleLink
        }

        focusedPost.scrollIntoView({
          behavior: 'smooth',
          block: 'center',
        })
      }
    }

    private clearPostFocus() {
      // No visual styles to clear; browser focus on title link is the indicator
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
}
