import { describe, it, beforeEach, afterEach, expect, vi } from "vitest";
import { setupSearchHotkeys } from "../setupSearchHotkeys";

describe("setupSearchHotkeys", () => {
  let searchIcon;
  let hotkeysMock;

  beforeEach(() => {
    searchIcon = {
      click: vi.fn(),
    };

    hotkeysMock = vi.fn();
    global.hotkeys = hotkeysMock;
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it("should bind command+k hotkey for Mac", () => {
    setupSearchHotkeys(searchIcon, true);
    expect(hotkeysMock).toHaveBeenCalledWith("command+k", expect.any(Function));
  });

  it("should bind ctrl+k hotkey for non-Mac", () => {
    setupSearchHotkeys(searchIcon, false);
    expect(hotkeysMock).toHaveBeenCalledWith("ctrl+k", expect.any(Function));
  });

  describe("openSearchForm", () => {
    let openSearchForm;
    let focusMock;

    beforeEach(() => {
      setupSearchHotkeys(searchIcon, true); // Ensure hotkeys are set up before accessing the mock calls
      openSearchForm = hotkeysMock.mock.calls[0][1];
      focusMock = vi.fn();
      document.getElementById = vi.fn().mockReturnValue({ focus: focusMock });
    });

    it("should focus on search input if search is already open", () => {
      document.querySelector = vi.fn().mockReturnValue({
        classList: {
          contains: vi.fn().mockReturnValue(true),
        },
      });

      openSearchForm();
      expect(document.getElementById).toHaveBeenCalledWith("search");
      expect(focusMock).toHaveBeenCalled();
      expect(searchIcon.click).not.toHaveBeenCalled();
    });

    it("should click search icon if search is not open", () => {
      document.querySelector = vi.fn().mockReturnValue({
        classList: {
          contains: vi.fn().mockReturnValue(false),
        },
      });

      openSearchForm();
      expect(searchIcon.click).toHaveBeenCalled();
      expect(document.getElementById).not.toHaveBeenCalled();
    });
  });
});
