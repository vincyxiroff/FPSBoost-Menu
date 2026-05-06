## 1. Panoramica Prodotto
Interfaccia NUI “premium” in-game per controllare l’FPS Boost Menu con un’esperienza più moderna rispetto al menu contestuale.
- Obiettivo: rendere l’uso rapido, leggibile e configurabile (NUI/ox_lib/entrambi) via config.lua
- Utenti: player FiveM che vogliono cambiare profilo performance/graphics e timecycle al volo

## 2. Funzionalità Core

### 2.1 Moduli Funzionali
1. **Overlay NUI (pagina unica)**: pannello principale con tabs e controlli
2. **Integrazione client.lua**: apertura/chiusura UI, invio stato, applicazione profili e reset
3. **Configurazione**: opzioni in config.lua per abilitazioni, lingua, persistenza e comportamento UI

### 2.2 Dettaglio Pagina
| Pagina | Modulo | Descrizione |
|--------|--------|-------------|
| Overlay NUI | Header + stato | Mostra profilo attivo, stato “Boost ON/OFF”, indicatori (timecycle/graphics) |
| Overlay NUI | Tab “Prestazioni” | Selezione profilo (Ultra Low/Medium/High), toggle culling, slider distanze/alpha (se abilitati), applica/reset |
| Overlay NUI | Tab “Timecycle” | Lista timecycle (preset), ricerca rapida, applica e reset timecycle |
| Overlay NUI | Tab “Grafica” | Pulsanti “Ultra Graphics” e “Reset”, eventuali toggle (es. LOD) se esposti dal client |
| Overlay NUI | Tab “Impostazioni” | Lingua IT/EN, persistenza profilo, toggle uso NUI/ox_lib, keybind/command info |

## 3. Processo Principale
Flusso utente tipico:
- Apre il menu (/fps o keybind se configurato)
- Seleziona un profilo prestazioni e lo applica
- Opzionalmente cambia timecycle o passa a Ultra Graphics
- Chiude il menu; se persistenza attiva, al prossimo join ripristina l’ultimo profilo

```mermaid
flowchart TD
  A["Player apre menu"] --> B{"Modalità UI?"}
  B -->| "NUI" | C["Apre overlay NUI"]
  B -->| "ox_lib" | D["Apre menu ox_lib"]
  B -->| "Entrambi" | E["Scelta UI / fallback"]
  C --> F["Player seleziona profilo / timecycle / reset"]
  D --> F
  E --> F
  F --> G["client.lua applica modifiche native + culling"]
  G --> H{"Persistenza attiva?"}
  H -->| "Sì" | I["Salva profilo (KVP)"]
  H -->| "No" | J["Nessun salvataggio"]
  I --> K["Chiude menu"]
  J --> K
```

## 4. Design Interfaccia Utente

### 4.1 Stile Visivo (Premium)
- Tema: dark “luxury” con effetto vetro (blur) e accenti metallici/teal
- Tipografia: display font caratteristico per titoli + font leggibile per body
- Componenti: pulsanti con stati (hover/active), slider con feedback numerico, toggle curati
- Motion: entrata pannello con easing morbido, micro-interazioni su hover e selezione

### 4.2 Linee Guida UI
| Modulo | Elementi UI |
|--------|-------------|
| Header | Titolo, badge profilo attivo, pill stato |
| Tabs | Tabbar con indicator animato |
| Profilo | Card selezionabili (Ultra Low/Medium/High/Graphics/Reset) + descrizioni |
| Controlli avanzati | Slider distanze, slider alpha, toggle “Aggressivo” (se abilitato) |
| Timecycle | Lista filtrabile + pulsanti “Applica” e “Reset” |
| Footer | Hint tasti (ESC per chiudere), versione risorsa |

### 4.3 Responsività
- Desktop-first (FiveM overlay), layout adattivo a diverse risoluzioni (16:9/21:9)
- Focus states e navigazione tastiera di base (esc chiude, tab naviga elementi principali)

