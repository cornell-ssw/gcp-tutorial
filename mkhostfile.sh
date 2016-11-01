gcloud compute instances list | awk 'NR>1 { print $1 }' > ~/machines.txt

