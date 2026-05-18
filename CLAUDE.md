# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Pelican site

### Commands

```bash
nix run                           # Start autoreload dev server at http://localhost:8000
nix build                         # Build static site to ./result/
nix develop                       # Enter dev shell (pelican, markdown, livereload)
pelican content                   # Build to output/ (within nix develop)
```

### Architecture

**Content:** `content/articles/` for blog posts, `content/pages/` for static pages. Pelican front matter uses `Title`, `Date`, `Slug`, `Tags`.

**URLs:** Articles at `/blog/{year}/{month}/{day}/{slug}/`, pages at `/{slug}/`. Configured in `pelicanconf.py`.

**Theme:** `themes/clean-blog/` — Jinja2 templates + pre-compiled plain CSS (no Less). Syntax highlighting uses the static `pygments.css` (default Pygments style with `.highlight` scope).

**Site variables** (`pelicanconf.py`): `TWITTER_USERNAME`, `GITHUB_USERNAME`, `EMAIL_ADDRESS`, `CURRENT_YEAR` are available in all templates. Social metadata is inlined here.

**Nix flake:** `flake.nix` defines three outputs:
- `packages.default` — builds the full site via `pelican … -s publishconf.py`, result is a store path of static HTML
- `apps.default` — `nix run` launches `pelican --autoreload --listen`
- `devShells.default` — shell with pelican, markdown, livereload

The `buildPhase` sets `PYTHONPATH=$PWD` so Pelican can import `pelicanconf.py` (which `publishconf.py` re-imports) inside the Nix sandbox.
