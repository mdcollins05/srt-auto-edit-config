# srt-auto-edit-config

Rules configuration for [srt-auto-edit](https://github.com/mdcollins05/srt-auto-edit),
which cleans subtitle (`.srt`) files: stripping ads and sync credits, fixing
formatting artifacts, and applying per-show corrections.

## Layout

- `srtautoedit.settings.yaml` — all rules, grouped by section:
  - **Formatting cleanup** — HTML/ASS tag removal, season/episode header cues
  - **Ad and credit removal** — subtitle sites, "synced by" credits, ripper tags
  - **Show specific corrections** — rules gated by `only_if_match` path globs
    (e.g. `*/Star Trek - Strange New Worlds*`), so they only apply to files
    whose path contains the show name
  - **General corrections** — spacing, hyphens, punctuation, music symbols
- `srtautoedit.rules.d/` — rules directory (planned split of `srtautoedit.settings.yaml`,
  not yet populated; see `CLAUDE.md`)

Rule semantics worth knowing: rules apply per subtitle cue with `re.MULTILINE`.
A `delete` action removes the *entire cue* if any line matches — prefer
anchored replace-with-empty patterns when a credit line can share a cue with
real dialogue. Cues left empty are dropped.

## Tests

Golden-file tests run every fixture in `tests/input/` through the real tool
(Docker image built from a sibling `../srt-auto-edit` checkout) with this
repo's rules, and diff the results against committed baselines in
`tests/expected/`.

```
make build               # once, or after the tool changes
make test                # run the suite
make generate-expected   # rebuild baselines after intentional rule changes
```

Workflow after editing rules: `make generate-expected`, review the git diff
in `tests/expected/` — that diff *is* the behavior change — then `make test`
and commit both. Fixture conventions and details: [tests/README.md](tests/README.md).
