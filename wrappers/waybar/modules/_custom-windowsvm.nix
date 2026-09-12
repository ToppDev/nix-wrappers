# Start/show a libvirt VM. `domain` is a parameter rather than a constant so a
# consumer can point it at whatever their VM is called; the default is only a
# common name, not an assumption about the machine this runs on.
{
  pkgs,
  domain ? "win10",
  ...
}: {
  format = "";
  on-click = "${pkgs.libvirt}/bin/virsh --connect qemu:///system start \"${domain}\"; ${pkgs.systemd}/bin/systemd-run --user --unit=virt-manager-gui ${pkgs.virt-manager}/bin/virt-manager --connect qemu:///system --show-domain-console \"${domain}\"";
  exec = let
    check-vm = pkgs.writeShellApplication {
      name = "check-vm";
      # sudo from the PATH, not /run/wrappers/bin/sudo: that path exists only on
      # NixOS, so the hardcoded form made the module silently fail anywhere else.
      runtimeInputs = [pkgs.libvirt pkgs.gnugrep];
      text = ''
        # Scoped to this domain. `virsh list --all | grep running` reported any
        # VM at all, so an unrelated guest lit this up as if it were ours.
        if sudo virsh list --all | grep -E "\<${domain}\>" | grep -q "running"; then
          printf '{"tooltip": "%s running", "class": "running"}' "${domain}"
        else
          printf '{"tooltip": "Start %s", "class": ""}' "${domain}"
        fi
      '';
    };
  in "${check-vm}/bin/check-vm";
  return-type = "json";
  restart-interval = 5;
}
