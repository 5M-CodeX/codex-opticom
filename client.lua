-- PARAMETERS --
local SEARCH_STEP_SIZE = 20.0                    -- Step size to search for traffic lights
local SEARCH_MIN_DISTANCE = 5.0                 -- Minimum distance to search for traffic lights
local SEARCH_MAX_DISTANCE = 50.0                 -- Maximum distance to search for traffic lights
local SEARCH_RADIUS = 20.0                       -- Radius to search for traffic light after translating coordinates
local HEADING_THRESHOLD = 40.0                   -- Player must match traffic light orientation within threshold (degrees)
local TRAFFIC_LIGHT_POLL_FREQUENCY_MS = 50      -- Reduce the polling frequency (ms) for quicker detection
local TRAFFIC_LIGHT_GREEN_DURATION_MS = 5000    -- Duration to keep the traffic light green (ms)

-- Array of all traffic light hashes
local trafficLightObjects = {
    [0] = 0x3e2b73a4,   -- prop_traffic_01a
    [1] = 0x336e5e2a,   -- prop_traffic_01b
    [2] = 0xd8eba922,   -- prop_traffic_01d
    [3] = 0xd4729f50,   -- prop_traffic_02a
    [4] = 0x272244b2,   -- prop_traffic_02b
    [5] = 0x33986eae,   -- prop_traffic_03a
    [6] = 0x2323cdc5    -- prop_traffic_03b
}

-- Create a table to track traffic light timers
local trafficLightTimers = {}

-- Function to set a traffic light green and start a timer to reset it
function SetTrafficLightGreen(trafficLight)
    SetEntityTrafficlightOverride(trafficLight, 0) -- Set traffic light green
    ShowNotification("Traffic light set to green.")
    local timer = SetTimeout(TRAFFIC_LIGHT_GREEN_DURATION_MS, function()
        ResetTrafficLight(trafficLight) -- Reset the traffic light to red after the specified duration
    end)
    trafficLightTimers[trafficLight] = timer -- Store the timer for reference
end

-- Function to reset a traffic light to red
function ResetTrafficLight(trafficLight)
    SetEntityTrafficlightOverride(trafficLight, -1) -- Reset the traffic light to red
    ShowNotification("Traffic light reset.")
    trafficLightTimers[trafficLight] = nil -- Remove the timer reference
end

-- Function to display a notification on the screen
function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- Register the server event to turn the traffic light green
RegisterNetEvent("OpticomSystem:TurnLightGreen")
AddEventHandler("OpticomSystem:TurnLightGreen", function(coords)
    -- Check if the player is in a vehicle
    local playerVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    if DoesEntityExist(playerVehicle) then
        local isSirenOn = IsVehicleSirenOn(playerVehicle)
        if isSirenOn then
            -- Find traffic light using trafficLightObjects array
            for _, trafficLightObject in pairs(trafficLightObjects) do
                local trafficLight = GetClosestObjectOfType(coords, 1.0, trafficLightObject, false, false, false)
                if trafficLight ~= 0 then
                    -- Set traffic light green and start the timer
                    SetTrafficLightGreen(trafficLight)
                    break
                end
            end
        end
    end
end)

-- Main thread --
Citizen.CreateThread(function()
    -- Initialize local variables
    local lastTrafficLight = 0

    -- Loop forever and check traffic lights at set interval
    while true do
        Citizen.Wait(TRAFFIC_LIGHT_POLL_FREQUENCY_MS)
        
        -- Get player and check traffic lights when in a vehicle
        local player = GetPlayerPed(-1)
        if IsPedInAnyVehicle(player) then
            -- Get player position, heading and search coordinates
            local playerVehicle = GetVehiclePedIsIn(player, false)
            local isSirenOn = IsVehicleSirenOn(playerVehicle)
            if isSirenOn then
                local playerPosition = GetEntityCoords(player)
                local playerHeading = GetEntityHeading(player)

                -- Search in front of the car for a traffic light that matches the player's heading
                local trafficLight = 0
                for searchDistance = SEARCH_MAX_DISTANCE, SEARCH_MIN_DISTANCE, -SEARCH_STEP_SIZE do
                    -- Get search coordinates and search for all traffic lights using trafficLightObjects array
                    local searchPosition = translateVector3(playerPosition, playerHeading, searchDistance)
                    for _, trafficLightObject in pairs(trafficLightObjects) do
                        -- Check if there is a traffic light in front of the player
                        trafficLight = GetClosestObjectOfType(searchPosition, SEARCH_RADIUS, trafficLightObject, false, false, false)
                        if trafficLight ~= 0 then
                            -- Check traffic light heading relative to player heading (to prevent setting the wrong lights)
                            local lightHeading = GetEntityHeading(trafficLight)
                            local headingDiff = math.abs(playerHeading - lightHeading)
                            if ((headingDiff < HEADING_THRESHOLD) or (headingDiff > (360.0 - HEADING_THRESHOLD))) then
                                -- Within the threshold, stop searching
                                break
                            else
                                -- Outside the threshold, skip and keep searching
                                trafficLight = 0
                            end
                        end
                    end

                    -- If a traffic light is found, stop searching
                    if trafficLight ~= 0 then
                        break
                    end
                end

                -- If a traffic light is found and not the same as the last one
                if (trafficLight ~= 0) and (trafficLight ~= lastTrafficLight) then
                    -- Set traffic light green and start the timer
                    SetTrafficLightGreen(trafficLight)
                    lastTrafficLight = trafficLight
                end
            end
        end
    end
end)

-- Translate vector3 using 2D polar notation (ignoring the z-axis)
function translateVector3(pos, angle, distance)
    local angleRad = angle * 2.0 * math.pi / 360.0
    return vector3(pos.x - distance * math.sin(angleRad), pos.y + distance * math.cos(angleRad), pos.z)
end
