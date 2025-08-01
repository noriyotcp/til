import { describe, it, beforeEach, afterEach, expect } from "vitest";
import { JSDOM } from "jsdom";
import fs from "fs";
import path from "path";

// Read the script content directly from the file
const convertToLinkScript = fs.readFileSync(
  path.resolve(__dirname, "../convertToLink.js"),
  "utf8"
);

// Create a virtual DOM environment
let dom;
let document;
let window;

beforeEach(() => {
  dom = new JSDOM(`<!DOCTYPE html><body></body>`, {
    runScripts: "dangerously",
    resources: "usable",
    url: "https://example.com", // Set the site domain
  });

  // Inject the script content into the virtual DOM
  const scriptEl = dom.window.document.createElement("script");
  scriptEl.textContent = convertToLinkScript;
  dom.window.document.body.appendChild(scriptEl);

  window = dom.window;
  document = window.document;
});

afterEach(() => {
  dom.window.close();
});

describe("convertToLink.js", () => {
  describe("convertUrlToLink", () => {
    it("should convert URLs in text nodes to links", () => {
      document.body.innerHTML = `<p>Visit https://example.com for more info.</p>`;
      const paragraph = document.querySelector("p");
      const textNodes = window.getTextNodesUnder(paragraph);
      textNodes.forEach((textNode) =>
        window.convertUrlToLink(textNode, window.isSameOrigin)
      );
      expect(paragraph.innerHTML).toBe(
        '<span>Visit <a href="https://example.com/">https://example.com/</a> for more info.</span>'
      );
    });

    it("should open external links in a new tab with appropriate attributes", () => {
      document.body.innerHTML = `<p>Visit https://external.com for more info.</p>`;
      const paragraph = document.querySelector("p");
      const textNodes = window.getTextNodesUnder(paragraph);
      textNodes.forEach((textNode) =>
        window.convertUrlToLink(textNode, window.isSameOrigin)
      );
      expect(paragraph.innerHTML).toBe(
        '<span>Visit <a href="https://external.com/" target="_blank" rel="noopener noreferrer">https://external.com/ <i class="fa-solid fa-arrow-up-right-from-square"></i></a> for more info.</span>'
      );
    });

    it("should not modify text without URLs", () => {
      document.body.innerHTML = `<p>No URLs here!</p>`;
      const paragraph = document.querySelector("p");
      const textNodes = window.getTextNodesUnder(paragraph);
      textNodes.forEach((textNode) =>
        window.convertUrlToLink(textNode, window.isSameOrigin)
      );
      expect(paragraph.innerHTML).toBe("No URLs here!");
    });

    it("should handle invalid URLs gracefully", () => {
      document.body.innerHTML = `<p>Visit invalid-url for more info.</p>`;
      const paragraph = document.querySelector("p");
      const textNodes = window.getTextNodesUnder(paragraph);
      textNodes.forEach((textNode) =>
        window.convertUrlToLink(textNode, window.isSameOrigin)
      );
      expect(paragraph.innerHTML).toBe("Visit invalid-url for more info.");
    });
  });

  describe("processExistingAnchors", () => {
    it("should add target and rel attributes to external links", () => {
      document.body.innerHTML = `<p><a href="https://external.com">External Link</a></p>`;
      const anchors = document.querySelectorAll("a");
      window.processExistingAnchors(anchors, window.isSameOrigin);
      const anchor = anchors[0];
      expect(anchor.getAttribute("target")).toBe("_blank");
      expect(anchor.getAttribute("rel")).toBe("noopener noreferrer");
      expect(anchor.innerHTML).toBe(
        'External Link <i class="fa-solid fa-arrow-up-right-from-square"></i>'
      );
    });

    it("should not modify internal links", () => {
      document.body.innerHTML = `<p><a href="https://example.com">Internal Link</a></p>`;
      const anchors = document.querySelectorAll("a");
      window.processExistingAnchors(anchors, window.isSameOrigin);
      const anchor = anchors[0];
      expect(anchor.getAttribute("target")).toBeNull();
      expect(anchor.getAttribute("rel")).toBeNull();
      expect(anchor.innerHTML).toBe("Internal Link");
    });

    it("should handle anchors without href attribute", () => {
      document.body.innerHTML = `<p><a>Link without href</a></p>`;
      const anchors = document.querySelectorAll("a");
      window.processExistingAnchors(anchors, window.isSameOrigin);
      const anchor = anchors[0];
      expect(anchor.getAttribute("target")).toBeNull();
      expect(anchor.getAttribute("rel")).toBeNull();
      expect(anchor.innerHTML).toBe("Link without href");
    });

    it("should not modify anchors with invalid URLs", () => {
      document.body.innerHTML = `<p><a href="invalid-url">Invalid URL</a></p>`;
      const anchors = document.querySelectorAll("a");
      window.processExistingAnchors(anchors, window.isSameOrigin);
      const anchor = anchors[0];
      expect(anchor.getAttribute("target")).toBeNull();
      expect(anchor.getAttribute("rel")).toBeNull();
      expect(anchor.innerHTML).toBe("Invalid URL");
    });
  });
});
