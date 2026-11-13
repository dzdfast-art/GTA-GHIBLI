# GTA GHIBLI — Public Repository Hardening

This plan keeps the repository **Public** so the connected development workflow can continue. It reduces accidental damage and secret exposure; it cannot stop people from viewing or forking public source code.

## Protections added in the repository

- `COPYRIGHT.md`: project rights notice and public-repository limitations.
- `docs/OWNERSHIP_AND_ASSET_REGISTER.md`: provenance and permission register for every shipped asset.
- `SECURITY.md`: private vulnerability-reporting guidance.
- `.github/workflows/security-audit.yml`: scheduled and change-triggered Gitleaks scan of files and Git history.
- `.github/workflows/godot-validation.yml`: existing Godot import, parse, interaction, mission and smoke-test checks.

## Owner actions in GitHub settings

The connected GitHub integration cannot currently administer branch-protection settings. The repository owner should review these settings in GitHub:

1. Open **Settings → Branches** (or **Rules → Rulesets**) and protect `main`.
2. Require a pull request before merging, with at least one approval if a second trusted reviewer is available.
3. Require the Godot validation and Repository security audit checks before merging, after each check has appeared at least once.
4. Require conversation resolution and prevent force pushes and branch deletion.
5. Keep administrator bypass disabled where practical, while preserving an owner recovery path.
6. Enable GitHub secret scanning and push protection if available for this account/repository.
7. Enable Dependabot alerts and security updates if dependency manifests are added.
8. Enable two-factor authentication or a passkey on the GitHub account; save recovery codes offline.
9. Review installed GitHub Apps and collaborators periodically. Grant only the minimum permissions needed.
10. Keep at least one dated backup outside the public repository, including original editable art, source documents, and evidence of authorship.

## Secrets and release hygiene

- Never put API keys, passwords, access tokens, signing keystores, private certificates, or database credentials in the repository.
- Store CI-only secrets in GitHub Actions Secrets; scope them to the narrowest environment and workflow that needs them.
- Do not expose secrets to workflows triggered by untrusted pull requests.
- Review Gitleaks findings manually. If a real secret was committed, revoke/rotate it immediately; deleting the line or rewriting Git history does not make an exposed credential safe.
- Keep Android signing keys and keystores outside Git, backed up securely, and never upload them as public workflow artifacts.
- Before each release, check asset provenance, third-party licences, attribution requirements, copyright notice, and build contents.
- Create versioned releases and preserve the source commit and build checksums. A checksum detects accidental changes only if the expected checksum is stored somewhere trustworthy.

## Game runtime integrity — realistic limits

A local manifest of file hashes can detect accidental corruption, but it is not strong anti-tamper protection if an attacker can change both the game and the manifest. Do not embed a secret master key in a client-side Android game. Strong verification requires a trusted signing key kept outside the repository and a verifiable signed release process. Even then, this raises the cost of tampering; it cannot prevent copying of public source.

## What is and is not enabled

| Control | Status |
|---|---|
| Public repository retained | Enabled |
| Copyright notice and asset register | Present |
| Security reporting policy | Added |
| Automated Gitleaks workflow | Added; awaiting first run |
| Godot validation workflow | Present |
| Branch protection / ruleset | Owner action required; connector lacks administration access |
| GitHub secret scanning / push protection | Owner action required; not verified as enabled |
| Dependabot alerts | Owner action required; not verified as enabled |
| Account 2FA / passkey | Owner action required; cannot be changed from repository files |
| Private off-site source/artwork backup | Owner action required |
| Signed Android releases | Future release task; not configured |

## Official GitHub guidance

- Branch protection: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches
- Secret scanning: https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning
- Push protection: https://docs.github.com/en/code-security/secret-scanning/introduction/about-push-protection
- Dependabot alerts: https://docs.github.com/en/code-security/dependabot/dependabot-alerts/about-dependabot-alerts
- Two-factor authentication: https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa

This document is an operational checklist, not a guarantee against copying or a substitute for legal advice.
