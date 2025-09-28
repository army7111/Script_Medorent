# MEDORENT RANGE SAM - Guida Configurazione Skynet IADS

## 📋 Panoramica
Questo documento descrive come configurare e utilizzare il sistema Range SAM basato su Skynet IADS, completamente compatibile con MOOSE Framework.

## ✅ Compatibilità Skynet + MOOSE
**Skynet IADS è completamente compatibile con MOOSE:**
- ✅ Entrambi utilizzano le stesse DCS API di base
- ✅ Nessun conflitto tra i framework
- ✅ Possono essere utilizzati insieme senza problemi
- ✅ Skynet può coesistere con TASK_A2A_DISPATCHER e altri sistemi MOOSE

## 🎯 Funzionalità Principali

### Sistema IADS Integrato
- **Comunicazioni realistiche** tra SAM ed EWR
- **Attivazione intelligente** dei SAM solo quando necessario
- **Gestione automatica** delle minacce SEAD/DEAD
- **Coordinamento** tra sistemi SAM multipli

### Gestione Avanzata
- **Respawn automatico** SAM distrutti (configurabile)
- **Menu F10** per controllo manuale del sistema
- **Integrazione** con sistema Range esistente
- **Debug mode** per troubleshooting

### Modalità Operative
- **Autonoma**: SAM sparano automaticamente
- **Manuale**: Controllo tramite menu F10
- **Training**: Integrata con sistema Range

## 🛠️ Requisiti Mission Editor

### 1. Gruppi SAM (OBBLIGATORI)
Creare i seguenti gruppi con **"Late Activation" abilitata**:

```
- RangeSAM-SA10    → SA-10/S-300 (Long Range)
- RangeSAM-SA15    → SA-15/Tor (Short Range)
```

**Configurazione gruppi SAM:**
- ✅ Late Activation: **ATTIVA**
- ✅ Paese: Russia o altro paese RED
- ✅ Skill: Excellent o High
- ✅ Posizionare nell'area del Range

### 2. Gruppi EWR (OPZIONALI)
Gruppi radar per detection a lungo raggio:

```
- RangeEWR-1       → EWR Primario
- RangeEWR-2       → EWR Secondario (opzionale)
```

**Tipi EWR consigliati:**
- 55G6 EWR
- 1L13 EWR  
- Big Bird (A-50 se disponibile)

### 3. Zona Range (OBBLIGATORIA)
- **Nome**: `RangeZone`
- **Tipo**: Trigger Zone (circolare o poligonale)
- **Posizione**: Area del Range da proteggere
- **Raggio suggerito**: 15-25 NM

### 4. Struttura Mission Editor
```
Groups:
├── Red Air Defense
│   ├── RangeSAM-SA10 (Late Activation)
│   └── RangeSAM-SA15 (Late Activation)
├── Red EWR
│   ├── RangeEWR-1 (Late Activation)
│   └── RangeEWR-2 (Late Activation, opzionale)
└── Blue Forces
    └── [Gruppi giocatori]

Zones:
└── RangeZone (Trigger Zone)
```

## ⚙️ Configurazione Script

### Parametri Principali
Nel file `MedorentRangeSAM.lua`, sezione `RANGE_SAM_CONFIG`:

```lua
local RANGE_SAM_CONFIG = {
    nome_iads = "RangeSAM",              -- Nome del sistema
    coalizione = coalition.side.RED,     -- Coalizione SAM
    debug_mode = true,                   -- Debug ON/OFF
    
    -- Lista gruppi SAM (aggiungere se necessario)
    sam_gruppi = {
        "RangeSAM-SA10",
        "RangeSAM-SA15",
        -- "RangeSAM-Pantsir",           -- Esempio aggiunta
    },
    
    -- Lista gruppi EWR
    ewr_gruppi = {
        "RangeEWR-1",
        "RangeEWR-2",
    },
    
    modalita_autonoma = false,           -- Auto-fire ON/OFF
    soppressione_sead = true,            -- Soppressione SEAD ON/OFF
    respawn_automatico = true,           -- Respawn automatico ON/OFF
}
```

### Configurazioni Avanzate

#### Tipi SAM Supportati
Il sistema riconosce automaticamente e configura:

- **SA-10/S-300** (Long Range)
  - Attivazione: 85% range massimo
  - Modalità: Attiva quando target in search range
  
- **SA-15/Tor** (Short Range)  
  - Attivazione: 95% range massimo
  - Modalità: Attiva solo quando target in kill zone

#### Personalizzazione Gruppi
Per aggiungere nuovi tipi SAM:

```lua
-- Nel file MedorentRangeSAM.lua, cerca la funzione InizializzaSkynetIADS()
-- Aggiungi nuove condizioni per tipi specifici:

elseif string.find(samName, "Pantsir") then
    -- Configurazione per Pantsir
    samSite:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
    samSite:setGoLiveRangeInPercent(90)
    LogInfo("SAM SHORAD configurato: " .. samName)
```

## 🎮 Utilizzo Menu F10

### Accesso Menu
1. Premere **F10** in volo
2. Selezionare **"🎯 Range SAM Control"**

### Opzioni Disponibili

#### 📊 Status Sistema
- **📋 Mostra Status SAM**: Visualizza stato di tutti i SAM
- **🔍 Lista Target Tracciati**: Target attualmente rilevati (in sviluppo)

#### 🎮 Controlli Range  
- **🔴 Disattiva Tutti SAM**: Spegne sistema IADS
- **🟢 Riattiva Tutti SAM**: Riaccende sistema IADS
- **🔄 Reset Sistema IADS**: Reset completo del sistema

## 🔧 Troubleshooting

### Problemi Comuni

#### "Zona RangeZone non trovata"
**Soluzione:**
1. Verificare che esista una Trigger Zone chiamata esattamente `RangeZone`
2. Controllare spelling (case-sensitive)
3. Assicurarsi che la zona sia salvata correttamente

#### "Nessun gruppo SAM trovato"
**Soluzione:**
1. Verificare esistenza gruppi con nomi esatti:
   - `RangeSAM-SA10`
   - `RangeSAM-SA15`
2. Controllare che abbiano "Late Activation" abilitata
3. Verificare che siano della coalizione RED

#### "Sistema non si attiva"
**Soluzione:**
1. Abilitare `debug_mode = true` in configurazione
2. Controllare DCS.log per errori specifici
3. Verificare che Skynet IADS sia caricato correttamente

### Debug Mode
Per attivare debug dettagliato:

```lua
local RANGE_SAM_CONFIG = {
    debug_mode = true,        -- Abilita logging dettagliato
    -- ... resto configurazione
}
```

**Messaggi debug verranno mostrati:**
- Nel DCS.log
- In chat in-game (se abilitato)

## 🔗 Integrazione con Sistema Esistente

### Compatibilità OnTheRange.lua
Il sistema Range SAM si integra automaticamente con il sistema Range esistente (`OnTheRange.lua`):

```lua
-- Il sistema rileva automaticamente se Rayakrange è attivo
if Rayakrange then
    LogInfo("Sistema Range esistente rilevato - Integrazione in corso...")
    -- Logica integrazione...
end
```

### Coesistenza con Altri Script
Il sistema è progettato per coesistere con:
- ✅ `LarnacaGCI.lua` (A2A Dispatcher)
- ✅ `MedorentAwacs.lua` (Sistema AWACS)  
- ✅ `MedorentHeli.lua` (Task system elicotteri)
- ✅ `CTLD_MOOSE.lua` (Sistema logistics)

## 📚 Risorse Aggiuntive

### Documentazione Skynet IADS
- **GitHub**: https://github.com/walder/Skynet-IADS
- **Wiki**: Documentazione completa API Skynet
- **Examples**: Esempi configurazione avanzata

### Tipi Unità Supportati
Skynet IADS supporta automaticamente tutti i SAM DCS:
- SA-2, SA-3, SA-5, SA-6, SA-8, SA-10, SA-11, SA-15, SA-17, SA-19
- Hawk, Patriot, Roland, Rapier
- Pantsir, Tunguska
- Tor, Osa, Strela, Kub
- E molti altri...

### Configurazioni Avanzate
Per configurazioni più complesse (settori, power management, etc.), 
consultare la documentazione ufficiale Skynet IADS.

---

## 📞 Supporto
Per problemi o domande specifiche:
1. Controllare prima questo documento
2. Abilitare debug mode
3. Consultare DCS.log per errori
4. Verificare configurazione Mission Editor