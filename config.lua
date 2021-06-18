Config = Config or {}


--      0 is no marker (best used with bt-target)
--      1 is marker

Config.Marker = 1

-- You can create more "traphouses" however I havent testing this

Config.TrapHouses = {
    [1] = {
        coords = {
            ["enter"]  =  {x = 636.48968505859, y = 2785.7883300781, z = 42.00, h = 295.5, r = 1.0},
            ["washer"] = {x = 1122.472, y = -3194.49, z = -40.38, h = 264.5, r = 1.0},
            ["laptop"] =   {x = 1129.50, y = -3193.60, z = -40.65, h = 264.5, r = 1.0},
        },
        pincode = 1111,
        inventory = {},
        opened = false,
        money = 0,
        laptopmoney = 0
    }
}

Config.AllowedItems = {
    ["metalscrap"] = {
        name = "metalscrap",
        wait = 500,
        reward = 3,
    },
    ["copper"] = {
        name = "copper",
        wait = 500,
        reward = 2,
    },
    ["iron"] = {
        name = "iron",
        wait = 500,
        reward = 2,
    },
    ["aluminum"] = {
        name = "aluminum",
        wait = 500,
        reward = 2,
    },
    ["steel"] = {
        name = "steel",
        wait = 500,
        reward = 2,
    },
    ["glass"] = {
        name = "glass",
        wait = 500,
        reward = 2,
    },
    ["lockpick"] = {
        name = "lockpick",
        wait = 10000,
        reward = 150,
    },
    ["screwdriverset"] = {
        name = "screwdriverset",
        wait = 10000,
        reward = 300,
    },
    ["electronickit"] = {
        name = "electronickit",
        wait = 10000,
        reward = 300,
    },
    ["radioscanner"] = {
        name = "radioscanner",
        wait = 10000,
        reward = 850,
    },
    ["gatecrack"] = {
        name = "gatecrack",
        wait = 10000,
        reward = 600,
    },
    ["trojan_usb"] = {
        name = "trojan_usb",
        wait = 10000,
        reward = 1000,
    },
    ["weed_brick"] = {
        name = "weed_brick",
        wait = 5000,
        reward = 250,
    },
    ["phone"] = {
        name = "phone",
        wait = 2000,
        reward = 750,
    },
    ["radio"] = {
        name = "radio",
        wait = 2000,
        reward = 180,
    },
    ["handcuffs"] = {
        name = "handcuffs",
        wait = 2000,
        reward = 400,
    },
    ["10kgoldchain"] = {
        name = "10kgoldchain",
        wait = 10000,
        reward = 3000,
    },
}