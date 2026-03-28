#!/bin/bash
# Telegram Proxy Fix - 快速诊断和修复脚本

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Telegram 代理诊断工具 ===${NC}\n"

# 1. 检查环境变量
echo -e "${YELLOW}[1/5] 检查环境变量${NC}"
if [ -n "$HTTPS_PROXY" ]; then
    echo -e "  ${GREEN}✓${NC} HTTPS_PROXY=$HTTPS_PROXY"
else
    echo -e "  ${RED}✗${NC} HTTPS_PROXY 未设置"
fi
echo

# 2. 检查代理软件运行状态
echo -e "${YELLOW}[2/5] 检查代理软件${NC}"
PROXY_FOUND=""
if lsof -iTCP -sTCP:LISTEN -P | grep -q "clash"; then
    echo -e "  ${GREEN}✓${NC} Clash Verge 正在运行"
    PROXY_FOUND="clash"
elif lsof -iTCP -sTCP:LISTEN -P | grep -q "v2ray"; then
    echo -e "  ${GREEN}✓${NC} V2Ray 正在运行"
    PROXY_FOUND="v2ray"
elif lsof -iTCP -sTCP:LISTEN -P | grep -q "surge"; then
    echo -e "  ${GREEN}✓${NC} Surge 正在运行"
    PROXY_FOUND="surge"
else
    echo -e "  ${RED}✗${NC} 未检测到常见代理软件"
fi
echo

# 3. 检测代理端口
echo -e "${YELLOW}[3/5] 检测代理端口${NC}"
COMMON_PORTS=(7890 7891 7897 7899 10808 10809 6152 6153)
AVAILABLE_PORT=""

for port in "${COMMON_PORTS[@]}"; do
    HTTP_CODE=$(curl -x http://127.0.0.1:$port -s -o /dev/null -w "%{http_code}" --connect-timeout 3 https://api.telegram.org 2>/dev/null || echo "000")
    if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "302" || "$HTTP_CODE" == "401" || "$HTTP_CODE" == "404" ]]; then
        echo -e "  ${GREEN}✓${NC} 端口 $port 可用"
        AVAILABLE_PORT=$port
    fi
done

if [ -z "$AVAILABLE_PORT" ]; then
    echo -e "  ${RED}✗${NC} 未检测到可用代理端口"
fi
echo

# 4. 测试 Telegram API 连接
echo -e "${YELLOW}[4/5] 测试 Telegram API${NC}"
if [ -n "$AVAILABLE_PORT" ]; then
    HTTP_CODE=$(curl -x http://127.0.0.1:$AVAILABLE_PORT -s -o /dev/null -w "%{http_code}" --connect-timeout 5 https://api.telegram.org 2>/dev/null || echo "000")
    if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "302" || "$HTTP_CODE" == "401" || "$HTTP_CODE" == "404" ]]; then
        echo -e "  ${GREEN}✓${NC} Telegram API 连接成功 (HTTP $HTTP_CODE)"
    else
        echo -e "  ${RED}✗${NC} Telegram API 连接失败"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} 跳过测试（无可用代理）"
fi
echo

# 5. 提供修复建议
echo -e "${YELLOW}[5/5] 修复建议${NC}"

if [ -n "$AVAILABLE_PORT" ]; then
    echo -e "  ${GREEN}检测到可用代理: http://127.0.0.1:$AVAILABLE_PORT${NC}"
    echo
    echo "执行以下命令设置代理："
    echo -e "  ${BLUE}export HTTPS_PROXY=http://127.0.0.1:$AVAILABLE_PORT${NC}"
    echo
    echo "或永久添加到 ~/.zshrc："
    echo -e "  ${BLUE}echo 'export HTTPS_PROXY=http://127.0.0.1:$AVAILABLE_PORT' >> ~/.zshrc && source ~/.zshrc${NC}"

    # 询问是否自动设置
    echo
    read -p "是否自动设置代理到 ~/.zshrc? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 移除旧的 HTTPS_PROXY 设置
        sed -i '' '/export HTTPS_PROXY=/d' ~/.zshrc 2>/dev/null || true
        # 添加新设置
        echo "export HTTPS_PROXY=http://127.0.0.1:$AVAILABLE_PORT" >> ~/.zshrc
        export HTTPS_PROXY=http://127.0.0.1:$AVAILABLE_PORT
        echo -e "${GREEN}✓ 代理已设置并生效${NC}"
    fi
else
    echo -e "  ${RED}未检测到可用代理${NC}"
    echo
    echo "请检查："
    echo "  1. 代理软件是否正在运行"
    echo "  2. 代理软件的端口设置"
    echo "  3. 是否需要开启 TUN/增强模式"
    echo
    echo "手动设置示例："
    echo -e "  ${BLUE}export HTTPS_PROXY=http://127.0.0.1:<你的代理端口>${NC}"
fi

echo
echo -e "${BLUE}=== 诊断完成 ===${NC}"
