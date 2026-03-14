import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import {
  createHotkeyMockDOM,
  createTagsPageMockDOM,
  createHotkeyManagerMock,
} from './hotkeys-mock'

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

    HotkeyManagerClass = createHotkeyManagerMock({
      mockDOM,
      enableKeySequences: true,
      enableHelp: true,
      enableEscape: true,
      enableIsIndividualPostPage: true,
      enableAstroPageLoad: true,
    })
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

  it('resets focus index after back to top (b t)', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Navigate to second post
    hotkeyManager.testNavigateToNextPost()
    hotkeyManager.testNavigateToNextPost()
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(1)

    // Press b t to scroll to top
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

    // Focus index should be reset
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(-1)
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

  it('scrolls focused post into view', () => {
    const hotkeyManager = new HotkeyManagerClass()

    hotkeyManager.testNavigateToNextPost()

    const focusedPost = hotkeyManager.getPostElements()[0]
    expect(focusedPost.scrollIntoView).toHaveBeenCalledWith({
      behavior: 'smooth',
      block: 'center',
    })
  })

  it('focuses title link when navigating with j/k', () => {
    const hotkeyManager = new HotkeyManagerClass()

    hotkeyManager.testNavigateToNextPost()

    const titleLink = mockDOM.mockElements.titleLinks[0]
    expect(titleLink.focus).toHaveBeenCalledWith({ preventScroll: true })
  })

  it('syncs focus index when Tab moves focus to a different article before j/k', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // j to navigate to first article (index=0)
    hotkeyManager.testNavigateToNextPost()
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)

    // Simulate Tab moving focus into the second article (index=1)
    mockDOM.mockDocument.activeElement = mockDOM.mockElements.titleLinks[1]

    // Press k - should sync to index=1 first, then decrement to index=0
    const kEvent = {
      key: 'k',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }
    hotkeyManager.testHandleKeyDown(kEvent as any)

    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)
    expect(mockDOM.mockElements.titleLinks[0].focus).toHaveBeenCalled()
  })

  it('syncs focus index when Tab moves focus forward before pressing j', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // j to navigate to first article (index=0)
    hotkeyManager.testNavigateToNextPost()
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)

    // Simulate Tab moving focus into the second article
    mockDOM.mockDocument.activeElement = mockDOM.mockElements.titleLinks[1]

    // Press j - should sync to index=1 first, then stay at index=1 (max)
    const jEvent = {
      key: 'j',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }
    hotkeyManager.testHandleKeyDown(jEvent as any)

    // Only 2 articles, so index stays at 1
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(1)
  })

  it('does NOT preventDefault on Enter when activeElement is outside the focused article', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Focus on first post with j
    hotkeyManager.testNavigateToNextPost()
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)

    // Simulate Tab moving focus to an external element (e.g., Archive button)
    const externalButton = { tagName: 'A', href: '/archive' }
    mockDOM.mockDocument.activeElement = externalButton

    const mockEvent = {
      key: 'Enter',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(mockEvent as any)

    // Should NOT preventDefault — browser default behavior (Archive link) should work
    expect(mockEvent.preventDefault).not.toHaveBeenCalled()
  })

  it('still opens focused post with Enter when activeElement is inside the article', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Focus on first post with j
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

  it('does NOT preventDefault on Enter when activeElement is a tag link inside the article', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Focus on first post with j
    hotkeyManager.testNavigateToNextPost()
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)

    // Simulate Tab moving focus to a tag link inside the same article
    const tagLink = { tagName: 'A', href: '/tags/Books' }
    mockDOM.mockDocument.activeElement = tagLink

    const mockEvent = {
      key: 'Enter',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(mockEvent as any)

    // Should NOT preventDefault — browser should follow the tag link
    expect(mockEvent.preventDefault).not.toHaveBeenCalled()
  })

  it('still opens focused post with Enter when activeElement is body', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Focus on first post with j
    hotkeyManager.testNavigateToNextPost()

    // Simulate activeElement being body (e.g., user clicked somewhere neutral)
    mockDOM.mockDocument.activeElement = mockDOM.mockDocument.body

    const mockEvent = {
      key: 'Enter',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(mockEvent as any)

    expect(mockEvent.preventDefault).toHaveBeenCalled()
    expect(mockDOM.mockWindow.location.href).toBe('/post/1')
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

describe('Tags list page j/k navigation', () => {
  let mockDOM: ReturnType<typeof createTagsPageMockDOM>
  let HotkeyManagerClass: any

  beforeEach(() => {
    mockDOM = createTagsPageMockDOM()
    global.document = mockDOM.mockDocument as any
    global.window = mockDOM.mockWindow as any

    HotkeyManagerClass = createHotkeyManagerMock({
      mockDOM,
      enableTagHeadings: true,
    })
  })

  afterEach(() => {
    vi.clearAllMocks()
    vi.unstubAllGlobals()
  })

  it('collects tag headings and post items in order', () => {
    const hotkeyManager = new HotkeyManagerClass()
    const elements = hotkeyManager.getPostElements()

    // Should be: tagHeading1, postItem1, postItem2, morePostsItem1, tagHeading2, postItem3
    expect(elements.length).toBe(6)
    expect(elements[0]).toBe(mockDOM.elements.tagHeading1)
    expect(elements[1]).toBe(mockDOM.elements.postItem1)
    expect(elements[2]).toBe(mockDOM.elements.postItem2)
    expect(elements[3]).toBe(mockDOM.elements.morePostsItem1)
    expect(elements[4]).toBe(mockDOM.elements.tagHeading2)
    expect(elements[5]).toBe(mockDOM.elements.postItem3)
  })

  it('navigates through tag headings and posts with j/k', () => {
    const hotkeyManager = new HotkeyManagerClass()
    const jEvent = {
      key: 'j',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    // j -> tag heading 1 (#Books)
    hotkeyManager.testHandleKeyDown(jEvent as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)
    expect(mockDOM.tagLinks[0].focus).toHaveBeenCalled()

    // j -> post 1
    hotkeyManager.testHandleKeyDown(jEvent as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(1)
    expect(mockDOM.postLinks[0].focus).toHaveBeenCalled()

    // j -> post 2
    hotkeyManager.testHandleKeyDown(jEvent as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(2)
    expect(mockDOM.postLinks[1].focus).toHaveBeenCalled()

    // j -> "...and N more posts" link
    hotkeyManager.testHandleKeyDown(jEvent as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(3)
    expect(mockDOM.moreLinks[0].focus).toHaveBeenCalled()

    // j -> tag heading 2 (#Coding)
    hotkeyManager.testHandleKeyDown(jEvent as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(4)
    expect(mockDOM.tagLinks[1].focus).toHaveBeenCalled()

    // j -> post 3
    hotkeyManager.testHandleKeyDown(jEvent as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(5)
    expect(mockDOM.postLinks[2].focus).toHaveBeenCalled()
  })

  it('opens tag page with Enter when tag heading is focused', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Navigate to first tag heading
    hotkeyManager.testNavigateToNextPost()
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)

    const enterEvent = {
      key: 'Enter',
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    hotkeyManager.testHandleKeyDown(enterEvent as any)

    expect(enterEvent.preventDefault).toHaveBeenCalled()
    expect(mockDOM.mockWindow.location.href).toBe('/tags/Books')
  })

  it('navigates between tag headings with Shift+J', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // Shift+J -> first tag heading (index=0, tagHeading1)
    const shiftJEvent1 = {
      key: 'J',
      shiftKey: true,
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }
    hotkeyManager.testHandleKeyDown(shiftJEvent1 as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)
    expect(mockDOM.tagLinks[0].focus).toHaveBeenCalled()

    // Shift+J -> second tag heading (index=4, tagHeading2), skipping posts and more link
    const shiftJEvent2 = {
      key: 'J',
      shiftKey: true,
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }
    hotkeyManager.testHandleKeyDown(shiftJEvent2 as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(4)
    expect(mockDOM.tagLinks[1].focus).toHaveBeenCalled()
  })

  it('navigates between tag headings with Shift+K', () => {
    const hotkeyManager = new HotkeyManagerClass()

    // First go to second tag heading with two Shift+J
    const shiftJ = {
      key: 'J',
      shiftKey: true,
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }
    hotkeyManager.testHandleKeyDown(shiftJ as any)
    hotkeyManager.testHandleKeyDown(shiftJ as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(4)

    // Shift+K -> back to first tag heading (index=0)
    const shiftKEvent = {
      key: 'K',
      shiftKey: true,
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }
    hotkeyManager.testHandleKeyDown(shiftKEvent as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(0)
    expect(mockDOM.tagLinks[0].focus).toHaveBeenCalled()
  })

  it('does not move past last tag heading with Shift+J', () => {
    const hotkeyManager = new HotkeyManagerClass()

    const shiftJ = {
      key: 'J',
      shiftKey: true,
      preventDefault: vi.fn(),
      target: { tagName: 'BODY' },
    }

    // Go to first tag heading
    hotkeyManager.testHandleKeyDown(shiftJ as any)
    // Go to second tag heading
    hotkeyManager.testHandleKeyDown(shiftJ as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(4)

    // Try again - should stay at second tag heading (no more H2s)
    hotkeyManager.testHandleKeyDown(shiftJ as any)
    expect(hotkeyManager.getCurrentFocusIndex()).toBe(4)
  })
})
