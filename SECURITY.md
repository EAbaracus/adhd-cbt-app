# Security Policy

## Reporting a Vulnerability

Please report security vulnerabilities privately. **Do not open a public
issue for a security problem.**

Use GitHub's private reporting: go to the
[**Security** tab](https://github.com/EAbaracus/adhd-cbt-app/security/advisories/new)
and click **Report a vulnerability**. This opens a private advisory visible
only to the maintainer.

Please include:

- a description of the vulnerability and its impact,
- steps to reproduce (a proof of concept if possible),
- affected component (Flutter app, FastAPI backend, or content pipeline), and
- any suggested remediation.

## What to expect

- **Acknowledgement:** within 5 business days.
- **Assessment:** the report is triaged and you receive an initial severity
  assessment.
- **Resolution:** accepted vulnerabilities are fixed as a priority; you are
  told when a fix ships. Declined reports are explained.

Please give a reasonable window for a fix before any public disclosure.

## Scope

This policy covers the code in this repository — the local-first Flutter app,
the FastAPI backend, and the content pipeline. The app is local-first and does
not transmit personal health information to a server by default; issues that
could cause unintended data exposure are treated as high priority.
