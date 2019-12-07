#!/bin/bash


size=400000

mkdir -p drives
loops=()
for i in 1 2 3 4 5 6
do
  dd if=/dev/zero of=drives/drv$i count=$size
  loops+=($(losetup --show -f drives/drv$i))
done
mdadm --create /dev/md42 --level=6 --raid-devices=6 ${loops[@]}
#sleep 1
echo "Raid content is ok!" > /dev/md42
#sleep
echo "raid array created"
sleep 1
for i in 0 1 2 3 4 5
do
  dd if=/dev/zero of=${loops[@]:$i:1}
  #dd if=/dev/zero of=${loops[@]:5:1}
  sleep 1
  #read -n 1 -s -r -p "Press any key to continue"
  echo -e "\n"
  mdadm --stop /dev/md42
  sleep 1
  #dd if=/dev/zero of=${loops[@]:4:1}
  #dd if=/dev/zero of=${loops[@]:5:1}
  
  
  sleep 1
  mdadm --assemble /dev/md42 --run --force ${loops[@]:0:$i} ${loops[@]:(($i+1))}
  mdadm -D /dev/md42
  sleep 1
  mdadm -D /dev/md42
  mdadm --add /dev/md42 ${loops[@]:$i:1}
  mdadm -D /dev/md42
  sleep 1
  mdadm -D /dev/md42
done
#read -n 1 -s -r -p "Press any key to continue"
echo -e "\n"

#sleep
#echo ${loops[@]:1}

cat /dev/md42

mdadm --stop /dev/md42
for lod in ${loops[@]}
do
  losetup -d $lod
done
rm -rf drives

