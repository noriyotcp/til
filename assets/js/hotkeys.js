import { detectOS, isMobile } from "./detectOS.js";
import { setupFocusHotkeys } from "./setupFocusHotkeys.js";

document.addEventListener("DOMContentLoaded", function () {
  // setup to search
  const searchIcon = document.querySelector("button.search__toggle");
  if (searchIcon) {
    if (!isMobile()) {
      searchIcon.setAttribute("tooltip", "cmd/ctrl + k to open, esc to close");
      searchIcon.setAttribute("tooltip-position", "left");
    }

    const os = detectOS();
    console.log(os);

    const openSearchForm = () => {
      const isSearchOpen = document
        .querySelector(".search-content")
        ?.classList.contains("is--visible");

      if (isSearchOpen) {
        return false;
      }

      searchIcon.click();
      return false;
    };

    if (os === "macOS") {
      hotkeys("command+k", openSearchForm);
    } else {
      hotkeys("ctrl+k", openSearchForm);
    }
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
