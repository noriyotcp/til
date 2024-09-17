class Phone {
    constructor(modelName, price, weight) {
        this.modelName = modelName;
        this.price = price;
        this.weight = weight;
    }
    getModelName() {
        return `modelName: ${this.modelName}`;
    }
    getPrice() {
        return `price: ${this.price}`;
    }
    getWeight() {
        return `weight: ${this.weight}`;
    }
}
module.exports = Phone;
