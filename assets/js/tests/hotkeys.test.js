import { setupFocusHotkeys } from "../setupFocusHotkeys.js";
import { setupSearchHotkeys } from "../setupSearchHotkeys.js";
import { setupHotkeysPopoverHotkeys } from "../setupHotkeysPopoverHotKeys.js";
import { setupBackToHotkeys } from "../setupBackToHotkeys.js";
import "../hotkeys.js";
import { describe, it, beforeEach, vi, expect } from "vitest";

vi.mock("../setupFocusHotkeys.js");
vi.mock("../setupSearchHotkeys.js");
vi.mock("../setupHotkeysPopoverHotKeys.js");
vi.mock("../setupBackToHotkeys.js");

describe("hotkeys.js", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <button class="search__toggle"></button>
    `;
    vi.clearAllMocks();
  });

  it("should set up search hotkeys if not on mobile", () => {
    Object.defineProperty(navigator, "userAgent", {
      value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
      writable: true,
    });

    document.dispatchEvent(new Event("DOMContentLoaded"));

    const searchIcon = document.querySelector("button.search__toggle");
    expect(searchIcon.getAttribute("tooltip")).toBe("cmd/ctrl + k to open, esc to close");
    expect(searchIcon.getAttribute("tooltip-position")).toBe("left");
    expect(setupSearchHotkeys).toHaveBeenCalledWith(searchIcon, true);
  });

  it("should not set up search hotkeys if on mobile", () => {
    Object.defineProperty(navigator, "userAgent", {
      value: "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15A372 Safari/604.1",
      writable: true,
    });

    document.dispatchEvent(new Event("DOMContentLoaded"));

    const searchIcon = document.querySelector("button.search__toggle");
    expect(searchIcon.getAttribute("tooltip")).toBeNull();
    expect(searchIcon.getAttribute("tooltip-position")).toBeNull();
    expect(setupSearchHotkeys).not.toHaveBeenCalled();
  });

  it("should register focus hotkeys if not on mobile", () => {
    Object.defineProperty(navigator, "userAgent", {
      value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
      writable: true,
    });

    document.dispatchEvent(new Event("DOMContentLoaded"));

    expect(setupFocusHotkeys).toHaveBeenCalled();
  });

  it("should set up hotkeys popover hotkeys if not on mobile", () => {
    Object.defineProperty(navigator, "userAgent", {
      value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
      writable: true,
    });

    document.dispatchEvent(new Event("DOMContentLoaded"));

    expect(setupHotkeysPopoverHotkeys).toHaveBeenCalled();
  });

  it("should set up back to hotkeys if not on mobile", () => {
    Object.defineProperty(navigator, "userAgent", {
      value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
      writable: true,
    });

    document.dispatchEvent(new Event("DOMContentLoaded"));

    expect(setupBackToHotkeys).toHaveBeenCalled();
  });
});
