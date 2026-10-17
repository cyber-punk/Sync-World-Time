--- Load Server
local Server = require 'SyncWorldTime/Server';

---Handle receiving SetTime command from a client
---@param player IsoPlayer
---@param args table
function Server.Commands.SetTime(player, args)
    if Server.Utils.IsSinglePlayer() or Server.Utils.IsPlayerAdmin(player) then
        Server.Modules.WorldTime.SetTime(args.hour, args.minute);
    end
end
