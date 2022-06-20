#!/usr/bin/env  bash

echo -e "Begin......"
directory=$(dirname "$(readlink -f "$0")") #git repository

echo "Directory:    "$directory

dir_config="${directory}"/etc/install.conf
#echo "Directory for config files:    "$dir_config
dir_scripts="${directory}"/lib
#echo "Directory for script files:    "$dir_scripts

for script in "${dir_scripts}"/*.sh ; do
        [[ -e "${script}" ]] || break
        source "${script}"
done

source "${dir_config}"
language
# shellcheck source=/usr/share/anarchy/lang
source "${lang_file}" # /lib/language.sh:43-60
export reload=true

set_locale
