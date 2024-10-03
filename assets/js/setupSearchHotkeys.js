import { detectOS } from "./detectOS.js";

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

export const setupSearchHotkeys = (searchIcon) => {
  const os = detectOS();
  console.log(os);

  if (os === "macOS") {
    hotkeys("command+k", () => openSearchForm(searchIcon));
  } else {
    hotkeys("ctrl+k", () => openSearchForm(searchIcon));
  }
};
