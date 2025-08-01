import siteConfig from '../../site.config'
import { Resvg } from '@resvg/resvg-js'
import type { APIContext, InferGetStaticPropsType } from 'astro'
import satori, { type SatoriOptions } from 'satori'
import { html } from 'satori-html'
import { resolveElementStyles } from '@utils'
import path from 'path'
import fs from 'fs'
import type { ReactNode } from 'react'
import { loadShikiTheme } from 'astro-expressive-code'

// ===== パフォーマンス最適化: 静的リソースを一度だけ読み込み =====

// フォントデータをキャッシュ
let fontDataCache: Buffer | null = null
const getFontData = () => {
  if (!fontDataCache) {
    const fontPath = path.resolve(
      './node_modules/@expo-google-fonts/jetbrains-mono/400Regular/JetBrainsMono_400Regular.ttf',
    )
    fontDataCache = fs.readFileSync(fontPath)
  }
  return fontDataCache
}

// アバター画像をキャッシュ
let avatarBase64Cache: string | null = null
const getAvatarBase64 = () => {
  if (avatarBase64Cache === null) {
    const avatarPath = path.resolve('./src/content/avatar.jpg')
    if (fs.existsSync(avatarPath)) {
      const avatarData = fs.readFileSync(avatarPath)
      avatarBase64Cache = `data:image/jpeg;base64,${avatarData.toString('base64')}`
    } else {
      avatarBase64Cache = '' // 空文字でキャッシュ
    }
  }
  return avatarBase64Cache || undefined
}

// テーマスタイルをキャッシュ
let themeStylesCache: { bg: string; fg: string; accent: string } | null = null
const getThemeStyles = async () => {
  if (!themeStylesCache) {
    const defaultShikiTheme = await loadShikiTheme(
      siteConfig.themes.default === 'auto'
        ? siteConfig.themes.include[0]
        : siteConfig.themes.default,
    )
    const styles = resolveElementStyles(defaultShikiTheme, {})
    themeStylesCache = {
      bg: styles.background,
      fg: styles.foreground,
      accent: styles.accent,
    }
  }
  return themeStylesCache
}

// Satoriオプションをキャッシュ
let ogOptionsCache: SatoriOptions | null = null
const getOgOptions = async (): Promise<SatoriOptions> => {
  if (!ogOptionsCache) {
    ogOptionsCache = {
      fonts: [
        {
          data: getFontData(),
          name: 'JetBrains Mono',
          style: 'normal',
          weight: 400,
        },
      ],
      height: 630,
      width: 1200,
      embedFont: true, // フォント埋め込みでパフォーマンス向上
    }
  }
  return ogOptionsCache
}

// ===== マークアップ生成の最適化 =====

const createMarkup = (title: string, pubDate: string | undefined, author: string, styles: { bg: string; fg: string; accent: string }, avatarBase64?: string) => {
  const { bg, fg, accent } = styles

  return html(`<div tw="flex flex-col max-w-full justify-center h-full bg-[${bg}] text-[${fg}] p-12">
    <div style="border-width: 12px; border-radius: 80px;" tw="flex items-center max-w-full p-8 border-[${accent}]/30">
      ${avatarBase64 ?
        `<div tw="flex flex-col justify-center items-center w-1/3 h-100">
            <img src="${avatarBase64}" tw="flex w-full rounded-full border-[${accent}]/30" />
        </div>` : ''}
      <div tw="flex flex-1 flex-col max-w-full justify-center items-center">
        ${pubDate ? `<p tw="text-3xl max-w-full text-[${accent}]">${pubDate}</p>` : ''}
        <h1 tw="text-6xl my-14 text-center leading-snug">${title}</h1>
        ${author !== title ? `<p tw="text-4xl text-[${accent}]">${author}</p>` : ''}
      </div>
    </div>
  </div>`)
}

type Props = InferGetStaticPropsType<typeof getStaticPaths>

export async function GET(context: APIContext) {
  try {
    const { pubDate, title, author } = context.props as Props

    // キャッシュされたリソースを取得
    const [ogOptions, themeStyles] = await Promise.all([
      getOgOptions(),
      getThemeStyles(),
    ])

    const avatarBase64 = getAvatarBase64()

    // SVG生成
    const svg = await satori(
      createMarkup(title, pubDate, author, themeStyles, avatarBase64) as ReactNode,
      ogOptions
    )

    // PNG変換（最適化設定）
    const resvg = new Resvg(svg, {
      fitTo: {
        mode: 'width',
        value: 1200,
      },
    })
    const png = resvg.render().asPng()

    return new Response(png, {
      headers: {
        'Cache-Control': 'public, max-age=31536000, immutable',
        'Content-Type': 'image/png',
        'Content-Length': png.length.toString(),
      },
    })
  } catch (error) {
    console.error('Social card generation error:', error)
    // エラー時はデフォルト画像を返す
    return new Response('', { status: 500 })
  }
}

export async function getStaticPaths() {
  // Social Cards生成を無効化（パフォーマンス優先）
  // デフォルト画像のみ生成
  return [
    {
      params: { slug: '__default' },
      props: { pubDate: undefined, title: siteConfig.title, author: siteConfig.author },
    },
  ]
}
