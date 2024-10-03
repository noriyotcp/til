import { detectOS, isMobile } from "./detectOS.js";
import { setupFocusHotkeys } from "./setupFocusHotkeys.js";
import { setupSearchHotkeys } from "./setupSearchHotkeys.js";

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

  // setup to open hotkeys modal
  const hotkeysModal = document.getElementById("hotkeys-modal");
  const hotkeysModalCloseBtn = document.getElementById(
    "hotkeys-modal-close-btn"
  );

  // Close modal
  hotkeysModalCloseBtn.addEventListener("click", () => hotkeysModal.close());
  hotkeysModal.addEventListener("click", (e) => {
    const { target, currentTarget } = e;
    if (target === currentTarget) {
      hotkeysModal.close();
    }
  });

  // Press '?' to open modal
  hotkeys("shift+/", () => hotkeysModal.showModal());
});
