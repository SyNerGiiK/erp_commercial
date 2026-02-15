# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.nodePackages.firebase-tools
    pkgs.jdk17
    pkgs.unzip
    pkgs.flutter
    pkgs.dart
    pkgs.nodejs_20
  ];

  # Sets environment variables in the workspace
  env = {
    # You can add environment variables here, like Supabase keys if needed
    # SUPABASE_URL = "your-url";
  };

  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.dart"
      "Dart-Code.flutter"
      "svelte.svelte-vscode" # Optionnel, mais utile si tu as des Edge Functions
      "eamodio.gitlens"
      "usernamehw.errorlens" # Affiche les erreurs directement en bout de ligne (très pratique)
      "humao.rest-client"    # Pour tester tes requêtes Supabase sans sortir de l'IDE
    ];

    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            "flutter"
            "run"
            "--machine"
            "-d"
            "web-server"
            "--web-hostname"
            "0.0.0.0"
            "--web-port"
            "$PORT"
          ];
          manager = "flutter";
        };
        # Tu pourras activer Android/iOS plus tard si tu reviens sur le mobile
        # android = {
        #   command = ["flutter" "run" "--machine" "-d" "android" "-dc" "emulator-5554"];
        #   manager = "flutter";
        # };
      };
    };

    # Workspace lifecycle hooks
    onCreate = {
      # Runs when the workspace is first created
      pub-get = "flutter pub get";
    };

    onStart = {
      # Runs every time the workspace is started
      # Example: start a background process to watch for changes
      # watch-backend = "npm run watch";
    };
  };
}