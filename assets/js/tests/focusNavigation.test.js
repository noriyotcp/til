import { describe, it, beforeEach, expect } from "vitest";
import {
  focusedItemIndex,
  resetFocusedItemIndex,
  moveFocusToNextItem,
  moveFocusToPreviousItem,
} from "../focusNavigation";

describe("focusNavigation", () => {
  let listItemLinks;

  beforeEach(() => {
    document.body.innerHTML = `
    <div class="search-content"></div>
    <a href="#" class="item">Item 1</a>
    <a href="#" class="item">Item 2</a>
    <a href="#" class="item">Item 3</a>
  `;
    listItemLinks = document.querySelectorAll(".item");
  });

  it("should reset focusedItemIndex to null", () => {
    resetFocusedItemIndex();
    expect(focusedItemIndex).toBeNull();
  });

  it("should move focus to next item", () => {
    moveFocusToNextItem(listItemLinks);
    expect(focusedItemIndex).toBe(0);
    expect(document.activeElement).toBe(listItemLinks[0]);

    moveFocusToNextItem(listItemLinks);
    expect(focusedItemIndex).toBe(1);
    expect(document.activeElement).toBe(listItemLinks[1]);
  });

  it("should not move focus to next item if search is open", () => {
    document.querySelector(".search-content").classList.add("is--visible");
    expect(moveFocusToNextItem(listItemLinks)).toBe(false);
  });

  it("should move focus to previous item", () => {
    moveFocusToNextItem(listItemLinks);
    moveFocusToNextItem(listItemLinks);
    moveFocusToPreviousItem(listItemLinks);
    expect(focusedItemIndex).toBe(1);
    expect(document.activeElement).toBe(listItemLinks[1]);
  });

  it("should not move focus to previous item if search is open", () => {
    document.querySelector(".search-content").classList.add("is--visible");
    expect(moveFocusToPreviousItem(listItemLinks)).toBe(false);
  });

  it("should not decrement index below 0", () => {
    moveFocusToPreviousItem(listItemLinks);
    expect(focusedItemIndex).toBe(0);
  });

  it("should not increment index beyond list length", () => {
    moveFocusToNextItem(listItemLinks);
    moveFocusToNextItem(listItemLinks);
    moveFocusToNextItem(listItemLinks);
    moveFocusToNextItem(listItemLinks);
    expect(focusedItemIndex).toBe(2);
    expect(document.activeElement).toBe(listItemLinks[2]);
  });
});
