// 4.1.4 アロー関数式で関数を作る

type Human = {
  height: number;
  weight: number;
};

const calcBMI = ({ height, weight }: Human): number => {
  return weight / height ** 2
};

const uhyo: Human = { height: 1.84, weight: 72 };

console.log(calcBMI(uhyo));
