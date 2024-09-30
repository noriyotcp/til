export const openSearchForm = () => {
  const isSearchOpen = document
    .querySelector(".search-content")
    ?.classList.contains("is--visible");

  if (isSearchOpen) {
    return false;
  }

  document.querySelector(".search__toggle").click();
  return false;
};
