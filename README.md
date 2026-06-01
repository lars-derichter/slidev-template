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

## Theme

This deck uses the custom theme
[`slidev-theme-ldr`](https://github.com/lars-derichter/ldr-slidev-theme),
installed as a Git dependency (`theme: ldr` in [slides.md](slides.md)).

Git dependencies do **not** auto-update. After pushing new commits to the
theme, pull them into this deck with:

```bash
npm update slidev-theme-ldr   # re-fetches the tracked branch
```

If that doesn't pick up the change, force a clean re-fetch:

```bash
npm install github:lars-derichter/ldr-slidev-theme
```

For stable presentations, pin a tagged release instead of tracking the branch.
Tag the theme repo (`git tag v1.1.0 && git push --tags`), then set the
dependency in [package.json](package.json) to:

```json
"slidev-theme-ldr": "github:lars-derichter/ldr-slidev-theme#v1.1.0"
```

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
