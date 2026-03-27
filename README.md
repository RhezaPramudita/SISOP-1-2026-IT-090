PRAKTIKUM SISOP MODUL 1

SOAL 1

BEGIN {
	FS = ","
	opsi = ARGV[2]
	delete ARGV[2]
}

Blok BEGIN dijalankan sebelum AWK menyentuh satu baris dari file. Disini FS menjadi pengatur pada file CSV, maksudnya setiap kolom dipisahkan oleh tanda koma. Script menerima dua input yaitu file CSV dab satu huruf opsi (a sampai e).

melewati header (tidak  usah baca headernya)
NR == 1 { next }

NR (Number of Record) merupakan variabel bawaan AWK yang menyimpan nomor baris yang sedang dibaca saat ini. NR == 1 {next} artinya jika sedang membaca baris ke 1, lewati baris ini dan langsung lanjut ke baris berikutnya.

{
	total++

Setiap kali AWK membaca satu baris, variabel total bertambah 1. Ini digunakan untuk menghitung jumlah seluruh penumpang.

	if (daftar_gerbong[$4] == 0) {
	total_gerbong++
	daftar_gerbong[$4] = 1
	}

$4 adalah nilai kolom ke 4 yaitu nomor gerbong. AWK mengecek apakah gerbong itu sudah pernah tercatat di array daftar_gerbong. Kalau belum (nilainya masih 0), maka total_gerbong ditambah 1 dan gerbong itu ditandai dengan nilai 1 agar tidak dihitung lagi.

	if ($2 > umur_maksimal) {
	umur_maksimal = $2
	nama_tertua = $1
	}

$2 adalah kolom umur dan $1 adalah kolom nama penumpang. Kalau umur lebih besar dari umur_maksimal maka akan tersimpan. Kalau ada yang lebih besar lagi maka akan diperbarui.

	jumlah_usia += $2

Umur setiap penumpang ditambahkan ke jumlah_usia. Hasil akumulasinya akan digunakan untuk menghitung rata-rata umur di blok END.

	if ($3 == "Business") {
	total_business++
	}
}

$3 adalah kolom kelas penumpang. Kalau nilainya tepat "Business", maka total_business akan bertambah 1.

END

Dijalankan setelah semua baris selesai dibaca.

 {
	if (opsi == "a") {
	printf "Jumlah seluruh penumpang KANJ adalah %d orang\n", total
	}

Mencetak opsi "a", yaitu menghitung seluruh jumlah penumpang.

	else if (opsi == "b") {
	printf "Jumlah gerbong penumpang KANJ adalah %d\n", total_gerbong
	}

Mencetak opsi "b", yaitu menghitung jumlah gerbong.

	else if (opsi == "c") {
	printf "%s adalah penumpang kereta tertua dengan usia %d tahun\n", nama_tertua, umur_maksimal
	}

Mencetak opsi "c", yaitu menentukan siapa penumpang tertua yang ada di kereta.

	else if (opsi == "d") {
	rata_rata = jumlah_usia / total
	printf "Rata-rata usia penumpang adalah %d tahun\n", int(rata_rata)
	}

Mencetak opsi "d", yaitu menghitung rata-rata usia penumpang.

	else if (opsi == "e") {
	printf "Jumlah penumpang business class ada %d orang\n", total_business
	}

Mencetak opsi "e", yaitu menghitung jumlah penumpang yang ada di business.

	else {
	printf "Soal tidak dikenali\n"
	}
}

Mencetak "Soal tidak dikenali" ketika user menginput yang bukan salah satu opsi (a sampai e).



SOAL 2

PARSERKOORDINAT.SH

Disini banyak perintah yang memiliki bagian yang disambung dengan pipe "|", artinya output dari satu perintah langsung menjadi input perintah berikutnya. Tujuannya adalah mengekstrak data lokasi dari file JSON dan menyimpan ke file CSV sederhana.

grep -E "id|site_name|latitude|longitude" gsxtrack.json | 

Membaca file gsxtrack.json dan hanya mengambil baris yang mengandung kata "id", "site_name", "latitude", atau "longitude". Opsi -E memungkinkan penggunaan ekspresi reguler dengan operator "|" ("atau"). Baris lain yang tidak relevan diabaikan.

sed 's/[",]//g' | 

Membersihkan hasil dari grep dengan menghapus semua karakter tanda kutip (") dan koma (,) dari setiap baris. Ini dilakukan karena format JSON menggunakan karakter-karakter tersebut, sehingga perlu dibersihkan agar datanya lebih mudah diproses oleh AWK.

awk ' {
        if ($1 == "id:") id = $2
        if ($1 == "site_name:") name = $2
        if ($1 == "latitude:") lat = $2
        if ($1 == "longitude:") {
                lon = $2
                printf "%s,%s,%s,%s\n", id, name, lat, lon
                }

AWK membaca baris per baris hasil dari 'sed'. Kolom pertama ('$1') adalah nama field, dan kolom kedua ('$2') adalah nilainya. Setiap kali menemukan field 'id', 'site_name', atau 'latitude', nilainya disimpan dulu ke variabel masing-masing. Baru ketika menemukan 'longitude, semua variabel yang sudah terkumpul langsung dicetak sekaligus dalam format CSV satu baris. Ini karena 'longitude' selalu menjadi field terakhir dari setiap entri lokasi di JSON tersebut.

        }' > titik-penting.txt

Mengalihkan seluruh output AWK ke file 'titik-penting.txt'. Jika file belum ada, akan dibuat baru. Jika sudah ada, isinya akan ditimpa.


echo "File titik-penting.txt berhasil dibuat!"

Mencetak pesan konfirmasi ke terminal bahwa proses telah selesai dan file titik-penting.txt berhasil dibuat.

NEMUPUSAKA.SH

ambil koordinat titik ke 1 (x1, y1)
lat1=$(awk -F',' 'NR==1 {print $3}' titik-penting.txt)
lon1=$(awk -F',' 'NR==1 {print $4}' titik-penting.txt)

Menagambil koordinat titik pertama. AWK membaca file titik-penting.txt dengan pemisah koma (-F','). NR==1 berarti hanya ambil baris pertama. $3 mengambil kolom ke 3 (latitude) dan $4 mengambil kolom ke 4 (longitude). Hasilnya disimpan ke variabel lat1 dan lon1.

ambil koordinat titik ke 3 (x2, y2) - diagonalnya
lat2=$(awk -F',' 'NR==3 {print $3}' titik-penting.txt)
lon2=$(awk -F',' 'NR==3 {print $4}' titik-penting.txt)
 Mengambil koordinat titik ketiga. Sama seperti sebelumnya, tapi mengambil baris ketiga (NR==3). Titik ini disebut "diagonal" karena diasumsikan sebagai sudut berlawanan dari titik pertama, seperti dua pojok berlawanan sebuah persegi panjang.

hitung titik tengah (latitude, longitude) menggunakan bc
rumus: (y1+y2)/2 dan (x1+x2)/2
mid_lat=$(echo "scale=10; ($lat1 + $lat2) / 2" | bc)
mid_lon=$(echo "scale=10; ($lon1 + $lon2) / 2" | bc)

Menghitung titik tengah. Dihitung dengan rumus rata-rata sederhana yaitu menjumlahkan dua nilai lalu dibagi 2. "bc" adalah kalkulator di terminal linux yang bisa menangani bilangan desimal. Scale=10 berarti hasil perhitungan ditampilkan dengan 10 angka dibelakang koma agar presisinya tinggi.

#output hasil ke terminal dan simpan ke file
echo "Koordinat pusat:" | tee posisipusaka.txt
echo "$mid_lat, $mid_lon" | tee -a posisipusaka.txt

'tee' berfungsi ganda, mencetak output ke terminal sekaligus menyimpannya ke file. Perintah pertama membuat file 'posisipusaka.txt' baru dengan tulisan "Koordinat pusat:"'. Perintah kedua menambahkan nilai koordinat tengah ke baris berikutnya di file yang sama, menggunakan flag '-a' (append) agar tidak menimpa baris sebelumnya.