#!/usr/bin/env bash
# Parse options
function in_array {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

usage="Usage: $(basename "$0") [-h|--help] [-d|--dry-run] add|set schema key \
item1 [item2 ...]
Add item/Set items to a GSetting array key.
...

Options:
-h, --help
    Display this help and exit

-d,  --dry-run
    Don't modify anything
...
"

getopt --test > /dev/null
if [[ $? -ne 4 ]]; then
    >&2 echo "I’m sorry, $(getopt --test) failed in this environment."
    exit 1
fi

## Define options: trailing colon means has an argument (customize this)
SHORT=h,d
LONG=help,dry-run

PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    >&2 echo getopt parse error
    exit 2
fi

eval set -- "$PARSED"

dry_run=no
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)
            echo "$usage"
            exit 0
            ;;
        -d | --dry-run)
            dry_run=yes
            ;;
        --)
            shift
            break
            ;;
    esac
    shift
done

if [ $# -lt 4 ]; then
    >&2 echo "$0: no enough arguments"
    exit 3
fi

cmd="$1"; shift
schema="$1"; shift
key="$1"; shift

# possible values for an array key returned by `gsettings`
# * empty: @as []
# * array of strings: ['foo', 'bar']
# * array of tuples: [('xkb', 'us'), ...]
array_str="$(gsettings get $schema $key)"
array_str="$( echo "$array_str" | sed 's/^@as \[//' | sed 's/^\[//' )"  # remove leading '@as [' or '['
array_str="$( echo "$array_str" | sed 's/]$//' )"  # remove trailing ']'

changed=no
case "$cmd" in
    add)
        # Get an array of current items
        string="$array_str"
        array=()
        while read -rd,; do
            i="$( echo $REPLY |\
                  sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//')"
            array+=("$i")
        done <<<"$string,"

        # Add remaining arguments to the array
        for item in "$@"; do
            # add quotes only if item is not a tuple, e.g. ('foo', 'bar')
            if [ "${item:0:1}" != '(' ] || [ "${item: -1}" != ')' ]; then
                item="'$item'"
            fi
            # if same item already exists, don't add it
            in_array "$item" "${array[@]}" && continue
            array+=("$item")
            changed=yes
        done

        # If nothing changes
        if [ $changed = no ]; then
            echo nothing changed
            exit
        fi
        ;;
    set)
        array=()
        # Add remaining arguments to the array
        for item in "$@"; do
            echo $item
            # add quotes only if item is not a tuple, e.g. ('foo', 'bar')
            if [ "${item:0:1}" != '(' ] || [ "${item: -1}" != ')' ]; then
                item="'$item'"
            fi
            array+=("$item")
        done
        ;;
    *)
        >&2 echo "$0: unknown subcommand \"$cmd\""
        exit 4
        ;;
esac

array_str="$( join_by ", "  "${array[@]}" )"
array_str="[$array_str]"

if [ $dry_run = no ]; then
    dbus-launch gsettings set $schema $key "$array_str"
else
    echo dbus-launch gsettings set $schema $key "$array_str"
fi
