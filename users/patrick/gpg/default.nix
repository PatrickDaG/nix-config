{
  programs.gpg.publicKeys = [
    {
      source = ./pubkey.gpg;
      trust = 5;
    }
    {
      source = ./newpubkey.gpg;
      trust = 5;
    }
  ];
}
