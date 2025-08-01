import { describe, it, beforeAll, expect } from "vitest";
import { JSDOM } from "jsdom";
import fs from "fs";
import path from "path";

// Read the script content directly from the file
const convertToTasklistScript = fs.readFileSync(
  path.resolve(__dirname, "../convertToTasklist.js"),
  "utf8"
);

// Create a virtual DOM environment
const dom = new JSDOM(
  `<!DOCTYPE html><body><div id="main_content"></div></body>`,
  {
    runScripts: "dangerously",
    resources: "usable",
  }
);

// Inject the script content into the virtual DOM
const scriptEl = dom.window.document.createElement("script");
scriptEl.textContent = convertToTasklistScript;
dom.window.document.body.appendChild(scriptEl);

const { window } = dom;
const { document } = window;

describe("convertToTasklist.js", () => {
  describe("convert", () => {
    it("should convert unchecked task list items", () => {
      const content = "[ ] Task 1";
      const expected =
        /<input type="checkbox" class="task-list-item-checkbox" disabled="disabled"( \/)?>( Task 1)?/;
      expect(window.convert(content)).toMatch(expected);
    });

    it("should convert checked task list items", () => {
      const content = "[x] Task 1";
      const expected =
        /<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" checked="checked"( \/)?>( Task 1)?/;
      expect(window.convert(content)).toMatch(expected);
    });

    it("should not convert non-task list items", () => {
      const content = "Task 1";
      const expected = "Task 1";
      expect(window.convert(content)).toBe(expected);
    });
  });

  describe("processListItems", () => {
    it("should process list items and convert them", () => {
      document.body.innerHTML = `
        <ul>
          <li>[ ] Task 1</li>
          <li>[x] Task 2</li>
        </ul>
      `;
      const listItems = document.querySelectorAll("li");
      window.processListItems(listItems);

      expect(listItems[0].innerHTML).toMatch(
        /<input type="checkbox" class="task-list-item-checkbox" disabled="disabled"( \/)?>( Task 1)?/
      );
      expect(listItems[1].innerHTML).toMatch(
        /<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" checked="checked"( \/)?>( Task 2)?/
      );
    });

    it("should add task-list-item class to converted items", () => {
      document.body.innerHTML = `
        <ul>
          <li>[ ] Task 1</li>
          <li>[x] Task 2</li>
        </ul>
      `;
      const listItems = document.querySelectorAll("li");
      window.processListItems(listItems);

      expect(listItems[0].classList.contains("task-list-item")).toBe(true);
      expect(listItems[1].classList.contains("task-list-item")).toBe(true);
    });

    it("should process nested list items", () => {
      document.body.innerHTML = `
        <ul>
          <li>[ ] Task 1
            <ul>
              <li>[x] Subtask 1</li>
            </ul>
          </li>
        </ul>
      `;
      const listItems = document.querySelectorAll("li");
      window.processListItems(listItems);

      expect(listItems[0].innerHTML).toMatch(
        /<input type="checkbox" class="task-list-item-checkbox" disabled="disabled"( \/)?>( Task 1)?/
      );
      expect(listItems[1].innerHTML).toMatch(
        /<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" checked="checked"( \/)?>( Subtask 1)?/
      );
    });
  });
});
