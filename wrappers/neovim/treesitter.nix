{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    # Parsers and queries are pinned and built by nixpkgs, so nothing is
    # compiled or downloaded at runtime. Grammars land on the runtimepath as
    # plugin dependencies; config/lua/treesitter.lua starts highlighting.
    specs.treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (g:
      with g; [
        # Neovim and its config
        lua
        luadoc
        vim
        vimdoc
        query
        # Nix
        nix
        # Systems
        rust
        c
        cpp
        cmake
        make
        zig
        # Scripting
        python
        bash
        awk
        # Web
        javascript
        typescript
        tsx
        jsdoc
        html
        css
        # JVM
        java
        # Data and config
        json
        jq
        yaml
        toml
        xml
        ini
        sql
        dockerfile
        just
        # Documents
        markdown
        markdown_inline
        latex
        bibtex
        typst
        # Git
        diff
        git_config
        gitattributes
        gitcommit
        gitignore
        git_rebase
        # Injected into other languages
        comment
        regex
        printf
      ]);
  };
}
