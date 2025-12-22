#!/usr/bin/env bash
set -euo pipefail

TMPDIR="/tmp/v2raya"
REPO="v2rayA/v2rayA"

log() { echo -e "[v2raya-install] $*"; }
die() { echo -e "[v2raya-install] ❌ $*" >&2; exit 1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "缺少命令：$1"; }

# --- precheck ---
need_cmd curl
need_cmd bash
need_cmd systemctl
need_cmd uname
need_cmd awk
need_cmd sed

if [[ $EUID -ne 0 ]]; then
  # 不是 root 就确保 sudo 可用
  need_cmd sudo
  SUDO="sudo"
else
  SUDO=""
fi

mkdir -p "$TMPDIR"
cd "$TMPDIR"

log "Step 0: 安装依赖工具（wget/ca-certificates/apt-transport-https 等）"
$SUDO apt-get update -y
$SUDO apt-get install -y wget ca-certificates gnupg apt-transport-https

# --- get latest release tag from GitHub ---
log "Step 1: 查询 v2rayA 最新版本号（GitHub Releases）"
LATEST_TAG="$(
  curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]\+\)".*/\1/p' \
  | head -n1
)"

[[ -n "${LATEST_TAG}" ]] || die "无法获取最新版本号（可能是网络/DNS/被限流）"
LATEST_VER="${LATEST_TAG#v}"   # 去掉前缀 v
log "✅ 最新版本：${LATEST_TAG}"

# --- detect arch and choose deb asset name ---
ARCH="$(uname -m)"
case "$ARCH" in
  aarch64|arm64) DEB_ARCH="arm64" ;;
  x86_64|amd64)  DEB_ARCH="x64" ;;
  *)
    die "不支持的架构：$ARCH（脚本仅支持 aarch64/arm64 或 x86_64/amd64）"
    ;;
esac

DEB_NAME="installer_debian_${DEB_ARCH}_${LATEST_VER}.deb"
DEB_URL="https://github.com/v2rayA/v2rayA/releases/download/${LATEST_TAG}/${DEB_NAME}"
DEB_PATH="${TMPDIR}/${DEB_NAME}"

log "Step 2: 安装 v2ray（v2fly fhs-install）"
curl -fsSLO "https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh"
$SUDO bash install-release.sh

log "Step 3: 禁用并停止 v2ray 服务（避免与 v2rayA 冲突）"
$SUDO systemctl disable v2ray --now || true

log "Step 4: 下载 v2rayA 安装包：${DEB_URL}"
wget -O "${DEB_PATH}" "${DEB_URL}" || die "下载失败：${DEB_URL}"

log "Step 5: 安装 v2rayA（apt 安装本地 deb，会自动拉依赖）"
$SUDO apt-get install -y "${DEB_PATH}"

log "Step 6: 启动 v2rayA 服务"
$SUDO systemctl start v2raya.service --now

log "Step 7: 检查服务状态"
$SUDO systemctl --no-pager --full status v2raya.service || true

# 获取 eth0 IPv4 地址
ETH0_IP="$(
  ip -4 addr show eth0 2>/dev/null \
  | awk '/inet /{print $2}' \
  | cut -d/ -f1 \
  | head -n1
)"

if [[ -n "$ETH0_IP" ]]; then
  log "✅ 安装完成。v2rayA Web 界面：http://${ETH0_IP}:2017"
else
  log "⚠️ 安装完成，但未获取到 eth0 IP，请检查网络。"
  log "👉 默认 Web 界面：http://<设备IP>:2017"
fi

