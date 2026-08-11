# Rule tests

Golden-file tests for the rules in this repo, run through the actual
`srt-auto-edit` tool (requires a checkout at `../srt-auto-edit` for the
Docker image).

```
make build               # once, or after the tool changes
make test                # run fixtures, diff against tests/expected/
make generate-expected   # rebuild baselines after intentional rule changes
```

Workflow after editing rules: `make generate-expected`, review the git diff
in `tests/expected/` (that diff *is* the behavior change), then `make test`
and commit both.

## Fixtures

| File | Covers |
|------|--------|
| `clean.srt` | Nothing should change; expected output identical to input |
| `ads-and-credits.srt` | Credit/ad cue deletion; bare `my-subs.com` line sharing a cue with dialogue |
| `formatting.srt` | HTML/ASS tag stripping, season/episode cues, HTML entities |
| `spacing-punctuation.srt` | General spacing, hyphen, punctuation corrections |
| `false-positives.srt` | Dialogue that rules must NOT touch (see known issues) |
| `<Show Name>/s01e01.srt` | `only_if_match` rules; the glob matches on file *path*, so these live in show-named directories |

Conventions:

- Rules run per cue. A `delete` action removes the whole cue if any line
  matches; a cue emptied by `replace` rules is dropped.
- If every cue in a file is removed, the tool deletes the file. The runner
  encodes that as "no file in `tests/expected/`" — an absent expected file
  means deletion is the expected outcome.
- New rule? Add a cue that triggers it, plus a near-miss to
  `false-positives.srt` if the pattern is loose.
- Real-world mangled cues from actual subtitle files make better fixtures
  than hand-written ones — paste them in when a new rule is added.

## Known issues locked into the baseline

The expected outputs record *current* behavior, including known bugs. When a
rule is fixed, regenerate and the diff should show the improvement.

None currently — `false-positives.srt` passes through untouched.

## Surveying the library for a new rule

When judging how loose a pattern is, grep the real library at
`/mnt/media/TV` (see the mount command in `CLAUDE.md`). Paths there contain
spaces, so build a file list and feed it with `xargs -d '\n'` — a bare
`grep ... $(cat list)` word-splits every path and silently reports nothing:

```
find /mnt/media/TV -maxdepth 3 -name '*.srt' > /tmp/f.txt
grep -i sdh /tmp/f.txt | shuf -n 60 > /tmp/sdh.txt   # SDH files carry the [sound cues]
xargs -a /tmp/sdh.txt -d '\n' grep -h 'PATTERN'
```

A full sweep of all ~9400 files takes longer than a couple of minutes over
CIFS; a 60-file SDH sample is enough to size a pattern.
