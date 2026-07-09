# Notes

## Tests

Golden-file tests in `tests/` run the real tool (Docker image built from a
sibling `../srt-auto-edit` checkout) against this repo's rules. `make test`
to run, `make generate-expected` after intentional rule changes (review the
git diff in `tests/expected/` — that diff is the behavior change). See
`tests/README.md` for fixture conventions and known bugs locked into the
baseline. If Docker isn't running: `sudo service docker start`.

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
