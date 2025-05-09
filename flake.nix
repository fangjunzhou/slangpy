{
  description = "Easily call Slang functions and integrate with PyTorch auto diff directly from Python.";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs-cuda.url = "github:nixos/nixpkgs/nixos-24.11";
      flake-utils.url = "github:numtide/flake-utils";
    };

  outputs = { self, nixpkgs, nixpkgs-cuda, flake-utils }:
    with flake-utils.lib;
    eachSystem [
      system.x86_64-linux
      system.aarch64-darwin
    ]
      (system:
        let
          # Setup.
          inherit (nixpkgs) lib;
          pkgs = import nixpkgs
            {
              inherit system;
            };
          pkgs-cuda = import nixpkgs-cuda
            {
              inherit system;
              config.allowUnfree = true;
            };
          config = import ./config.nix {
            inherit pkgs pkgs-cuda lib;
          };
          inherit (config) basePkgs linuxPkgs ldLibs;
        in
        {
          devShells.default = pkgs.mkShell
            {
              buildInputs = basePkgs ++ (lib.optional pkgs.stdenv.isLinux linuxPkgs);
              shellHook = ''
                # Create the virtual environment if it doesn't exist
                if [ -d .venv ]; then
                  # Activate the virtual environment
                  source .venv/bin/activate
                  # Add .venv/bin to PATH
                  export PATH=$PWD/.venv/bin:$PATH
                else
                  echo "Environment not initialized."
                fi
              '';
              # Setup LD_LIBRARY_PATH on Linux.
              LD_LIBRARY_PATH = lib.makeLibraryPath ldLibs;
              # Setup CUDA_PATH on Linux.
              CUDA_PATH = lib.optionalString pkgs.stdenv.isLinux pkgs-cuda.cudatoolkit;
            };
        }
      );
}
