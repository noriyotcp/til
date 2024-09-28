export function getOS() {
  const userAgent = window.navigator.userAgent.toLowerCase();

  // Detect macOS
  if (
    userAgent.indexOf("macintosh") !== -1 ||
    userAgent.indexOf("mac os x") !== -1
  ) {
    return "macOS";
  }

  // Detect Windows
  if (userAgent.indexOf("windows") !== -1) {
    return "Windows";
  }

  // Detect Linux
  if (userAgent.indexOf("linux") !== -1) {
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

