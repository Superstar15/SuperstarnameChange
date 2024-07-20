ESX = exports["es_extended"]:getSharedObject()

local function sendToDiscord(name, message)
    if not LogConfig.Webhook.enable then
        return
    end

    local connect = {
        {
            ["color"] = LogConfig.Webhook.color,
            ["description"] = message,
            ["author"] = {
                ["name"] = LogConfig.Webhook.botname,
                ["icon_url"] = LogConfig.Webhook.botimage
            },
            ["footer"] = {
                ["icon_url"] = LogConfig.Webhook.botimage,
                ["text"] = "Superstar | " .. os.date("%Y-%m-%d %H:%M:%S")
            },
        }
    }

    PerformHttpRequest(LogConfig.Webhook.url, function(err, text, headers)
    end, 'POST', json.encode({
        username = LogConfig.Webhook.botname,
        avatar_url = LogConfig.Webhook.botimage,
        embeds = connect
    }), { ['Content-Type'] = 'application/json' })
end

local function logNameChange(identifier, oldFirstName, oldLastName, newFirstName, newLastName, steamName)
    local message = string.format("**Name Change**\n\n**ID:** %s\n**Steam Name:** %s\n**License:** %s\n**Old Name:** %s %s\n**New Name:** %s %s",
        identifier, steamName, identifier, oldFirstName, oldLastName, newFirstName, newLastName)
    sendToDiscord(LogConfig.Webhook.botname, message)
end

ESX.RegisterServerCallback('namechanger:updateName', function(source, cb, firstname, lastname, locationIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    local location = Config.Namechangelocation[tostring(locationIndex)]
    local price = location.price
    local money = (Config.Money == 'bank') and xPlayer.getAccount('bank').money or xPlayer.getMoney()
    local identifier = xPlayer.getIdentifier()
    local steamName = GetPlayerName(source)

    if money >= price then
        if Config.Money == 'bank' then
            xPlayer.removeAccountMoney('bank', price)
        else
            xPlayer.removeMoney(price)
        end

        MySQL.query('SELECT firstname, lastname FROM users WHERE identifier = ?', {identifier}, function(result)
            if result[1] then
                local oldFirstName = result[1].firstname
                local oldLastName = result[1].lastname

                MySQL.update('UPDATE users SET firstname = ?, lastname = ? WHERE identifier = ?', {
                    firstname, lastname, identifier
                }, function(affectedRows)
                    if affectedRows > 0 then
                        logNameChange(identifier, oldFirstName, oldLastName, firstname, lastname, steamName)
                        cb(true)
                    else
                        cb(false)
                    end
                end)
            else
                cb(false)
            end
        end)
    else
        cb(false)
    end
end)