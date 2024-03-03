-- Crea e attiva CTLD nella missione
CTLD_medorent = CTLD:New(coalition.side.BLUE, {"Helicargo","CSAR","Herccargo"},"CTLD Medorent")
CTLD_medorent:__Start(5)
-- Inizio Parametri e opzioni di configurazione
CTLD_medorent.dropcratesanywhere = true -- Option to allow crates to be dropped anywhere.
CTLD_medorent.enableHercules = true
CTLD_medorent.forcehoverload = false
CTLD_medorent.CrateDistance = 100
-- Fine Parametri e opzioni di configurazione

-- Tipi di unità utilizzabili
---- Truppe
CTLD_medorent:AddTroopsCargo("Ingegneri",{"Engineer"}, CTLD_CARGO.Enum.ENGINEERS,4,80)
-- CTLD_medorent:EngineerSearch = 2000
CTLD_medorent:AddTroopsCargo("Anti-Tank Squadra Piccola",{"ATS"},CTLD_CARGO.Enum.TROOPS,3,80)
CTLD_medorent:AddTroopsCargo("Anti-Air Squadra Piccola",{"AA_Inf"},CTLD_CARGO.Enum.TROOPS,3,80)
---- Veicoli in Box
CTLD_medorent:AddCratesCargo("Humvee Scout",{"HeliRecon-"},CTLD_CARGO.Enum.VEHICLE,1,2000)
CTLD_medorent:AddCratesCargo("SHORAD",{"SHORAD_Temp"},CTLD_CARGO.Enum.VEHICLE,2,2775)
--CTLD_medorent:AddCratesCargo("Forward Ops Base",{"FOB"},CTLD_CARGO.Enum.FOB,8,2775)
CTLD_medorent:AddCratesCargo("Postazione NASAMS Completa",{"NASAMSTemplate"},CTLD_CARGO.Enum.VEHICLE,7,2775)
CTLD_medorent:AddCratesCargo("Paladin Singolo Artiglieria",{"PaladinM109Template"},CTLD_CARGO.Enum.VEHICLE,3,2775)
-- Fine Tipi di unità utilizzabili

-- Dichiarazione delle zone di carico
CTLD_medorent:AddCTLDZone("ZonaCarico",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
CTLD_medorent:AddCTLDZone("ZonaCarico-1",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
CTLD_medorent:AddCTLDZone("ZonaCarico-2",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
CTLD_medorent:AddCTLDZone("ZonaCarico-3",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
-- Start CTLD
