--US_HQ = COMMANDCENTER:New((GROUP:FindByName("BLUEHQ")),"Blue Command Center")
--RU_HQ = COMMANDCENTER:New((GROUP:FindByName("REDHQ")), "Red Command Center")


-- Decl Warehouses
WarehousesLAND = {}
WarehousesCypro = {}
WarehousesSHIP = {}

local warehouseData = {
    {table = WarehousesLAND, name = "Incirlik", staticName = "WHINCIRLIK", warehouseName = "Warehouse Incirlik", airport = "Incirlik"},
    {table = WarehousesLAND, name = "Gazipasa", staticName = "WHGAZIPASA", warehouseName = "Warehouse Gazipasa", airport = "Gazipasa"},
    {table = WarehousesLAND, name = "Bassel_Al_Assad", staticName = "WHBASSELALASSAD", warehouseName = "Warehouse Bassel Al-Assad", airport = "Bassel Al-Assad"},
    {table = WarehousesCypro, name = "Paphos", staticName = "WHPAPHOS", warehouseName = "Warehouse Paphos", airport = "Paphos"},
    {table = WarehousesCypro, name = "Akrotiri", staticName = "WHAKROTIRI", warehouseName = "Warehouse Akrotiri", airport = "Akrotiri"},
    {table = WarehousesCypro, name = "Pinarbashi", staticName = "WHPINARBASHI", warehouseName = "Warehouse Pinarbashi", airport = "Pinarbashi"},
    {table = WarehousesCypro, name = "Lakatamia", staticName = "WHLAKATAMIA", warehouseName = "Warehouse Lakatamia", airport = "Lakatamia"},
    {table = WarehousesCypro, name = "Ercan", staticName = "WHERCAN", warehouseName = "Warehouse Ercan", airport = "Ercan"},
    {table = WarehousesCypro, name = "Larnaca", staticName = "WHLARNACA", warehouseName = "Warehouse Larnaca", airport = "Larnaca"},
    {table = WarehousesCypro, name = "Kingsfield", staticName = "WHKINGSFIELD", warehouseName = "Warehouse Kingsfield", airport = "Kingsfield"},
    {table = WarehousesCypro, name = "Gecitkale", staticName = "WHGECITKALE", warehouseName = "Warehouse Gecitkale", airport = "Gecitkale"},
    {table = WarehousesCypro, name = "EastCypro", staticName = "WHEASTCYPRO", warehouseName = "Warehouse East Cypro", airport = "FARPCyproEast"}
}

for _, data in ipairs(warehouseData) do
    local warehouse = WAREHOUSE:New(STATIC:FindByName(data.staticName), data.warehouseName)
    
        if data.airport then
        local airport = AIRBASE:FindByName(data.airport)
        warehouse:SetAirbase(airport)
end
    warehouse:Start()
    data.table[data.name] = warehouse
end

-- -- Inizializzazione Warehouse con unità

-- WarehousesLAND.Incirlik:AddAsset("REDAICAP", 10)
-- WarehousesLAND.Incirlik:AddAsset("TEMPL-AirTransportRED", 10, WAREHOUSE.Attribute.AIRTRANSPORT, 90000 )
-- WarehousesLAND.Incirlik:AddAsset("TEMPL-RedTank", 50)
-- WarehousesLAND.Incirlik:AddAsset("TEMPL-RedTruck", 50)
-- WarehousesLAND.Incirlik:AddAsset("TEMPL-RedInf", 100)
-- WarehousesLAND.Incirlik:AddAsset("TEMPL-SA15", 10)
-- WarehousesLAND.Incirlik:AddAsset("TEMPL-RedAAA", 10)
-- WarehousesLAND.Incirlik:AddAsset("TEMPL-BAISu25", 50)

-- -- Funzione per la richiesta semplice di unità: ex. 
-- function RequestResource(fromWarehouse, toWarehouse, groupName, number, transportType)
--     -- DEBUG - Invia messaggio con dati richiesta
--     MESSAGE:New("Richiesta da " .. fromWarehouse:GetAirbaseName() .. " per " .. toWarehouse:GetAirbaseName() .. " di " .. number .. " " .. groupName, 60):ToAll()
--     -- Controlla se le coalizioni dei magazzini sono uguali
--     if fromWarehouse:GetCoalition() ~= toWarehouse:GetCoalition() then
--         print("Richiesta negata: Le coalizioni dei magazzini non sono uguali")
--         return
--     end
--     if transportType == nil then
--         fromWarehouse:AddRequest(toWarehouse, WAREHOUSE.Descriptor.GROUPNAME, groupName, number)
--     else
--         fromWarehouse:AddRequest(toWarehouse, WAREHOUSE.Descriptor.GROUPNAME, groupName, number, transportType)
--     end
-- end

-- function InitialRequest()
--     RequestResource(WarehousesLAND.Incirlik, WarehousesCypro.Larnaca, "TEMPL-RedTank", 5, WAREHOUSE.TransportType.AIRPLANE)
-- end

-- SchedulazioneIniziale = SCHEDULER:New( nil, InitialRequest, {}, 10, 300, 0, 3600 )
WAREHOUSE:SetDebugOn()
