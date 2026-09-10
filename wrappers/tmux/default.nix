{self, ...}: {
  flake.wrappers.tmux = {
    wlib,
    pkgs,
    lib,
    ...
  }: let
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    popuptmux = pkgs.writeShellApplication {
      name = "popuptmux";
      text = ''
        current_path=$(tmux display-message -p -F "#{pane_current_path}")
        session_name=$(tmux display-message -p -F "#{session_name}")
        if [[ "$session_name" == popup-* ]]; then
          tmux detach-client
        else
          tmux popup -h70% -w70% -E "tmux attach -t \"popup-$session_name\" || tmux new -s \"popup-$session_name\" -c \"$current_path\""
        fi
      '';
    };
    popuptrash = pkgs.writeShellApplication {
      name = "popuptrash";
      text = ''
        session_name=$(tmux display-message -p -F "#{session_name}")
        if [[ "$session_name" == trash ]]; then
          tmux detach-client
        else
          tmux popup -T"Trash" -h80% -w80% -E "tmux attach -t trash || tmux new -s trash '${pkgs.trashy}/bin/trash restore'"
        fi
      '';
    };
    popupgit = pkgs.writeShellApplication {
      name = "popupgit";
      text = ''
        current_path=$(tmux display-message -p -F "#{pane_current_path}")
        if [[ ! -d "$current_path/.git" && ! $(git -C "$current_path" rev-parse --git-dir 2> /dev/null) ]]; then
          exit 0;
        fi

        current_path=$(git -C "$current_path" rev-parse --show-toplevel)
        session_name=$(tmux display-message -p -F "#{session_name}")
        if [[ "$session_name" == git-* ]]; then
          tmux detach-client
        else
          session_name="git-$(basename "$current_path" | sed -r 's/\.//g')"
          [ "$(date -r "$current_path/.git/FETCH_HEAD" +'%F')" != "$(date +'%F')" ] && do_fetch=1 || do_fetch=0
          tmux popup -T"lazygit" -h90% -w90% -E "tmux attach -t \"$session_name\" || tmux new -s \"$session_name\" '[ $do_fetch = 1 ] && echo Fetching Git repo... && git -C \"$current_path\" fetch; ${lib.getExe selfpkgs.lazygit} -p \"$current_path\"'"
        fi
      '';
    };

    panehost = pkgs.writeShellApplication {
      name = "tmux-pane-host";
      runtimeInputs = [pkgs.procps pkgs.gawk];
      text = builtins.readFile ./pane-host.sh;
    };

    # `#h` is always the machine running the tmux server, so it keeps naming the
    # local host while a pane is ssh'd elsewhere. Ask the pane's processes instead.
    paneHost = "#(${lib.getExe panehost} #{pane_pid} #{host_short})";
    windowText = "${paneHost}:#{?#{==:#{host},#{pane_title}},#{b:pane_current_path},#T}";
  in {
    imports = [wlib.wrapperModules.tmux];

    escapeTime = 0;
    historyLimit = 1000000;
    modeKeys = "vi";
    prefix = "C-a";
    shell = lib.getExe selfpkgs.zsh;
    sourceSensible = true;
    statusKeys = "vi";
    terminal = "xterm-256color";
    vimVisualKeys = true;
    visualActivity = true;

    # configuration to run before all tmux plugins are sourced
    configBefore =
      # bash
      ''
        set-option -g set-titles on
        set-option -g set-titles-string "#S / #W / ${windowText}"
        set-option -sa terminal-overrides ",xterm*:Tc" # 24-bit color support
        set -g detach-on-destroy on      # don't exit from tmux when closing a session
        set -g renumber-windows on       # renumber all windows when any window is closed
        set -g set-clipboard on          # use system set-clipboard
        set -g status-position top
        set -g extended-keys on
        # set -g default-terminal "''${TERM}"
        # set-option -g default-shell "''${SHELL}"
        set -g pane-active-border-style 'fg=magenta,bg=default'
        set -g pane-border-style 'fg=brightblack,bg=default'

        is_helix="ps -o state= -o comm= -t '#{pane_tty}' \
                | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|\.?h(eli)?x(-wrapped)?)(diff)?$'"

        bind t run-shell '${lib.getExe popuptrash}'
        bind k run-shell '${lib.getExe popuptmux}'
        bind g if-shell "$is_helix" 'send-keys C-g' 'run-shell ${lib.getExe popupgit}'

        bind-key -n Home send Escape "OH"
        bind-key -n End send Escape "OF"

        # Remove 'all' keybindings
        # unbind-key -a

        # https://www.seanh.cc/2020/12/28/binding-keys-in-tmux/
        # Key modifiers
        #   C- = Control (Control modifiers are case insensitive)
        #   S- = Shift (But don't use with letters, use `bind N`)
        #   M- = Alt
        # Special Keys:
        #   Up, Down, Left, Right, BSpace, Delete, End, Enter, Escape, F1 … F12,
        #   Home, Insert, PageDown or PgDn, PageUp or PgUp, Space and Tab
        # Keybind options
        #   -r                Repeatable/Hold key
        #   -n                Root/Without prefix
        #   -T copy-mode-vi   Keybindings in vi copy mode
        # Multiple commands:
        #   Separate commands with '\;'
        #   Multiline by adding '\' at the end

        # bind C-x lock-server
        # bind C-d detach
        bind * list-clients
        bind l refresh-client

        bind : command-prompt
        # bind * setw synchronize-panes
        bind P set pane-border-status

        bind R command-prompt "rename-session %%"
        bind S choose-session

        # bind c new-window -c "$HOME"
        bind x kill-pane # Close pane but without asking
        bind r command-prompt "rename-window %%"
        # bind -n M-y select-window -t :1
        # bind -n M-c select-window -t :2
        # bind -n M-l select-window -t :3
        # bind -n M-m select-window -t :4
        # bind -n M-k select-window -t :5
        # bind -n M-z select-window -t :6
        # bind -n M-f select-window -t :7
        # bind -n M-u select-window -t :8
        # bind -n M-, select-window -t :9
        bind -n M-1 select-window -t :1
        bind -n M-2 select-window -t :2
        bind -n M-3 select-window -t :3
        bind -n M-4 select-window -t :4
        bind -n M-5 select-window -t :5
        bind -n M-6 select-window -t :6
        bind -n M-7 select-window -t :7
        bind -n M-8 select-window -t :8
        bind -n M-9 select-window -t :9
        bind -n M-0 select-window -t :0
        bind -n M-p previous-window
        bind -n M-a next-window
        bind C-a last-window

        bind z resize-pane -Z # Zoom/Maximize pane
        # Open panes in current directory
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind s split-window -v -c "#{pane_current_path}"
        bind h split-window -v -c "#{pane_current_path}"
        bind v split-window -h -c "#{pane_current_path}"
        # bind '"' choose-window

        # bind h select-pane -L
        # bind j select-pane -D
        # bind k select-pane -U
        # bind l select-pane -R

        # Resizing
        # bind -r J resize-pane -D 5
        # bind -r K resize-pane -U 5
        # bind -r L resize-pane -R 5
        # bind -r H resize-pane -L 5
        bind -r C-Down resize-pane -D 5
        bind -r C-Up resize-pane -U 5
        bind -r C-Right resize-pane -R 5
        bind -r C-Left resize-pane -L 5
      '';
    # configuration to run after all tmux plugins are sourced
    configAfter =
      # bash
      ''
        set -g status-interval 5 # how quickly a pane's host change is picked up
      '';

    plugins = [
      {
        plugin =
          pkgs.tmuxPlugins.catppuccin.overrideAttrs
          (oldAttrs: rec {
            version = "v2.3.0";
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "tmux";
              rev = version;
              hash = "sha256-3CJRQCgS8NAN7vOLBjNGiHbGXTIrIyY/FLmfZrXcEYc=";
            };
          });
        configBefore =
          # bash
          ''
            set -g @catppuccin_window_status_style "rounded"
            # set -g @catppuccin_window_status_style "custom"
            # set -g @catppuccin_window_left_separator ""
            # set -g @catppuccin_window_right_separator " "
            # set -g @catppuccin_window_middle_separator " █"
            set -g @catppuccin_window_number_position "right"
            set -g @catppuccin_window_text "${windowText}"
            # set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,(),}"
            set -g @catppuccin_window_current_text "${windowText}#{?window_zoomed_flag,(),}"

            # application - display the current window running application
            # directory   - display the basename of the current window path
            # session     - display the number of tmux sessions running
            # user        - display the username
            # host        - display the hostname
            # date_time   - display the date and time
            # battery     - display the battery
            # set -g status-right "#{E:@catppuccin_status_directory}"
            # set -g status-right "#{E:@catppuccin_status_application}"
            set -g status-right ""
            set -g status-left "#{E:@catppuccin_status_session}"
            set -g @catppuccin_status_left_separator ""
            set -g @catppuccin_status_right_separator " "
            set -g @catppuccin_status_right_separator_inverse "no"
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"
            set -g @catppuccin_directory_text "#{b:pane_current_path}"
            set -g @catppuccin_date_time_text "%H:%M"

          '';
      }
      {
        plugin = pkgs.tmuxPlugins.mkTmuxPlugin {
          # pluginName = "tmux-sessionx";
          # rtpFilePath = "sessionx.tmux";
          version = "2024-12-28";
          src = pkgs.fetchFromGitHub {
            owner = "omerxx";
            repo = "tmux-sessionx";
            rev = "4f58ca79b1c6292c20182ab2fce2b1f2cb39fb9b";
            hash = "sha256-/fmcgFxu2ndJXYNJ3803arcecinYIajPI+1cTcuFVo0=";
          };
          # meta.homepage = "https://github.com/omerxx/tmux-sessionx";
          pluginName = "sessionx";

          nativeBuildInputs = [pkgs.makeWrapper];

          postPatch = ''
            substituteInPlace sessionx.tmux \
              --replace "\$CURRENT_DIR/scripts/sessionx.sh" "$out/share/tmux-plugins/sessionx/scripts/sessionx.sh"
            substituteInPlace scripts/sessionx.sh \
              --replace "/tmux-sessionx/scripts/preview.sh" "$out/share/tmux-plugins/sessionx/scripts/preview.sh"
            substituteInPlace scripts/sessionx.sh \
              --replace "/tmux-sessionx/scripts/reload_sessions.sh" "$out/share/tmux-plugins/sessionx/scripts/reload_sessions.sh"
          '';

          postInstall = ''
            chmod +x $target/scripts/sessionx.sh
            wrapProgram $target/scripts/sessionx.sh \
              --prefix PATH : ${with pkgs; lib.makeBinPath [zoxide fzf gnugrep gnused coreutils]}
            chmod +x $target/scripts/preview.sh
            wrapProgram $target/scripts/preview.sh \
              --prefix PATH : ${with pkgs; lib.makeBinPath [coreutils gnugrep gnused]}
            chmod +x $target/scripts/reload_sessions.sh
            wrapProgram $target/scripts/reload_sessions.sh \
              --prefix PATH : ${with pkgs; lib.makeBinPath [coreutils gnugrep gnused]}
          '';

          meta = with lib; {
            description = "A fuzzy Tmux session manager with preview capabilities, deleting, renaming and more!";
            homepage = "https://github.com/omerxx/tmux-sessionx";
            platforms = platforms.all;
          };
        };
        configBefore =
          # bash
          ''
            set-environment -gu TMUX_PLUGIN_MANAGER_PATH
            set -g @sessionx-bind 'q'
            set -g @sessionx-x-path "''${HOME}/Git"
            set -g @sessionx-window-height '85%'
            set -g @sessionx-window-width '75%'
            set -g @sessionx-zoxide-mode 'on'
          '';
      }
      {
        plugin = pkgs.tmuxPlugins.vim-tmux-navigator;
        configBefore =
          # bash
          ''
            # Smart pane switching with awareness of Vim splits.
            # See: https://github.com/christoomey/vim-tmux-navigator

            # decide whether we're in a Vim process
            is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
                | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

            bind-key -n 'C-Left' if-shell "$is_vim" 'send-keys C-Left' 'select-pane -L'
            bind-key -n 'C-Down' if-shell "$is_vim" 'send-keys C-Down' 'select-pane -D'
            bind-key -n 'C-Up' if-shell "$is_vim" 'send-keys C-Up' 'select-pane -U'
            bind-key -n 'C-Right' if-shell "$is_vim" 'send-keys C-Right' 'select-pane -R'

            bind-key -T copy-mode-vi 'C-Left' select-pane -L
            bind-key -T copy-mode-vi 'C-Down' select-pane -D
            bind-key -T copy-mode-vi 'C-Up' select-pane -U
            bind-key -T copy-mode-vi 'C-Right' select-pane -R

            # Disable all default keybinds
            set -g @vim_navigator_mapping_left ""
            set -g @vim_navigator_mapping_right ""
            set -g @vim_navigator_mapping_up ""
            set -g @vim_navigator_mapping_down ""
            set -g @vim_navigator_mapping_prev ""
            set -g @vim_navigator_prefix_mapping_clear_screen ""
          '';
      }
      {
        plugin = pkgs.tmuxPlugins.yank;
        configBefore =
          # bash
          ''
            bind-key -T copy-mode-vi v send-keys -X begin-selection
            bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
            bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
          '';
      }
      # Makes startup very slow
      # {
      #   plugin = pkgs.tmuxPlugins.resurrect;
      #   configBefore = /* bash */ ''
      #     set -g @resurrect-strategy-nvim 'session'
      #   '';
      # }
      # {
      #   plugin = pkgs.tmuxPlugins.continuum;
      #   configBefore = /* bash */ ''
      #     set -g @continuum-restore 'on'
      #     set -g @continuum-save-interval '60' # minutes
      #   '';
      # }
      {
        plugin = pkgs.tmuxPlugins.tmux-thumbs; # <prefix> + space
        configBefore =
          # bash
          ''
            set -g @thumbs-key Space
            set -g @thumbs-unique enabled
            set -g @thumbs-command 'tmux set-buffer -- {} && echo -n {} | ${pkgs.xclip}/bin/xclip -selection clipboard'
            set -g @thumbs-upcase-command 'tmux set-buffer -- {} && tmux paste-buffer && echo -n {} | ${pkgs.xclip}/bin/xclip -selection clipboard'
            bind -n M-v paste-buffer
          '';
      }
      {
        plugin = pkgs.tmuxPlugins.tmux-fzf; # <prefix> + f
        configBefore =
          # bash
          ''
            TMUX_FZF_LAUNCH_KEY="f"
          '';
      }
      {
        plugin = pkgs.tmuxPlugins.fzf-tmux-url; # <prefix> + u
        configBefore =
          # bash
          ''
            set -g @fzf-url-bind 'u'
            set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
            set -g @fzf-url-history-limit '2000'
          '';
      }
    ];
  };
}
