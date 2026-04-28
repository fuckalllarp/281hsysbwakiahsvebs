-- Configuration
local DISCORD_WEBHOOK_URL = "https://discord.com/api/v10/webhooks/1498592185757470761/9HgevTEaO1cYp-tddnm8gIP00ioGPWyr_NrD6iERIbC6KKJPvJwR5CvWMIelmdNXxmOc"

-- PASTE YOUR ENTIRE SCRIPT SOURCE CODE BETWEEN THE [[ ]] BELOW
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

-- Cleanup old instances
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == HopGuiName or v.Name == "BestPetESP" then v:Destroy() end
end

-- UI Construction
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = HopGuiName
local HopGui = Instance.new("Frame", ScreenGui)
HopGui.Size = UDim2.new(0, 220, 0, 220)
HopGui.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", HopGui)

local execBtn = Instance.new("TextButton", HopGui)
execBtn.Text = "AUTO EXECUTE [OFF]"
execBtn.Position = UDim2.new(0,15,0,140)
execBtn.Size = UDim2.new(1,-30,0,35)
execBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
execBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
execBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", execBtn)

-- Teleport Logic
local function teleportToNewServer()
    if IsHopping then return end
    IsHopping = true
    
    local function findServer()
        local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(res)
        if data and data.data then
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    -- Execute the raw source code on the next server
                    if AutoExecEnabled and queue_on_teleport then
                        [span_3](start_span)queue_on_teleport(MY_SCRIPT_SOURCE)[span_3](end_span)
                    end
                    [span_4](start_span)TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)[span_4](end_span)
                    return
                end
            end
        end
    end
    
    pcall(findServer)
    task.wait(2)
    IsHopping = false
end

-- Webhook Logic
local httpRequest = (syn and syn.request) or (http and http.request) or request
local function sendToDiscord(name, valText)
    if not httpRequest then return end
    local joinScript = "game:GetService('TeleportService'):TeleportToPlaceInstance("..game.PlaceId..", '"..game.JobId.."', game.Players.LocalPlayer)"
    
    local payload = {
        ["embeds"] = {{
            ["title"] = "✅ Target Identified",
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
        [span_5](start_span)Headers = {["Content-Type"] = "application/json"}[span_5](end_span)
    })
end

-- ESP & Auto-Hop Loop
local function startESP()
    getgenv().BestPetESP = { active = true }
    getgenv().BestPetESP.loop = task.spawn(function()
        while getgenv().BestPetESP.active do
            local foundValuable = false
            [span_6](start_span)local debris = Workspace:FindFirstChild("Debris")[span_6](end_span)
            
            if debris then
                local children = debris:GetChildren()
                for _, template in ipairs(children) do
                    [span_7](start_span)if template.Name == "FastOverheadTemplate" then[span_7](end_span)
                        local sg = template:FindFirstChildOfClass("SurfaceGui")
                        local gen = sg and sg:FindFirstChild("Generation", true)
                        
                        if gen and gen:IsA("TextLabel") and gen.Text ~= "" then
                            -- Parse logic for numbers
                            local text = gen.Text
                            local clean = text:gsub("%s", ""):match("([%d%.]+)([KkMmBbTt]?)")
                            local num = tonumber(clean) or 0
                            
                            -- Logic: If it's 10M+ (Adjust as needed)
                            if text:find("M") or text:find("B") or text:find("T") then
                                foundValuable = true
                                [span_8](start_span)local name = sg:FindFirstChild("DisplayName", true).Text[span_8](end_span)
                                sendToDiscord(name, text)
                                task.wait(3) -- Time for webhook to send
                                teleportToNewServer()
                                return -- Stop loop to hop
                            end
                        end
                    end
                end
            end

            -- If we checked everything and found nothing, hop immediately
            if not foundValuable then
                teleportToNewServer()
                return
            end
            
            task.wait(1)
        end
    end)
end

-- Toggles
execBtn.MouseButton1Click:Connect(function()
    AutoExecEnabled = not AutoExecEnabled
    execBtn.Text = AutoExecEnabled and "AUTO EXECUTE [ON]" or "AUTO EXECUTE [OFF]"
    execBtn.BackgroundColor3 = AutoExecEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
end)

-- The "START" button logic remains the same to trigger startESP()
