#!/data/data/com.termux/files/usr/bin/bash

echo -e "\033[1;34m[*] Đang cấu hình Mirror và Package...\033[0m"

# 1. Bỏ qua setup storage nếu đã có hoặc chạy ngầm không chặn luồng
if [ ! -d "$HOME/storage" ]; then
    (termux-setup-storage >/dev/null 2>&1 &)
fi

# 2. Đổi repo trực tiếp sang mirror Grimler/Main (Nhanh và không bị hỏi hay ping nghẽn)
mkdir -p /data/data/com.termux/files/usr/etc/apt/sources.list.d
echo "deb https://packages.termux.dev/apt/termux-main stable main" > /data/data/com.termux/files/usr/etc/apt/sources.list

# 3. Chạy update tĩnh, ép cờ non-interactive triệt để
export DEBIAN_FRONTEND=noninteractive
apt update -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef"
apt upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef"
apt install python tsu -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef"

# 4. Tải file script về máy
echo -e "\033[1;34m[*] Đang tải ToolRejoin...\033[0m"
curl -Ls https://raw.githubusercontent.com/huuduydz/AutoSam_TpHome/refs/heads/main/ToolRejoin -o ~/hudy.py

# 5. Tạo alias
if ! grep -q 'alias hudy=' ~/.bashrc 2>/dev/null; then
    echo 'alias hudy="python ~/hudy.py"' >> ~/.bashrc
fi

echo -e "\n\033[1;32m[✓] Cài đặt hoàn tất! Chạy tool bằng lệnh bên dưới.\033[0m\n"
