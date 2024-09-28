// /Users/noriyo_tcp/MyPlayground/til/assets/js/searchHotkeys.js
import { getOS } from "./osUtils.js";
import { isSearchOpen } from "./searchUtils.js";

export function setupSearchHotkeys() {
  const searchIcon = document.querySelector("button.search__toggle");
  if (!searchIcon) {
    console.log("searchIcon is not found");
    return false;
  }
  searchIcon.setAttribute("tooltip", "cmd/ctrl + k to open, esc to close");
  searchIcon.setAttribute("tooltip-position", "left");

  const openSearchForm = () => {
    if (isSearchOpen()) {
      return false;
    }

    document.querySelector(".search__toggle").click();
    return false;
  };

  const os = getOS();
  console.log(os);

  if (os === "macOS") {
    hotkeys("command+k", openSearchForm);
  } else {
    hotkeys("ctrl+k", openSearchForm);
  }
}

