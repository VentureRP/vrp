VRConfig = {}

VRConfig.MaxPlayers = GetConvarInt('sv_maxclients', 64) -- Gets max players from config file, default 32
VRConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)

VRConfig.Money = {}
VRConfig.Money.MoneyTypes = {['cash'] = 500, ['bank'] = 5000 } -- ['type']=startamount - Add or remove money types for your server (for ex. ['blackmoney']=0), remember once added it will not be removed from the database!
VRConfig.Money.DontAllowMinus = {'cash'} -- Money that is not allowed going in minus
VRConfig.Money.PayCheckTimeOut = 10 -- The time in minutes that it will give the paycheck

VRConfig.Player = {}
VRConfig.Player.MaxWeight = 120000 -- Max weight a player can carry (currently 120kg, written in grams)
VRConfig.Player.MaxInvSlots = 41 -- Max inventory slots for a player
VRConfig.Player.Bloodtypes = {
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
}

VRConfig.Server = {} -- General server config
VRConfig.Server.closed = false -- Set server closed (no one can join except people with ace permission 'vradmin.join')
VRConfig.Server.closedReason = "Server Closed" -- Reason message to display when people can't join the server
VRConfig.Server.uptime = 0 -- Time the server has been up.
VRConfig.Server.whitelist = false -- Enable or disable whitelist on the server
VRConfig.Server.discord = "" -- Discord invite link
VRConfig.Server.PermissionList = {} -- permission list
