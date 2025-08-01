import { setupFocusHotkeys } from "../setupFocusHotkeys";
import {
  moveFocusToPreviousItem,
  moveFocusToNextItem,
  focusedItemIndex,
  resetFocusedItemIndex,
} from "../focusNavigation";
import { vi, describe, beforeEach, afterEach, it, expect } from "vitest";

vi.mock("../focusNavigation", () => ({
  moveFocusToPreviousItem: vi.fn(),
  moveFocusToNextItem: vi.fn(),
  focusedItemIndex: 0,
  resetFocusedItemIndex: vi.fn(),
}));

describe("setupFocusHotkeys", () => {
  let addEventListenerMock;
  let querySelectorAllMock;
  let hotkeysMock;

  beforeEach(() => {
    document.body.innerHTML = `
      <div class="taxonomy__index">
        <ul>
          <li><a href="#">Item 1</a></li>
          <li><a href="#">Item 2</a></li>
        </ul>
      </div>
      <div class="entries-list">
        <div class="list__item">
          <h2><a href="#">Entry 1</a></h2>
        </div>
        <div class="list__item">
          <h2><a href="#">Entry 2</a></h2>
        </div>
      </div>
      <a class="back-to-top" href="#">Back to top</a>
    `;

    addEventListenerMock = vi.spyOn(HTMLElement.prototype, "addEventListener");
    querySelectorAllMock = vi.spyOn(document, "querySelectorAll");

    // Mock hotkeys library
    const hotkeysCallbacks = {};
    hotkeysMock = vi.fn((key, callback) => {
      hotkeysCallbacks[key] = callback;
    });
    hotkeysMock.trigger = (key) => {
      if (hotkeysCallbacks[key]) {
        hotkeysCallbacks[key]();
      }
    };
    global.hotkeys = hotkeysMock;
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it("should set up focus hotkeys and event listeners correctly", () => {
    setupFocusHotkeys();

    // Check if listItemLinks are populated correctly
    expect(querySelectorAllMock).toHaveBeenCalledWith(".taxonomy__index");
    expect(querySelectorAllMock).toHaveBeenCalledWith(".entries-list");
    expect(querySelectorAllMock).toHaveBeenCalledWith(".back-to-top");

    // Check if event listeners are added to listItemLinks
    expect(addEventListenerMock).toHaveBeenCalledWith(
      "focusout",
      expect.any(Function)
    );
    expect(addEventListenerMock).toHaveBeenCalledWith(
      "click",
      expect.any(Function)
    );

    // Check if hotkeys are set up
    expect(hotkeys).toHaveBeenCalledWith("j", expect.any(Function));
    expect(hotkeys).toHaveBeenCalledWith("k", expect.any(Function));
  });

  it("should call resetFocusedItemIndex when back-to-top link is clicked", () => {
    setupFocusHotkeys();

    const backToTopLink = document.querySelector(".back-to-top");
    backToTopLink.click();

    expect(resetFocusedItemIndex).toHaveBeenCalled();
  });

  it('should call moveFocusToNextItem when "j" hotkey is pressed', () => {
    setupFocusHotkeys();

    hotkeys.trigger("j");
    expect(moveFocusToNextItem).toHaveBeenCalled();
  });

  it('should call moveFocusToPreviousItem when "k" hotkey is pressed', () => {
    setupFocusHotkeys();

    hotkeys.trigger("k");
    expect(moveFocusToPreviousItem).toHaveBeenCalled();
  });

  it("should log correct index and focusedItemIndex on focusout", () => {
    setupFocusHotkeys();

    const listItemLinks = document.querySelectorAll(
      ".taxonomy__index li > a, .entries-list .list__item h2 > a"
    );
    listItemLinks.forEach((link, index) => {
      const consoleSpy = vi.spyOn(console, "log");
      link.dispatchEvent(new Event("focusout"));
      expect(consoleSpy).toHaveBeenCalledWith(
        `index link ${index} is unfocused`
      );
      expect(consoleSpy).toHaveBeenCalledWith(
        `focusedItemIndex is ${focusedItemIndex}`
      );
      consoleSpy.mockRestore();
    });
  });

  it("should log focusedItemIndex on back-to-top click", () => {
    setupFocusHotkeys();

    const backToTopLink = document.querySelector(".back-to-top");
    const consoleSpy = vi.spyOn(console, "log");
    backToTopLink.click();
    expect(consoleSpy).toHaveBeenCalledWith(
      `focusedItemIndex is ${focusedItemIndex}`
    );
    consoleSpy.mockRestore();
  });
});
