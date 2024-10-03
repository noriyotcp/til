import { detectOS, isMobile } from "./detectOS.js";
import { setupFocusHotkeys } from "./setupFocusHotkeys.js";
import { setupSearchHotkeys } from "./setupSearchHotkeys.js";
import { setupHotkeysPopoverHotkeys } from "./setupHotkeysPopoverHotKeys.js";

document.addEventListener("DOMContentLoaded", function () {
  // setup to search
  const searchIcon = document.querySelector("button.search__toggle");
  if (searchIcon) {
    if (!isMobile()) {
      searchIcon.setAttribute("tooltip", "cmd/ctrl + k to open, esc to close");
      searchIcon.setAttribute("tooltip-position", "left");
    }

    setupSearchHotkeys(searchIcon);
  }

  // Register focus hotkeys
  setupFocusHotkeys();

  // Setup hotkeys popover hotkeys
  setupHotkeysPopoverHotkeys();
});
