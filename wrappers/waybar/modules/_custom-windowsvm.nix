{pkgs, ...}: {
  format = "";
  on-click = "${pkgs.libvirt}/bin/virsh --connect qemu:///system start \"win10\"; ${pkgs.systemd}/bin/systemd-run --user --unit=virt-manager-gui ${pkgs.virt-manager}/bin/virt-manager --connect qemu:///system --show-domain-console \"win10\"";
  exec = let
    check-vm = pkgs.writeShellApplication {
      name = "check-vm";
      runtimeInputs = [pkgs.libvirt pkgs.gnugrep];
      text = ''
        if /run/wrappers/bin/sudo virsh list --all | grep -q "running"; then
          printf '{"tooltip": "Windows VM running", "class": "running"}'
        else
          printf '{"tooltip": "Start Windows VM", "class": ""}'
        fi
      '';
    };
  in "${check-vm}/bin/check-vm";
  return-type = "json";
  restart-interval = 5;
}
