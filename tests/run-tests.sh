#!/bin/bash
set -euo pipefail

CONFIG=${CONFIG:-/config/srtautoedit.settings.yaml}
INPUT_DIR=/tests/input
EXPECTED_DIR=/tests/expected
WORK_DIR=$(mktemp -d)
PASS=0
FAIL=0

while IFS= read -r -d '' rel; do
    rel=${rel#./}
    input_file="$INPUT_DIR/$rel"
    expected_file="$EXPECTED_DIR/$rel"
    tmp_file="$WORK_DIR/$rel"

    mkdir -p "$(dirname "$tmp_file")"
    cp "$input_file" "$tmp_file"
    python /app/srtautoedit.py -a -q -c "$CONFIG" "$tmp_file" 2>/dev/null || true

    # The tool deletes a file when every cue is removed. An absent expected
    # file means "deletion is the expected outcome".
    if [ ! -f "$tmp_file" ] && [ ! -f "$expected_file" ]; then
        echo "PASS: $rel (deleted, as expected)"
        PASS=$((PASS + 1))
    elif [ ! -f "$tmp_file" ]; then
        echo "FAIL: $rel (file was deleted, expected output exists)"
        FAIL=$((FAIL + 1))
    elif [ ! -f "$expected_file" ]; then
        echo "MISSING: $rel (no expected file — run 'make generate-expected' first)"
        FAIL=$((FAIL + 1))
    elif diff -q "$tmp_file" "$expected_file" >/dev/null 2>&1; then
        echo "PASS: $rel"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $rel"
        diff "$tmp_file" "$expected_file" || true
        FAIL=$((FAIL + 1))
    fi
done < <(cd "$INPUT_DIR" && find . -name '*.srt' -print0 | sort -z)

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
