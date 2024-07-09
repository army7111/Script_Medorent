RedSamSpawn = SPAWN:New("CIPROREDSAM-SA10Ercan")
RedSamSpawn:InitLimit(12, 100)
RedSamSpawn:SpawnScheduled( 10800, 0.9, false )

RedSamSpawnEastSA15 = SPAWN:New("CIPROREDSAM-SA15East")
RedSamSpawnEastSA15:InitLimit(2, 100)
RedSamSpawnEastSA15:SpawnScheduled( 10800, 0.9, false )


CyproStratego = STRATEGO:New("CyproStratego",coalition.side.RED, 70)
CyproStratego:SetUsingBudget(true,500)
CyproStratego:SetDebug(false,false,false)
CyproStratego:Start()

local czCypro = {
    {table = CZCypro, name = "Paphos", airport = "AIRBASE.Syria.Paphos"},
    {table = CZCypro, name = "Akrotiri", airport = "AIRBASE.Syria.Akrotiri"},
    {table = CZCypro, name = "Pinarbashi", airport = "AIRBASE.Syria.Pinarbashi"},
    {table = CZCypro, name = "Lakatamia", airport = "AIRBASE.Syria.Lakatamia"},
    {table = CZCypro, name = "Ercan", airport = "AIRBASE.Syria.Ercan"},
    {table = CZCypro, name = "Larnaca", airport = "AIRBASE.Syria.Larnaca"},
    {table = CZCypro, name = "Kingsfield", airport = "AIRBASE.Syria.Kingsfield"},
    {table = CZCypro, name = "Gecitkale", airport = "AIRBASE.Syria.Gecitkale"},
    {table = CZCypro, name = "EastCypro", airport = "EastCyproFarp"}
}

-- Inizializza Warehouse Cypro

WarehousesCypro = {}
WarehouseNasi = {}
local warehouseData = {
    {table = WarehouseNasi, name = "An Nasiriyah", staticName = "WHAnNasiriyah", warehouseName = "Warehouse An Nasiriyah", airport = "An_Nasiriyah"},
    {table = WarehousesCypro, name = "Paphos", staticName = "WHPAPHOS", warehouseName = "Warehouse Paphos", airport = "Paphos"},
    {table = WarehousesCypro, name = "Akrotiri", staticName = "WHAKROTIRI", warehouseName = "Warehouse Akrotiri", airport = "Akrotiri"},
    {table = WarehousesCypro, name = "Pinarbashi", staticName = "WHPINARBASHI", warehouseName = "Warehouse Pinarbashi", airport = "Pinarbashi"},
    {table = WarehousesCypro, name = "Lakatamia", staticName = "WHLAKATAMIA", warehouseName = "Warehouse Lakatamia", airport = "Lakatamia"},
    {table = WarehousesCypro, name = "Ercan", staticName = "WHERCAN", warehouseName = "Warehouse Ercan", airport = "Ercan"},
    {table = WarehousesCypro, name = "Larnaca", staticName = "WHLARNACA", warehouseName = "Warehouse Larnaca", airport = "Larnaca"},
    {table = WarehousesCypro, name = "Kingsfield", staticName = "WHKINGSFIELD", warehouseName = "Warehouse Kingsfield", airport = "Kingsfield"},
    {table = WarehousesCypro, name = "Gecitkale", staticName = "WHGECITKALE", warehouseName = "Warehouse Gecitkale", airport = "Gecitkale"},
    {table = WarehousesCypro, name = "Nicosia", staticName = "WHNICOSIA", warehouseName = "Warehouse Nicosia", airport = "Nicosia"},
    {table = WarehousesCypro, name = "EastCypro", staticName = "WHEASTCYPRO", warehouseName = "Warehouse East Cypro", airport = "EastCyproFarp"}
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