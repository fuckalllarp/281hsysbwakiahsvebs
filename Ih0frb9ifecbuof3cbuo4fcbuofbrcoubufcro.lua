-- Configuration
local DISCORD_WEBHOOK_URL = "https://discord.com/api/v10/webhooks/1498592185757470761/9HgevTEaO1cYp-tddnm8gIP00ioGPWyr_NrD6iERIbC6KKJPvJwR5CvWMIelmdNXxmOc"
local MY_SCRIPT_SOURCE = "loadstring(game:HttpGet('https://raw.githubusercontent.com/fuckalllarp/281hsysbwakiahsvebs/refs/heads/main/Ih0frb9ifecbuof3cbuo4fcbuofbrcoubufcro.lua'))()"

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local Player = game:GetService("Players").LocalPlayer

local HopGuiName = "MobyServerHopGui"
local IsHopping = false
local AutoExecEnabled = false

-- Cleanup
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == HopGuiName or v.Name == "BestPetESP" then v:Destroy() end
end

-- UI Construction
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = HopGuiName

local HopGui = Instance.new("Frame", ScreenGui)
HopGui.Size = UDim2.new(0, 220, 0, 190)
HopGui.Position = UDim2.new(0.5, -110, 0.5, -95)
HopGui.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HopGui.Active = true
HopGui.Draggable = true -- Legacy drag for simplicity
Instance.new("UICorner", HopGui)

local startBtn = Instance.new("TextButton", HopGui)
startBtn.Text = "START SCANNER"
startBtn.Size = UDim2.new(1, -20, 0, 40)
startBtn.Position = UDim2.new(0, 10, 0, 10)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", startBtn)

local execBtn = Instance.new("TextButton", HopGui)
execBtn.Text = "AUTO EXECUTE [OFF]"
execBtn.Size = UDim2.new(1, -20, 0, 40)
execBtn.Position = UDim2.new(0, 10, 0, 60)
execBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
execBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", execBtn)

local statusLbl = Instance.new("TextLabel", HopGui)
statusLbl.Text = "Status: Idle"
statusLbl.Size = UDim2.new(1, -20, 0, 30)
statusLbl.Position = UDim2.new(0, 10, 0, 110)
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLbl.Font = Enum.Font.Gotham

-- Teleport Logic
local function teleportToNewServer()
    if IsHopping then return end
    IsHopping = true
    statusLbl.Text = "Status: Hopping..."
    
    local function findServer()
        local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(res)
        if data and data.data then
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    if AutoExecEnabled and queue_on_teleport then
                        [span_0](start_span)queue_on_teleport(MY_SCRIPT_SOURCE)[span_0](end_span)
                    end
                    [span_1](start_span)TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)[span_1](end_span)
                    return
                end
            end
        end
    end
    
    pcall(findServer)
    task.wait(5) -- Longer wait to prevent spamming failed hops
    IsHopping = false
end

-- Webhook Logic
local httpRequest = (syn and syn.request) or (http and http.request) or request
local function sendToDiscord(name, valText)
    if not httpRequest then return end
    local joinScript = "game:GetService('TeleportService'):TeleportToPlaceInstance("..game.PlaceId..", '"..game.JobId.."', game.Players.LocalPlayer)"
    
    local payload = {
        ["embeds"] = {{
            ["title"] = "✅ Target Found in " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
            ["color"] = 0x00FF00,
            ["fields"] = {
                {["name"] = "Brainrot", ["value"] = name, ["inline"] = true},
                {["name"] = "Value", ["value"] = valText, ["inline"] = true},
                {["name"] = "Join Script", ["value"] = "```lua\n"..joinScript.."\n```"}
            },
            ["footer"] = {["text"] = "JobId: "..game.JobId}
        }}
    }

    httpRequest({
        Url = DISCORD_WEBHOOK_URL,
        Method = "POST",
        Body = HttpService:JSONEncode(payload),
        [span_2](start_span)Headers = {["Content-Type"] = "application/json"}[span_2](end_span)
    })
end

-- ESP & Auto-Hop Loop
local function startESP()
    if getgenv().Scanning then return end
    getgenv().Scanning = true
    statusLbl.Text = "Status: Scanning..."
    
    task.spawn(function()
        -- Give the game a few seconds to load objects before the first check
        task.wait(3) 
        
        local foundValuable = false
        [span_3](start_span)local debris = Workspace:FindFirstChild("Debris")[span_3](end_span)
        
        if debris then
            for _, template in ipairs(debris:GetChildren()) do
                [span_4](start_span)if template.Name == "FastOverheadTemplate" then[span_4](end_span)
                    local sg = template:FindFirstChildOfClass("SurfaceGui")
                    local gen = sg and sg:FindFirstChild("Generation", true)
                    
                    if gen and gen:IsA("TextLabel") and gen.Text ~= "" then
                        local text = gen.Text
                        -- Checks if the text contains Million, Billion, or Trillion
                        if text:find("M") or text:find("B") or text:find("T") then
                            foundValuable = true
                            [span_5](start_span)local name = sg:FindFirstChild("DisplayName", true) and sg:FindFirstChild("DisplayName", true).Text or "Unknown"[span_5](end_span)
                            sendToDiscord(name, text)
                            statusLbl.Text = "Status: Target Found!"
                            task.wait(2)
                            teleportToNewServer()
                            return 
                        end
                    end
                end
            end
        end

        if not foundValuable then
            statusLbl.Text = "Status: No targets, hopping..."
            task.wait(1)
            teleportToNewServer()
        end
        getgenv().Scanning = false
    end)
end

-- Button Connections
execBtn.MouseButton1Click:Connect(function()
    AutoExecEnabled = not AutoExecEnabled
    execBtn.Text = AutoExecEnabled and "AUTO EXECUTE [ON]" or "AUTO EXECUTE [OFF]"
    execBtn.BackgroundColor3 = AutoExecEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
end)

startBtn.MouseButton1Click:Connect(function()
    startESP()
end)
