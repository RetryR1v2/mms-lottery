Config = {}

-----------------------------------------------------------------------------------
----------------------------------Winner Settings----------------------------------
-----------------------------------------------------------------------------------
Config.EnableWebHook = true
Config.WHTitle = 'Der Gewinner ist'
Config.WHTitleNoWinner = 'Kein Gewinner'
Config.WHLink = ''  -- Discord WH link Here
Config.WHColor = 16711680 -- red
Config.WHName = 'Lottery' -- name
Config.WHLogo = '' -- must be 30x30px
Config.WHFooterLogo = '' -- must be 30x30px
Config.WHAvatar = '' -- must be 30x30px


-----------------------------------------------------------------------------------
----------------------------------Winner Settings----------------------------------
-----------------------------------------------------------------------------------

Config.WinnerPickTime = 60  -- Time in Minutes when lotterie pick a Winner  Only a Winner Will be Picket if Tickets are Bought
Config.AnnonceIfNoWinner = true
Config.AnnonceWinner = true

-----------------------------------------------------------------------------------
----------------------------------Ticket Settings----------------------------------
-----------------------------------------------------------------------------------

Config.LimitTickets = true -- Limit the Tickets a Player Can Buy make sense to equal the chances of win
Config.MaxTickets = 3 -- if a player has more money to buy more tickets he has a higher, 
-- chance to win as someone who cant afford more tickets Limit tickets will make it Fair.

-----------------------------------------------------------------------------------
---------------------------------Lottery Settings----------------------------------
-----------------------------------------------------------------------------------

Config.LotteryBlips = true
Config.CreateNPC = true
Config.Show3dText = true
Config.TextLabel3D = 'Lotterie'
Config.LotteryStations = {

    {
        coords = vector3(-808.3, -1292.35, 43.66),   --- Also the Location of Blip and Npc (Blackwater)
        NpcHeading = 269.78,
    },  
    {
        coords = vector3(-291.42, 784.18, 119.29),   --- Also the Location of Blip and Npc (Valentine)
        NpcHeading = 26.07,
    },
    {
        coords = vector3(1311.66, -1312.31, 76.79),   --- Also the Location of Blip and Npc (Rhodes)
        NpcHeading = 327.44,
    },
    {
        coords = vector3(2531.12, -1202.2, 53.68),   --- Also the Location of Blip and Npc (SaintDenise)
        NpcHeading = 272.05,
    },

}

-----------------------------------------------------------------------------------
----------------------------------Jackpot Settings---------------------------------
-----------------------------------------------------------------------------------

Config.UseStartAmount = true   --- ture/false you can Choose the StartMoney if Checkput Should Start for example by 10$
Config.StartAmount = 10   ------ Jackpot is Startamount + TicketPrice Means the First entry in DB will be 15 then every Ticket bought increased by 5
Config.TicketPrice = 5   ------- this is the Ticket Price and Also the amount that the jackpot Incresed by Like a Real Lottery

-----------------------------------------------------------------------------------
----------------------------------Translations-------------------------------------
-----------------------------------------------------------------------------------
--De
Config.PromptName = 'Lotterie'
Config.LotteryHeader = 'Lotterie'
Config.LabelBuyTicket = 'Kaufe Los Preis: '
Config.CloseLotterieMenu = 'Lotterie Schließen'
Config.TicketBought = 'Los für ' .. Config.TicketPrice .. '$ gekauft.'
Config.NextWinnerPick = 'Nächste Ziehung in: '
Config.MinuteLabel = ' Minuten'
Config.NoTicketsBought = 'Lotterie: Es wurden keine Lose Gekauft somit gibt es keinen Gewinner schade!'
Config.MaxTicketsBought = 'Du hast schon genug Lose! Max Lose: '
Config.TheWinnerIs = 'Der Gewinner ist: '
Config.HeWins = ' Der Gewinn ist: '
Config.LotteryOver = 'Es wurde ein Gewinner ausgelost schau in der Lotterie ob du Gewonnen hast'
Config.JackpotAmount = 'Aktueller Jackpot: '
Config.LabelGetWinnings = 'Gewinn Auszahlen!'
Config.WinningsGetLabel = 'Herzlichen Glückwunsch du Gewinnst '
Config.SadNoWin = 'Leider keinen Gewinn.'