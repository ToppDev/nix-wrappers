{...}: {
  perSystem = {pkgs, ...}: {
    packages.syspre = pkgs.writeShellApplication {
      name = "syspre";
      runtimeInputs = with pkgs; [libvirt gnugrep zenity docker];
      text = ''
        if sudo virsh list --all | grep -q "running" \
            && ! zenity --question --width=400 --title "Do you really want to $1?" --text="<b>There are virtual machines running</b>\n\n$(sudo virsh list --all)"; then
          exit 1
        fi
        if sudo docker container ls | grep -q -i "forgejo" \
            && ! zenity --question --width=400 --title "Do you really want to $1?" --text="<b>There are Git actions running</b>\n\n$(sudo docker container ls)"; then
          exit 1
        fi
        exit 0
      '';
    };
  };
}
