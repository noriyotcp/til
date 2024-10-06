import { setupFocusHotkeys } from "./setupFocusHotkeys.js";
import { setupSearchHotkeys } from "./setupSearchHotkeys.js";
import { setupHotkeysPopoverHotkeys } from "./setupHotkeysPopoverHotKeys.js";

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

    // Get all <a> elements with the class .back-to-top
    const backToTopLinks = document.querySelectorAll("a.back-to-top");

    backToTopLinks.forEach((link) => {
      const href = link.getAttribute("href");

      // Regular expression to get everything after #
      const match = href.match(/#(.+)/);

      if (match && match[1]) {
        const content = match[1];

        let hotkeyValue;
        if (/^\d/.test(content)) {
          // If it starts with a number, extract only the numbers and process them
          const numbers = content.replace(/-/g, "");
          hotkeyValue = "b " + numbers.split("").join(" ");
        } else if (content === "page-title") {
          // If it is page-title, assign `b t` as the hotkey
          hotkeyValue = "b t";
        }

        link.setAttribute("data-hotkey", hotkeyValue);
      }
    });
  }
});
