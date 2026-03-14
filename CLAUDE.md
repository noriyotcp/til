# TIL Blog

Astro-based personal blog (TIL - Today I Learned). Deployed via GitHub Pages.

## Commands

- `npm run dev` — Dev server (localhost:4321)
- `npm run build` — Production build
- `npm test` — Run tests (vitest)
- `npm run format` — Format with prettier

## Architecture

- **Framework**: Astro with MDX support
- **Pages**: `src/pages/` — Home, Archive (`posts/[...page]`), Tags (`tags.astro`), Tag detail (`tags/[tag]/[...page]`)
- **Components**: `src/components/` — Astro components
- **Posts**: `src/content/posts/` — MDX/MD blog posts
- **Layouts**: `src/layouts/Layout.astro` — Main layout, includes HotkeyManager

### HotkeyManager (`src/components/HotkeyManager.astro`)

Global keyboard navigation system. Inline `<script>` with a single class.

- j/k: Navigate between posts (article elements on most pages, h2 + .post-item + "more posts" on /tags)
- Shift+J/K: Jump between tag headings (tags page only)
- Enter: Open focused item
- g h / g a / g t: Go to Home / Archive / Tags
- g p / g n: Previous / Next page
- b t: Back to top (resets focus)
- Escape: Close modals, clear focus
- ?: Help modal

Key design decisions:
- Browser focus on title link is the sole visual indicator (no custom outline)
- `syncFocusIndex()` keeps j/k index in sync with Tab-moved browser focus
- Enter only intercepts when activeElement is the title link or body (not tag links, Read buttons)

## Testing

Tests in `src/test/`. Run with `vitest`.

- `integration/hotkeys.test.ts` — HotkeyManager tests with mock DOM. **Note**: The test file contains a copy of the HotkeyManager class logic in the mock. Changes to HotkeyManager.astro must be mirrored in the test mock.
- `integration/search.test.ts` — Search component tests
- `content/schema.test.ts` — Content schema validation

## Conventions

- Ensure all files end with a newline character (EOF newline)
- Use prettier for formatting
- Commit messages: concise, focus on "why" not "what"
