{ ... }: {
    programs.freetube = {
        enable = true;
        settings = {
            defaultQuality = "1080";
            baseTheme = "nordic";
            playNextVideo = false;

            useSponsorBlock = true;
            useDeArrowTitles = true;

            hideRecommendedVideos = true;
            hideTrendingVideos = true;
            hideSubscriptionsShorts = true;
            hideSubscriptionsCommunity = true;
            hideChannelShorts = true;
            hideChannelCommunity = true;
        };
    };
}
