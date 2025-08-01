#!/usr/bin/env node

import fs from 'fs'
import path from 'path'

const postsDir = path.join(process.cwd(), 'src/content/posts')

function processMarkdownFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8')

  // Check if file has frontmatter
  if (!content.startsWith('---')) {
    console.log(`Skipping ${filePath}: No frontmatter found`)
    return
  }

  // Split content into frontmatter and body
  const parts = content.split('---')
  if (parts.length < 3) {
    console.log(`Skipping ${filePath}: Invalid frontmatter format`)
    return
  }

  const frontmatter = parts[1]
  const body = parts.slice(2).join('---')

  // Check if draft already exists
  if (frontmatter.includes('draft:')) {
    console.log(`Skipping ${filePath}: draft metadata already exists`)
    return
  }

  // Add draft: false to frontmatter
  const updatedFrontmatter = frontmatter.trim() + '\ndraft: false'
  const updatedContent = `---\n${updatedFrontmatter}\n---${body}`

  fs.writeFileSync(filePath, updatedContent)
  console.log(`Updated ${filePath}: Added draft: false`)
}

function processDirectory(dirPath) {
  const items = fs.readdirSync(dirPath)

  for (const item of items) {
    const itemPath = path.join(dirPath, item)
    const stat = fs.statSync(itemPath)

    if (stat.isDirectory()) {
      // Recursively process subdirectories
      processDirectory(itemPath)
    } else if (item.endsWith('.md')) {
      processMarkdownFile(itemPath)
    }
  }
}

// Start processing
console.log('Adding draft: false metadata to markdown files...')
processDirectory(postsDir)
console.log('Done!')
