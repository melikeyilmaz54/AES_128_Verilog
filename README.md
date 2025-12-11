AES ALGORİTMASI
SİSTEM MODÜLLERİ ŞEMASI:

<img width="406" height="452" alt="sistemseması" src="https://github.com/user-attachments/assets/192f252b-0cc5-48a6-a02c-f94cb6e35404" />


BİT YERLEŞİMİ:

<img width="477" height="242" alt="Resim2" src="https://github.com/user-attachments/assets/f3c47c64-5af2-464f-9415-02faf81bf896" />


AES ALGORİTMASI (Advanced Encryption Standard): AES algoritması 128 bit blok uzunluğuna sahiptir. 16 byte lık bloklar üzerinde gerçeklenir. Girişteki her bir byte 4x4 lük AES durum matrisinin bir hücresine yerleştiriliyor. İşlemlerden sonra en son matristeki byte değerleri birleştirilerek algoritma çıkışı elde edilmiş oluyor. 128 bit anahtar kullanılıyorsa bu algoritma 10 tur da gerçekleşebilir.

AES algoritması her round u 4 işlemden oluşan 10 rounddan meydana gelir. Başlangıçta AddRoundKey yapılmak üzere her round SubBytes, ShiftRows, MixColums ve AddRoundKey adımlarından oluşur. Son tur da MixColums işlemi yapılmaz.
Şifre çözme algoritmasında ise bu işlemleri tersten olacak şekilde ilerletiriz.

<img width="514" height="357" alt="Resim3" src="https://github.com/user-attachments/assets/89889fde-f633-4ede-9f09-568b3c89058a" />  <img width="200" height="200" alt="Resim4" src="https://github.com/user-attachments/assets/9fbe6fd0-e676-4567-b4dd-7c7a087823ea" />

1. SubBytes dönüşümü

Durum matrisindeki her bir byte tabloya göre yeni byte değeriyle değiştirilir. Örneğin hex olarak S 0,0 ın değeri 41 olsun. Tabloya göre x değeri 4, y değeri 1 olan bölge matristeki yeni değer olarak değiştirilir.

<img width="1100" height="300" alt="Resim5" src="https://github.com/user-attachments/assets/ddd4db78-68f5-4c94-ab78-2466f85a46c2" />

2. ShiftRows Dönüşümü

Durum matrisindeki satırlar dairesel döndürmeye tabi tutulur.
İlk satır aynen kalır, ikinci satır 1 birim, üçüncü satır 2 birim, dördüncü satır 3 birim sola dairesel kaydırılır.
Şifre çözme işleminde ise dönüşümler sola değil sağa doğru yapılır.

<img width="400" height="200" alt="Resim6" src="https://github.com/user-attachments/assets/53ced8c3-c6c4-4656-9ee5-d054de176ad8" />



3. MixColums Dönüşümü

Bu sefer sütunlarla işlem yapıyoruz. Her sütunu üstteki matrisle çarparak yeni sütunu oluşturuyoruz.
Şifre çözmede ise matristeki sütunları alt taraftakimatris ile çarparak yeni değerlerini elde ediyoruz.

 <img width="510" height="214" alt="Resim7" src="https://github.com/user-attachments/assets/c6d3b05e-bedf-4fbe-8d05-ead3167a1c4f" />
 
4. AddRoundKey Dönüşümü

Her bir sütunu, tur anahtarını içeren matristeki her bir sütun ile XOR işleminden geçiriyoruz.
Bu işlemin tersi de kendisiyle aynıdır.

<img width="500" height="200" alt="Resim8" src="https://github.com/user-attachments/assets/beaafbb6-aa22-4150-bfe0-4e9ff4e0fdb7" />


ENCRYPT MODÜLÜ DURUM ŞEMASI:

<img width="456" height="402" alt="Resim9" src="https://github.com/user-attachments/assets/f061de4c-f568-4f97-9fb2-8f474bdfb0cc" />


DECRYPT MODÜLÜ DURUM ŞEMASI:

<img width="507" height="335" alt="Resim10" src="https://github.com/user-attachments/assets/8f4902a3-53bb-41d2-9df2-73cbd3ea3339" />


MODÜLLER

<img width="299" height="250" alt="Resim11" src="https://github.com/user-attachments/assets/967f3fb1-c612-46a6-8b18-608ff078d1ed" />

KEYSCHEDULE

Kelime tabanlı gerçekleştirir. AES algoritması için her round için ayrı bir anahtar üretilir. Şifre çözme sürecinde üretilen anahtarlar tekrar kullanılır.

Anahtar 4 parçaya bölünür. Her biri 32 bit (1 word). (w[0], w[1], w[2], w[3])

Son parça (w[3]) bir adım sola (yukarı) kaydırılır. - g()

Her bir parça s box dan geçirilir. - g()

Sabit katsayılarla bu bloğu XOR işleminden geçiririz. - g()

İlk parça (w[0]) ile g fonksiyonundan geçirilmiş son parça (w[3]) XOR işleminden geçirilerek şifreli veri (w[4]) elde edilir.

Bu şifreli veriyle w[1] XOR lanarak diğer şifreli veri (w[5]) elde edilir.

128 bit tamamlanınca yani w4 w5 w6 w7 oluşturulunca tekrardan döngüde başa gidilir ve g fonksiyonundan geçirilip adımlar 10 tur boyunca tekrarlanır.

<img width="535" height="346" alt="Resim12" src="https://github.com/user-attachments/assets/7c87a5d8-93b8-4d59-be7d-da83be848567" />




<img width="300" height="100" alt="Resim13" src="https://github.com/user-attachments/assets/71d0582d-6448-4745-90ac-f305ac36c7c8" />  
<img width="300" height="300" alt="Resim14" src="https://github.com/user-attachments/assets/69252f7c-328d-40d6-b0c6-7d5393b1957e" /> <img width="457" height="300" alt="Resim15" src="https://github.com/user-attachments/assets/c801bacd-24dd-4e07-a03b-59948662fefa" />



DURUM ŞEMASI:
TCL ÇIKTISI:

<img width="540" height="333" alt="Resim16" src="https://github.com/user-attachments/assets/d705dafe-66a0-4679-9082-148a6b398bea" />


https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf
