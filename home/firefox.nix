{ config, pkgs, ... }: {
    programs.firefox = {
        enable = true;
        profiles.wouter = {
            settings = {
                "dom.security.https_only_mode" = true;
                "general.smoothScroll" = true;
            };
            search = {
                default = "Qwant";
                force = true;
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
                    "Qwant" = {
                        urls = [
                            {
                                template = "https://www.qwant.com/";
                                params = [
                                    { name = "q"; value = "{searchTerms}"; }
                                ];
                            }
                        ];
                    };
                    "Ecosia" = {
                        urls = [
                            {
                                template = "https://www.ecosia.org/search";
                                params = [
                                    { name = "q"; value = "{searchTerms}"; } 
                                ];
                            }
                        ];
                        definedAliases = [ "@ec" ];
                    };
                    "Google".metaData.hidden = true;
                    "Amazon.com".metaData.hidden = true;
                    "Amazon.nl".metaData.hidden = true;
                    "Wikipedia (en)".metaData.hidden = true;
                    "Bing".metaData.hidden = true;
                    "eBay".metaData.hidden = true;
                };
            };
        };
        package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
            extraPolicies = {
                DisplayBookmarksToolbar = "always";
                DisableFirefoxStudies = true;
                DisableTelemetry = true;
                DisablePocket = true;
                DisableProfileImport = true;
                NoDefaultBookmarks = true;
                OfferToSaveLogins = false;
                OfferToSaveLoginsDefault = false;
                PasswordManagerEnabled = false;
                SearchSuggestEnabled = false;
                EnableTrackingProtection = true;
                FirefoxHome = {
                    Search = true;
                    Pocket = false;
                    Snippets = false;
                    TopSites = false;
                    Highlights = false;
                };
                UserMessaging = {
                    ExtensionRecommendations = false;
                    SkipOnboarding = true;
                };
            };
        };
    };
}
