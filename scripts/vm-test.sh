#!/usr/bin/env bash
# Hard Gaming OS – QEMU-Testlauf mit seriellem Bootlog (für die Build-/Test-VM).
#
#   ./scripts/vm-test.sh live   ISO uefi|bios      ISO starten, leere Zielplatte angehängt
#   ./scripts/vm-test.sh direct ISO std|lts        Kernel+initramfs direkt booten (Parameter aus grub.cfg der ISO)
#   ./scripts/vm-test.sh disk   NAME uefi|bios     Installierte Platte OHNE ISO starten
#   ./scripts/vm-test.sh shot   NAME BILDNAME      Screenshot der laufenden VM (echter VM-Screenshot)
#
# NAME ist der Name der VM (Standard: Dateiname der ISO ohne .iso). Logs, Platte und
# UEFI-Variablen liegen unter dist/vm/NAME/ – außerhalb des Staging-Verzeichnisses.
# Im Bootmenü für den Diagnosestart den Eintrag „(Diagnose: seriell, ohne Splash)“ wählen.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
usage() { sed -n '3,12p' "$0" >&2; exit 2; }
[[ $# -ge 3 ]] || usage
MODE="$1"; shift
RAM="${HGOS_VM_RAM:-8192}"; CPUS="${HGOS_VM_CPUS:-4}"; DISK_SIZE="${HGOS_VM_DISK:-64G}"
DISPLAY_OPT="${HGOS_VM_DISPLAY:-gtk}"
command -v qemu-system-x86_64 >/dev/null || { echo 'qemu-system-x86_64 fehlt (pacman -S qemu-full)' >&2; exit 3; }

accel=(-machine q35)
if [[ -w /dev/kvm ]]; then accel=(-machine q35,accel=kvm -cpu host); else echo 'Hinweis: ohne KVM (sehr langsam)' >&2; fi

find_ovmf() {
  for dir in /usr/share/edk2/x64 /usr/share/edk2-ovmf/x64 /usr/share/OVMF /usr/share/ovmf/x64; do
    for code in OVMF_CODE.4m.fd OVMF_CODE.fd; do
      vars="${code/CODE/VARS}"
      [[ -f "$dir/$code" && -f "$dir/$vars" ]] && { echo "$dir/$code $dir/$vars"; return; }
    done
  done
  echo 'OVMF fehlt (pacman -S edk2-ovmf)' >&2; exit 3
}

vm_dir() { local d="$ROOT/dist/vm/$1"; mkdir -p "$d/logs" "$d/screenshots"; echo "$d"; }

firmware_args() { # $1=uefi|bios $2=vmdir
  [[ "$1" == bios ]] && return 0
  [[ "$1" == uefi ]] || usage
  read -r code vars < <(find_ovmf) || true
  [[ -n "${code:-}" ]] || exit 3
  # Persistente Variablen pro VM, sonst geht der von Calamares angelegte Booteintrag verloren.
  [[ -f "$2/OVMF_VARS.fd" ]] || cp "$vars" "$2/OVMF_VARS.fd"
  printf '%s\n' -drive "if=pflash,format=raw,readonly=on,file=$code" -drive "if=pflash,format=raw,file=$2/OVMF_VARS.fd"
}

common_args() { # $1=vmdir $2=logname
  local serial="$1/logs/$2-$(date +%Y%m%d-%H%M%S)-serial.log"
  echo "Serielles Log: $serial" >&2
  printf '%s\n' "${accel[@]}" -m "$RAM" -smp "$CPUS" \
    -vga virtio -display "$DISPLAY_OPT" \
    -nic user,model=virtio-net-pci \
    -serial "file:$serial" \
    -monitor "unix:$1/monitor.sock,server,nowait" \
    -drive "file=$1/disk.qcow2,if=virtio,format=qcow2"
}

ensure_disk() { [[ -f "$1/disk.qcow2" ]] || qemu-img create -f qcow2 "$1/disk.qcow2" "$DISK_SIZE" >/dev/null; }

iso_read() { # $1=iso $2=path-in-iso
  if command -v bsdtar >/dev/null; then bsdtar -xOf "$1" "${2#/}" 2>/dev/null
  elif command -v xorriso >/dev/null; then xorriso -osirrox on -indev "$1" -extract "$2" /dev/stdout 2>/dev/null
  else echo 'bsdtar oder xorriso nötig' >&2; exit 3; fi
}

case "$MODE" in
  live)
    ISO="$(realpath -e "$1")"; FW="$2"; NAME="${HGOS_VM_NAME:-$(basename "$ISO" .iso)}"
    D="$(vm_dir "$NAME")"; ensure_disk "$D"
    sha256sum "$ISO" | tee "$D/logs/iso.sha256"
    mapfile -t fw < <(firmware_args "$FW" "$D")
    [[ "$FW" == bios || ${#fw[@]} -gt 0 ]] || { echo 'UEFI-Firmware nicht eingerichtet' >&2; exit 3; }
    mapfile -t args < <(common_args "$D" "live-$FW")
    exec qemu-system-x86_64 "${args[@]}" "${fw[@]}" -cdrom "$ISO" -boot order=d,menu=on
    ;;
  direct)
    ISO="$(realpath -e "$1")"; KERNEL="$2"; NAME="${HGOS_VM_NAME:-$(basename "$ISO" .iso)}"
    [[ "$KERNEL" == std || "$KERNEL" == lts ]] || usage
    D="$(vm_dir "$NAME")"; ensure_disk "$D"; W="$D/direct"; rm -rf "$W"; mkdir -p "$W"
    cfg=""
    for path in /boot/grub/grub.cfg /boot/grub/loopback.cfg /grub/grub.cfg /EFI/BOOT/grub.cfg; do
      cfg="$(iso_read "$ISO" "$path" || true)"; [[ -n "$cfg" ]] && { echo "Menü: $path" >&2; break; }
    done
    [[ -n "$cfg" ]] || { echo 'Kein GRUB-Menü in der ISO gefunden' >&2; exit 4; }
    # Ersten regulären (nicht Diagnose-, nicht nomodeset-) Eintrag des gewählten Kernels nehmen.
    linux_line="$(grep -E '^[[:space:]]+linux ' <<<"$cfg" | grep -v -e nomodeset -e ttyS0 | \
      { if [[ "$KERNEL" == lts ]]; then grep -- '-lts'; else grep -v -- '-lts'; fi; } | head -n1)"
    [[ -n "$linux_line" ]] || { echo "Kein Menüeintrag für Kernel $KERNEL" >&2; exit 4; }
    read -r _ kpath kparams <<<"$linux_line"
    ipath="/arch/boot/x86_64/initramfs-${kpath##*/vmlinuz-}.img"
    iso_read "$ISO" "$kpath" > "$W/vmlinuz"; iso_read "$ISO" "$ipath" > "$W/initramfs.img"
    [[ -s "$W/vmlinuz" && -s "$W/initramfs.img" ]] || { echo "Kernel/initramfs fehlt: $kpath $ipath" >&2; exit 4; }
    kparams="$(sed -E 's/(^| )(quiet|splash)( |$)/ /g' <<<"$kparams") console=tty0 console=ttyS0,115200n8 plymouth.enable=0 loglevel=7 systemd.show_status=1 systemd.log_target=console rd.udev.log_level=info"
    printf 'Kernel: %s\nInitramfs: %s\nParameter: %s\n' "$kpath" "$ipath" "$kparams" | tee "$D/logs/direct-$KERNEL-cmdline.txt"
    mapfile -t args < <(common_args "$D" "direct-$KERNEL")
    exec qemu-system-x86_64 "${args[@]}" -cdrom "$ISO" -kernel "$W/vmlinuz" -initrd "$W/initramfs.img" -append "$kparams"
    ;;
  disk)
    NAME="$1"; FW="$2"; D="$(vm_dir "$NAME")"
    [[ -f "$D/disk.qcow2" ]] || { echo "Keine Platte: $D/disk.qcow2" >&2; exit 4; }
    mapfile -t fw < <(firmware_args "$FW" "$D")
    [[ "$FW" == bios || ${#fw[@]} -gt 0 ]] || { echo 'UEFI-Firmware nicht eingerichtet' >&2; exit 3; }
    mapfile -t args < <(common_args "$D" "disk-$FW")
    exec qemu-system-x86_64 "${args[@]}" "${fw[@]}" -boot order=c
    ;;
  shot)
    NAME="$1"; D="$ROOT/dist/vm/$NAME"; OUT="$D/screenshots/$2"
    command -v socat >/dev/null || { echo 'socat fehlt' >&2; exit 3; }
    printf 'screendump %s.ppm\n' "$OUT" | socat - "UNIX-CONNECT:$D/monitor.sock" >/dev/null
    sleep 1
    if command -v magick >/dev/null; then magick "$OUT.ppm" "$OUT.png" && rm -f "$OUT.ppm"; echo "$OUT.png"; else echo "$OUT.ppm"; fi
    ;;
  *) usage;;
esac
