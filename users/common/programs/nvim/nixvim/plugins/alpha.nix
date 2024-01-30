{
  programs.nixvim.plugins.alpha = {
    enable = true;
    layout = let
      padding = val: {
        type = "padding";
        inherit val;
      };
    in [
      (padding 2)
      {
        type = "text";
        val = [
          "⠄⠰⠛⠋⢉⣡⣤⣄⡉⠓⢦⣀⠙⠉⠡⠔⠒⠛⠛⠛⠶⢶⣄⠘⢿⣷⣤⡈⠻⣧"
          "⢀⡔⠄⠄⠄⠙⣿⣿⣿⣷⣤⠉⠁⡀⠐⠒⢿⣿⣿⣿⣶⣄⡈⠳⢄⣹⣿⣿⣾⣿"
          "⣼⠁⢠⡄⠄⠄⣿⣿⣿⣿⡟⠄⡐⠁⡀⠄⠈⣿⣿⣿⣿⣿⣷⣤⡈⠻⣿⣿⣿⣿"
          "⢻⡀⠈⠄⠄⣀⣿⣿⣿⡿⠃⠄⡇⠈⠛⠄⠄⣿⣿⣿⣿⣿⣿⠟⠋⣠⣶⣿⣿⣿"
          "⠄⢉⡓⠚⠛⠛⠋⣉⣩⣤⣤⣀⠑⠤⣤⣤⣾⣿⣿⣿⡿⠛⢁⣤⣾⣿⣿⣿⣿⣿"
          "⠄⠈⠙⠛⠋⣭⣭⣶⣾⣿⣿⣿⣷⣦⢠⡍⠉⠉⢠⣤⣴⠚⢩⣴⣿⣿⣿⣿⣿⣿"
          "⠄⢴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣭⣭⣭⣥⣴⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿"
          "⠄⣴⣶⡶⠶⠶⠶⠶⠶⠶⠶⠶⣮⣭⣝⣛⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
          "⠄⠙⣿⡄⠄⠄⢀⡤⠬⢭⣝⣒⢂⠭⣉⠻⠿⣷⣶⣦⣭⡛⣿⣿⣿⣿⣿⣿⣿⣿"
          "⠄⠄⠸⣿⡇⠄⠸⣎⣁⣾⠿⠉⢀⠇⣸⣿⣿⢆⡉⠹⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿"
          "⠄⠄⠄⣿⡇⠄⢀⡶⠶⠶⠾⠿⠮⠭⠭⢭⣥⣿⣿⣷⢸⣿⢸⣿⣿⣿⣿⣿⣿⣿"
          "⠄⠄⠄⣿⡇⠄⠈⣷⠄⠄⠄⣭⣙⣹⢙⣰⡎⣿⢏⣡⣾⢏⣾⣿⣿⣿⣿⣿⣿⣿"
          "⠄⠄⢰⣿⡇⠄⠄⢿⠄⠄⠈⣿⠉⠉⣻⣿⡷⣰⣿⡿⣡⣿⣿⣿⣿⣿⣿⣿⣿⣿"
          "⠄⠄⢸⣿⡇⠄⠄⠘⠿⠤⠤⠿⠿⠿⢤⣤⣤⡿⣃⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
          "⠄⠄⠘⢿⣷⣤⣄⣀⣀⣀⣀⣀⣠⣴⣾⡿⢋⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋"
        ];
        opts = {
          position = "center";
          hl = "Type";
        };
      }
      (padding 2)
      {
        type = "group";
        opts.spacing = 1;
        val = [
          {
            type = "button";
            val = "  New file";
            on_press.__raw = "function() vim.cmd[[enew]] end";
            opts = {
              keymap = [
                "n"
                "e"
                ":enew<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              shortcut = "e";
              position = "center";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "󰅙  Quit Neovim";
            on_press.__raw = "function() vim.cmd[[qa]] end";
            opts = {
              keymap = [
                "n"
                "q"
                ":qa<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              shortcut = "q";
              position = "center";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
        ];
      }
    ];
  };
}
