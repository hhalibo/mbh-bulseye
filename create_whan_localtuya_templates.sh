#!/bin/sh

BASE_DIR="/usr/share/hassio/homeassistant/custom_components/localtuya/templates"

############################################
# 检查目录是否存在
############################################
if [ -d "$BASE_DIR" ]; then
    echo "📁 目录已存在，跳过创建: $BASE_DIR"
else
    echo "📁 目录不存在，正在创建: $BASE_DIR"
    mkdir -p "$BASE_DIR" || {
        echo "❌ 创建目录失败: $BASE_DIR"
        exit 1
    }
fi

############################################
# 通用函数：文件存在就跳过
############################################
write_if_not_exists() {
    FILE_PATH="$1"

    if [ -f "$FILE_PATH" ]; then
        echo "⏭️  文件已存在，跳过: $(basename "$FILE_PATH")"
        return
    fi

    echo "📝 创建文件: $(basename "$FILE_PATH")"
    cat > "$FILE_PATH"
}

############################################
# whan_1gang_switch.yaml
############################################
write_if_not_exists "$BASE_DIR/whan_1gang_switch.yaml" << 'EOF'
# 1-gang switch with backlight

- switch:
    id: "24"
    friendly_name: "L1"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

- switch:
    id: "36"
    friendly_name: "Backlight"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

###############################################
#                 SELECTS                     #
###############################################

- select:
    id: "18"
    friendly_name: "switch_mode_l1"
    entity_category: config
    select_options:
      switch_1: "Switch Mode"
      scene_1: "Scene Mode"
EOF

############################################
# whan_2gang_switch.yaml
############################################
write_if_not_exists "$BASE_DIR/whan_2gang_switch.yaml" << 'EOF'
# 2-gang switch with backlight

- switch:
    id: "24"
    friendly_name: "L1"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

- switch:
    id: "25"
    friendly_name: "L2"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

- switch:
    id: "36"
    friendly_name: "Backlight"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

###############################################
#                 SELECTS                     #
###############################################

- select:
    id: "18"
    friendly_name: "switch_mode_l1"
    entity_category: config
    select_options:
      switch_1: "Switch Mode"
      scene_1: "Scene Mode"

- select:
    id: "19"
    friendly_name: "switch_mode_l2"
    entity_category: config
    select_options:
      switch_2: "Switch Mode"
      scene_2: "Scene Mode"
EOF

############################################
# whan_3gang_switch.yaml
############################################
write_if_not_exists "$BASE_DIR/whan_3gang_switch.yaml" << 'EOF'
# 3-gang switch with backlight

- switch:
    id: "24"
    friendly_name: "L1"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

- switch:
    id: "25"
    friendly_name: "L2"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

- switch:
    id: "26"
    friendly_name: "L3"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

- switch:
    id: "36"
    friendly_name: "Backlight"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

###############################################
#                 SELECTS                     #
###############################################

- select:
    id: "18"
    friendly_name: "switch_mode_l1"
    entity_category: config
    select_options:
      switch_1: "Switch Mode"
      scene_1: "Scene Mode"

- select:
    id: "19"
    friendly_name: "switch_mode_l2"
    entity_category: config
    select_options:
      switch_2: "Switch Mode"
      scene_2: "Scene Mode"

- select:
    id: "20"
    friendly_name: "switch_mode_l3"
    entity_category: config
    select_options:
      switch_3: "Switch Mode"
      scene_3: "Scene Mode"
EOF

############################################
# whan_4&6gang_switch.yaml
############################################
write_if_not_exists "$BASE_DIR/whan_4_6gang_switch.yaml" << 'EOF'
# 4 / 6-gang switch with backlight

- switch:
    id: "24"
    friendly_name: "L1"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

- switch:
    id: "25"
    friendly_name: "L2"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

- switch:
    id: "26"
    friendly_name: "L3"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

- switch:
    id: "27"
    friendly_name: "L4"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

- switch:
    id: "36"
    friendly_name: "Backlight"
    entity_category: None
    restore_on_reconnect: false
    is_passive_entity: false
    platform: "switch"

###############################################
#                 SELECTS                     #
###############################################

- select:
    id: "18"
    friendly_name: "switch_mode_l1"
    entity_category: config
    select_options:
      switch_1: "Switch Mode"
      scene_1: "Scene Mode"

- select:
    id: "19"
    friendly_name: "switch_mode_l2"
    entity_category: config
    select_options:
      switch_2: "Switch Mode"
      scene_2: "Scene Mode"

- select:
    id: "20"
    friendly_name: "switch_mode_l3"
    entity_category: config
    select_options:
      switch_3: "Switch Mode"
      scene_3: "Scene Mode"

- select:
    id: "21"
    friendly_name: "switch_mode_l4"
    entity_category: config
    select_options:
      switch_4: "Switch Mode"
      scene_4: "Scene Mode"
EOF

echo "✅ 脚本执行完成（已存在的文件未被覆盖）"
