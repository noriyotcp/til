function getPhoneBrand(name) {
    if (name === 'Apple') {
        return 'iPhone';
    } else if (name === 'Samsung') {
        return 'Galaxy';
    } else {
        return 'Unknown';
    }
}
module.exports = getPhoneBrand;