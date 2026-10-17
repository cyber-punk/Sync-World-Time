---@class Config
local Config = {

    ModName = "SyncWorldTime",
    ModVersion = "1.5.0",
    ModInfo = {
        Author = "Konijima & Cyber-Punk",
    },

    --- Define Global ModData tables to create on the client
    --- if true, it will always be requested/overwritten by the server
    --- if false, it will only be local
    ClientModData = {

    },

    --- Define Global ModData tables to create on the server
    ServerModData = {

    },

    --- Define custom events to add on the client
    ClientEvents = {
        "OnDateSet",
        "OnTimeSet",
    },

    --- Define custom events to add on the server
    ServerEvents = {
        "OnDateSet",
        "OnTimeSet",
    },

};

print("--------------------------------------------------------------------")
print("Initializing " .. Config.ModName .. " version " .. Config.ModVersion);
for k, v in pairs(Config.ModInfo) do
    print(k .. ": " .. v); --- print each mod info to the console log
end
print("--------------------------------------------------------------------")

return Config;
