import { getCollection, type CollectionEntry } from 'astro:content'
import type { PostEntry, PostValidationResult, SearchablePost } from '../types'

/**
 * Get all valid posts, excluding drafts and validating schema
 */
export async function getValidatedPosts(): Promise<PostEntry[]> {
  try {
    const posts = await getCollection('posts')

    // Filter out drafts and validate posts
    const validPosts = posts.filter((post): post is PostEntry => {
      // Skip drafts
      if (post.data.draft) {
        return false
      }

      // Validate required fields
      const postDate = post.data.date || post.data.published
      if (!post.data.title || !postDate) {
        console.warn(`Post ${post.id} missing required fields (title or date/published)`)
        return false
      }

      return true
    })

    // Sort by date (newest first)
    return validPosts.sort((a, b) => {
      const dateA = a.data.date || a.data.published
      const dateB = b.data.date || b.data.published
      return new Date(dateB).getTime() - new Date(dateA).getTime()
    })
  } catch (error) {
    console.error('Error loading posts:', error)
    return []
  }
}

/**
 * Get posts by tag
 */
export async function getPostsByTag(tag: string): Promise<PostEntry[]> {
  const posts = await getValidatedPosts()
  return posts.filter(post =>
    post.data.tags?.some(postTag =>
      postTag.toLowerCase() === tag.toLowerCase()
    )
  )
}

/**
 * Get all unique tags from posts
 */
export async function getAllTags(): Promise<string[]> {
  const posts = await getValidatedPosts()
  const tagSet = new Set<string>()

  posts.forEach(post => {
    post.data.tags?.forEach(tag => tagSet.add(tag))
  })

  return Array.from(tagSet).sort()
}

/**
 * Validate a single post
 */
export function validatePost(post: any): PostValidationResult {
  const errors: string[] = []

  if (!post.data.title) {
    errors.push('Title is required')
  }

  const postDate = post.data.date || post.data.published
  if (!postDate) {
    errors.push('Date or published field is required')
  }

  if (postDate && isNaN(new Date(postDate).getTime())) {
    errors.push('Date must be a valid date')
  }

  if (post.data.tags && !Array.isArray(post.data.tags)) {
    errors.push('Tags must be an array')
  }

  return {
    isValid: errors.length === 0,
    errors: errors.length > 0 ? errors : undefined,
    post: errors.length === 0 ? post : undefined
  }
}

/**
 * Convert posts to searchable format
 */
export async function getSearchablePosts(): Promise<SearchablePost[]> {
  const posts = await getValidatedPosts()

  return Promise.all(
    posts.map(async (post) => {
      const { Content } = await post.render()

      return {
        title: post.data.title,
        content: post.body,
        tags: post.data.tags || [],
        url: `/posts/${post.slug}`,
        date: post.data.date || post.data.published,
        slug: post.slug
      }
    })
  )
}

/**
 * Format date for display
 */
export function formatDate(date: Date | string): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date

  return dateObj.toLocaleDateString('ja-JP', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

/**
 * Generate post URL from slug
 */
export function getPostUrl(slug: string): string {
  return `/posts/${slug}`
}

/**
 * Extract excerpt from post content
 */
export function getPostExcerpt(content: string, maxLength: number = 200): string {
  // Remove markdown syntax and HTML tags
  const plainText = content
    .replace(/#{1,6}\s+/g, '') // Remove headers
    .replace(/\*\*(.*?)\*\*/g, '$1') // Remove bold
    .replace(/\*(.*?)\*/g, '$1') // Remove italic
    .replace(/\[(.*?)\]\(.*?\)/g, '$1') // Remove links
    .replace(/<[^>]*>/g, '') // Remove HTML tags
    .replace(/\n+/g, ' ') // Replace newlines with spaces
    .trim()

  if (plainText.length <= maxLength) {
    return plainText
  }

  return plainText.substring(0, maxLength).replace(/\s+\S*$/, '') + '...'
}
