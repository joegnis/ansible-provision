#!/bin/bash
# Create a new profile called 'solarized' if there's no existing profile.
# Override if one exists.
# Then set it as the default profile
dconfdir=/org/gnome/terminal/legacy/profiles:
profile_ids=($(dconf list $dconfdir/ | grep ^: |\
               sed 's/\///g' | sed 's/://g'))

create_new_profile() {
    local profile_name="$1"
    local profile_ids_old="$(dconf read "$dconfdir"/list | tr -d "]")"
    local profile_id="$(uuidgen)"

    [ -z "$profile_ids_old" ] && local lb="["  # if there's no list
    [ ${#profile_ids[@]} -gt 0 ] && local delimiter=,  # if the list is empty
    dconf write $dconfdir/list \
        "${lb}${profile_ids_old}${delimiter} '$profile_id']"
    dconf write "$dconfdir/:$profile_id"/visible-name "'$profile_name'"
    echo $profile_id
}

duplicate_profile() {
    local from_profile_id="$1"; shift
    local to_profile_name="$1"; shift
    # If UUID doesn't exist, abort
    in_array "$from_profile_id" "${profile_ids[@]}" || return 1
    # Create a new profile
    local id=$(create_new_profile "$to_profile_name")
    # Copy an old profile and write it to the new
    dconf dump "$dconfdir/:$from_profile_id/" \
        | dconf load "$dconfdir/:$id/"
    # Rename
    dconf write "$dconfdir/:$id"/visible-name "'$to_profile_name'"
}

set_default_profile() {
    local profile_id="$1"
    dconf write $dconfdir/default "'$profile_id'"
}

get_profile_uuid() {
    # Print the UUID linked to the profile name sent in parameter
    local profile_name="$1"
    for i in ${!profile_ids[*]}; do
        if [[ "$(dconf read $dconfdir/:${profile_ids[i]}/visible-name)" == \
            "'$profile_name'" ]]; then
            echo "${profile_ids[i]}"
            return 0
        fi
    done
}

in_array() {
    local e
    for e in "${@:2}"; do [[ $e == $1 ]] && return 0; done
    return 1
}

dbus-launch
id="$(get_profile_uuid solarized)"  # Try to get UUID of 'solarized' profile
[ -z "$id" ] && id="$(create_new_profile solarized)"
set_default_profile "$id"
