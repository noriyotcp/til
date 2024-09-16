
    function convert(content) {
      const boxUnchecked = '<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" />';
      const boxChecked = '<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" checked="checked" />';
      
      let converted = content.replace(/^\s*\[\s\]\s+/gm, boxUnchecked + ' ');
      converted = converted.replace(/^\s*\[x\]\s+/gim, boxChecked + ' ');
      
      return converted;
    }

    document.addEventListener('DOMContentLoaded', () => {
      const contentEl = document.getElementById('content');
      if (contentEl) {
        const htmlContent = contentEl.innerHTML;
        contentEl.innerHTML = convert(htmlContent);
      }
    });
