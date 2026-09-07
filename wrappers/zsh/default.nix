{self, ...}: {
  flake.wrappers.zsh = {
    wlib,
    pkgs,
    lib,
    ...
  }: let
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    rm-or-trash = pkgs.writeShellApplication {
      name = "rm-or-trash";
      runtimeInputs = [pkgs.rmtrash pkgs.coreutils];
      text = builtins.readFile ./rm-or-trash.sh;
    };
  in {
    imports = [wlib.wrapperModules.zsh];
    zshAliases = {
      ":q" = "exit";
      ":qa" = "exit";
      cp = "cp -iv";
      mv = "mv -iv";
      bc = "bc -ql";
      mkd = "mkdir -pv";
      ffmpeg = "${lib.getExe pkgs.ffmpeg} -hide_banner";
      ls = "${lib.getExe pkgs.eza} --color=always --icons=always --group-directories-first";
      ll = "${lib.getExe pkgs.eza} --color=always --long --git --icons=always --group-directories-first --all --group";
      grep = "${pkgs.ripgrep}/bin/rg";
      diff = "${pkgs.diffutils}/bin/diff --color=auto";
      df = "${lib.getExe pkgs.dysk} --units=binary";
      ccat = "${lib.getExe pkgs.highlight} --out-format=ansi";
      wget = "${lib.getExe pkgs.wget} --no-hsts";
      # hx = "helix";

      # rm = "rm -vI";
      rm = "${lib.getExe rm-or-trash} -I";
      rmdir = "${pkgs.rmtrash}/bin/rmdirtrash";
      trash-restore = "${pkgs.trashy}/bin/trash list | ${lib.getExe pkgs.fzf} --multi | ${pkgs.gawk}/bin/awk '{$1=$1;print}' | ${pkgs.util-linux}/bin/rev | ${pkgs.coreutils}/bin/cut -d ' ' -f1 | ${pkgs.util-linux}/bin/rev | ${pkgs.toybox}/bin/xargs ${pkgs.trashy}/bin/trash restore --match=exact --force";
      trash-empty = "${pkgs.trashy}/bin/trash empty --all";
    };
    # Environment variables go into zshenv
    zshenv.content =
      # bash
      ''
        export DISABLE_UPDATE_PROMPT="true"
        export ZSH_CACHE_DIR="$HOME/.cache/zsh"
        export ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump-$ZSH_VERSION"

        # Make gpg work as ssh key (yubikey)
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      '';

    # All configuration and plugins go into zshrc
    zshrc.content =
      # bash
      ''
        # Ensure GPG knows which terminal to draw the PIN prompt on
        export GPG_TTY=$(tty)

        # Custom Completions Setup
        fpath=(
          ${pkgs.just}/share/zsh/site-functions
          ${pkgs.glow}/share/zsh/site-functions
          ${pkgs.nh}/share/zsh/site-functions
          $fpath
        )

        # Native Zsh Options
        setopt AUTOCD
        unsetopt BEEP

        # History Configuration
        mkdir -p $HOME/.local/share/zsh/
        HISTFILE="$HOME/.local/share/zsh/zsh_history"
        HISTSIZE=10000000 # Number of history lines to keep.
        SAVEHIST=10000000 # Number of history lines to save.
        # Do not enter command lines into the history list if they are duplicates of older ones.
        setopt HIST_IGNORE_ALL_DUPS

        # Zinit plugin manager
        ZINIT_HOME="${pkgs.zinit}/share/zinit"
        source "$ZINIT_HOME/zinit.zsh"

        # Load plugins
        zinit light zsh-users/zsh-autosuggestions
        zinit light zsh-users/zsh-syntax-highlighting

        # Use zsh as the default shell in a nix-shell environment
        zinit light chisui/zsh-nix-shell
        # Replace zsh's default completion selection menu with fzf!
        zinit light Aloxaf/fzf-tab
        # Prefix current command with sudo (2x Esc)
        zinit snippet OMZP::sudo
        # Colorizes sections and commands
        zinit snippet OMZP::colored-man-pages

        # Keybindings

        # History search with arrow keys using whole line as filter
        # https://superuser.com/questions/585003/searching-through-history-with-up-and-down-arrow-in-zsh
        autoload -U up-line-or-beginning-search
        autoload -U down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search

        # Load terminal-specific escape sequences
        zmodload zsh/terminfo # Ensure terminfo is available
        typeset -g -A key     # Create a global associative array
        key[Up]="''${terminfo[kcuu1]}"
        key[Down]="''${terminfo[kcud1]}"
        key[Left]="''${terminfo[kcub1]}"
        key[Right]="''${terminfo[kcuf1]}"
        key[Home]="''${terminfo[khome]}"
        key[End]="''${terminfo[kend]}"
        key[Insert]="''${terminfo[kich1]}"
        key[Delete]="''${terminfo[kdch1]}"
        key[Backspace]="''${terminfo[kbs]}"
        key[PageUp]="''${terminfo[kpp]}"
        key[PageDown]="''${terminfo[knp]}"

        # Standard terminal navigation and editing
        [[ -n "''${key[Up]}" ]]     && bindkey "''${key[Up]}"     up-line-or-beginning-search
        [[ -n "''${key[Down]}" ]]   && bindkey "''${key[Down]}"   down-line-or-beginning-search
        [[ -n "''${key[Delete]}" ]] && bindkey "''${key[Delete]}" delete-char
        [[ -n "''${key[Home]}" ]]   && bindkey "''${key[Home]}"   beginning-of-line
        [[ -n "''${key[End]}" ]]    && bindkey "''${key[End]}"    end-of-line
        function zle_do_nothing() {} # Create an empty ZLE widget that swallows inputs
        zle -N zle_do_nothing
        [[ -n "''${key[PageUp]}" ]] && bindkey "''${key[PageUp]}" zle_do_nothing
        [[ -n "''${key[PageDown]}" ]] && bindkey "''${key[PageDown]}" zle_do_nothing

        # Fallback raw escape sequences for Normal Mode (Highly recommended)
        bindkey "^[[A"  up-line-or-beginning-search   # Up
        bindkey "^[[B"  down-line-or-beginning-search # Down
        bindkey "^[[3~" delete-char                   # Delete
        bindkey "^[[H"  beginning-of-line             # Home
        bindkey "^[[F"  end-of-line                   # End
        bindkey "^[[1~" beginning-of-line             # Home (Alternative)
        bindkey "^[[4~" end-of-line                   # End (Alternative)

        # Shell Integrations
        eval "$(${lib.getExe pkgs.fzf} --zsh)"
        eval "$(${lib.getExe pkgs.zoxide} init --cmd cd zsh)"
        eval "$(${lib.getExe pkgs.direnv} hook zsh)"

        # Completions Initialization
        autoload -Uz compinit
        # disable sort when completing `git checkout`
        zstyle ':completion:*:git-checkout:*' sort false
        # case-insensitive completion
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        # set list-colors to enable filename colorizing
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
        zstyle ':completion:*' menu no

        # preview directory's content with eza when completing cd with fzf-tab
        zstyle ':fzf-tab:complete:cd:*' fzf-preview '${lib.getExe pkgs.eza} -1 --color=always --icons=always --group-directories-first $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview '${lib.getExe pkgs.eza} -1 --color=always --icons=always --group-directories-first $realpath'

        zmodload zsh/complist
        compinit -d $ZSH_CACHE_DIR/zcompdump

        # Replay compdefs (to be done after compinit).
        # -q - quiet.
        zinit cdreplay -q

        # Yazi directory wrapper
        function y() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
          fi
          rm -f -- "$tmp"
        }

        # Starship outputs the unwrapped starship executable, so we need to fix it
        eval "$(${lib.getExe selfpkgs.starship} init zsh | sed -E 's|/[^ ]*/bin/starship|${lib.getExe selfpkgs.starship}|g')"
      '';
  };
}
