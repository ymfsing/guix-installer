
;; https://github.com/podiki/dot.me/blob/master/guix/.config/guix/config.scm
;; https://github.com/daviwil/dotfiles/blob/master/Systems.org

;; Indicate which modules to import to access the variables used in this configuration.
(use-modules (gnu)
             (guix channels)
             (guix inferior)
             (nongnu packages linux)
             (nongnu system linux-initrd)
             (srfi srfi-1)
             )


(use-service-modules cups desktop networking sddm ssh xorg)


(define %my-desktop-services

  (modify-services %desktop-services

                   ;; use sddm instead of gdm
                   (delete gdm-service-type)

                   ;; substitute
                   ;; https://substitutes.nonguix.org/
                   ;; http://substitutes.guix.sama.re/

                   (guix-service-type
                    config => (guix-configuration
                               (inherit config)
                               (substitute-urls
                                (append (list "https://substitutes.nonguix.org")
                                        %default-substitute-urls))
                               (authorized-keys
                                (append
                                 (list
                                  (plain-file "nonguix.pub"
                                              "
(public-key
 (ecc
  (curve Ed25519)
  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)
  )
 )"))
                                 %default-authorized-guix-keys))))))


(operating-system

 ;; https://gitlab.com/nonguix/nonguix
 ;; (kernel linux)

 ;; Pinning kernel version
 (kernel
  (let*
      ((channels
        (list (channel
               (name 'nonguix)
               (url "https://gitlab.com/nonguix/nonguix")
               (branch "master")
               (commit "c1358b112f75b77b9bdca69fe1f135acc8998fc3"))
              (channel
               (name 'guix)
               (url "https://git.savannah.gnu.org/git/guix.git")
               (branch "master")
               (commit "bf0740235543a365bfb7c8a662969f5bb05b9496"))))
       (inferior (inferior-for-channels channels)))
    (first (lookup-inferior-packages inferior "linux" "5.19.17"))))

 (initrd microcode-initrd)

 (firmware (list linux-firmware))

 (host-name "GUIX")
 (locale "en_US.utf8")
 (timezone "Asia/Shanghai")
 (keyboard-layout (keyboard-layout "us"))

 ;; The list of user accounts ('root' is implicit).
 (users (cons* (user-account
                (name "ymfsing")
                (comment "ymfsing")
                (group "users")
                (home-directory "/home/ymfsing")
                (supplementary-groups '("wheel" "netdev" "audio" "video")))
               %base-user-accounts))

 ;; The list of packages
 (packages (append
            (map specification->package
                 (list

				  "bluez"
				  "bluez-alsa"
				  "tlp"
				  "pulseaudio"

				  "exfat-utils"
				  "fuse-exfat"
				  "ntfs-3g"

                  "openssl"
				  "iptables"
				  "nss-certs"
				  "network-manager-applet"

                  "sugar-light-sddm-theme"

				  "i3-wm"
				  "i3status"
                  "i3lock"
				  "rofi"

				  "alacritty"
				  "st"

				  "neofetch"
				  "git"
				  "ripgrep"

				  "emacs-next"

				  "font-gnu-unifont"
				  "font-dejavu"
				  "font-lxgw-wenkai"

				  "ungoogled-chromium"
                  "zathura"
				  ))
            %base-packages))

 ;; Below is the list of system services.  To search for available
 ;; services, run 'guix system search KEYWORD' in a terminal.
 (services (append
            (list
             ;; (service tlp-service-type)

             ;; (service cups-service-type)

             ;; To configure OpenSSH, pass an 'openssh-configuration'
             ;; record as a second argument to 'service' below.
             (service openssh-service-type
		              (openssh-configuration
		               (port-number 2222)))

             (service sddm-service-type
                      (sddm-configuration
                       (theme "sugar-light")))

             ;; (set-xorg-configuration
             ;;  (xorg-configuration (keyboard-layout keyboard-layout)))

             )

            %my-desktop-services))

 ;; Allow resolution of '.local' host names with mDNS.
 ;; (name-service-switch %mdns-host-lookup-nss)

 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets (list "/boot/efi"))
              (keyboard-layout keyboard-layout)))

 (swap-devices (list (swap-space
                      (target (uuid
                               "xxxx")))))

 ;; The list of file systems that get "mounted".  The unique
 ;; file system identifiers there ("UUIDs") can be obtained
 ;; by running 'blkid' in a terminal.
 (file-systems (cons* (file-system
                       (mount-point "/boot/efi")
                       (device (uuid "xxxx"
                                     'fat32))
                       (type "vfat"))

                      (file-system
                       (mount-point "/")
                       (device (uuid
                                "xxxx"
                                'ext4))
                       (type "ext4"))

                      %base-file-systems))

 )
