const state = {
  resourceName: null,
  open: false,
  activeProfile: null,
  boostActive: false,
  locale: "it",
  config: {
    uiMode: "nui",
    commandName: "fps",
    saveProfileKvp: true
  },
  selectedProfile: null,
  timecycles: [
    { id: "yell_tunnel_nodirect", label: { it: "Tunnel (FPS)", en: "Tunnel (FPS)" } },
    { id: "cinema", label: { it: "Cinema (FPS)", en: "Cinema (FPS)" } },
    { id: "LifeInvaderLOD", label: { it: "Life (FPS)", en: "Life (FPS)" } },
    { id: "ReduceDrawDistanceMission", label: { it: "Reduce Distance (FPS)", en: "Reduce Distance (FPS)" } },
    { id: "MP_Powerplay_blend", label: { it: "PowerPlay Blend (Grafica)", en: "PowerPlay Blend (Graphics)" } },
    { id: "tunnel", label: { it: "Tunnel + Reflection", en: "Tunnel + Reflection" }, extra: { extra: "reflection_correct_ambient" } }
  ]
}

const STRINGS = {
  it: {
    tabPerformance: "Prestazioni",
    tabTimecycle: "Timecycle",
    tabGraphics: "Grafica",
    tabSettings: "Impostazioni",
    profile: "Profilo",
    boost: "Boost",
    on: "ON",
    off: "OFF",
    profilesTitle: "Profili",
    profilesHint: "Seleziona e applica al volo",
    ultraLowDesc: "Massimo FPS",
    mediumDesc: "Bilanciato",
    highDesc: "Minimo impatto",
    apply: "Applica",
    reset: "Reset",
    quickTitle: "Azioni rapide",
    quickHint: "Qualità e reset",
    ultraGraphicsTitle: "Ultra Graphics",
    ultraGraphicsDesc: "Ripristina la qualità al massimo",
    tipTitle: "Tip",
    tipText: "ESC chiude il menu. Puoi continuare a muoverti dopo la chiusura.",
    tcTitle: "Timecycle",
    tcHint: "Filtra e applica preset",
    search: "Cerca...",
    tcApply: "Applica",
    gfxTitle: "Grafica",
    gfxHint: "Preset qualità",
    gfxUltraDesc: "Texture, luci e profondità più spinte",
    gfxResetDesc: "Torna ai valori base del menu",
    settingsLangTitle: "Lingua",
    settingsLangHint: "IT / EN",
    cfgTitle: "Configurazione",
    cfgHint: "Valori attivi da config.lua",
    ui: "UI",
    command: "Command",
    persist: "Persistenza",
    yes: "Sì",
    no: "No"
  },
  en: {
    tabPerformance: "Performance",
    tabTimecycle: "Timecycle",
    tabGraphics: "Graphics",
    tabSettings: "Settings",
    profile: "Profile",
    boost: "Boost",
    on: "ON",
    off: "OFF",
    profilesTitle: "Profiles",
    profilesHint: "Select and apply instantly",
    ultraLowDesc: "Max FPS",
    mediumDesc: "Balanced",
    highDesc: "Low impact",
    apply: "Apply",
    reset: "Reset",
    quickTitle: "Quick actions",
    quickHint: "Quality and reset",
    ultraGraphicsTitle: "Ultra Graphics",
    ultraGraphicsDesc: "Restore max visual quality",
    tipTitle: "Tip",
    tipText: "ESC closes the menu. You can keep playing after closing.",
    tcTitle: "Timecycle",
    tcHint: "Filter and apply presets",
    search: "Search...",
    tcApply: "Apply",
    gfxTitle: "Graphics",
    gfxHint: "Quality presets",
    gfxUltraDesc: "More aggressive textures, lights, depth",
    gfxResetDesc: "Return to base menu values",
    settingsLangTitle: "Language",
    settingsLangHint: "IT / EN",
    cfgTitle: "Configuration",
    cfgHint: "Active values from config.lua",
    ui: "UI",
    command: "Command",
    persist: "Persistence",
    yes: "Yes",
    no: "No"
  }
}

const el = {
  app: document.getElementById("app"),
  closeBtn: document.getElementById("closeBtn"),
  tabs: Array.from(document.querySelectorAll(".tab")),
  panels: Array.from(document.querySelectorAll(".panel")),
  tabIndicator: document.querySelector(".tabIndicator"),
  profileBtns: Array.from(document.querySelectorAll(".profileBtn")),
  applySelectedBtn: document.getElementById("applySelectedBtn"),
  resetBtn: document.getElementById("resetBtn"),
  ultraGraphicsBtn: document.getElementById("ultraGraphicsBtn"),
  gfxUltraBtn: document.getElementById("gfxUltraBtn"),
  gfxResetBtn: document.getElementById("gfxResetBtn"),
  tcSearch: document.getElementById("tcSearch"),
  tcResetBtn: document.getElementById("tcResetBtn"),
  tcList: document.getElementById("tcList"),
  activeProfileLabel: document.getElementById("activeProfileLabel"),
  activeProfileValue: document.getElementById("activeProfileValue"),
  boostLabel: document.getElementById("boostLabel"),
  boostValue: document.getElementById("boostValue"),
  boostPill: document.getElementById("boostPill"),
  segBtns: Array.from(document.querySelectorAll(".segBtn")),
  kvUiModeValue: document.getElementById("kvUiModeValue"),
  kvCommandValue: document.getElementById("kvCommandValue"),
  kvPersistValue: document.getElementById("kvPersistValue")
}

function t(key) {
  const lang = STRINGS[state.locale] ? state.locale : "en"
  return STRINGS[lang][key] ?? key
}

function postNui(name, data = {}) {
  const resource = state.resourceName || "nui-resource"
  return fetch(`https://${resource}/${name}`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(data)
  }).catch(() => {})
}

function setOpen(open) {
  state.open = open
  if (open) {
    el.app.classList.remove("is-hidden")
    el.app.setAttribute("aria-hidden", "false")
    requestAnimationFrame(() => updateTabIndicator())
  } else {
    el.app.classList.add("is-hidden")
    el.app.setAttribute("aria-hidden", "true")
    state.selectedProfile = null
    el.profileBtns.forEach((b) => b.classList.remove("is-selected"))
    el.applySelectedBtn.disabled = true
  }
}

function applyTranslations() {
  const ids = [
    ["tabPerformance", "tabPerformance"],
    ["tabTimecycle", "tabTimecycle"],
    ["tabGraphics", "tabGraphics"],
    ["tabSettings", "tabSettings"],
    ["activeProfileLabel", "profile"],
    ["boostLabel", "boost"],
    ["perfTitle", "profilesTitle"],
    ["perfHint", "profilesHint"],
    ["descUltraLow", "ultraLowDesc"],
    ["descMedium", "mediumDesc"],
    ["descHigh", "highDesc"],
    ["applyLabel", "apply"],
    ["resetLabel", "reset"],
    ["quickTitle", "quickTitle"],
    ["quickHint", "quickHint"],
    ["ultraGraphicsTitle", "ultraGraphicsTitle"],
    ["ultraGraphicsDesc", "ultraGraphicsDesc"],
    ["noteTitle", "tipTitle"],
    ["noteText", "tipText"],
    ["tcTitle", "tcTitle"],
    ["tcHint", "tcHint"],
    ["tcResetLabel", "reset"],
    ["gfxTitle", "gfxTitle"],
    ["gfxHint", "gfxHint"],
    ["gfxUltraTitle", "ultraGraphicsTitle"],
    ["gfxUltraDesc", "gfxUltraDesc"],
    ["gfxResetTitle", "reset"],
    ["gfxResetDesc", "gfxResetDesc"],
    ["langTitle", "settingsLangTitle"],
    ["langHint", "settingsLangHint"],
    ["cfgTitle", "cfgTitle"],
    ["cfgHint", "cfgHint"],
    ["kvUiMode", "ui"],
    ["kvCommand", "command"],
    ["kvPersist", "persist"]
  ]

  ids.forEach(([id, key]) => {
    const node = document.getElementById(id)
    if (!node) return
    node.textContent = t(key)
  })

  el.tcSearch.placeholder = t("search")
  updateBoostPill()
  renderTimecycleList()
  renderConfigSummary()
}

function updateBoostPill() {
  el.boostValue.textContent = state.boostActive ? t("on") : t("off")
  if (state.boostActive) {
    el.boostPill.classList.add("pillAccent")
  } else {
    el.boostPill.classList.remove("pillAccent")
  }
}

function renderConfigSummary() {
  el.kvUiModeValue.textContent = state.config.uiMode ?? "—"
  el.kvCommandValue.textContent = `/${state.config.commandName ?? "fps"}`
  el.kvPersistValue.textContent = state.config.saveProfileKvp ? t("yes") : t("no")
}

function setActiveTab(tabId) {
  el.tabs.forEach((btn) => {
    const active = btn.dataset.tab === tabId
    btn.classList.toggle("is-active", active)
    btn.setAttribute("aria-selected", active ? "true" : "false")
  })
  el.panels.forEach((p) => p.classList.toggle("is-active", p.dataset.panel === tabId))
  updateTabIndicator()
}

function updateTabIndicator() {
  const activeTab = el.tabs.find((t) => t.classList.contains("is-active"))
  if (!activeTab) return
  const railLeft = 16
  const rect = activeTab.getBoundingClientRect()
  const shellRect = document.querySelector(".shell").getBoundingClientRect()
  const x = rect.left - shellRect.left + railLeft
  el.tabIndicator.style.width = `${rect.width}px`
  el.tabIndicator.style.transform = `translateX(${x - railLeft}px)`
}

function renderTimecycleList() {
  const q = (el.tcSearch.value || "").trim().toLowerCase()
  const lang = state.locale in STRINGS ? state.locale : "en"

  const items = state.timecycles
    .map((tc) => ({
      ...tc,
      title: tc.label?.[lang] ?? tc.id,
      key: `${tc.id} ${(tc.label?.it ?? "")} ${(tc.label?.en ?? "")}`.toLowerCase()
    }))
    .filter((tc) => (q ? tc.key.includes(q) : true))

  el.tcList.innerHTML = ""
  items.forEach((tc) => {
    const row = document.createElement("div")
    row.className = "listItem"
    row.setAttribute("role", "listitem")

    const left = document.createElement("div")
    const title = document.createElement("div")
    title.className = "listItemTitle"
    title.textContent = tc.title
    const meta = document.createElement("div")
    meta.className = "listItemMeta"
    meta.textContent = tc.id
    left.appendChild(title)
    left.appendChild(meta)

    const btn = document.createElement("button")
    btn.className = "listItemBtn"
    btn.type = "button"
    btn.textContent = t("tcApply")
    btn.addEventListener("click", () => {
      postNui("applyTimecycle", { name: tc.id, strength: 0.5, extra: tc.extra ?? null })
    })

    row.appendChild(left)
    row.appendChild(btn)
    el.tcList.appendChild(row)
  })
}

function setLocale(locale) {
  state.locale = locale === "it" ? "it" : "en"
  el.segBtns.forEach((b) => b.classList.toggle("is-active", b.dataset.locale === state.locale))
  applyTranslations()
}

function setStateFromClient(payload) {
  if (!payload) return
  state.resourceName = payload.resourceName ?? state.resourceName
  state.activeProfile = payload.activeProfile ?? null
  state.boostActive = Boolean(payload.boostActive)
  state.locale = payload.locale === "it" ? "it" : "en"
  state.config = {
    uiMode: payload.config?.uiMode ?? state.config.uiMode,
    commandName: payload.config?.commandName ?? state.config.commandName,
    saveProfileKvp: Boolean(payload.config?.saveProfileKvp ?? state.config.saveProfileKvp)
  }

  el.activeProfileValue.textContent = state.activeProfile ?? "—"
  updateBoostPill()
  setLocale(state.locale)
}

function wireEvents() {
  window.addEventListener("message", (event) => {
    const msg = event.data
    if (!msg || typeof msg !== "object") return
    if (msg.type === "fpsboost:open") {
      setStateFromClient(msg.payload)
      setOpen(true)
      setActiveTab("performance")
      return
    }
    if (msg.type === "fpsboost:close") {
      setOpen(false)
      return
    }
    if (msg.type === "fpsboost:state") {
      setStateFromClient(msg.payload)
    }
  })

  document.addEventListener("keydown", (e) => {
    if (!state.open) return
    if (e.key === "Escape") {
      postNui("close")
      setOpen(false)
    }
  })

  el.closeBtn.addEventListener("click", () => {
    postNui("close")
    setOpen(false)
  })

  el.tabs.forEach((btn) => {
    btn.addEventListener("click", () => setActiveTab(btn.dataset.tab))
  })

  el.profileBtns.forEach((btn) => {
    btn.addEventListener("click", () => {
      state.selectedProfile = btn.dataset.profile
      el.profileBtns.forEach((b) => b.classList.toggle("is-selected", b === btn))
      el.applySelectedBtn.disabled = false
    })
  })

  el.applySelectedBtn.addEventListener("click", () => {
    if (!state.selectedProfile) return
    postNui("applyProfile", { profile: state.selectedProfile })
  })

  el.resetBtn.addEventListener("click", () => postNui("resetAll"))
  el.ultraGraphicsBtn.addEventListener("click", () => postNui("applyProfile", { profile: "ultra_graphics" }))
  el.gfxUltraBtn.addEventListener("click", () => postNui("applyProfile", { profile: "ultra_graphics" }))
  el.gfxResetBtn.addEventListener("click", () => postNui("resetAll"))

  el.tcSearch.addEventListener("input", () => renderTimecycleList())
  el.tcResetBtn.addEventListener("click", () => postNui("resetTimecycle"))

  el.segBtns.forEach((b) => {
    b.addEventListener("click", () => {
      const locale = b.dataset.locale
      setLocale(locale)
      postNui("setLocale", { locale: state.locale })
    })
  })
}

wireEvents()
applyTranslations()
renderTimecycleList()
setActiveTab("performance")
setOpen(false)

