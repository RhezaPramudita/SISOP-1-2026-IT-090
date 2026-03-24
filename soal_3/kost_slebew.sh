#!/bin/bash

# path file database
DB="data/penghuni.csv"

if [[ $1 == "--check-tagihan" ]]; then
	# mencari baris yang mengandung "nunggak" (case-insensitive)
	# lalu mencetak waktu sekarang dan data penghuninya ke file log
	awk -F',' 'BEGIN { IGNORECASE=1 } $5 ~ /nunggak/ {
		"date \"+%Y-%m-%d %H:%M:%S\"" | getline dt
	printf "[%s] TAGIHAN: %s (Kamar %s) - Nunggak Rp%s\n", dt, $1, $2, $3
	}' "$DB" >> log/tagihan.log
	exit 0
fi

# fungsi menu utama
show_menu() {
	clear
	echo "======================================="
	echo "      SISTEM MANAJEMEN KOS SLEBEW      "
	echo "======================================="
	echo " 1 | Tambah Penghuni Baru"
	echo " 2 | Hapus Penghuni"
	echo " 3 | Tampilkan Daftar Penghuni"
	echo " 4 | Update Status Penghuni"
	echo " 5 | Cetak Laporan Keuangan"
	echo " 6 | Kelola Cron (Pengingat Tagihan)"
	echo " 7 | Exit Program"
	echo "======================================="
	read -p "Enter option [1-7]: " choice
}

# awk
# fitur tambah penghuni
tambah_penghuni() {
	echo " TAMBAH PENGHUNI KOST SLEBEW "
	read -p "Masukkan Nama: " nama
	read -p "Masukkan Kamar: " kamar
# grep
	read -p "Masukkan Harga Sewa: " harga
	read -p "Masukkan Tanggal Masuk (YYYY-MM-DD): " tanggal
	read -p "Status (Aktif/Nunggak): " status

	echo "$nama, $kamar, $harga, $tanggal, $status" >> $DB
	echo "[✓] Penghuni $nama berhasil ditambahkan"
	read -p "Tekan [ENTER] untuk kembali"
}

# fitur hapus penghuni
hapus_penghuni() {
	echo " HAPUS PENGHUNI KOST SLEBEW "
	read -p "Masukkan nama penghuni yang akan dihapus: " nama_hapus
# cek apakah nama ada di database
	if grep -q "^$nama_hapus," "$DB"; then
# ambil data tersebut
		data_lama=$(grep "^nama_hapus," "$DB")
		tanggal_sekarang=$(date +%Y-%m-%d)
# pindahkan ke file history_hapus.csv
		echo "$data_lama, $tanggal_sekarang" >> sampah/history_hapus.csv
# hapus dari database utama menggunakan sed
# kita buat file sementara lalu timpa file yang asli
		grep -v "^$nama_hapus," "$DB" > data/temp.csv && mv data/temp.csv "$DB"

		echo "[✓] Data penghuni \"$nama_hapus\" berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus dari sistem"
	else
		echo "[!] Nama tidak ditemukan!"
	fi
	read -p "Tekan [ENTER] untuk kembali ke menu"
}

# fitur tampilkan daftar
tampilkan_daftar() {
	clear
	echo " DAFTAR PENGHUNI KOST SLEBEW "
# cek apkah file ada dan tidak kosong
	if [ ! -s "$DB" ]; then
		echo " ( Belum ada data penghuni ) "
	else
# menggunakan awk untuk memformat tabel
		awk -F',' '
		BEGIN {
			# membuat header tabel
			printf "%-3s | %-15s | %-5s |%-12s | %-10s\n", "No", "Nama", "Kamar", "Harga Sewa", "Status"
			print "-------------------------------------------------------------------"
			aktif = 0
			nunggak = 0
		}
		{
			# mencetak baris data (NR adalah nomor baris otomatis dari awk)
			printf "%-3d | %-15s | %-5s | Rp%-10s | %-10s\n", NR, $1, $2, $3, $5

			# menghitung statistik berdasarkan kolom ke 5 (status)
			if ($5 == "Aktif") aktif++
			else if ($5 == "Nunggak") nunggak++
		}
		END {
			print "-------------------------------------------------------------------"
			printf "Total: %d penghuni | Aktif: %d | Nunggak: %d\n", NR, aktif, nunggak
		}
		' "$DB"
	fi

	echo "======================================================="
	read -p "Tekan [ENTER] untuk kembali ke menu"
}

update_status() {
	echo " UPDATE STATUS "
	read -p "Masukkan Nama Penghuni: " nama_update
	read -p "Masukkan Status Baru (Aktif/Nunggak): " status_baru

	# validasi input status agar sesuai aturan
	if [[ ! "$status_baru" =~ ^(Aktif|Nunggak|aktif|nunggak)$ ]]; then
		echo "[!] Status tidak valid! Gunakan 'Aktif' atau 'Nunggak'."
	elif grep -iq "^$nama_update," "$DB"; then
		# menggunakan sed -i untuk mengubah status di kolom ke 5
		# kita cari baris yang diawali nama tersebut, lalu ganti kata setelah koma ke 4
		# format csv: nama, kamar, harga, tanggal, status

		# cara simpel: ganti kata terakhir di baris tersehbut
		sed -i "/^$nama_update,/I s/[^,]*$/$status_baru/" "$DB"

		echo "[✓] Status $nama_update berhasil diubah menjadi: $status_baru"
	else
		echo "[!] Nama penghuni tidak ditemukan!"
	fi
	read -p "Tekan [ENTER] untuk kembali"
}

cetak_laporan() {
	clear
	echo " LAPORAN KEUANGAN KOST SLEBEW "

	laporan_teks=$(awk -F',' '
	BEGIN {
		aktif = 0; nunggak = 0; kamar = 0;
	}
	{
		kamar++;
		if ($5 ~ /^[Aa]ktif/) aktif += $3;
		else if ($5 ~ /^[Nn]unggak/) nunggak += $3;
	}
	END {
		printf "Total pemasukan (Aktif) : Rp%d\n", aktif
		printf "Total tunggakan         : Rp%d\n", nunggak
		printf "Jumlah kamar terisi     : %d\n", kamar
		print "----------------------------------------------"
		print "Daftar penghuni menunggak:"
	} ' "$DB")

	# ambil daftar nama yang nunggak aja
	daftar_nunggak=$(awk -F',' '$5 ~ /^[Nn]unggak/ {print " - " $1}' "$DB")
	if [ -z "$daftar_nunggak" ]; then daftar_nunggak=" Tidak ada tunggakan."; fi

	# tampilkan ke layar
	echo "$laporan_teks"
	echo "$daftar_nunggak"

	# simpan ke file (pakai > untuk overwrite atau >> untuk append)
	echo -e "--- Laporan Tanggal $(date) ---\n$laporan_teks\n$daftar_nunggak\n" > rekap/laporan_bulanan.txt

	echo -e "\n[✓] Laporan berhasil disimpan ke rekap/laporan_bulanan.txt"
	read -p "Tekan [ENTER] untuk kembali"
}

kelola_cron() {
	echo " PENGATURAN CRON "
	read -p "Pilih [1-3]: " cron_choice

	# ambil path lengkap (absolute path) script kamu agar cron tidak bingung
	SCRIPT_PATH=$(realpath "0")

	case $cron_choice in
		1)
			# ambil crontab yang sudah ada, tambahkan yang baru, lalu pasang lagi
			(crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH"; echo "0 7 * * * $SCRIPT_PATH --check-tagihan") | crontab -
			echo "[✓] Jadwal otomatis jam 070:00 pagi berhasil dipasang!"
			;;
		2)
			# hapus baris yang mengandung path script ini dari crontab
			crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" | crontab -
			echo "[✓] Jadwal otomatis berhasil dihapus"
			;;
		*) return ;;
	esac
	read -p "Tekan [ENTER] untuk kembali..."
}

while true; do
	show_menu
	case $choice in
		1) tambah_penghuni ;;
		2) hapus_penghuni ;;
		3) tampilkan_daftar ;;
		4) update_status ;;
		5) cetak_laporan ;;
		6) kelola_cron ;;
		7)
			echo "Terima kasih sudah menggunakan Sistem Kost Slebew!"
			echo "Sampai jumpa lagi!"
			exit 0
			;;
		*)
			echo "[!] Opsi tidak valid, silahkan pilih 1-7."
			sleep 2
			;;
	esac
done
