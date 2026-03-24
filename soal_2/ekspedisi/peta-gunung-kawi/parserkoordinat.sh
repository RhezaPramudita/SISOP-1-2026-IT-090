#!/bin/bash

# ngambil data menggunakan grep, sed, dan awk
# filter baris yang mengandung id, site_name, latitude, dan longitude
grep -E "id|site_name|latitude|longitude" gsxtrack.json | sed 's/[",]//g' | awk ' {
	if ($1 == "id:") id = $2
	if ($1 == "site_name:") name = $2
	if ($1 == "latitude:") lat = $2
	if ($1 == "longitude:") {
		lon = $2
		printf "%s,%s,%s,%s\n", id, name, lat, lon
		}
	}' > titik-penting.txt

echo "File titik-penting.txt berhasil dibuat!"
