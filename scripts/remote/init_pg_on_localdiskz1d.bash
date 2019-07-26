#!bin/bash

if [[ ! -d /mnt/main ]]
then
  #Stop the Postgres server:
  sudo service postgresql stop
  sleep 1
  echo "z1d instance: partitioning and formatting ephemeral NVMe SSD before test..."
  sudo parted /dev/nvme1n1 mklabel msdos
  sudo parted -a optimal /dev/nvme1n1 mkpart primary ext4 0%  69.9GB
  sudo mkfs.ext4 /dev/nvme1n1p1
  sudo mount /dev/nvme1n1p1 /mnt -t ext4
  sleep .5
  #Move the database files to the new data disk:
  echo "z1d instance: moving postgresql to the ephemeral drive before test..."
  sudo mv /var/lib/postgresql/9.5/main /mnt/main
  sudo -u postgres ln -s /mnt/main /var/lib/postgresql/9.5/main 
  sleep 1
  #Edit postgresql.conf:
  #CFG=/etc/postgresql/9.5/main/postgresql.conf
  #K=data_directory
  #V=\'/mnt/postgres-data9.5\'
  #sudo sed -i "/^$K/c$K = $V" $CFG

  #Start Postgres:
  sudo service postgresql start
  sleep 15
fi
