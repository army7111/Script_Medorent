-- define monitoring for one airbase
local ATCBassel=ATC_GROUND_UNIVERSAL:New({AIRBASE.Syria.Bassel_Al_Assad})
--set kick speed
ATCBassel:SetKickSpeed(UTILS.KnotsToMps(60))
-- start monitoring evey 10 secs
ATCBassel:Start(10)