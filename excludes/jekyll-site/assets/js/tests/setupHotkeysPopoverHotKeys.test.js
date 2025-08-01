import { setupHotkeysPopoverHotkeys } from "../setupHotkeysPopoverHotKeys";
import { describe, it, beforeEach, afterEach, expect, vi } from "vitest";
import { JSDOM } from "jsdom";

describe("setupHotkeysPopoverHotkeys", () => {
  let hotkeysPopover;
  let hotkeysPopoverCloseBtn;
  let dom;

  beforeEach(() => {
    // Set up jsdom
    dom = new JSDOM(
      `
      <div id="hotkeys-popover"></div>
      <button id="hotkeys-popover-close-icon"></button>
    `,
      { url: "http://localhost" }
    );

    global.window = dom.window;
    global.document = dom.window.document;
    global.HTMLElement = dom.window.HTMLElement;
    global.MouseEvent = dom.window.MouseEvent;

    hotkeysPopover = document.getElementById("hotkeys-popover");
    hotkeysPopoverCloseBtn = document.getElementById(
      "hotkeys-popover-close-icon"
    );

    // Mock the showPopover and hidePopover methods
    hotkeysPopover.showPopover = vi.fn();
    hotkeysPopover.hidePopover = vi.fn();

    // Mock the hotkeys function
    global.hotkeys = vi.fn((key, callback) => {
      document.addEventListener("keydown", (event) => {
        if (event.shiftKey && event.key === "/") {
          callback();
        }
      });
    });

    setupHotkeysPopoverHotkeys();
  });

  afterEach(() => {
    vi.clearAllMocks();
    dom.window.close();
  });

  it("should add click event listener to close button to hide popover", () => {
    hotkeysPopoverCloseBtn.click();
    expect(hotkeysPopover.hidePopover).toHaveBeenCalled();
  });

  it("should hide popover when clicking outside of it", () => {
    const clickEvent = new MouseEvent("click", {
      bubbles: true,
      cancelable: true,
      view: window, // Ensure the view property is set to the global window object
    });

    hotkeysPopover.dispatchEvent(clickEvent);
    expect(hotkeysPopover.hidePopover).toHaveBeenCalled();
  });

  it("should not hide popover when clicking inside of it", () => {
    const innerElement = document.createElement("div");
    hotkeysPopover.appendChild(innerElement);

    const clickEvent = new MouseEvent("click", {
      bubbles: true,
      cancelable: true,
      view: window, // Ensure the view property is set to the global window object
    });

    innerElement.dispatchEvent(clickEvent);
    expect(hotkeysPopover.hidePopover).not.toHaveBeenCalled();
  });

  it('should show popover when pressing "shift+/"', () => {
    const keydownEvent = new KeyboardEvent("keydown", {
      key: "/",
      shiftKey: true,
    });

    document.dispatchEvent(keydownEvent);
    expect(hotkeysPopover.showPopover).toHaveBeenCalled();
  });
});
