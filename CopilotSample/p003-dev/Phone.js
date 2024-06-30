class Phone {
    constructor(modelName, price) {
        this.modelName = modelName;
        this.price = price;
    }
    getModelName() {
        return `modelName: ${this.modelName}`;
    }
    getPrice() {
        return `price: ${this.price}`;
    }
}
module.exports = Phone;