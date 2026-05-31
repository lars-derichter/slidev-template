# slidev-template

## What this project is

A clean, minimal [Slidev](https://sli.dev) starter that Lars clones per
presentation. The single deck lives in [slides.md](slides.md); the browser
hot-reloads on save.

## Commands

```bash
npm install
npm run dev      # dev server, opens browser
npm run build    # static site into dist/
npm run export   # PDF export
```

## Theme

The deck uses the custom theme `slidev-theme-ldr`, installed as a **Git
dependency** from `github:lars-derichter/ldr-slidev-theme` (see
[package.json](package.json)) and selected with `theme: ldr` in the
[slides.md](slides.md) frontmatter.

- Slidev themes ship `.vue`/CSS source and need **no build step**, so the Git
  install works as-is.
- Git deps do **not** auto-update. Pull new theme commits with
  `npm update slidev-theme-ldr`, or pin a tag (`#v0.1.0`) for stable decks.
  See the README "Theme" section.
- The theme repo has its own CLAUDE.md describing how to edit the theme itself.

## Deployment

[.github/workflows/deploy.yml](.github/workflows/deploy.yml) builds and deploys
to GitHub Pages on every push to `main`. The `--base` flag uses the repo name
automatically. One-time setup: **Settings → Pages → Source → GitHub Actions**.

## Conventions

- `dist/` is build output — not committed, safe to delete.
- Prettier with `prettier-plugin-slidev` formats `slides.md`.
- Output docs as Markdown.
