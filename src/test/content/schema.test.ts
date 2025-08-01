import { describe, it, expect, vi } from 'vitest'
import { z } from 'zod'

// Mock the image function from Astro
const mockImage = () => z.string()

// Import the schema logic (we'll recreate it here for testing)
const createPostSchema = ({ image }: { image: () => z.ZodString }) =>
  z.object({
    title: z.string(),
    date: z.string().transform((str) => new Date(str)).optional(),
    published: z.coerce.date().optional(),
    last_modified_at: z.string().transform((str) => new Date(str)).optional(),
    tags: z.array(z.string()).optional().default([]),
    draft: z.boolean().optional().default(false),
    description: z.string().optional(),
    author: z.string().optional(),
    coverImage: z
      .strictObject({
        src: image(),
        alt: z.string(),
      })
      .optional(),
  })
  .transform((data) => {
    const normalizedDate = data.date || data.published
    if (!normalizedDate) {
      throw new Error('Either date or published field is required')
    }

    return {
      ...data,
      date: normalizedDate,
      published: data.published || normalizedDate
    }
  })

const createHomeSchema = ({ image }: { image: () => z.ZodString }) =>
  z.object({
    avatarImage: z
      .object({
        src: image(),
        alt: z.string().optional().default('My avatar'),
      })
      .optional(),
    githubCalendar: z.string().optional(),
  })

describe('Content Collection Schemas', () => {
  describe('Posts Schema', () => {
    const postSchema = createPostSchema({ image: mockImage })

    it('validates valid post with date field', () => {
      const validPost = {
        title: 'Test Post',
        date: '2024-01-01',
        tags: ['test', 'blog'],
        description: 'A test post',
      }

      const result = postSchema.parse(validPost)
      expect(result.title).toBe('Test Post')
      expect(result.date).toBeInstanceOf(Date)
      expect(result.published).toBeInstanceOf(Date)
      expect(result.tags).toEqual(['test', 'blog'])
      expect(result.draft).toBe(false)
    })

    it('validates valid post with published field', () => {
      const validPost = {
        title: 'Test Post',
        published: '2024-01-01',
        tags: ['test'],
      }

      const result = postSchema.parse(validPost)
      expect(result.title).toBe('Test Post')
      expect(result.date).toBeInstanceOf(Date)
      expect(result.published).toBeInstanceOf(Date)
    })

    it('prefers date over published when both are present', () => {
      const validPost = {
        title: 'Test Post',
        date: '2024-01-01',
        published: '2024-01-02',
      }

      const result = postSchema.parse(validPost)
      expect(result.date.getTime()).toBe(new Date('2024-01-01').getTime())
      expect(result.published.getTime()).toBe(new Date('2024-01-02').getTime())
    })

    it('applies default values correctly', () => {
      const minimalPost = {
        title: 'Test Post',
        date: '2024-01-01',
      }

      const result = postSchema.parse(minimalPost)
      expect(result.tags).toEqual([])
      expect(result.draft).toBe(false)
    })

    it('validates last_modified_at field', () => {
      const postWithModified = {
        title: 'Test Post',
        date: '2024-01-01',
        last_modified_at: '2024-01-02',
      }

      const result = postSchema.parse(postWithModified)
      expect(result.last_modified_at).toBeInstanceOf(Date)
      expect(result.last_modified_at?.getTime()).toBe(new Date('2024-01-02').getTime())
    })

    it('validates cover image structure', () => {
      const postWithCover = {
        title: 'Test Post',
        date: '2024-01-01',
        coverImage: {
          src: '/path/to/image.jpg',
          alt: 'Cover image',
        },
      }

      const result = postSchema.parse(postWithCover)
      expect(result.coverImage).toEqual({
        src: '/path/to/image.jpg',
        alt: 'Cover image',
      })
    })

    it('throws error when neither date nor published is provided', () => {
      const invalidPost = {
        title: 'Test Post',
        tags: ['test'],
      }

      expect(() => postSchema.parse(invalidPost)).toThrow('Either date or published field is required')
    })

    it('handles invalid date format gracefully', () => {
      const invalidPost = {
        title: 'Test Post',
        date: 'invalid-date',
      }

      const result = postSchema.parse(invalidPost)
      // JavaScript Date constructor creates Invalid Date for invalid strings
      expect(result.date.toString()).toBe('Invalid Date')
    })

    it('throws error for missing required title', () => {
      const invalidPost = {
        date: '2024-01-01',
      }

      expect(() => postSchema.parse(invalidPost)).toThrow()
    })

    it('validates draft field as boolean', () => {
      const draftPost = {
        title: 'Draft Post',
        date: '2024-01-01',
        draft: true,
      }

      const result = postSchema.parse(draftPost)
      expect(result.draft).toBe(true)
    })
  })

  describe('Home Schema', () => {
    const homeSchema = createHomeSchema({ image: mockImage })

    it('validates minimal home content', () => {
      const minimalHome = {}

      const result = homeSchema.parse(minimalHome)
      expect(result).toEqual({})
    })

    it('validates home with avatar image', () => {
      const homeWithAvatar = {
        avatarImage: {
          src: '/avatar.jpg',
          alt: 'My profile picture',
        },
      }

      const result = homeSchema.parse(homeWithAvatar)
      expect(result.avatarImage).toEqual({
        src: '/avatar.jpg',
        alt: 'My profile picture',
      })
    })

    it('applies default alt text for avatar', () => {
      const homeWithAvatar = {
        avatarImage: {
          src: '/avatar.jpg',
        },
      }

      const result = homeSchema.parse(homeWithAvatar)
      expect(result.avatarImage?.alt).toBe('My avatar')
    })

    it('validates GitHub calendar username', () => {
      const homeWithGithub = {
        githubCalendar: 'testuser',
      }

      const result = homeSchema.parse(homeWithGithub)
      expect(result.githubCalendar).toBe('testuser')
    })

    it('validates complete home configuration', () => {
      const completeHome = {
        avatarImage: {
          src: '/avatar.jpg',
          alt: 'Profile picture',
        },
        githubCalendar: 'testuser',
      }

      const result = homeSchema.parse(completeHome)
      expect(result).toEqual(completeHome)
    })
  })
})
