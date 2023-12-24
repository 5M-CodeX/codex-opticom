-- Server side event to broadcast traffic light changes to all clients
RegisterServerEvent('trafficlights:syncTrafficLight')
AddEventHandler('trafficlights:syncTrafficLight', function(trafficLight, isGreen)
    TriggerClientEvent('trafficlights:updateTrafficLight', -1, trafficLight, isGreen)
end)