#!/bin/bash
# Force to enable an installed GNOME shell extension
# Extracted from https://github.com/cyberalex4life/gnome-shell-extension-cl

function enable_extension() {

    arguments=("$@")

    for extension_to_enable in "${arguments[@]}"
    do

        if  [ "$(check_extension_in_all_extensions "$extension_to_enable")" = false ]
        then
            echo "'$extension_to_enable' is not installed."
            continue
        fi
        if  [ "$(check_extension_is_enabled "$extension_to_enable")" = true ]
        then
            echo "'$extension_to_enable' is already enabled."
            continue
        fi
        #if [ "$(version_greater)" = true ]
        #then
            #gnome-shell-extension-tool -e "$extension_to_enable"
            #continue
        #fi
        enabled_extensions_string=$(gsettings get org.gnome.shell enabled-extensions | tr -d "]")
        [ ! -z "$(echo $enabled_extensions_string | sed -e 's|^@as ||g' | tr -d '[')" ] && delimiter=,
        enabled_extensions_string="${enabled_extensions_string}${delimiter} '$extension_to_enable' ]"
        gsettings set org.gnome.shell enabled-extensions "$enabled_extensions_string"
        echo "'$extension_to_enable' enabled."

    done
    return
}

function check_extension_in_all_extensions() {
    extension_to_check=$1
    installed_extensions=( $(get_installed_extensions) )
    for installed_extension in "${installed_extensions[@]}"
    do
        if [ "$installed_extension" = "$extension_to_check" ]
        then
            echo true
            return
        fi
    done
    echo false
}

function get_installed_extensions() {
    global_installed_extensions=( $(find "/usr/share/gnome-shell/extensions/" \
                                         -maxdepth 1 -type d -name "*@*" -exec \
                                         /usr/bin/basename {} \;) )
    local_installed_extensions=( $(find "/home/$USER/.local/share/gnome-shell/extensions/" \
                                        -maxdepth 1 -type d -name "*@*" -exec \
                                        /usr/bin/basename {} \;) )

    if [ ${#local_installed_extensions[@]} -gt ${#global_installed_extensions[@]} ]
    then
        installed_extensions=( ${local_installed_extensions[@]} )
        test_extensions=( ${global_installed_extensions[@]} )
    else
        installed_extensions=( ${global_installed_extensions[@]} )
        test_extensions=( ${local_installed_extensions[@]} )
    fi
    for test_extension in "${test_extensions[@]}"
    do
        test_extension_not_doubled=true
        for installed_extension in "${installed_extensions[@]}"
        do
            if [ "$test_extension" = "$installed_extension" ]
            then
                test_extension_not_doubled=false
                break
            fi
        done
        if  [ $test_extension_not_doubled = true ]
        then
            test_extension=( $test_extension )
            installed_extensions=( "${installed_extensions[@]}" "${test_extension[@]}" )
            #echo ${test_extension[@]}
        fi
    done
    echo "${installed_extensions[@]}"
}

function check_extension_is_enabled() {
    extension_to_check=$1
    enabled_extensions=( $(gsettings get org.gnome.shell enabled-extensions | \
                               sed -e 's|^@as ||g' | tr -d "[",",","]","\'") )
    for enabled_extension in "${enabled_extensions[@]}"
    do
        if [ "$enabled_extension" = "$extension_to_check" ]
        then
            echo true
            return
        fi
    done
    echo false
}

enable_extension "$@"
