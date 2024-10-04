export function detectOS(userAgent) {
  const userAgentLower = userAgent.toLowerCase();

  // Detect macOS
  if (
    userAgentLower.indexOf("macintosh") !== -1 ||
    userAgentLower.indexOf("mac os x") !== -1
  ) {
    return "macOS";
  }

  // Detect Windows
  if (userAgentLower.indexOf("windows") !== -1) {
    return "Windows";
  }

  // Detect Linux
  if (userAgentLower.indexOf("linux") !== -1) {
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

export function isMobile(userAgent) {
  return detectOS(userAgent) === "iOS" || detectOS(userAgent) === "Android";
}
