import { detectOS } from "./detectOS.js";
import { moveFocusToPreviousItem, moveFocusToNextItem, focusedItemIndex, resetFocusedItemIndex } from "./focusNavigation.js";

document.addEventListener("DOMContentLoaded", function () {
  // setup to search
  const searchIcon = document.querySelector("button.search__toggle");
  if (!searchIcon) {
    console.log("searchIcon is not found");
    return false;
  }
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

  // setup to move focus to next/previous item
  const entriesLists = document.querySelectorAll(".entries-list");
  if (entriesLists.length === 0) {
    return false;
  }

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

  const helpModal = document.getElementById("hotkeys-modal");
  const closeBtn = document.getElementById("close-btn");

  // Close modal
  closeBtn.addEventListener("click", () => helpModal.close());
  helpModal.addEventListener("click", (e) => {
    const { target, currentTarget } = e;
    if (target === currentTarget) {
      helpModal.close();
    }
  });

  // Hotkeys handler
  hotkeys("*", function () {
    if (hotkeys.shift && hotkeys.isPressed(191)) {
      console.log("shift + ? is pressed");
      helpModal.showModal();
      console.log("show help modal");
    }
  });
});
