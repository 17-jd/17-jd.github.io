# AGENTS.md

## Cursor Cloud specific instructions

This is a GitHub Pages personal website (`17-jd.github.io`, custom domain `itsjaydip.me`). The repo is very minimal — just `README.md` and `CNAME`.

### How it works

GitHub Pages uses Jekyll to render Markdown into HTML. The `README.md` is auto-converted to the site's index page via the `jekyll-readme-index` plugin (enabled by default on GitHub Pages).

### Local development

Prerequisites (installed by VM snapshot): Ruby, Jekyll, and `jekyll-readme-index` gem.

To serve the site locally (replicating GitHub Pages behavior):

```
cd /workspace && jekyll serve --host 0.0.0.0 --port 4000
```

The site requires a `_config.yml` that enables the `jekyll-readme-index` plugin to match GitHub Pages behavior. Without it, Jekyll shows a directory listing instead of rendering `README.md` as the index.

### Caveats

- There is no `Gemfile`, no build system, no tests, and no linter in this repo — it is purely static content.
- The `_site/` directory is Jekyll's build output and should not be committed.
- The `CNAME` file configures the custom domain (`itsjaydip.me`) for GitHub Pages.
