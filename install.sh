#!/bin/bash


# Boshlang'ich papkani so'rash
echo "Iltimos, boshlang'ich papkani kiriting (masalan: /home/user/workspace):"
read -r workspace_dir

# Papka mavjudligini tekshirish
if [ ! -d "$workspace_dir" ]; then
  echo "Xatolik: Belirtilgan papka mavjud emas. Skriptni to'xtataman."
  exit 1
fi

# Foydalanuvchi tomonidan kiritilgan papkani .sh fayliga saqlash
echo "Boshlang'ich papka: $workspace_dir"
echo "$workspace_dir" > workspace_path.txt


# Funksiya: Tizimning paket menejerini aniqlash
detect_package_manager() {
    if command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    else
        echo "none"
    fi
}

# Funksiya: Cronni o'rnatish
install_cron() {
    PACKAGE_MANAGER=$(detect_package_manager)

    if [ "$PACKAGE_MANAGER" == "pacman" ]; then
        # Arch, Manjaro, va boshqa Arch-based tizimlar uchun
        if ! command -v crontab &> /dev/null; then
            echo "Arch tizimida cronie o'rnatilmoqda..."
            sudo pacman -S --noconfirm cronie
        fi
    elif [ "$PACKAGE_MANAGER" == "apt" ]; then
        # Debian, Ubuntu, va boshqa Debian-based tizimlar uchun
        if ! command -v crontab &> /dev/null; then
            echo "Debian tizimida cron o'rnatilmoqda..."
            sudo apt update && sudo apt install -y cron
        fi
    elif [ "$PACKAGE_MANAGER" == "dnf" ]; then
        # Fedora va boshqa Red Hat-based tizimlar uchun
        if ! command -v crontab &> /dev/null; then
            echo "Fedora tizimida cron o'rnatilmoqda..."
            sudo dnf install -y cronie
        fi
    else
        echo "Paket menejeri aniqlanmadi! Cronni o'rnatish uchun tizimni tekshirib chiqing."
        exit 1
    fi
}

# Funksiya: Cron xizmatini ishga tushurish
start_cron_service() {
    if ! systemctl is-active --quiet cronie.service; then
        echo "Cron xizmati ishga tushirilyapti..."
        sudo systemctl enable cronie.service --now
    else
        echo "Cron xizmati allaqachon ishga tushgan."
    fi
}

# Funksiya: Crontabni tahrirlash (autobackuper.sh faylini qo'shish)
edit_crontab() {
    script_path="$(dirname "$(realpath "$0")")/autobackuper.sh"

    # Yangi crontab yozuvini qo'shish
    if ! crontab -l | grep -q "$script_path"; then
        echo "*/5 * * * * $script_path" | crontab -
        echo "Yangi crontab qo'shildi: $script_path har 5 daqiqada ishga tushadi."
    else
        echo "Cron yozuvi allaqachon mavjud."
    fi
}

# Asosiy ish jarayoni

# Cronni o'rnatish
install_cron

# Cron xizmatini ishga tushirish
start_cron_service

# Yangi crontab qo'shish
edit_crontab
