---
name: init-project
description: Interactively initialize a new project from the garland flake templates. Asks language, project kind, lint strictness and optional add-ons (LibAFL fuzzing, Kani verification, CodeQL/semgrep CI, git hooks), then scaffolds, wires everything up and smoke tests the dev shell. Use when the user wants to start, create, scaffold or initialize a new project.
---

# init-project

Initialize a new project from the templates in the garland repo. Ask the questions
below with AskUserQuestion (combine independent questions into one call), then
execute. Use jj, never git. Do not use em dashes or emojis in generated text.

Snippet files referenced below live in this skill's `snippets/` directory.

## Step 1: Where and what

Determine the target directory: if the cwd is empty (or only VCS files), use it;
otherwise ask for a project name and `mkdir` a subdirectory. The directory name
becomes the project name via `just init`.

Ask:

1. **Language**: rust / zig / python / elixir / gleam / android / default (bare devenv).

2. **Language follow-ups**:
   - rust: kind = general binary / library / embedded / web service (axum).
     If embedded, also ask the target: thumbv6m-none-eabi (Cortex-M0) /
     thumbv7em-none-eabihf (Cortex-M4F/M7) / riscv32imac-unknown-none-elf / other.
   - python: application or library (decides `uv init` vs `uv init --lib`).
   - other languages: no follow-ups.

3. **Assurance level**: high assurance or scratch project.
   The rust template ships strict clippy lints by default, so this decides
   whether to keep or strip them (see step 3).

4. **Add-ons** (multiSelect, only offer what fits the language):
   - Fuzzing, LibAFL based (rust only)
   - Formal verification with Kani (rust only)
   - Nix build CI (GitHub Actions)
   - CodeQL CI (GitHub Actions)
   - Semgrep CI (GitHub Actions)
   - Git hooks (formatter/linter pre-commit hooks via devenv git-hooks)
   - Property testing (skip for zig, which has no mature library; see
     `references/property-testing.md`)

## Step 2: Scaffold

Pick the template flake: `path:$HOME/.garland` if that directory exists, else
`github:wjehee/.garland`. The `path:` form matters locally because the repo is a
jj colocated checkout and plain git-based flake refs miss uncommitted files.

```
nix flake init -t <flake>#<language>
```

Then apply each selected file-only add-on the same way (they only add new files,
so they compose): `#github-ci` for nix build CI, `#codeql-ci`, `#semgrep-ci`,
`#rust-fuzz` for fuzzing.

Initialize VCS and the project name:

```
jj git init --colocate
just init
```

If the fuzzing add-on was chosen, `just init` does not cover `fuzz/Cargo.toml`,
so additionally run: `sed -i "s/changeme/<name>/g" fuzz/Cargo.toml`.

Run the language's scaffolding step where the template needs one:
`uv init` or `uv init --lib` (python), `gleam new .` (gleam), `mix new .`
(elixir), `zig init` (zig). Android projects are created from Android Studio;
just tell the user.

## Step 3: Lint strictness

- rust, high assurance: keep the `[lints.clippy]` block the template ships in
  `Cargo.toml` (canonical copy: `snippets/rust-lints-high-assurance.toml`; use it
  to restore or extend the block if it is missing).
- rust, scratch: remove the `[lints.clippy]` block from `Cargo.toml` entirely.
- python, high assurance: append `snippets/python-ruff-high-assurance.toml` to
  `pyproject.toml` after `uv init`.
- python, scratch and all other languages: leave defaults.

## Step 4: Rust kind specifics

- library: rename `src/main.rs` to `src/lib.rs` and replace its content with an
  empty `pub` module or a minimal function. In `flake.nix` the naersk
  `buildPackage` still works for libraries; leave it.
- web service: `cargo add axum tokio --features tokio/full` (inside the dev
  shell, step 7, or edit Cargo.toml directly) and replace `src/main.rs` with a
  minimal axum server (bind 0.0.0.0:3000, one `/` route returning text).
- embedded: copy `snippets/rust-embedded/config.toml` to `.cargo/config.toml`
  and set the chosen target in it; make `src/main.rs` `#![no_std] #![no_main]`
  with a `panic_halt` handler and a `#[cortex_m_rt::entry]` (or riscv-rt) main;
  `cargo add` the matching runtime crates (cortex-m, cortex-m-rt, panic-halt for
  ARM); in `devenv.nix` set `languages.rust.targets = [ "<target>" ];` and add
  `probe-rs-tools` to `packages`. Skip the strict `arithmetic_side_effects` and
  `indexing_slicing` denies only if the user asked for scratch; high assurance
  keeps them even for embedded.

## Step 5: Add-on wiring (edits templates cannot do)

- **Fuzzing (LibAFL)**: the `rust-fuzz` template added a standalone `fuzz/`
  workspace. Uncomment the path dependency on the parent crate in
  `fuzz/Cargo.toml` and point `fuzz_one` in `fuzz/src/main.rs` at a real entry
  point of the crate if one exists yet. Add to the justfile:

  ```
  # Fuzz with LibAFL
  fuzz:
      cargo run --manifest-path fuzz/Cargo.toml --release
  ```

- **Kani**: append `snippets/rust-kani-proofs.rs` to the end of `src/main.rs`
  (or `src/lib.rs` for libraries) and add to the justfile:

  ```
  # One time Kani install (not in nixpkgs)
  kani-setup:
      cargo install --locked kani-verifier
      cargo kani setup

  # Prove Kani harnesses
  verify:
      cargo kani
  ```

- **Git hooks**: ensure `devenv.yaml` has the git-hooks input (the rust template
  already ships it; for other languages append `snippets/git-hooks-input.yaml`
  under `inputs:`). Then make sure `devenv.nix` has a `git-hooks.hooks` block:
  rust already ships rustfmt + clippy; for other languages merge in the matching
  fragment from `snippets/hooks-<language>.nix`.
  If git hooks were NOT selected but the language is rust, remove the
  `git-hooks.hooks` block from `devenv.nix` (scratch projects may not want
  hooks) only when the user chose scratch; high assurance keeps them.

- **Property testing**: follow `references/property-testing.md` for the
  language: add the dev dependency (proptest, hypothesis, stream_data, qcheck,
  kotest), create one example property test in the project's test location, and
  make sure the justfile has a `test` recipe that runs the suite.

- **CodeQL CI**: set the language matrix in `.github/workflows/codeql.yml` to
  the project language (rust, python, java-kotlin for android, etc.). Zig,
  gleam and elixir are not supported by CodeQL; if one of those was chosen,
  tell the user and remove the workflow again (or suggest semgrep instead).

## Step 6: Secrets

The templates ship `secretspec.toml` and `.sops.yaml` with placeholder
recipients. Remind the user to put their age public key in `.sops.yaml` before
using `secretspec set`. Do not create or touch any secret values.

## Step 7: Activate and smoke test

```
direnv allow
devenv shell -- true
```

If the shell builds, run the language's build/lint once (`just build` or
equivalent) where cheap. Report failures honestly; do not commit a broken
scaffold. On success:

```
jj commit -m "Initial project scaffold"
```

Finish by summarizing what was set up and any manual follow-ups (age keys, CI
repo secrets, fuzz harness wiring, `just kani-setup`).
