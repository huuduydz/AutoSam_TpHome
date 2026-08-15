#!/data/data/com.termux/files/usr/bin/bash

echo -e "\033[1;34m[*] Đang cấu hình Termux & Mirror...\033[0m"

# 1. Tự động chuyển Mirror sang nhóm All (tránh lỗi kết nối repo)
MIRROR_DIR="/data/data/com.termux/files/usr/etc/termux"
if [ -d "$MIRROR_DIR/mirrors/all" ]; then
    [ -L "$MIRROR_DIR/chosen_mirrors" ] && unlink "$MIRROR_DIR/chosen_mirrors"
    ln -s "$MIRROR_DIR/mirrors/all" "$MIRROR_DIR/chosen_mirrors"
fi

# 2. Cấp quyền bộ nhớ không hiện prompt đơ máy
termux-setup-storage >/dev/null 2>&1

# 3. Cập nhật Package & Cài đặt thư viện cần thiết
export DEBIAN_FRONTEND=noninteractive
pkg update -y -o Dpkg::Options::="--force-confold" --check-mirror
pkg upgrade -y -o Dpkg::Options::="--force-confold"
pkg install python root-repo tsu -y -o Dpkg::Options::="--force-confold"

# 4. Tải tool Python về thư mục gốc
echo -e "\033[1;34m[*] Đang tải script ToolRejoin...\033[0m"
curl -Ls https://raw.githubusercontent.com/huuduydz/AutoSam_TpHome/refs/heads/main/ToolRejoin -o ~/hudy.py

# 5. Gán Alias (phòng hờ chạy lệnh ngắn hudy)
if ! grep -q 'alias hudy=' ~/.bashrc 2>/dev/null; then
    echo 'alias hudy="python ~/hudy.py"' >> ~/.bashrc
fi

echo -e "\n\033[1;32m[✓] Cài đặt thành công! Dùng lệnh bên dưới để chạy tool.\033[0m\n"
