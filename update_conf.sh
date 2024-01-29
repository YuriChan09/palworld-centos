#!/bin/bash

cat << EOF >> ~/.bashrc
pal_config=/home/steam/Steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
default_pal_config=/home/steam/Steam/steamapps/common/PalServer/DefaultPalWorldSettings.ini 

# modify PalWorldSettings.ini
update-pal-config() {
    local param=\$1
    local value=\$2
    sed -i "s/\(\$param=\)[^,]*/\1\$value/" "\$pal_config"
}
EOF


# 服务器配置文件没有内容，需要自行复制一份默认的配置文件供其使用
# 注意：尽管下面的cp命令使用了强制覆盖-f，但是系统可能会通过设置alias cp='cp -i'强制提示是否确认覆盖，遇到是否要覆盖的提示的话，输入y加回车确认

cp -f $default_pal_config $pal_config

source ~/.bashrc
