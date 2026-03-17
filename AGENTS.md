# AGENTS.md

## Cursor Cloud specific instructions

This is a minimal GitHub Pages site served at `itsjaydip.me`. The `README.md` is rendered as the homepage via Jekyll's `jekyll-readme-index` plugin (bundled in the `github-pages` gem).

### Running locally

```bash
bundle exec jekyll serve --host 0.0.0.0 --port 4000
```

The site will be available at `http://localhost:4000/`. Jekyll auto-regenerates on file changes.

### Key notes

- There is no `_config.yml`; GitHub Pages defaults apply automatically.
- The `github-pages` gem (specified in `Gemfile`) pins Jekyll and all plugins to the exact versions used by GitHub Pages, so local rendering matches production.
- The GitHub Metadata warning about API authentication is harmless for local development and can be ignored.
- There are no automated tests, linters, or build steps beyond Jekyll itself. Validation is done by visually inspecting the served site.
- System dependency: Ruby (3.x) and Bundler must be installed before `bundle install` will work. These are pre-installed in the Cloud Agent environment.
