export const isSearchOpen = () => {
  return document
    .querySelector(".search-content")
    ?.classList.contains("is--visible");
};

export const openSearchForm = () => {
  if (isSearchOpen()) {
    return false;
  }

  document.querySelector(".search__toggle").click();
  return false;
};

