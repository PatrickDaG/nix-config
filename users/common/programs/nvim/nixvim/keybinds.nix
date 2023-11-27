let
  options = {
    noremap = true;
    silent = true;
  };
in {
  programs.nixvim.keymaps = [
    {
      key = "<M-down>";
      action = "<C-w><down>";
      inherit options;
    }
    {
      key = "<M-up>";
      action = "<C-w><up>";
      inherit options;
    }
    {
      key = "<M-left>";
      action = "<C-w><left>";
      inherit options;
    }
    {
      key = "<M-right>";
      action = "<C-w><right>";
      inherit options;
    }

    {
      key = "<M-r>";
      action = "<C-w><down>";
      inherit options;
    }
    {
      key = "<M-l>";
      action = "<C-w><up>";
      inherit options;
    }
    {
      key = "<M-n>";
      action = "<C-w><left>";
      inherit options;
    }
    {
      key = "<M-s>";
      action = "<C-w><right>";
      inherit options;
    }

    # scroll with cursor lock
    {
      key = "<S-down>";
      action = "<C-e>";
      inherit options;
    }
    {
      key = "<S-up>";
      action = "<C-y>";
      inherit options;
    }
    {
      key = "<S-down>";
      action = "<C-[><C-e>a";
      inherit options;
      mode = "i";
    }
    {
      key = "<S-up>";
      action = "<C-[><C-y>a";
      inherit options;
      mode = "i";
    }
    {
      key = "<leader>u";
      action = "<cmd>UndotreeToggle<cr>";
      inherit options;
    }
  ];
}
