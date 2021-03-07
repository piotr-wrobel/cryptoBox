#!/bin/bash

    G="\033[1;32m";
    Y="\033[1;33m";
    R="\033[0;31m";
    N="\033[0;39m";
    CONTAINER_PATH="${HOME}/crypto/containers"
    MOUNT_PATH="${HOME}/mnt"

    function notification ()
    {
        echo -e "$G" "\n[+] $1" "$N"
    };

    function warning ()
    {
        echo -e "$Y" "\n[-] $1" "$N"
    };

    function error ()
    {
        echo -e "$R" "\n[!] $1" "$N"
    };

    function is_mounted ()
    {
        COUNT=`mount | grep "${MOUNT_PATH}/${vol_name}" | wc -l`;
        if [[ ${COUNT} -lt 1 ]]; then
          return 0
        else
          return 1
        fi
    }

    function is_unlocked ()
    {
      COUNT=`sudo dmsetup ls | grep "${vol_name}.(" | wc -l`;
      if [[ ${COUNT} -lt 1 ]]; then
        return 0
      else
        return 1
      fi
    }

    function checkDirectories ()
    {
      if [[ ! -d ${CONTAINER_PATH} ]]; then
        mkdir -p ${CONTAINER_PATH}
      fi
      if [[ ! -d ${MOUNT_PATH} ]]; then
        mkdir -p ${MOUNT_PATH}
      fi
    }

    function nameVol ()
    {
        checkDirectories
        read -p "Name of encrypted container (e.g., "container", "valut"): " vol_name;
        if [[ ! -n "${vol_name}" ]]; then
            full_vol_name='EncryptedContainer.cnt';
            vol_name='EncryptedContainer'
        else
          full_vol_name="${vol_name}.cnt"
        fi
        case $1 in
          open)
            if [[ ! -f "${CONTAINER_PATH}/${full_vol_name}" ]]; then
              warning "Sorry, but container ${vol_name} doesn't exist...."
              exit 0;
            fi
          ;;
          create)
          if [[ -f "${CONTAINER_PATH}/${full_vol_name}" ]]; then
            warning "Sorry, but container ${vol_name} already exist !!!"
            exit 0;
          fi
          ;;
          close)
          ;;
          *)
            error "ERROR: Undefinied option in nameVol() calling !"
            exit 0;
          ;;
        esac
    };

    function nameKey ()
    {
        read -p "Name of Key file (e.g., "master.keyfile", "image.jpg"): " key_file;
        if [[ ! -n "${key_file}" ]]; then
            key_file='master.keyfile';
        fi
    };

    function nameSize ()
    {
        read -p "Choose volume size (e.g., 10G, 200M): " vol_size;
        if [[ ! -n "${vol_size}" ]]; then
            vol_size='1G';
        fi
    };

    function ddZero ()
    {
        dd if=/dev/zero of="${CONTAINER_PATH}/${full_vol_name}" bs=1 count=0 seek="${vol_size}" && notification "Empty volume created."
    };

    function ddRandom ()
    {
        dd if=/dev/urandom of="${CONTAINER_PATH}/${key_file}" bs=4096 count=1 && notification "Key file successfully created."
    };

    function encryptCon ()
    {
        #sudo cryptsetup -y -c aes-xts-plain64 -s 512 -h sha512 -i 5000 --use-random luksFormat "${CONTAINER_PATH}/${full_vol_name}" "${CONTAINER_PATH}/${key_file}" && notification "Encrypted container created."
        sudo cryptsetup -y -c aes-xts-plain64 -s 512 -h sha512 -i 5000 --use-random luksFormat "${CONTAINER_PATH}/${full_vol_name}" && notification "Encrypted container created."
    };

    function encryptOpen ()
    {
        #sudo cryptsetup luksOpen "${full_vol_name}" "$vol_name" --key-file "${CONTAINER_PATH}/${key_file}" && notification "Volume unlocked."
        is_unlocked
        if [[ $? -eq 1 ]]; then
          warning "Container ${vol_name} is already open !"
        else
          sudo cryptsetup luksOpen "${CONTAINER_PATH}/${full_vol_name}" "${vol_name}" && notification "Volume unlocked."
        fi
    };

    function encryptClose ()
    {
      is_unlocked
      if [[ $? -eq 0 ]]; then
        warning "Container ${vol_name} is not open !"
      else
        sudo dmsetup remove /dev/mapper/"${vol_name}" && notification "Container closed."
      fi
    };

    function mkfsFormat ()
    {
        sudo mkfs.ext4 /dev/mapper/"${vol_name}" && notification "Volume formatted."
    };

    function mountDir ()
    {
      if [[ ! -d "${MOUNT_PATH}/${vol_name}" ]]; then
        mkdir -p "${MOUNT_PATH}/${vol_name}"
      fi
      is_mounted
      if [[ $? -eq 1 ]]; then
        warning "Container ${vol_name} is already mounted !"
      else
        sudo mount /dev/mapper/"${vol_name}" "${MOUNT_PATH}/${vol_name}"/ && notification "Volume mounted."
      fi
    };

    function umountDir ()
    {
      is_mounted
      if [[ $? -eq 0 ]]; then
        warning "Container ${vol_name} is not mounted !"
      else
        sudo umount "${MOUNT_PATH}/${vol_name}"/ && notification "Volume umounted."
      fi
    }

    function volPerm ()
    {
        sudo chown -R "$USER":"$USER" "${MOUNT_PATH}/${vol_name}" && notification "Volume permissions set."
    };
