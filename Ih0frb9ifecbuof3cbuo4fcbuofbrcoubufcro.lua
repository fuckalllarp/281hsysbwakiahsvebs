--[[ 
    REBUILT BOT HOPPER
    - [span_3](start_span)Switched Firebase to Discord Webhooks[span_3](end_span)
    - Fixed "nil value" error for queue_on_teleport
    - Added Auto-Hop when targets are found or server is empty
]]

-- Configuration
local DISCORD_WEBHOOK_URL = "https://discord.com/api/v10/webhooks/1498592185757470761/9HgevTEaO1cYp-tddnm8gIP00ioGPWyr_NrD6iERIbC6KKJPvJwR5CvWMIelmdNXxmOc"
local MY_SCRIPT_SOURCE = "loadstring(game:HttpGet('https://raw.githubusercontent.com/fuckalllarp/281hsysbwakiahsvebs/refs/heads/main/Ih0frb9ifecbuof3cbuo4fcbuofbrcoubufcro.lua'))()" -- Set this to your main script link

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local Player = game:GetService("Players").LocalPlayer

-- Universal executor support for queue_on_teleport
local queuer = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request

local HopGuiName = "MobyServerHopGui"
local IsHopping = false
local AutoExecEnabled = false
local SentToWebhook = {}
local ActiveESPs = {}

-[span_4](start_span)- Cleanup existing GUIs[span_4](end_span)
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == HopGuiName or v.Name == "BestPetESP" then v:Destroy() end
end

-[span_5](start_span)- UI Construction[span_5](end_span)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = HopGuiName
ScreenGui.ResetOnSpawn = false

local HopGui = Instance.new("Frame", ScreenGui)
HopGui.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
HopGui.Position = UDim2.new(0.5, -110, 0.5, -110)
HopGui.Size = UDim2.new(0, 220, 0, 230)
HopGui.Active = true
Instance.new("UICorner", HopGui).CornerRadius = UDim.new(0, 8)

local HopTitle = Instance.new("TextLabel", HopGui)
HopTitle.BackgroundTransparency = 1
HopTitle.Size = UDim2.new(1, 0, 0, 40)
HopTitle.Font = Enum.Font.GothamBold
HopTitle.Text = "Bot Webhook & ESP"
HopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HopTitle.TextSize = 14

local espBtn = Instance.new("TextButton", HopGui)
espBtn.Text = "START SCANNER [OFF]"
espBtn.Position = UDim2.new(0,15,0,50)
espBtn.Size = UDim2.new(1,-30,0,35)
espBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
espBtn.TextColor3 = Color3.fromRGB(255,255,255)
espBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", espBtn)

local execBtn = Instance.new("TextButton", HopGui)
execBtn.Text = "AUTO EXECUTE [OFF]"
execBtn.Position = UDim2.new(0,15,0,95)
execBtn.Size = UDim2.new(1,-30,0,35)
execBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
execBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
execBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", execBtn)

local statusLbl = Instance.new("TextLabel", HopGui)
statusLbl.Text = "Status: Idle"
statusLbl.Position = UDim2.new(0,15,0,140)
statusLbl.Size = UDim2.new(1,-30,0,30)
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLbl.Font = Enum.Font.Gotham

-[span_6](start_span)[span_7](start_span)- Teleport Logic[span_6](end_span)[span_7](end_span)
local function teleportToNewServer()
    if IsHopping then return end
    IsHopping = true
    statusLbl.Text = "Status: Finding Server..."
    
    local function doHop()
        local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(req)
        if data and data.data then
            for _, v in ipairs(data.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    if AutoExecEnabled and queuer then
                        queuer(MY_SCRIPT_SOURCE)
                    end
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, Player)
                    return
                end
            end
        end
    end
    pcall(doHop)
    task.wait(3)
    IsHopping = false
end

-[span_8](start_span)- Webhook Sender[span_8](end_span)
local function sendToDiscord(name, valText)
    if not httpRequest then return end
    local joinScript = "game:GetService('TeleportService'):TeleportToPlaceInstance("..game.PlaceId..", '"..game.JobId.."', game.Players.LocalPlayer)"
    
    local payload = {
        ["embeds"] = {{
            ["title"] = "🚀 Brainrot Found!",
            ["color"] = 65280,
            ["fields"] = {
                {["name"] = "Name", ["value"] = name, ["inline"] = true},
                {["name"] = "Money/Sec", ["value"] = valText, ["inline"] = true},
                {["name"] = "Job ID", ["value"] = "```"..game.JobId.."```"},
                {["name"] = "Join Command", ["value"] = "```lua\n"..joinScript.."```"}
            }
        }}
    }

    pcall(function()
        httpRequest({
            Url = DISCORD_WEBHOOK_URL,
            Method = "POST",
            Body = HttpService:JSONEncode(payload),
            Headers = {["Content-Type"] = "application/json"}
        })
    end)
end

-[span_9](start_span)- Value Parsing[span_9](end_span)
local function parseValue(text)
    local clean = tostring(text or ""):gsub("%s", "")
    local num, suffix = clean:match("([%d%.]+)([KkMmBbTt]?)")
    if not num then return 0 end
    num = tonumber(num) or 0
    local mults = {K=1e3, M=1e6, B=1e9, T=1e12}
    return num * (mults[(suffix or ""):upper()] or 1)
end

-[span_10](start_span)[span_11](start_span)- Scanner / ESP Loop[span_10](end_span)[span_11](end_span)
local function startScanner()
    getgenv().BestPetESP = { active = true }
    statusLbl.Text = "Status: Scanning..."
    
    task.spawn(function()
        task.wait(2) -- Let debris load
        local foundInServer = false
        local debris = Workspace:FindFirstChild("Debris")
        
        if debris then
            for _, template in ipairs(debris:GetChildren()) do
                if template.Name == "FastOverheadTemplate" then
                    local sg = template:FindFirstChildOfClass("SurfaceGui")
                    local gen = sg and sg:FindFirstChild("Generation", true)
                    
                    if gen and gen.Text ~= "" then
                        local valText = gen.Text
                        local numVal = parseValue(valText)
                        
                        [span_12](start_span)if numVal >= 10000000 then -- 10M+[span_12](end_span)
                            foundInServer = true
                            local name = sg:FindFirstChild("DisplayName", true).Text or "Brainrot"
                            if not SentToWebhook[name..valText] then
                                SentToWebhook[name..valText] = true
                                sendToDiscord(name, valText)
                                task.wait(2) -- Sync wait
                                teleportToNewServer()
                                return
                            end
                        end
                    end
                end
            end
        end

        if not foundInServer then
            statusLbl.Text = "Status: Empty, Hopping..."
            teleportToNewServer()
        end
    end)
end

-[span_13](start_span)[span_14](start_span)- Connections[span_13](end_span)[span_14](end_span)
execBtn.MouseButton1Click:Connect(function()
    AutoExecEnabled = not AutoExecEnabled
    execBtn.Text = AutoExecEnabled and "AUTO EXECUTE [ON]" or "AUTO EXECUTE [OFF]"
    execBtn.BackgroundColor3 = AutoExecEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
end)

espBtn.MouseButton1Click:Connect(function()
    startScanner()
end)

-[span_15](start_span)- Dragging Logic[span_15](end_span)
local hDragging, hDragStart, hStartPos
HopGui.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        hDragging = true hDragStart = input.Position hStartPos = HopGui.Position
    end
end)
HopGui.InputChanged:Connect(function(input)
    if hDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - hDragStart
        HopGui.Position = UDim2.new(hStartPos.X.Scale, hStartPos.X.Offset + delta.X, hStartPos.Y.Scale, hStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then hDragging = false end
end)
