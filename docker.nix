{
  cacert,
  buildEnv,
  dockerTools,
  polis,
}:
  dockerTools.buildImage {
    name = "222068622593.dkr.ecr.us-east-1.amazonaws.com/polis";
    tag = "latest";
    config.Cmd = ["polis"];
    config.Env = [
      "PORT=80"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    config.ExposedPorts = {
      "80/tcp" = {};
    };
    copyToRoot = buildEnv {
      name = "polis-image-root";
      pathsToLink = ["/bin"];
      paths = [
        polis
        cacert
      ];
    };
    extraCommands = ''
      mkdir tmp
    '';
  }
