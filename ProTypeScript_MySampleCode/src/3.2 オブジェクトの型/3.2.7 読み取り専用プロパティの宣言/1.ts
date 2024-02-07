type MyObj = {
  readonly foo: number
}

const obj: MyObj = { foo: 123 };

// Cannot assign to 'foo' because it is a read-only property.
obj.foo = 0;

