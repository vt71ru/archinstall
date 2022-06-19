#!/usr/bin/env  bash

echo -e "Begin......"
directory=$(dirname "$(readlink -f "$0")") #git repository

echo "Directory:    "$directory

dir_config="${directory}"/etc/anarchy.conf
echo "Directory for config files:    "$dir_config

dir_scripts="${directory}"/lib
echo "Directory for script files:    "$dir_scripts

for script in "${dir_scripts}"/*.sh ; do
        [[ -e "${script}" ]] || break
        # shellcheck source=/usr/lib/anarchy/*.sh
        echo $script
        source "${script}"
done
