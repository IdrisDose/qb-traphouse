QBCore = nil
isLoggedIn = false
PlayerData = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            Citizen.Wait(200)
        end
    end
end)

local ClosestTraphouse = nil
local InsideTraphouse = false
local CurrentTraphouse = nil
local InTraphouseRange = false
local selling = false

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            SetClosestTraphouse()
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    Wait(1000)
    if QBCore.Functions.GetPlayerData() ~= nil then
        isLoggedIn = true
        PlayerData = QBCore.Functions.GetPlayerData()
        QBCore.Functions.TriggerCallback('qb-traphouse:server:GetTraphousesData', function(trappies)
            Config.TrapHouses = trappies
        end)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerData = QBCore.Functions.GetPlayerData()
    QBCore.Functions.TriggerCallback('qb-traphouse:server:GetTraphousesData', function(trappies)
        Config.TrapHouses = trappies
    end)
end)

function SetClosestTraphouse()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil
    for id, traphouse in pairs(Config.TrapHouses) do
        if current ~= nil then
            if #(pos - vector3(Config.TrapHouses[id].coords.enter.x, Config.TrapHouses[id].coords.enter.y, Config.TrapHouses[id].coords.enter.z)) < dist then
                current = id
                dist = #(pos - vector3(Config.TrapHouses[id].coords.enter.x, Config.TrapHouses[id].coords.enter.y, Config.TrapHouses[id].coords.enter.z))
            end
        else
            dist = #(pos - vector3(Config.TrapHouses[id].coords.enter.x, Config.TrapHouses[id].coords.enter.y, Config.TrapHouses[id].coords.enter.z))
            current = id
        end
    end
    ClosestTraphouse = current
end

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent('qb-traphouse:client:EnterTraphouse')
AddEventHandler('qb-traphouse:client:EnterTraphouse', function(code)
    if ClosestTraphouse ~= nil then
        if InTraphouseRange then
            local data = Config.TrapHouses[ClosestTraphouse]
            SendNUIMessage({
                action = "open"
            })
            SetNuiFocus(true, true)
        end
    end
end)

RegisterNUICallback('PinpadClose', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('EnterPincode', function(d)
    local data = Config.TrapHouses[ClosestTraphouse]
    if tonumber(d.pin) == data.pincode then
        EnterTraphouse()
        CurrentTraphouse = ClosestTraphouse
        InsideTraphouse = true
    else
        QBCore.Functions.Notify('Incorrect Code', 'error')
    end
end)

--  !!!!!!!!!!!!!!!!!!!!!!!!! BT TARGET SHIT Un-Comment if you would like to use it, I cant find a way to make it work in Config.lua lol  !!!!!!!!!!!!!!!!!!!!!!!!!

--[[Citizen.CreateThread(function()
    exports["bt-target"]:AddBoxZone("EnterTrap", vector3(636.49, 2786.20, 42.00), 0.9, 0.6, {
        name="EnterTrap",
        heading=91,
        debugPoly=false,
        minZ=41.79,
        maxZ=42.99
        }, {
            options = {
                {
                    event = "qb-traphouse:client:EnterTraphouse",
                    icon = "fas fa-door-closed",
                    label = "Enter",
                    job = {"all"},
                },
            },
            distance = 1.5
        })
    end)

Citizen.CreateThread(function()
    exports["bt-target"]:AddBoxZone("LeaveTrap", vector3(1138.129, -3199.196, -39.66), 0.9, 0.6, {
        name="LeaveTrap",
        heading=91,
        debugPoly=false,
        minZ=-40.79,
        maxZ=-37.99
        }, {
            options = {
                {
                    event = "qb-traphouse:client:LeaveTraphouse",
                    icon = "fas fa-door-closed",
                    label = "Leave",
                    job = {"all"},
                },
            },
            distance = 1.5
        })
    end)

    Citizen.CreateThread(function()
        exports["bt-target"]:AddBoxZone("OpenLaptop", vector3(1129.50, -3193.60, -40.65), 0.6, 0.6, {
            name="OpenLaptop",
            heading=91,
            debugPoly=true,
            minZ=-40.79,
            maxZ=-38.99
            }, {
                options = {
                    {
                        event = "qb-traphouse:Laptop",
                        icon = "far fa-sitemap",
                        label = "Open Laptop",
                        job = {"all"},
                    },
                },
                distance = 1.5
            })
        end)

RegisterNetEvent("qb-traphouse:Laptop")
AddEventHandler("qb-traphouse:Laptop", function()
    local data = Config.TrapHouses[ClosestTraphouse]
    local TraphouseInventory = {}
    TraphouseInventory.label = "Laptop-"..CurrentTraphouse
    TraphouseInventory.items = data.inventory
    TraphouseInventory.slots = 10
    TraphouseInventory.maxweight = 100000
    TriggerServerEvent("inventory:server:OpenInventory", "traphouse", CurrentTraphouse, TraphouseInventory)
end)]]

Citizen.CreateThread(function()
    while true do

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local inRange = false

        if ClosestTraphouse ~= nil then
            local data = Config.TrapHouses[ClosestTraphouse]
            if InsideTraphouse then
                local ExitDistance = #(pos - vector3(1138.119, -3199.49, -39.66))
                if ExitDistance < 20 and Config.Marker == 1 then
                    inRange = true
                    if ExitDistance < 1 and Config.Marker == 1 then
                        DrawText3Ds(1138.119, -3199.49, -39.66, '~b~E~w~ - Leave')
                        if IsControlJustPressed(0, 38) then
                            LeaveTraphouse(data)
                        end
                    end
                end

                local InteractDistance = #(pos - vector3(data.coords["washer"].x, data.coords["washer"].y, data.coords["washer"].z))
                CurrentTraphouse = ClosestTraphouse
                if InteractDistance < 20 then
                    inRange = true
                    if InteractDistance < 1 then

                    -- I know the code looks fucking horrible but it works... idk how... but it does

                        if data.money == 0 and data.laptopmoney == 0 then
                            DrawText3Ds(data.coords["washer"].x, data.coords["washer"].y, data.coords["washer"].z + 0.2, '~b~H~w~ - Open Washer')
                            selling = false
                        elseif data.money == 2 and data.laptopmoney == 0 then
                            DrawText3Ds(data.coords["washer"].x, data.coords["washer"].y, data.coords["washer"].z + 0.1, '~b~ Washing...')
                            selling = true
                        elseif data.money > 3 and data.laptopmoney == 0 then
                            DrawText3Ds(data.coords["washer"].x, data.coords["washer"].y, data.coords["washer"].z, '~b~E~w~ - Grab Stack of Cash (~g~$'..data.money..'~w~)')
                            selling = true
                        else
                            DrawText3Ds(data.coords["washer"].x, data.coords["washer"].y, data.coords["washer"].z + 0.1, '~r~ Too much electricity being used')
                            selling = true
                        end
                        if IsControlJustPressed(0,74) and selling == false then
                            QBCore.Functions.Progressbar("bills_wash", "opening washer", math.random(2000, 3000), false, true, {
                                disableMovement = false,
                                disableCarMovement = false,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                            animDict = "mp_car_bomb",
                            anim = "car_bomb_mechanic",
                            flags = 16,
                            }, {}, {}, function() -- Done
                                StopAnimTask(GetPlayerPed(-1), "mp_car_bomb", "car_bomb_mechanic", 1.0)
                                washer = 4
                            local TraphouseInventory = {}
                            TraphouseInventory.label = "Washer-"..CurrentTraphouse
                            TraphouseInventory.items = data.inventory
                            TraphouseInventory.slots = 1
                            TraphouseInventory.maxweight = 100000
                            TriggerServerEvent("inventory:server:OpenInventory", "traphouse", CurrentTraphouse, TraphouseInventory)
                            end, function()
                                QBCore.Functions.Notify("Canceled..", "error")
                            end)                        
                            end
                            if IsControlJustPressed(0, 38) and data.money > 100 then
                                QBCore.Functions.Progressbar("bills_collect", "collecting clean bill's...", math.random(2000, 3000), false, true, {
                                    disableMovement = false,
                                    disableCarMovement = false,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                animDict = "mp_car_bomb",
                                anim = "car_bomb_mechanic",
                                flags = 16,
                                }, {}, {}, function() -- Done
                                    TriggerServerEvent("qb-traphouse:server:TakeMoney", CurrentTraphouse)
                                    TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                                    StopAnimTask(GetPlayerPed(-1), "mp_car_bomb", "car_bomb_mechanic", 1.0)
                                    collect = false                        
                                end, function()
                                    QBCore.Functions.Notify("Canceled..", "error")
                                end)
                            end
                    end
                end
            else
                local EnterDistance = #(pos - vector3(data.coords["enter"].x, data.coords["enter"].y, data.coords["enter"].z))
                if EnterDistance < 20 then
                    inRange = true
                    if EnterDistance > 1 then
                        InTraphouseRange = true
                    elseif  EnterDistance < 2.0 and Config.Marker == 1 then
                        DrawText3Ds(data.coords["enter"].x, data.coords["enter"].y, data.coords["enter"].z, '~b~E~w~ - Enter')
                        InTraphouseRange = true
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('qb-traphouse:server:Enter')
                        end
                    else
                        if InTraphouseRange then
                            InTraphouseRange = false
                        end
                    end
                end
            end
        else
            Citizen.Wait(2000)
        end

        Citizen.Wait(3)
    end
end)

Citizen.CreateThread(function()
    while true do

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local inRange = false

        if ClosestTraphouse ~= nil then
            local data = Config.TrapHouses[ClosestTraphouse]
            if InsideTraphouse then
                local ExitDistance = #(pos - vector3(1138.119, -3199.49, -39.66))
                local InteractDistance = #(pos - vector3(data.coords["laptop"].x, data.coords["laptop"].y, data.coords["laptop"].z))
                if InteractDistance < 20 then
                    inRange = true
                    if InteractDistance < 1 then
                        if data.laptopmoney == 0 and data.money == 0 then
                            DrawText3Ds(data.coords["laptop"].x, data.coords["laptop"].y, data.coords["laptop"].z + 0.2, '~b~H~w~ - Open Laptop')
                            selling = false
                        elseif data.laptopmoney == 2 and data.money == 0 then
                            DrawText3Ds(data.coords["laptop"].x, data.coords["laptop"].y, data.coords["laptop"].z + 0.1, '~r~ Looking for buyer...')
                            selling = true
                        elseif data.laptopmoney > 3 and data.money == 0 then 
                            DrawText3Ds(data.coords["laptop"].x, data.coords["laptop"].y, data.coords["laptop"].z, '~b~E~w~ - Transfer Cash to Bank (~g~$'..data.laptopmoney..'~w~)')
                            selling = true
                        else
                            DrawText3Ds(data.coords["laptop"].x, data.coords["laptop"].y, data.coords["laptop"].z + 0.1, '~r~ Too much electricity being used')
                            selling = true
                        end
                        if IsControlJustPressed(0,74) and selling == false then
                            QBCore.Functions.Progressbar("laptop_open", "opening laptop", math.random(2000, 3000), false, true, {
                                disableMovement = true,
                                disableCarMovement = false,
                                disableMouse = false,
                                disableCombat = true,
                            }, {
                            animDict = "missheist_jewel@hacking",
                            anim = "hack_loop",
                            flags = 16,
                            }, {}, {}, function() -- Done
                                StopAnimTask(GetPlayerPed(-1), "missheist_jewel@hacking", "hack_loop", 1.0)
                            local TraphouseInventory = {}
                            TraphouseInventory.label = "Laptop-"..CurrentTraphouse
                            TraphouseInventory.items = data.inventory
                            TraphouseInventory.slots = 10
                            TraphouseInventory.maxweight = 100000
                            TriggerServerEvent("inventory:server:OpenInventory", "traphouse", CurrentTraphouse, TraphouseInventory)
                            end, function()
                                QBCore.Functions.Notify("Canceled..", "error")
                            end)                        
                            end
                            if IsControlJustPressed(0, 38) and data.laptopmoney > 4 then
                                QBCore.Functions.Progressbar("laptop_collect", "hackerman stuff", math.random(2000, 3000), false, true, {
                                    disableMovement = false,
                                    disableCarMovement = false,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                animDict = "missheist_jewel@hacking",
                                anim = "hack_loop",
                                flags = 16,
                                }, {}, {}, function() -- Done
                                    TriggerServerEvent("qb-traphouse:server:TakeMoney", CurrentTraphouse)
                                    TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                                    StopAnimTask(GetPlayerPed(-1), "missheist_jewel@hacking", "hack_loop", 1.0)
                                    collect = false                        
                                end, function()
                                    QBCore.Functions.Notify("Canceled..", "error")
                                end)
                            end
                    end
                end
            else
            end
        else
            Citizen.Wait(2000)
        end

        Citizen.Wait(3)
    end
end)

function EnterTraphouse()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    DoScreenFadeOut(250)
    Citizen.Wait(250)
        SetEntityCoords(PlayerPedId(), 1138.129, -3199.196, -39.66, true, true, true, false)
        DoScreenFadeIn(250)
        CurrentTraphouse = ClosestTraphouse
        InsideTraphouse = true
        --SetRainLevel(0.0)
        --TriggerEvent('qb-weathersync:client:DisableSync')
        print('Entered')
        --SetWeatherTypePersist('EXTRASUNNY')
        --SetWeatherTypeNow('EXTRASUNNY')
        --SetWeatherTypeNowPersist('EXTRASUNNY')
        NetworkOverrideClockTime(23, 0, 0)
end

RegisterNetEvent('qb-traphouse:client:LeaveTraphouse')
AddEventHandler('qb-traphouse:client:LeaveTraphouse', function()
    local ped = PlayerPedId()
    local data = Config.TrapHouses[ClosestTraphouse]
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    DoScreenFadeOut(250)
    Citizen.Wait(250)
       -- TriggerEvent('qb-weathersync:client:EnableSync')
        DoScreenFadeIn(250)
        SetEntityCoords(ped, data.coords["enter"].x, data.coords["enter"].y, data.coords["enter"].z + 0.5)
        SetEntityHeading(ped, data.coords["enter"].h)
        CurrentTraphouse = nil
        InsideTraphouse = false
end)

function LeaveTraphouse(data)
    local ped = PlayerPedId()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    DoScreenFadeOut(250)
    Citizen.Wait(250)
        TriggerEvent('qb-weathersync:client:EnableSync')
        DoScreenFadeIn(250)
        SetEntityCoords(ped, data.coords["enter"].x, data.coords["enter"].y, data.coords["enter"].z + 0.5)
        SetEntityHeading(ped, data.coords["enter"].h)
        CurrentTraphouse = nil
        InsideTraphouse = false
end

RegisterNetEvent('qb-traphouse:client:SyncData')
AddEventHandler('qb-traphouse:client:SyncData', function(k, data)
    Config.TrapHouses[k] = data
end)
