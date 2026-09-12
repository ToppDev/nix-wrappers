# Pre-flight check for the power scripts: refuse to shut down or reboot while
# work is still running, after asking.
{...}: {
  perSystem = {pkgs, ...}: {
    packages.syspre = pkgs.writeShellApplication {
      name = "syspre";
      runtimeInputs = with pkgs; [libvirt gnugrep zenity docker];
      text = ''
        # Which containers count as "still busy" is a property of the machine,
        # not of this script, so it is an override rather than a constant.
        container_pattern="''${SYSPRE_CONTAINER_PATTERN:-forgejo}"

        if sudo virsh list --all | grep -q "running" \
            && ! zenity --question --width=400 --title "Do you really want to $1?" --text="<b>There are virtual machines running</b>\n\n$(sudo virsh list --all)"; then
          exit 1
        fi
        if [ -n "$container_pattern" ] \
            && sudo docker container ls | grep -q -i "$container_pattern" \
            && ! zenity --question --width=400 --title "Do you really want to $1?" --text="<b>There are containers still running</b>\n\n$(sudo docker container ls)"; then
          exit 1
        fi
        exit 0
      '';
    };
  };
}
