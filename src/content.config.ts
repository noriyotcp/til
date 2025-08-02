import { defineCollection, z } from 'astro:content'
import { glob } from 'astro/loaders'

const postsCollection = defineCollection({
  loader: glob({
    pattern: ['**/*.md', '**/*.mdx'],
    base: './src/content/posts'
    // Note: ignore patterns will be added when migrating Jekyll posts
  }),
  schema: ({ image }) =>
    z.object({
      title: z.string(),
      // Support both Jekyll 'date' field and existing Astro 'published' field
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
      if (!data.date && !data.published) {
        throw new Error('Either date or published field is required')
      }

      return {
        ...data,
        date: data.date || data.published,
        published: data.published || data.date,
      }
    }),
})

const homeCollection = defineCollection({
  loader: glob({ pattern: ['home.md', 'home.mdx'], base: './src/content' }),
  schema: ({ image }) =>
    z.object({
      avatarImage: z
        .object({
          src: image(),
          alt: z.string().optional().default('My avatar'),
        })
        .optional(),
      githubCalendar: z.string().optional(), // GitHub username for calendar
    }),
})

const addendumCollection = defineCollection({
  loader: glob({ pattern: ['addendum.md', 'addendum.mdx'], base: './src/content' }),
  schema: ({ image }) =>
    z.object({
      avatarImage: z
        .object({
          src: image(),
          alt: z.string().optional().default('My avatar'),
        })
        .optional(),
    }),
})

export const collections = {
  posts: postsCollection,
  home: homeCollection,
  addendum: addendumCollection,
}
