# GTA GHIBLI — Security Policy

GTA GHIBLI is an original game project. This policy explains how to report security issues and how the project handles security-sensitive material.

## Supported development branch

- `main` is the primary development branch.
- Security fixes should be reviewed and tested before release.
- Do not publish exploit details, credentials, private keys, access tokens, or personal data in issues or pull requests.

## Reporting a vulnerability

Please do not open a public issue for an exploitable vulnerability.

Use GitHub's **Report a vulnerability** option on the repository Security tab if private vulnerability reporting is available. If it is unavailable, contact the repository maintainer through the contact method listed on the maintainer's GitHub profile. Include:
- A concise description and impact.
- Reproduction steps or a minimal proof of concept.
- Affected commit, file path, and version.
- Any suggested mitigation.

Do not include real user data or secrets in a report.

## Security boundaries

- The repository intentionally remains public. Public source code can be viewed and forked under GitHub's platform terms.
- Copyright notices and integrity checks do not prevent copying of publicly accessible files.
- Never commit passwords, API keys, access tokens, signing keys, keystores, private certificates, database credentials, or personal information.
- Store CI credentials in GitHub Actions Secrets or environment-scoped secrets, never in source files.
- Treat downloaded assets, plugins, addons, scripts, and generated files as untrusted until reviewed.
- Keep third-party licences and asset provenance in `docs/OWNERSHIP_AND_ASSET_REGISTER.md`.

## Response

The maintainer should acknowledge a credible report, assess impact, prepare a fix, validate it, and publish an advisory or release note when appropriate. Avoid exposing details before users have a reasonable opportunity to update.

## Important limitation

No client-side anti-tamper code can make a public repository impossible to copy or guarantee that a modified game build cannot be made. This policy is a practical security process, not a guarantee of theft prevention.
