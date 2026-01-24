#!/bin/bash

# 定义 Home Assistant 容器名称（确保你的容器名正确）
CONTAINER_NAME="homeassistant"

# 检查容器是否运行
if ! docker ps --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
    echo "错误：Home Assistant 容器 '$CONTAINER_NAME' 未运行！"
    exit 1
fi

echo "✅ 进入 Home Assistant Docker 容器并执行命令..."

# 在容器内执行安装命令
docker exec -it "$CONTAINER_NAME" sh -c "
    apk add nano && \
    pip3 install --upgrade pip setuptools wheel && \
    pip3 install miservice qiniu asgiref pydub && \
    wget -q -O - https://install.hacs.xyz | bash
"

echo "✅ 创建额外文件/share/uptime_check.sh"

# 在容器内创建 uptime_check 文件和目录
docker exec -i "$CONTAINER_NAME" sh -c "cat >> /share/uptime_check.sh" << 'EOF'
#!/bin/bash
uptime_seconds=$(cut -d. -f1 /proc/uptime)
if [ "$uptime_seconds" -lt 200 ]; then
  echo "on"
else
  echo "off"
fi
EOF

# 在容器内执行安装命令
docker exec -it "$CONTAINER_NAME" sh -c "
    chmod +x /share/uptime_check.sh
"

echo "✅ 依赖安装完成，修改 Home Assistant 配置文件..."

# 追加内容到 configuration.yaml
docker exec -i "$CONTAINER_NAME" sh -c "cat >> /config/configuration.yaml" << 'EOF'

#light: !include lights.yaml
rest:
  - scan_interval: 3600
    resource_template: http://tool.bitefu.net/jiari/?d={{ now().strftime('%Y%m%d') }}
    sensor:   
      - name: cn_workdays
        value_template: >-
          {% if value == '0' %}
            工作日
          {% elif value == '1' %}
            假日
          {% elif value == '2' %}
            节日
          {% else %}
            unknown
          {% endif %}
command_line:
  - sensor:
      name: CPU Temperature
      unique_id: 6f03a5d6-b32c-473d-a21b-69fd82ed4b4d
      command: "cat /sys/class/thermal/thermal_zone0/temp"
      unit_of_measurement: "°C"
      value_template: '{{ value | multiply(0.001) | round(1) }}'
      scan_interval: 10
  - sensor:
      name: Host Uptime State
      unique_id: 6f03a5d6-c33c-473d-a21b-69fd82ed4b4d
      command: "bash /share/uptime_check.sh"
      scan_interval: 30  # 每30秒检查一次
  - sensor:
      name: ZRAM 使用率
      command: "awk 'NR==2 {printf(\"%.0f\", $4/$3*100)}' /proc/swaps"
      unit_of_measurement: "%"
      scan_interval: 60
  - sensor:
      name: 系统可用内存
      command: "awk '/MemAvailable/ {printf(\"%.0f\", $2/1024)}' /proc/meminfo"
      unit_of_measurement: "MB"
      scan_interval: 60
EOF

echo "✅ 配置已修改，创建额外文件和目录..."

# 在容器内创建 YAML 文件和目录
docker exec -it "$CONTAINER_NAME" sh -c "
    cd /config && \
    touch lights.yaml && \
    touch input_boolean.yaml && \
    touch customize.yaml && \
    touch known_devices.yaml && \
    touch ui-lovelace.yaml && \
    mkdir -p packages && \
    mkdir -p custom_components && \
    mkdir -p www
"

echo "✅ 额外文件和目录创建完成："
echo "   - lights.yaml"
echo "   - customize.yaml"
echo "   - known_devices.yaml"
echo "   - ui-lovelace.yaml"
echo "   - packages/"
echo "   - www/"

echo "✅ 请手动重启 Home Assistant 以应用更改。"
echo "👉 你可以执行以下命令手动重启："
echo "   docker restart $CONTAINER_NAME"

echo "✅ 脚本执行完成，不会自动重启 Home Assistant 🚀"
