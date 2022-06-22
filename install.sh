#!/usr/bin/env  bash

init() {
echo -e "Begin..............................."
directory=$(dirname "$(readlink -f "$0")") #git repository

echo "Directory:    "$directory

dir_config="${directory}"/etc/install.conf
dir_scripts="${directory}"/lib

for script in "${dir_scripts}"/*.sh ; do
        [[ -e "${script}" ]] || break
        source "${script}"
done

source "${dir_config}"
config
language
source "${lang_file}" 
export reload=true
}

main() {
echo $lang_file
sleep 10
set_locale
check_connect
}

init
main
