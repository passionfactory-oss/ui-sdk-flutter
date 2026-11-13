# Contributing

Thanks for your interest in contributing. This guide covers how to get from a clone to a merged pull request.

By participating, you agree to abide by our [Code of Conduct](./CODE_OF_CONDUCT.md). All documentation, code, comments, and commit messages in this repository are written in **English**.

## Getting started

The repository is a [pub workspace](https://dart.dev/tools/pub/workspaces), and `.fvmrc` pins the Flutter version. With [FVM](https://fvm.app):

```bash
git clone https://github.com/passionfactory-oss/ui-sdk-flutter.git
cd ui-sdk-flutter
fvm install
fvm flutter pub get
```

Read [ARCHITECTURE.md](./ARCHITECTURE.md) before changing code, and the [architecture decision records](./docs/adr/index.md) for why it is shaped that way.

## Development workflow

1. Create a branch from `main` (for example `feat/roving-focus` or `fix/issue-123`).
2. Keep each pull request to one logical change.
3. Run the checks below and make sure they pass. CI runs the same checks.
4. Open a pull request and fill out the template.

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
(cd packages/ui_sdk_flutter && fvm flutter test)
```

A change that alters a public API's name or shape, adds a component, or adds a dependency needs a maintainer's agreement first. Open a discussion before writing it.

## Commit messages

We follow [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): subject`, where `type` is one of `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, and so on. Breaking changes include a `BREAKING CHANGE:` footer. Pull requests are squash-merged, so the PR title becomes the commit on `main`.

## Pull requests

Start with an issue or a discussion, not a pull request. A drive-by AI-generated PR is cheap to write and expensive to review. Deciding what to build, and how, is the part we'd rather do with you up front.

Once a maintainer has agreed to take the change forward:

- Reference the issue your PR addresses (for example `Closes #123`).
- Use a Conventional Commits PR title.
- Make sure CI is green before requesting review.

## Reporting bugs and requesting features

| You want to…                     | File it as…      | Humans                                                                                              | Agents                                                                           |
| -------------------------------- | ---------------- | --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Report a bug or propose a fix    | an **Issue**     | [New issue](https://github.com/passionfactory-oss/ui-sdk-flutter/issues/new/choose)                 | [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE)                              |
| Request a feature or enhancement | a **Discussion** | [New discussion](https://github.com/passionfactory-oss/ui-sdk-flutter/discussions/categories/ideas) | [`.github/DISCUSSION_TEMPLATE/ideas.yml`](.github/DISCUSSION_TEMPLATE/ideas.yml) |

A well-framed problem is worth more to us than a finished PR. Send the clearest account of the bug, or the strongest case for the feature. Accepted proposals are promoted to issues before implementation, and if we take yours on, we credit you.

**Security vulnerabilities**: do not open a public issue. Follow [SECURITY.md](./SECURITY.md).
