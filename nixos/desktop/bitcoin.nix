{ ... }:
{
  nix-bitcoin.generateSecrets = true;

  nix-bitcoin.operator = {
    enable = true;
    name = "henrique";
  };

  services = {
    bitcoind = {
      enable = true;
      txindex = true;
      dbCache = 5000;
      assumevalid = "0000000000000000000307a4cd9b0110c06e1f5a74ed12e6096cba31bcff1294";
      dataDir = "/var/lib/bitcoind/";
      extraConfig = ''
        debuglogfile=/var/lib/bitcoind/debug.log
      '';
      tor.enforce = false;
      tor.proxy = false;
    };
    lnd = {
      enable = false;
    };
  };
}
