#!/bin/bash
if [ $# -lt 3 -o "$1" == "-h" -o "$1" == "--help" ]; then
    exec >&2
    echo ""
    echo "Usage: $0 [ -h | --help ]"
    echo "       $0 name maxsize folder(s)..."
    echo ""
    echo "This program creates name.zip containing all files in the"
    echo "specified folders, unless their combined size exceeds maxsize."
    echo ""
    echo "When the combined file sizes exceed maxsize, this program"
    echo "will create name-1.zip, name-2.zip, and so on, with each"
    echo "archive containing at least one file, but archive contents"
    echo "not exceeding the maxsize. Each archive will contain full files."
    echo ""
    echo "Files are not reordered or sorted, so archive sizes may"
    echo "fluctuate wildly."
    echo ""
    exit 0
fi

# Base name of the zip archive to create
BASENAME="$1"
if [ -z "$BASENAME" ]; then
    echo "Empty zip archive name!" >&2
    exit 1
fi

# Maximum size for input files for each archive
case "$2" in
    *k|*K)           MAXTOTAL=$[ (${2//[^0-9]/} -0) * 1000 ] || exit $? ;;
    *kb|*kB|*Kb|*KB) MAXTOTAL=$[ (${2//[^0-9]/} -0) * 1024 ] || exit $? ;;
    *m|*M)           MAXTOTAL=$[ (${2//[^0-9]/} -0) * 1000000 ] || exit $? ;;
    *mb|*mB|*Mb|*MB) MAXTOTAL=$[ (${2//[^0-9]/} -0) * 1048576 ] || exit $? ;;
    *g|*G)           MAXTOTAL=$[ (${2//[^0-9]/} -0) * 1000000000 ] || exit $? ;;
    *gb|*gB|*Gb|*GB) MAXTOTAL=$[ (${2//[^0-9]/} -0) * 1073741824 ] || exit $? ;;
    *[^0-9]*)        echo "$2: Invalid maximum size." >&2
                     exit 1 ;;
    *)               MAXTOTAL=$[ $2 ] || exit $? ;;
esac
shift 2

find "$@" -type f -print0 | (

    # Current index, list of files, and total size of files
    INDEX=0
    FILES=()
    TOTAL=0

    while read -d "" FILE ; do
        SIZE=`stat -c %s "$FILE"` || continue

        NEWTOTAL=$[ SIZE + TOTAL ]
        if [ ${#FILES[@]} -lt 1 ] || [ $NEWTOTAL -le $MAXTOTAL ]; then
            FILES=("${FILES[@]}" "$FILE")
            TOTAL=$NEWTOTAL
            continue
        fi

        INDEX=$[ INDEX + 1 ]
        zip "$BASENAME-$INDEX.zip" "${FILES[@]}" || exit $?

        FILES=("$FILE")
        TOTAL=$SIZE
    done

    if [ ${#FILES[@]} -gt 0 ]; then
        if [ $INDEX -gt 0 ]; then
            INDEX=$[ INDEX + 1 ]
            zip "$BASENAME-$INDEX.zip" "${FILES[@]}" || exit $?
        else
            zip "$BASENAME.zip" "${FILES[@]}" || exit $?
        fi
    elif [ $INDEX -eq 0 ]; then
        echo "No files to zip specified." >&2
        exit 0
    fi

    echo "" >&2
    if [ $INDEX -gt 0 ]; then
        echo "Created $INDEX files:" >&2
        for I in `seq 1 $INDEX` ; do
            echo "    $BASENAME-$I.zip ($(stat -c %s "$BASENAME-$I.zip") bytes)" >&2
        done
    else
        echo "Created 1 file:" >&2
        echo "    $BASENAME.zip ($(stat -c %s "$BASENAME.zip") bytes)" >&2
    fi
    echo "" >&2
    exit 0
)
exit $?
