{ pkgs, pkgs-cuda, lib }:

{
  # Base packages.
  basePkgs = with pkgs; [
    # Python environment.
    python3
    uv
    # Build system.
    cmake
    ninja
    # Slangpy dependencies.
    libjpeg
    libpng
    openexr_3
    asmjit
  ];
  # Linux packages (x11 and cuda required).
  linuxPkgs = with pkgs; [
    # CUDA toolkit.
    pkgs-cuda.cudatoolkit
    # Graphics libraries.
    vulkan-loader
    libGL.dev
    # X11 related libraries.
    xorg.libX11.dev
    xorg.libXi.dev
    xorg.libXrandr.dev
    xorg.libXinerama.dev
    xorg.libXcursor.dev
  ];

  # LD_LIBRARY_PATH libraries.
  ldLibs = [ ] ++ lib.optionals pkgs.stdenv.isLinux (
    pkgs.pythonManylinuxPackages.manylinux1 ++ [
      "/run/opengl-driver"
      pkgs.vulkan-loader
      pkgs-cuda.cudatoolkit
    ]
  );
}
