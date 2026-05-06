local function getCurrentVersion()
    local manifest = LoadResourceFile(GetCurrentResourceName(), 'fxmanifest.lua')
    if type(manifest) ~= 'string' then
        return nil
    end

    return manifest:match('version%s+["\'](.-)["\']')
end

local function getRemoteVersion(body)
    if type(body) ~= 'string' then
        return nil
    end
    return body:match('version%s+["\'](.-)["\']')
end

local function printOutdated(currentVersion, remoteVersion, url)
    print([[

 ███████╗██████╗ ███████╗██████╗  ██████╗  ██████╗ ███████╗████████╗
 ██╔════╝██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔═══██╗██╔════╝╚══██╔══╝
 █████╗  ██████╔╝███████╗██████╔╝██║   ██║██║   ██║███████╗   ██║   
 ██╔══╝  ██╔═══╝ ╚════██║██╔══██╗██║   ██║██║   ██║╚════██║   ██║   
 ██║     ██║     ███████║██████╔╝╚██████╔╝╚██████╔╝███████║   ██║   
 ╚═╝     ╚═╝     ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝   ╚═╝   

]])

    print(('Update disponibile per %s'):format(GetCurrentResourceName()))
    print(('Versione attuale: %s'):format(currentVersion or 'unknown'))
    print(('Ultima versione:  %s'):format(remoteVersion or 'unknown'))
    print(('URL check: %s'):format(url or 'n/a'))
    print('Consiglio: aggiorna il resource da GitHub (pull main / scarica release) per evitare bug e ottenere le nuove feature.')
    print('')
end

CreateThread(function()
    if not Config or not Config.VersionCheck or not Config.VersionCheck.enabled then
        return
    end

    local url = Config.VersionCheck.url
    if type(url) ~= 'string' or url == '' then
        return
    end

    local current = getCurrentVersion()
    if current == nil or current == '' then
        return
    end

    PerformHttpRequest(url, function(status, body)
        if status ~= 200 then
            return
        end

        local remote = getRemoteVersion(body)
        if remote == nil or remote == '' then
            return
        end

        if remote ~= current then
            printOutdated(current, remote, url)
        end
    end, 'GET')
end)

