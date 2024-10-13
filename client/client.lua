local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local FeatherMenu =  exports['feather-menu'].initiate()

local CreatedBlips4 = {}
local CreatedNpcs4 = {}
local LotteryMenuOpen = false

Citizen.CreateThread(function()
local LotteryMenuPrompt = BccUtils.Prompts:SetupPromptGroup()
    local lotteryprompt = LotteryMenuPrompt:RegisterPrompt(Config.PromptName, 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})
    if Config.LotteryBlips then
        for h,v in pairs(Config.LotteryStations) do
        local lotteryblip = BccUtils.Blips:SetBlip(Config.BoardblipName, 'blip_shop_train', 0.2, v.coords.x,v.coords.y,v.coords.z)
        CreatedBlips4[#CreatedBlips4 + 1] = lotteryblip
        end
    end
    if Config.CreateNPC then
        for h,v in pairs(Config.LotteryStations) do
        local lotteryped = BccUtils.Ped:Create('u_f_m_tumgeneralstoreowner_01', v.coords.x, v.coords.y, v.coords.z -1, 0, 'world', false)
        CreatedNpcs4[#CreatedNpcs4 + 1] = lotteryped
        lotteryped:Freeze()
        lotteryped:SetHeading(v.NpcHeading)
        lotteryped:Invincible()
        SetBlockingOfNonTemporaryEvents(lotteryped:GetPed(), true)
        end
    end
    while true do
        Wait(1)
        for h,v in pairs(Config.LotteryStations) do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - v.coords)
        if dist < 2 then
            LotteryMenuPrompt:ShowGroup(Config.PromptName)
            if Config.Show3dText then
            BccUtils.Misc.DrawText3D(v.coords.x, v.coords.y, v.coords.z, Config.TextLabel3D)
            end
            if lotteryprompt:HasCompleted() then
                TriggerEvent('mms-lottery:client:openlottery')
            end
        end
    end
    end
end)

RegisterNetEvent('mms-lottery:client:openlottery')
AddEventHandler('mms-lottery:client:openlottery',function()
    LotteryMenu:Open({
        startupPage = LotteryMenuPage1,
    })
end)


Citizen.CreateThread(function ()
    LotteryMenu = FeatherMenu:RegisterMenu('lotterymenu', {
        top = '20%',
        left = '20%',
        ['720width'] = '500px',
        ['1080width'] = '700px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '8000px',
        style = {
            ['border'] = '5px solid orange',
            -- ['background-image'] = 'none',
            ['background-color'] = '#FF8C00'
        },
        contentslot = {
            style = {
                ['height'] = '550px',
                ['min-height'] = '250px'
            }
        },
        draggable = true,
    --canclose = false
}, {
    opened = function()
        --print("MENU OPENED!")
    end,
    closed = function()
        --print("MENU CLOSED!")
    end,
    topage = function(data)
        --print("PAGE CHANGED ", data.pageid)
    end
})
    LotteryMenuPage1 = LotteryMenu:RegisterPage('seite1')
    LotteryMenuPage1:RegisterElement('header', {
        value = Config.LotteryHeader,
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    LotteryMenuPage1:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    TextDisplay = LotteryMenuPage1:RegisterElement('textdisplay', {
        value = Config.NextWinnerPick,
        style = {}
    })
    TextDisplay2 = LotteryMenuPage1:RegisterElement('textdisplay', {
        value = Config.JackpotAmount .. ' 0$',
        style = {}
    })
    LotteryMenuPage1:RegisterElement('button', {
        label = Config.LabelBuyTicket .. Config.TicketPrice .. '$',
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-lottery:client:buyticket')
    end)
    LotteryMenuPage1:RegisterElement('button', {
        label = Config.LabelGetWinnings,
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-lottery:client:getwinnings')
    end)
    LotteryMenuPage1:RegisterElement('button', {
        label =  Config.CloseLotterieMenu,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        LotteryMenu:Close({ 
        })
    end)
    LotteryMenuPage1:RegisterElement('subheader', {
        value = Config.LotteryHeader,
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    LotteryMenuPage1:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    
end)

RegisterNetEvent('mms-lottery:client:getwinnings',function ()
    TriggerServerEvent('mms-lottery:server:getwinnings')
end)

RegisterNetEvent('mms-lottery:client:updatejackpot',function(jackpotmoney)
    if LotteryMenuOpen == true then
        TextDisplay2:update({
            value = Config.JackpotAmount .. jackpotmoney .. '$',
            style = {}
        })
    end
end)

RegisterNetEvent('mms-lottery:client:updatetimer',function(timeleft)
    if LotteryMenuOpen == true then
        local round = math.round(timeleft)
        TextDisplay:update({
            value = Config.NextWinnerPick .. round .. Config.MinuteLabel,
            style = {}
        })
    end
end)

RegisterNetEvent('FeatherMenu:opened', function(menudata)
    if menudata.menuid == 'lotterymenu' then
        LotteryMenuOpen = true
    end
end)

RegisterNetEvent('FeatherMenu:closed', function(menudata)
    if menudata.menuid == 'lotterymenu' then
        LotteryMenuOpen = false
    end
end)

---------------Buy Ticket Part
RegisterNetEvent('mms-lottery:client:buyticket')
AddEventHandler('mms-lottery:client:buyticket',function()
    local Money =  VORPcore.Callback.TriggerAwait('mms-banking:callback:getplayermoney')
    Citizen.Wait(250)
    if Money >= Config.TicketPrice then
        TriggerServerEvent('mms-lottery:server:buyticket')
    else
        VORPcore.NotifyTip(Config.NotEnoghMoney, 5000)
    end
end)




---- CleanUp on Resource Restart 

RegisterNetEvent('onResourceStop',function(resource)
    if resource == GetCurrentResourceName() then
    for _, npcs in ipairs(CreatedNpcs4) do
        npcs:Remove()
	end
    for _, blips in ipairs(CreatedBlips4) do
        blips:Remove()
	end
end
end)