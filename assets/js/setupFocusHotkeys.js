import { moveFocusToPreviousItem, moveFocusToNextItem, focusedItemIndex, resetFocusedItemIndex } from "./focusNavigation.js";

export const setupFocusHotkeys = () => {
  const listItemLinks = [];
  const taxonomy__indexes = document.querySelectorAll(".taxonomy__index");
  const entriesLists = document.querySelectorAll(".entries-list");

  const backToTopLinks = document.querySelectorAll(".back-to-top");

  if (taxonomy__indexes.length > 0) {
    taxonomy__indexes.forEach((index) => {
      index.querySelectorAll("li > a").forEach((item) => {
        listItemLinks.push(item);
      });
    });
  }

  if (entriesLists.length > 0) {
    entriesLists.forEach((list) => {
      list.querySelectorAll(".list__item h2 > a").forEach((item) => {
        listItemLinks.push(item);
      });
    });
  }

  console.log(listItemLinks);

  listItemLinks.forEach((link, index) => {
    link.addEventListener("focusout", (_event) => {
      // Even if the focus is out, the focusedItemIndex remains the same
      console.log(`index link ${index} is unfocused`);
      console.log(`focusedItemIndex is ${focusedItemIndex}`);
    });
  });

  backToTopLinks.forEach((link, index) => {
    link.addEventListener("click", (_event) => {
      resetFocusedItemIndex();
      console.log(`focusedItemIndex is ${focusedItemIndex}`);
    });
  });

  if (listItemLinks.length > 0) {
    hotkeys("j", () => moveFocusToNextItem(listItemLinks));
    hotkeys("k", () => moveFocusToPreviousItem(listItemLinks));
  }
};
