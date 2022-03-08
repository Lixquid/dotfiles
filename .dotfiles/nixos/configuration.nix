{ config, pkgs, lib, ... }:

{
    imports = [
        ./hardware-configuration.nix
        ./secrets.nix
    ];

    environment.systemPackages = with pkgs; [
        bc
        brightnessctl
        dotnet-sdk_5
        firefox
        gcc
        gimp
        git
        i3status-rust
        inkscape
        jetbrains.rider
        keepass
        libreoffice
        maim
        mullvad-vpn
        neovim
        nodejs
        nodePackages.yarn
        openscad
        powershell
        pulseaudio
        redshift
        rustup
        vlc
        vscodium-fhs
        xclip
        xfce.thunar
        xfce.xfce4-terminal
        xss-lock
        youtube-dl
    ];

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "rider"
    ];

    fonts.fonts = with pkgs; [
        fira-code
        font-awesome
    ];

    boot.loader.systemd-boot.enable = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    powerManagement = {
        enable = true;
        powertop.enable = true;
    };

    networking = {
        hostName = "Artemis";

        useDHCP = false;
        interfaces.wlp170s0.useDHCP = true;

        wireless = {
            enable = true;
            interfaces = ["wlp170s0"];
            userControlled.enable = true;
            networks = {
                # Wifi networks
                # "Free WiFi SSID" = {};
                # "Private Wifi".psk = "password";
            };
        };

        # Needed for mullvad
        firewall.checkReversePath = "loose";
        wireguard.enable = true;

        firewall.allowedTCPPortRanges = [
            { from = 65000; to = 65200; }
        ];
        firewall.allowedUDPPortRanges = [
            { from = 65000; to = 65200; }
        ];
    };

    hardware = {
        pulseaudio.enable = true;
        logitech.wireless = {
            enable = true;
            enableGraphical = true;
        };
        opengl.extraPackages = with pkgs; [
            mesa_drivers
            vaapiIntel
            vaapiVdpau
            libvdpau-va-gl
            intel-media-driver
        ];
    };
    security.pam.services.sudo.fprintAuth = true;

    time.timeZone = "Europe/London";

    services = {
        xserver = {
            enable = true;
            layout = "gb";
            xkbOptions = "caps:escape";

            libinput.enable = true;
            windowManager.i3.enable = true;
        };
        # Fingerprint Sensor
        fprintd.enable = true;
        # Thermal Sensor
        thermald.enable = true;

        mullvad-vpn.enable = true;
        logind.lidSwitch = "suspend";
    };

    users = {
        mutableUsers = false;
        users.jon = {
            isNormalUser = true;
            shell = pkgs.powershell;
            extraGroups = ["wheel"];
            # Generate with mkpasswd -m sha-512
            # hashedPassword = "";
        };
    };
}
