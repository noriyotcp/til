export const setupHotkeysModalHotkeys = () => {
  // setup to open hotkeys modal
  const hotkeysModal = document.getElementById("hotkeys-modal");
  const hotkeysModalCloseBtn = document.getElementById("hotkeys-modal-close-btn");

  // Close modal
  hotkeysModalCloseBtn.addEventListener("click", () => hotkeysModal.close());
  hotkeysModal.addEventListener("click", (e) => {
    const { target, currentTarget } = e;
    if (target === currentTarget) {
      hotkeysModal.close();
    }
  });

  // Press '?' to open modal
  hotkeys("shift+/", () => hotkeysModal.show());
};
