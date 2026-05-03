--[[
    FLY & NOCLIP SCRIPT (Multi-Device)
    Befehle:
    ;fly [1-15] -> Startet Fliegen (WASD / Stick / Controller)
    ;unfly      -> Stoppt Fliegen
    ;noclip     -> Durch Wände gehen AN
    ;unnoclip   -> Durch Wände gehen AUS
]]

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- UI Anzeige oben in der Mitte
local function createUI()
    if player.PlayerGui:FindFirstChild("CustomInfoGui") then
        player.PlayerGui.CustomInfoGui:Destroy()
    end

    local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    sg.Name = "CustomInfoGui"
    
    local label = Instance.new("TextLabel", sg)
    label.Size = UDim2.new(0, 400, 0, 50)
    label.Position = UDim2.new(0.5, -200, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "if you Like the Script you the Besht Bro"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 24
end

createUI()

-- Variablen
local character, humanoid, root
local flying = false
local noclip = false
local flySpeed = 50 

local function updateVars()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")
end
updateVars()
player.CharacterAdded:Connect(updateVars)

-- Noclip Logik
runService.Stepped:Connect(function()
    if noclip and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Fly Logik (Steuerung via MoveDirection)
local function startFly()
    if flying then return end
    flying = true
    
    local bg = Instance.new("BodyGyro", root)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = root.CFrame

    local bv = Instance.new("BodyVelocity", root)
    bv.velocity = Vector3.new(0, 0, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

    humanoid.PlatformStand = true

    task.spawn(function()
        while flying and character and root do
            local camera = workspace.CurrentCamera
            
            -- WICHTIG: Das hier erkennt automatisch WASD und den iPad Thumbstick!
            local moveDir = humanoid.MoveDirection
            
            if moveDir.Magnitude > 0 then
                -- Bewegt dich dorthin, wo du drückst/steuerst
                bv.velocity = moveDir * flySpeed
            else
                -- Halten, wenn keine Eingabe erfolgt
                bv.velocity = Vector3.new(0, 0, 0)
            end
            
            -- Charakter dreht sich mit der Kamera
            bg.cframe = camera.CFrame
            task.wait()
        end
        
        -- Aufräumen
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        if humanoid then humanoid.PlatformStand = false end
    end)
end

-- Chat Befehle
player.Chatted:Connect(function(msg)
    local args = string.split(msg:lower(), " ")

    if args[1] == ";fly" then
        local input = tonumber(args[2])
        if input then
            flySpeed = math.clamp(input, 1, 15) * 10
        else
            flySpeed = 50 
        end
        startFly()
        
    elseif args[1] == ";unfly" then
        flying = false
        
    elseif args[1] == ";noclip" then
        noclip = true
        
    elseif args[1] == ";unnoclip" then
        noclip = false
    end
end)
