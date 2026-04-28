--[[ 
    FINAL INTEGRATED BOT HOPPER
    - Fixed "nil value" error by adding universal function checks
    - [span_3](start_span)Included Discord Webhook integration[span_3](end_span)
    - [span_4](start_span)[span_5](start_span)Added Auto-Hop when targets found or server is empty[span_4](end_span)[span_5](end_span)
]]

-- Configuration
local DISCORD_WEBHOOK_URL = "https://discord.com/api/v10/webhooks/1498592185757470761/9HgevTEaO1cYp-tddnm8gIP00ioGPWyr_NrD6iERIbC6KKJPvJwR5CvWMIelmdNXxmOc"
local MY_SCRIPT_SOURCE = "loadstring(game:HttpGet('https://raw.githubusercontent.com/fuckalllarp/281hsysbwakiahsvebs/refs/heads/main/Ih0frb9ifecbuof3cbuo4fcbuofbrcoubufcro.lua'))()"

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local Player = game:GetService("Players").LocalPlayer

-- Universal Executor Function Support
local queuer = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request

local HopGuiName = "MobyServerHopGui"
local IsHopping = false
local AutoExecEnabled = false
local SentToWebhook = {}

-[span_6](start_span)- Cleanup existing GUIs[span_6](end_span)
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == HopGuiName or v.Name == "BestPetESP" then v:Destroy() end
end

-[span_7](start_span)- UI Construction[span_7](end_span)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = HopGuiName
ScreenGui.ResetOnSpawn = false

local HopGui = Instance.new("Frame", ScreenGui)
HopGui.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
HopGui.Position = UDim2.new(0.5, -110, 0.5, -110)
HopGui.Size = UDim2.new(0, 220, 0, 200)
Instance.new("UICorner", HopGui)

local startBtn = Instance.new("TextButton", HopGui)
startBtn.Text = "START SCANNER"
startBtn.Size = UDim2.new(1, -30, 0, 40)
startBtn.Position = UDim2.new(0, 15, 0, 20)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 106, 255)
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", startBtn)

local execBtn = Instance.new("TextButton", HopGui)
execBtn.Text = "AUTO EXECUTE [OFF]"
execBtn.Size = UDim2.new(1, -30, 0, 40)
execBtn.Position = UDim2.new(0, 15, 0, 70)
execBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
execBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
execBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", execBtn)

local statusLbl = Instance.new("TextLabel", HopGui)
statusLbl.Text = "Status: Ready"
statusLbl.Position = UDim2.new(0, 15, 0, 120)
statusLbl.Size = UDim2.new(1, -30, 0, 30)
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLbl.Font = Enum.Font.Gotham

-[span_8](start_span)- Teleport Logic[span_8](end_span)
local function teleport()
    if IsHopping then return end
    IsHopping = true
    statusLbl.Text = "Status: Server Hopping..."
    
    local function hop()
        local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(res)
        for _, v in ipairs(data.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                if AutoExecEnabled and queuer then
                    pcall(function() queuer(MY_SCRIPT_SOURCE) end)
                end
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, Player)
                return
            end
        end
    end
    pcall(hop)
    task.wait(5)
    IsHopping = false
end

-[span_9](start_span)[span_10](start_span)- Webhook Logic[span_9](end_span)[span_10](end_span)
local function sendWebhook(name, val)
    if not httpRequest then return end
    local join = "game:GetService('TeleportService'):TeleportToPlaceInstance("..game.PlaceId..", '"..game.JobId.."', game.Players.LocalPlayer)"
    pcall(function()
        httpRequest({
            Url = DISCORD_WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "🎯 High Value Found!",
                    color = 0x00FF00,
                    fields = {
                        {name = "Brainrot", value = name, inline = true},
                        {name = "Value", value = val, inline = true},
                        {name = "JobId", value = "```"..game.JobId.."```"},
                        {name = "Join Command", value = "```lua\n"..join.."```"}
                    }
                }}
            })
        })
    end)
end

-[span_11](start_span)[span_12](start_span)- Scanner Logic[span_11](end_span)[span_12](end_span)
local function scan()
    statusLbl.Text = "Status: Scanning..."
    task.wait(3) -- Wait for game objects to load
    
    local debris = Workspace:FindFirstChild("Debris")
    local found = false
    
    if debris then
        for _, item in ipairs(debris:GetChildren()) do
            if item.Name == "FastOverheadTemplate" then
                local sg = item:FindFirstChildOfClass("SurfaceGui")
                local gen = sg and sg:FindFirstChild("Generation", true)
                if gen and gen.Text ~= "" then
                    local txt = gen.Text
                    -[span_13](start_span)[span_14](start_span)- Check for Million, Billion, or Trillion suffixes[span_13](end_span)[span_14](end_span)
                    if txt:find("M") or txt:find("B") or txt:find("T") then
                        found = true
                        local nameLabel = sg:FindFirstChild("DisplayName", true)
                        local name = nameLabel and nameLabel.Text or "Unknown"
                        
                        if not SentToWebhook[name..txt] then
                            SentToWebhook[name..txt] = true
                            sendWebhook(name, txt)
                            task.wait(1)
                            teleport()
                            return
                        end
                    end
                end
            end
        end
    end
    
    if not found then
        statusLbl.Text = "Status: No units, hopping..."
        teleport()
    end
end

-[span_15](start_span)- Toggle Connections[span_15](end_span)
execBtn.MouseButton1Click:Connect(function()
    AutoExecEnabled = not AutoExecEnabled
    execBtn.Text = AutoExecEnabled and "AUTO EXECUTE [ON]" or "AUTO EXECUTE [OFF]"
    execBtn.BackgroundColor3 = AutoExecEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
end)

startBtn.MouseButton1Click:Connect(function()
    scan()
end)

-[span_16](start_span)- Auto Fix for Debris folder[span_16](end_span)
task.spawn(function()
    while task.wait(2) do
        if not Workspace:FindFirstChild("Debris") then
            local d = Instance.new("Folder", Workspace)
            d.Name = "Debris"
        end
    end
end)
