{pkgs, ...}: {
  format = "{}";
  rewrite = {
    "(.*) - Brave" = "$1";
    "(.*) - Chromium" = "$1";
  };
  separate-outputs = true;
  tooltip = false;
}
