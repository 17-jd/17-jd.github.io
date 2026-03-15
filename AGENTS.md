# AGENTS.md

## Cursor Cloud specific instructions

This is a minimal **GitHub Pages** static site for the custom domain `itsjaydip.me`. The repository contains only a `README.md` and a `CNAME` file — there is no build system, no dependencies, no tests, and no linting configuration.

### Running the site locally

Serve the repo root with Python's built-in HTTP server:

```
python3 -m http.server 8000
```

Then browse `http://localhost:8000/` for the directory listing, or `http://localhost:8000/README.md` for the README content.

### Key caveats

- **No build step, linting, or tests exist** in this repository. There are no `package.json`, `Gemfile`, `go.mod`, or similar dependency files.
- GitHub Pages renders `README.md` via Jekyll in production, but the local Python HTTP server serves raw Markdown (no rendering). For full-fidelity local preview, Jekyll would need to be installed, but the repo has no Jekyll config.
- The `CNAME` file maps the GitHub Pages deployment to `itsjaydip.me`.
