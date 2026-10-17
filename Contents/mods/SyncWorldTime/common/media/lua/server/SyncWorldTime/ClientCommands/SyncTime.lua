--- Load Server
local Server = require 'SyncWorldTime/Server';

---Handle receiving SyncTime command from a client
---@param player IsoPlayer
---@param args table
function Server.Commands.SyncTime(player, args)
    if Server.Utils.IsSinglePlayer() or Server.Utils.IsPlayerAdmin(player) then
        Server.Modules.WorldTime.SyncSystemTime();
    end
end
