#!/usr/bin/env sh
set -eu

MAX_DRIFT="${MAX_DRIFT:-86400}"   # 允许最大偏差秒数，默认 24h

log() { printf "%s\n" "$*"; }

get_local_epoch() {
  date -u +%s
}

# 方式1：从 HTTP 响应头 Date: 获取（不依赖 TLS，最适合“时间错导致 HTTPS 失败”的场景）
get_net_epoch_from_http_date() {
  url="$1"
  # 只取响应头；兼容重定向；提取 Date: 行
  hdr_date="$(curl -fsSLI -L "$url" 2>/dev/null | tr -d '\r' | awk -F': ' 'tolower($1)=="date"{print $2; exit}')"
  [ -n "${hdr_date:-}" ] || return 1
  date -u -d "$hdr_date" +%s 2>/dev/null
}

# 方式2：从 worldtimeapi 的 JSON 里取 unixtime（HTTPS）
get_net_epoch_from_worldtimeapi_https() {
  json="$(curl -fsSL "https://worldtimeapi.org/api/timezone/Asia/Shanghai" 2>/dev/null)" || return 1
  echo "$json" | sed -n 's/.*"unixtime":[ ]*\([0-9]\+\).*/\1/p' | head -n1
}

# 依次尝试多个来源，直到拿到 NET_EPOCH
get_net_epoch() {
  # 优先 HTTP Date（更抗时间错、抗证书问题）
  for u in \
    "http://worldtimeapi.org/api/timezone/Asia/Shanghai" \
    "http://neverssl.com/" \
    "http://www.baidu.com/" \
    "http://1.1.1.1/"
  do
    e="$(get_net_epoch_from_http_date "$u" || true)"
    if [ -n "${e:-}" ]; then
      echo "$e"
      return 0
    fi
  done

  # 再尝试 HTTPS JSON（如果环境允许）
  e="$(get_net_epoch_from_worldtimeapi_https || true)"
  if [ -n "${e:-}" ]; then
    echo "$e"
    return 0
  fi

  return 1
}

LOCAL_EPOCH="$(get_local_epoch)"
NET_EPOCH="$(get_net_epoch || true)"

if [ -z "${NET_EPOCH:-}" ]; then
  log "❌ 无法获取互联网时间"
  log "   建议检查："
  log "   1) DNS:   cat /etc/resolv.conf"
  log "   2) 连通:  ping -c 1 1.1.1.1"
  log "   3) HTTP:  curl -I http://neverssl.com/"
  log "   4) HTTPS: curl -I https://www.google.com/  (若时间错，通常会失败)"
  exit 2
fi

DRIFT=$((LOCAL_EPOCH - NET_EPOCH))
ABS_DRIFT=${DRIFT#-}

log "🕒 本机 UTC 时间 : $(date -u -d "@$LOCAL_EPOCH" '+%F %T UTC')"
log "🌐 网络 UTC 时间 : $(date -u -d "@$NET_EPOCH" '+%F %T UTC')"
log "⏱  时间偏差     : ${ABS_DRIFT} 秒"

# 额外提示：如果本机时间在“未来很多”，APT 很容易出现 InRelease not valid yet
if [ "$DRIFT" -gt 0 ] && [ "$ABS_DRIFT" -gt "$MAX_DRIFT" ]; then
  log ""
  log "🚨 你现在的系统时间明显比互联网时间“更晚/在未来”"
  log "   这就是会触发：InRelease is not valid yet / Docker 源不可用 的典型原因"
  log "👉 修复建议："
  log "   - 有 chrony：  chronyc -a makestep"
  log "   - 或启用NTP：  timedatectl set-ntp true"
  exit 1
fi

if [ "$ABS_DRIFT" -gt "$MAX_DRIFT" ]; then
  log ""
  log "🚨 系统时间偏差过大（超过 ${MAX_DRIFT}s）"
  log "👉 这会导致 apt 仓库校验/安装失败（包括 Docker 源）"
  exit 1
fi

log "✅ 系统时间正常（偏差在允许范围内）"
exit 0
