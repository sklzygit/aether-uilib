--[[
╔══════════════════════════════════════════════════════════════════╗
║                    NOVA  ·  UI LIBRARY  v2.0                     ║
║              "Obsidian" — Engineered. Precise. Lethal.           ║
╚══════════════════════════════════════════════════════════════════╝

  QUICK START:
  ─────────────────────────────────────────────────────────────────
  local Nova = loadstring(game:HttpGet(RAW_URL))()

  local Win = Nova:CreateWindow({
      Title    = "My Script",
      SubTitle = "v1.0.0",
      Key      = Enum.KeyCode.RightShift,   -- toggle key (optional)
  })

  local Tab     = Win:CreateTab("Combat", "sword")
  local Section = Tab:CreateSection("Aimbot")

  Section:CreateToggle({ Label="Enable", Default=false, Callback=function(v) end })
  Section:CreateSlider({ Label="FOV", Min=10, Max=360, Default=90, Suffix="°", Callback=function(v) end })
  Section:CreateDropdown({ Label="Part", Options={"Head","Torso"}, Default="Head", Callback=function(v) end })
  Section:CreateButton({ Label="Do Thing", Callback=function() end })
  Section:CreateInput({ Label="Name", Placeholder="...", Callback=function(v,enter) end })
  Section:CreateKeybind({ Label="Key", Default=Enum.KeyCode.Q, Callback=function(k) end })
  Section:CreateLabel({ Text="Some info text" })
  Section:CreateSeparator()

  Win:Notify({ Title="Loaded", Message="Ready.", Type="success", Duration=4 })
  Win:SaveConfig("slot1")
  Win:LoadConfig("slot1")
  ─────────────────────────────────────────────────────────────────
]]

-- ════════════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LP   = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════════════════
-- THEME  —  "Obsidian"
--   Deep black base · Electric cyan accents · Monospaced precision
-- ════════════════════════════════════════════════════════════════════
local T = {
    Base        = Color3.fromRGB(8,   9,  12),
    Surface     = Color3.fromRGB(12,  13, 18),
    Panel       = Color3.fromRGB(15,  17, 23),
    Card        = Color3.fromRGB(19,  21, 30),
    CardHover   = Color3.fromRGB(24,  27, 38),
    Elevated    = Color3.fromRGB(28,  31, 44),
    ElevatedHi  = Color3.fromRGB(34,  38, 54),

    Accent      = Color3.fromRGB(0,  210, 200),
    AccentDim   = Color3.fromRGB(0,  140, 134),
    AccentGlow  = Color3.fromRGB(0,  255, 242),
    AccentBg    = Color3.fromRGB(0,   38,  36),

    Success     = Color3.fromRGB(60,  210, 120),
    Warning     = Color3.fromRGB(255, 185,  50),
    Danger      = Color3.fromRGB(235,  65,  75),

    TxtPrimary  = Color3.fromRGB(220, 228, 240),
    TxtSecond   = Color3.fromRGB(130, 145, 170),
    TxtMuted    = Color3.fromRGB(65,   75,  98),
    TxtAccent   = Color3.fromRGB(0,   210, 200),

    BorderLo    = Color3.fromRGB(255, 255, 255),
    BorderHi    = Color3.fromRGB(0,   210, 200),

    RLg   = UDim.new(0, 12),
    RMd   = UDim.new(0, 8),
    RSm   = UDim.new(0, 5),
    RXs   = UDim.new(0, 3),
    RPill = UDim.new(1, 0),

    Fast   = TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Med    = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.48, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),

    Bold  = Enum.Font.GothamBold,
    Semi  = Enum.Font.GothamSemibold,
    Reg   = Enum.Font.Gotham,
    Mono  = Enum.Font.RobotoMono,
}

-- ════════════════════════════════════════════════════════════════════
-- UTILITY
-- ════════════════════════════════════════════════════════════════════
local U = {}

function U.Tween(o, ti, props)
    local t = TweenService:Create(o, ti, props)
    t:Play()
    return t
end
function U.Fast(o,p)   return U.Tween(o, T.Fast,   p) end
function U.Med(o,p)    return U.Tween(o, T.Med,    p) end
function U.Bounce(o,p) return U.Tween(o, T.Bounce, p) end

function U.Corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or T.RMd
    return c
end

function U.Stroke(p, col, alpha, thick)
    local s = Instance.new("UIStroke", p)
    s.Color           = col   or T.BorderLo
    s.Transparency    = alpha or 0.88
    s.Thickness       = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function U.Pad(p, t, r, b, l)
    local pad = Instance.new("UIPadding", p)
    pad.PaddingTop    = UDim.new(0, t or 0)
    pad.PaddingRight  = UDim.new(0, r or t or 0)
    pad.PaddingBottom = UDim.new(0, b or t or 0)
    pad.PaddingLeft   = UDim.new(0, l or r or t or 0)
    return pad
end

function U.List(p, dir, gap, ha, va)
    local l = Instance.new("UIListLayout", p)
    l.FillDirection       = dir or Enum.FillDirection.Vertical
    l.Padding             = UDim.new(0, gap or 0)
    l.HorizontalAlignment = ha  or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = va  or Enum.VerticalAlignment.Top
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    return l
end

function U.Grad(p, cols, rot)
    local g = Instance.new("UIGradient", p)
    if type(cols[1]) == "table" then
        local kps = {}
        for i, kp in ipairs(cols) do
            kps[i] = ColorSequenceKeypoint.new(kp[1], kp[2])
        end
        g.Color = ColorSequence.new(kps)
    else
        g.Color = ColorSequence.new(cols[1], cols[2])
    end
    g.Rotation = rot or 0
    return g
end

function U.New(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

-- Auto-resize ScrollingFrame canvas to content
function U.AutoCanvas(scroll, layout, extra)
    extra = extra or 0
    local function upd()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + extra)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    upd()
end

-- Auto-resize Frame height to content
function U.AutoHeight(frame, layout, extra)
    extra = extra or 0
    local function upd()
        frame.Size = UDim2.new(
            frame.Size.X.Scale, frame.Size.X.Offset,
            0, layout.AbsoluteContentSize.Y + extra)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    upd()
end

-- Cyan ripple on click
function U.Ripple(btn, x, y)
    local rip = Instance.new("Frame", btn)
    rip.BackgroundColor3 = T.Accent
    rip.BackgroundTransparency = 0.80
    rip.BorderSizePixel = 0
    rip.ZIndex = btn.ZIndex + 8
    rip.Size = UDim2.new(0, 0, 0, 0)
    rip.Position = UDim2.new(0, x, 0, y)
    rip.AnchorPoint = Vector2.new(0.5, 0.5)
    U.Corner(rip, T.RPill)
    local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.4
    U.Tween(rip, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, sz, 0, sz),
        BackgroundTransparency = 1,
    })
    game:GetService("Debris"):AddItem(rip, 0.55)
end

-- ════════════════════════════════════════════════════════════════════
-- ICONS
-- ════════════════════════════════════════════════════════════════════
local ICONS = {
    sword   = "⚔",  eye     = "◉",  settings = "⚙",
    player  = "◈",  star    = "★",  home     = "⌂",
    misc    = "◆",  bell    = "◎",  key      = "◇",
    search  = "⌕",  lock    = "⊠",  color    = "◑",
    code    = "⟨⟩", folder  = "▤",  combat   = "⚔",
    visual  = "◉",  config  = "⚙",  info     = "ⓘ",
    warn    = "⚠",  danger  = "⊘",  success  = "⊛",
}
function U.Icon(n) return ICONS[n] or "◆" end

-- ════════════════════════════════════════════════════════════════════
-- CONFIG SYSTEM
-- ════════════════════════════════════════════════════════════════════
local ConfigStore        = {}
local ComponentRegistry  = {}
local _idN = 0
local function newId() _idN = _idN + 1; return "nv_" .. _idN end

local function saveConfig(slot)
    local data = {}
    for id, comp in pairs(ComponentRegistry) do
        local ok, v = pcall(comp.get)
        if ok then data[id] = v end
    end
    ConfigStore[slot] = data
    if writefile then
        pcall(writefile, "Nova_" .. slot .. ".json",
            game:GetService("HttpService"):JSONEncode(data))
    end
end

local function loadConfig(slot)
    local data = ConfigStore[slot]
    if not data and readfile then
        local ok, raw = pcall(readfile, "Nova_" .. slot .. ".json")
        if ok and raw then
            local ok2, dec = pcall(function()
                return game:GetService("HttpService"):JSONDecode(raw)
            end)
            if ok2 then data = dec end
        end
    end
    if not data then return end
    for id, val in pairs(data) do
        if ComponentRegistry[id] then
            pcall(ComponentRegistry[id].set, val, true)
        end
    end
end

-- ════════════════════════════════════════════════════════════════════
-- NOTIFICATION ENGINE
-- ════════════════════════════════════════════════════════════════════
local _notifStack = nil

local function fireNotif(opts)
    if not _notifStack then return end
    local dur    = opts.Duration or 4
    local nType  = opts.Type or "info"
    local cmap   = { success=T.Success, warning=T.Warning, danger=T.Danger, info=T.Accent }
    local imap   = { success="success", warning="warn", danger="danger", info="info" }
    local accent = cmap[nType] or T.Accent

    local Card = Instance.new("Frame", _notifStack)
    Card.Name = "Notif"
    Card.Size = UDim2.new(1, 0, 0, 68)
    Card.BackgroundColor3 = T.Panel
    Card.BorderSizePixel = 0
    Card.ClipsDescendants = true
    Card.BackgroundTransparency = 1
    U.Corner(Card, T.RMd)
    U.Stroke(Card, accent, 0.65, 1)

    -- Left stripe
    local Stripe = Instance.new("Frame", Card)
    Stripe.Size = UDim2.new(0, 3, 1, 0)
    Stripe.BackgroundColor3 = accent
    Stripe.BorderSizePixel = 0
    U.Corner(Stripe, T.RPill)

    -- Top line
    local TopLine = Instance.new("Frame", Card)
    TopLine.Size = UDim2.new(1, 0, 0, 1)
    TopLine.BackgroundColor3 = accent
    TopLine.BackgroundTransparency = 0.6
    TopLine.BorderSizePixel = 0

    -- Icon circle
    local IC = Instance.new("Frame", Card)
    IC.Size = UDim2.new(0, 28, 0, 28)
    IC.Position = UDim2.new(0, 12, 0.5, -14)
    IC.BackgroundColor3 = accent
    IC.BackgroundTransparency = 0.82
    IC.BorderSizePixel = 0
    U.Corner(IC, T.RPill)
    U.New("TextLabel", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = U.Icon(imap[nType]),
        TextColor3 = accent,
        TextSize = 13,
        Font = T.Bold,
    }, IC)

    U.New("TextLabel", {
        Size = UDim2.new(1,-50,0,18),
        Position = UDim2.new(0,48,0,12),
        BackgroundTransparency = 1,
        Text = opts.Title or "Notification",
        TextColor3 = T.TxtPrimary,
        TextSize = 13,
        Font = T.Bold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Card)

    U.New("TextLabel", {
        Size = UDim2.new(1,-50,0,15),
        Position = UDim2.new(0,48,0,32),
        BackgroundTransparency = 1,
        Text = opts.Message or "",
        TextColor3 = T.TxtSecond,
        TextSize = 11,
        Font = T.Reg,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, Card)

    -- Progress bar
    local PBg = Instance.new("Frame", Card)
    PBg.Size = UDim2.new(1,-16,0,2)
    PBg.Position = UDim2.new(0,8,1,-5)
    PBg.BackgroundColor3 = T.Elevated
    PBg.BorderSizePixel = 0
    U.Corner(PBg, T.RPill)
    local Prog = Instance.new("Frame", PBg)
    Prog.Size = UDim2.new(1,0,1,0)
    Prog.BackgroundColor3 = accent
    Prog.BorderSizePixel = 0
    U.Corner(Prog, T.RPill)

    Card.Position = UDim2.new(1.1, 0, 0, 0)
    U.Med(Card, { BackgroundTransparency = 0, Position = UDim2.new(0,0,0,0) })
    U.Tween(Prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0,0,1,0) })

    task.delay(dur, function()
        U.Fast(Card, { BackgroundTransparency = 1, Position = UDim2.new(1.1,0,0,0) })
        task.wait(0.22)
        if Card and Card.Parent then Card:Destroy() end
    end)
end

-- ════════════════════════════════════════════════════════════════════
-- COMPONENTS
-- ════════════════════════════════════════════════════════════════════
local Comp = {}

-- ── SEPARATOR ────────────────────────────────────────────────────────
function Comp.Separator(parent, label)
    local Wrap = U.New("Frame", {
        Size = UDim2.new(1,0,0,20),
        BackgroundTransparency = 1,
        Name = "Separator",
    }, parent)

    if label and label ~= "" then
        U.New("Frame", {
            Size = UDim2.new(0.3,0,0,1),
            Position = UDim2.new(0,0,0.5,0),
            BackgroundColor3 = T.BorderLo,
            BackgroundTransparency = 0.82,
            BorderSizePixel = 0,
        }, Wrap)
        U.New("TextLabel", {
            Size = UDim2.new(0.4,0,1,0),
            Position = UDim2.new(0.3,0,0,0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = T.TxtMuted,
            TextSize = 10,
            Font = T.Bold,
            TextXAlignment = Enum.TextXAlignment.Center,
        }, Wrap)
        U.New("Frame", {
            Size = UDim2.new(0.3,0,0,1),
            Position = UDim2.new(0.7,0,0.5,0),
            BackgroundColor3 = T.BorderLo,
            BackgroundTransparency = 0.82,
            BorderSizePixel = 0,
        }, Wrap)
    else
        U.New("Frame", {
            Size = UDim2.new(1,0,0,1),
            Position = UDim2.new(0,0,0.5,0),
            BackgroundColor3 = T.BorderLo,
            BackgroundTransparency = 0.88,
            BorderSizePixel = 0,
        }, Wrap)
    end
    return Wrap
end

-- ── LABEL ─────────────────────────────────────────────────────────────
function Comp.Label(parent, opts)
    local f = U.New("Frame", {
        Size = UDim2.new(1,0,0,30),
        BackgroundColor3 = T.Card,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Name = "Label",
    }, parent)
    U.Corner(f, T.RSm)
    U.Pad(f, 0,10,0,12)

    local pip = Instance.new("Frame", f)
    pip.Size = UDim2.new(0,2,0,12)
    pip.Position = UDim2.new(0,0,0.5,-6)
    pip.BackgroundColor3 = T.AccentDim
    pip.BorderSizePixel = 0
    U.Corner(pip, T.RPill)

    local lbl = U.New("TextLabel", {
        Size = UDim2.new(1,-14,1,0),
        Position = UDim2.new(0,14,0,0),
        BackgroundTransparency = 1,
        Text = opts.Text or "Label",
        TextColor3 = opts.Color or T.TxtSecond,
        TextSize = opts.Size or 12,
        Font = T.Reg,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)

    local api = {}
    function api:Set(txt) lbl.Text = txt end
    function api:SetColor(col) lbl.TextColor3 = col end
    return api
end

-- ── BUTTON ────────────────────────────────────────────────────────────
function Comp.Button(parent, opts)
    local h = opts.Description and 48 or 38

    local Btn = Instance.new("TextButton", parent)
    Btn.Name = "Button"
    Btn.Size = UDim2.new(1,0,0,h)
    Btn.BackgroundColor3 = T.Card
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.ClipsDescendants = true
    U.Corner(Btn, T.RSm)
    local stroke = U.Stroke(Btn, T.BorderLo, 0.88, 1)
    U.Pad(Btn, 0,14,0,14)

    -- Hover tint
    local HFill = Instance.new("Frame", Btn)
    HFill.Size = UDim2.new(1,0,1,0)
    HFill.BackgroundColor3 = T.Accent
    HFill.BackgroundTransparency = 1
    HFill.BorderSizePixel = 0
    HFill.ZIndex = Btn.ZIndex + 1

    -- Left accent bar
    local Bar = Instance.new("Frame", Btn)
    Bar.Size = UDim2.new(0,2,0.55,0)
    Bar.Position = UDim2.new(0,0,0.225,0)
    Bar.BackgroundColor3 = T.Accent
    Bar.BackgroundTransparency = 1
    Bar.BorderSizePixel = 0
    U.Corner(Bar, T.RPill)

    local topOffset = opts.Description and 8 or 0
    local MainLbl = U.New("TextLabel", {
        Size = UDim2.new(1,-24,0, opts.Description and 20 or 0),
        Position = UDim2.new(0,0,0,topOffset),
        AutomaticSize = opts.Description and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = opts.Label or "Button",
        TextColor3 = T.TxtPrimary,
        TextSize = 13,
        Font = T.Semi,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Btn.ZIndex + 2,
    }, Btn)

    if opts.Description then
        U.New("TextLabel", {
            Size = UDim2.new(1,-24,0,16),
            Position = UDim2.new(0,0,0,28),
            BackgroundTransparency = 1,
            Text = opts.Description,
            TextColor3 = T.TxtMuted,
            TextSize = 11,
            Font = T.Reg,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = Btn.ZIndex + 2,
        }, Btn)
    end

    U.New("TextLabel", {
        Size = UDim2.new(0,18,1,0),
        Position = UDim2.new(1,-18,0,0),
        BackgroundTransparency = 1,
        Text = "›",
        TextColor3 = T.TxtMuted,
        TextSize = 20,
        Font = T.Bold,
        ZIndex = Btn.ZIndex + 2,
    }, Btn)

    Btn.MouseEnter:Connect(function()
        U.Fast(Btn,     { BackgroundColor3 = T.CardHover })
        U.Fast(HFill,   { BackgroundTransparency = 0.94 })
        U.Fast(Bar,     { BackgroundTransparency = 0 })
        U.Fast(stroke,  { Color = T.AccentDim, Transparency = 0.55 })
        U.Fast(MainLbl, { TextColor3 = T.TxtAccent })
    end)
    Btn.MouseLeave:Connect(function()
        U.Fast(Btn,     { BackgroundColor3 = T.Card })
        U.Fast(HFill,   { BackgroundTransparency = 1 })
        U.Fast(Bar,     { BackgroundTransparency = 1 })
        U.Fast(stroke,  { Color = T.BorderLo, Transparency = 0.88 })
        U.Fast(MainLbl, { TextColor3 = T.TxtPrimary })
    end)
    Btn.MouseButton1Down:Connect(function()
        U.Fast(Btn, { BackgroundColor3 = T.AccentBg })
    end)
    Btn.MouseButton1Up:Connect(function()
        U.Fast(Btn, { BackgroundColor3 = T.CardHover })
    end)
    Btn.MouseButton1Click:Connect(function(x, y)
        local rel = Btn.AbsolutePosition
        U.Ripple(Btn, x - rel.X, y - rel.Y)
        if opts.Callback then task.spawn(opts.Callback) end
    end)

    local api = {}
    function api:SetLabel(t) MainLbl.Text = t end
    return api
end

-- ── TOGGLE ────────────────────────────────────────────────────────────
function Comp.Toggle(parent, opts)
    local val = opts.Default == true
    local id  = newId()

    local Row = Instance.new("TextButton", parent)
    Row.Name = "Toggle"
    Row.Size = UDim2.new(1,0,0, opts.Description and 48 or 38)
    Row.BackgroundColor3 = T.Card
    Row.BorderSizePixel = 0
    Row.Text = ""
    Row.AutoButtonColor = false
    U.Corner(Row, T.RSm)
    U.Stroke(Row, T.BorderLo, 0.88, 1)
    U.Pad(Row, 0,14,0,14)

    local MainLbl = U.New("TextLabel", {
        Size = UDim2.new(1,-56,0, opts.Description and 20 or 0),
        Position = UDim2.new(0,0,0, opts.Description and 8 or 0),
        AutomaticSize = opts.Description and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = opts.Label or "Toggle",
        TextColor3 = T.TxtSecond,
        TextSize = 13,
        Font = T.Semi,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Row)

    if opts.Description then
        U.New("TextLabel", {
            Size = UDim2.new(1,-56,0,16),
            Position = UDim2.new(0,0,0,28),
            BackgroundTransparency = 1,
            Text = opts.Description,
            TextColor3 = T.TxtMuted,
            TextSize = 11,
            Font = T.Reg,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, Row)
    end

    -- Track
    local Track = Instance.new("Frame", Row)
    Track.Size = UDim2.new(0,44,0,24)
    Track.Position = UDim2.new(1,-44,0.5,-12)
    Track.BackgroundColor3 = T.Elevated
    Track.BorderSizePixel = 0
    U.Corner(Track, T.RPill)
    local tStroke = U.Stroke(Track, T.BorderLo, 0.75, 1)

    -- Knob
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0,18,0,18)
    Knob.BackgroundColor3 = T.TxtMuted
    Knob.BorderSizePixel = 0
    U.Corner(Knob, T.RPill)

    local KDot = Instance.new("Frame", Knob)
    KDot.Size = UDim2.new(0,6,0,6)
    KDot.Position = UDim2.new(0.5,-3,0.5,-3)
    KDot.BackgroundColor3 = T.Base
    KDot.BackgroundTransparency = 0.4
    KDot.BorderSizePixel = 0
    U.Corner(KDot, T.RPill)

    local function refresh(animate)
        local fn = animate and U.Fast or function(o,p) for k,v in pairs(p) do o[k]=v end end
        if val then
            fn(Track,   { BackgroundColor3 = T.AccentBg })
            fn(tStroke, { Color = T.Accent, Transparency = 0.35 })
            fn(Knob,    { Position = UDim2.new(1,-21,0.5,-9), BackgroundColor3 = T.Accent })
            fn(KDot,    { BackgroundColor3 = T.AccentGlow, BackgroundTransparency = 0 })
            fn(MainLbl, { TextColor3 = T.TxtPrimary })
        else
            fn(Track,   { BackgroundColor3 = T.Elevated })
            fn(tStroke, { Color = T.BorderLo, Transparency = 0.75 })
            fn(Knob,    { Position = UDim2.new(0,3,0.5,-9), BackgroundColor3 = T.TxtMuted })
            fn(KDot,    { BackgroundColor3 = T.Base, BackgroundTransparency = 0.4 })
            fn(MainLbl, { TextColor3 = T.TxtSecond })
        end
    end

    refresh(false)

    Row.MouseButton1Click:Connect(function()
        val = not val
        refresh(true)
        U.Bounce(Knob, { Size = UDim2.new(0,20,0,20) })
        task.delay(0.14, function() U.Fast(Knob, { Size = UDim2.new(0,18,0,18) }) end)
        if opts.Callback then task.spawn(opts.Callback, val) end
    end)

    Row.MouseEnter:Connect(function() U.Fast(Row, { BackgroundColor3 = T.CardHover }) end)
    Row.MouseLeave:Connect(function() U.Fast(Row, { BackgroundColor3 = T.Card }) end)

    local api = {}
    function api:Set(v, silent)
        val = v; refresh(true)
        if not silent and opts.Callback then task.spawn(opts.Callback, val) end
    end
    function api:Get() return val end
    ComponentRegistry[id] = { get=function() return val end, set=function(v,s) api:Set(v,s) end }
    return api
end

-- ── SLIDER ────────────────────────────────────────────────────────────
function Comp.Slider(parent, opts)
    local mn   = opts.Min      or 0
    local mx   = opts.Max      or 100
    local dec  = opts.Decimals or 0
    local suf  = opts.Suffix   or ""
    local val  = math.clamp(opts.Default or mn, mn, mx)
    local drag = false
    local id   = newId()

    local function fmt(v)
        return string.format("%." .. dec .. "f", v) .. suf
    end

    local Wrap = Instance.new("Frame", parent)
    Wrap.Name = "Slider"
    Wrap.Size = UDim2.new(1,0,0,56)
    Wrap.BackgroundColor3 = T.Card
    Wrap.BorderSizePixel = 0
    U.Corner(Wrap, T.RSm)
    U.Stroke(Wrap, T.BorderLo, 0.88, 1)
    U.Pad(Wrap, 10,14,10,14)

    local LRow = Instance.new("Frame", Wrap)
    LRow.Size = UDim2.new(1,0,0,18)
    LRow.BackgroundTransparency = 1

    U.New("TextLabel", {
        Size = UDim2.new(0.6,0,1,0),
        BackgroundTransparency = 1,
        Text = opts.Label or "Slider",
        TextColor3 = T.TxtSecond,
        TextSize = 12,
        Font = T.Semi,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, LRow)

    -- Monospaced value readout
    local VBox = Instance.new("Frame", LRow)
    VBox.Size = UDim2.new(0,62,0,18)
    VBox.Position = UDim2.new(1,-62,0,0)
    VBox.BackgroundColor3 = T.Elevated
    VBox.BorderSizePixel = 0
    U.Corner(VBox, T.RXs)
    local ValLbl = U.New("TextLabel", {
        Size = UDim2.new(1,-6,1,0),
        Position = UDim2.new(0,3,0,0),
        BackgroundTransparency = 1,
        Text = fmt(val),
        TextColor3 = T.TxtAccent,
        TextSize = 11,
        Font = T.Mono,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, VBox)

    -- Track
    local TrackBg = Instance.new("Frame", Wrap)
    TrackBg.Size = UDim2.new(1,0,0,4)
    TrackBg.Position = UDim2.new(0,0,1,-10)
    TrackBg.BackgroundColor3 = T.Elevated
    TrackBg.BorderSizePixel = 0
    U.Corner(TrackBg, T.RPill)

    local Fill = Instance.new("Frame", TrackBg)
    Fill.BackgroundColor3 = T.Accent
    Fill.BorderSizePixel = 0
    U.Corner(Fill, T.RPill)
    U.Grad(Fill, { {0, T.AccentGlow}, {1, T.AccentDim} })

    -- Thumb
    local Thumb = Instance.new("Frame", TrackBg)
    Thumb.Size = UDim2.new(0,14,0,14)
    Thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Thumb.BorderSizePixel = 0
    Thumb.ZIndex = TrackBg.ZIndex + 3
    U.Corner(Thumb, T.RPill)
    local tStroke = U.Stroke(Thumb, T.Accent, 0.15, 2)

    local ThumbGlow = Instance.new("Frame", TrackBg)
    ThumbGlow.Size = UDim2.new(0,20,0,20)
    ThumbGlow.BackgroundColor3 = T.Accent
    ThumbGlow.BackgroundTransparency = 1
    ThumbGlow.BorderSizePixel = 0
    ThumbGlow.ZIndex = TrackBg.ZIndex + 2
    U.Corner(ThumbGlow, T.RPill)

    local function setVis(v)
        local pct = (v - mn) / (mx - mn)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        Thumb.Position = UDim2.new(pct, -7, 0.5, -7)
        ThumbGlow.Position = UDim2.new(pct, -10, 0.5, -10)
        ValLbl.Text = fmt(v)
    end

    setVis(val)

    local function fromX(ix)
        local abs = TrackBg.AbsolutePosition.X
        local w   = TrackBg.AbsoluteSize.X
        local pct = math.clamp((ix - abs) / w, 0, 1)
        local raw = mn + pct * (mx - mn)
        local f   = 10 ^ dec
        val = math.floor(raw * f + 0.5) / f
        setVis(val)
        if opts.Callback then opts.Callback(val) end
    end

    local Hit = Instance.new("TextButton", Wrap)
    Hit.Size = UDim2.new(1,0,0,22)
    Hit.Position = UDim2.new(0,0,1,-16)
    Hit.BackgroundTransparency = 1
    Hit.Text = ""
    Hit.ZIndex = Thumb.ZIndex + 1

    Hit.MouseButton1Down:Connect(function(x)
        drag = true
        U.Fast(Thumb, { Size = UDim2.new(0,18,0,18), Position = UDim2.new((val-mn)/(mx-mn),-9,0.5,-9) })
        U.Fast(ThumbGlow, { BackgroundTransparency = 0.75 })
        U.Fast(tStroke, { Transparency = 0 })
        fromX(x)
    end)

    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then fromX(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and drag then
            drag = false
            U.Fast(Thumb, { Size = UDim2.new(0,14,0,14) })
            setVis(val)
            U.Fast(ThumbGlow, { BackgroundTransparency = 1 })
            U.Fast(tStroke, { Transparency = 0.15 })
        end
    end)

    local api = {}
    function api:Set(v, silent)
        val = math.clamp(v, mn, mx); setVis(val)
        if not silent and opts.Callback then opts.Callback(val) end
    end
    function api:Get() return val end
    ComponentRegistry[id] = { get=function() return val end, set=function(v,s) api:Set(v,s) end }
    return api
end

-- ── INPUT ─────────────────────────────────────────────────────────────
function Comp.Input(parent, opts)
    local val = opts.Default or ""
    local id  = newId()

    local Wrap = Instance.new("Frame", parent)
    Wrap.Name = "Input"
    Wrap.Size = UDim2.new(1,0,0,54)
    Wrap.BackgroundColor3 = T.Card
    Wrap.BorderSizePixel = 0
    U.Corner(Wrap, T.RSm)
    local wStroke = U.Stroke(Wrap, T.BorderLo, 0.88, 1)
    U.Pad(Wrap, 8,14,8,14)

    U.New("TextLabel", {
        Size = UDim2.new(1,0,0,14),
        BackgroundTransparency = 1,
        Text = (opts.Label or "Input"):upper(),
        TextColor3 = T.TxtMuted,
        TextSize = 9,
        Font = T.Bold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Wrap)

    local BoxBg = Instance.new("Frame", Wrap)
    BoxBg.Size = UDim2.new(1,0,0,22)
    BoxBg.Position = UDim2.new(0,0,1,-22)
    BoxBg.BackgroundColor3 = T.Base
    BoxBg.BorderSizePixel = 0
    U.Corner(BoxBg, T.RXs)

    local Box = Instance.new("TextBox", BoxBg)
    Box.Size = UDim2.new(1,-8,1,0)
    Box.Position = UDim2.new(0,4,0,0)
    Box.BackgroundTransparency = 1
    Box.Text = val
    Box.PlaceholderText = opts.Placeholder or "Enter value..."
    Box.PlaceholderColor3 = T.TxtMuted
    Box.TextColor3 = T.TxtPrimary
    Box.TextSize = 12
    Box.Font = T.Reg
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.ClearTextOnFocus = false

    Box.Focused:Connect(function()
        U.Fast(wStroke, { Color = T.Accent, Transparency = 0.3 })
        U.Fast(BoxBg,   { BackgroundColor3 = T.AccentBg })
    end)
    Box.FocusLost:Connect(function(enter)
        U.Fast(wStroke, { Color = T.BorderLo, Transparency = 0.88 })
        U.Fast(BoxBg,   { BackgroundColor3 = T.Base })
        val = Box.Text
        if opts.Callback then opts.Callback(val, enter) end
    end)

    local api = {}
    function api:Set(v) Box.Text = v; val = v end
    function api:Get() return val end
    ComponentRegistry[id] = { get=function() return val end, set=function(v,_) api:Set(v) end }
    return api
end

-- ── DROPDOWN ──────────────────────────────────────────────────────────
function Comp.Dropdown(parent, opts)
    local options  = opts.Options or {}
    local multi    = opts.Multi == true
    local selected = {}
    local open     = false
    local id       = newId()
    local ITEM_H   = 32

    if opts.Default then
        if multi and type(opts.Default) == "table" then
            for _, v in ipairs(opts.Default) do selected[v] = true end
        elseif not multi then
            selected[opts.Default] = true
        end
    elseif #options > 0 and not multi then
        selected[options[1]] = true
    end

    local function display()
        local keys = {}
        for k in pairs(selected) do keys[#keys+1] = k end
        if #keys == 0 then return "None"
        elseif #keys == 1 then return keys[1]
        else return #keys .. " selected" end
    end

    local Container = Instance.new("Frame", parent)
    Container.Name = "Dropdown"
    Container.Size = UDim2.new(1,0,0,38)
    Container.BackgroundTransparency = 1
    Container.ClipsDescendants = false

    local Hdr = Instance.new("TextButton", Container)
    Hdr.Size = UDim2.new(1,0,0,38)
    Hdr.BackgroundColor3 = T.Card
    Hdr.BorderSizePixel = 0
    Hdr.Text = ""
    Hdr.AutoButtonColor = false
    Hdr.ZIndex = 2
    U.Corner(Hdr, T.RSm)
    local hStroke = U.Stroke(Hdr, T.BorderLo, 0.88, 1)
    U.Pad(Hdr, 0,14,0,14)

    U.New("TextLabel", {
        Size = UDim2.new(0.5,0,1,0),
        BackgroundTransparency = 1,
        Text = opts.Label or "Dropdown",
        TextColor3 = T.TxtSecond,
        TextSize = 12,
        Font = T.Semi,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, Hdr)

    local ValLbl = U.New("TextLabel", {
        Size = UDim2.new(0.4,0,1,0),
        Position = UDim2.new(0.5,0,0,0),
        BackgroundTransparency = 1,
        Text = display(),
        TextColor3 = T.TxtAccent,
        TextSize = 12,
        Font = T.Bold,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 3,
    }, Hdr)

    local Chev = U.New("TextLabel", {
        Size = UDim2.new(0,18,1,0),
        Position = UDim2.new(1,-18,0,0),
        BackgroundTransparency = 1,
        Text = "⌄",
        TextColor3 = T.TxtMuted,
        TextSize = 15,
        Font = T.Bold,
        ZIndex = 3,
    }, Hdr)

    local panelH = math.min(#options, 5) * ITEM_H + 8

    local Panel = Instance.new("Frame", Container)
    Panel.Size = UDim2.new(1,0,0,0)
    Panel.Position = UDim2.new(0,0,0,42)
    Panel.BackgroundColor3 = T.Panel
    Panel.BorderSizePixel = 0
    Panel.ClipsDescendants = true
    Panel.ZIndex = 20
    U.Corner(Panel, T.RSm)
    U.Stroke(Panel, T.Accent, 0.55, 1)

    local Scroll = Instance.new("ScrollingFrame", Panel)
    Scroll.Size = UDim2.new(1,0,1,0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 2
    Scroll.ScrollBarImageColor3 = T.Accent
    Scroll.ZIndex = 21
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    U.Pad(Scroll, 4,4,4,4)
    U.List(Scroll, Enum.FillDirection.Vertical, 2)

    local function rebuild()
        for _, c in ipairs(Scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, opt in ipairs(options) do
            local isSel = selected[opt]
            local OBtn = Instance.new("TextButton", Scroll)
            OBtn.Name = opt
            OBtn.Size = UDim2.new(1,0,0,ITEM_H)
            OBtn.BackgroundColor3 = isSel and T.AccentBg or T.Card
            OBtn.BackgroundTransparency = isSel and 0 or 1
            OBtn.BorderSizePixel = 0
            OBtn.Text = ""
            OBtn.AutoButtonColor = false
            OBtn.ZIndex = 22
            U.Corner(OBtn, T.RXs)

            if isSel then
                local bar = Instance.new("Frame", OBtn)
                bar.Size = UDim2.new(0,2,0.5,0)
                bar.Position = UDim2.new(0,0,0.25,0)
                bar.BackgroundColor3 = T.Accent
                bar.BorderSizePixel = 0
                U.Corner(bar, T.RPill)
            end

            U.New("TextLabel", {
                Size = UDim2.new(1,-32,1,0),
                Position = UDim2.new(0,10,0,0),
                BackgroundTransparency = 1,
                Text = opt,
                TextColor3 = isSel and T.TxtAccent or T.TxtSecond,
                TextSize = 12,
                Font = isSel and T.Bold or T.Reg,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 23,
            }, OBtn)

            if isSel then
                U.New("TextLabel", {
                    Size = UDim2.new(0,20,1,0),
                    Position = UDim2.new(1,-22,0,0),
                    BackgroundTransparency = 1,
                    Text = "✓",
                    TextColor3 = T.Accent,
                    TextSize = 12,
                    Font = T.Bold,
                    ZIndex = 23,
                }, OBtn)
            end

            OBtn.MouseEnter:Connect(function()
                if not selected[opt] then
                    U.Fast(OBtn, { BackgroundTransparency = 0.7, BackgroundColor3 = T.Elevated })
                end
            end)
            OBtn.MouseLeave:Connect(function()
                if not selected[opt] then
                    U.Fast(OBtn, { BackgroundTransparency = 1 })
                end
            end)
            OBtn.MouseButton1Click:Connect(function()
                if multi then
                    if selected[opt] then selected[opt] = nil else selected[opt] = true end
                else
                    selected = { [opt] = true }
                end
                ValLbl.Text = display()
                rebuild()

                local val
                if multi then
                    val = {}
                    for k in pairs(selected) do val[#val+1] = k end
                else
                    for k in pairs(selected) do val = k break end
                end

                if opts.Callback then task.spawn(opts.Callback, val) end
                if not multi then
                    open = true
                    Hdr.MouseButton1Click:Fire()
                end
            end)
        end
        local total = #options * (ITEM_H + 2) + 8
        Scroll.CanvasSize = UDim2.new(0,0,0,total)
    end

    rebuild()

    local function toggle()
        open = not open
        if open then
            U.Fast(hStroke, { Color = T.Accent, Transparency = 0.35 })
            U.Med(Panel,     { Size = UDim2.new(1,0,0,panelH) })
            U.Med(Container, { Size = UDim2.new(1,0,0,38+panelH+4) })
            U.Fast(Chev,     { Rotation = 180 })
        else
            U.Fast(hStroke, { Color = T.BorderLo, Transparency = 0.88 })
            U.Med(Panel,     { Size = UDim2.new(1,0,0,0) })
            U.Med(Container, { Size = UDim2.new(1,0,0,38) })
            U.Fast(Chev,     { Rotation = 0 })
        end
    end

    Hdr.MouseButton1Click:Connect(toggle)
    Hdr.MouseEnter:Connect(function() U.Fast(Hdr, { BackgroundColor3 = T.CardHover }) end)
    Hdr.MouseLeave:Connect(function() U.Fast(Hdr, { BackgroundColor3 = T.Card }) end)

    local api = {}
    function api:Set(v, silent)
        selected = {}
        if multi and type(v) == "table" then
            for _, x in ipairs(v) do selected[x] = true end
        else selected[v] = true end
        ValLbl.Text = display()
        rebuild()
        if not silent and opts.Callback then opts.Callback(v) end
    end
    function api:Get()
        if multi then local t={}; for k in pairs(selected) do t[#t+1]=k end return t end
        for k in pairs(selected) do return k end
    end
    function api:SetOptions(newOpts)
        options = newOpts; selected = {}
        ValLbl.Text = display()
        panelH = math.min(#options,5) * ITEM_H + 8
        rebuild()
        if open then
            Panel.Size = UDim2.new(1,0,0,panelH)
            Container.Size = UDim2.new(1,0,0,38+panelH+4)
        end
    end
    ComponentRegistry[id] = {
        get = function() return api:Get() end,
        set = function(v,s) api:Set(v,s) end,
    }
    return api
end

-- ── KEYBIND ───────────────────────────────────────────────────────────
function Comp.Keybind(parent, opts)
    local key     = opts.Default or Enum.KeyCode.Unknown
    local binding = false
    local id      = newId()

    local function kname(k)
        return tostring(k):gsub("Enum%.KeyCode%.","")
    end

    local Row = Instance.new("Frame", parent)
    Row.Name = "Keybind"
    Row.Size = UDim2.new(1,0,0,38)
    Row.BackgroundColor3 = T.Card
    Row.BorderSizePixel = 0
    U.Corner(Row, T.RSm)
    U.Stroke(Row, T.BorderLo, 0.88, 1)
    U.Pad(Row, 0,14,0,14)

    U.New("TextLabel", {
        Size = UDim2.new(0.6,0,1,0),
        BackgroundTransparency = 1,
        Text = opts.Label or "Keybind",
        TextColor3 = T.TxtSecond,
        TextSize = 12,
        Font = T.Semi,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Row)

    local Pill = Instance.new("TextButton", Row)
    Pill.Size = UDim2.new(0,84,0,24)
    Pill.Position = UDim2.new(1,-84,0.5,-12)
    Pill.BackgroundColor3 = T.Elevated
    Pill.BorderSizePixel = 0
    Pill.Text = kname(key)
    Pill.TextColor3 = T.TxtAccent
    Pill.TextSize = 11
    Pill.Font = T.Mono
    Pill.AutoButtonColor = false
    U.Corner(Pill, T.RXs)
    local pStroke = U.Stroke(Pill, T.Accent, 0.55, 1)

    Pill.MouseButton1Click:Connect(function()
        if binding then return end
        binding = true
        Pill.Text = "· · ·"
        U.Fast(Pill,    { BackgroundColor3 = T.AccentBg, TextColor3 = T.AccentGlow })
        U.Fast(pStroke, { Transparency = 0.1 })

        local conn
        conn = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if inp.KeyCode == Enum.KeyCode.Unknown then return end
            conn:Disconnect()
            key = inp.KeyCode
            binding = false
            Pill.Text = kname(key)
            U.Fast(Pill,    { BackgroundColor3 = T.Elevated, TextColor3 = T.TxtAccent })
            U.Fast(pStroke, { Transparency = 0.55 })
            if opts.Callback then task.spawn(opts.Callback, key) end
        end)
    end)

    Pill.MouseEnter:Connect(function()
        if not binding then U.Fast(Pill, { BackgroundColor3 = T.ElevatedHi }) end
    end)
    Pill.MouseLeave:Connect(function()
        if not binding then U.Fast(Pill, { BackgroundColor3 = T.Elevated }) end
    end)

    local api = {}
    function api:Get() return key end
    function api:Set(k) key = k; Pill.Text = kname(k) end
    ComponentRegistry[id] = { get=function() return tostring(key) end, set=function() end }
    return api
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION
-- ════════════════════════════════════════════════════════════════════
local SectionMeta = {}
SectionMeta.__index = SectionMeta
function SectionMeta:CreateButton(o)    return Comp.Button(self._c, o)    end
function SectionMeta:CreateToggle(o)    return Comp.Toggle(self._c, o)    end
function SectionMeta:CreateSlider(o)    return Comp.Slider(self._c, o)    end
function SectionMeta:CreateInput(o)     return Comp.Input(self._c, o)     end
function SectionMeta:CreateDropdown(o)  return Comp.Dropdown(self._c, o)  end
function SectionMeta:CreateKeybind(o)   return Comp.Keybind(self._c, o)   end
function SectionMeta:CreateLabel(o)     return Comp.Label(self._c, o)     end
function SectionMeta:CreateSeparator(l) return Comp.Separator(self._c, l) end

-- ════════════════════════════════════════════════════════════════════
-- TAB META
-- ════════════════════════════════════════════════════════════════════
local TabMeta = {}
TabMeta.__index = TabMeta

function TabMeta:CreateSection(name)
    local Outer = Instance.new("Frame", self._scroll)
    Outer.Name = name or "Section"
    Outer.Size = UDim2.new(1,0,0,0)
    Outer.BackgroundTransparency = 1

    local OL = U.List(Outer, Enum.FillDirection.Vertical, 0)

    -- Header
    local Hdr = Instance.new("Frame", Outer)
    Hdr.Size = UDim2.new(1,0,0,26)
    Hdr.BackgroundTransparency = 1
    Hdr.LayoutOrder = 0

    -- Cyan pip
    local pip = Instance.new("Frame", Hdr)
    pip.Size = UDim2.new(0,2,0,12)
    pip.Position = UDim2.new(0,0,0.5,-6)
    pip.BackgroundColor3 = T.Accent
    pip.BorderSizePixel = 0
    U.Corner(pip, T.RPill)

    U.New("TextLabel", {
        Size = UDim2.new(1,-10,1,0),
        Position = UDim2.new(0,10,0,0),
        BackgroundTransparency = 1,
        Text = (name or "Section"):upper(),
        TextColor3 = T.TxtMuted,
        TextSize = 10,
        Font = T.Bold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Hdr)

    -- Rule below header
    local rule = Instance.new("Frame", Hdr)
    rule.Size = UDim2.new(1,0,0,1)
    rule.Position = UDim2.new(0,0,1,-1)
    rule.BackgroundColor3 = T.BorderLo
    rule.BackgroundTransparency = 0.88
    rule.BorderSizePixel = 0

    -- Content
    local Content = Instance.new("Frame", Outer)
    Content.Name = "Content"
    Content.Size = UDim2.new(1,0,0,0)
    Content.BackgroundTransparency = 1
    Content.LayoutOrder = 1
    local CL = U.List(Content, Enum.FillDirection.Vertical, 4)
    U.AutoHeight(Content, CL, 0)

    -- Bottom spacer
    local spacer = Instance.new("Frame", Outer)
    spacer.Size = UDim2.new(1,0,0,12)
    spacer.BackgroundTransparency = 1
    spacer.LayoutOrder = 2

    U.AutoHeight(Outer, OL, 0)

    return setmetatable({ _c = Content }, SectionMeta)
end

-- ════════════════════════════════════════════════════════════════════
-- WINDOW FACTORY
-- ════════════════════════════════════════════════════════════════════
local function BuildWindow(config)
    config = config or {}
    local W  = config.Size and config.Size.X.Offset or 600
    local H  = config.Size and config.Size.Y.Offset or 440
    local sp = config.Position or UDim2.new(0.5,-W/2,0.5,-H/2)

    local SIDEBAR_W  = 44    -- icon-only strip
    local NAMES_W    = 148   -- icon + name panel total width

    -- ── ROOT GUI ─────────────────────────────────────────────────────
    local SG = Instance.new("ScreenGui")
    SG.Name = "Nova_" .. (config.Title or "UI")
    SG.ResetOnSpawn = false
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SG.IgnoreGuiInset = true
    SG.Parent = PGui

    -- ── SHADOW ───────────────────────────────────────────────────────
    local Shadow = Instance.new("Frame", SG)
    Shadow.Size = UDim2.new(0, W+56, 0, H+56)
    Shadow.Position = UDim2.new(sp.X.Scale, sp.X.Offset-28, sp.Y.Scale, sp.Y.Offset-28)
    Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Shadow.BackgroundTransparency = 0.42
    Shadow.BorderSizePixel = 0
    Shadow.ZIndex = 0
    U.Corner(Shadow, UDim.new(0,18))

    -- ── MAIN FRAME ───────────────────────────────────────────────────
    local Win = Instance.new("Frame", SG)
    Win.Name = "Window"
    Win.Size = UDim2.new(0, W, 0, H)
    Win.Position = sp
    Win.BackgroundColor3 = T.Base
    Win.BorderSizePixel = 0
    Win.ClipsDescendants = true
    U.Corner(Win, T.RLg)
    U.Stroke(Win, T.Accent, 0.70, 1)

    -- Background gradient
    U.Grad(Win, {
        {0,   T.Surface},
        {0.5, T.Base},
        {1,   Color3.fromRGB(5,5,9)},
    }, 155)

    -- ── TOP ACCENT RULE ──────────────────────────────────────────────
    local TopRule = Instance.new("Frame", Win)
    TopRule.Size = UDim2.new(1,0,0,1)
    TopRule.BackgroundColor3 = T.Accent
    TopRule.BackgroundTransparency = 0.25
    TopRule.BorderSizePixel = 0
    TopRule.ZIndex = 10

    -- Soft glow bloom under the top rule
    local TopGlow = Instance.new("Frame", Win)
    TopGlow.Size = UDim2.new(0.5,0,0,20)
    TopGlow.Position = UDim2.new(0.25,0,0,0)
    TopGlow.BackgroundColor3 = T.Accent
    TopGlow.BackgroundTransparency = 0.88
    TopGlow.BorderSizePixel = 0
    TopGlow.ZIndex = 9
    U.Grad(TopGlow, {
        {0,   Color3.fromRGB(0,0,0)},
        {0.5, T.Accent},
        {1,   Color3.fromRGB(0,0,0)},
    })

    -- ── TITLEBAR ─────────────────────────────────────────────────────
    local TBar = Instance.new("Frame", Win)
    TBar.Name = "TitleBar"
    TBar.Size = UDim2.new(1,0,0,48)
    TBar.BackgroundColor3 = T.Panel
    TBar.BorderSizePixel = 0
    TBar.ZIndex = 5

    -- Titlebar bottom hairline
    local TRule = Instance.new("Frame", TBar)
    TRule.Size = UDim2.new(1,0,0,1)
    TRule.Position = UDim2.new(0,0,1,-1)
    TRule.BackgroundColor3 = T.BorderLo
    TRule.BackgroundTransparency = 0.82
    TRule.BorderSizePixel = 0

    -- Logo mark
    local Logo = Instance.new("Frame", TBar)
    Logo.Size = UDim2.new(0,22,0,22)
    Logo.Position = UDim2.new(0,11,0.5,-11)
    Logo.BackgroundColor3 = T.Accent
    Logo.BorderSizePixel = 0
    U.Corner(Logo, T.RXs)
    U.Grad(Logo, { {0,T.AccentGlow}, {1,T.AccentDim} }, 135)
    U.New("TextLabel", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = "◆",
        TextColor3 = T.Base,
        TextSize = 10,
        Font = T.Bold,
    }, Logo)

    -- Title + subtitle
    local TitleLbl = U.New("TextLabel", {
        Size = UDim2.new(0,170,0,20),
        Position = UDim2.new(0, SIDEBAR_W+4, 0.5,-16),
        BackgroundTransparency = 1,
        Text = config.Title or "Nova",
        TextColor3 = T.TxtPrimary,
        TextSize = 14,
        Font = T.Bold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, TBar)

    local SubLbl = U.New("TextLabel", {
        Size = UDim2.new(0,170,0,13),
        Position = UDim2.new(0, SIDEBAR_W+4, 0.5,4),
        BackgroundTransparency = 1,
        Text = config.SubTitle or "",
        TextColor3 = T.TxtMuted,
        TextSize = 10,
        Font = T.Mono,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, TBar)

    -- ── SEARCH ───────────────────────────────────────────────────────
    local SWrap = Instance.new("Frame", TBar)
    SWrap.Size = UDim2.new(0,155,0,26)
    SWrap.Position = UDim2.new(0.5,-77,0.5,-13)
    SWrap.BackgroundColor3 = T.Elevated
    SWrap.BorderSizePixel = 0
    SWrap.ZIndex = 6
    U.Corner(SWrap, T.RSm)
    local sStroke = U.Stroke(SWrap, T.BorderLo, 0.80, 1)

    U.New("TextLabel", {
        Size = UDim2.new(0,16,1,0),
        Position = UDim2.new(0,6,0,0),
        BackgroundTransparency = 1,
        Text = "⌕",
        TextColor3 = T.TxtMuted,
        TextSize = 13,
        Font = T.Bold,
        ZIndex = 7,
    }, SWrap)

    local SBox = Instance.new("TextBox", SWrap)
    SBox.Size = UDim2.new(1,-24,1,0)
    SBox.Position = UDim2.new(0,22,0,0)
    SBox.BackgroundTransparency = 1
    SBox.Text = ""
    SBox.PlaceholderText = "Search..."
    SBox.PlaceholderColor3 = T.TxtMuted
    SBox.TextColor3 = T.TxtPrimary
    SBox.TextSize = 12
    SBox.Font = T.Reg
    SBox.TextXAlignment = Enum.TextXAlignment.Left
    SBox.ClearTextOnFocus = false
    SBox.ZIndex = 7

    SBox.Focused:Connect(function()
        U.Fast(sStroke, { Color = T.Accent, Transparency = 0.35 })
    end)
    SBox.FocusLost:Connect(function()
        U.Fast(sStroke, { Color = T.BorderLo, Transparency = 0.80 })
    end)
    SBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = SBox.Text:lower()
        for _, pg in ipairs(SG:GetDescendants()) do
            if pg.Name:find("_Page") then
                for _, sec in ipairs(pg:GetDescendants()) do
                    if sec.Name == "Content" then
                        for _, comp in ipairs(sec:GetChildren()) do
                            if comp:IsA("Frame") or comp:IsA("TextButton") then
                                local lbl = comp:FindFirstChildWhichIsA("TextLabel")
                                comp.Visible = (q == "") or
                                    (lbl and lbl.Text:lower():find(q, 1, true) ~= nil) or false
                            end
                        end
                    end
                end
            end
        end
    end)

    -- ── WINDOW CONTROLS ──────────────────────────────────────────────
    local minimized = false

    local function makeCtrl(col, xOff, sym, fn)
        local B = Instance.new("TextButton", TBar)
        B.Size = UDim2.new(0,13,0,13)
        B.Position = UDim2.new(1,-xOff,0.5,-6)
        B.BackgroundColor3 = col
        B.BackgroundTransparency = 0.15
        B.BorderSizePixel = 0
        B.Text = ""
        B.AutoButtonColor = false
        B.ZIndex = 6
        U.Corner(B, T.RPill)
        local sl = U.New("TextLabel", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Text = sym,
            TextColor3 = T.Base,
            TextTransparency = 1,
            TextSize = 8,
            Font = T.Bold,
            ZIndex = 7,
        }, B)
        B.MouseEnter:Connect(function()
            U.Fast(B,  { BackgroundTransparency = 0 })
            U.Fast(sl, { TextTransparency = 0 })
        end)
        B.MouseLeave:Connect(function()
            U.Fast(B,  { BackgroundTransparency = 0.15 })
            U.Fast(sl, { TextTransparency = 1 })
        end)
        B.MouseButton1Click:Connect(fn)
    end

    makeCtrl(T.Danger,  28, "✕", function()
        U.Fast(Win,    { BackgroundTransparency = 1 })
        U.Fast(Shadow, { BackgroundTransparency = 1 })
        task.delay(0.18, function() SG:Destroy() end)
    end)
    makeCtrl(T.Warning, 46, "−", function()
        minimized = not minimized
        U.Med(Win, { Size = minimized and UDim2.new(0,W,0,48) or UDim2.new(0,W,0,H) })
    end)

    -- ── SIDEBAR (icon strip) ──────────────────────────────────────────
    local Sidebar = Instance.new("Frame", Win)
    Sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -48)
    Sidebar.Position = UDim2.new(0,0,0,48)
    Sidebar.BackgroundColor3 = T.Surface
    Sidebar.BorderSizePixel = 0
    U.Grad(Sidebar, { {0,T.Panel}, {1,T.Base} }, 180)

    local SideRule = Instance.new("Frame", Sidebar)
    SideRule.Size = UDim2.new(0,1,1,0)
    SideRule.Position = UDim2.new(1,-1,0,0)
    SideRule.BackgroundColor3 = T.BorderLo
    SideRule.BackgroundTransparency = 0.88
    SideRule.BorderSizePixel = 0

    local IconFrame = Instance.new("Frame", Sidebar)
    IconFrame.Size = UDim2.new(1,0,1,0)
    IconFrame.BackgroundTransparency = 1
    local IconLayout = U.List(IconFrame, Enum.FillDirection.Vertical, 4,
        Enum.HorizontalAlignment.Center)
    U.Pad(IconFrame, 8,0,8,0)

    -- ── NAME SIDEBAR ─────────────────────────────────────────────────
    local NameSide = Instance.new("Frame", Win)
    NameSide.Size = UDim2.new(0, NAMES_W - SIDEBAR_W, 1, -48)
    NameSide.Position = UDim2.new(0, SIDEBAR_W, 0, 48)
    NameSide.BackgroundColor3 = T.Panel
    NameSide.BorderSizePixel = 0
    U.Grad(NameSide, { {0,T.Panel}, {1,T.Base} }, 180)

    local NRule = Instance.new("Frame", NameSide)
    NRule.Size = UDim2.new(0,1,1,0)
    NRule.Position = UDim2.new(1,-1,0,0)
    NRule.BackgroundColor3 = T.BorderLo
    NRule.BackgroundTransparency = 0.88
    NRule.BorderSizePixel = 0

    local NameFrame = Instance.new("Frame", NameSide)
    NameFrame.Size = UDim2.new(1,0,1,0)
    NameFrame.BackgroundTransparency = 1
    local NameLayout = U.List(NameFrame, Enum.FillDirection.Vertical, 4,
        Enum.HorizontalAlignment.Left)
    U.Pad(NameFrame, 8,0,8,6)

    -- ── CONTENT AREA ─────────────────────────────────────────────────
    local ContentArea = Instance.new("Frame", Win)
    ContentArea.Size = UDim2.new(0, W - NAMES_W, 1, -48)
    ContentArea.Position = UDim2.new(0, NAMES_W, 0, 48)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = true

    -- ── NOTIFICATION STACK ───────────────────────────────────────────
    _notifStack = Instance.new("Frame", SG)
    _notifStack.Name = "NotifStack"
    _notifStack.Size = UDim2.new(0,285,1,0)
    _notifStack.Position = UDim2.new(1,-300,0,0)
    _notifStack.BackgroundTransparency = 1
    U.Pad(_notifStack, 16,0,16,0)
    U.List(_notifStack, Enum.FillDirection.Vertical, 8,
        Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)

    -- ── DRAG ─────────────────────────────────────────────────────────
    do
        local dragging, ds, sp2
        TBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; ds = i.Position; sp2 = Win.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d  = i.Position - ds
                local np = UDim2.new(sp2.X.Scale, sp2.X.Offset+d.X, sp2.Y.Scale, sp2.Y.Offset+d.Y)
                Win.Position    = np
                Shadow.Position = UDim2.new(np.X.Scale, np.X.Offset-28, np.Y.Scale, np.Y.Offset-28)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end

    -- ── TOGGLE KEY ───────────────────────────────────────────────────
    if config.Key then
        UserInputService.InputBegan:Connect(function(i, gpe)
            if gpe then return end
            if i.KeyCode == config.Key then
                Win.Visible    = not Win.Visible
                Shadow.Visible = Win.Visible
            end
        end)
    end

    -- ── TAB SYSTEM ───────────────────────────────────────────────────
    local tabs      = {}
    local activeTab = nil

    local function switchTab(tabObj)
        if activeTab == tabObj then return end
        if activeTab then
            U.Fast(activeTab._iBtn, { BackgroundTransparency = 1 })
            U.Fast(activeTab._iLbl, { TextColor3 = T.TxtMuted })
            U.Fast(activeTab._nBtn, { BackgroundTransparency = 1 })
            U.Fast(activeTab._nLbl, { TextColor3 = T.TxtMuted, Font = T.Reg })
            activeTab._bar.BackgroundTransparency = 1
            activeTab._page.Visible = false
        end
        activeTab = tabObj
        U.Fast(tabObj._iBtn, { BackgroundColor3 = T.AccentBg, BackgroundTransparency = 0 })
        U.Fast(tabObj._iLbl, { TextColor3 = T.Accent })
        U.Fast(tabObj._nBtn, { BackgroundColor3 = T.AccentBg, BackgroundTransparency = 0 })
        U.Fast(tabObj._nLbl, { TextColor3 = T.TxtAccent, Font = T.Bold })
        tabObj._bar.BackgroundTransparency = 0
        tabObj._page.Visible = true
    end

    -- ── WINDOW API ───────────────────────────────────────────────────
    local winAPI = {}

    function winAPI:CreateTab(name, icon)
        -- Icon button
        local IBtn = Instance.new("TextButton", IconFrame)
        IBtn.Size = UDim2.new(0,30,0,30)
        IBtn.BackgroundColor3 = T.AccentBg
        IBtn.BackgroundTransparency = 1
        IBtn.BorderSizePixel = 0
        IBtn.Text = ""
        IBtn.AutoButtonColor = false
        U.Corner(IBtn, T.RSm)

        -- Active left bar
        local Bar = Instance.new("Frame", IBtn)
        Bar.Size = UDim2.new(0,2,0.6,0)
        Bar.Position = UDim2.new(0,0,0.2,0)
        Bar.BackgroundColor3 = T.Accent
        Bar.BackgroundTransparency = 1
        Bar.BorderSizePixel = 0
        U.Corner(Bar, T.RPill)

        local ILbl = U.New("TextLabel", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Text = U.Icon(icon or "misc"),
            TextColor3 = T.TxtMuted,
            TextSize = 15,
            Font = T.Bold,
        }, IBtn)

        -- Name button
        local NBtn = Instance.new("TextButton", NameFrame)
        NBtn.Size = UDim2.new(1,0,0,30)
        NBtn.BackgroundColor3 = T.AccentBg
        NBtn.BackgroundTransparency = 1
        NBtn.BorderSizePixel = 0
        NBtn.Text = ""
        NBtn.AutoButtonColor = false
        U.Corner(NBtn, T.RXs)

        local NLbl = U.New("TextLabel", {
            Size = UDim2.new(1,-6,1,0),
            Position = UDim2.new(0,3,0,0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = T.TxtMuted,
            TextSize = 12,
            Font = T.Reg,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, NBtn)

        -- Page (scrolling)
        local Page = Instance.new("ScrollingFrame", ContentArea)
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = T.Accent
        Page.ScrollBarImageTransparency = 0.35
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.Visible = false
        Page.ScrollingEnabled = true
        U.Pad(Page, 12,14,16,14)

        local PL = U.List(Page, Enum.FillDirection.Vertical, 6)
        U.AutoCanvas(Page, PL, 24)

        local tabObj = {
            _iBtn = IBtn, _iLbl = ILbl,
            _nBtn = NBtn, _nLbl = NLbl,
            _bar  = Bar,  _page = Page,
            _scroll = Page,
        }
        setmetatable(tabObj, TabMeta)
        tabs[#tabs+1] = tabObj

        local function activate() switchTab(tabObj) end
        IBtn.MouseButton1Click:Connect(activate)
        NBtn.MouseButton1Click:Connect(activate)

        IBtn.MouseEnter:Connect(function()
            if activeTab ~= tabObj then
                U.Fast(IBtn, { BackgroundColor3 = T.Elevated, BackgroundTransparency = 0 })
            end
        end)
        IBtn.MouseLeave:Connect(function()
            if activeTab ~= tabObj then
                U.Fast(IBtn, { BackgroundTransparency = 1 })
            end
        end)
        NBtn.MouseEnter:Connect(function()
            if activeTab ~= tabObj then
                U.Fast(NBtn, { BackgroundColor3 = T.Elevated, BackgroundTransparency = 0 })
            end
        end)
        NBtn.MouseLeave:Connect(function()
            if activeTab ~= tabObj then
                U.Fast(NBtn, { BackgroundTransparency = 1 })
            end
        end)

        if #tabs == 1 then switchTab(tabObj) end
        return tabObj
    end

    function winAPI:Notify(opts)   fireNotif(opts) end
    function winAPI:SaveConfig(s)
        saveConfig(s or "default")
        fireNotif({ Title="Config Saved", Message="Slot: "..(s or "default"),
            Type="success", Duration=3 })
    end
    function winAPI:LoadConfig(s)
        loadConfig(s or "default")
        fireNotif({ Title="Config Loaded", Message="Slot: "..(s or "default"),
            Type="info", Duration=3 })
    end
    function winAPI:SetTitle(t)    TitleLbl.Text = t end
    function winAPI:SetSubtitle(t) SubLbl.Text   = t end
    function winAPI:Destroy()      SG:Destroy() end

    -- Entrance animation
    Win.BackgroundTransparency = 1
    Win.Position = UDim2.new(sp.X.Scale, sp.X.Offset, sp.Y.Scale, sp.Y.Offset + 20)
    task.defer(function()
        U.Med(Win, { BackgroundTransparency = 0, Position = sp })
    end)

    return winAPI
end

-- ════════════════════════════════════════════════════════════════════
-- LIBRARY ENTRY POINT
-- ════════════════════════════════════════════════════════════════════
local Nova = {}
Nova.__index = Nova
function Nova:CreateWindow(config) return BuildWindow(config) end
Nova.Theme = T
return Nova