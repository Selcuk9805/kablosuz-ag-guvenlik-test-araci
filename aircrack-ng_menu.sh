#!/bin/bash


#Adaptörün sabit olarak tanımlanması
#source adapter.sh
# Kablosuz Ağ Araçları Menüsü
aircrack_menu() {
    clear
    echo "==== Kablosuz Ağ Araçları ===="
    echo "1) Wi-Fi Kartını Seç ve Monitör Moduna Al"
    echo "2) Yakındaki Ağları Tara"
    echo "3) Handshake Yakala (Sadece dinleme)"
    echo "4) Ana Menü"
    echo "=================================="
    read -p "Seçiminizi yapın: " aircrack_secim

    case "$aircrack_secim" in
        1)
            # Mevcut ağ arayüzlerini listele
            echo "Mevcut ağ arayüzleri:"
            iwconfig | grep "IEEE 802.11" | awk '{print $1}'
            
            # Kullanıcıdan Wi-Fi kartını seçmesini iste
            read -p "Kullanacağınız Wi-Fi kartını girin (örnek: wlan0): " wifi_kart
            
            # Monitör modunu başlat
            sudo airmon-ng start "$wifi_kart"
            
            echo "Monitör modu aktif! Geri dönmek için Enter'a basın..."
            read
            aircrack_menu
            ;;

        2)
            # Yakındaki ağları tarama ve listeleme
            clear
            echo "Yakındaki ağ cihazları 15 saniye boyunca taranacaktır..."
            sleep 2
            timestamp=$(date +"%H:%M:%S_%d_%m_%Y")
            airodump-ng -w dosyacikti --output-format csv $wifi_kart_mon &
            sleep 15
            pkill -f airodump-ng
            mkdir ag-listesi
            mv dosyacikti-01.csv ./ag-listesi
            cd ag-listesi
            mv dosyacikti-01.csv wifi--"$timestamp".csv
            cd ..
            clear
            echo "Ağ taraması tamamlandı! wifi--$timestamp.csv dosyasında kayıtlı."
            read -p "Devam etmek için Enter'a basın..."
            aircrack_menu
            ;;

        3)
            # Ağ cihazlarını tarat ve kullanıcıya seçim yaptır
            #read -p "Monitör modundaki kartı girin (örnek: wlan0mon): " mon_kart
            source adapter.sh
            echo "Yakındaki ağlar taranıyor, lütfen bekleyin..."
            echo "Kullanılan ağ adaptörü $wifi_kart"
            echo "Monitör modundaki ağ adaptörü $wifi_kart_mon"
            echo "15 saniye sonra sonuçlar ekrana yazdırılacaktır."
            sleep 2
            airodump-ng "$wifi_kart_mon" --write temp --output-format csv &
            sleep 10  # Ağ taramasının tamamlanması için bekleme süresi
            pkill -f airodump-ng  # Taramayı durdur

            # Ağları CSV dosyasından çek ve listele
            clear
            echo "Bulunan ağlar:"
            awk -F',' 'NR>2 && $1 ~ /[0-9A-Fa-f:]{17}/ {print NR-2 ") BSSID: " $1 ", Kanal: " $4 ", SSID: " $14}' temp-01.csv
            
            read -p "Hedef ağın numarasını seçin: " secim
            hedef_bssid=$(awk -F',' -v sec="$secim" 'NR==sec+2 {print $1}' temp-01.csv)
            hedef_kanal=$(awk -F',' -v sec="$secim" 'NR==sec+2 {print $4}' temp-01.csv)

            hedef_bssid=$(echo "$hedef_bssid" | xargs)
            hedef_kanal=$(echo "$hedef_kanal" | xargs) 

            if [[ -z "$hedef_bssid" || -z "$hedef_kanal" ]]; then
                echo "Geçersiz seçim! Tekrar deneyin."
                sleep 2
                return
            fi
            
            clear
            echo "Seçilen ağ: BSSID=$hedef_bssid, Kanal=$hedef_kanal"
            sleep 3
            rm temp-01.csv
            # Handshake yakalamaya başla
            echo "Ağ izleme başlatılıyor. WPA handshake bulunduğunda CTRL + C ile çıkış yapın."
            sleep 0.4
            echo "Ağ izleme başlatılıyor. WPA handshake bulunduğunda CTRL + C ile çıkış yapın."
            sleep 0.4
            echo "Ağ izleme başlatılıyor. WPA handshake bulunduğunda CTRL + C ile çıkış yapın."
            sleep 3
            clear
            airodump-ng "$wifi_kart_mon" --bssid "$hedef_bssid" -c "$hedef_kanal" --write yakalama
            #aireplay-ng --deauth 10 -a "$hedef_bssid" "$mon_kart"
            
            echo "Yakalanan trafik 'yakalama.cap' dosyasına kaydedilecek."
            read -p "Devam etmek için Enter'a basın..."
            aircrack_menu
            ;;

        4)
            clear
            echo "Program yeniden başlatılıyor..."
            sleep 1
            bash baslat.sh
            ;;

        *)
            echo "Geçersiz seçim! Tekrar deneyin."
            sleep 2
            ;;
    esac
}

# Eğer bu dosya doğrudan çalıştırılıyorsa fonksiyonu çağır
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    aircrack_menu
fi
