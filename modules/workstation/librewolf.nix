{
    flake.modules.homeManager.workstation = { pkgs, ... }: {
        programs.librewolf = {
            enable = true;
            # TODO: temporary fix -- drop this back to the default `pkgs.librewolf`
            # (and remove the allowInsecurePredicate in modules/core/default.nix)
            # once nixpkgs resumes maintaining librewolf and drops the insecure mark.
            #
            # nixpkgs marks every librewolf variant insecure because the packaging
            # lost its maintainer. librewolf-bin tracks the official upstream binaries
            # (still patched by LibreWolf), so it stays current. The insecure flag is
            # allowed by name in modules/core/default.nix.
            package = pkgs.librewolf-bin;
            configPath = ".config/librewolf/librewolf";
            profiles.default = {
                isDefault = true;
                settings = {
                    "layout.css.prefers-color-scheme.content-override" = 0;
                    "privacy.resistFingerprinting" = false;
                    "privacy.fingerprintingProtection" = true;
                    "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme,-JSLocale";
                    "intl.regional_prefs.use_os_locales" = false;
                    "intl.date_time.pattern_override.date_short" = "dd-MM-yyyy";
                    "intl.date_time.pattern_override.time_short" = "HH:mm";
                };
                search = {
                    force = true;
                    default = "ddg";
                    order = [ "ddg" "My NixOS" ];
                    engines = {
                        "My NixOS" = {
                            urls = [
                                {
                                    template = "https://mynixos.com/search";
                                    params = [
                                        { name = "q"; value= "{searchTerms}"; }
                                    ];
                                }
                            ];
                            definedAliases = [ "@np" ];
                        };
                        "google".metaData.hidden = true;
                        "bing".metaData.hidden = true;
                        "amazon".metaData.hidden = true;
                        "wikipedia".metaData.hidden = true;
                    };
                };
            };
            policies = {
                DisplayBookmarksToolbar = "always";
                Bookmarks = [
                    { Title = ""; URL = "https://github.com/WJehee"; Placement = "toolbar"; }
                    { Title = ""; URL = "https://mail.startmail.com/mail/folders/INBOX"; Placement = "toolbar"; }

                    { Title = "Syncthing"; URL = "http://localhost:8384/"; Placement = "toolbar"; Folder = "Tech"; }
                    { Title = "Hetzner"; URL = "https://console.hetzner.com/projects"; Placement = "toolbar"; Folder = "Tech"; }
                    { Title = "Claude"; URL = "https://claude.ai/"; Placement = "toolbar"; Folder = "Tech"; }
                    { Title = "Hugging Face"; URL = "https://huggingface.co/"; Placement = "toolbar"; Folder = "Tech"; }
                    { Title = "Open WebUI"; URL = "http://localhost:9090"; Placement = "toolbar"; Folder = "Tech"; }

                    { Title = "Intigriti"; URL = "https://app.intigriti.com/researcher/dashboard"; Placement = "toolbar"; Folder = "Hacking"; }
                    { Title = "HackerOne"; URL = "https://hackerone.com/opportunities/all"; Placement = "toolbar"; Folder = "Hacking"; }
                    { Title = "Hack The Box"; URL = "https://app.hackthebox.com/home"; Placement = "toolbar"; Folder = "Hacking"; }
                ];
                DisableTelemetry = true;
                DisablePocket = true;
                DisableProfileImport = true;
                DisableSetDesktopBackground	= true;

                DisableFirefoxStudies = true;
                DisableFirefoxScreenshots = true;
                DisableFirefoxAccounts = true;

                OfferToSaveLogins = false;
                OfferToSaveLoginsDefault = false;
                PasswordManagerEnabled = false;
                EnableTrackingProtection = true;
                SearchSuggestEnabled = false;
                TranslateEnabled = false;
                SanitizeOnShutdown = false;

                HardwareAcceleration = true;

                FirefoxHome = {
                    Search = true;
                    Pocket = false;
                    Snippets = false;
                    TopSites = false;
                    Highlights = false;
                };
                FirefoxSuggest = {
                    WebSuggestions = false;
                    SponsoredSuggestions = false;
                    ImproveSuggest = false;
                    Locked = false;
                };
                UserMessaging = {
                    ExtensionRecommendations = false;
                    SkipOnboarding = true;
                };
                Preferences = {
                    "dom.security.https_only_mode" = true;
                    "general.smoothScroll" = true;
                    "webgl.disabled" = false;
                    "browser.toolbars.bookmarks.showOtherBookmarks" = true;
                };
                SearchEngines = {
                    Remove = [
                        "DuckDuckGo Lite"
                        "MetaGer"
                        "Mojeek"
                        "SearXNG - searx.be"
                        "StartPage"
                    ];
                };
                ExtensionSettings = let
                    moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
                in {
                    "uBlock0@raymondhill.net" = {
                        install_url = moz "ublock-origin";
                        installation_mode = "force_installed";
                        private_browsing = true;
                        default_area = "menupanel";
                    };
                    "addon@darkreader.org" = {
                        install_url = moz "darkreader";
                        installation_mode = "force_installed";
                        private_browsing = true;
                    };
                    "keepassxc-browser@keepassxc.org" = {
                        install_url = moz "keepassxc-browser";
                        installation_mode = "force_installed";
                    };
                    "foxyproxy@eric.h.jung" = {
                        install_url = moz "foxyproxy-standard";
                        installation_mode = "force_installed";
                        private_browsing = true;
                        default_area = "navbar";
                    };
                };
            };
        };
    };
}
