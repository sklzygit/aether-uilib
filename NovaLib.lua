--[[
    ╔═══════════════════════════════════════════════════════╗
    ║              NOVA UI LIBRARY  v0.1.0                  ║
    ║         Phase 1 — Core Foundation & Window            ║
    ╚═══════════════════════════════════════════════════════╝

    API EXAMPLE:
    ─────────────────────────────────────────────────────────
    local Nova = loadstring(...)()

    local Window = Nova:CreateWindow({
        Title    = "My Script",
        SubTitle = "v1.0.0",
        Size     = UDim2.new(0, 560, 0, 420),
    })

    local Tab = Window:CreateTab("Visuals", "eye")   -- icon optional
    local Section = Tab:CreateSection("Combat")

    Section:CreateButton({ Label = "Click Me", Callback = function() print("hi") end })
    Section:CreateToggle({ Label = "ESP", Default = false, Callback = function(v) end })
    Section:CreateSlider({ Label = "FOV", Min = 60, Max = 120, Default = 90, Callback = function(v) end })
    Section:CreateDropdown({ Label = "Team", Options = {"Red","Blue"}, Default = "Red", Callback = function(v) end })
    Section:CreateInput({ Label = "Name", Placeholder = "Enter text...", Callback = function(v) end })
    Section:CreateKeybind({ Label = "Toggle Key", Default = Enum.KeyCode.RightShift, Callback = function(k) end })

    Window:Notify({ Title = "Hello", Message = "Loaded!", Duration = 4 })
    ─────────────────────────────────────────────────────────
]]

-- ══════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TextService       = game:GetService("TextService")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════════════════════════════
-- THEME
-- ══════════════════════════════════════════════════════════════════════════════
local Theme = {
    -- Base surfaces
    Base         = Color3.fromRGB(10,  10,  15),
    Surface      = Color3.fromRGB(16,  14,  24),
    SurfaceLight = Color3.fromRGB(22,  19,  34),
    Elevated     = Color3.fromRGB(28,  24,  42),
    Border       = Color3.fromRGB(255, 255, 255),   -- used at low alpha
    BorderAlpha  = 0.88,

    -- Accent
    Accent       = Color3.fromRGB(110, 65, 245),
    AccentLight  = Color3.fromRGB(145, 100, 255),
    AccentDim    = Color3.fromRGB(70,  40, 170),
    AccentGlow   = Color3.fromRGB(130, 80, 255),

    -- Semantic
    Success      = Color3.fromRGB(72,  210, 130),
    Warning      = Color3.fromRGB(245, 185, 60),
    Danger       = Color3.fromRGB(225, 65,  85),
    Info         = Color3.fromRGB(70,  160, 245),

    -- Text
    TextPrimary  = Color3.fromRGB(235, 225, 255),
    TextSecond   = Color3.fromRGB(155, 135, 195),
    TextMuted    = Color3.fromRGB(95,  82,  130),
    TextInvert   = Color3.fromRGB(10,  10,  15),

    -- Corner radii
    RadiusLg     = UDim.new(0, 14),
    RadiusMd     = UDim.new(0, 10),
    RadiusSm     = UDim.new(0, 7),
    RadiusXs     = UDim.new(0, 5),
    RadiusPill   = UDim.new(1, 0),

    -- Spacing
    PadLg        = 16,
    PadMd        = 12,
    PadSm        = 8,
    PadXs        = 5,

    -- Animation
    TweenFast    = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenMed     = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenSlow    = TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenBounce  = TweenInfo.new(0.5,  Enum.EasingStyle.Back,  Enum.EasingDirection.Out),

    -- Font
    FontBold     = Enum.Font.GothamBold,
    FontSemi     = Enum.Font.GothamSemibold,
    FontReg      = Enum.Font.Gotham,
}

-- ══════════════════════════════════════════════════════════════════════════════
-- UTILITY
-- ══════════════════════════════════════════════════════════════════════════════
local Util = {}

function Util.Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function Util.TweenFast(obj, props)  return Util.Tween(obj, Theme.TweenFast, props)  end
function Util.TweenMed(obj, props)   return Util.Tween(obj, Theme.TweenMed,  props)  end
function Util.TweenSlow(obj, props)  return Util.Tween(obj, Theme.TweenSlow, props)  end

function Util.Corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = radius or Theme.RadiusMd
    return c
end

function Util.Stroke(parent, color, alpha, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color       = color or Theme.Border
    s.Transparency = alpha or Theme.BorderAlpha
    s.Thickness   = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function Util.Gradient(parent, colors, rotation)
    local g = Instance.new("UIGradient", parent)
    if type(colors[1]) == "table" then
        local seq = {}
        for i, kp in ipairs(colors) do
            seq[i] = ColorSequenceKeypoint.new(kp[1], kp[2])
        end
        g.Color = ColorSequence.new(seq)
    else
        g.Color = ColorSequence.new(colors[1], colors[2])
    end
    g.Rotation = rotation or 0
    return g
end

function Util.Padding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or top or 0)
    p.PaddingBottom = UDim.new(0, bottom or top or 0)
    p.PaddingLeft   = UDim.new(0, left   or right or top or 0)
    return p
end

function Util.ListLayout(parent, dir, padding, halign, valign)
    local l = Instance.new("UIListLayout", parent)
    l.FillDirection       = dir    or Enum.FillDirection.Vertical
    l.Padding             = UDim.new(0, padding or 0)
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = valign or Enum.VerticalAlignment.Top
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    return l
end

function Util.New(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

-- Auto-resize a frame to fit its UIListLayout children
function Util.AutoSize(frame, layout, axis, extraPad)
    axis = axis or "Y"
    extraPad = extraPad or 0
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if axis == "Y" then
            frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset,
                0, layout.AbsoluteContentSize.Y + extraPad)
        else
            frame.Size = UDim2.new(0, layout.AbsoluteContentSize.X + extraPad,
                frame.Size.Y.Scale, frame.Size.Y.Offset)
        end
    end)
end

-- Ripple effect for buttons
function Util.Ripple(button, x, y)
    local ripple = Instance.new("Frame", button)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.82
    ripple.BorderSizePixel = 0
    ripple.ZIndex = button.ZIndex + 5
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Util.Corner(ripple, Theme.RadiusPill)

    local target = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.2
    Util.Tween(ripple, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, target, 0, target),
        BackgroundTransparency = 1,
    })
    game:GetService("Debris"):AddItem(ripple, 0.5)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- ICON SYSTEM  (text-based via label unicode / simple shapes)
-- (In production you'd use an image atlas; here we use clean unicode symbols)
-- ══════════════════════════════════════════════════════════════════════════════
local Icons = {
    eye        = "👁",
    settings   = "⚙",
    player     = "👤",
    combat     = "⚔",
    misc       = "✦",
    home       = "⌂",
    star       = "★",
    lock       = "🔒",
    key        = "🔑",
    bell       = "🔔",
    check      = "✓",
    cross      = "✕",
    plus       = "+",
    minus      = "−",
    arrow      = "›",
    search     = "🔍",
    color      = "🎨",
    folder     = "📁",
    code       = "</>",
    info       = "ℹ",
    warn       = "⚠",
    danger     = "✖",
    success    = "✔",
}

function Util.Icon(name)
    return Icons[name] or "◆"
end

-- ══════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════════════════════
local NotificationStack = nil  -- set when window is created

local function CreateNotification(opts)
    -- opts: { Title, Message, Type, Duration }
    if not NotificationStack then return end

    local notifType = opts.Type or "info"
    local accentMap = {
        success = Theme.Success,
        warning = Theme.Warning,
        danger  = Theme.Danger,
        info    = Theme.AccentLight,
    }
    local iconMap = {
        success = "success",
        warning = "warn",
        danger  = "danger",
        info    = "info",
    }
    local accent = accentMap[notifType] or Theme.AccentLight
    local duration = opts.Duration or 4

    -- Card
    local Card = Instance.new("Frame", NotificationStack)
    Card.Name = "Notification"
    Card.Size = UDim2.new(1, 0, 0, 64)
    Card.BackgroundColor3 = Theme.SurfaceLight
    Card.BorderSizePixel = 0
    Card.BackgroundTransparency = 1
    Card.ClipsDescendants = true
    Util.Corner(Card, Theme.RadiusMd)

    -- Slide in from right
    Card.Position = UDim2.new(1.2, 0, 0, 0)
    Util.TweenMed(Card, {
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0),
    })

    Util.Stroke(Card, accent, 0.55, 1)

    -- Left accent bar
    local Bar = Instance.new("Frame", Card)
    Bar.Size = UDim2.new(0, 3, 1, -16)
    Bar.Position = UDim2.new(0, 0, 0, 8)
    Bar.BackgroundColor3 = accent
    Bar.BorderSizePixel = 0
    Util.Corner(Bar, Theme.RadiusPill)

    -- Icon
    local IconLbl = Util.New("TextLabel", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 12, 0.5, -14),
        BackgroundTransparency = 1,
        Text = Util.Icon(iconMap[notifType]),
        TextColor3 = accent,
        TextSize = 16,
        Font = Theme.FontBold,
    }, Card)

    -- Title
    local TitleLbl = Util.New("TextLabel", {
        Size = UDim2.new(1, -52, 0, 18),
        Position = UDim2.new(0, 44, 0, 12),
        BackgroundTransparency = 1,
        Text = opts.Title or "Notification",
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Card)

    -- Message
    local MsgLbl = Util.New("TextLabel", {
        Size = UDim2.new(1, -52, 0, 16),
        Position = UDim2.new(0, 44, 0, 32),
        BackgroundTransparency = 1,
        Text = opts.Message or "",
        TextColor3 = Theme.TextSecond,
        TextSize = 11,
        Font = Theme.FontReg,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, Card)

    -- Progress bar
    local ProgBg = Instance.new("Frame", Card)
    ProgBg.Size = UDim2.new(1, -16, 0, 2)
    ProgBg.Position = UDim2.new(0, 8, 1, -6)
    ProgBg.BackgroundColor3 = Theme.Elevated
    ProgBg.BorderSizePixel = 0
    Util.Corner(ProgBg, Theme.RadiusPill)

    local Prog = Instance.new("Frame", ProgBg)
    Prog.Size = UDim2.new(1, 0, 1, 0)
    Prog.BackgroundColor3 = accent
    Prog.BorderSizePixel = 0
    Util.Corner(Prog, Theme.RadiusPill)

    -- Animate progress then dismiss
    Util.Tween(Prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    })

    task.delay(duration, function()
        Util.TweenMed(Card, {
            BackgroundTransparency = 1,
            Position = UDim2.new(1.2, 0, 0, 0),
        })
        task.wait(0.3)
        Card:Destroy()
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- COMPONENT BUILDERS  (Phase 1 — full set: Button, Toggle, Slider,
--                      Dropdown, Input, Keybind, Label, Separator)
-- ══════════════════════════════════════════════════════════════════════════════

local Components = {}

-- ── SEPARATOR ────────────────────────────────────────────────────────────────
function Components.Separator(parent, label)
    local Wrap = Instance.new("Frame", parent)
    Wrap.Size = UDim2.new(1, 0, 0, 22)
    Wrap.BackgroundTransparency = 1
    Wrap.Name = "Separator"

    if label and label ~= "" then
        local Line1 = Instance.new("Frame", Wrap)
        Line1.Size = UDim2.new(0.35, -8, 0, 1)
        Line1.Position = UDim2.new(0, 0, 0.5, 0)
        Line1.BackgroundColor3 = Theme.Border
        Line1.BackgroundTransparency = Theme.BorderAlpha
        Line1.BorderSizePixel = 0

        local Lbl = Util.New("TextLabel", {
            Size = UDim2.new(0.3, 0, 1, 0),
            Position = UDim2.new(0.35, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            Font = Theme.FontBold,
            TextXAlignment = Enum.TextXAlignment.Center,
        }, Wrap)

        local Line2 = Instance.new("Frame", Wrap)
        Line2.Size = UDim2.new(0.35, -8, 0, 1)
        Line2.Position = UDim2.new(0.65, 8, 0.5, 0)
        Line2.BackgroundColor3 = Theme.Border
        Line2.BackgroundTransparency = Theme.BorderAlpha
        Line2.BorderSizePixel = 0
    else
        local Line = Instance.new("Frame", Wrap)
        Line.Size = UDim2.new(1, 0, 0, 1)
        Line.Position = UDim2.new(0, 0, 0.5, 0)
        Line.BackgroundColor3 = Theme.Border
        Line.BackgroundTransparency = Theme.BorderAlpha
        Line.BorderSizePixel = 0
    end

    return Wrap
end

-- ── LABEL ─────────────────────────────────────────────────────────────────────
function Components.Label(parent, opts)
    -- opts: { Text, Color, Size }
    local Lbl = Util.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = opts.Text or "Label",
        TextColor3 = opts.Color or Theme.TextSecond,
        TextSize = opts.Size or 12,
        Font = Theme.FontReg,
        TextXAlignment = Enum.TextXAlignment.Left,
        Name = "Label",
    }, parent)

    local api = {}
    function api:Set(text) Lbl.Text = text end
    function api:SetColor(col) Lbl.TextColor3 = col end
    return api
end

-- ── BUTTON ────────────────────────────────────────────────────────────────────
function Components.Button(parent, opts)
    -- opts: { Label, Description, Icon, Callback }
    local Btn = Instance.new("TextButton", parent)
    Btn.Name = "Button"
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Theme.Elevated
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Util.Corner(Btn, Theme.RadiusSm)
    Util.Stroke(Btn, Theme.Border, 0.90, 1)

    -- Left accent bar (appears on hover)
    local AccentBar = Instance.new("Frame", Btn)
    AccentBar.Size = UDim2.new(0, 2, 0.6, 0)
    AccentBar.Position = UDim2.new(0, 0, 0.2, 0)
    AccentBar.BackgroundColor3 = Theme.Accent
    AccentBar.BackgroundTransparency = 1
    AccentBar.BorderSizePixel = 0
    Util.Corner(AccentBar, Theme.RadiusPill)

    local Inner = Instance.new("Frame", Btn)
    Inner.Size = UDim2.new(1, 0, 1, 0)
    Inner.BackgroundTransparency = 1
    Util.Padding(Inner, 0, 14, 0, 14)

    local RowLayout = Util.ListLayout(Inner, Enum.FillDirection.Horizontal, 8,
        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

    -- Icon (optional)
    if opts.Icon then
        Util.New("TextLabel", {
            Size = UDim2.new(0, 18, 1, 0),
            BackgroundTransparency = 1,
            Text = Util.Icon(opts.Icon),
            TextColor3 = Theme.AccentLight,
            TextSize = 14,
            Font = Theme.FontBold,
            LayoutOrder = 0,
        }, Inner)
    end

    -- Text column
    local TextCol = Instance.new("Frame", Inner)
    TextCol.Size = UDim2.new(1, 0, 1, 0)
    TextCol.BackgroundTransparency = 1
    TextCol.LayoutOrder = 1
    local ColLayout = Util.ListLayout(TextCol, Enum.FillDirection.Vertical, 0,
        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

    local MainLbl = Util.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, opts.Description and 18 or 0),
        AutomaticSize = opts.Description and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = opts.Label or "Button",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Theme.FontSemi,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
    }, TextCol)

    if opts.Description then
        Util.New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = opts.Description,
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            Font = Theme.FontReg,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
        }, TextCol)
    end

    -- Arrow
    Util.New("TextLabel", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1,
        Text = "›",
        TextColor3 = Theme.TextMuted,
        TextSize = 18,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, Btn)

    -- Hover / press states
    Btn.MouseEnter:Connect(function()
        Util.TweenFast(Btn, {BackgroundColor3 = Theme.SurfaceLight})
        Util.TweenFast(AccentBar, {BackgroundTransparency = 0})
        Util.TweenFast(MainLbl, {TextColor3 = Theme.AccentLight})
    end)
    Btn.MouseLeave:Connect(function()
        Util.TweenFast(Btn, {BackgroundColor3 = Theme.Elevated})
        Util.TweenFast(AccentBar, {BackgroundTransparency = 1})
        Util.TweenFast(MainLbl, {TextColor3 = Theme.TextPrimary})
    end)
    Btn.MouseButton1Down:Connect(function()
        Util.TweenFast(Btn, {BackgroundColor3 = Theme.AccentDim})
    end)
    Btn.MouseButton1Up:Connect(function()
        Util.TweenFast(Btn, {BackgroundColor3 = Theme.SurfaceLight})
    end)
    Btn.MouseButton1Click:Connect(function(x, y)
        local rel = Btn.AbsolutePosition
        Util.Ripple(Btn, x - rel.X, y - rel.Y)
        if opts.Callback then
            task.spawn(opts.Callback)
        end
    end)

    local api = {}
    function api:SetLabel(text) MainLbl.Text = text end
    return api
end

-- ── TOGGLE ────────────────────────────────────────────────────────────────────
function Components.Toggle(parent, opts)
    -- opts: { Label, Description, Default, Callback }
    local value = opts.Default == true

    local Row = Instance.new("TextButton", parent)
    Row.Name = "Toggle"
    Row.Size = UDim2.new(1, 0, 0, 40)
    Row.BackgroundColor3 = Theme.Elevated
    Row.BorderSizePixel = 0
    Row.Text = ""
    Row.AutoButtonColor = false
    Util.Corner(Row, Theme.RadiusSm)
    Util.Stroke(Row, Theme.Border, 0.90, 1)
    Util.Padding(Row, 0, 14, 0, 14)

    -- Labels
    local LabelCol = Instance.new("Frame", Row)
    LabelCol.Size = UDim2.new(1, -60, 1, 0)
    LabelCol.BackgroundTransparency = 1
    local ColLayout = Util.ListLayout(LabelCol, Enum.FillDirection.Vertical, 0,
        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

    local MainLbl = Util.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, opts.Description and 18 or 0),
        AutomaticSize = opts.Description and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = opts.Label or "Toggle",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Theme.FontSemi,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
    }, LabelCol)

    if opts.Description then
        Util.New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = opts.Description,
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            Font = Theme.FontReg,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
        }, LabelCol)
    end

    -- Switch track
    local Track = Instance.new("Frame", Row)
    Track.Size = UDim2.new(0, 40, 0, 22)
    Track.Position = UDim2.new(1, -40, 0.5, -11)
    Track.BackgroundColor3 = value and Theme.Accent or Theme.Surface
    Track.BorderSizePixel = 0
    Util.Corner(Track, Theme.RadiusPill)

    -- Knob
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Util.Corner(Knob, Theme.RadiusPill)

    -- Glow behind knob when on
    local KnobGlow = Instance.new("Frame", Track)
    KnobGlow.Size = UDim2.new(0, 22, 0, 22)
    KnobGlow.Position = value and UDim2.new(1, -22, 0.5, -11) or UDim2.new(0, 0, 0.5, -11)
    KnobGlow.BackgroundColor3 = Theme.AccentGlow
    KnobGlow.BackgroundTransparency = value and 0.65 or 1
    KnobGlow.BorderSizePixel = 0
    KnobGlow.ZIndex = Track.ZIndex - 1
    Util.Corner(KnobGlow, Theme.RadiusPill)

    local function refresh(animate)
        local fn = animate and Util.TweenFast or function(o, p) for k,v in pairs(p) do o[k]=v end end
        if value then
            fn(Track, {BackgroundColor3 = Theme.Accent})
            fn(Knob, {Position = UDim2.new(1, -19, 0.5, -8)})
            fn(KnobGlow, {Position = UDim2.new(1, -22, 0.5, -11), BackgroundTransparency = 0.65})
        else
            fn(Track, {BackgroundColor3 = Theme.SurfaceLight})
            fn(Knob, {Position = UDim2.new(0, 3, 0.5, -8)})
            fn(KnobGlow, {Position = UDim2.new(0, 0, 0.5, -11), BackgroundTransparency = 1})
        end
    end

    refresh(false)

    Row.MouseButton1Click:Connect(function()
        value = not value
        refresh(true)
        if opts.Callback then
            task.spawn(opts.Callback, value)
        end
    end)

    Row.MouseEnter:Connect(function() Util.TweenFast(Row, {BackgroundColor3 = Theme.SurfaceLight}) end)
    Row.MouseLeave:Connect(function() Util.TweenFast(Row, {BackgroundColor3 = Theme.Elevated}) end)

    local api = {}
    function api:Set(v, silent)
        value = v
        refresh(true)
        if not silent and opts.Callback then task.spawn(opts.Callback, value) end
    end
    function api:Get() return value end
    return api
end

-- ── SLIDER ────────────────────────────────────────────────────────────────────
function Components.Slider(parent, opts)
    -- opts: { Label, Min, Max, Default, Decimals, Suffix, Callback }
    local min      = opts.Min or 0
    local max      = opts.Max or 100
    local decimals = opts.Decimals or 0
    local suffix   = opts.Suffix or ""
    local value    = math.clamp(opts.Default or min, min, max)
    local dragging = false

    local function fmt(v)
        return string.format("%." .. decimals .. "f", v) .. suffix
    end

    local Wrap = Instance.new("Frame", parent)
    Wrap.Name = "Slider"
    Wrap.Size = UDim2.new(1, 0, 0, 52)
    Wrap.BackgroundColor3 = Theme.Elevated
    Wrap.BorderSizePixel = 0
    Util.Corner(Wrap, Theme.RadiusSm)
    Util.Stroke(Wrap, Theme.Border, 0.90, 1)
    Util.Padding(Wrap, 10, 14, 10, 14)

    -- Top row: label + value
    local TopRow = Instance.new("Frame", Wrap)
    TopRow.Size = UDim2.new(1, 0, 0, 16)
    TopRow.BackgroundTransparency = 1

    Util.New("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Label or "Slider",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Theme.FontSemi,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, TopRow)

    local ValLbl = Util.New("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = fmt(value),
        TextColor3 = Theme.AccentLight,
        TextSize = 12,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, TopRow)

    -- Track
    local TrackBg = Instance.new("Frame", Wrap)
    TrackBg.Name = "Track"
    TrackBg.Size = UDim2.new(1, 0, 0, 6)
    TrackBg.Position = UDim2.new(0, 0, 1, -10)
    TrackBg.BackgroundColor3 = Theme.Surface
    TrackBg.BorderSizePixel = 0
    Util.Corner(TrackBg, Theme.RadiusPill)

    local Fill = Instance.new("Frame", TrackBg)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Util.Corner(Fill, Theme.RadiusPill)
    Util.Gradient(Fill, {
        {0,   Theme.AccentLight},
        {1,   Theme.Accent},
    })

    -- Thumb
    local Thumb = Instance.new("Frame", TrackBg)
    Thumb.Size = UDim2.new(0, 14, 0, 14)
    Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Thumb.BorderSizePixel = 0
    Thumb.ZIndex = TrackBg.ZIndex + 2
    Util.Corner(Thumb, Theme.RadiusPill)
    local ThumbStroke = Util.Stroke(Thumb, Theme.Accent, 0.2, 2)

    local function setVisual(v)
        local pct = (v - min) / (max - min)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        Thumb.Position = UDim2.new(pct, -7, 0.5, -7)
        ValLbl.Text = fmt(v)
    end

    setVisual(value)

    -- Input handling
    local function updateFromInput(inputX)
        local abs = TrackBg.AbsolutePosition.X
        local width = TrackBg.AbsoluteSize.X
        local pct = math.clamp((inputX - abs) / width, 0, 1)
        local raw = min + pct * (max - min)
        local factor = 10^decimals
        value = math.floor(raw * factor + 0.5) / factor
        setVisual(value)
        if opts.Callback then opts.Callback(value) end
    end

    -- Hit area (larger than visible track)
    local Hit = Instance.new("TextButton", Wrap)
    Hit.Size = UDim2.new(1, 0, 0, 20)
    Hit.Position = UDim2.new(0, 0, 1, -14)
    Hit.BackgroundTransparency = 1
    Hit.Text = ""
    Hit.ZIndex = Thumb.ZIndex + 1

    Hit.MouseButton1Down:Connect(function(x)
        dragging = true
        Util.TweenFast(Thumb, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(
            (value - min)/(max-min), -9, 0.5, -9)})
        Util.TweenFast(ThumbStroke, {Transparency = 0})
        updateFromInput(x)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            Util.TweenFast(Thumb, {Size = UDim2.new(0, 14, 0, 14)})
            Util.TweenFast(ThumbStroke, {Transparency = 0.2})
            -- snap visual
            setVisual(value)
        end
    end)

    local api = {}
    function api:Set(v, silent)
        value = math.clamp(v, min, max)
        setVisual(value)
        if not silent and opts.Callback then opts.Callback(value) end
    end
    function api:Get() return value end
    return api
end

-- ── TEXT INPUT ────────────────────────────────────────────────────────────────
function Components.Input(parent, opts)
    -- opts: { Label, Placeholder, Default, MaxLength, Numeric, Callback, OnFocus, OnBlur }
    local value = opts.Default or ""

    local Wrap = Instance.new("Frame", parent)
    Wrap.Name = "Input"
    Wrap.Size = UDim2.new(1, 0, 0, 52)
    Wrap.BackgroundColor3 = Theme.Elevated
    Wrap.BorderSizePixel = 0
    Util.Corner(Wrap, Theme.RadiusSm)
    local WrapStroke = Util.Stroke(Wrap, Theme.Border, 0.90, 1)
    Util.Padding(Wrap, 8, 14, 8, 14)

    Util.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = opts.Label or "Input",
        TextColor3 = Theme.TextSecond,
        TextSize = 10,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Wrap)

    local Box = Instance.new("TextBox", Wrap)
    Box.Size = UDim2.new(1, 0, 0, 20)
    Box.Position = UDim2.new(0, 0, 1, -20)
    Box.BackgroundTransparency = 1
    Box.Text = value
    Box.PlaceholderText = opts.Placeholder or "Type here..."
    Box.PlaceholderColor3 = Theme.TextMuted
    Box.TextColor3 = Theme.TextPrimary
    Box.TextSize = 13
    Box.Font = Theme.FontReg
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.ClearTextOnFocus = false
    if opts.MaxLength then Box.MaxVisibleGraphemes = opts.MaxLength end

    Box.Focused:Connect(function()
        Util.TweenFast(WrapStroke, {Color = Theme.Accent, Transparency = 0.3})
        if opts.OnFocus then opts.OnFocus() end
    end)
    Box.FocusLost:Connect(function(enter)
        Util.TweenFast(WrapStroke, {Color = Theme.Border, Transparency = 0.90})
        value = Box.Text
        if opts.Callback then opts.Callback(value, enter) end
        if opts.OnBlur then opts.OnBlur(enter) end
    end)

    local api = {}
    function api:Set(v) Box.Text = v; value = v end
    function api:Get() return value end
    return api
end

-- ── DROPDOWN ─────────────────────────────────────────────────────────────────
function Components.Dropdown(parent, opts)
    -- opts: { Label, Options, Default, Callback, Multi }
    local options  = opts.Options or {}
    local multi    = opts.Multi == true
    local selected = {}
    local open     = false

    if opts.Default then
        if multi and type(opts.Default) == "table" then
            for _, v in ipairs(opts.Default) do selected[v] = true end
        elseif not multi then
            selected[opts.Default] = true
        end
    elseif #options > 0 and not multi then
        selected[options[1]] = true
    end

    local function getDisplay()
        local keys = {}
        for k in pairs(selected) do keys[#keys+1] = k end
        if #keys == 0 then return "None"
        elseif #keys == 1 then return keys[1]
        else return #keys .. " selected" end
    end

    -- Container (will auto-resize)
    local Container = Instance.new("Frame", parent)
    Container.Name = "Dropdown"
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundTransparency = 1
    Container.ClipsDescendants = false

    -- Header button
    local Header = Instance.new("TextButton", Container)
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Theme.Elevated
    Header.BorderSizePixel = 0
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.ZIndex = 2
    Util.Corner(Header, Theme.RadiusSm)
    local HeaderStroke = Util.Stroke(Header, Theme.Border, 0.90, 1)
    Util.Padding(Header, 0, 14, 0, 14)

    Util.New("TextLabel", {
        Size = UDim2.new(0.55, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Label or "Dropdown",
        TextColor3 = Theme.TextSecond,
        TextSize = 12,
        Font = Theme.FontSemi,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, Header)

    local ValLbl = Util.New("TextLabel", {
        Size = UDim2.new(0.35, 0, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = getDisplay(),
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 3,
    }, Header)

    local ChevronLbl = Util.New("TextLabel", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Text = "⌄",
        TextColor3 = Theme.TextMuted,
        TextSize = 16,
        Font = Theme.FontBold,
        ZIndex = 3,
    }, Header)

    -- Dropdown panel
    local Panel = Instance.new("Frame", Container)
    Panel.Name = "Panel"
    Panel.Size = UDim2.new(1, 0, 0, 0)
    Panel.Position = UDim2.new(0, 0, 0, 44)
    Panel.BackgroundColor3 = Theme.SurfaceLight
    Panel.BorderSizePixel = 0
    Panel.ClipsDescendants = true
    Panel.ZIndex = 10
    Util.Corner(Panel, Theme.RadiusSm)
    Util.Stroke(Panel, Theme.Accent, 0.55, 1)

    local Scroll = Instance.new("ScrollingFrame", Panel)
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = Theme.Accent
    Scroll.ZIndex = 11
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Util.Padding(Scroll, 4, 4, 4, 4)

    local List = Util.ListLayout(Scroll, Enum.FillDirection.Vertical, 2)

    -- Option entries
    local function rebuild()
        for _, child in ipairs(Scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in ipairs(options) do
            local isSelected = selected[opt]
            local OptBtn = Instance.new("TextButton", Scroll)
            OptBtn.Name = opt
            OptBtn.Size = UDim2.new(1, 0, 0, 30)
            OptBtn.BackgroundColor3 = isSelected and Theme.AccentDim or Color3.fromRGB(0,0,0)
            OptBtn.BackgroundTransparency = isSelected and 0 or 1
            OptBtn.BorderSizePixel = 0
            OptBtn.Text = ""
            OptBtn.AutoButtonColor = false
            OptBtn.ZIndex = 12
            Util.Corner(OptBtn, Theme.RadiusXs)

            Util.New("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = opt,
                TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecond,
                TextSize = 12,
                Font = isSelected and Theme.FontBold or Theme.FontReg,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 13,
            }, OptBtn)

            if isSelected then
                Util.New("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -24, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "✓",
                    TextColor3 = Theme.AccentLight,
                    TextSize = 13,
                    Font = Theme.FontBold,
                    ZIndex = 13,
                }, OptBtn)
            end

            OptBtn.MouseEnter:Connect(function()
                if not selected[opt] then
                    Util.TweenFast(OptBtn, {BackgroundTransparency = 0.7, BackgroundColor3 = Theme.Elevated})
                end
            end)
            OptBtn.MouseLeave:Connect(function()
                if not selected[opt] then
                    Util.TweenFast(OptBtn, {BackgroundTransparency = 1})
                end
            end)
            OptBtn.MouseButton1Click:Connect(function()
                if multi then
                    selected[opt] = not selected[opt] or nil
                else
                    selected = {[opt] = true}
                end
                ValLbl.Text = getDisplay()
                rebuild()
                local val = multi and (function()
                    local t = {}; for k in pairs(selected) do t[#t+1]=k end return t
                end)() or opts.Default
                -- get first selected for single
                if not multi then
                    for k in pairs(selected) do val = k break end
                end
                if opts.Callback then task.spawn(opts.Callback, val) end
                if not multi then
                    -- close after single select
                    Header.MouseButton1Click:Fire()
                end
            end)
        end

        -- update scroll canvas
        local itemH = 30
        local padV = 8
        local totalH = #options * (itemH + 2) + padV
        Scroll.CanvasSize = UDim2.new(0,0,0, totalH)
    end

    rebuild()

    -- Open/close
    local targetH = math.min(#options, 5) * 32 + 10

    local function toggle()
        open = not open
        if open then
            Util.TweenFast(HeaderStroke, {Color = Theme.Accent, Transparency = 0.4})
            Util.TweenMed(Panel, {Size = UDim2.new(1, 0, 0, targetH)})
            Util.TweenMed(Container, {Size = UDim2.new(1, 0, 0, 40 + targetH + 4)})
            Util.TweenFast(ChevronLbl, {Rotation = 180})
        else
            Util.TweenFast(HeaderStroke, {Color = Theme.Border, Transparency = 0.90})
            Util.TweenMed(Panel, {Size = UDim2.new(1, 0, 0, 0)})
            Util.TweenMed(Container, {Size = UDim2.new(1, 0, 0, 40)})
            Util.TweenFast(ChevronLbl, {Rotation = 0})
        end
    end

    Header.MouseButton1Click:Connect(toggle)
    Header.MouseEnter:Connect(function() Util.TweenFast(Header, {BackgroundColor3 = Theme.SurfaceLight}) end)
    Header.MouseLeave:Connect(function() Util.TweenFast(Header, {BackgroundColor3 = Theme.Elevated}) end)

    local api = {}
    function api:Set(v, silent)
        selected = {}
        if multi and type(v) == "table" then
            for _,x in ipairs(v) do selected[x]=true end
        else selected[v]=true end
        ValLbl.Text = getDisplay()
        rebuild()
        if not silent and opts.Callback then opts.Callback(v) end
    end
    function api:Get()
        if multi then local t={}; for k in pairs(selected) do t[#t+1]=k end return t end
        for k in pairs(selected) do return k end
    end
    function api:SetOptions(newOpts)
        options = newOpts
        selected = {}
        ValLbl.Text = getDisplay()
        targetH = math.min(#options, 5) * 32 + 10
        rebuild()
        if open then
            Panel.Size = UDim2.new(1, 0, 0, targetH)
            Container.Size = UDim2.new(1, 0, 0, 40 + targetH + 4)
        end
    end
    return api
end

-- ── KEYBIND ───────────────────────────────────────────────────────────────────
function Components.Keybind(parent, opts)
    -- opts: { Label, Default, Callback }
    local key      = opts.Default or Enum.KeyCode.Unknown
    local binding  = false

    local IGNORED = {
        [Enum.KeyCode.Unknown] = true,
        [Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,
        [Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,
    }

    local function keyName(k)
        local n = tostring(k):gsub("Enum.KeyCode.", "")
        return n
    end

    local Row = Instance.new("Frame", parent)
    Row.Name = "Keybind"
    Row.Size = UDim2.new(1, 0, 0, 40)
    Row.BackgroundColor3 = Theme.Elevated
    Row.BorderSizePixel = 0
    Util.Corner(Row, Theme.RadiusSm)
    Util.Stroke(Row, Theme.Border, 0.90, 1)
    Util.Padding(Row, 0, 14, 0, 14)

    Util.New("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Label or "Keybind",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Theme.FontSemi,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Row)

    local Pill = Instance.new("TextButton", Row)
    Pill.Size = UDim2.new(0, 80, 0, 24)
    Pill.Position = UDim2.new(1, -80, 0.5, -12)
    Pill.BackgroundColor3 = Theme.Surface
    Pill.BorderSizePixel = 0
    Pill.Text = keyName(key)
    Pill.TextColor3 = Theme.AccentLight
    Pill.TextSize = 11
    Pill.Font = Theme.FontBold
    Pill.AutoButtonColor = false
    Util.Corner(Pill, Theme.RadiusSm)
    Util.Stroke(Pill, Theme.Accent, 0.5, 1)

    Pill.MouseButton1Click:Connect(function()
        if binding then return end
        binding = true
        Pill.Text = "..."
        Util.TweenFast(Pill, {BackgroundColor3 = Theme.AccentDim, TextColor3 = Color3.fromRGB(255,255,255)})

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if IGNORED[input.KeyCode] then return end
            conn:Disconnect()
            key = input.KeyCode
            binding = false
            Pill.Text = keyName(key)
            Util.TweenFast(Pill, {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.AccentLight})
            if opts.Callback then task.spawn(opts.Callback, key) end
        end)
    end)

    local api = {}
    function api:Get() return key end
    function api:Set(k) key = k; Pill.Text = keyName(k) end
    return api
end

-- ══════════════════════════════════════════════════════════════════════════════
-- SECTION
-- ══════════════════════════════════════════════════════════════════════════════
local SectionMeta = {}
SectionMeta.__index = SectionMeta

function SectionMeta:_add(comp)
    -- nothing extra needed — component is already parented to Content
    return comp
end

function SectionMeta:CreateButton(opts)    return self:_add(Components.Button(self._content, opts)) end
function SectionMeta:CreateToggle(opts)    return self:_add(Components.Toggle(self._content, opts)) end
function SectionMeta:CreateSlider(opts)    return self:_add(Components.Slider(self._content, opts)) end
function SectionMeta:CreateInput(opts)     return self:_add(Components.Input(self._content, opts)) end
function SectionMeta:CreateDropdown(opts)  return self:_add(Components.Dropdown(self._content, opts)) end
function SectionMeta:CreateKeybind(opts)   return self:_add(Components.Keybind(self._content, opts)) end
function SectionMeta:CreateLabel(opts)     return self:_add(Components.Label(self._content, opts)) end
function SectionMeta:CreateSeparator(lbl)  return Components.Separator(self._content, lbl) end

-- ══════════════════════════════════════════════════════════════════════════════
-- TAB CONTENT + SECTIONS
-- ══════════════════════════════════════════════════════════════════════════════
local TabMeta = {}
TabMeta.__index = TabMeta

function TabMeta:CreateSection(name)
    local Wrap = Instance.new("Frame", self._scroll)
    Wrap.Name = name or "Section"
    Wrap.Size = UDim2.new(1, 0, 0, 0)   -- auto-resized
    Wrap.BackgroundTransparency = 1

    local WrapLayout = Util.ListLayout(Wrap, Enum.FillDirection.Vertical, 0)

    -- Section header
    local HeaderRow = Instance.new("Frame", Wrap)
    HeaderRow.Size = UDim2.new(1, 0, 0, 28)
    HeaderRow.BackgroundTransparency = 1
    HeaderRow.LayoutOrder = 0

    local HeaderLine = Instance.new("Frame", HeaderRow)
    HeaderLine.Size = UDim2.new(0, 2, 0.55, 0)
    HeaderLine.Position = UDim2.new(0, 0, 0.22, 0)
    HeaderLine.BackgroundColor3 = Theme.Accent
    HeaderLine.BorderSizePixel = 0
    Util.Corner(HeaderLine, Theme.RadiusPill)

    Util.New("TextLabel", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = (name or "Section"):upper(),
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LetterSpacing = 2,
    }, HeaderRow)

    -- Content list
    local Content = Instance.new("Frame", Wrap)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.BackgroundTransparency = 1
    Content.LayoutOrder = 1

    local ContentLayout = Util.ListLayout(Content, Enum.FillDirection.Vertical, 4)
    Util.AutoSize(Content, ContentLayout, "Y", 0)

    -- bottom spacer
    local Spacer = Instance.new("Frame", Wrap)
    Spacer.Size = UDim2.new(1, 0, 0, 10)
    Spacer.BackgroundTransparency = 1
    Spacer.LayoutOrder = 2

    -- Wrap auto-sizes
    Util.AutoSize(Wrap, WrapLayout, "Y", 0)

    local section = setmetatable({ _content = Content }, SectionMeta)
    return section
end

-- ══════════════════════════════════════════════════════════════════════════════
-- WINDOW
-- ══════════════════════════════════════════════════════════════════════════════

local function CreateWindow(lib, config)
    config = config or {}
    local winTitle    = config.Title    or "Nova"
    local winSub      = config.SubTitle or ""
    local winSize     = config.Size     or UDim2.new(0, 560, 0, 420)
    local winPos      = config.Position or UDim2.new(0.5, -280, 0.5, -210)
    local accentColor = config.Accent   -- optional override
    if accentColor then Theme.Accent = accentColor end

    -- ── ROOT GUI ─────────────────────────────────────────────────────────────
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NovaLib_" .. winTitle
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui

    -- ── MAIN FRAME ───────────────────────────────────────────────────────────
    local Win = Instance.new("Frame", ScreenGui)
    Win.Name = "Window"
    Win.Size = winSize
    Win.Position = winPos
    Win.BackgroundColor3 = Theme.Base
    Win.BorderSizePixel = 0
    Win.ClipsDescendants = false
    Util.Corner(Win, Theme.RadiusLg)
    Util.Stroke(Win, Theme.Border, 0.86, 1)

    -- Background gradient
    Util.Gradient(Win, {
        {0,   Theme.Surface},
        {0.5, Theme.Base},
        {1,   Color3.fromRGB(7, 5, 13)},
    }, 135)

    -- Subtle shadow (layered frame below)
    local Shadow = Instance.new("Frame", ScreenGui)
    Shadow.Size = UDim2.new(0, winSize.X.Offset + 40, 0, winSize.Y.Offset + 40)
    Shadow.Position = UDim2.new(winPos.X.Scale, winPos.X.Offset - 20, winPos.Y.Scale, winPos.Y.Offset - 20)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.55
    Shadow.BorderSizePixel = 0
    Shadow.ZIndex = Win.ZIndex - 1
    Util.Corner(Shadow, UDim.new(0, 22))

    -- ── TITLEBAR ─────────────────────────────────────────────────────────────
    local TitleBar = Instance.new("Frame", Win)
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 52)
    TitleBar.BackgroundTransparency = 1

    -- Accent top bar
    local TopBar = Instance.new("Frame", Win)
    TopBar.Size = UDim2.new(0.35, 0, 0, 2)
    TopBar.Position = UDim2.new(0.325, 0, 0, 0)
    TopBar.BackgroundColor3 = Theme.Accent
    TopBar.BorderSizePixel = 0
    Util.Corner(TopBar, Theme.RadiusPill)
    Util.Gradient(TopBar, {
        {0,   Color3.fromRGB(80, 40, 200)},
        {0.5, Theme.AccentLight},
        {1,   Color3.fromRGB(80, 40, 200)},
    })

    -- Logo/Icon area
    local LogoFrame = Instance.new("Frame", TitleBar)
    LogoFrame.Size = UDim2.new(0, 36, 0, 36)
    LogoFrame.Position = UDim2.new(0, 14, 0.5, -18)
    LogoFrame.BackgroundColor3 = Theme.AccentDim
    LogoFrame.BorderSizePixel = 0
    Util.Corner(LogoFrame, Theme.RadiusSm)
    Util.Gradient(LogoFrame, {
        {0,   Theme.AccentLight},
        {1,   Theme.AccentDim},
    }, 135)

    Util.New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "◆",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Theme.FontBold,
    }, LogoFrame)

    -- Title + subtitle
    local TitleCol = Instance.new("Frame", TitleBar)
    TitleCol.Size = UDim2.new(0, 200, 1, 0)
    TitleCol.Position = UDim2.new(0, 58, 0, 0)
    TitleCol.BackgroundTransparency = 1

    Util.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 0.5, -22),
        BackgroundTransparency = 1,
        Text = winTitle,
        TextColor3 = Theme.TextPrimary,
        TextSize = 15,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, TitleCol)

    Util.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0.5, 6),
        BackgroundTransparency = 1,
        Text = winSub,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        Font = Theme.FontReg,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, TitleCol)

    -- Window controls (close / minimise)
    local Controls = Instance.new("Frame", TitleBar)
    Controls.Size = UDim2.new(0, 64, 0, 24)
    Controls.Position = UDim2.new(1, -78, 0.5, -12)
    Controls.BackgroundTransparency = 1

    local function makeWinBtn(color, xOff, symbol, action)
        local Btn = Instance.new("TextButton", Controls)
        Btn.Size = UDim2.new(0, 24, 0, 24)
        Btn.Position = UDim2.new(0, xOff, 0, 0)
        Btn.BackgroundColor3 = color
        Btn.BackgroundTransparency = 0.3
        Btn.BorderSizePixel = 0
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Util.Corner(Btn, Theme.RadiusPill)

        local Sym = Util.New("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = symbol,
            TextColor3 = Color3.fromRGB(255,255,255),
            TextTransparency = 0.6,
            TextSize = 11,
            Font = Theme.FontBold,
        }, Btn)

        Btn.MouseEnter:Connect(function()
            Util.TweenFast(Btn, {BackgroundTransparency = 0})
            Util.TweenFast(Sym, {TextTransparency = 0})
        end)
        Btn.MouseLeave:Connect(function()
            Util.TweenFast(Btn, {BackgroundTransparency = 0.3})
            Util.TweenFast(Sym, {TextTransparency = 0.6})
        end)
        Btn.MouseButton1Click:Connect(action)
        return Btn
    end

    local minimized = false
    local contentRef -- set below

    makeWinBtn(Color3.fromRGB(255,95,87),   0, "✕", function()
        Util.TweenFast(Win, {BackgroundTransparency = 1})
        Util.TweenFast(ScreenGui, {})
        task.delay(0.2, function() ScreenGui:Destroy() end)
    end)
    makeWinBtn(Color3.fromRGB(255,189,46), 28, "−", function()
        minimized = not minimized
        if minimized then
            Util.TweenMed(Win, {Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 52)})
        else
            Util.TweenMed(Win, {Size = winSize})
        end
    end)

    -- Divider below titlebar
    local TitleDivider = Instance.new("Frame", Win)
    TitleDivider.Size = UDim2.new(1, -28, 0, 1)
    TitleDivider.Position = UDim2.new(0, 14, 0, 52)
    TitleDivider.BackgroundColor3 = Theme.Border
    TitleDivider.BackgroundTransparency = 0.88
    TitleDivider.BorderSizePixel = 0

    -- ── SIDEBAR (Tabs) ────────────────────────────────────────────────────────
    local Sidebar = Instance.new("Frame", Win)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, -53)
    Sidebar.Position = UDim2.new(0, 0, 0, 53)
    Sidebar.BackgroundColor3 = Theme.Surface
    Sidebar.BorderSizePixel = 0
    -- Round only left-bottom corner
    Util.Corner(Sidebar, Theme.RadiusLg)

    local SideGrad = Instance.new("UIGradient", Sidebar)
    SideGrad.Color = ColorSequence.new(Theme.Surface, Theme.Base)
    SideGrad.Rotation = 180

    -- Sidebar right border
    local SideBorder = Instance.new("Frame", Sidebar)
    SideBorder.Size = UDim2.new(0, 1, 1, 0)
    SideBorder.Position = UDim2.new(1, -1, 0, 0)
    SideBorder.BackgroundColor3 = Theme.Border
    SideBorder.BackgroundTransparency = 0.88
    SideBorder.BorderSizePixel = 0

    local TabList = Instance.new("ScrollingFrame", Sidebar)
    TabList.Size = UDim2.new(1, 0, 1, -10)
    TabList.Position = UDim2.new(0, 0, 0, 8)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ScrollBarThickness = 0
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    Util.Padding(TabList, 0, 8, 0, 8)
    local TabListLayout = Util.ListLayout(TabList, Enum.FillDirection.Vertical, 2)
    Util.AutoSize(TabList, TabListLayout, "Y", 16)

    -- ── CONTENT AREA ─────────────────────────────────────────────────────────
    local ContentArea = Instance.new("Frame", Win)
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -140, 1, -53)
    ContentArea.Position = UDim2.new(0, 140, 0, 53)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = true
    contentRef = ContentArea

    -- ── NOTIFICATION STACK ───────────────────────────────────────────────────
    NotificationStack = Instance.new("Frame", ScreenGui)
    NotificationStack.Name = "Notifications"
    NotificationStack.Size = UDim2.new(0, 280, 1, 0)
    NotificationStack.Position = UDim2.new(1, -296, 0, 0)
    NotificationStack.BackgroundTransparency = 1
    NotificationStack.BorderSizePixel = 0
    Util.Padding(NotificationStack, 16, 0, 16, 0)
    local NotiLayout = Util.ListLayout(NotificationStack, Enum.FillDirection.Vertical, 8,
        Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
    NotificationStack.AnchorPoint = Vector2.new(0, 0)

    -- ── DRAG BEHAVIOUR ───────────────────────────────────────────────────────
    do
        local dragging, dragStart, startPos
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging  = true
                dragStart = input.Position
                startPos  = Win.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                local newPos = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                Win.Position = newPos
                Shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 20,
                    newPos.Y.Scale, newPos.Y.Offset - 20)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- ── TAB MANAGEMENT ───────────────────────────────────────────────────────
    local tabs      = {}
    local activeTab = nil

    local function switchTab(tabObj)
        if activeTab == tabObj then return end

        -- Deactivate previous
        if activeTab then
            local prev = activeTab
            Util.TweenFast(prev._btn, {BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 1})
            Util.TweenFast(prev._btnLabel, {TextColor3 = Theme.TextMuted})
            Util.TweenFast(prev._btnBar,   {BackgroundTransparency = 1})
            Util.TweenFast(prev._page,     {BackgroundTransparency = 1})
            prev._page.Visible = false
        end

        activeTab = tabObj
        Util.TweenFast(tabObj._btn,       {BackgroundColor3 = Theme.Elevated, BackgroundTransparency = 0})
        Util.TweenFast(tabObj._btnLabel,  {TextColor3 = Theme.TextPrimary})
        Util.TweenFast(tabObj._btnBar,    {BackgroundTransparency = 0})
        tabObj._page.Visible = true
        Util.TweenFast(tabObj._page,      {BackgroundTransparency = 1})  -- already transparent bg
    end

    -- Window API object
    local windowAPI = {}

    function windowAPI:CreateTab(name, icon)
        -- Sidebar button
        local Btn = Instance.new("TextButton", TabList)
        Btn.Name = name
        Btn.Size = UDim2.new(1, 0, 0, 36)
        Btn.BackgroundColor3 = Theme.Elevated
        Btn.BackgroundTransparency = 1
        Btn.BorderSizePixel = 0
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Util.Corner(Btn, Theme.RadiusSm)

        -- Active indicator bar
        local ActiveBar = Instance.new("Frame", Btn)
        ActiveBar.Size = UDim2.new(0, 2, 0.5, 0)
        ActiveBar.Position = UDim2.new(0, 0, 0.25, 0)
        ActiveBar.BackgroundColor3 = Theme.Accent
        ActiveBar.BackgroundTransparency = 1
        ActiveBar.BorderSizePixel = 0
        Util.Corner(ActiveBar, Theme.RadiusPill)

        -- Icon (optional)
        local xOffset = 14
        if icon then
            Util.New("TextLabel", {
                Size = UDim2.new(0, 18, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = Util.Icon(icon),
                TextColor3 = Theme.TextMuted,
                TextSize = 14,
                Font = Theme.FontBold,
            }, Btn)
            xOffset = 32
        end

        local BtnLabel = Util.New("TextLabel", {
            Size = UDim2.new(1, -(xOffset + 4), 1, 0),
            Position = UDim2.new(0, xOffset, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.TextMuted,
            TextSize = 13,
            Font = Theme.FontSemi,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, Btn)

        -- Tab page (scroll frame)
        local Page = Instance.new("ScrollingFrame", ContentArea)
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Util.Padding(Page, 12, 12, 12, 14)

        local PageLayout = Util.ListLayout(Page, Enum.FillDirection.Vertical, 6)
        Util.AutoSize(Page, PageLayout, "Y", 24)

        local tabObj = {
            _btn       = Btn,
            _btnLabel  = BtnLabel,
            _btnBar    = ActiveBar,
            _page      = Page,
            _scroll    = Page,
        }
        setmetatable(tabObj, TabMeta)
        tabs[#tabs + 1] = tabObj

        Btn.MouseButton1Click:Connect(function() switchTab(tabObj) end)
        Btn.MouseEnter:Connect(function()
            if activeTab ~= tabObj then
                Util.TweenFast(Btn, {BackgroundTransparency = 0.6})
            end
        end)
        Btn.MouseLeave:Connect(function()
            if activeTab ~= tabObj then
                Util.TweenFast(Btn, {BackgroundTransparency = 1})
            end
        end)

        -- Auto-activate first tab
        if #tabs == 1 then switchTab(tabObj) end

        return tabObj
    end

    function windowAPI:Notify(opts)
        CreateNotification(opts)
    end

    function windowAPI:Destroy()
        ScreenGui:Destroy()
    end

    -- Entrance animation
    Win.Position = UDim2.new(winPos.X.Scale, winPos.X.Offset, winPos.Y.Scale, winPos.Y.Offset - 18)
    Win.BackgroundTransparency = 0.4
    Util.TweenMed(Win, {
        Position = UDim2.new(winPos.X.Scale, winPos.X.Offset, winPos.Y.Scale, winPos.Y.Offset),
        BackgroundTransparency = 0,
    })

    return windowAPI
end

-- ══════════════════════════════════════════════════════════════════════════════
-- LIBRARY ENTRY POINT
-- ══════════════════════════════════════════════════════════════════════════════
local Nova = {}
Nova.__index = Nova

function Nova:CreateWindow(config)
    return CreateWindow(self, config)
end

-- Expose theme for user customisation
Nova.Theme = Theme

return Nova
