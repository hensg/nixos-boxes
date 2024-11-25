{
  services.borgbackup.jobs = {
    homeBackup = {
      paths = "/home";
      exclude = [
        "**/.cache"
        "**/target"
        "/home/*/go/bin"
        "/home/*/go/pkg"
      ];
      repo = "/mnt/backups/borgbackup";
      doInit = false;
      encryption = {
        mode = "none";
      };
      inhibitsSleep = true;
      compression = "lz4";
      startAt = "hourly";
      prune.keep = {
        within = "6H";
        daily = 7;
        weekly = 4;
        monthly = 1;
      };
    };
  };
}
