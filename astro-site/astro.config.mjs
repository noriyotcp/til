// @ts-check
import { defineConfig } from 'astro/config'
import tailwindcss from '@tailwindcss/vite'
import sitemap from '@astrojs/sitemap'
import mdx from '@astrojs/mdx'
import rehypeSlug from 'rehype-slug'
import rehypeAutolinkHeadings from 'rehype-autolink-headings'
import expressiveCode from 'astro-expressive-code'
import siteConfig from './src/site.config'
import { pluginLineNumbers } from '@expressive-code/plugin-line-numbers'
import icon from 'astro-icon'
import {
  remarkDescription,
  remarkReadingTime,
  rehypeTitleFigure,
} from './src/settings-utils'
import { fromHtmlIsomorphic } from 'hast-util-from-html-isomorphic'
import rehypeExternalLinks from 'rehype-external-links'
import remarkDirective from 'remark-directive' /* Handle ::: directives as nodes */
import rehypeUnwrapImages from 'rehype-unwrap-images'
import { remarkAdmonitions } from './src/plugins/remark-admonitions' /* Add admonitions */
import remarkMath from 'remark-math' /* for latex math support */
import rehypeKatex from 'rehype-katex' /* again, for latex math support */
import remarkGemoji from './src/plugins/remark-gemoji' /* for shortcode emoji support */
import rehypePixelated from './src/plugins/rehype-pixelated' /* Custom plugin to handle pixelated images */
import react from '@astrojs/react'

// https://astro.build/config
export default defineConfig({
  site: siteConfig.site,
  base: '/til',
  trailingSlash: 'never',
  prefetch: true,
  vite: {
    // @ts-ignore - Type compatibility issue with Vite plugin
    plugins: [tailwindcss()],
    build: {
      // ビルドパフォーマンスの最適化
      target: 'es2020',
      minify: 'esbuild',
      // 並列処理の最適化
      rollupOptions: {
        // 並列処理数を最適化
        maxParallelFileOps: 8,
        external: [
          // Exclude non-blog directories and files
          /^\/projects\//,
          /^\/Rails\//,
          /^\/tmp\//,
          /^\/excludes\//,
          /^\/node_modules\//,
          /^\/_site\//,
          /\.sh$/,
          /vitest\.config\.js$/,
          /\.test\.js$/,
        ],
        output: {
          // コード分割の最適化
          manualChunks: {
            // React関連を別チャンクに分離
            'react-vendor': ['react', 'react-dom'],
            // GitHub calendar を別チャンクに分離
            'github-calendar': ['react-github-calendar'],
            // Satori関連（Social Cards）を別チャンクに分離
            'satori': ['satori', '@resvg/resvg-js', 'satori-html'],
          },
          // チャンクファイル名の最適化
          chunkFileNames: (chunkInfo) => {
            const facadeModuleId = chunkInfo.facadeModuleId
            if (facadeModuleId) {
              if (facadeModuleId.includes('github-calendar')) {
                return 'assets/github-calendar-[hash].js'
              }
              if (facadeModuleId.includes('react')) {
                return 'assets/react-[hash].js'
              }
              if (facadeModuleId.includes('satori')) {
                return 'assets/satori-[hash].js'
              }
            }
            return 'assets/[name]-[hash].js'
          },
        },
      },
    },
  },
  markdown: {
    remarkPlugins: [
      [remarkDescription, { maxChars: 200 }],
      remarkReadingTime,
      remarkDirective,
      remarkAdmonitions,
      remarkMath,
      remarkGemoji,
    ],
    rehypePlugins: [
      rehypeSlug,
      [
        rehypeAutolinkHeadings,
        {
          behavior: 'append',
          properties: {
            className: ['heading-anchor'],
          },
          content: fromHtmlIsomorphic(
            '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-link-icon lucide-link"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>',
            { fragment: true },
          ).children,
        },
      ],
      rehypeTitleFigure,
      [
        rehypeExternalLinks,
        {
          rel: ['noreferrer', 'noopener'],
          target: '_blank',
        },
      ],
      rehypeUnwrapImages,
      rehypePixelated,
      rehypeKatex,
    ],
  },

  integrations: [
    sitemap(),
    expressiveCode({
      themes: siteConfig.themes.include,
      useDarkModeMediaQuery: false,
      defaultProps: {
        showLineNumbers: false,
        wrap: false,
      },
      plugins: [pluginLineNumbers()],
    }), // Must come after expressive-code integration
    mdx(),
    icon(),
    react(),
  ],
  experimental: {
    contentIntellisense: true,
  },
})
