local emergencyVehicleModels = {
    "police",
    "ambulance",
    -- Add more emergency vehicle models here
}

local opticomRadius = 50.0
local opticomActive = false

local trafficLightStates = {
    ["green"] = { duration = 10 },
    ["yellow"] = { duration = 3 },
    ["red"] = { duration = 15 }
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = GetPlayerPed(-1)
        local playerVehicle = GetVehiclePedIsIn(playerPed, false)
        
        if playerVehicle then
            local modelHash = GetEntityModel(playerVehicle)
            local modelName = GetDisplayNameFromVehicleModel(modelHash)
            
            if IsVehicleAnEmergencyVehicle(playerVehicle) then
                local coords = GetEntityCoords(playerVehicle)
                local nearbyLights = GetNearbyTrafficLights(coords, opticomRadius)
                
                if #nearbyLights > 0 then
                    TriggerEvent("opticom:activate", nearbyLights)
                end
            end
        end
    end
end)

function GetNearbyTrafficLights(coords, radius)
    local lights = {}
    local objects = GetGamePool("CObject")
    
    for _, object in ipairs(objects) do
        if IsObjectAnEntity(object) and IsEntityAVehicle(object) == false then
            local objCoords = GetEntityCoords(object)
            local distance = Vdist2(objCoords, coords)
            
            if distance <= radius * radius then
                table.insert(lights, object)
            end
        end
    end
    
    return lights
end

RegisterNetEvent("opticom:activate")
AddEventHandler("opticom:activate", function(lights)
    if opticomActive then return end
    
    opticomActive = true
    for _, light in ipairs(lights) do
        ChangeTrafficLightState(light, "green")
    end
    
    StopAIVehiclesNearPlayer()
    
    Citizen.Wait(5000) -- Simulate Opticom duration
    opticomActive = false
end)

function ChangeTrafficLightState(light, state)
    if DoesEntityExist(light) then
        -- Change traffic light state based on the specified duration
        local duration = trafficLightStates[state].duration
        SetTrafficLightState(light, state)
        
        Citizen.Wait(duration * 1000)
        
        if state ~= "red" then
            ChangeTrafficLightState(light, "red")
        end
    end
end

function SetTrafficLightState(light, state)
    if state == "green" then
        -- Set traffic light state to green
    elseif state == "yellow" then
        -- Set traffic light state to yellow
    elseif state == "red" then
        -- Set traffic light state to red
    end
end

function StopAIVehiclesNearPlayer()
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    local aiVehicles = GetGamePool("CVehicle")
    
    for _, vehicle in ipairs(aiVehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = Vdist2(vehicleCoords, playerCoords)
        
        if distance <= opticomRadius * opticomRadius then
            SetVehicleForwardSpeed(vehicle, 0.0)
            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        end
    end
end
