// 2.5.3 条件分岐(2)elseを使う

let userName = "Noriyo";

// if (条件式) 文1 else 文2
if (userName !== "") {
  console.log("ちゃんと名前があってえらい!");
} else {
  console.log("名前を入力してください!");
  userName = "名無し";
}

let num = 0;

if (num < 0) { // if (条件式)
  console.log("num は負の数です"); // 文1
} else if (num === 0) { // else 文2 に別の if が入った文
  console.log("num は0です");
} else {
  console.log("num は正の数です");
}

if (num < 0) { // if (条件式)
  console.log("num は負の数です"); // 文1
} else { // else 文2
  if (num === 0) { // if (条件式)
    console.log("num は0です");
  } else {
    console.log("num は正の数です");
  }
}


