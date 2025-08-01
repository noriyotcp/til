const urlRegex = /\bhttps?:\/\/[^\s"'<>]+/gi;

// Utility function to check if two URLs have the same origin
function isSameOrigin(origin, destination) {
  return origin.origin === destination.origin;
}

// Function to get all text nodes under a given element
function getTextNodesUnder(el) {
  let n,
    a = [];
  const walk = document.createTreeWalker(el, NodeFilter.SHOW_TEXT, null, false);
  while ((n = walk.nextNode())) a.push(n);
  return a;
}

// Function to convert a single URL in a text node to a link
function convertUrlToLink(textNode, isSameOrigin) {
  const text = textNode.nodeValue;
  const newText = text.replace(urlRegex, function (url) {
    try {
      const validUrl = new URL(url);
      if (isSameOrigin(window.location, validUrl)) {
        return `<a href="${validUrl.href}">${validUrl.href}</a>`;
      } else {
        return `<a href="${validUrl.href}" target="_blank" rel="noopener noreferrer">${validUrl.href} <i class="fa-solid fa-arrow-up-right-from-square"></i></a>`;
      }
    } catch (e) {
      return url; // Return the original text if the URL is invalid
    }
  });

  if (newText !== text) {
    const span = document.createElement("span");
    span.innerHTML = newText;
    textNode.parentElement.replaceChild(span, textNode);
  }
}

// Function to process existing anchor tags
function processExistingAnchors(anchors, isSameOrigin) {
  anchors.forEach(function (anchor) {
    try {
      const validUrl = new URL(anchor.href);
      if (!isSameOrigin(window.location, validUrl)) {
        if (
          !anchor.hasAttribute("target") ||
          anchor.getAttribute("target") !== "_blank"
        ) {
          anchor.setAttribute("target", "_blank");
        }
        if (
          !anchor.hasAttribute("rel") ||
          !anchor.getAttribute("rel").includes("noopener noreferrer")
        ) {
          anchor.setAttribute("rel", "noopener noreferrer");
        }
        if (
          !anchor.innerHTML.includes(
            '<i class="fa-solid fa-arrow-up-right-from-square"></i>'
          )
        ) {
          anchor.innerHTML +=
            ' <i class="fa-solid fa-arrow-up-right-from-square"></i>';
        }
      }
    } catch (e) {
      // Do nothing if the URL is invalid
    }
  });
}

// Main function to convert URLs to links in the document
function convertToLinks() {
  if (document.body.classList.contains("layout--single")) {
    const paragraphs = document.querySelectorAll("section.page__content p");
    paragraphs.forEach(function (paragraph) {
      const codeElements = paragraph.querySelectorAll("code");
      const codeTextNodes = [];

      codeElements.forEach(function (codeElement) {
        codeTextNodes.push(...getTextNodesUnder(codeElement));
      });

      const textNodes = getTextNodesUnder(paragraph).filter(
        (node) => !codeTextNodes.includes(node)
      );
      textNodes.forEach((textNode) => convertUrlToLink(textNode, isSameOrigin));

      const anchors = paragraph.querySelectorAll("a");
      processExistingAnchors(anchors, isSameOrigin);
    });
  }
}

// Add event listener for DOMContentLoaded
document.addEventListener("DOMContentLoaded", convertToLinks);
