#!/bin/bash

set -e

echo "============================================"
echo "  Evilginx 3.3.0 一键安装脚本"
echo "  适用于 Ubuntu 22.04.5 LTS"
echo "============================================"
echo ""

GO_VERSION="1.22.5"
INSTALL_DIR="/opt/evilginx"
GO_INSTALL_DIR="/usr/local"

if [ "$EUID" -ne 0 ]; then
    echo "[错误] 请使用 root 权限运行此脚本"
    echo "用法: sudo bash install.sh"
    exit 1
fi

echo "[1/6] 更新系统包..."
apt-get update -qq
apt-get install -y -qq git make wget tar >/dev/null 2>&1
echo "      完成"

echo "[2/6] 安装 Go ${GO_VERSION}..."
if [ -d "${GO_INSTALL_DIR}/go" ]; then
    rm -rf ${GO_INSTALL_DIR}/go
fi
wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
tar -C ${GO_INSTALL_DIR} -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz

export PATH=$PATH:${GO_INSTALL_DIR}/go/bin
export GOPATH=$HOME/go

if ! grep -q "GO_INSTALL_DIR/go/bin" /etc/profile; then
    echo "export PATH=\$PATH:${GO_INSTALL_DIR}/go/bin" >> /etc/profile
    echo "export GOPATH=\$HOME/go" >> /etc/profile
fi
echo "      完成 ($(${GO_INSTALL_DIR}/go/bin/go version))"

echo "[3/6] 克隆 Evilginx 仓库..."
if [ -d "${INSTALL_DIR}" ]; then
    rm -rf ${INSTALL_DIR}
fi
git clone -q https://github.com/kgretzky/evilginx2.git ${INSTALL_DIR}
echo "      完成"

echo "[4/6] 编译 Evilginx..."
cd ${INSTALL_DIR}
mkdir -p build
${GO_INSTALL_DIR}/go/bin/go build -o ./build/evilginx -mod=vendor main.go
echo "      完成"

echo "[5/6] 创建符号链接..."
ln -sf ${INSTALL_DIR}/build/evilginx /usr/local/bin/evilginx
chmod +x /usr/local/bin/evilginx
echo "      完成"

echo "[6/6] 创建配置目录..."
mkdir -p ~/.evilginx
mkdir -p ${INSTALL_DIR}/redirectors
echo "      完成"

echo ""
echo "============================================"
echo "  安装完成!"
echo "============================================"
echo ""
echo "安装路径: ${INSTALL_DIR}"
echo "配置目录: ~/.evilginx"
echo "Phishlets: ${INSTALL_DIR}/phishlets"
echo ""
echo "使用方法:"
echo "  普通模式:    sudo evilginx"
echo "  开发者模式:  sudo evilginx -developer"
echo "  调试模式:    sudo evilginx -debug"
echo ""
echo "注意: 运行 evilginx 需要 root 权限"
echo ""
