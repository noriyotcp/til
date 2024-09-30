const isSearchOpen = () => {
  return document
    .querySelector(".search-content")
    ?.classList.contains("is--visible");
};

export let focusedItemIndex = null;

// cannot modify focusedItemIndex even if it's exported as let variable
// under the effect of the immutable exported module values
// so use a function to reset value with null
// cf. https://2ality.com/2015/07/es6-module-exports.html#es6-modules-export-immutable-bindings
export const resetFocusedItemIndex = () => {
  focusedItemIndex = null;
};

const incrementIndex = (listLength) => {
  if (focusedItemIndex === null) {
    focusedItemIndex = 0;
  } else if (focusedItemIndex !== listLength - 1) {
    focusedItemIndex++;
  }
};

const decrementIndex = (listLength) => {
  if (focusedItemIndex !== null && focusedItemIndex !== 0) {
    focusedItemIndex--;
  }
};

const focusListItem = (listItemLinks) => {
  if (isSearchOpen()) {
    return false;
  }

  listItemLinks[focusedItemIndex].focus();
  console.log(focusedItemIndex);

  return false;
};

export const moveFocusToNextItem = (listItemLinks) => {
  if (isSearchOpen()) {
    return false;
  }

  incrementIndex(listItemLinks.length);
  focusListItem(listItemLinks);

  return false;
};

export const moveFocusToPreviousItem = (listItemLinks) => {
  if (isSearchOpen()) {
    return false;
  }

  decrementIndex(listItemLinks.length);
  focusListItem(listItemLinks);

  return false;
};
