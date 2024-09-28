import { getOS } from "./osUtils.js";
import { isSearchOpen } from "./searchUtils.js";
import { setupSearchHotkeys } from "./searchHotkeys.js";

document.addEventListener("DOMContentLoaded", function () {
  setupSearchHotkeys();

  let focusedItemIndex = null;
  // default index is null
  // increment index by 1 when this function is called
  // argument is the length of the list
  const incrementIndex = (listLength) => {
    // if current index is the last index of the list, does not increment
    if (focusedItemIndex === null) {
      focusedItemIndex = 0;
    } else if (focusedItemIndex !== listLength - 1) {
      focusedItemIndex++;
    }
  };

  const decrementIndex = (listLength) => {
    // if current index is the first index of the list, does not decrement
    if (focusedItemIndex !== null && focusedItemIndex !== 0) {
      focusedItemIndex--;
    }
  };

  // setup
  const entriesLists = document.querySelectorAll(".entries-list");
  // If the entries list is not found, do nothing
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
        focusedItemIndex = null;
      }
      console.log(`listItem link ${index} is unfocused`);
      console.log(`focusedItemIndex is ${focusedItemIndex}`);
    });
  });

  const focusListItem = () => {
    if (isSearchOpen()) {
      return false;
    }

    listItemLinks[focusedItemIndex].focus();
    console.log(focusedItemIndex);

    return false;
  };

  const moveFocusToNextItem = () => {
    if (isSearchOpen()) {
      return false;
    }

    incrementIndex(listItemLinks.length);
    focusListItem();

    return false;
  };

  const moveFocusToPreviousItem = () => {
    if (isSearchOpen()) {
      return false;
    }

    decrementIndex(listItemLinks.length);
    focusListItem();

    return false;
  };

  hotkeys("j", moveFocusToNextItem);
  hotkeys("k", moveFocusToPreviousItem);
});
