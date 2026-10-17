--- Contains a fix to the server auto sync at startup that was causing stack corruption
--- on windows (not sure on linux but I assume its the same) trying to set date and time to early before the world loads.
--- Also only check for mod setting changes every tenth tick instead of every tick. - Cyber-Punk 11/11/2025
--- Maybe make the settings change interval a SandboxVar for heavly loaded servers?

--- Load Server
local Server = require 'SyncWorldTime/Server';
local TimeZones = require 'SyncWorldTime/Classes/TimeZones';

---@class ServerModuleWorldTime
local ServerModuleWorldTime = {};

---@return boolean
function ServerModuleWorldTime.IsSystemTimeSyncEnabled()
    return SandboxVars.DayLength == 27 and SandboxVars.SyncWorldTime.syncWorldWithSystemTime;
end

---@param year number real year number
---@param month number real month number
---@param day number real day number
function ServerModuleWorldTime.SetDate(year, month, day)
    if SandboxVars.SyncWorldTime.disabled then return; end

    local gameTime = getGameTime();
    gameTime:setYear(year);
    gameTime:setMonth(month - 1);
    local daysInMonth = gameTime:daysInMonth(year, month - 1);
    if day > daysInMonth then day = daysInMonth; end
    gameTime:setDay(day - 1);

    local args = {
        year = year,
        month = month,
        day = day,
    };
    Server.SendCommand("SetDate", args);

    Server.TriggerEvent("OnDateSet", gameTime:getYear(), gameTime:getMonth() + 1, gameTime:getDayPlusOne());

    Server.Log("World date set to " .. Server.Utils.FormatDate(gameTime:getYear(), gameTime:getMonth() + 1, gameTime:getDayPlusOne()));
end

---@param hour number
---@param minute number
function ServerModuleWorldTime.SetTime(hour, minute)
    if SandboxVars.SyncWorldTime.disabled then return; end

    local gameTime = getGameTime();
    local floatMinute = minute / 60;
    local floatTime = hour + floatMinute;
    gameTime:setTimeOfDay(floatTime);

    local args = {
        hour = hour,
        minute = minute,
    };
    Server.SendCommand("SetTime", args);

    Server.TriggerEvent("OnTimeSet", gameTime:getHour(), gameTime:getMinutes());

    Server.Log("World time set to " .. Server.Utils.FormatTime(gameTime:getHour(), gameTime:getMinutes()));
end

function ServerModuleWorldTime.SyncSystemTime()
    if SandboxVars.SyncWorldTime.disabled then return; end

    Server.Log("Syncing game time to system time...");

    local systemTime = os.date("*t");
    local year, month, day, hour, minute = TimeZones.AdjustDateTime(SandboxVars.SyncWorldTime.utcOffset, systemTime.year, systemTime.month, systemTime.day, systemTime.hour, systemTime.min);

    ServerModuleWorldTime.SetDate(year, month, day);
    ServerModuleWorldTime.SetTime(hour, minute);
end

--- Add the module to the server Modules object
Server.Modules.WorldTime = ServerModuleWorldTime;

------------------------------------------------------------------------------------------------------------------------

local lastDayLength, lastUtcOffset, lastSyncEnabled;
local startupSyncAttempted = false;

--- Game Time is ready
local function onGameTimeLoaded()
    --- don't run for clients
    if not isServer() and not Server.Utils.IsSinglePlayer() then return; end

    lastDayLength = SandboxVars.DayLength;
    lastUtcOffset = SandboxVars.SyncWorldTime.utcOffset;
    lastSyncEnabled = SandboxVars.SyncWorldTime.syncWorldWithSystemTime;
end
Events.OnGameTimeLoaded.Add(onGameTimeLoaded);

local function syncAtStartup()
    if startupSyncAttempted then return; end
    startupSyncAttempted = true;

    lastDayLength = SandboxVars.DayLength;
    lastUtcOffset = SandboxVars.SyncWorldTime.utcOffset;
    lastSyncEnabled = SandboxVars.SyncWorldTime.syncWorldWithSystemTime;

    if SandboxVars.SyncWorldTime.disabled then
        Server.Log("Startup sync skipped: the mod is disabled in Sandbox settings.");
    elseif not lastSyncEnabled then
        Server.Log("Startup sync skipped: 'Sync to system time' is disabled in Sandbox settings.");
    elseif SandboxVars.DayLength ~= 27 then
        Server.Log("Startup sync skipped: Day Length is " .. tostring(SandboxVars.DayLength) .. ", not Real-time (27).");
    else
        Server.Log("Starting world-time sync after server startup.");
        ServerModuleWorldTime.SyncSystemTime();
    end
end

--- Dedicated servers fire this at startup even when paused without players.
local function onServerStarted()
    if isServer() then
        syncAtStartup();
    end
end
Events.OnServerStarted.Add(onServerStarted);

--- Check if sandbox vars has been changed.
--- Single-player uses a delayed tick fallback because it may not fire OnServerStarted.
local startupTicks = 0;
local ticksSinceSettingsCheck = 0;

local function onTick()
    --- don't run for clients
    if not isServer() and not Server.Utils.IsSinglePlayer() then
        Events.OnTick.Remove(onTick);
        return;
    end

    ticksSinceSettingsCheck = ticksSinceSettingsCheck + 1;
    if not startupSyncAttempted then
        if not Server.Utils.IsSinglePlayer() then return; end

        startupTicks = startupTicks + 1;
        if startupTicks < 10 then return; end

        syncAtStartup();
    elseif ticksSinceSettingsCheck >= 10 then
        ticksSinceSettingsCheck = 0;
        if lastDayLength ~= SandboxVars.DayLength
            or lastUtcOffset ~= SandboxVars.SyncWorldTime.utcOffset
            or lastSyncEnabled ~= SandboxVars.SyncWorldTime.syncWorldWithSystemTime then
            lastDayLength = SandboxVars.DayLength;
            lastUtcOffset = SandboxVars.SyncWorldTime.utcOffset;
            lastSyncEnabled = SandboxVars.SyncWorldTime.syncWorldWithSystemTime;

            if ServerModuleWorldTime.IsSystemTimeSyncEnabled() then
                Server.Log("World-time sync settings changed; syncing to system time.");
                ServerModuleWorldTime.SyncSystemTime();
            end
        end
    end
end
Events.OnTick.Add(onTick);
