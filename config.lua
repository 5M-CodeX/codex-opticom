Config = {}

-- Detection Settings
Config.DetectionDistance = 80.0         -- Distance at which the Opticom detects traffic lights (in meters)
Config.DetectionRange = 10.0            -- Radius around the detected traffic light to trigger the effect (in meters)

-- Whitelist Settings
Config.UseWhitelist = true              -- Enable/disable whitelisting of emergency vehicles
Config.EmergencyVehicleWhitelist = {     -- List of vehicle models that can trigger the Opticom effect
    'police',
    'police2',
    'police3',
    'police4'
}

-- Blacklist Settings
Config.BlacklistedVehicles = {          -- List of vehicle models that should be ignored by the Opticom
    'bmx',
    'cruiser'
}

-- Traffic Control Settings
Config.EnableTrafficControl = true      -- Enable/disable traffic control when the Opticom is triggered
Config.TrafficStopDuration = 5000       -- Duration (in milliseconds) for which traffic stops at tripped lights

-- Reset Settings
Config.ResetDelay = 30000               -- Delay (in milliseconds) before the traffic lights and traffic reset after detectance

-- Traffic Light Models
Config.TrafficLightModels = {           -- List of traffic light models to detect and control
    'prop_traffic_01a',
    'prop_traffic_01b',
    'prop_traffic_01d',
    'prop_traffic_02a',
    'prop_traffic_02b',
    'prop_traffic_03a',
    'prop_traffic_03b',
    'prop_traffic_lights_01',
    'prop_traffic_lights_02',
    'prop_traffic_lights_03'
}
