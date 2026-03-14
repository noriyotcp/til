import { visit } from 'unist-util-visit'
import type { Plugin } from 'unified'
import type { Root } from 'hast'

const plugin: Plugin<[], Root> = () => {
  return function transformer(tree) {
    visit(tree, 'element', (el) => {
      if (el.tagName === 'img' && el.properties?.src) {
        const src = el.properties.src
        // If the src starts with /images/, prepend the base URL
        if (typeof src === 'string' && src.startsWith('/images/')) {
          el.properties.src = '/til' + src
        }
      }
    })
  }
}

export default plugin
