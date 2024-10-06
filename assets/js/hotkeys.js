import { setupFocusHotkeys } from "./setupFocusHotkeys.js";
import { setupSearchHotkeys } from "./setupSearchHotkeys.js";
import { setupHotkeysPopoverHotkeys } from "./setupHotkeysPopoverHotKeys.js";
import { setupBackToHotkeys } from "./setupBackToHotkeys.js";

document.addEventListener("DOMContentLoaded", function () {
  const userAgent = navigator.userAgent;
  const isMobile = /iphone|ipad|ipod|android/i.test(userAgent);
  const isMac =
    userAgent.toLowerCase().indexOf("macintosh") !== -1 ||
    userAgent.toLowerCase().indexOf("mac os x") !== -1;

  if (!isMobile) {
    // setup to search
    const searchIcon = document.querySelector("button.search__toggle");
    if (searchIcon) {
      searchIcon.setAttribute("tooltip", "cmd/ctrl + k to open, esc to close");
      searchIcon.setAttribute("tooltip-position", "left");
      setupSearchHotkeys(searchIcon, isMac);
    }
    // Register focus hotkeys
    setupFocusHotkeys();
    // Setup hotkeys popover hotkeys
    setupHotkeysPopoverHotkeys();
    // Setup back to hotkeys
    setupBackToHotkeys();
  }
});
