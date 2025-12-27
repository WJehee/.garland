{ pkgs, ... }: {
    programs.librewolf = {
        enable = true;
        profiles.default = {
            isDefault = true;
            bookmarks = {
                force = true;
                settings = [
                    {
                        name = "My toolbar bookmarks";
                        toolbar = true;
                        bookmarks = [
                            {
                                name = "";
                                url = "https://github.com/WJehee";
                            }
                            {
                                name = "";
                                url = "https://mail.startmail.com/mail/folders/INBOX";
                            }
                            # "separator"
                        ];
                    }
                    {
                        name = "BlueSky";
                        url = "https://bsky.app/";
                    }
                    {
                        name = "Syncthing";
                        url = "http://localhost:8384/";
                    }
                    {
                        name = "Tech";
                        bookmarks = [
                            {
                                name = "Hetzner";
                                url = "https://console.hetzner.com/projects";
                            }
                            {
                                name = "Claude";
                                url = "https://claude.ai/";
                            }
                        ];
                    }
                    {
                        name = "Hacking";
                        bookmarks = [
                            {
                                name = "Intigriti";
                                url = "https://app.intigriti.com/researcher/dashboard";
                            }
                            {
                                name = "HackerOne";
                                url = "https://hackerone.com/opportunities/all";
                            }
                            {
                                name = "Hack The Box";
                                url = "https://app.hackthebox.com/home";
                            }
                        ];
                    }
                ];
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
