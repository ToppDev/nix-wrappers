{pkgs, ...}: {
  # tooltip-format ="<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
  tooltip-format = "<tt><small>{calendar}</small></tt>";
  # https://fmt.dev/latest/syntax/#chrono-format-specifications
  # 'H'	The hour (24-hour clock) as a decimal number. If the result is a single digit, it is prefixed with 0. The modified command %OH produces the locale's alternative representation.
  # 'M'	The minute as a decimal number. If the result is a single digit, it is prefixed with 0. The modified command %OM produces the locale's alternative representation.
  # 'a'	The abbreviated weekday name, e.g. "Sat". If the value does not contain a valid weekday, an exception of type format_error is thrown.
  # 'd'	The day of month as a decimal number. If the result is a single decimal digit, it is prefixed with 0. The modified command %Od produces the locale's alternative representation.
  # 'b'	The abbreviated month name, e.g. "Nov". If the value does not contain a valid month, an exception of type format_error is thrown.
  format = "{:%H:%M %a, %d %b}";
  # format-alt = "{:%d %b %Y}";
  calendar = {
    mode = "month";
    mode-mon-col = 3;
    weeks-pos = "left";
    on-scroll = 1;
    format = {
      months = "<span color='#ffead3'><b>{}</b></span>";
      days = "<span color='#ecc6d9'><b>{}</b></span>";
      weeks = "<span color='#99ffdd'><b>W{}</b></span>";
      weekdays = "<span color='#ffcc66'><b>{}</b></span>";
      today = "<span color='#ff6699'><b><u>{}</u></b></span>";
    };
  };
  actions = {
    # on-click = ""; # left click changes between format/format/alt
    # on-click-right = "mode";

    on-click = "mode"; # single month calendar/full year
    on-scroll-up = "shift_down";
    on-scroll-down = "shift_up";
  };
}
