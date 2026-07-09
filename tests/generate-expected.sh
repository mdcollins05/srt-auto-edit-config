#!/bin/bash
set -euo pipefail

CONFIG=${CONFIG:-/config/srtautoedit.settings.yaml}
INPUT_DIR=/tests/input
EXPECTED_DIR=/tests/expected
WORK_DIR=$(mktemp -d)

while IFS= read -r -d '' rel; do
    rel=${rel#./}
    input_file="$INPUT_DIR/$rel"
    expected_file="$EXPECTED_DIR/$rel"
    tmp_file="$WORK_DIR/$rel"

    mkdir -p "$(dirname "$tmp_file")"
    cp "$input_file" "$tmp_file"
    python /app/srtautoedit.py -a -q -c "$CONFIG" "$tmp_file" 2>/dev/null || true

    if [ -f "$tmp_file" ]; then
        mkdir -p "$(dirname "$expected_file")"
        cp "$tmp_file" "$expected_file"
        echo "Generated: $rel"
    else
        # Tool deleted the file (all cues removed). No expected file = the
        # test runner treats deletion as the expected outcome.
        rm -f "$expected_file"
        echo "Generated: $rel (file deleted — deletion is the expected outcome)"
    fi
done < <(cd "$INPUT_DIR" && find . -name '*.srt' -print0 | sort -z)

echo ""
echo "Expected files written to $EXPECTED_DIR"
echo "Review the outputs and commit them to lock in the baseline."
