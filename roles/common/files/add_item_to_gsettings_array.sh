#!/usr/bin/env bash
schema="$1"
key="$2"
item="$3"  # no single quotes around it

in_array() {
    local e
    for e in "${@:2}"; do [[ $e == $1 ]] && return 0; done
    return 1
}

array_str=$(gsettings get $schema $key)
array_str="${array_str:0:-1}"  # delete trailing ']'

if [ "$array_str" != "@as [" ]; then  # if not an empty array
    delimiter=,  # Will need a ',' to add the item

    # Get an array of current items
    string="$array_str"
    string="$( echo ${string:1} )"  # delete leading '['
    array=()
    while read -rd,; do
        i="$( echo $REPLY |\
              sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//')"  # delete spaces
        array+=("$i")
    done <<<"$string,"

    # if same item already exists, nothing will change
    if [ "${item:0:1}" != '(' ] || [ "${item: -1}" != ')' ]; then
      item="'$item'"
    fi
    in_array "$item" "${array[@]}" && exit
else
  item="'$item'"
fi

array_str="${array_str}${delimiter} $item ]"
dbus-launch gsettings set $schema $key "$array_str"
