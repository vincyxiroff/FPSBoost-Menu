Config = {}

Config.FeatureExperimental = false -- If you set this to True, you will enable experimental features

Config.fpstimecycle_test = false

Config.clearpedandobj = true

Config.UiMode = 'nui'

Config.Locale = 'auto'

Config.CommandName = 'fps'

Config.EnableKeybind = false

Config.Keybind = 'F7'

Config.SaveProfileKvp = true

Config.ProfileKvpKey = 'fpsboost:profile'

Config.NuiTheme = 'luxury_dark'

Config.Culling = {
    enabled = true,
    aggressive = true,
    objects = { alpha = 210, distance = 90 },
    peds = { alpha = 245, distance = 60, aoBlob = false },
    vehicles = { alpha = 255, distance = 120 }
}

Config.CullingProfiles = {
    ultra_low = {
        objects = { alpha = 210, distance = 90 },
        peds = { alpha = 245, distance = 60, aoBlob = false },
        vehicles = { alpha = 255, distance = 120 }
    },
    medium = {
        objects = { alpha = 210, distance = 130 },
        peds = { alpha = 250, distance = 100, aoBlob = false },
        vehicles = { alpha = 255, distance = 160 }
    },
    high = {
        objects = { alpha = 245, distance = 200 },
        peds = { alpha = 255, distance = 150, aoBlob = true },
        vehicles = { alpha = 255, distance = 250 }
    }
}

Config.CullingBatch = {
    enabled = true,
    maxPerTick = 120,
    tickWaitMs = 0
}
