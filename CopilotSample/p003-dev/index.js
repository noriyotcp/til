const Phone = require('./PhoneWithWeight');
const getPhoneBrand = require('./getPhoneBrand');

// Phoneクラスの動作確認
console.log('Phoneクラスの動作確認');
const myPhone = new Phone('iPhone 15', 124800, 171);
console.log(myPhone.getModelName());
console.log(myPhone.getPrice());
console.log(myPhone.getWeight());

// getPhoneBrand関数の動作確認
console.log('getPhoneBrand関数の動作確認');
console.log(getPhoneBrand('Apple'));
console.log(getPhoneBrand('Samsung'));
console.log(getPhoneBrand('Nokia'));