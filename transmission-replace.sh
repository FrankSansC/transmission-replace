#!/usr/bin/env bash

# transmission-replace.sh
# https://github.com/FrankSansC/transmission-replace
#
# Replace all trackers URL from a .torrent file with a new one

set -eu


readonly RED="\e[1;31m"
readonly BLUE="\e[1;34m"
readonly RESET="\e[0m"

readonly TR_SHOW="transmission-show"
readonly TR_EDIT="transmission-edit"
readonly CMD_TO_CHECK=( "${TR_SHOW}" "${TR_EDIT}" )

readonly SHORT_OPTS="t:f:vh"
readonly LONG_OPTS="tracker:,file:,verbose,help"
OPTS=$(getopt --options "${SHORT_OPTS}" --longoptions "${LONG_OPTS}" -- "$@")
readonly OPTS

new_tracker=""
torrent_file=""
debug=0

print_usage() {
    printf "%s: [options]\n" "$0"
    printf "\nOptions:\n"
    printf " -t --tracker\t<url>\t\tTracker URL to replace with\n"
    printf " -f --file\t<torrent_file>\tSpecify a torrent file\n"
    printf " -v --verbose\t\t\tShow debug information\n"
    printf " -h --help\t\t\tShow this usage\n"
}

print_error() {
    printf "${RED}[Error] %s${RESET}\n" "$1"
}

print_debug() {
    if [ "${debug}" -ne 0 ]; then
        printf "${BLUE}[Debug] %s${RESET}\n" "$1"
    fi
}

# Check that transmission CLI tools are installed
for cmd in "${CMD_TO_CHECK[@]}"; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
        print_error "$(printf "%s is missing\n" "${cmd}")"
    fi
done

# Parse arguments
eval set -- "${OPTS}"
while :; do
    case "${1:-}" in
        -t | --tracker ) new_tracker="$2";  shift 2 ;;
        -f | --file    ) torrent_file="$2"; shift 2 ;;
        -v | --verbose ) debug=1;           shift 1 ;;
        -h | --help    ) print_usage;       exit;;
        --             ) shift;             break ;;
        *              ) print_error "$(printf "Unknown argument %s" "${1}")";;
    esac
done

# Check arguments
if [ -z "${new_tracker}" ]; then
    print_error "No tracker URL provided"
fi
if [ -z "${torrent_file}" ]; then
    print_error "No torrent file specified"
fi
if [ ! -e "${torrent_file}" ]; then
    print_error "$(printf "Can't find torrent file %s" "${torrent_file}")"
fi

# Extract trackers URL
trackers_url="$(${TR_SHOW} --trackers "${torrent_file}" | tr -d ' ' | { grep -E "https?" || true; })"
if [ -n "${trackers_url}" ]; then
    print_debug "$(printf "Found the following tracker(s) for %s:\n%s" "${torrent_file}" "${trackers_url}")"

    # Remove all of them
    readarray -t <<<"${trackers_url}"
    for url in "${MAPFILE[@]}"; do
        print_debug "$(printf "Remove tracker %s" "${url}")"
        "${TR_EDIT}" --delete "${url}" "${torrent_file}" >/dev/null
    done
fi

# Add the new tracker URL
print_debug "$(printf "Add tracker %s" "${new_tracker}")"
"${TR_EDIT}" --add "${new_tracker}" "${torrent_file}" >/dev/null

print_debug "Done!\n"
