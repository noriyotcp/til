export function detectOS() {
  const userAgent = navigator.userAgent.toLowerCase();

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
  if (/iphone|ipad|ipod/i.test(userAgent)) {
    return "iOS";
  }

  // Detect Android
  if (/android/i.test(userAgent)) {
    return "Android";
  }

  return "Unknown";
}

export function isMobile() {
  return detectOS() === "iOS" || detectOS() === "Android";
}
