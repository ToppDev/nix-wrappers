{pkgs, ...}: {
  format = "   {specific_used:0.0f}/{specific_total:0.0f} GiB ({percentage_used}%)";
  unit = "GB";
  path = "/";
  tooltip = false;
}
