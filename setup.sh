#!/data/data/com.termux/files/usr/bin/bash

# =====================================================================
# TOOL REJOIN SETUP SCRIPT FOR TERMUX (HIGH-SPEED & VISIBLE PROGRESS)
# =====================================================================

C_CYAN="\033[1;36m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_RED="\033[1;31m"
C_RESET="\033[0m"

echo -e "${C_CYAN}[*] Đang kiểm tra & khởi tạo môi trường Termux...${C_RESET}"

# 1. Dọn dẹp tiến trình apt/dpkg bị treo & xóa file lock cũ
killall -9 apt apt-get dpkg dpkg-deb >/dev/null 2>&1 || true
rm -f /data/data/com.termux/files/usr/var/lib/dpkg/lock*
rm -f /data/data/com.termux/files/usr/var/cache/apt/archives/lock
rm -f /data/data/com.termux/files/usr/var/lib/apt/lists/lock

# 2. Yêu cầu quyền bộ nhớ (Thông báo rõ ràng tránh treo chờ popup)
if [ ! -d "$HOME/storage" ]; then
    echo -e "${C_YELLOW}[!] NẾU HỆ ĐIỀU HÀNH HIỆN POPUP HỎI QUYỀN BỘ NHỚ -> HÃY BẤM 'CHO PHÉP' (ALLOW)...${C_RESET}"
    termux-setup-storage
    sleep 2
fi

# 3. Chạy script đổi mirror Termux
echo -e "${C_CYAN}[*] Đang thiết lập mirror Termux tối ưu...${C_RESET}"
. <(curl -Ls https://raw.githubusercontent.com/huuduydz/AutoSam_TpHome/refs/heads/main/termux-change-repo.sh)

# 4. Cập nhật gói hệ thống & cài đặt phụ thuộc
export DEBIAN_FRONTEND=noninteractive
echo -e "${C_CYAN}[*] Đang tải & cài đặt gói phụ thuộc (python, sqlite, tsu, curl, procps)...${C_RESET}"
echo -e "${C_YELLOW}[i] Quá trình này tải khoảng 30-50MB, vui lòng chờ trong giây lát...${C_RESET}"

pkg update -y -o Dpkg::Options::="--force-confold"
pkg install python sqlite tsu curl ncurses-utils procps -y -o Dpkg::Options::="--force-confold"

# 5. Tải Tool Rejoin mới nhất
echo -e "${C_CYAN}[*] Đang tải file script Tool Rejoin (hudy.py)...${C_RESET}"
curl -Ls https://raw.githubusercontent.com/huuduydz/AutoSam_TpHome/refs/heads/main/test-rj -o ~/hudy.py
chmod +x ~/hudy.py

# 6. Thiết lập Alias tự động
if ! grep -q 'alias hudy=' ~/.bashrc 2>/dev/null; then
    echo 'alias hudy="python ~/hudy.py"' >> ~/.bashrc
    echo 'alias hudy4="python ~/hudy.py"' >> ~/.bashrc
fi

# Nạp alias vào phiên làm việc hiện tại
alias hudy="python ~/hudy.py" 2>/dev/null || true

echo -e "\n${C_GREEN}[✓] SETUP THÀNH CÔNG HOÀN TẤT!${C_RESET}"
echo -e "${C_YELLOW}[i] Bạn có thể gõ ngay lệnh: ${C_CYAN}hudy${C_YELLOW} hoặc ${C_CYAN}python ~/hudy.py${C_YELLOW} để mở tool.${C_RESET}\n"
