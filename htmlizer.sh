#!/bin/bash

# Filename:      htmlizer.sh
# Description:   Exports source code to html files.
# Maintainer:    Jeremy Cantrell <jmcantrell@gmail.com>
# Last Modified: Thu 2010-03-18 00:06:20 (-0400)

# I needed a way to convert a bunch of source code into HTML for use in my
# website. Along with crontab, this gets me there.

# IMPORTS {{{1

source bashful-messages
source bashful-modes
source bashful-profile

# VARIABLES {{{1

SCRIPT_NAME=$(basename "$0" .sh)
SCRIPT_USAGE="Converts source code files to HTML."
SCRIPT_OPTIONS="
-C DIRECTORY    Use DIRECTORY for configuration.

-P PROFILE      Use PROFILE for action.
-N              Create new profile.
-L              List profiles.
-D              Delete profile.
-E              Edit profile.
"

interactive ${INTERACTIVE:-0}
verbose     ${VERBOSE:-0}

# PROFILE OPTIONS {{{1

PROFILE_DEFAULT="
directory=~/public_html/files
file=~/code/project/script
"

profile_init || error_exit "Could not initialize profiles."

# COMMAND-LINE OPTIONS {{{1

unset OPTIND
while getopts ":hifvqC:P:NLDE" option; do
    case $option in
        C) CONFIG_DIR=$OPTARG ;;

        P) PROFILE=$OPTARG ;;
        N) PROFILE_ACTION=create ;;
        L) PROFILE_ACTION=list ;;
        D) PROFILE_ACTION=delete ;;
        E) PROFILE_ACTION=edit ;;

        i) interactive 1 ;;
        f) interactive 0 ;;

        v) verbose 1 ;;
        q) verbose 0 ;;

        h) usage_exit 0 ;;
        *) usage_exit 1 ;;
    esac
done && shift $(($OPTIND - 1))

# PROFILE ACTIONS {{{1

if [[ $PROFILE_ACTION ]]; then
    if ! profile_$PROFILE_ACTION; then
        error_exit "Could not $PROFILE_ACTION profile(s)."
    fi
    exit 0
fi

# PROFILE CONTENT ACTIONS {{{1

OIFS=$IFS; IFS=$'\n'
for PROFILE in $(profile_list "$PROFILE"); do
    IFS=$OIFS

    if ! profile_load; then
        error "Could not load profile '$PROFILE'."
        continue
    fi

    mkdir -p "$directory"
    html_file=$directory/${file##*/}.html

    info -c "$file => $html_file"
    vim2html -vt "$file" "$html_file"
done
