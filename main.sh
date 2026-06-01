#!/bin/bash
#// HAMZA OĞUS
#// 2420171030
#//https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=nKqhn7LYEJ
#//https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=Yx1h8Daepa
#//https://credsverse.com/credentials/=ea88187c-ce8c-4987-b318-9a4cbb04b850

LOG_FILE="report.log"

echo "--- Donanım Raporu Başlangıcı ---" > "$LOG_FILE"
echo "Tarih ve Saat (ISO 8601): $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$LOG_FILE"
echo "---------------------------------" >> "$LOG_FILE"

OS_TYPE=$(uname -s)

if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo -e "\n[İşletim Sistemi: macOS]" >> "$LOG_FILE"
    echo "--- Sistem ve Donanım Bilgileri ---" >> "$LOG_FILE"
    system_profiler SPHardwareDataType >> "$LOG_FILE"
    
    echo -e "\n--- Ağ ve MAC Bilgileri ---" >> "$LOG_FILE"
    ifconfig >> "$LOG_FILE"

elif [[ "$OS_TYPE" =~ MINGW|CYGWIN|MSYS ]]; then
    echo -e "\n[İşletim Sistemi: Windows]" >> "$LOG_FILE"
    
    echo -e "\n--- İşlemci (CPU) ---" >> "$LOG_FILE"
    wmic cpu get name >> "$LOG_FILE" 2>/dev/null
    
    echo "--- RAM ---" >> "$LOG_FILE"
    wmic memorychip get capacity >> "$LOG_FILE" 2>/dev/null
    
    echo "--- Anakart ---" >> "$LOG_FILE"
    wmic baseboard get product,Manufacturer >> "$LOG_FILE" 2>/dev/null
    
    echo "--- UUID ---" >> "$LOG_FILE"
    wmic csproduct get UUID >> "$LOG_FILE" 2>/dev/null
    
    echo -e "\n--- MAC Bilgisi ---" >> "$LOG_FILE"
    getmac >> "$LOG_FILE" 2>/dev/null

else
    echo "Desteklenmeyen veya tanımlanamayan işletim sistemi: $OS_TYPE" >> "$LOG_FILE"
fi

echo "Donanım bilgileri $LOG_FILE dosyasına yazıldı."

echo ""
read -s -p "Lütfen şifreleme için parolayı giriniz (Örn: MYO+202): " PAROLA
echo ""

gpg --batch --yes --pinentry-mode loopback --passphrase "$PAROLA" --symmetric --cipher-algo AES256 "$LOG_FILE"

if [ -f "$LOG_FILE.gpg" ]; then
    rm "$LOG_FILE"
    echo "Şifreleme başarılı! Orijinal '$LOG_FILE' dosyası silindi."
    echo "Çıktı dosyası: $LOG_FILE.gpg"
else
    echo "Hata: Şifreleme işlemi tamamlanamadı."
fi
