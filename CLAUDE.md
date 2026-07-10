# Notes

## Tests

Golden-file tests in `tests/` run the real tool (Docker image built from a
sibling `../srt-auto-edit` checkout) against this repo's rules. `make test`
to run, `make generate-expected` after intentional rule changes (review the
git diff in `tests/expected/` — that diff is the behavior change). See
`tests/README.md` for fixture conventions and known bugs locked into the
baseline. If Docker isn't running: `sudo service docker start`.

## Rule change workflow (required for every rule change)

Any change to rules (add, edit, or remove) must come with test coverage
proving it works:

1. **Add fixtures first.** A cue that the rule should act on goes in the
   matching file under `tests/input/` (`ads-and-credits.srt`,
   `formatting.srt`, `spacing-punctuation.srt`); rules gated by
   `only_if_match` need a fixture under the show-named directory. If the
   pattern is at all loose (unanchored, optional groups, common words), also
   add a near-miss that must survive to `false-positives.srt`. Prefer the
   real-world cue text that motivated the change over invented examples.
2. **Regenerate baselines:** `make generate-expected`.
3. **Validate via the diff:** review `git diff tests/expected/` — it must
   show exactly the intended behavior change and nothing else. Unrelated
   cues changing means the pattern is too broad; fix the rule, not the
   baseline. Confirm the new fixture cue actually changed — an untouched
   fixture means the rule never fired.
4. **Run `make test`** — must be 9/9 (or new total) passing.
5. **Commit fixtures, baselines, and rule change together** so the diff
   documents the behavior.

When removing a rule, keep its fixtures — they prove remaining rules still
cover (or intentionally no longer cover) those cues.

## Planned: split rules into rules_directory

Move all rules out of `srtautoedit.settings.yaml` into `srtautoedit.rules.d/` (already configured as the rules directory). Proposed structure:

```
srtautoedit.rules.d/
├── 10-formatting.yaml        # HTML/ASS/WEBVTT tag removal, season/episode lines
├── 20-ads-and-credits.yaml   # Website names, sync credits, ripped-by lines, etc.
├── 30-general.yaml           # Spacing, hyphens, punctuation, music symbols, etc.
├── tv-moon-knight.yaml
├── tv-righteous-gemstones.yaml
├── tv-strange-new-worlds.yaml
└── tv-supacell.yaml
```

Notes:
- Subdirectories inside rules.d are NOT supported (code uses os.listdir, not os.walk)
- Numbered files apply before tv- files (digits sort before letters)
- srtautoedit.settings.yaml would keep only the rules_directory pointer, no rules

## Subtitle file access

Media files are on a CIFS share. Mount with:

```
sudo mkdir /mnt/media
sudo mount -t cifs -o ro,username=mdcollins05 //mattvirt/media/library /mnt/media
```
