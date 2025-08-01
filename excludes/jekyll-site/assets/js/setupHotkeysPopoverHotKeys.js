export const setupHotkeysPopoverHotkeys = () => {
  // setup to open hotkeys popover
  const hotkeysPopover = document.getElementById("hotkeys-popover");
  const hotkeysPopoverCloseBtn = document.getElementById(
    "hotkeys-popover-close-icon"
  );

  // Close popover
  hotkeysPopoverCloseBtn.addEventListener("click", () => hotkeysPopover.hidePopover());
  hotkeysPopover.addEventListener("click", (e) => {
    const { target, currentTarget } = e;
    if (target === currentTarget) {
      hotkeysPopover.hidePopover();
    }
  });

  // Add native keydown listener for debugging Shift+? event
  document.addEventListener("keydown", (e) => {
    if (e.key === "?" && e.shiftKey) {
      hotkeysPopover.showPopover();
    }
  });
};
