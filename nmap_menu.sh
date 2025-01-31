#!/bin/bash

nmap_menu() {
    while true; do
        clear
        echo "==== nmap Ağ Tarama İşlemleri ===="
        echo "1) Hızlı Tarama (-T4 -F)"
        echo "2) Yavaş Tarama (-T2)"
        echo "3) Subnet Tarama (-sn)"
        echo "4) Ana Menü"
        echo "=================================="
        read -p "Bir seçenek girin: " nmap_secim

        case $nmap_secim in
            1)
                read -p "Hedef IP adresini girin: " target
                echo "Nmap hızlı tarama başlatılıyor..."
                mkdir nmap-sonuc > /dev/null
                cd nmap-sonuc
                nmap -T4 -F "$target" | tee "nmap_hizli_${target}.txt"
                cd ..
                clear
                echo "Tarama tamamlandı! Mevcut dizine nmap_hizli_${target}.txt adıyla kaydedildi!"
                sleep 2
                ;;
            2)
                read -p "Hedef IP adresini girin: " target
                echo "Nmap yavaş tarama başlatılıyor..."
                mkdir nmap-sonuc > /dev/null
                cd nmap-sonuc
                nmap -T2 "$target" | tee "nmap_yavas_${target}.txt"
                cd ..
                clear
                echo "Tarama tamamlandı! Mevcut dizine nmap_yavas_${target}.txt adıyla kaydedildi!"
                sleep 2
                ;;
            3)
                read -p "Subnet adresini girin (örn: 192.168.1.0/24): " target
                echo "Nmap subnet taraması başlatılıyor..."
                mkdir nmap-sonuc > /dev/null
                cd nmap-sonuc
                nmap -sn "$target" | tee "nmap_subnet_${target}.txt"
                cd ..
                clear
                echo "Tarama tamamlandı! Mevcut dizine nmap_subnet_${target}.txt adıyla kaydedildi!"
                sleep 2
                ;;
            4)
                clear
                echo "Program yeniden başlatılıyor..."
                sleep 1
                bash baslat.sh
                ;;
            *)
                echo "Geçersiz seçenek, lütfen tekrar deneyin."
                ;;
        esac
    done
}

#Ana dizine tekrar dön

# Eğer bu dosya doğrudan çalıştırılıyorsa fonksiyonu çağır
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    nmap_menu
fi
