-- ╔═══════════════════════════════════════╗
-- ║        Nova UI Library — Test Script  ║
-- ╚═══════════════════════════════════════╝

local Nova = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/sklzygit/aether-uilib/main/NovaLib.lua"
))()

-- ── CREATE WINDOW ────────────────────────
local Window = Nova:CreateWindow({
    Title    = "Aether",
    SubTitle = "v1.0.0 — Test Suite",
    Size     = UDim2.new(0, 580, 0, 440),
})

-- ══════════════════════════════════════════
-- TAB 1: Combat
-- ══════════════════════════════════════════
local CombatTab = Window:CreateTab("Combat", "combat")

local CombatSection = CombatTab:CreateSection("Aimbot")

CombatSection:CreateToggle({
    Label       = "Enable Aimbot",
    Description = "Locks onto the nearest target",
    Default     = false,
    Callback    = function(v)
        print("[Aimbot] Enabled:", v)
    end,
})

CombatSection:CreateSlider({
    Label    = "FOV",
    Min      = 10,
    Max      = 360,
    Default  = 90,
    Suffix   = "°",
    Callback = function(v)
        print("[Aimbot] FOV set to:", v)
    end,
})

CombatSection:CreateSlider({
    Label    = "Smoothness",
    Min      = 1,
    Max      = 100,
    Default  = 50,
    Suffix   = "%",
    Callback = function(v)
        print("[Aimbot] Smoothness:", v)
    end,
})

CombatSection:CreateDropdown({
    Label    = "Target Part",
    Options  = { "Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm" },
    Default  = "Head",
    Callback = function(v)
        print("[Aimbot] Target part:", v)
    end,
})

CombatSection:CreateKeybind({
    Label    = "Aimbot Key",
    Default  = Enum.KeyCode.Q,
    Callback = function(k)
        print("[Aimbot] Key changed to:", k)
    end,
})

local HitboxSection = CombatTab:CreateSection("Hitbox")

HitboxSection:CreateToggle({
    Label    = "Expand Hitboxes",
    Default  = false,
    Callback = function(v) print("[Hitbox] Expand:", v) end,
})

HitboxSection:CreateSlider({
    Label    = "Hitbox Size",
    Min      = 1,
    Max      = 20,
    Default  = 5,
    Decimals = 1,
    Callback = function(v) print("[Hitbox] Size:", v) end,
})

-- ══════════════════════════════════════════
-- TAB 2: Visuals
-- ══════════════════════════════════════════
local VisualsTab = Window:CreateTab("Visuals", "eye")

local ESPSection = VisualsTab:CreateSection("ESP")

local espEnabled = false
ESPSection:CreateToggle({
    Label    = "Player ESP",
    Default  = false,
    Callback = function(v)
        espEnabled = v
        print("[ESP] Enabled:", v)
        Window:Notify({
            Title   = "ESP " .. (v and "Enabled" or "Disabled"),
            Message = v and "Player ESP is now active." or "Player ESP turned off.",
            Type    = v and "success" or "warning",
            Duration = 3,
        })
    end,
})

ESPSection:CreateToggle({
    Label    = "Box ESP",
    Default  = false,
    Callback = function(v) print("[ESP] Box:", v) end,
})

ESPSection:CreateToggle({
    Label    = "Name ESP",
    Default  = true,
    Callback = function(v) print("[ESP] Name:", v) end,
})

ESPSection:CreateDropdown({
    Label    = "ESP Color Mode",
    Options  = { "Team Color", "Health Based", "Static", "Rainbow" },
    Default  = "Team Color",
    Callback = function(v) print("[ESP] Color mode:", v) end,
})

ESPSection:CreateSlider({
    Label    = "Max Distance",
    Min      = 100,
    Max      = 5000,
    Default  = 1000,
    Suffix   = " st",
    Callback = function(v) print("[ESP] Max dist:", v) end,
})

local WorldSection = VisualsTab:CreateSection("World")

WorldSection:CreateToggle({
    Label    = "Fullbright",
    Default  = false,
    Callback = function(v)
        local lighting = game:GetService("Lighting")
        lighting.Brightness = v and 10 or 1
        lighting.ClockTime  = v and 14 or lighting.ClockTime
        print("[World] Fullbright:", v)
    end,
})

WorldSection:CreateSlider({
    Label    = "Field of View",
    Min      = 70,
    Max      = 120,
    Default  = 90,
    Suffix   = "°",
    Callback = function(v)
        workspace.CurrentCamera.FieldOfView = v
    end,
})

-- ══════════════════════════════════════════
-- TAB 3: Player
-- ══════════════════════════════════════════
local PlayerTab = Window:CreateTab("Player", "player")

local MovSection = PlayerTab:CreateSection("Movement")

MovSection:CreateToggle({
    Label    = "Infinite Jump",
    Default  = false,
    Callback = function(v)
        local UIS = game:GetService("UserInputService")
        if v then
            _G.NovaIJConn = UIS.JumpRequest:Connect(function()
                game.Players.LocalPlayer.Character.Humanoid:ChangeState(
                    Enum.HumanoidStateType.Jumping)
            end)
        else
            if _G.NovaIJConn then
                _G.NovaIJConn:Disconnect()
                _G.NovaIJConn = nil
            end
        end
        print("[Player] Infinite Jump:", v)
    end,
})

MovSection:CreateSlider({
    Label    = "Walk Speed",
    Min      = 16,
    Max      = 300,
    Default  = 16,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end,
})

MovSection:CreateSlider({
    Label    = "Jump Power",
    Min      = 50,
    Max      = 500,
    Default  = 50,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = v
        end
    end,
})

MovSection:CreateButton({
    Label       = "Reset Character",
    Description = "Respawns your character",
    Icon        = "player",
    Callback    = function()
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
        Window:Notify({
            Title    = "Character Reset",
            Message  = "Your character has been respawned.",
            Type     = "info",
            Duration = 2,
        })
    end,
})

local MiscSection = PlayerTab:CreateSection("Misc")

MiscSection:CreateInput({
    Label       = "Chat Message",
    Placeholder = "Type something...",
    Callback    = function(text, entered)
        if entered and text ~= "" then
            if game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") then
                print("[Chat] Would send:", text)
            end
            print("[Input] Text submitted:", text)
        end
    end,
})

MiscSection:CreateSeparator("Notifications Test")

MiscSection:CreateButton({
    Label    = "Fire Success Notify",
    Callback = function()
        Window:Notify({ Title = "Success!", Message = "Everything went perfectly.", Type = "success", Duration = 4 })
    end,
})

MiscSection:CreateButton({
    Label    = "Fire Warning Notify",
    Callback = function()
        Window:Notify({ Title = "Warning", Message = "Something might be off.", Type = "warning", Duration = 4 })
    end,
})

MiscSection:CreateButton({
    Label    = "Fire Danger Notify",
    Callback = function()
        Window:Notify({ Title = "Error", Message = "Something went wrong!", Type = "danger", Duration = 4 })
    end,
})

-- ── STARTUP NOTIFY ───────────────────────
task.wait(0.5)
Window:Notify({
    Title    = "Nova Loaded",
    Message  = "Aether UI Test Suite is ready.",
    Type     = "success",
    Duration = 4,
})