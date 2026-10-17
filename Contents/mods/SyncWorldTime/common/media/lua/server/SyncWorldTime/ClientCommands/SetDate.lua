--- Load Server
local Server = require 'SyncWorldTime/Server';

---Handle receiving SetDate command from a client
---@param player IsoPlayer
---@param args table
function Server.Commands.SetDate(player, args)
    if Server.Utils.IsSinglePlayer() or Server.Utils.IsPlayerAdmin(player) then
        Server.Modules.WorldTime.SetDate(args.year, args.month, args.day);
    end
end
