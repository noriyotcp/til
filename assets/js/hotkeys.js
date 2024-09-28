function getOS() {
  const userAgent = window.navigator.userAgent.toLowerCase();
  const platform = window.navigator.platform.toLowerCase();

  // Detect macOS
  if (
    userAgent.indexOf("macintosh") !== -1 ||
    userAgent.indexOf("mac os x") !== -1 ||
    platform.indexOf("mac") !== -1
  ) {
    return "macOS";
  }

  // Detect Windows
  if (userAgent.indexOf("windows") !== -1 || platform.indexOf("win") !== -1) {
    return "Windows";
  }

  // Detect Linux
  if (userAgent.indexOf("linux") !== -1 || platform.indexOf("linux") !== -1) {
    return "Linux";
  }

  // Detect iOS
  if (/iphone|ipad|ipod/.test(userAgent)) {
    return "iOS";
  }

  // Detect Android
  if (/android/.test(userAgent)) {
    return "Android";
  }

  return "Unknown";
}

document.addEventListener("DOMContentLoaded", function () {
  const searchIcon = document.querySelector("button.search__toggle");
  if (!searchIcon) {
    console.log("searchIcon is not found");
    return false;
  }
  searchIcon.setAttribute("tooltip", "cmd/ctrl + k to open, esc to close");
  searchIcon.setAttribute("tooltip-position", "left");

  const isSearchOpen = () => {
    return document
    .querySelector(".search-content")
    ?.classList.contains("is--visible");
  }

  const openSearchForm = () => {
    // If the search form is already open, do nothing
    if (isSearchOpen()) {
      return false;
    }

    document.querySelector(".search__toggle").click();
    return false;
  };

  const os = getOS();

  // Detect whether you are using macOS or not
  if (os === "macOS") {
    hotkeys("command+k", openSearchForm);
  } else {
    hotkeys("ctrl+k", openSearchForm);
  }

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
  }

  // setup
  const entriesList = document.querySelector(".entries-list");
  const entriesLists = document.querySelectorAll(".entries-list");
  // If the entries list is not found, do nothing
  if (!entriesList) {
    return false;
  }
  if (entriesLists.length === 0) {
    return false;
  }

  // const listItems = entriesList.querySelectorAll(".list__item");

  const listItems = [];
  entriesLists.forEach((list) => {
    list.querySelectorAll(".list__item").forEach((item) => {
      listItems.push(item);
    }
    );
  });

  // const listItemLinks = entriesList.querySelectorAll(".list__item h2 > a");

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

    // remove .item-focus class from all list items
    listItems.forEach((linkItem) => {
      linkItem.classList.remove("item-focus");
    });

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

  hotkeys("j", moveFocusToNextItem);
});
