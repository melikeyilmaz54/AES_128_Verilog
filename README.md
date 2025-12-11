🟦 AES ALGORİTMASI – README DÖKÜMÜ
🔹 AES Sistem Modülleri Şeması

![AES System Modules]("\Users\ASUS\Pictures\sistemseması.png")

🔹 Bit Yerleşimi

(Durum matrisi / state array bit yerleşimi görseli eklenebilir)

![AES Bit Placement](./images/aes_bit_placement.png)

🟦 1. AES ALGORTIMASINA GİRİŞ (Advanced Encryption Standard)

AES algoritması 128 bit blok üzerinde çalışır ve girişteki 16 byte veri, 4×4'lük durum matrisine (state) yerleştirilir.
Her turdan sonra bu matris güncellenir ve son tur sonunda matris tekrar 128 bit tek parça hâline getirilerek şifreli çıktı üretilir.

Blok boyutu: 128 bit

Durum matrisi: 4×4 byte

Round sayısı: 128 bit anahtar için 10 round

Her round işlemleri:

SubBytes

ShiftRows

MixColumns (son turda yok)

AddRoundKey

Şifre çözme işlemi (Decrypt) bu adımların tersleri ile yapılır:

InvSubBytes

InvShiftRows

InvMixColumns

AddRoundKey

🟦 2. AES ROUND ADIMLARI
🔸 2.1 SubBytes Dönüşümü

Her byte, S-Box tablosuna göre yeni bir byte ile değiştirilir.

S-Box giriş: (x, y) koordinatı

Örn: S[0,0] = 0x41 ise → bu değer tabloya göre yeni byte olur.

👉 Lineer olmayan tek dönüşümdür ve AES'in güvenliğinin temelidir.

🔸 2.2 ShiftRows Dönüşümü

Durum matrisindeki satırlar dairesel olarak sola kaydırılır:

Satır	Kaydırma
0. satır	kaydırılmaz
1. satır	1 sola
2. satır	2 sola
3. satır	3 sola

Decrypt işleminde bu kaydırmalar sağa yapılır.

🔸 2.3 MixColumns Dönüşümü

Bu adımda her sütun, sabit bir GF(2⁸) matris çarpımı ile dönüştürülür.

Encrypt işleminde üstteki matris kullanılır.

Decrypt işleminde inverse matris kullanılır.

👉 Lineer dönüşümdür ve difüzyon sağlar.

🔸 2.4 AddRoundKey Dönüşümü

Her sütundaki byte, round anahtarının ilgili byte'ı ile XOR işlemine tabi tutulur.

XOR işlemi tersinir → şifre çözmede aynı işlem kullanılır.

🟦 3. AES ENCRYPT (Şifreleme) DURUM ŞEMASI

(Buraya diyagram görselini ekleyebilirsin)

![AES Encrypt FSM](./images/aes_encrypt_fsm.png)

🟦 4. AES DECRYPT (Şifre Çözme) DURUM ŞEMASI
![AES Decrypt FSM](./images/aes_decrypt_fsm.png)

🟦 5. MODÜLLER
🔸 5.1 ENCRYPT Modülleri
![Encrypt Modules](./images/encrypt_modules.png)

🔸 5.2 DECRYPT Modülleri
![Decrypt Modules](./images/decrypt_modules.png)

🟦 6. KEY SCHEDULE (Anahtar Üretimi)

AES’de anahtar genişletme işlemi kelime (word) tabanlıdır.
Her word = 32 bit (4 byte)

128 bit anahtar için başlangıçta:

w[0], w[1], w[2], w[3]


Sonraki round anahtarları aşağıdaki adımlarla üretilir:

Key Expansion Adımları

Anahtar 4 parçaya bölünür → her biri 32 bit.

Son word RotWord ile sola döndürülür.

RotWord içindeki her byte S-Box dönüşümünden geçirilir.

Rcon sabitleri ile XOR yapılır (g() fonksiyonu).

w[4] = w[0] XOR g(w[3])

w[5] = w[4] XOR w[1]

w[6] = w[5] XOR w[2]

w[7] = w[6] XOR w[3]

Bu döngü 10 tur boyunca devam eder → toplam 44 word oluşur.

🟦 7. KeySchedule Durum Şeması
![KeySchedule FSM](./images/keyschedule_fsm.png)

🟦 8. TCL ÇIKTISI
![TCL Output](./images/tcl_output.png)

🟦 9. AES NIST STANDARDI

Orijinal standart dokümanı:
🔗 https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf
