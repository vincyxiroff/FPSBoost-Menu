## 1. Design Architetturale

```mermaid
flowchart LR
  A["client.lua (FiveM)"] -->| "SendNUIMessage" | B["NUI (HTML/CSS/JS)"]
  B -->| "fetch NUI callback" | A
  A --> C["Natives / culling / timecycle"]
  A --> D["KVP (persistenza profilo)"]
```

## 2. Tecnologie
- Runtime: Lua 5.4 (client) + NUI (HTML/CSS/JS)
- UI: pagina singola statica (senza build) con CSS custom e JS modulare
- Comunicazione: `SendNUIMessage` + `RegisterNUICallback` (pattern NUI standard FiveM)
- Dipendenze: nessuna aggiuntiva lato web; `ox_lib` opzionale (fallback/compatibilità) controllato da config.lua

## 3. Struttura File (proposta)
- `fxmanifest.lua`
  - aggiunta `ui_page` e `files` per asset NUI
- `client/client.lua`
  - gestione apertura UI (command + opzionale keybind), focus NUI, callbacks, stato attivo
- `config.lua`
  - nuove opzioni UI e comportamento
- `web/`
  - `index.html`
  - `assets/` (font locali, icone, background/noise)
  - `styles.css`
  - `app.js`

## 4. Contratto Messaggi NUI

### 4.1 Messaggi da client → NUI (SendNUIMessage)
- `type: "fpsboost:state"`
  - `activeProfile`: `"ultra_low" | "medium" | "high" | "ultra_graphics" | "reset"`
  - `boostActive`: `boolean`
  - `locale`: `"it" | "en"`
  - `config`: subset non-sensibile (es. limiti slider, UI mode)

- `type: "fpsboost:open"`
  - payload stato iniziale

- `type: "fpsboost:close"`

### 4.2 Callback da NUI → client (RegisterNUICallback)
- `applyProfile`
  - body: `{ profile: string }`
- `applyTimecycle`
  - body: `{ name: string, strength?: number }`
- `resetAll`
- `setLocale`
  - body: `{ locale: "it" | "en" }`
- `setUiMode`
  - body: `{ uiMode: "nui" | "ox" | "both" }` (se consentito da config)
- `close`

## 5. Sicurezza & Robustezza
- Nessun dato sensibile in NUI; evitare logging eccessivo lato client
- Validazione input callback (whitelist profili e timecycle consentiti)
- Protezione da spam: cooldown minimo su apply/reset (client-side)
- Gestione focus: `SetNuiFocus(true/false, true/false)` e chiusura su ESC

## 6. Configurazione (proposta)
- `Config.UiMode`: `"nui" | "ox" | "both"`
- `Config.Locale`: `"it" | "en" | "auto"`
- `Config.SaveProfileKvp`: `true/false`
- `Config.CommandName`: default `"fps"`
- `Config.EnableKeybind`: `true/false`
- `Config.Keybind`: default `"F7"` (se abilitato)
- `Config.NuiTheme`: `"luxury_dark"` (espandibile)

