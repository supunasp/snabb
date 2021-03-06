# Run like this:
#   nix-build /path/to/this/directory
# ... and the files are produced in ./result/

{ pkgs ? (import <nixpkgs> {})
}:

with pkgs;

stdenv.mkDerivation rec {
  # TODO: get the version from somewhere?
  name = "snabb";

  src = ./.;

  buildInputs = [ makeWrapper ];

  patchPhase = ''
    patchShebangs .

    # some hardcodeism
    for f in $(find src/program/snabbnfv/ -type f); do
      substituteInPlace $f --replace "/bin/bash" "${bash}/bin/bash"
    done

    # We need a way to pass $PATH to the scripts
    sed -i '2iexport PATH=${git}/bin:${mariadb}/bin:${which}/bin:${procps}/bin:${coreutils}/bin' src/program/snabbnfv/neutron_sync_master/neutron_sync_master.sh.inc
    sed -i '2iexport PATH=${git}/bin:${coreutils}/bin:${diffutils}/bin:${nettools}/bin' src/program/snabbnfv/neutron_sync_agent/neutron_sync_agent.sh.inc
  '';

  preBuild = ''
    make clean
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp src/snabb $out/bin
  '';
}
