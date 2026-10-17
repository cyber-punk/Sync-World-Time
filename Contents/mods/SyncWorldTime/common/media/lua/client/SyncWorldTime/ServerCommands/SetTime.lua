--- Load Client
local Client = require 'SyncWorldTime/Client';

---Handle receiving SetTime command from the server
---@param args table
function Client.Commands.SetTime(args)
    Client.Modules.WorldTime.SetTime(args.hour, args.minute);
end
