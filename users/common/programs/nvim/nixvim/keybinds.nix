let
  options = {
    noremap = true;
    silent = true;
  };
in
{
  programs.nixvim.keymaps = [
    {
      key = "<M-down>";
      action = "<C-w><down>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }
    {
      key = "<M-up>";
      action = "<C-w><up>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }
    {
      key = "<M-left>";
      action = "<C-w><left>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }
    {
      key = "<M-right>";
      action = "<C-w><right>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }

    {
      key = "<M-r>";
      action = "<C-w><down>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }
    {
      key = "<M-l>";
      action = "<C-w><up>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }
    {
      key = "<M-n>";
      action = "<C-w><left>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }
    {
      key = "<M-s>";
      action = "<C-w><right>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }

    # scroll with cursor lock
    {
      key = "<S-down>";
      action = "<C-e>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }
    {
      key = "<S-up>";
      action = "<C-y>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }
    {
      key = "<S-down>";
      action = "<C-esc><C-e>a";
      inherit options;
      mode = "i";
    }
    {
      key = "<S-up>";
      action = "<C-esc><C-y>a";
      inherit options;
      mode = "i";
    }
    {
      key = "<leader>u";
      action = "<cmd>UndotreeToggle<cr>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }
    {
      key = "<leader>t";
      action = "<cmd>Neotree toggle<cr>";
      inherit options;
      mode = [
        "n"
        "v"
        "s"
      ];
    }
  ];
}
