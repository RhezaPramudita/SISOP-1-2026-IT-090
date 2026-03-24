#!/bin/bash

# ambil koordinat titik ke 1 (x1, y1)
lat1=$(awk -F',' 'NR==1 {print $3}' titik-penting.txt)
lon1=$(awk -F',' 'NR==1 {print $4}' titik-penting.txt)

# ambil koordinat titik ke 3 (x2, y2) - diagonalnya
lat2=$(awk -F',' 'NR==3 {print $3}' titik-penting.txt)
lon2=$(awk -F',' 'NR==3 {print $4}' titik-penting.txt)

# hitung titik tengah (latitude, longitude) menggunakan bc
# rumus: (y1+y2)/2 dan (x1+x2)/2
mid_lat=$(echo "scale=10; ($lat1 + $lat2) / 2" | bc)
mid_lon=$(echo "scale=10; ($lon1 + $lon2) / 2" | bc)

# output hasil ke terminal dan simpan ke file
echo "Koordinat pusat:" | tee posisipusaka.txt
echo "$mid_lat, $mid_lon" | tee -a posisipusaka.txt
