{
  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
  };

  users.users.minng01 = {
    extraGroups = [
      "docker"
    ];
  };
}
