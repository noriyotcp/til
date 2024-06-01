// https://typescriptbook.jp/reference/object-oriented/class/fields

class Person {
  name: string | undefined;

  constructor(personName?: string) {
    this.name = personName ?? "Alice";
  }
}
const alice = new Person();
const bob = new Person("Bob");
console.log(`name is ${alice.name}`);
console.log(`name is ${bob.name}`);

