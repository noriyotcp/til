// deno --allow-net emjis-deno.ts
// https://source.chromium.org/chromium/chromium/src/+/main:third_party/ced/src/util/languages/languages.cc;l=35
// language table はここにある。skinTone 一覧は https://www.emj.is/ にある
async function translateText(text: string, skinTone: string = "👋"): Promise<any> {
  const response = await fetch("https://www.emj.is/api/translate", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept-Language": "ja", // 日本語を優先
    },
    body: JSON.stringify({ text, skinTone }),
  });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  return await response.json();
}

async function main() {
  try {
    const originalText = "なるはやでお願いします";
    const translation = await translateText(originalText, "👋");
    console.log({ originalText, ...translation });
  } catch (error) {
    console.error("翻訳に失敗しました:", error);
  }
}

main();
