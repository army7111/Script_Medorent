-- Crea e attiva CTLD nella missione
local ctld_medorent = CTLD:New(coalition.side.BLUE, {"Helicargo","CSAR"},"CTLD Medorent")

-- Inizio Parametri e opzioni di configurazione
ctld_medorent.dropcratesanywhere = true -- Option to allow crates to be dropped anywhere.
ctld_medorent.enableHercules = true
ctld_medorent.forcehoverload = false
ctld_medorent.CrateDistance = 100

-- Fine Parametri e opzioni di configurazione

-- Tipi di unità utilizzabili
-- Truppe

ctld_medorent:AddTroopsCargo("Ingegneri",{"Engineer"}, CTLD_CARGO.Enum.ENGINEERS,4,80)
-- ctld_medorent:EngineerSearch = 2000
ctld_medorent:AddTroopsCargo("Anti-Tank Squadra Piccola",{"ATS"},CTLD_CARGO.Enum.TROOPS,3,80)
ctld_medorent:AddTroopsCargo("Anti-Air Squadra Piccola",{"AA_Inf"},CTLD_CARGO.Enum.TROOPS,3,80)
-- Veicoli in Box
ctld_medorent:AddCratesCargo("Humvee Scout",{"HeliRecon-"},CTLD_CARGO.Enum.VEHICLE,1,2000)
ctld_medorent:AddCratesCargo("SHORAD",{"SHORAD_Temp"},CTLD_CARGO.Enum.VEHICLE,2,2775)
--ctld_medorent:AddCratesCargo("Forward Ops Base",{"FOB"},CTLD_CARGO.Enum.FOB,8,2775)
ctld_medorent:AddCratesCargo("Postazione NASAMS Completa",{"NASAMSTemplate"},CTLD_CARGO.Enum.VEHICLE,7,2775)
ctld_medorent:AddCratesCargo("Paladin Singolo Artiglieria",{"PaladinM109Template"},CTLD_CARGO.Enum.VEHICLE,3,2775)

-- Fine Tipi di unità utilizzabili

-- Dichiarazione delle zone di carico
ctld_medorent:AddCTLDZone("ZonaCarico",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
ctld_medorent:AddCTLDZone("ZonaCarico-1",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
ctld_medorent:AddCTLDZone("ZonaCarico-2",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
ctld_medorent:AddCTLDZone("ZonaCarico-3",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
-- Start CTLD
ctld_medorent:Start()