import { moveFocusToPreviousItem, moveFocusToNextItem, focusedItemIndex, resetFocusedItemIndex } from "./focusNavigation.js";

export const setupFocusHotkeys = () => {
  const listItemLinks = [];
  const taxonomy__indexes = document.querySelectorAll(".taxonomy__index");
  const entriesLists = document.querySelectorAll(".entries-list");

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
      if (focusedItemIndex === index) {
        resetFocusedItemIndex();
      }
      console.log(`index link ${index} is unfocused`);
      console.log(`focusedItemIndex is ${focusedItemIndex}`);
    });
  });

  if (listItemLinks.length > 0) {
    hotkeys("j", () => moveFocusToNextItem(listItemLinks));
    hotkeys("k", () => moveFocusToPreviousItem(listItemLinks));
  }
};
