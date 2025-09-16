# Contributing to Developer Stash

Thanks for your interest in improving this curated list. This guide explains how to propose changes, add new resources, and interpret the status taxonomy.

## Table of Contents

- [Scope](#scope)
- [Status Taxonomy](#status-taxonomy)
- [Adding or Updating a Resource](#adding-or-updating-a-resource)
- [Validation Checklist](#validation-checklist)
- [Automations](#automations)
- [Commit Message Guidelines](#commit-message-guidelines)
- [License](#license)

## Scope

Developer Stash focuses on resources that help software developers build, deploy, design, and learn effectively. Categories include (but are not limited to): blogs, books, build tools, cloud platforms, editors, frameworks, learning platforms, databases, and design/prototyping tools.

Out of scope: generic news sites unrelated to software, purely marketing landing pages, unmaintained personal projects (unless historically significant), and closed, paywalled content without a publicly discoverable overview page.

## Status Taxonomy

Each resource is labeled with a status to help readers gauge current relevance:

| Status     | Meaning                                                                                          | Typical Signals                                                                 |
| ---------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| core       | Widely adopted and actively maintained                                                           | Frequent releases, strong community, high ecosystem usage                       |
| niche      | Useful but serving a specialized or narrower audience                                           | Smaller community, specific use cases                                           |
| legacy     | Historically important; limited new adoption                                                     | Few recent releases, declining mindshare, used mainly in older systems          |
| deprecated | Discontinued / archived; kept for historical context                                            | Official sunset notice, archived repo                                           |
| emerging   | Rapidly growing and drawing adoption; may still be stabilizing                                  | Rising GitHub stars, conference talks, release velocity                         |
| declining  | Still available but adoption/momentum decreasing                                                | Reduced release cadence, migration recommendations from maintainers             |

When proposing a status, add a short rationale in the PR description if it’s not obvious.

## Adding or Updating a Resource

1. Edit `_data/resources.yml` only (do not hand-edit `README.md`).
1. Place the resource under the appropriate `categories` entry. If a category does not exist but seems broadly useful, open an issue first to discuss.
1. Provide:
   - `name` (official project or title)
   - `url` (canonical homepage or documentation root)
   - `description` (concise, neutral, value-focused; avoid marketing fluff)
   - `status` (see taxonomy)
   - Optional: `author`, `twitter`, or other fields if we extend the schema
1. Run the generator locally:

```bash
ruby scripts/generate_readme.rb
```

1. Stage and commit both the YAML update and regenerated README:

```bash
git add _data/resources.yml README.md
git commit -m "feat(resources): add <Name> as <status>"
```

1. Open a pull request describing the change and justification for status.

## Validation Checklist

Before submitting a PR:

Checklist:

- [ ] Link resolves (no obvious redirects to unrelated content)
- [ ] Description is <= ~140 characters and objective
- [ ] Status matches taxonomy definitions
- [ ] No duplicate of existing resource under another name
- [ ] Spelling and capitalization consistent
- [ ] `README.md` regenerated (CI will fail otherwise)

## Automations

Two GitHub Actions support quality:

1. `Generate README` workflow ensures `README.md` matches `_data/resources.yml`. If it fails, run the generator and recommit.
2. `Link Check` (weekly + on relevant PRs) validates external URLs. Fix or replace dead links when flagged.

### Optional Local Git Hook

To automatically regenerate the README when editing `_data/resources.yml` you can enable the provided pre-commit hook:

```bash
chmod +x scripts/pre-commit.sh
ln -sf ../../scripts/pre-commit.sh .git/hooks/pre-commit
```

Now any commit that stages the YAML (or the generator) will refresh and re-stage `README.md`.

## Commit Message Guidelines

Use a conventional style where practical:

docs: adjust description of PostgreSQL
 
```text
feat(resources): add Svelte as emerging
chore(resources): update status of Heroku to legacy
docs: adjust description of PostgreSQL
```

Prefixes: `feat`, `fix`, `chore`, `docs`, `refactor`, `ci`.

## License

By contributing, you agree that your contributions are licensed under the MIT License of this repository.

Thank you for helping keep Developer Stash relevant and high quality!
