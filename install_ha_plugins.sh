#!/bin/bash

# 定义 Home Assistant 容器名称（确保你的容器名正确）
CONTAINER_NAME="homeassistant"

# 检查容器是否运行
if ! docker ps --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
    echo "错误：Home Assistant 容器 '$CONTAINER_NAME' 未运行！"
    exit 1
fi

echo "✅ 开始在 Home Assistant 容器内执行插件安装..."

# 在容器内执行所有 Git 克隆和安装操作（保持在 /config 目录）
docker exec -it "$CONTAINER_NAME" sh -c "
    cd /config || exit;

    # 克隆并安装 ha_file_explorer
    git clone https://github.com/shaonianzhentan/ha_file_explorer --depth=1;
    cp -r ha_file_explorer/custom_components/ha_file_explorer custom_components;
    rm -rf ha_file_explorer;

    # 克隆并安装 websitechecker
    git clone https://github.com/mvdwetering/websitechecker --depth=1;
    cp -r websitechecker/custom_components/websitechecker custom_components;
    rm -rf websitechecker;

    # 克隆并安装 hass-edge-tts
    git clone https://github.com/hasscc/hass-edge-tts --depth=1;
    cp -r hass-edge-tts/custom_components/edge_tts custom_components;
    rm -rf hass-edge-tts;

    # 克隆并安装 SSHCommand
    git clone https://github.com/AlexxIT/SSHCommand --depth=1;
    cp -r SSHCommand/custom_components/ssh_command custom_components;
    rm -rf SSHCommand;

    # 克隆并安装 Node-Red
    git clone https://github.com/zachowj/hass-node-red --depth=1;
    cp -r hass-node-red/custom_components/nodered custom_components;
    rm -rf hass-node-red;

    # 克隆并安装 SmartIR
    git clone https://github.com/smartHomeHub/SmartIR --depth=1;
    cp -r SmartIR/custom_components/smartir custom_components;
    cp -r SmartIR/codes custom_components/smartir;
    rm -rf SmartIR;

    # 克隆并安装 panel_iframe
    git clone https://github.com/shaonianzhentan/panel_iframe --depth=1;
    cp -r panel_iframe/custom_components/panel_iframe custom_components;
    rm -rf panel_iframe;

    # 克隆并安装 iPhone Detect
    git clone https://github.com/mudape/iphonedetect --depth=1;
    cp -r iphonedetect/custom_components/iphonedetect custom_components;
    rm -rf iphonedetect;

    # 克隆并安装 ha_cloud_music
    git clone https://github.com/shaonianzhentan/ha_cloud_music --depth=1;
    cp -r ha_cloud_music/custom_components/ha_cloud_music custom_components;
    rm -rf ha_cloud_music;

    # 克隆并安装 LocalTuya
    git clone https://github.com/xZetsubou/hass-localtuya --depth=1;
    cp -r hass-localtuya/custom_components/localtuya custom_components;
    rm -rf hass-localtuya;

    # 克隆并安装 XiaomiGateway3
    git clone https://github.com/AlexxIT/XiaomiGateway3 --depth=1;
    cp -r XiaomiGateway3/custom_components/xiaomi_gateway3 custom_components;
    rm -rf XiaomiGateway3;

    # 克隆并安装 高德地图
    git clone https://github.com/dscao/gaode_maps --depth=1;
    cp -r gaode_maps/custom_components/gaode_maps custom_components;
    rm -rf gaode_maps;

    # 克隆并安装 小米 MIOT Raw
    git clone https://github.com/lekoOwO/xiaomi_miot_raw --depth=1;
    cp -r xiaomi_miot_raw/custom_components/xiaomi_miot_raw custom_components;
    rm -rf xiaomi_miot_raw;
"

echo "✅ 插件已安装到 Home Assistant 容器内的 custom_components！"
echo "❗ 你需要手动重启 Home Assistant 以应用这些新组件。"
echo "👉 手动重启命令：docker restart $CONTAINER_NAME"
echo "✅ 脚本执行完成 🚀"
