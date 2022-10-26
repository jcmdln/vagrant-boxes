;; SPDX-License-Identifier: ISC

(use-modules
  (gnu)
  (gnu packages)
  (gnu services linux))
(use-service-modules networking ssh)
(use-package-modules screen ssh)

(operating-system
  (host-name "guix")
  (locale "en_US.utf8")
  (timezone "America/New_York")

  (initrd-modules (cons
    "virtio_scsi"
    %base-initrd-modules))

  (bootloader (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (target "/boot/efi")))

  (file-systems (append
    (list
      (file-system
        (device (file-system-label "guix"))
        (mount-point "/")
        (options "compress=zstd,subvol=root")
        (type "btrfs"))
      (file-system
        (device (file-system-label "guix"))
        (mount-point "/gnu")
        (options "noatime,compress=zstd,subvol=gnu")
        (type "btrfs"))
      (file-system
        (device (file-system-label "guix"))
        (mount-point "/home")
        (options "compress=zstd,subvol=home")
        (type "btrfs")))
    %base-file-systems))

  (packages (append
    (map specification->package '(
      "btrfs-progs"
      "curl"
      "emacs-no-x"
      "inetutils"
      "links"
      "tmux"
      "unzip"
      "vim"))
    %base-packages))

  (services (append
    (list
      (service dhcp-client-service-type)
      (service openssh-service-type (openssh-configuration
        (openssh openssh-sans-x)
        (port-number 22)))
      (service zram-device-service-type (zram-device-configuration
        (memory-limit "1G")
        (size "512M"))))
    %base-services))

  (users (cons
    (user-account
      (name "vagrant")
      (group "users")
      (supplementary-groups '("wheel")))
    %base-user-accounts))
) ;; operating-system
