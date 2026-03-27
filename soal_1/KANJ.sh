BEGIN {
	FS = ","
	opsi = ARGV[2]
	delete ARGV[2]
}

# melewati header (tidak  usah baca headernya)
NR == 1 { next }
{
	total++
	if (daftar_gerbong[$4] == 0) {
	total_gerbong++
	daftar_gerbong[$4] = 1
	}
	if ($2 > umur_maksimal) {
	umur_maksimal = $2
	nama_tertua = $1
	}
	jumlah_usia += $2
	if ($3 == "Business") {
	total_business++
	}
}
END {
	if (opsi == "a") {
	printf "Jumlah seluruh penumpang KANJ adalah %d orang\n", total
	}
	else if (opsi == "b") {
	printf "Jumlah gerbong penumpang KANJ adalah %d\n", total_gerbong
	}
	else if (opsi == "c") {
	printf "%s adalah penumpang kereta tertua dengan usia %d tahun\n", nama_tertua, umur_maksimal
	}
	else if (opsi == "d") {
	rata_rata = jumlah_usia / total
	printf "Rata-rata usia penumpang adalah %d tahun\n", int(rata_rata)
	}
	else if (opsi == "e") {
	printf "Jumlah penumpang business class ada %d orang\n", total_business
	}
	else {
	printf "Soal tidak dikenali\n"
	}
}
