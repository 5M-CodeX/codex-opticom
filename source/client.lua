-- PARAMETERS --
local SEARCH_STEP_SIZE = 10.0
local SEARCH_MIN_DISTANCE = 5.0
local SEARCH_MAX_DISTANCE = 30.0
local SEARCH_RADIUS = 20.0
local HEADING_THRESHOLD = 40.0
local TRAFFIC_LIGHT_POLL_FREQUENCY_MS = 50
local TRAFFIC_LIGHT_GREEN_DURATION_MS = 5000

-- Array of all traffic light hashes
local trafficLightObjects = {
    0x3e2b73a4, -- prop_traffic_01a
    0x336e5e2a, -- prop_traffic_01b
    0xd8eba922, -- prop_traffic_01d
    0xd4729f50, -- prop_traffic_02a
    0x272244b2, -- prop_traffic_02b
    0x33986eae, -- prop_traffic_03a
    0x2323cdc5  -- prop_traffic_03b
}

-- Create a table to track traffic light timers
local trafficLightTimers = {}

-- Cooldown for notifications
local notificationCooldown = 5000
local lastNotificationTime

-- Function to set a traffic light green and start a timer to reset it
function SetTrafficLightGreen(trafficLight)
    SetEntityTrafficlightOverride(trafficLight, 0)
    ShowNotification("Traffic light set to green.")
    local timer = SetTimeout(TRAFFIC_LIGHT_GREEN_DURATION_MS, function()
        ResetTrafficLight(trafficLight)
    end)
    trafficLightTimers[trafficLight] = timer
end

-- Function to reset a traffic light to red
function ResetTrafficLight(trafficLight)
    SetEntityTrafficlightOverride(trafficLight, -1)
    ShowNotification("Traffic light reset.")
    trafficLightTimers[trafficLight] = nil
end

-- Function to display a notification on the screen
function ShowNotification(text)
    local currentTime = GetGameTimer()
    if not lastNotificationTime or (currentTime - lastNotificationTime > notificationCooldown) then
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, false)
        lastNotificationTime = currentTime
    end
end

-- Function to broadcast traffic light changes
function BroadcastTrafficLightChange(trafficLight, isGreen)
    TriggerServerEvent('trafficlights:syncTrafficLight', trafficLight, isGreen)
end

-- Main thread (modified to use the broadcasting function)
Citizen.CreateThread(function()
    while true do
        local playerPed = GetPlayerPed(-1)

        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if IsVehicleSirenOn(vehicle) then
                local playerPosition = GetEntityCoords(playerPed)
                local playerHeading = GetEntityHeading(playerPed)
                local trafficLight = 0
                local loopFrequency = TRAFFIC_LIGHT_POLL_FREQUENCY_MS

                for searchDistance = SEARCH_MAX_DISTANCE, SEARCH_MIN_DISTANCE, -SEARCH_STEP_SIZE do
                    Citizen.Wait(loopFrequency)

                    local searchPosition = translateVector3(playerPosition, playerHeading, searchDistance)

                    for _, trafficLightObject in pairs(trafficLightObjects) do
                        trafficLight = GetClosestObjectOfType(searchPosition, SEARCH_RADIUS, trafficLightObject, false, false, false)

                        if trafficLight ~= 0 then
                            local lightHeading = GetEntityHeading(trafficLight)
                            local headingDiff = math.abs(playerHeading - lightHeading)

                            if headingDiff < HEADING_THRESHOLD or headingDiff > (360.0 - HEADING_THRESHOLD) then
                                SetTrafficLightGreen(trafficLight)
                                BroadcastTrafficLightChange(trafficLight, true)  -- Broadcast the change
                                break
                            else
                                trafficLight = 0
                            end
                        end
                    end

                    if trafficLight ~= 0 then
                        local normalizedDistance = (searchDistance - SEARCH_MIN_DISTANCE) / (SEARCH_MAX_DISTANCE - SEARCH_MIN_DISTANCE)
                        loopFrequency = math.max(50, math.floor(TRAFFIC_LIGHT_POLL_FREQUENCY_MS - normalizedDistance * (TRAFFIC_LIGHT_POLL_FREQUENCY_MS - 50)))
                        break
                    end
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

-- Translate vector3 using 2D polar notation
function translateVector3(pos, angle, distance)
    local angleRad = angle * 2.0 * math.pi / 360.0
    return vector3(pos.x - distance * math.sin(angleRad), pos.y + distance * math.cos(angleRad), pos.z)
end
