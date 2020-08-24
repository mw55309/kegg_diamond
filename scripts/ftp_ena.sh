#!/bin/bash
ftp_urls=$(curl "https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=${1}&result=read_run&fields=fastq_ftp" -s | sed -n 2p)

url_list=$(echo $ftp_urls | tr ";" "\n")

for addr in $url_list
do
	curl  $addr -O -sS
done

