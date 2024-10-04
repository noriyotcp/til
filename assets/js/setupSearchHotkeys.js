const openSearchForm = (searchIcon) => {
  const isSearchOpen = document
    .querySelector(".search-content")
    ?.classList.contains("is--visible");

  if (isSearchOpen) {
    return false;
  }

  searchIcon.click();
  return false;
};

export const setupSearchHotkeys = (searchIcon, isMac) => {
  if (isMac) {
    hotkeys("command+k", () => openSearchForm(searchIcon));
  } else {
    hotkeys("ctrl+k", () => openSearchForm(searchIcon));
  }
};
