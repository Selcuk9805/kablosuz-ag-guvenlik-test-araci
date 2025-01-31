#!/bin/bash

# Selcuk Sercan tarafindan yazilmistir ve duzenlenmistir. Akilli olun cocuklar!


# Root yetkisi kontrolu ile bismillah diyip basliyoruz...
if [[ "$EUID" -ne 0 ]]; then
    echo "Bu scripti çalıştırmak için root yetkisine sahip olmalısınız."
    exit 1
fi

# Bağımlı olan shell scriptlerini içeri aktarma kısmı

source aircrack-ng_menu.sh
source nmap_menu.sh

# İnternet bağlantısını kontrol et
if ping -c 1 8.8.8.8 &> /dev/null; then
    status="${GREEN}✓ Bağlı${NC}"
    local_ip=$(hostname -I | awk '{print $1}')
    public_ip=$(curl -s https://ifconfig.me)
else
    status="${RED}✗ Bağlı Değil${NC}"
    local_ip="N/A"
    public_ip="N/A"
fi




clear
echo "Gerekli yazılımlar kontrol ediliyor..."
echo ""
sleep 0.5
# Sistem gereksinimlerini kontrol et ve yükle
yazilim_kontrol() {
    for arac in "$@"; do
        if ! command -v "$arac" &> /dev/null; then
            echo "$arac yüklü değil, yüklenecek..."
            sudo apt update
            sudo apt install -y "arac"
        else
            echo "$arac zaten yüklü."
            sleep 0.7
        fi
    done
}


yazilim_kontrol "aircrack-ng" "figlet" "nmap"

clear
echo -e "\e[1;34m"  # Mavi renk
figlet -f slant "SELCUK SERCAN"
echo -e "\e[0m"  # Renk sıfırla
sleep 0.5
clear
echo -e "\e[1;34m"  # Mavi renk
figlet -f slant "KABLOSUZ"
echo -e "\e[0m"  # Renk sıfırla
sleep 0.5
clear
echo -e "\e[1;34m"  # Mavi renk
figlet -f slant "AGLARDA"
echo -e "\e[0m"  # Renk sıfırla
sleep 0.5
clear
echo -e "\e[1;34m"  # Mavi renk
figlet -f slant "GUVENLIK"
echo -e "\e[0m"  # Renk sıfırla
sleep 0.5
clear
echo -e "\e[1;34m"  # Mavi renk
figlet -f slant "TEST ARACI"
echo -e "\e[0m"  # Renk sıfırla
sleep 0.5


if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    distro_info="$NAME $VERSION"
else
    distro_info="Dağıtım bilgisi bulunamadı"
fi


# Ana Menü Fonksiyonu
function ana_menu() {
    clear
    echo -e "========== Bağlantı Durumu: $status =========="
    echo -e "Yerel IP: $local_ip"
    echo -e "Genel IP: $public_ip"
    echo -e "İşletim sistemi: $distro_info"
    echo "========== Kablosuz Ağlarda Güvenlik Test Aracı =========="
    echo "1. aircrack-ng ile Kablosuz Ağ Testleri"
    echo "2. nmap Kullanarak Ağ Tarama İşlemleri"
    echo "3. Çıkış yap"
    read -p "Lütfen bir seçenek seçin (1-2-3): " secim

    case $secim in
        1)
            aircrack_menu
            ;;
        2)
            nmap_menu
            ;;
        3)  
            echo "Program sonlandırılıyor..."
            exit 0
            ;;
        *)
            echo "Geçersiz seçim. Lütfen tekrar deneyin."
            main_menu
            ;;
    esac
}

# Ana menüyü başlat
ana_menu
