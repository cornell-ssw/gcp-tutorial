gcloud compute instances list | awk 'NR>1 { print $4 }' > ~/machines.txt

