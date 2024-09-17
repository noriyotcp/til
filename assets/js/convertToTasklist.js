function convert(content) {
  const boxUnchecked =
    '<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" />';
  const boxChecked =
    '<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" checked="checked" />';

  let converted = content.replace(/\[\s\]\s+/g, boxUnchecked + " ");
  converted = converted.replace(/\[x\]\s+/g, boxChecked + " ");

  return converted;
}

function processListItems(list) {
  list.forEach((li) => {
    const originalContent = li.innerHTML.trim();
    const convertedContent = convert(originalContent);

    console.log("originalContent:", originalContent);
    console.log("convertedContent:", convertedContent);

    if (convertedContent !== originalContent) {
      li.innerHTML = convertedContent;
      li.classList.add("task-list-item");
    }

    // 再帰処理のため、ネストされたli要素をチェック
    const nestedLists = li.querySelectorAll("ul, ol");
    if (nestedLists.length > 0) {
      nestedLists.forEach((nestedList) => {
        processListItems(nestedList.querySelectorAll("li"));
      });
    }
  });
}

document.addEventListener("DOMContentLoaded", () => {
  const contentEl = document.getElementById("main_content");
  if (contentEl) {
    processListItems(contentEl.querySelectorAll("li"));
  }
});
