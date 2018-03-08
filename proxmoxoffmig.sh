#!/bin/bash
# Emirsah KURSATOGLU
# www.emirsah.com
# Linux, remote server run command script

USR="Your Server Username"
PORT="Your Server Port Number"
PASSWORD="Your PASSWORD"
NOW=$(date +'%Y_%m_%d')
echo Process Date $NOW
echo ""
read  -p "Enter Proxmox Server IP Address (e.g. XX.XX.XX.XX) : " proxmox_ip
echo ""
    read  -p "Enter VM to be migrate (e.g. XXXX) : " vm_id
echo ""
echo -n "$vm_id will be turned off (y/n) :  "
    read TURNED
        if echo "$TURNED" | grep -iq "^n" ;then
            exit 1
        else
            STOP=$( sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no -p $PORT  $USR@$proxmox_ip  qm stop $vm_id)
        fi
    sleep 10
        if [[ $STOP = *"running"* ]]; then
            exit 1
        else
            echo -n "$vm_id status stopped "
echo ""
echo ""
            echo -n "I will now take a backup of $vm_id"
echo ""
            echo -n "Are you sure ?  (y/n) : "
        fi
    read BNOW
        if echo "$BNOW" | grep -iq "^n" ;then
            exit 1
        else
            BACKUP=$( sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no -p $PORT  $USR@$proxmox_ip  "vzdump  $vm_id --storage local")
        fi
            Backup_File=$( sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no -p $PORT  $USR@$proxmox_ip  "ls  /var/lib/vz/dump/ | grep $vm_id | grep $NOW | grep vma")
echo ""
echo "Backup Was Created"
        echo  Back File Name : $Backup_File
PATHLOC="/var/lib/vz/dump/$Backup_File"
echo "Backup File Path Location $PATHLOC"
echo ""
        echo -n "$vm_id will be migrate ? (y/n) :"
    read MIG
        if echo "$MIG" | grep -iq "^n" ;then
            exit 1
        else
    read  -p "Enter Migrate Proxmox Server IP Address (e.g. XX.XX.XX.XX) : " proxmig_ip
SCPMIG="/usr/bin/sshpass -p $PASSWORD scp -o StrictHostKeyChecking=no -r $PATHLOC root@$proxmig_ip:$PATHLOC"
Migration=$( sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no -p $PORT  $USR@$proxmox_ip  $SCPMIG)
        fi
echo ""
echo "backup file moved to $proxmig_ip Proxmox Server"
echo ""
echo ""
        echo -n "$vm_id restore over $proxmig_ip Proxmox Server ? (y/n) :"
    read RESTORE
        if echo "$RESTORE" | grep -iq "^n" ;then
    echo "Only file transfer not restore $vm_id proxmox server"
        sleep 5
            exit 1
        else
REST="qmrestore $PATHLOC $vm_id"
RESTPROX=$( sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no -p $PORT  $USR@$proxmig_ip  $REST)
        fi
echo ""
echo "Restore is complete .) "
echo ""
        echo -n "$vm_id will be turned online (y/n) :  "
    read ONLINE
        if echo "$ONLINE" | grep -iq "^n" ;then
    echo "Restore is complete, you can use your server"
        sleep 5
            exit 1
        else
PROXONLINE=$( sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no -p $PORT  $USR@$proxmig_ip  qm start $vm_id)
        fi
        if [[ $PROXONLINE = *"running"* ]]; then
    echo "Server Status Running "
        sleep 3
            exit 1
        else
    echo "Please check $vm_id"
        sleep 3
        fi
