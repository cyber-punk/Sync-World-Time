--- Load Client
local Client = require 'SyncWorldTime/Client';

---@class ClientModuleWorldTime
local ClientModuleWorldTime = {};

---@return boolean
function ClientModuleWorldTime.IsSystemTimeSyncEnabled()
    return SandboxVars.DayLength == 27 and SandboxVars.SyncWorldTime.syncWorldWithSystemTime;
end

---@param year number real year number
---@param month number real month number
---@param day number real day number
function ClientModuleWorldTime.SetDate(year, month, day)
    if SandboxVars.SyncWorldTime.disabled then return; end

    local gameTime = getGameTime();
    gameTime:setYear(year);
    gameTime:setMonth(month - 1);
    local daysInMonth = gameTime:daysInMonth(year, month - 1);
    if day > daysInMonth then day = daysInMonth; end
    gameTime:setDay(day - 1);

    Client.TriggerEvent("OnDateSet", gameTime:getYear(), gameTime:getMonth() + 1, gameTime:getDayPlusOne());

    Client.Log("World date set to " .. Client.Utils.FormatDate(gameTime:getYear(), gameTime:getMonth() + 1, gameTime:getDayPlusOne()));
end

---@param hour number
---@param minute number
function ClientModuleWorldTime.SetTime(hour, minute)
    if SandboxVars.SyncWorldTime.disabled then return; end

    local gameTime = getGameTime();
    local floatMinute = minute / 60;
    local floatTime = hour + floatMinute;
    gameTime:setTimeOfDay(floatTime);

    Client.TriggerEvent("OnTimeSet", gameTime:getHour(), gameTime:getMinutes());

    Client.Log("World time set to " .. Client.Utils.FormatTime(gameTime:getHour(), gameTime:getMinutes()));
end

---@param year number real year number
---@param month number real month number
---@param day number real day number
function ClientModuleWorldTime.SendSetDate(year, month, day)
    if SandboxVars.SyncWorldTime.disabled then return; end

    if Client.Utils.IsSinglePlayer() or Client.Utils.IsPlayerAdmin(getPlayer()) then
        local args = {
            year = year,
            month = month,
            day = day,
        };
        Client.SendCommand("SetDate", args);
    end
end

---@param hour number
---@param minute number
function ClientModuleWorldTime.SendSetTime(hour, minute)
    if SandboxVars.SyncWorldTime.disabled then return; end

    if Client.Utils.IsSinglePlayer() or Client.Utils.IsPlayerAdmin(getPlayer()) then
        local args = {
            hour = hour,
            minute = minute,
        };
        Client.SendCommand("SetTime", args);
    end
end

function ClientModuleWorldTime.SendSyncTime()
    if SandboxVars.SyncWorldTime.disabled then return; end

    if Client.Utils.IsSinglePlayer() or Client.Utils.IsPlayerAdmin(getPlayer()) then
        Client.SendCommand("SyncTime");
    end
end

function ClientModuleWorldTime.OpenWorldTimeWindow()
    if SandboxVars.SyncWorldTime.disabled then return; end

    local window = Client.UI.WorldTimeWindow:new();
    window:initialise();
    window:addToUIManager();
end

--- Add the module to the client Modules object
Client.Modules.WorldTime = ClientModuleWorldTime;

------------------------------------------------------------------------------------------------------------------------

--- Add admin and debug context menu
local function onFillWorldObjectContextMenu(player, context)
    if SandboxVars.SyncWorldTime.disabled then return; end
    if Client.UI.WorldTimeWindow.instance then return; end

    local playerObj = getSpecificPlayer(player);
    if Client.Utils.IsSinglePlayer() then
        if playerObj and not playerObj:getVehicle() then
            context:addOption("Sync World Time", nil, ClientModuleWorldTime.OpenWorldTimeWindow);
        end
    elseif playerObj and string.lower(playerObj:getAccessLevel() or "") == "admin" then
        context:addOption("Sync World Time", nil, ClientModuleWorldTime.OpenWorldTimeWindow);
    end
end
Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu);
