{ ... }: {
    programs.librewolf = {
        enable = true;
        profiles.default = {
            isDefault = true;
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

                { Title = "Syncthing"; URL = "http://localhost:8384/"; Placement = "menu"; }
                { Title = "Hetzner"; URL = "https://console.hetzner.com/projects"; Placement = "menu"; Folder = "Tech"; }
                { Title = "Claude"; URL = "https://claude.ai/"; Placement = "menu"; Folder = "Tech"; }
                { Title = "Hugging Face"; URL = "https://huggingface.co/"; Placement = "menu"; Folder = "Tech"; }

                { Title = "Intigriti"; URL = "https://app.intigriti.com/researcher/dashboard"; Placement = "menu"; Folder = "Hacking"; }
                { Title = "HackerOne"; URL = "https://hackerone.com/opportunities/all"; Placement = "menu"; Folder = "Hacking"; }
                { Title = "Hack The Box"; URL = "https://app.hackthebox.com/home"; Placement = "menu"; Folder = "Hacking"; }
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
                "layout.css.prefers-color-scheme.content-override" = 0;
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
}
