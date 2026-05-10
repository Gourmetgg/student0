CS 162 Homework Companion Documents
===================================

This directory contains enhanced, repository-specific English documentation for
the CS 162 homework assignments in this repository.

Artifacts
---------

- `cs162-homework-companion.md`: generated from the root README and every
  `hw-*` README. It is the printable companion guide.
- `test-completeness-audit.md`: a hand-written validation report that explains
  what was checked, which commands were blocked locally, and whether each
  homework's testing is complete.
- `build-pdfs.js`: a small Node script that rebuilds the companion guide,
  renders Markdown to HTML, and asks Chrome or Edge to print PDFs when a
  supported browser is available.

Generated PDF files, when present:

- `cs162-homework-companion.pdf`
- `test-completeness-audit.pdf`

Why these documents are better than a plain copy of the official pages
----------------------------------------------------------------------

These files do not duplicate the CS 162 website verbatim. They are original,
repo-specific guides that add:

- Direct mapping from official CS 162 tasks to this repository's files.
- Local build and run commands.
- Current test inventory.
- Evidence-based completeness verdicts.
- Detailed missing-test prompts that can be converted into scripts, Rust tests,
  C harnesses, or Pintos `.ck` tests.
- Environment notes for Windows, WSL, Linux, and the CS 162 VM.

Regenerate PDFs
---------------

From the repository root:

```sh
node docs/cs162-homework-guides/build-pdfs.js
```

The script requires Node and a local Chrome or Edge installation for PDF
printing. If no supported browser is available, it still writes the generated
Markdown and HTML files.
