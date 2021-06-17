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
local IsKeyHolder = false
local InTraphouseRange = false

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
            if not IsKeyHolder then
                SendNUIMessage({
                    action = "open"
                })
                SetNuiFocus(true, true)
            else
                EnterTraphouse()
                CurrentTraphouse = ClosestTraphouse
                InsideTraphouse = true
            end
        end
    end
end)

RegisterNUICallback('PinpadClose', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('ErrorMessage', function(data)
    QBCore.Functions.Notify(data.message, 'error')
end)

RegisterNUICallback('EnterPincode', function(d)
    local data = Config.TrapHouses[ClosestTraphouse]
    if tonumber(d.pin) == data.pincode then
        EnterTraphouse()
        CurrentTraphouse = ClosestTraphouse
        InsideTraphouse = true
    else
        QBCore.Functions.Notify('This Code Is Incorrect', 'error')
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
                if ExitDistance < 20 then
                    inRange = true
                    if ExitDistance < 1 then
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
                        if data.money == 0 then
                            DrawText3Ds(data.coords["washer"].x, data.coords["washer"].y, data.coords["washer"].z + 0.2, '~b~H~w~ - Open Washer')
                            --DrawText3Ds(data.coords["washer"].x, data.coords["washer"].y, data.coords["washer"].z, '~r~ Cash: Empty')
                        end
                        if data.money == 2 then
                            DrawText3Ds(data.coords["washer"].x, data.coords["washer"].y, data.coords["washer"].z + 0.1, '~b~ Washing...')
                        end
                        if data.money > 3 then 
                            DrawText3Ds(data.coords["washer"].x, data.coords["washer"].y, data.coords["washer"].z, '~b~E~w~ - Grab Stack of Cash (~g~$'..data.money..'~w~)')
                        end
                        if IsControlJustPressed(0,74) then
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
                    if EnterDistance < 1 then
                        InTraphouseRange = true
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
                local InteractDistance = #(pos - vector3(data.coords["sell"].x, data.coords["sell"].y, data.coords["sell"].z))
                if InteractDistance < 20 then
                    inRange = true
                    if InteractDistance < 1 then
                        if data.laptopmoney == 0 then
                            DrawText3Ds(data.coords["sell"].x, data.coords["sell"].y, data.coords["sell"].z + 0.2, '~b~H~w~ - Open Laptop')
                        end
                        if data.laptopmoney == 2 then
                            DrawText3Ds(data.coords["sell"].x, data.coords["sell"].y, data.coords["sell"].z + 0.1, '~r~ Looking for buyer...')
                        end
                        if data.laptopmoney > 3 then 
                            DrawText3Ds(data.coords["sell"].x, data.coords["sell"].y, data.coords["sell"].z, '~b~E~w~ - Transfer Cash to Bank (~g~$'..data.laptopmoney..'~w~)')
                        end
                        if IsControlJustPressed(0,74) then
                            QBCore.Functions.Progressbar("laptop_open", "opening laptop", math.random(2000, 3000), false, true, {
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
                            local TraphouseInventory = {}
                            TraphouseInventory.label = "placeholder-"..CurrentTraphouse
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
            end
        else
            Citizen.Wait(2000)
        end

        Citizen.Wait(3)
    end
end)

function EnterTraphouse()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    DoScreenFadeOut(1000)
    SetEntityCoords(PlayerPedId(), 1138.129, -3199.196, -39.66, true, true, true, false)
    DoScreenFadeIn(1000)
    CurrentTraphouse = ClosestTraphouse
    InsideTraphouse = true
    SetRainLevel(0.0)
    TriggerEvent('qb-weathersync:client:DisableSync')
    print('Entered')
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(23, 0, 0)
end

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