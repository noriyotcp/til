import { dirname } from 'path';
import { fileURLToPath } from 'url';
import { FlatCompat } from '@eslint/eslintrc';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

async function eslintConfig() {
  return [
    ...compat.extends('next/core-web-vitals', 'next/typescript'),
    {
      files: ['**/*.tsx', '**/*.ts'],
      rules: {
        'react/function-component-definition': [
          2,
          {
            namedComponents: 'arrow-function',
          },
        ],
      },
    },
  ];
}

export default eslintConfig();
