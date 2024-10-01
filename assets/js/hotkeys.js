import { detectOS } from "./detectOS.js";
import { moveFocusToPreviousItem, moveFocusToNextItem, focusedItemIndex, resetFocusedItemIndex } from "./focusNavigation.js";

document.addEventListener("DOMContentLoaded", function () {
  // setup to search
  const searchIcon = document.querySelector("button.search__toggle");
  if (searchIcon) {
    searchIcon.setAttribute("tooltip", "cmd/ctrl + k to open, esc to close");
    searchIcon.setAttribute("tooltip-position", "left");

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

  // setup to move focus to next/previous item
  const entriesLists = document.querySelectorAll(".entries-list");
  if (entriesLists.length > 0) {
    const listItemLinks = [];
    entriesLists.forEach((list) => {
      list.querySelectorAll(".list__item h2 > a").forEach((item) => {
        listItemLinks.push(item);
      });
    });

    console.log(listItemLinks);

    listItemLinks.forEach((link, index) => {
      link.addEventListener("focusout", (_event) => {
        if (focusedItemIndex === index) {
          resetFocusedItemIndex();
        }
        console.log(`listItem link ${index} is unfocused`);
        console.log(`focusedItemIndex is ${focusedItemIndex}`);
      });
    });

    hotkeys("j", () => moveFocusToNextItem(listItemLinks));
    hotkeys("k", () => moveFocusToPreviousItem(listItemLinks));
  }

  // setup to open hotkeys modal
  const hotkeysModal = document.getElementById("hotkeys-modal");
  const hotkeysModalCloseBtn = document.getElementById("hotkeys-modal-close-btn");

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
