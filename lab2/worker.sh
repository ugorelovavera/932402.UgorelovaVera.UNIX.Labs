#!/bin/sh

SHARED_DIR="${SHARED_DIR:-/shared}"
LOCK_FILE="$SHARED_DIR/.lock"
if [ -z "$CONTAINER_ID" ]; then
    CONTAINER_ID=$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n')
fi
echo "Container ID: $CONTAINER_ID"

SEQ=0
while true; do
    SEQ=$((SEQ + 1))
    exec 9>"$LOCK_FILE"
    flock -x 9
    N=1
    while [ -e "$SHARED_DIR/$(printf '%03d' "$N")" ]; do
        N=$((N + 1))
    done
    FILENAME=$(printf '%03d' "$N")
    echo "$CONTAINER_ID $SEQ" > "$SHARED_DIR/$FILENAME"
    echo "$CONTAINER_ID $SEQ $FILENAME" >> "$SHARED_DIR/.log"
    flock -u 9
    exec 9>&-
    echo "created: $FILENAME ($CONTAINER_ID $SEQ)"
    sleep 1
    
    exec 9>"$LOCK_FILE"
    flock -x 9
    rm -f "$SHARED_DIR/$FILENAME"
    flock -u 9
    exec 9>&-
    echo "removed: $FILENAME"
    sleep 1
done