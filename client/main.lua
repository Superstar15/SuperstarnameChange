local isNear = false
ESX = exports["es_extended"]:getSharedObject()

CreateThread(function()
    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for index, loc in pairs(Config.Namechangelocation) do
            local coords = loc[1]
            if #(playerCoords - coords) < 2.0 then
                if not isNear then
                    isNear = true
                    if Config.Oxtarget then
                        exports.ox_target:addSphereZone({
                            coords = coords,
                            radius = 2.0,
                            options = {
                                {
                                    label = Config.Language.Oxtargetlabel,
                                    icon = 'fas fa-edit',
                                    onSelect = function()
                                        openNameChangeMenu(index)
                                    end
                                }
                            }
                        })
                    else
                        lib.showTextUI(Config.Language.Showtextuilabel, { position = 'right-center', icon = 'fas fa-edit' })
                    end
                end
                if not Config.Oxtarget and IsControlJustReleased(0, 38) then
                    openNameChangeMenu(index)
                end
            else
                if isNear then
                    isNear = false
                    if Config.Oxtarget then
                        exports.ox_target:removeSphereZone(coords)
                    else
                        lib.hideTextUI()
                    end
                end
            end
        end
    end
end)

function openNameChangeMenu(locationIndex)
    local input = lib.inputDialog(Config.Language.namechangetitle, {
        { type = 'input', label = Config.Language.firstname, placeholder = Config.Language.firstnameplaceholder, required = true },
        { type = 'input', label = Config.Language.lastname, placeholder = Config.Language.lastnameplaceholder, required = true }
    })
    
    if input then
        local lastname = input[1]
        local firstname = input[2]

        ESX.TriggerServerCallback('namechanger:updateName', function(success)
            if success then
                notifyUser(Config.Language.namechangesuccess, 'success')
            else
                notifyUser(Config.Language.namechangeerror, 'error')
            end
        end, firstname, lastname, tostring(locationIndex))
    end
end

function notifyUser(message, type)
    if Config.Notify == 'ox' then
        lib.notify({ title = 'Notification', description = message, type = type })
    else
        ESX.ShowNotification(message, type)
    end
end