{
  self,
  inputs,
  ...
}: {
  flake.wrappers.environment = {pkgs, ...}: let
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [self.wrapperModules.zsh];
    binName = "zsh";
    runtimePkgs = with pkgs; [
      # nix
      nil # Yet another language server for Nix
      nixd # Feature-rich Nix language server interoperating with C++ nix
      statix # Lints and suggestions for the nix programming language
      alejandra # Uncompromising Nix Code Formatter
      nix-inspect # Interactive TUI for inspecting nix configs and other expressions
      unstable.devenv # Per-project declarative development environments
      selfpkgs.nixos-rollback

      vim
      tree
      wget
      htop
      btop
      gnugrep
      gawk
      usbutils
      jq
      dysk

      ripgrep
      fzf
      fd
      eza
      glow
      just
      zoxide
      zellij # Terminal workspace with batteries included
      unstable.herdr # Agent multiplexer that lives in your terminal

      # wrapped
      selfpkgs.bat
      selfpkgs.git
      selfpkgs.helix
      selfpkgs.lazygit
      selfpkgs.tmux
    ];
  };
}
