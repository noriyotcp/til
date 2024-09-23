document.addEventListener("DOMContentLoaded", function() {
  // 正規表現で URL を検出
  const urlRegex = /\bhttps?:\/\/[^\s<]+/ig;

  // 特定のタグ内のテキストノードを取得する関数
  function getTextNodesUnder(el) {
    var n, a=[], walk=document.createTreeWalker(el,NodeFilter.SHOW_TEXT,null,false);
    while(n=walk.nextNode()) a.push(n);
    return a;
  }

  // `layout--single` クラスが body に付与されている場合にのみ実行
  if (document.body.classList.contains('layout--single')) {
    // 記事本文の <p> タグ内のテキストノードを処理する関数
    const paragraphs = document.querySelectorAll('section.page__content p');
    paragraphs.forEach(function(paragraph) {
      const textNodes = getTextNodesUnder(paragraph);
      textNodes.forEach(function(textNode) {
        const text = textNode.nodeValue;
        const newText = text.replace(urlRegex, function(url) {
          try {
            const validUrl = new URL(url);
            return `<a href="${validUrl.href}" target="_blank" rel="noopener noreferrer">${validUrl.href}</a>`;
          } catch (e) {
            return url; // 有効なURLでない場合はそのままにする
          }
        });

        // newTextが変換された場合、古いテキストノードを削除して、新しい HTML を挿入
        if(newText !== text) {
          const span = document.createElement("span");
          span.innerHTML = newText;
          textNode.parentElement.replaceChild(span, textNode);
        }
      });
    });
  }
});

