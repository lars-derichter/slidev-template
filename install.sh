#!/usr/bin/env bash
#
# install.sh — turn a fresh clone of slidev-template into its own GitHub-hosted
# presentation repo, while keeping a link back to the template as `upstream`.
#
# It will:
#   - rename the template's remote to `upstream` (for pulling future updates)
#   - activate the chosen theme's starter deck (ldr or tm)
#   - create a new GitHub repo named after this folder (or --repository)
#   - set it as `origin`, push, and enable GitHub Pages
#   - add the live presentation URL to the top of README.md
#   - run `npm install` so you can start straight away
#
# Requires the GitHub CLI (`gh`), installed and authenticated.

set -euo pipefail

# --- helpers ---------------------------------------------------------------

# Colors only when stdout is a terminal.
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'
else
  BOLD=''; RED=''; GREEN=''; YELLOW=''; RESET=''
fi

info()  { printf '%s\n' "$*"; }
ok()    { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn()  { printf '%s⚠%s  %s\n' "$YELLOW" "$RESET" "$*" >&2; }
err()   { printf '%s✗ %s%s\n' "$RED" "$*" "$RESET" >&2; }
die()   { err "$*"; exit 1; }

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Bootstraps a new GitHub-hosted presentation from this Slidev template:
renames the template remote to `upstream`, creates a new repo, pushes it,
enables GitHub Pages, links the live URL in README.md, and runs `npm install`.

Options:
  -r, --repository <name>   Repository name to create (default: this folder's
                            name, cleaned for GitHub).
      --public              Create a public repo (skip the prompt).
      --private             Create a private repo (skip the prompt).
                            Note: GitHub Pages needs a public repo on free plans.
      --theme <ldr|tm>      Theme for the starter deck: ldr (personal) or
                            tm (Thomas More). Default: prompt; ldr when
                            not interactive.
      --no-install          Skip running `npm install` at the end.
  -h, --help                Show this help and exit.

Requirements:
  GitHub CLI (`gh`) installed and authenticated (`gh auth login`).
  See https://cli.github.com/
EOF
}

# --- flag parsing ----------------------------------------------------------

REPO_NAME=""
VISIBILITY=""        # "public" | "private" | "" (prompt)
THEME=""             # "ldr" | "tm" | "" (prompt)
RUN_INSTALL=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage; exit 0 ;;
    -r|--repository)
      [[ $# -ge 2 ]] || die "Option $1 requires a value."
      REPO_NAME="$2"; shift 2 ;;
    --repository=*)
      REPO_NAME="${1#*=}"; shift ;;
    --public)
      VISIBILITY="public"; shift ;;
    --private)
      VISIBILITY="private"; shift ;;
    --theme)
      [[ $# -ge 2 ]] || die "Option $1 requires a value."
      THEME="$2"; shift 2 ;;
    --theme=*)
      THEME="${1#*=}"; shift ;;
    --no-install)
      RUN_INSTALL=0; shift ;;
    *)
      err "Unknown option: $1"; echo; usage; exit 1 ;;
  esac
done

case "$THEME" in
  ""|ldr|tm) ;;
  *) die "Invalid value for --theme: '$THEME' (expected ldr or tm)." ;;
esac

# --- preflight checks ------------------------------------------------------

if ! command -v gh >/dev/null 2>&1; then
  err "GitHub CLI (\`gh\`) is not installed."
  cat >&2 <<'EOF'

Install it, then re-run this script:
  macOS:   brew install gh
  Other:   https://github.com/cli/cli#installation

After installing, sign in with:
  gh auth login
  Docs: https://cli.github.com/manual/gh_auth_login
EOF
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  err "You are not logged in to GitHub CLI."
  cat >&2 <<'EOF'

Authenticate, then re-run this script:
  gh auth login
  Docs: https://cli.github.com/manual/gh_auth_login
EOF
  exit 1
fi

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "Not inside a git repository. Run this from a clone of the template."

# We need an existing remote to turn into `upstream`.
if ! git remote get-url origin >/dev/null 2>&1 \
   && ! git remote get-url upstream >/dev/null 2>&1; then
  die "No \`origin\` or \`upstream\` remote found — nothing to base this on. Clone the template first."
fi

# --- resolve repo name -----------------------------------------------------

clean_name() {
  # Lowercase, non-allowed chars -> '-', collapse repeats, trim leading/trailing '-'.
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9._-]+/-/g; s/-+/-/g; s/^[-.]+//; s/[-.]+$//'
}

if [[ -z "$REPO_NAME" ]]; then
  REPO_NAME="$(basename "$(git rev-parse --show-toplevel)")"
fi
REPO_NAME="$(clean_name "$REPO_NAME")"
[[ -n "$REPO_NAME" ]] || die "Could not derive a valid repository name. Pass one with --repository."

LOGIN="$(gh api user --jq .login)"
[[ -n "$LOGIN" ]] || die "Could not determine your GitHub username via \`gh\`."
TARGET="$LOGIN/$REPO_NAME"
PAGES_URL="https://${LOGIN}.github.io/${REPO_NAME}/"

info "${BOLD}Repository:${RESET} $TARGET"
info "${BOLD}Pages URL:${RESET}  $PAGES_URL"

if gh repo view "$TARGET" >/dev/null 2>&1; then
  die "Repository $TARGET already exists on GitHub. Pick another name with --repository."
fi

# --- resolve visibility ----------------------------------------------------

if [[ -z "$VISIBILITY" ]]; then
  if [[ -t 0 ]]; then
    info ""
    info "GitHub Pages needs a ${BOLD}public${RESET} repo on free plans."
    read -r -p "Make the repository public? [Y/n] " answer
    case "${answer:-Y}" in
      [Nn]*) VISIBILITY="private" ;;
      *)     VISIBILITY="public" ;;
    esac
  else
    VISIBILITY="public"
  fi
fi
info "${BOLD}Visibility:${RESET} $VISIBILITY"

# --- resolve theme ---------------------------------------------------------

if [[ -z "$THEME" ]]; then
  if [[ -t 0 ]]; then
    info ""
    info "Themes: ${BOLD}ldr${RESET} (personal) or ${BOLD}tm${RESET} (Thomas More)."
    while :; do
      read -r -p "Which theme? [ldr/tm] " answer
      case "${answer:-ldr}" in
        [Ll]*) THEME="ldr"; break ;;
        [Tt]*) THEME="tm";  break ;;
        *)     warn "Please answer 'ldr' or 'tm'." ;;
      esac
    done
  else
    THEME="ldr"
  fi
fi
info "${BOLD}Theme:${RESET}      $THEME"

# --- activate theme starter ------------------------------------------------

TOPLEVEL="$(git rev-parse --show-toplevel)"
if [[ "$THEME" == "tm" ]]; then
  if [[ -f "$TOPLEVEL/slides-tm.md" ]]; then
    mv -f "$TOPLEVEL/slides-tm.md" "$TOPLEVEL/slides.md"
    ok "Activated the tm starter deck as slides.md."
  else
    info "tm starter already activated — skipping."
  fi
  rm -f "$TOPLEVEL/public/forest.jpg"
else
  rm -f "$TOPLEVEL/slides-tm.md" "$TOPLEVEL/public/demo.jpg"
  ok "Keeping the ldr starter deck as slides.md."
fi

THEME_PATHS=("$TOPLEVEL/slides.md" "$TOPLEVEL/slides-tm.md"
             "$TOPLEVEL/public/forest.jpg" "$TOPLEVEL/public/demo.jpg")
if [[ -n "$(git status --porcelain -- "${THEME_PATHS[@]}")" ]]; then
  git add -- "${THEME_PATHS[@]}"
  git commit -m "Use the $THEME theme starter" >/dev/null
  ok "Committed theme selection."
fi

# --- rename remote -> upstream --------------------------------------------

if git remote get-url upstream >/dev/null 2>&1; then
  ok "Remote \`upstream\` already exists — leaving it."
else
  git remote rename origin upstream
  ok "Renamed \`origin\` -> \`upstream\`."
fi

# Make sure `origin` is free so `gh repo create --remote=origin` can attach it.
if git remote get-url origin >/dev/null 2>&1; then
  git remote remove origin
fi

# --- create repo + set origin (no push yet) --------------------------------

info "Creating $VISIBILITY repository $TARGET …"
gh repo create "$TARGET" --"$VISIBILITY" --source=. --remote=origin
ok "Created repository and set it as \`origin\`."

gh repo edit "$TARGET" --homepage "$PAGES_URL" >/dev/null \
  && ok "Set repository homepage to the Pages URL." \
  || warn "Could not set the repository homepage (non-fatal)."

# --- enable GitHub Pages (before pushing) ----------------------------------

if gh api -X POST "repos/$TARGET/pages" -f build_type=workflow >/dev/null 2>&1; then
  ok "Enabled GitHub Pages (source: GitHub Actions)."
else
  warn "Could not enable GitHub Pages automatically."
  cat >&2 <<EOF
  Enable it manually once:
    Open: https://github.com/$TARGET/settings/pages
    Under "Build and deployment", set Source to "GitHub Actions".
  (On a free plan, Pages requires a public repository.)
EOF
fi

# --- add live link to README ----------------------------------------------

README="$(git rev-parse --show-toplevel)/README.md"
LINK_LINE="🔗 **Live presentation:** $PAGES_URL"

if [[ -f "$README" ]] && ! grep -qF "$PAGES_URL" "$README"; then
  tmp="$(mktemp)"
  awk -v link="$LINK_LINE" '
    BEGIN { done = 0 }
    {
      print
      if (!done && $0 ~ /^# /) {
        print ""
        print link
        done = 1
      }
    }
  ' "$README" >"$tmp"
  mv "$tmp" "$README"
  ok "Added live presentation link to README.md."
else
  info "README already references the Pages URL — skipping."
fi

# --- commit + push ---------------------------------------------------------

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if ! git diff --quiet -- "$README" 2>/dev/null; then
  git add "$README"
  git commit -m "Add hosted presentation link" >/dev/null
  ok "Committed README change."
fi

info "Pushing to origin/$BRANCH …"
git push -u origin "$BRANCH"
ok "Pushed. The deploy workflow will publish to Pages."

# --- npm install -----------------------------------------------------------

if [[ "$RUN_INSTALL" -eq 1 ]]; then
  info "Running npm install …"
  if npm install; then
    ok "Dependencies installed."
  else
    warn "npm install failed — run it manually before \`npm run dev\`."
  fi
fi

# --- done ------------------------------------------------------------------

cat <<EOF

${GREEN}${BOLD}Done!${RESET} Your presentation repo is ready.

  Repository: https://github.com/$TARGET
  Live deck:  $PAGES_URL
              (first deploy takes a minute — watch the Actions tab)
  Theme:      $THEME (slides.md)

Next steps:
  npm run dev        # start editing slides.md with live reload

Template updates:
  git fetch upstream && git merge upstream/$BRANCH   # pull theme/workflow updates
EOF
