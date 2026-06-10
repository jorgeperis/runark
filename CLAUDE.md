# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

- **Rails 8.1.3** / Ruby 3.4.2
- **Database**: SQLite in all environments (no PostgreSQL); Solid Queue, Solid Cache, and Solid Cable use separate SQLite databases — no Redis needed
- **Frontend**: Hotwire (Turbo + Stimulus), Propshaft, Importmaps — no Node.js/Webpack build step
- **CSS**: css-zero (lightweight utility CSS) — not Tailwind
- **Auth**: Custom Rails 8 auth using `has_secure_password` + `Session` model — no Devise
- **Email**: Resend gem for transactional email
- **Deployment**: Kamal 2 + Docker to a single server

## Commands

```bash
# Development
bin/dev                         # Start server (Procfile.dev)
bin/rails c                     # Console

# Testing
bundle exec rspec               # Full test suite
bundle exec rspec path/to/spec.rb:42  # Single test at line
bin/rails db:test:prepare       # Run before specs after schema changes

# Linting / security
bin/rubocop -f github           # Lint (GitHub output format)
bin/brakeman --no-pager         # Security scan
bin/importmap audit             # JS dependency audit

# Deployment
bin/kamal deploy                # Deploy via Kamal (requires RAILS_MASTER_KEY + Docker access)
```

## Code style

- Rubocop Omakase preset (`.rubocop.yml`); run `bin/rubocop -A` to auto-correct
- No comments unless the *why* is non-obvious

## Known quirks

- `MontlyDistance` (missing 'h') is an established typo throughout the codebase — models, routes, controllers, views all use it consistently; do not rename it
- Importmaps: add new JS libraries via `bin/importmap pin <package>`, not npm
- System tests require Chrome; in CI, Chrome is installed as part of the test job
- Production uses multi-DB: separate SQLite files for primary, cache, queue, and cable

## Git workflow

- Branch off `main` with feature branches; open a PR for all changes
- Commits on `main` trigger CI (scan → lint → test) and auto-deploy via GitHub Actions on success
