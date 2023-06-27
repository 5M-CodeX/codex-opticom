local trippedLights = {} -- Stores the tripped traffic lights

-- Function to check if a vehicle model is whitelisted
function IsVehicleWhitelisted(model)
    if Config.UseWhitelist then
        for _, whitelistedModel in ipairs(Config.EmergencyVehicleWhitelist) do
            if GetHashKey(model) == GetHashKey(whitelistedModel) then
                return true
            end
        end
    end
    return false
end

-- Function to check if a vehicle model is blacklisted
function IsVehicleBlacklisted(model)
    for _, blacklistedModel in ipairs(Config.BlacklistedVehicles) do
        if GetHashKey(model) == GetHashKey(blacklistedModel) then
            return true
        end
    end
    return false
end

-- Function to check if a vehicle is an emergency vehicle
function IsEmergencyVehicle(vehicle)
    local model = GetEntityModel(vehicle)
    return IsVehicleWhitelisted(model) and not IsVehicleBlacklisted(model)
end

-- Function to stop traffic at tripped lights
function StopTrafficAtLights(lights)
    if Config.EnableTrafficControl then
        for _, light in ipairs(lights) do
            SetTrafficLightsLocked(light.object, true)
        end
        Citizen.Wait(Config.TrafficStopDuration)
        for _, light in ipairs(lights) do
            SetTrafficLightsLocked(light.object, false)
        end
    end
end

-- Function to reset tripped lights and traffic
function ResetLightsAndTraffic()
    for _, light in ipairs(trippedLights) do
        SetEntityTrafficlightOverride(light.object, -1)
    end
    trippedLights = {}
    ResetTrafficLights()
end

-- Function to detect and handle traffic lights
function HandleTrafficLights()
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)

    if IsPedInAnyVehicle(player) and IsEmergencyVehicle(vehicle) then
        local coords = GetEntityCoords(vehicle)

        -- Search for nearby traffic lights
        for _, model in ipairs(Config.TrafficLightModels) do
            local trafficLights = GetClosestObjectOfType(coords, Config.DetectionDistance, GetHashKey(model), false, false, false)

            for _, light in ipairs(trafficLights) do
                local lightCoords = GetEntityCoords(light)
                local distance = #(coords - lightCoords)

                if distance <= Config.DetectionRange and not trippedLights[light] then
                    trippedLights[light] = true
                    SetEntityTrafficlightOverride(light, 0) -- Change the light to green

                    -- Debug message
                    TriggerEvent('chat:addMessage', {
                        args = { '^2Opticom:', 'Traffic light tripped!' }
                    })
                end
            end
        end
    end
end

-- Main thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        HandleTrafficLights()
    end
end)

-- Traffic control and reset threads
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.ResetDelay)
        ResetLightsAndTraffic()
    end
end)

-- Traffic stop thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        StopTrafficAtLights(trippedLights)
    end
end)
