# slidev-template

## What this project is

A clean, minimal [Slidev](https://sli.dev) starter that Lars clones per
presentation. The single deck lives in [slides.md](slides.md); the browser
hot-reloads on save. An alternate starter deck for the Thomas More theme
lives in [slides-tm.md](slides-tm.md) — `install.sh` activates one of the
two and removes the other.

## Commands

```bash
npm install
npm run dev      # dev server, opens browser
npm run build    # static site into dist/
npm run export   # PDF export
```

## Themes

Two custom themes are installed as **pinned Git dependencies** (see
[package.json](package.json)): `slidev-theme-ldr`
(`github:lars-derichter/ldr-slidev-theme#v1.1.0`, `theme: ldr`) and
`slidev-theme-tm` (`github:lars-derichter/tm-slidev-theme#v1.0.0`,
`theme: tm`).

- `install.sh --theme ldr|tm` (or its prompt) activates one starter deck as
  `slides.md` and deletes the other starter plus its demo image. Both deps
  stay in package.json by design — do not prune the unused one.
- Slidev themes ship `.vue`/CSS source and need **no build step**, so the Git
  install works as-is.
- The deps are pinned to tags, so `npm update` won't move them. To pull theme
  changes: tag a new release in the theme repo, bump the `#vX.Y.Z` pin, run
  `npm install`. See the README "Themes" section.
- The themes are **not interchangeable** in an existing deck: layout names
  differ (`two-cols-ldr` vs `two-cols-tm`, tm-only `toc` with
  `hideInToc`/`level`, tm colorways via `color:`) and so do accent classes
  (`.sage`/`.maple` vs `.teal`/`.green`/`.navy`).
- Each theme repo has its own CLAUDE.md describing how to edit the theme
  itself.

## Deployment

[.github/workflows/deploy.yml](.github/workflows/deploy.yml) builds and deploys
to GitHub Pages on every push to `main`. The `--base` flag uses the repo name
automatically. One-time setup: **Settings → Pages → Source → GitHub Actions**.

## Conventions

- `dist/` is build output — not committed, safe to delete.
- Prettier with `prettier-plugin-slidev` formats `slides.md` and
  `slides-*.md`.
- Output docs as Markdown.
