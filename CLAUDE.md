# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Pelican site

### Commands

```bash
nix run                           # Start autoreload dev server at http://localhost:8000
nix build                         # Build static site to ./result/
nix flake check                   # Run all checks (html-validate, lychee, djlint, markdownlint)
nix develop                       # Enter dev shell (pelican, markdown, livereload, linters)
pelican content                   # Build to output/ (within nix develop)
```

### Architecture

**Content:** `content/articles/` for blog posts, `content/pages/` for static pages. Pelican front matter uses `Title`, `Date`, `Slug`, `Tags`.

**URLs:** Articles at `/blog/{year}/{month}/{day}/{slug}/`, pages at `/{slug}/`. Configured in `pelicanconf.py`.

**Theme:** `themes/clean-blog/` — Jinja2 templates + pre-compiled plain CSS (no Less). Syntax highlighting uses the static `pygments.css` (default Pygments style with `.highlight` scope).

**Site variables** (`pelicanconf.py`): `MASTODON_USERNAME`, `MASTODON_URL`, `GITHUB_USERNAME`, `EMAIL_ADDRESS`, `CURRENT_YEAR` are available in all templates. `MASTODON_URL` is derived from `MASTODON_USERNAME` automatically. Use `JINJA_GLOBALS` to expose variables inside content files processed by the jinja2content plugin.

**Nix flake:** `flake.nix` defines:
- `packages.default` — builds the full site via `pelican content -s pelicanconf.py`; result is a store path of static HTML
- `apps.default` — `nix run` launches `pelican --autoreload --listen`
- `devShells.default` — shell with pelican, markdown, livereload, and all linters
- `checks.*` — five lint/validation checks run by `nix flake check`:
  - `html-validate` — validates built HTML against `html-validate:recommended` (`linters/htmlvalidate.json`)
  - `lychee` — checks links in built HTML; offline mode only (`linters/lychee.toml`); `--root-dir` set to the site store path
  - `djlint` — lints Jinja2 templates in `themes/clean-blog/templates/` (`linters/djlintrc`)
  - `markdownlint` — lints Markdown in `content/` (`linters/markdownlint.json`)
  - `stylelint` — placeholder; all CSS is third-party so no rules are enforced (`linters/stylelintrc.json`)

The `buildPhase` sets `PYTHONPATH=$PWD` so Pelican can import `pelicanconf.py` inside the Nix sandbox.
