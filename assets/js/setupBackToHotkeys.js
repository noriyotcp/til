export const setupBackToHotkeys = () => {
  // Get all <a> elements with the class .back-to-top
  const backToTopLinks = document.querySelectorAll("a.back-to-top");

  backToTopLinks.forEach((link) => {
    const href = link.getAttribute("href");

    // Regular expression to get everything after #
    const match = href.match(/#(.+)/);

    if (match && match[1]) {
      const content = match[1];

      let hotkeyValue;
      if (/^\d/.test(content)) {
        // If it starts with a number, extract only the numbers and process them
        const numbers = content.replace(/-/g, "");
        hotkeyValue = "b " + numbers.split("").join(" ");
      } else if (content === "page-title") {
        // If it is page-title, assign `b t` as the hotkey
        hotkeyValue = "b t";
      }

      link.setAttribute("data-hotkey", hotkeyValue);
    }
  });
}
