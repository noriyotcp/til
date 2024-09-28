export const isSearchOpen = () => {
  return document
    .querySelector(".search-content")
    ?.classList.contains("is--visible");
};

