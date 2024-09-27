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
  const searchIcon = document.querySelector('button.search__toggle');
  if (!searchIcon) {
    console.log('searchIcon is not found');
    return false;
  };
  searchIcon.setAttribute('tooltip', 'cmd/ctrl + k to open, esc to close');
  searchIcon.setAttribute('tooltip-position', 'left');

  const openSearchForm = () => {
    const isSearchOpen = document
      .querySelector(".search-content")
      .classList.contains("is--visible");

    // If the search form is already open, do nothing
    if (isSearchOpen) {
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
});
