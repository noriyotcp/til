const getPhoneBrand = require('./getPhoneBrand');

test('returns iPhone when the brand is Apple', () => {
    expect(getPhoneBrand('Apple')).toBe('iPhone');
});

test('returns Galaxy when the brand is Samsung', () => {
    expect(getPhoneBrand('Samsung')).toBe('Galaxy');
});

test('returns Unknown when the brand is neither Apple nor Samsung', () => {
    expect(getPhoneBrand('Nokia')).toBe('Unknown');
});