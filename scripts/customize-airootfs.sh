#!/usr/bin/env bash
set -euo pipefail
for package in linux-cachyos linux-cachyos-lts; do
  for marker in /usr/lib/modules/*/pkgbase; do
    [[ $(cat "$marker") == "$package" ]] || continue
    kernel_dir="${marker%/pkgbase}"
    install -m644 "$kernel_dir/vmlinuz" "/boot/vmlinuz-$package"
    mkinitcpio -k "${kernel_dir##*/}" -c /etc/mkinitcpio.conf.d/archiso.conf -g "/boot/initramfs-$package.img"
    break
  done
  test -s "/boot/initramfs-$package.img"
done
