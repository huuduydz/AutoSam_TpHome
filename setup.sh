#!/data/data/com.termux/files/usr/bin/bash

# =====================================================================
# TOOL REJOIN SETUP SCRIPT FOR TERMUX (OPTIMIZED 2026)
# =====================================================================

# Định nghĩa màu sắc ANSI
C_CYAN="\033[1;36m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_RED="\033[1;31m"
C_RESET="\033[0m"

echo -e "${C_CYAN}[*] Đang khởi tạo quá trình tối ưu & cài đặt môi trường Termux...${C_RESET}"

# 1. Dọn dẹp tiến trình apt/dpkg bị treo & xóa file lock
killall -9 apt apt-get dpkg dpkg-deb >/dev/null 2>&1 || true
rm -f /data/data/com.termux/files/usr/var/lib/dpkg/lock*
rm -f /data/data/com.termux/files/usr/var/cache/apt/archives/lock
rm -f /data/data/com.termux/files/usr/var/lib/apt/lists/lock

# 2. Đổi nguồn Mirror tốc độ cao (Tối ưu riêng cho CloudPhone / Termux Việt Nam)
mkdir -p /data/data/com.termux/files/usr/etc/apt/sources.list.d
cat << 'EOF' > /data/data/com.termux/files/usr/etc/apt/sources.list
deb https://termux.librehat.com/apt/termux-main stable main
deb https://mirrors.grimler.se/termux/termux-main stable main
EOF

# 3. Cài đặt các gói phụ thuộc cần thiết (Python, SQLite3, TSU Root, Curl, Procps, Ncurses)
export DEBIAN_FRONTEND=noninteractive
echo -e "${C_CYAN}[*] Đang cài đặt gói phụ thuộc (python, sqlite, tsu, curl, procps)...${C_RESET}"
dpkg --configure -a >/dev/null 2>&1 || true
apt update -y -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true >/dev/null 2>&1 || true
apt --fix-broken install -y >/dev/null 2>&1 || true
apt install python sqlite tsu curl ncurses-utils procps -y -o Dpkg::Options::="--force-confold"

# 4. Kiểm tra & Yêu cầu quyền bộ nhớ Termux (/sdcard)
if [ ! -d "$HOME/storage" ]; then
    echo -e "${C_YELLOW}[*] Đang yêu cầu quyền truy cập bộ nhớ SDCard (/sdcard)...${C_RESET}"
    termux-setup-storage >/dev/null 2>&1 || true
fi

# 5. Tải Tool Rejoin mới nhất
echo -e "${C_CYAN}[*] Đang tải bản Tool Rejoin mới nhất (hudy.py)...${C_RESET}"
curl -Ls https://raw.githubusercontent.com/huuduydz/AutoSam_TpHome/refs/heads/main/ToolRejoin -o ~/hudy.py
chmod +x ~/hudy.py

# 6. Thiết lập Alias tự động
if ! grep -q 'alias hudy=' ~/.bashrc 2>/dev/null; then
    echo 'alias hudy="python ~/hudy.py"' >> ~/.bashrc
    echo 'alias hudy4="python ~/hudy.py"' >> ~/.bashrc
fi

# Áp dụng Alias ngay cho phiên làm việc hiện tại
alias hudy="python ~/hudy.py" 2>/dev/null || true

echo -e "\n${C_GREEN}[✓] Setup & Tối ưu hóa môi trường hoàn tất thành công!${C_RESET}"
echo -e "${C_YELLOW}[i] Bạn có thể gõ lệnh: ${C_CYAN}hudy${C_YELLOW} hoặc ${C_CYAN}python ~/hudy.py${C_YELLOW} để bắt đầu.${C_RESET}\n"
