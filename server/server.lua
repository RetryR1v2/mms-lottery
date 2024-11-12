-----------------------------------------------------------------------
-- version checker
-----------------------------------------------------------------------
local function versionCheckPrint(_type, log)
    local color = _type == 'success' and '^2' or '^1'

    print(('^5['..GetCurrentResourceName()..']%s %s^7'):format(color, log))
end

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/RetryR1v2/mms-lottery/main/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

        if not text then 
            versionCheckPrint('error', 'Currently unable to run a version check.')
            return 
        end

      
        if text == currentVersion then
            versionCheckPrint('success', 'You are running the latest version.')
        else
            versionCheckPrint('error', ('Current Version: %s'):format(currentVersion))
            versionCheckPrint('success', ('Latest Version: %s'):format(text))
            versionCheckPrint('error', ('You are currently running an outdated version, please update to version %s'):format(text))
        end
    end)
end

local VORPcore = exports.vorp_core:GetCore()

local jackpot = 'pricemoney'

local counter = nil
local timeleft = 0


----------------------------------------------------------------------------------------------------
-------------------------------------Pick Winner Part-----------------------------------------------
----------------------------------------------------------------------------------------------------

Citizen.CreateThread(function ()

    local Timer = MySQL.query.await("SELECT * FROM mms_lotterytimer", { })
        if #Timer > 0 then
            counter = Timer[1].timer
        else
            counter = Config.WinnerPickTime * 60
            MySQL.insert('INSERT INTO `mms_lotterytimer` (timer) VALUES (?)',
            {counter}, function()end)
        end
        Citizen.Wait(500)

    while counter > 0 do
        Citizen.Wait(2000)
        counter = counter - 2
        timeleft = counter / 60
        local OldTimer = MySQL.query.await("SELECT * FROM mms_lotterytimer", { })
        if #OldTimer > 0 then
            local oldcounter = OldTimer[1].timer
            local newcounter = OldTimer[1].timer -2
            MySQL.update('UPDATE `mms_lotterytimer` SET timer = ? WHERE timer = ?',{newcounter, oldcounter})
        end
        for _, player in ipairs(GetPlayers()) do
            TriggerClientEvent('mms-lottery:client:updatetimer',player,timeleft)
        end
        if counter <= 0 then
            TriggerEvent('mms-lottery:server:pickwinner')
            counter = Config.WinnerPickTime * 60
            local OldTimer = MySQL.query.await("SELECT * FROM mms_lotterytimer", { })
            if #OldTimer > 0 then
                local oldcounter = OldTimer[1].timer
                local newcounter = counter
                MySQL.update('UPDATE `mms_lotterytimer` SET timer = ? WHERE timer = ?',{newcounter, oldcounter})
            end
            timeleft = 0
            Citizen.Wait(500)
        end
    end
end)

RegisterServerEvent('mms-lottery:server:pickwinner',function ()
    exports.oxmysql:execute('SELECT * FROM mms_lotteryticket', {}, function(result)
        if result and #result > 0 then
            local winner = {}

            for _, v in ipairs(result) do
                table.insert(winner, v.id)
            end
            local randondomwinner = math.random(1,#winner)
            winnerticketid = winner[randondomwinner]
            print(winnerticketid)
            TriggerEvent('mms-lottery:server:winner',winnerticketid)
        else
            if Config.AnnonceIfNoWinner == true then
                for _, player in ipairs(GetPlayers()) do
                    VORPcore.NotifyTip(player, Config.NoTicketsBought, 10000)  
                end
                if Config.EnableWebHook == true then
                    VORPcore.AddWebhook(Config.WHTitleNoWinner, Config.WHLink, Config.NoTicketsBought, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
                end
            else 
                if Config.EnableWebHook == true then
                    VORPcore.AddWebhook(Config.WHTitleNoWinner, Config.WHLink, Config.NoTicketsBought, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
                end
            end
        end
    end)
end)

VORPcore.Callback.Register('mms-banking:callback:getplayermoney', function(source,cb)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local Money = Character.money
    cb(Money)
end)

RegisterServerEvent('mms-lottery:server:winner',function(winnerticketid)
    exports.oxmysql:execute('SELECT * FROM mms_lotteryticket WHERE id = ?', {winnerticketid}, function(result)
        winnerfirstname = result[1].firstname
        winnerlastname = result[1].lastname
        winneridentifier = result[1].identifier
        
    end)
    exports.oxmysql:execute('SELECT * FROM mms_lotteryjackpot', {}, function(result)
        winnerpricemoney = result[1].money
    end)
    Citizen.Wait(2000) -- Wait for execute and Getting data  
    TriggerEvent('mms-lottery:server:insertwinner',winnerfirstname,winneridentifier,winnerlastname,winnerpricemoney)
end)

RegisterServerEvent('mms-lottery:server:insertwinner',function(winnerfirstname,winneridentifier,winnerlastname,winnerpricemoney)
    if Config.EnableWebHook == true then
    VORPcore.AddWebhook(Config.WHTitle, Config.WHLink, Config.TheWinnerIs .. winnerfirstname .. ' ' .. winnerlastname .. ' ' .. Config.HeWins .. winnerpricemoney .. '$', Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
    end
    if Config.AnnonceWinner == true then
        for _, player in ipairs(GetPlayers()) do
            VORPcore.NotifyTip(player, Config.TheWinnerIs .. winnerfirstname .. ' ' .. winnerlastname .. ' ' .. Config.HeWins .. winnerpricemoney .. '$', 10000)  
        end
    else
        for _, player in ipairs(GetPlayers()) do
            VORPcore.NotifyTip(player, Config.LotteryOver, 10000)
        end
    end
    MySQL.insert('INSERT INTO `mms_lotterywinner` (firstname, lastname, identifier, pricemoney) VALUES (?, ?, ?, ?)', 
    {winnerfirstname,winnerlastname,winneridentifier,winnerpricemoney}, function()end)
    TriggerEvent('mms-lottery:server:clear')
end)

RegisterServerEvent('mms-lottery:server:clear',function ()
    MySQL.execute('DELETE FROM mms_lotteryticket', {}, function() end)
    MySQL.execute('DELETE FROM mms_lotteryjackpot', {}, function()end)
end)

----------------------------------------------------------------------------------------------------
-------------------------------------Buy Ticket Part------------------------------------------------
----------------------------------------------------------------------------------------------------


RegisterServerEvent('mms-lottery:server:buyticket',function ()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local Money = Character.money
    local randomwait = math.random(250,500)
    Citizen.Wait(randomwait) -- Just to catch if More Players are Buying Tickets that Server dont get Spammed
    local identifier = Character.charIdentifier
    local firstname = Character.firstname
    local lastname = Character.lastname
    if Money >= Config.TicketPrice then
    if Config.LimitTickets == true then
    MySQL.query('SELECT * FROM `mms_lotteryticket` WHERE identifier = ?', {identifier}, function(result)
        if result[1] ~= nil then
            if result[1].tickets < Config.MaxTickets then
                local newtickets = result[1].tickets + 1 
                MySQL.insert('INSERT INTO `mms_lotteryticket` (firstname, lastname, identifier,tickets) VALUES (?, ?, ?, ?)', {firstname,lastname,identifier,newtickets}, function()end)
                MySQL.update('UPDATE `mms_lotteryticket` SET tickets = ? WHERE identifier = ?',{newtickets, identifier})
                VORPcore.NotifyTip(src, Config.TicketBought, 5000)
                Character.removeCurrency(0, Config.TicketPrice)
                MySQL.query('SELECT `money` FROM `mms_lotteryjackpot` WHERE jackpot = ?', {jackpot}, function(result)
                    if result[1] ~= nil  then
                        local money = result[1].money
                        local newmoney = money + Config.TicketPrice
                        MySQL.update('UPDATE `mms_lotteryjackpot` SET money = ? WHERE jackpot = ?',{newmoney, jackpot})
                    else
                        if Config.UseStartAmount then
                        local firstmoney  = Config.TicketPrice + Config.StartAmount
                        MySQL.insert('INSERT INTO `mms_lotteryjackpot` (jackpot,money) VALUES (?, ?)', {jackpot,firstmoney}, function()end)
                        else
                        MySQL.insert('INSERT INTO `mms_lotteryjackpot` (jackpot,money) VALUES (?, ?)', {jackpot,Config.TicketPrice}, function()end)
                        end
                    end
                end)
            else 
                VORPcore.NotifyTip(src, Config.MaxTicketsBought .. Config.MaxTickets, 5000)
            end
        else
            Character.removeCurrency(0, Config.TicketPrice)
            VORPcore.NotifyTip(src, Config.TicketBought, 5000)
            MySQL.insert('INSERT INTO `mms_lotteryticket` (firstname, lastname, identifier,tickets) VALUES (?, ?, ?, ?)', {firstname,lastname,identifier,1}, function()end)
            MySQL.query('SELECT `money` FROM `mms_lotteryjackpot` WHERE jackpot = ?', {jackpot}, function(result)
                if result[1] ~= nil  then
                    local money = result[1].money
                    local newmoney = money + Config.TicketPrice
                    MySQL.update('UPDATE `mms_lotteryjackpot` SET money = ? WHERE jackpot = ?',{newmoney, jackpot})
                else
                    if Config.UseStartAmount then
                    local firstmoney  = Config.TicketPrice + Config.StartAmount
                    MySQL.insert('INSERT INTO `mms_lotteryjackpot` (jackpot,money) VALUES (?, ?)', {jackpot,firstmoney}, function()end)
                    else
                    MySQL.insert('INSERT INTO `mms_lotteryjackpot` (jackpot,money) VALUES (?, ?)', {jackpot,Config.TicketPrice}, function()end)
                    end
                end
            end)
        end
    end)
    else
        MySQL.insert('INSERT INTO `mms_lotteryticket` (firstname, lastname, identifier) VALUES (?, ?, ?)', {firstname,lastname,identifier}, function()end)
        VORPcore.NotifyTip(src, Config.TicketBought, 5000)
        Character.removeCurrency(0, Config.TicketPrice)
        MySQL.query('SELECT `money` FROM `mms_lotteryjackpot` WHERE jackpot = ?', {jackpot}, function(result)
            if result[1] ~= nil  then
                local money = result[1].money
                local newmoney = money + Config.TicketPrice
                MySQL.update('UPDATE `mms_lotteryjackpot` SET money = ? WHERE jackpot = ?',{newmoney, jackpot})
            else
                if Config.UseStartAmount then
                local firstmoney  = Config.TicketPrice + Config.StartAmount
                MySQL.insert('INSERT INTO `mms_lotteryjackpot` (jackpot,money) VALUES (?, ?)', {jackpot,firstmoney}, function()end)
                else
                MySQL.insert('INSERT INTO `mms_lotteryjackpot` (jackpot,money) VALUES (?, ?)', {jackpot,Config.TicketPrice}, function()end)
                end
            end
        end)
    end
end
end)


----------------------------------------------------------------------------------------------------
----------------------------------------Jackpot Part------------------------------------------------
----------------------------------------------------------------------------------------------------

Citizen.CreateThread(function ()
    while true do
        MySQL.query('SELECT `money` FROM `mms_lotteryjackpot` WHERE jackpot = ?', {jackpot}, function(result)
            if result[1] ~= nil  then
                local jackpotmoney = result[1].money
                for _, player in ipairs(GetPlayers()) do
                    TriggerClientEvent('mms-lottery:client:updatejackpot',player,jackpotmoney)
                end
                Citizen.Wait(2000)
            end
        end)
        Citizen.Wait(2000)
    end
end)

Citizen.CreateThread(function ()
    while true do
        MySQL.query('SELECT `money` FROM `mms_lotteryjackpot` WHERE jackpot = ?', {jackpot}, function(result)
            if result[1] ~= nil  then
                local jackpotmoney = result[1].money
                for _, player in ipairs(GetPlayers()) do
                    TriggerClientEvent('mms-lottery:client:updatejackpot',player,jackpotmoney)
                end
                Citizen.Wait(2000)
            else
                local jackpotmoney = 0
                for _, player in ipairs(GetPlayers()) do
                    TriggerClientEvent('mms-lottery:client:updatejackpot',player,jackpotmoney)
                end
            end
        end)
        Citizen.Wait(2000)
    end
end)

RegisterServerEvent('mms-lottery:server:getwinnings',function ()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.charIdentifier
    MySQL.query('SELECT * FROM `mms_lotterywinner` WHERE identifier = ?', {identifier}, function(result)
        if result[1] ~= nil  then
            local reward = result[1].pricemoney
            Character.addCurrency(0, reward)
            VORPcore.NotifyTip(src, Config.WinningsGetLabel .. reward .. '$', 5000)
            MySQL.execute('DELETE FROM mms_lotterywinner WHERE identifier = ? AND pricemoney = ?', { identifier, reward }, function() end)
        else
            VORPcore.NotifyTip(src, Config.SadNoWin, 5000)
        end
    end)
end)
--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()