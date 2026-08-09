# Slidev template

A clean, minimal [Slidev](https://sli.dev) starter set up to deploy to GitHub
Pages.

## Start a new presentation from this template

Clone the template **into a folder named after your presentation** — that
folder name becomes the GitHub repo name by default — then run `install.sh`:

```bash
git clone https://github.com/lars-derichter/slidev-template.git my-presentation
cd my-presentation
./install.sh
```

The script:

- asks which theme to use (`ldr` or `tm`) and activates its starter deck as
  `slides.md`, removing the other starter and its demo image,
- renames the template's remote to `upstream` (so you can pull future updates),
- creates a new GitHub repo named after the folder,
- sets it as `origin` and pushes,
- enables GitHub Pages (source: GitHub Actions) — or prints instructions if it
  can't,
- adds the live presentation URL to the top of this README,
- runs `npm install`.

**Prerequisite:** the [GitHub CLI](https://cli.github.com/) (`gh`), installed
and authenticated (`gh auth login`).

**Flags:**

| Flag                      | Effect                                                |
| ------------------------- | ----------------------------------------------------- |
| `-r`, `--repository NAME` | Repo name to create, if different from the folder.    |
| `--public` / `--private`  | Set visibility (default: prompt; Pages needs public). |
| `--theme <ldr\|tm>`       | Choose the starter theme (default: prompt).           |
| `--no-install`            | Skip `npm install`.                                   |
| `-h`, `--help`            | Show usage.                                           |

**Pull later template updates** (theme, workflow, tooling):

```bash
git fetch upstream
git merge upstream/main
```

## Develop

```bash
npm install
npm run dev
```

Edit [slides.md](slides.md); the browser updates on save.

The repo starts with the ldr deck as `slides.md`; the tm starter lives in
[slides-tm.md](slides-tm.md) until `install.sh` runs. Preview it with:

```bash
npx slidev slides-tm.md --open
```

## Themes

Two custom themes are installed as pinned Git dependencies:

| Theme       | Package            | Repo                                                                    | Frontmatter  |
| ----------- | ------------------ | ----------------------------------------------------------------------- | ------------ |
| Personal    | `slidev-theme-ldr` | [ldr-slidev-theme](https://github.com/lars-derichter/ldr-slidev-theme)  | `theme: ldr` |
| Thomas More | `slidev-theme-tm`  | [tm-slidev-theme](https://github.com/lars-derichter/tm-slidev-theme)    | `theme: tm`  |

`install.sh` asks which one to use (or takes `--theme`) and activates that
theme's starter deck as `slides.md`, removing the other starter and its demo
image. Both packages stay in [package.json](package.json) — the unused
dependency is harmless.

Without `install.sh`, switch to the tm starter manually:

```bash
mv slides-tm.md slides.md   # optionally: rm public/forest.jpg
```

**Updating a theme.** The dependencies are pinned to tags (`#v1.1.0` /
`#v1.0.0`), so `npm update` will not move them. To pull in theme changes, tag
a new release in the theme repo (`git tag v1.2.0 && git push --tags`), bump
the pin in [package.json](package.json), and run `npm install`.

**Switching an existing deck's theme** takes more than editing `theme:` in
the frontmatter: the layout names differ (`two-cols-ldr` vs `two-cols-tm`;
only tm has the `toc` layout with its `hideInToc`/`level` keys and the
`color: white | orange | navy` colorways), and so do the accent classes
(ldr's `.sage`/`.maple` vs tm's `.teal`/`.green`/`.navy`). Use each theme's
example deck as the reference.

## Build & export

```bash
npm run build    # static site into dist/
npm run export   # PDF export
```

## Deploy to GitHub Pages

The workflow in [.github/workflows/deploy.yml](.github/workflows/deploy.yml)
builds and deploys on every push to `main`. Enable it once:

1. Push this repo to GitHub.
2. Go to **Settings → Pages → Build and deployment** and set **Source** to
   **GitHub Actions**.
3. Push to `main` (or run the workflow manually under the **Actions** tab).

The slides land at `https://<user>.github.io/<repo>/`. The `--base` flag in the
workflow uses the repository name automatically, so no extra config is needed.

Made with [Slidev](https://sli.dev).

&copy; Lars De Richter
