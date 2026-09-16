# Start/show a libvirt VM from the bar.
{...}: {
  flake.wrappers.waybar = {
    lib,
    pkgs,
    config,
    ...
  }: {
    options.windowsVmDomain = lib.mkOption {
      type = lib.types.str;
      default = "win10";
      description = ''
        libvirt domain this button starts and shows. A common name as the
        default rather than an assumption about the machine — point it at
        whatever the VM is actually called.
      '';
    };

    config.settings."custom/windowsvm" = let
      inherit (config) windowsVmDomain;
      check-vm = pkgs.writeShellApplication {
        name = "check-vm";
        # sudo from the PATH, not /run/wrappers/bin/sudo: that path exists only
        # on NixOS, so the hardcoded form silently failed anywhere else.
        runtimeInputs = [pkgs.libvirt pkgs.gnugrep];
        text = ''
          # Scoped to this domain. Grepping `virsh list --all` for "running"
          # reported any VM at all, so an unrelated guest lit this up.
          if sudo virsh list --all | grep -E "\<${windowsVmDomain}\>" | grep -q "running"; then
            printf '{"tooltip": "%s running", "class": "running"}' "${windowsVmDomain}"
          else
            printf '{"tooltip": "Start %s", "class": ""}' "${windowsVmDomain}"
          fi
        '';
      };
    in {
      format = "";
      on-click = "${pkgs.libvirt}/bin/virsh --connect qemu:///system start \"${windowsVmDomain}\"; ${pkgs.systemd}/bin/systemd-run --user --unit=virt-manager-gui ${pkgs.virt-manager}/bin/virt-manager --connect qemu:///system --show-domain-console \"${windowsVmDomain}\"";
      exec = "${check-vm}/bin/check-vm";
      return-type = "json";
      restart-interval = 5;
    };
  };
}
