# Security Policy

## Supported Versions

No version has been published to pub.dev yet. Until the first release, security fixes land on `main`. After it, fixes are provided for the latest released version.

| Version                  | Supported          |
| ------------------------ | ------------------ |
| `main`                   | :white_check_mark: |
| Latest pub.dev release   | :white_check_mark: |
| Older pub.dev releases   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues, discussions, or pull requests.**

Instead, report them privately through GitHub's [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability): go to the repository's **Security** tab and click **"Report a vulnerability"**.

If you cannot use that channel, email **security@passionfactory.ai** instead.

Please include:

- A description of the vulnerability and its impact
- Steps to reproduce, or a proof of concept
- Affected versions, and any known mitigations

The agent bridge (`snapshot`, `act`, `query`) lets software operate an app's components. Reports about it reaching a release build, or accepting a step that `allow` should have refused, are in scope.

## What to Expect

- We aim to acknowledge your report within **72 hours**.
- We will keep you informed of progress toward a fix and may ask for additional detail.
- Once a fix is released, we will credit you in the advisory unless you prefer to remain anonymous.

We ask that you give us a reasonable opportunity to address the issue before any public disclosure.
