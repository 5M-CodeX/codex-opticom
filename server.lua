-- Send request to change traffic light to all clients
RegisterServerEvent("OpticomSystem:TurnLightGreen")
AddEventHandler("OpticomSystem:TurnLightGreen", function(coords)
    TriggerClientEvent("OpticomSystem:TurnLightGreen", -1, coords)
end)
