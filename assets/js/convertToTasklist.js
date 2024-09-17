function convert(content) {
  const boxUnchecked =
    '<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" />';
  const boxChecked =
    '<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" checked="checked" />';

  let converted = content.replace(/\[\s\]\s+/gm, boxUnchecked + " ");
  converted = converted.replace(/\[x\]\s+/gim, boxChecked + " ");

  return converted;
}

document.addEventListener("DOMContentLoaded", () => {
  const contentEl = document.getElementById("main_content");
  if (contentEl) {
    contentEl.querySelectorAll("li").forEach((li) => {
      const liContent = li.innerHTML;
      li.innerHTML = convert(liContent);
    });
  }
});
