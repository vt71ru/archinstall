LANG="ru_RU.UTF-8"

title=" -| My linux |- "
backtitle=" -| Установщик Arch linux |- "

error="Ошибка:"

yes="Да"
no="Нет"

ok="Ок"
cancel="Отмена"

connection1="-| Проверка cоединения |- "
msg1="Проверка подключения к интернету"

set_locale() {
dialog --backtitle "$backtitle"  --title "$title" --infobox "\nSetup locale\n" 5 30
loadkeys ru
sed -i 's/^#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
locale-gen >> /dev/null
setfont cyr-sun16
}
