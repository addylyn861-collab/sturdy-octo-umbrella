-- =============================
-- Services & setup
-- =============================
Players = game:GetService('Players')
TweenService = game:GetService('TweenService')
PathfindingService = game:GetService('PathfindingService')
UserInputService = game:GetService('UserInputService')
CoreGui = game:GetService('CoreGui')
RunService = game:GetService('RunService')
Workspace = game:GetService('Workspace')

-- =============================
-- Critical Variables for ESP
-- =============================
local player = Players.LocalPlayer
local plotsFolder = Workspace:FindFirstChild('Plots')
    or Workspace:WaitForChild('Plots')

-- =============================
-- Modern UI Effects
-- =============================

-- Global state variables (converted to globals to avoid local limit)
connections = {}
unloaded = false
DropdownRegistry = {}
globalDragState = { isDragging = false, draggedWindow = nil }
lastAltPress = 0 -- For debouncing Alt key presses
blurOperationInProgress = false -- Prevent multiple blur operations
autoHitStopRequested = false -- Immediate stop flag for auto hit
sidebarApi = nil -- Global reference to sidebar API for theme updates
openWindows = {} -- Global reference to open windows for theme updates
uiRefs = {} -- Global reference to UI element references for UISync functions

-- Subtle organic color effects for UI elements

-- Placeholder for organic effects functions (moved after bind function is defined)

-- Enhanced button hover effects
function addButtonHoverEffect(button)
    if not button then
        return
    end

    local originalColor = button.BackgroundColor3
    local originalSize = button.Size

    button.MouseEnter:Connect(function()
        -- Subtle color brightening and size increase
        TweenService
            :Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.new(
                    math.min(1, originalColor.R + 0.1),
                    math.min(1, originalColor.G + 0.1),
                    math.min(1, originalColor.B + 0.1)
                ),
                Size = UDim2.new(
                    originalSize.X.Scale,
                    originalSize.X.Offset + 2,
                    originalSize.Y.Scale,
                    originalSize.Y.Offset + 2
                ),
            })
            :Play()
    end)

    button.MouseLeave:Connect(function()
        -- Return to original state
        TweenService
            :Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                BackgroundColor3 = originalColor,
                Size = originalSize,
            })
            :Play()
    end)
end
Lighting = game:GetService('Lighting')
SoundService = game:GetService('SoundService')
ProximityPromptService = game:GetService('ProximityPromptService')
ReplicatedStorage = game:GetService('ReplicatedStorage')
TextService = game:GetService('TextService')
HttpService = game:GetService('HttpService') -- ADDED for webhook posting

existingGuiName = 'YourGuiName'

-- Kill previous UI instances
pcall(function()
    for _, container in ipairs({
        CoreGui,
        Players.LocalPlayer and Players.LocalPlayer:WaitForChild('PlayerGui'),
    }) do
        if container then
            old = container:FindFirstChild(existingGuiName)
            if old then
                old:Destroy()
            end
            old_failsafe =
                container:FindFirstChild(existingGuiName .. '_failsafe')
            if old_failsafe then
                old_failsafe:Destroy()
            end
            old_overlay =
                container:FindFirstChild(existingGuiName .. '_Overlay')
            if old_overlay then
                old_overlay:Destroy()
            end
            old_toasts = container:FindFirstChild(existingGuiName .. '_Toasts')
            if old_toasts then
                old_toasts:Destroy()
            end
            -- NEW: Kill seed toasts GUI
            old_seed_toasts =
                container:FindFirstChild(existingGuiName .. '_SeedToasts')
            if old_seed_toasts then
                old_seed_toasts:Destroy()
            end
        end
    end
end)

-- =============================
-- State & Unload Logic
-- =============================
unloaded = false
connections = {}
function bind(conn)
    if conn then
        table.insert(connections, conn)
    end
    return conn
end
mainGui, failsafeGui, gameInfoGui, espGui, overlayGui = nil, nil, nil, nil, nil
toastsGui, toastContainer = nil, nil
seedToastsGui, seedToastContainer = nil, nil -- NEW: For seed alerts

-- Add organic UI effects to match lava lamp theme (without layout shifts)
function addOrganicUIEffects(element)
    if not element then
        return
    end

    -- Only add subtle color shifting to prevent layout shifts
    if element.BackgroundColor3 then
        local originalColor = element.BackgroundColor3
        local colorShift = TweenService:Create(
            element,
            TweenInfo.new(
                8,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut,
                -1,
                true
            ),
            {
                BackgroundColor3 = Color3.new(
                    math.min(1, originalColor.R + 0.03),
                    math.min(1, originalColor.G + 0.03),
                    math.min(1, originalColor.B + 0.03)
                ),
            }
        )
        colorShift:Play()
    end
end

-- Enhanced button hover effects with organic feel (respects button state)
function addOrganicButtonEffects(button)
    if not button then
        return
    end

    local originalSize = button.Size

    -- More noticeable hover effects with glow and scale
    bind(button.MouseEnter:Connect(function()
        -- Bigger scale change and add glow effect
        TweenService
            :Create(
                button,
                TweenInfo.new(
                    0.2,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = UDim2.new(
                        originalSize.X.Scale,
                        originalSize.X.Offset + 12,
                        originalSize.Y.Scale,
                        originalSize.Y.Offset + 6
                    ),
                }
            )
            :Play()

        -- Add glowing stroke effect
        if not button:FindFirstChild('HoverStroke') then
            local hoverStroke = Instance.new('UIStroke')
            hoverStroke.Name = 'HoverStroke'
            hoverStroke.Color = Color3.fromRGB(255, 255, 255)
            hoverStroke.Thickness = 0
            hoverStroke.Transparency = 1
            hoverStroke.Parent = button

            -- Animate stroke in
            TweenService
                :Create(
                    hoverStroke,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {
                        Thickness = 3,
                        Transparency = 0.3,
                    }
                )
                :Play()
        end
    end))

    bind(button.MouseLeave:Connect(function()
        -- Return to original size with bounce
        TweenService
            :Create(
                button,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = originalSize,
                }
            )
            :Play()

        -- Remove glow stroke
        local hoverStroke = button:FindFirstChild('HoverStroke')
        if hoverStroke then
            TweenService
                :Create(
                    hoverStroke,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {
                        Thickness = 0,
                        Transparency = 1,
                    }
                )
                :Play()
            game:GetService('Debris'):AddItem(hoverStroke, 0.3)
        end
    end))
end

function disconnectAll()
    for _, c in ipairs(connections) do
        pcall(function()
            c:Disconnect()
        end)
    end
    connections = {}
end

-- Dropdown registry so we can close all when hiding GUI
DropdownRegistry = {}
-- Make DropdownStateRegistry persistent across script reloads
local REGISTRY_KEY = 'AAA_DropdownStateRegistry_' .. tostring(player.UserId)

-- Check if any registry exists for this user
local foundRegistry = false
for key, value in pairs(_G) do
    if
        string.find(
            key,
            'AAA_DropdownStateRegistry_' .. tostring(player.UserId)
        )
    then
        DropdownStateRegistry = value
        foundRegistry = true
        break
    end
end

if not foundRegistry then
    _G[REGISTRY_KEY] = {}
    DropdownStateRegistry = _G[REGISTRY_KEY]
else
end

function registerDropdown(api)
    table.insert(DropdownRegistry, api)
end

function closeAllDropdowns(except)
    local savedCount = 0

    for i, api in ipairs(DropdownRegistry) do
        if api ~= except then
            -- Save dropdown state before closing
            local identifier
            if api.persistenceKey and tostring(api.persistenceKey) ~= '' then
                identifier = 'dropdown_key_' .. tostring(api.persistenceKey)
            else
                identifier = 'dropdown_'
                    .. (api.container and api.container.Name or 'unknown')
                if api.container and api.container.Parent then
                    local parentName = api.container.Parent.Name or 'unknown'
                    local containerName = api.container.Name or 'unknown'
                    identifier = 'dropdown_'
                        .. parentName
                        .. '_'
                        .. containerName
                end
            end
            local state = {}

            -- Handle multi-select dropdowns first (they have both GetSelected and GetSelection)
            if api.GetSelection and api.GetItems then
                state.selected = api.GetSelection()
                state.items = api.GetItems()
                state.type = 'multi'
            -- Handle single-select dropdowns (they only have GetSelected, not GetSelection)
            elseif api.GetSelected and api.GetItems then
                state.selected = api.GetSelected()
                state.items = api.GetItems()
                state.type = 'single'
            end

            if next(state) ~= nil then -- Only save if we have some state
                DropdownStateRegistry[identifier] = state
                savedCount = savedCount + 1
            end

            pcall(function()
                if api.Close then
                    api.Close()
                end
            end)
        end
    end
end

-- Function to restore dropdown state
function restoreDropdownState(api, identifier)
    if not identifier then
        return
    end

    local state = DropdownStateRegistry[identifier]

    if state and state.selected then
        -- Restore the selected state based on dropdown type
        pcall(function()
            if state.type == 'single' and api.SetSelectedByName then
                -- Single-select dropdown
                api.SetSelectedByName(state.selected)
            elseif state.type == 'multi' and api.SetSelection then
                -- Multi-select dropdown
                api.SetSelection(state.selected)
                local count = 0
                for k, v in pairs(state.selected) do
                    if v then
                        count = count + 1
                    end
                end
            end
        end)
    else
    end
end

function unload()
    if unloaded then
        return
    end
    unloaded = true

    -- Clean up connections
    disconnectAll()

    -- Stop auto collect
    autoCollectEnabled = false
    autoCollectRunning = false
    if autoCollectThread then
        task.cancel(autoCollectThread)
        autoCollectThread = nil
    end

    -- Stop auto buy threads
    seedAutoBuyEnabled = false
    gearAutoBuyEnabled = false
    antiAfkEnabled = false
    autoFavouriteEnabled = false
    if seedAutoBuyThread then
        task.cancel(seedAutoBuyThread)
        seedAutoBuyThread = nil
    end
    if gearAutoBuyThread then
        task.cancel(gearAutoBuyThread)
        gearAutoBuyThread = nil
    end
    if antiAfkThread then
        task.cancel(antiAfkThread)
        antiAfkThread = nil
    end
    if autoFavouriteThread then
        task.cancel(autoFavouriteThread)
        autoFavouriteThread = nil
    end

    -- destroy GUIs safely
    pcall(function()
        if mainGui and mainGui.Destroy then
            mainGui:Destroy()
        end
    end)
    pcall(function()
        if sidebarGui and sidebarGui.Destroy then
            sidebarGui:Destroy()
        end
    end)
    pcall(function()
        if failsafeGui and failsafeGui.Destroy then
            failsafeGui:Destroy()
        end
    end)
    pcall(function()
        if gameInfoGui and gameInfoGui.Destroy then
            gameInfoGui:Destroy()
        end
    end)
    pcall(function()
        if espGui and espGui.Destroy then
            espGui:Destroy()
        end
    end)
    pcall(function()
        if overlayGui and overlayGui.Destroy then
            overlayGui:Destroy()
        end
    end)
    pcall(function()
        if toastsGui and toastsGui.Destroy then
            toastsGui:Destroy()
        end
    end)
    pcall(function()
        if seedToastsGui and seedToastsGui.Destroy then
            seedToastsGui:Destroy()
        end
    end)
    pcall(function()
        if seedTimerInfoGui and seedTimerInfoGui.Destroy then
            seedTimerInfoGui:Destroy()
        end
    end)
    pcall(function()
        if unloadConfirmGui and unloadConfirmGui.Destroy then
            unloadConfirmGui:Destroy()
        end
    end)
    pcall(function()
        if loadingGui and loadingGui.Destroy then
            loadingGui:Destroy()
        end
    end)

    -- Clean up diagnostic GUI
    pcall(function()
        local playerGui = game:GetService('Players').LocalPlayer.PlayerGui
        local diagnosticGui = playerGui:FindFirstChild('SellDiagnostic')
        if diagnosticGui and diagnosticGui.Destroy then
            diagnosticGui:Destroy()
        end
    end)

    -- Clean up hitbox cache and restore original properties
    for hitbox, original in pairs(seedTimerHitboxCache) do
        if hitbox and hitbox.Parent then
            pcall(function()
                hitbox.Transparency = original.originalTransparency
                hitbox.Color = original.originalColor
                hitbox.Material = original.originalMaterial
                hitbox.CanCollide = original.originalCanCollide
                hitbox.CFrame = original.originalCFrame
            end)
        end
    end
    seedTimerHitboxCache = {}

    -- Clean up minimal sidebar if it exists
    pcall(function()
        local minimalSidebar =
            CoreGui:FindFirstChild(existingGuiName .. '_MinimalSidebar')
        if minimalSidebar and minimalSidebar.Destroy then
            minimalSidebar:Destroy()
        end
    end)

    -- disconnect connections and cleanup
    disconnectAll()

    pcall(function()
        blur = Lighting:FindFirstChild(existingGuiName .. '_UIBlur')
        if blur and blur.Destroy then
            blur:Destroy()
        end
    end)

    pcall(function()
        if script and script.Destroy then
            script:Destroy()
        end
    end)
end

-- Predeclare config state variables as globals to avoid local limit
sidebarScale = 1.0 -- Global sidebar scale value
toastScale = 1.25 -- Global toast scale value
uiRefs = {}
theme = 'dark' -- "dark" or "light"
alertEnabled = false
alertSoundEnabled = true
alertVolume = 1.0
alertMatchMode = 'Both'
webhookEnabled = false
webhookUrl = ''
webhookPingMode = 'None'
autoCollectEnabled = false
autoCollectIntervalSec = 90
autoCollectType = 'Teleport'
nextCollectTime = 0
autoCollectRunning = false
autoCollectThread = nil
autoEquipBestEnabled = false
autoEquipBestIntervalSec = 100
nextEquipBestTime = 0
autoEquipBestThread = nil

-- Auto Sell variables
autoSellEnabled = autoSellEnabled or false
autoSellIntervalSec = autoSellIntervalSec or 60
autoSellThread = autoSellThread or nil
autoSellLoop = autoSellLoop or function() end

performanceModeWarningShown = false
espEnabled = false
seedAlertEnabled = true
seedAlertVolume = 1.0
gameInfoEnabled = false
gearWebhookEnabled = true
brainrotServerwideEnabled = false
gameInfoScale = 1.0
gameInfoScaleObj = nil
gearAlertEnabled = true
keepSidebarOpen = false
disableBlur = false
disableAnimations = false
seedTimerEspEnabled = false
seedTimerInfoEnabled = false
seedTimerHitboxEnabled = false
mobileButtonEnabled = true
antiAfkEnabled = false
antiAfkThread = nil
sidebarLocation = 'Left' -- "Left" or "Right"

-- Auto Favourite variables
autoFavouriteEnabled = false
autoFavouriteIntervalSec = 60
autoFavouriteThread = nil
autoFavouriteRarities = { Limited = true, Godly = true, Secret = true }
autoFavouriteMutations = {
    None = true,
    Gold = true,
    Diamond = true,
    Frozen = true,
    Neon = true,
    Galactic = true,
    UpsideDown = true,
    Magma = true,
    Underworld = true,
    Rainbow = true,
    Ruby = true,
}

-- Alert filter sets as globals
alertRaritySet = { Godly = true, Secret = true }
alertMutationSet = {
    Neon = true,
    Frozen = true,
    Galactic = true,
    Rainbow = true,
    UpsideDown = true,
    Magma = true,
    Underworld = true,
}
selectedRarities = {}
selectedMutations = {}
selectedSeedFilters = selectedSeedFilters
    or { ['King Limone Seed'] = true, ['Mango Seed'] = true }

-- Alert cache variables (to prevent duplicate alerts)
_alertSeen = setmetatable({}, { __mode = 'k' })
_seedAlertSeen = {} -- Simple true/false flag for seed alerts
_gearAlertSeen = {} -- Simple true/false flag for gear alerts

-- Batch alert cooldown variables
SEED_BATCH_COOLDOWN = 60 -- seconds
GEAR_BATCH_COOLDOWN = 60 -- seconds
_lastSeedBatchAlertAt = 0
_lastGearBatchAlertAt = 0

-- Utility constructor (global to avoid local limit)
function New(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= 'Parent' then
            o[k] = v
        end
    end
    if children then
        for _, c in ipairs(children) do
            c.Parent = o
        end
    end
    o.Parent = props and props.Parent or nil
    return o
end

-- Create a failsafe unload button immediately (global to avoid local limit)
function createFailsafeUnload()
    local sg = New('ScreenGui', {
        Name = existingGuiName .. '_failsafe',
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999999,
        Parent = CoreGui,
    })
    local btn = New('TextButton', {
        Parent = sg,
        Size = UDim2.new(0, 120, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        Text = 'Unload Script',
        ZIndex = 2,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 12) }),
    })
    btn.MouseButton1Click:Connect(unload)
    return sg
end
failsafeGui = createFailsafeUnload()

-- Top-most overlay for dropdown menus (not for toasts)
function ensureOverlay()
    -- Always check if the GUI exists in CoreGui, don't trust the global variable
    overlayGui = CoreGui:FindFirstChild(existingGuiName .. '_Overlay')
    if not overlayGui or not overlayGui.Parent then
        overlayGui = New('ScreenGui', {
            Name = existingGuiName .. '_Overlay',
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 999999,
            IgnoreGuiInset = true,
            Parent = CoreGui,
        })
    end
    overlayGui.Enabled = true
    return overlayGui
end

-- Top-most toasts GUI (separate so it's never covered)
function ensureToastsGui()
    if toastsGui and toastsGui.Parent then
        return toastsGui
    end
    toastsGui = Instance.new('ScreenGui')
    toastsGui.Name = existingGuiName .. '_Toasts'
    toastsGui.ResetOnSpawn = false
    toastsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toastsGui.DisplayOrder = 2000000
    toastsGui.IgnoreGuiInset = true
    toastsGui.Parent = CoreGui

    toastContainer = Instance.new('Frame')
    toastContainer.Name = 'Toasts'
    toastContainer.BackgroundTransparency = 1
    toastContainer.AnchorPoint = Vector2.new(1, 0)
    toastContainer.Position = UDim2.new(1, -12, 0, 12)
    toastContainer.Size = UDim2.new(0, 0, 0, 0) -- Start with zero size
    toastContainer.AutomaticSize = Enum.AutomaticSize.XY -- Automatically size on both axes
    toastContainer.ZIndex = 2000001
    toastContainer.Parent = toastsGui

    -- Add UIScale for toast scaling
    local toastScaleObj = Instance.new('UIScale')
    toastScaleObj.Scale = toastScale
    toastScaleObj.Parent = toastContainer

    local layout = Instance.new('UIListLayout')
    layout.Parent = toastContainer
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    return toastsGui
end

-- NEW: Top-most GUI for seed toasts (right by default, shifts slightly left when brainrot alerts are on)
function ensureSeedToastsGui()
    if seedToastsGui and seedToastsGui.Parent then
        return seedToastsGui
    end
    seedToastsGui = Instance.new('ScreenGui')
    seedToastsGui.Name = existingGuiName .. '_SeedToasts'
    seedToastsGui.ResetOnSpawn = false
    seedToastsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    seedToastsGui.DisplayOrder = 2000000
    seedToastsGui.IgnoreGuiInset = true
    seedToastsGui.Parent = CoreGui

    seedToastContainer = Instance.new('Frame')
    seedToastContainer.Name = 'SeedToasts'
    seedToastContainer.BackgroundTransparency = 1
    seedToastContainer.AnchorPoint = Vector2.new(1, 0)
    seedToastContainer.Position = UDim2.new(1, -12, 0, 12)
    seedToastContainer.Size = UDim2.new(0, 0, 0, 0) -- Start with zero size
    seedToastContainer.AutomaticSize = Enum.AutomaticSize.XY -- Automatically size on both axes
    seedToastContainer.ZIndex = 2000001
    seedToastContainer.Parent = seedToastsGui

    -- Add UIScale for toast scaling
    local seedToastScaleObj = Instance.new('UIScale')
    seedToastScaleObj.Scale = toastScale
    seedToastScaleObj.Parent = seedToastContainer

    local layout = Instance.new('UIListLayout')
    layout.Parent = seedToastContainer
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    return seedToastsGui
end

-- Bottom-right GUI for gear toasts (own lane)
gearToastsGui, gearToastContainer = nil, nil
function ensureGearToastsGui()
    if gearToastsGui and gearToastsGui.Parent then
        return gearToastsGui
    end
    gearToastsGui = Instance.new('ScreenGui')
    gearToastsGui.Name = existingGuiName .. '_GearToasts'
    gearToastsGui.ResetOnSpawn = false
    gearToastsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gearToastsGui.DisplayOrder = 2000000
    gearToastsGui.IgnoreGuiInset = true
    gearToastsGui.Parent = CoreGui

    gearToastContainer = Instance.new('Frame')
    gearToastContainer.Name = 'GearToasts'
    gearToastContainer.BackgroundTransparency = 1
    gearToastContainer.AnchorPoint = Vector2.new(1, 1)
    gearToastContainer.Position = UDim2.new(1, -12, 1, -12)
    gearToastContainer.Size = UDim2.new(0, 0, 0, 0)
    gearToastContainer.AutomaticSize = Enum.AutomaticSize.XY
    gearToastContainer.ZIndex = 2000001
    gearToastContainer.Parent = gearToastsGui

    -- Add UIScale for toast scaling
    local gearToastScaleObj = Instance.new('UIScale')
    gearToastScaleObj.Scale = toastScale
    gearToastScaleObj.Parent = gearToastContainer

    local layout = Instance.new('UIListLayout')
    layout.Parent = gearToastContainer
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    return gearToastsGui
end

-- Helper to place seed toasts and brainrot toasts relative to the right edge.
function updateToastPositions()
    if not toastContainer or not seedToastContainer then
        return
    end

    local gap = 8
    local rightMargin = 12

    local alertOn = (type(alertEnabled) == 'boolean' and alertEnabled)
    local seedAlertOn = (
        type(seedAlertEnabled) == 'boolean' and seedAlertEnabled
    )

    local seedW = seedToastContainer.AbsoluteSize.X
    local brainW = toastContainer.AbsoluteSize.X

    if alertOn and seedAlertOn then
        seedToastContainer.Position = UDim2.new(1, -rightMargin, 0, 12)
        toastContainer.Position =
            UDim2.new(1, -(rightMargin + seedW + gap), 0, 12)
    elseif alertOn then
        toastContainer.Position = UDim2.new(1, -rightMargin, 0, 12)
        seedToastContainer.Position = UDim2.new(1, -rightMargin, 0, 12)
    elseif seedAlertOn then
        seedToastContainer.Position = UDim2.new(1, -rightMargin, 0, 12)
        toastContainer.Position = UDim2.new(1, -rightMargin, 0, 12)
    else
        seedToastContainer.Position = UDim2.new(1, -rightMargin, 0, 12)
        toastContainer.Position = UDim2.new(1, -rightMargin, 0, 12)
    end
end

-- Viewport helpers
local function getViewport()
    local cam = Workspace.CurrentCamera
    if not cam then
        return 1920, 1080
    end
    local v = cam.ViewportSize
    return v.X or 1920, v.Y or 1080
end
function isSmallViewport()
    local vw = select(1, getViewport())
    return vw < 900
end
local function getMobileSidebarScale()
    local vw = select(1, getViewport())
    if vw >= 900 then
        return 1.0
    end
    return math.clamp(vw / 900, 0.5, 1.0)
end

-- Responsive layout for mobile/small screens: scale sidebar and clamp window sizes
function applyResponsiveLayout()
    local vw, vh = getViewport()

    -- Compute target UI scale for sidebar on small viewports
    local targetScale = getMobileSidebarScale()

    -- Apply to sidebar UIScale if present
    pcall(function()
        local sidebarGui = CoreGui:FindFirstChild(existingGuiName .. '_Sidebar')
        if sidebarGui then
            local sidebar = sidebarGui:FindFirstChild('Frame')
            if sidebar then
                local s = sidebar:FindFirstChild('UIScale')
                if not s then
                    s = Instance.new('UIScale')
                    s.Parent = sidebar
                end
                local desired = math.min(sidebarScale or 1.0, targetScale)
                s.Scale = desired

                -- On small screens, force collapsed width and clamp height so bottom buttons are visible
                if isSmallViewport() then
                    local baseCollapsed = 60
                    local width = math.floor(baseCollapsed * desired)
                    local height = math.min(490, vh - 20)
                    if disableAnimations then
                        sidebar.Size = UDim2.new(0, width, 0, height)
                    else
                        TweenService
                            :Create(
                                sidebar,
                                TweenInfo.new(
                                    0.15,
                                    Enum.EasingStyle.Quad,
                                    Enum.EasingDirection.Out
                                ),
                                { Size = UDim2.new(0, width, 0, height) }
                            )
                            :Play()
                    end
                end
            end
        end
    end)

    -- Clamp open window sizes/positions to viewport
    pcall(function()
        local margin = 8
        local maxW = math.max(200, vw - margin * 2)
        local maxH = math.max(160, vh - margin * 2)

        for _, window in pairs(openWindows or {}) do
            if window and window.Parent then
                -- Determine target size (preserve aspect if possible)
                local current = window.Size
                local wpx = (current.X.Scale == 0) and current.X.Offset
                    or math.floor(maxW * (current.X.Scale > 0 and 1 or 0))
                local hpx = (current.Y.Scale == 0) and current.Y.Offset
                    or math.floor(maxH * (current.Y.Scale > 0 and 1 or 0))

                -- If scale-based, convert to clamped pixel size for safety
                local targetWidth = math.min((wpx > 0 and wpx or 600), maxW)
                local targetHeight = math.min((hpx > 0 and hpx or 400), maxH)
                -- Center within viewport to avoid creeping
                local targetPos = UDim2.new(
                    0.5,
                    -math.floor(targetWidth / 2),
                    0.5,
                    -math.floor(targetHeight / 2)
                )

                if disableAnimations then
                    window.Size = UDim2.new(0, targetWidth, 0, targetHeight)
                    window.Position = targetPos
                else
                    TweenService
                        :Create(
                            window,
                            TweenInfo.new(
                                0.2,
                                Enum.EasingStyle.Quad,
                                Enum.EasingDirection.Out
                            ),
                            {
                                Size = UDim2.new(
                                    0,
                                    targetWidth,
                                    0,
                                    targetHeight
                                ),
                                Position = targetPos,
                            }
                        )
                        :Play()
                end
            end
        end
    end)
end

-- Common format helpers
function formatNumber(num)
    if not num then
        return '0'
    end
    if num < 1000 then
        return tostring(math.floor(num))
    end
    if num < 1000000 then
        return string.format('%.1fk', num / 1000)
    end
    if num < 1000000000 then
        return string.format('%.1fm', num / 1000000)
    end
    return string.format('%.1fb', num / 1000000000)
end
function parseHumanNumber(s)
    if not s then
        return nil
    end
    s = tostring(s):lower()
    s = s:gsub(',', ''):gsub('%s+', '')
    local mult = 1
    if s:find('k') then
        mult = 1e3
        s = s:gsub('k', '')
    elseif s:find('m') then
        mult = 1e6
        s = s:gsub('m', '')
    elseif s:find('b') then
        mult = 1e9
        s = s:gsub('b', '')
    end
    local n = tonumber(s:match('[-%d%.]+'))
    if not n then
        return nil
    end
    return n * mult
end
function toTitleCase(s)
    s = tostring(s or '')
    local lower = s:lower()
    return lower:sub(1, 1):upper() .. lower:sub(2)
end

-- Fix corrupted character encoding
function fixCorruptedText(text)
    if not text then
        return text
    end
    text = tostring(text)
    -- Fix common corrupted characters using hex codes to avoid syntax issues
    text = text:gsub('\226\128\162', '•') -- Fix bullet point (â€¢)
    text = text:gsub('\226\128\156', '"') -- Fix left quotation mark (â€œ)
    text = text:gsub('\226\128\157', '"') -- Fix right quotation mark (â€)
    return text
end

-- Player refs
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild('HumanoidRootPart')
local humanoid = char:FindFirstChildOfClass('Humanoid')
bind(player.CharacterAdded:Connect(function(c)
    if unloaded then
        return
    end
    char = c
    root = c:WaitForChild('HumanoidRootPart')
    humanoid = c:FindFirstChildOfClass('Humanoid')
end))
-- =============================
-- Plot detection (Robust)
-- =============================
plotsFolder = Workspace:FindFirstChild('Plots')
    or Workspace:WaitForChild('Plots')
myPlot = nil
lastPlotScan = 0

-- FIX: Use DisplayName for fallback check.
function getMyPlot(forceScan)
    local localPlayer = player
    if not localPlayer then
        return nil
    end
    local localPlayerName = localPlayer.Name
    local localPlayerDisplayName = localPlayer.DisplayName

    -- If we have a cached plot, verify it's still ours before returning it.
    if not forceScan and myPlot and myPlot.Parent then
        local playerValue = myPlot:FindFirstChild('Values', true)
            and myPlot.Values:FindFirstChild('Player')
        if playerValue and playerValue.Value == localPlayer then
            return myPlot -- It's still ours, return the cached plot.
        end
    end

    -- If cache is invalid or a scan is forced, find the plot again.
    myPlot = nil

    -- Method 1: Check the 'Player' ObjectValue directly (most reliable).
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local playerValue = plot:FindFirstChild('Values', true)
            and plot.Values:FindFirstChild('Player')
        if playerValue and playerValue.Value == localPlayer then
            myPlot = plot
            return plot
        end
    end

    -- Method 2: Check the avatar image in the sign (most reliable for distinguishing players with same display name)
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local playerSign = plot:FindFirstChild('PlayerSign')
        local billboard = playerSign
            and playerSign:FindFirstChildOfClass('BillboardGui')
        if billboard then
            local textLabel = billboard:FindFirstChild('Holder', true)
            if textLabel then
                textLabel = textLabel:FindFirstChild('Username')
            end
            if not textLabel then
                textLabel = billboard:FindFirstChildOfClass('TextLabel')
            end
            if textLabel and textLabel.Text == localPlayerDisplayName then
                -- Check if the avatar image matches the current player
                local avatarImage = billboard:FindFirstChild('Avatar')
                    or billboard:FindFirstChildOfClass('ImageLabel')
                if avatarImage and avatarImage:IsA('ImageLabel') then
                    -- Get the current player's avatar URL in the correct Roblox thumbnail format
                    local avatarUrl = 'rbxthumb://type=AvatarHeadShot&id='
                        .. localPlayer.UserId
                        .. '&w=180&h=180'
                    if avatarImage.Image == avatarUrl then
                        myPlot = plot
                        return plot
                    end
                end
            end
        end
    end

    -- Method 3: Fallback to checking the sign's text against DisplayName (original method)
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local playerSign = plot:FindFirstChild('PlayerSign')
        local billboard = playerSign
            and playerSign:FindFirstChildOfClass('BillboardGui')
        if billboard then
            local textLabel = billboard:FindFirstChild('Holder', true)
            if textLabel then
                textLabel = textLabel:FindFirstChild('Username')
            end
            if not textLabel then
                textLabel = billboard:FindFirstChildOfClass('TextLabel')
            end
            if textLabel and textLabel.Text == localPlayerDisplayName then
                myPlot = plot
                return plot
            end
        end
    end

    -- Method 4: Try to find plot by checking if the player is actually in the plot
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local playerSign = plot:FindFirstChild('PlayerSign')
        local billboard = playerSign
            and playerSign:FindFirstChildOfClass('BillboardGui')
        if billboard then
            local textLabel = billboard:FindFirstChild('Holder', true)
            if textLabel then
                textLabel = textLabel:FindFirstChild('Username')
            end
            if not textLabel then
                textLabel = billboard:FindFirstChildOfClass('TextLabel')
            end
            if textLabel and textLabel.Text == localPlayerDisplayName then
                -- Check if the player is actually in this plot by checking their position
                local char = localPlayer.Character
                if char and char:FindFirstChild('HumanoidRootPart') then
                    local playerPos = char.HumanoidRootPart.Position
                    local plotBounds = plot:FindFirstChild('Bounds')
                        or plot:FindFirstChild('PlotBounds')
                    if plotBounds then
                        local plotPos = plotBounds.Position
                        local plotSize = plotBounds.Size
                        -- Check if player is within the plot bounds
                        if
                            math.abs(playerPos.X - plotPos.X)
                                <= plotSize.X / 2
                            and math.abs(playerPos.Z - plotPos.Z)
                                <= plotSize.Z / 2
                        then
                            myPlot = plot
                            return plot
                        end
                    end
                end
            end
        end
    end

    return nil -- No plot found
end

-- =============================
-- THEME & COMPONENTS
-- =============================
-- Theme system
-- Dark theme colors (hardcoded)
-- Theme system
local themes = {
    dark = {
        Sidebar = Color3.fromRGB(15, 17, 21),
        SidebarExpanded = Color3.fromRGB(20, 22, 27),
        SidebarHover = Color3.fromRGB(30, 34, 42),
        SidebarActive = Color3.fromRGB(45, 50, 65),
        ContentBg = Color3.fromRGB(25, 28, 35),
        Surface = Color3.fromRGB(18, 20, 24),
        Card = Color3.fromRGB(28, 30, 36),
        Stroke = Color3.fromRGB(64, 66, 74),
        Text = Color3.fromRGB(232, 235, 240),
        Muted = Color3.fromRGB(180, 184, 192),
        Success = Color3.fromRGB(30, 200, 120),
        Danger = Color3.fromRGB(255, 90, 90),
        AccentA = Color3.fromRGB(95, 66, 255),
        AccentB = Color3.fromRGB(0, 195, 255),
        DefaultButton = Color3.fromRGB(60, 65, 75),
    },
    light = {
        -- Background & Layout Colors
        Sidebar = Color3.fromRGB(249, 250, 251), -- Soft off-white sidebar (#F9FAFB)
        SidebarExpanded = Color3.fromRGB(243, 244, 246), -- Light grey expanded state (#F3F4F6)
        SidebarHover = Color3.fromRGB(229, 231, 235), -- Medium grey hover (#E5E7EB)
        SidebarActive = Color3.fromRGB(59, 130, 246), -- Professional blue active (#3B82F6)
        ContentBg = Color3.fromRGB(248, 250, 252), -- Very light blue-grey background (#F8FAFC)
        Surface = Color3.fromRGB(255, 255, 255), -- Pure white surfaces (#FFFFFF)
        Card = Color3.fromRGB(255, 255, 255), -- Pure white cards (#FFFFFF)
        Stroke = Color3.fromRGB(209, 213, 219), -- Light grey borders (#D1D5DB)

        -- Text Colors (High Contrast)
        Text = Color3.fromRGB(17, 24, 39), -- Dark grey text (#111827) - High contrast
        Muted = Color3.fromRGB(107, 114, 128), -- Medium grey muted text (#6B7280)

        -- Status Colors
        Success = Color3.fromRGB(34, 197, 94), -- Green success (#22C55E)
        Danger = Color3.fromRGB(239, 68, 68), -- Red danger (#EF4444)

        -- Accent Colors
        AccentA = Color3.fromRGB(59, 130, 246), -- Professional blue (#3B82F6)
        AccentB = Color3.fromRGB(37, 99, 235), -- Darker blue (#2563EB)

        -- Button Colors (High Contrast)
        DefaultButton = Color3.fromRGB(60, 65, 75), -- Dark grey buttons (same as dark mode)
    },
}

-- Get current theme colors
local function getThemeColors()
    return themes[theme] or themes.dark
end
local currentTheme = getThemeColors()
local Sidebar = currentTheme.Sidebar
local SidebarExpanded = currentTheme.SidebarExpanded
local SidebarHover = currentTheme.SidebarHover
local SidebarActive = currentTheme.SidebarActive
local ContentBg = currentTheme.ContentBg
local Surface = currentTheme.Surface
local Card = currentTheme.Card
local Stroke = currentTheme.Stroke
local Text = currentTheme.Text
local Muted = currentTheme.Muted
local Success = currentTheme.Success
local Danger = currentTheme.Danger
local AccentA = currentTheme.AccentA
local AccentB = currentTheme.AccentB
local DefaultButton = currentTheme.DefaultButton
local ActiveTab = AccentA:lerp(AccentB, 0.5)

-- Theme application function
function applyTheme(newTheme)
    theme = newTheme
    local newColors = themes[theme] or themes.dark

    -- Update global color variables
    Sidebar = newColors.Sidebar
    SidebarExpanded = newColors.SidebarExpanded
    SidebarHover = newColors.SidebarHover
    SidebarActive = newColors.SidebarActive
    ContentBg = newColors.ContentBg
    Surface = newColors.Surface
    Card = newColors.Card
    Stroke = newColors.Stroke
    Text = newColors.Text
    Muted = newColors.Muted
    Success = newColors.Success
    Danger = newColors.Danger
    AccentA = newColors.AccentA
    AccentB = newColors.AccentB
    DefaultButton = newColors.DefaultButton
    ActiveTab = AccentA:lerp(AccentB, 0.5)

    -- Function to recursively apply theme to all UI elements
    local function applyThemeToInstance(instance)
        if not instance or not instance.Parent then
            return
        end

        -- Skip slider components - they have their own updateColors method
        if
            instance:IsA('Frame')
            and (
                instance.Name == 'bar'
                or instance.Name == 'fill'
                or instance.Name == 'knob'
            )
        then
            return
        end

        -- Skip window control buttons - they should keep their original colors
        if
            instance:IsA('TextButton')
            and instance.Size == UDim2.new(0, 30, 0, 30)
        then
            -- This is likely a window control button (minimize, fullscreen, close)
            -- Only update text color to black in light mode, keep background color unchanged
            if theme == 'light' then
                instance.TextColor3 = Color3.fromRGB(0, 0, 0) -- Black text in light mode
            else
                instance.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text in dark mode
            end
            return
        end

        -- Apply background colors based on element type and name
        if instance:IsA('Frame') or instance:IsA('TextButton') then
            if
                instance.Name:find('Sidebar')
                or instance.Name:find('MinimalSidebar')
            then
                instance.BackgroundColor3 = newColors.Sidebar
            elseif
                instance.Name:find('Card')
                or instance.Name:find('MainCard')
                or instance.Name:find('AlertsCard')
                or instance.Name:find('SettingsCard')
            then
                instance.BackgroundColor3 = newColors.Card
            elseif instance.Name:find('Surface') then
                instance.BackgroundColor3 = newColors.Surface
            elseif
                instance.Name:find('Content')
                or instance.Name:find('ContentArea')
            then
                instance.BackgroundColor3 = newColors.ContentBg
            elseif
                instance.Name:find('Button') or instance.Name:find('Btn')
            then
                -- Check if button has a stored state (from Components.SetState)
                if UIState[instance] then
                    -- Recalculate button color based on current theme and stored state
                    local storedState = UIState[instance].state
                    local newColor
                    if storedState == 'on' then
                        newColor = newColors.Success -- Green for on
                    else
                        -- For light mode, use Danger (red) for off state
                        -- For dark mode, use DefaultButton (grey) for off state
                        if newTheme == 'light' then
                            newColor = newColors.Danger -- Red for off in light mode
                        else
                            newColor = newColors.DefaultButton -- Grey for off in dark mode
                        end
                    end
                    instance.BackgroundColor3 = newColor
                    -- Update the stored color to the new theme's color
                    UIState[instance].color = newColor
                else
                    -- Default button color for buttons without stored state
                    instance.BackgroundColor3 = newColors.DefaultButton
                end
            elseif
                instance.Name:find('Window') or instance.Name:find('Panel')
            then
                instance.BackgroundColor3 = newColors.Surface
            elseif
                instance.Name:find('TitleBar')
                or instance.Name:find('Header')
                or instance.Name:find('TopBar')
                or instance.Name:find('TopBarGlass')
            then
                instance.BackgroundColor3 = newColors.Card
            elseif instance.Name:find('Scroll') then
                instance.BackgroundColor3 = newColors.Surface
            else
                -- Default frame color
                instance.BackgroundColor3 = newColors.Surface
            end
        end

        -- Apply text colors
        if instance:IsA('TextLabel') or instance:IsA('TextButton') then
            if instance.Name:find('Title') or instance.Name:find('Header') then
                instance.TextColor3 = newColors.Text
            elseif instance.Name:find('Muted') or instance.Name:find('Sub') then
                instance.TextColor3 = newColors.Muted
            else
                instance.TextColor3 = newColors.Text
            end
        end

        -- Apply stroke colors
        if instance:IsA('UIStroke') then
            instance.Color = newColors.Stroke
        end

        -- Apply to TextBoxes
        if instance:IsA('TextBox') then
            instance.BackgroundColor3 = newColors.Surface
            instance.TextColor3 = newColors.Text
            instance.PlaceholderColor3 = newColors.Muted
        end

        -- Recursively apply to children
        for _, child in ipairs(instance:GetChildren()) do
            applyThemeToInstance(child)
        end
    end

    -- Apply theme to main GUI
    if mainGui and mainGui.Parent then
        applyThemeToInstance(mainGui)
    end

    -- Apply theme to sidebar GUI
    local sidebarGui = CoreGui:FindFirstChild(existingGuiName .. '_Sidebar')
    if sidebarGui then
        applyThemeToInstance(sidebarGui)
    end

    -- Apply theme to minimal sidebar
    local minimalSidebar =
        CoreGui:FindFirstChild(existingGuiName .. '_MinimalSidebar')
    if minimalSidebar then
        applyThemeToInstance(minimalSidebar)
    end

    -- Update sidebar API theme
    if sidebarApi and sidebarApi.updateTheme then
        sidebarApi.updateTheme()
    end

    -- Apply theme to all open windows
    for windowType, window in pairs(openWindows or {}) do
        if window and window.Parent then
            applyThemeToInstance(window)

            -- Special handling for settings page sliders
            if windowType == 'settings' then
                -- Update slider colors using the slider API
                if refs and refs.sidebarScaleSlider then
                    refs.sidebarScaleSlider.updateColors()
                end
                if refs and refs.gameInfoScaleSlider then
                    refs.gameInfoScaleSlider.updateColors()
                end
                if refs and refs.toastScaleSlider then
                    refs.toastScaleSlider.updateColors()
                end
            end
        end
    end

    -- Apply theme to toast containers
    for _, container in ipairs({
        toastContainer,
        seedToastContainer,
        gearToastContainer,
    }) do
        if container and container.Parent then
            applyThemeToInstance(container)
        end
    end

    -- Apply theme to seed timer info GUI
    if seedTimerInfoGui and seedTimerInfoGui.Parent then
        applyThemeToInstance(seedTimerInfoGui)
    end

    -- Apply theme to game info GUI
    if gameInfoGui and gameInfoGui.Parent then
        applyThemeToInstance(gameInfoGui)
    end

    -- Apply theme to ESP GUI
    if espGui and espGui.Parent then
        applyThemeToInstance(espGui)
    end

    -- Apply theme to unload confirmation GUI
    if unloadConfirmGui and unloadConfirmGui.Parent then
        applyThemeToInstance(unloadConfirmGui)
    end

    -- Apply theme to loading GUI
    if loadingGui and loadingGui.Parent then
        applyThemeToInstance(loadingGui)
    end

    -- Force update all UI sync components
    if Components.UISync and Components.UISync.syncAll then
        pcall(Components.UISync.syncAll, uiRefs or {})
    end

    -- Update slider colors after theme is applied
    if uiRefs then
        if
            uiRefs.sidebarScaleSlider
            and uiRefs.sidebarScaleSlider.updateColors
        then
            uiRefs.sidebarScaleSlider.updateColors()
        end
        if
            uiRefs.gameInfoScaleSlider
            and uiRefs.gameInfoScaleSlider.updateColors
        then
            uiRefs.gameInfoScaleSlider.updateColors()
        end
        if uiRefs.toastScaleSlider and uiRefs.toastScaleSlider.updateColors then
            uiRefs.toastScaleSlider.updateColors()
        end
    end

    -- Update all UI states to use new theme colors
    for element, stateData in pairs(UIState) do
        if element and element.Parent and stateData then
            -- Update the stored color to use new theme colors
            local newColor = newColors.Danger -- Default to danger for off state
            if stateData.state == 'on' then
                newColor = newColors.Success
            elseif stateData.state == 'off' then
                newColor = newColors.Danger
            end
            -- Update the stored color and re-apply
            stateData.color = newColor
            pcall(function()
                TweenService:Create(
                    element,
                    TweenInfo.new(0.18),
                    { BackgroundColor3 = newColor }
                ):Play()
            end)
        end
    end
end

local Rarities = {
    Rare = Color3.fromRGB(0, 195, 255),
    Epic = Color3.fromRGB(95, 66, 255),
    Legendary = Color3.fromRGB(255, 190, 0),
    Mythic = Color3.fromRGB(255, 60, 120),
    Godly = Color3.fromRGB(0, 255, 170),
    Secret = Color3.fromRGB(255, 0, 255),
    Limited = Color3.fromRGB(255, 128, 0),
}

FX = {}
function FX.CreateOrGetBlur()
    blur = Lighting:FindFirstChild(existingGuiName .. '_UIBlur')
    if not blur then
        blur = Instance.new('BlurEffect')
        blur.Name = existingGuiName .. '_UIBlur'
        blur.Size = 0
        blur.Parent = Lighting
    end
    return blur
end
function FX.TweenBlur(enable)
    -- Prevent multiple blur operations from running simultaneously
    if blurOperationInProgress then
        return
    end

    blur = FX.CreateOrGetBlur()

    -- If blur is disabled, always set blur size to 0 (remove blur)
    if disableBlur then
        if disableAnimations then
            blur.Size = 0
        else
            blurOperationInProgress = true
            local tween = TweenService:Create(
                blur,
                TweenInfo.new(
                    0.25,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                { Size = 0 }
            )
            tween:Play()
            tween.Completed:Connect(function()
                blurOperationInProgress = false
            end)
        end
        return
    end

    local target = enable and 12 or 0

    -- If animations are disabled, set blur size immediately
    if disableAnimations then
        blur.Size = target
    else
        blurOperationInProgress = true
        local tween = TweenService:Create(
            blur,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = target }
        )
        tween:Play()
        tween.Completed:Connect(function()
            blurOperationInProgress = false
        end)
    end
end

-- Helper function to create tweens that respect the disableAnimations setting
function FX.CreateTween(object, tweenInfo, properties)
    if disableAnimations then
        -- If animations are disabled, apply properties immediately
        for property, value in pairs(properties) do
            object[property] = value
        end
        return {
            Play = function() end,
            Completed = { Connect = function() end },
        } -- Dummy tween object
    else
        return TweenService:Create(object, tweenInfo, properties)
    end
end

-- Add math.clamp function if it doesn't exist
if not math.clamp then
    function math.clamp(value, min, max)
        return math.max(min, math.min(max, value))
    end
end

Components = {}

UIState = setmetatable({}, { __mode = 'k' })
-- Centralized UI sync helpers (populated during GUI build)
Components.UISync = {}

-- Add missing toggle functions

function Components.UISync.toggleAutoEquipBest(enabled)
    autoEquipBestEnabled = enabled
    if enabled then
        nextEquipBestTime = time() + autoEquipBestIntervalSec
    else
    end
    -- Update button state if it exists
    if uiRefs and uiRefs.autoEquipBestBtn then
        Components.SetState(
            uiRefs.autoEquipBestBtn,
            enabled and 'on' or 'off',
            enabled and Success or DefaultButton
        )
    end
end

-- Helpers extracted to keep main scopes small (helps low-register executors)
function setupDragHandlers(frame, topBar, topGlass, topTitle)
    local dragging, dragStart, startCenter
    local viewport = (
        Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize
    ) or Vector2.new(1920, 1080)
    if Workspace.CurrentCamera then
        bind(
            Workspace.CurrentCamera
                :GetPropertyChangedSignal('ViewportSize')
                :Connect(function()
                    viewport = Workspace.CurrentCamera.ViewportSize
                end)
        )
    end
    function clamp(n, a, b)
        return n < a and a or n > b and b or n
    end
    function updateDrag(input)
        if not dragging then
            return
        end
        if not dragStart or not startCenter then
            return
        end
        local delta = input.Position - dragStart
        local newX = startCenter.X + delta.X
        local newY = startCenter.Y + delta.Y
        local absSize = frame.AbsoluteSize
        local minX, minY = 0, 0
        local maxX, maxY = viewport.X - absSize.X, viewport.Y - absSize.Y
        if newX < minX then
            newX = minX
        elseif newX > maxX then
            newX = maxX
        end
        if newY < minY then
            newY = minY
        elseif newY > maxY then
            newY = maxY
        end
        frame.Position = UDim2.fromOffset(newX, newY)
    end
    function beginDrag(input)
        if unloaded then
            return
        end
        dragging = true
        dragStart = input.Position
        local absPos = frame.AbsolutePosition
        startCenter = Vector2.new(absPos.X, absPos.Y) -- Use top-left position, not center
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
    function hook(el)
        if not el then
            return
        end
        el.Active = true
        el.Selectable = true
        bind(el.InputBegan:Connect(function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                beginDrag(input)
            end
        end))
    end
    hook(topBar)
    hook(topGlass)
    hook(topTitle)
    bind(UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then
            updateDrag(input)
        end
    end))
    bind(UserInputService.InputEnded:Connect(function(input)
        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = false
        end
    end))
end
function setupGuiVisibility(mainGui, sidebarContainer, sidebarApi, openWindows)
    local guiVisible = true
    local isAnimating = false

    function showGui()
        if unloaded then
            return
        end
        ensureOverlay()
        FX.TweenBlur(true)
        mainGui.Enabled = true
        guiVisible = true
        -- Show sidebar
        if sidebarContainer then
            sidebarContainer.Enabled = true
        end
        -- Make sure sidebar is visible (in case it was hidden by S button)
        if sidebarApi and sidebarApi.sidebar then
            sidebarApi.sidebar.Visible = true
        end

        -- Animate all open windows with pop-in effect when showing
        if openWindows then
            for windowType, window in pairs(openWindows) do
                if window and window.Parent then
                    -- Set initial state for pop-in animation
                    window.Size = UDim2.new(0, 0, 0, 0)
                    window.Position = UDim2.new(0.5, 0, 0.5, 0)
                    window.BackgroundTransparency = 1

                    -- Hide all content initially
                    for _, child in pairs(window:GetChildren()) do
                        if
                            child:IsA('GuiObject')
                            and child.Name ~= 'UICorner'
                            and child.Name ~= 'UIStroke'
                        then
                            child.Visible = false
                        end
                    end

                    -- Create a smooth pop-in animation
                    local popInTween = FX.CreateTween(
                        window,
                        TweenInfo.new(
                            0.3,
                            Enum.EasingStyle.Back,
                            Enum.EasingDirection.Out
                        ),
                        {
                            Size = window:GetAttribute('OriginalSize')
                                or UDim2.new(0, 600, 0, 400),
                            Position = window:GetAttribute('CurrentPosition')
                                or window:GetAttribute('OriginalPosition')
                                or UDim2.new(0.5, -300, 0.5, -200),
                            BackgroundTransparency = 0,
                        }
                    )

                    popInTween:Play()

                    -- Show content after a short delay to prevent flash
                    task.delay(0.1, function()
                        for _, child in pairs(window:GetChildren()) do
                            if
                                child:IsA('GuiObject')
                                and child.Name ~= 'UICorner'
                                and child.Name ~= 'UIStroke'
                            then
                                child.Visible = true
                            end
                        end
                    end)
                end
            end
        end

        -- Don't remove minimal sidebar here - let the S button handle its own lifecycle
        -- The minimal sidebar should only be destroyed when the S button is clicked
        -- Reset sidebar state when showing GUI, but respect keepSidebarOpen setting
        -- Don't reset if we're about to animate
        if not isAnimating and sidebarApi and sidebarApi.resetSidebar then
            if keepSidebarOpen then
                -- If keep sidebar open is enabled, just ensure it's in the correct state
                -- Don't reset it to closed
            else
                sidebarApi.resetSidebar()
            end
        end
    end

    function hideGui()
        if unloaded then
            return
        end
        closeAllDropdowns()
        guiVisible = false

        -- Animate all open windows with pop-out effect before hiding GUI
        if openWindows then
            local animationCount = 0
            local totalWindows = 0

            -- Count total windows to animate
            for windowType, window in pairs(openWindows) do
                if window and window.Parent then
                    totalWindows = totalWindows + 1
                end
            end

            if totalWindows > 0 then
                -- Animate each window
                for windowType, window in pairs(openWindows) do
                    if window and window.Parent then
                        -- Create a smooth pop-out animation
                        local popOutTween = FX.CreateTween(
                            window,
                            TweenInfo.new(
                                0.3,
                                Enum.EasingStyle.Back,
                                Enum.EasingDirection.In
                            ),
                            {
                                Size = UDim2.new(0, 0, 0, 0),
                                Position = UDim2.new(0.5, 0, 0.5, 0),
                                BackgroundTransparency = 1,
                            }
                        )

                        popOutTween:Play()
                        animationCount = animationCount + 1

                        -- Hide content after a short delay to sync with animation (or immediately if animations disabled)
                        if disableAnimations then
                            -- Hide content immediately if animations are disabled
                            for _, child in pairs(window:GetChildren()) do
                                if
                                    child:IsA('GuiObject')
                                    and child.Name ~= 'UICorner'
                                    and child.Name ~= 'UIStroke'
                                then
                                    child.Visible = false
                                end
                            end
                        else
                            -- Hide content after a short delay to sync with animation
                            spawn(function()
                                wait(0.1) -- Small delay to let animation start
                                for _, child in pairs(window:GetChildren()) do
                                    if
                                        child:IsA('GuiObject')
                                        and child.Name ~= 'UICorner'
                                        and child.Name ~= 'UIStroke'
                                    then
                                        child.Visible = false
                                    end
                                end
                            end)
                        end
                    end
                end

                -- Wait for animation to complete before hiding GUI
                spawn(function()
                    wait(0.3) -- Wait for pop-out animation to complete
                    mainGui.Enabled = false
                    -- Hide sidebar
                    if sidebarContainer then
                        sidebarContainer.Enabled = false
                    end
                    FX.TweenBlur(false)
                end)
            else
                -- No windows to animate, hide GUI immediately
                mainGui.Enabled = false
                -- Hide sidebar
                if sidebarContainer then
                    sidebarContainer.Enabled = false
                end
                FX.TweenBlur(false)
            end
        else
            -- No openWindows table, hide GUI immediately
            mainGui.Enabled = false
            -- Hide sidebar
            if sidebarContainer then
                sidebarContainer.Enabled = false
            end
            FX.TweenBlur(false)
        end
    end

    function toggleGui()
        if guiVisible then
            hideGui()
        else
            showGui()
        end
    end

    bind(UserInputService.InputBegan:Connect(function(i)
        if unloaded then
            return
        end
        if i.KeyCode == Enum.KeyCode.LeftAlt then
            -- Alt key should always work regardless of mobile button setting

            -- Debounce rapid Alt presses to prevent blur conflicts
            if lastAltPress and tick() - lastAltPress < 0.5 then
                return -- Ignore rapid presses
            end
            lastAltPress = tick()

            -- Check current GUI state before toggling
            local wasVisible = guiVisible

            toggleGui()

            -- Only animate sidebar slide-out when hiding GUI
            if not wasVisible and sidebarApi and sidebarApi.animateSlideIn then
                -- GUI is being shown, animate slide-in
                isAnimating = true
                -- Set sidebar to off-screen position immediately
                if sidebarApi.setOffScreenPosition then
                    sidebarApi.setOffScreenPosition()
                end
                -- Delay the animation slightly to ensure GUI is fully shown first
                spawn(function()
                    wait(0.1)
                    sidebarApi.animateSlideIn()
                    isAnimating = false
                end)
            elseif wasVisible and sidebarApi then
                -- GUI is being hidden, first close sidebar if it's open
                if sidebarApi.closeSidebar then
                    sidebarApi.closeSidebar()
                end
                -- Then animate slide-out
                if sidebarApi.animateSlideOut then
                    isAnimating = true
                    sidebarApi.animateSlideOut()
                    -- Reset flag after animation duration
                    spawn(function()
                        wait(0.4)
                        isAnimating = false
                    end)
                end
            end
        end
    end))
end

-- Missing toggle functions from original script
function toggleGameInfo(on)
    gameInfoEnabled = on
    if gameInfoGui then
        gameInfoGui.Enabled = on
    end
    if on then
        animateGameInfoShow()
        startGameInfoThread()
    else
        stopGameInfoThread()
    end
end

-- =============================
-- Seed Timer Info
-- =============================
function buildSeedTimerInfoGui()
    if seedTimerInfoGui then
        pcall(function()
            seedTimerInfoGui:Destroy()
        end)
        seedTimerInfoGui = nil
    end

    seedTimerInfoGui = New('ScreenGui', {
        Name = existingGuiName .. '_SeedTimerInfo',
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
        Enabled = false,
        Parent = CoreGui,
    })

    -- Position to the right of the sidebar
    local sidebarWidth = 280 -- Approximate sidebar width
    local sidebarPosition = sidebarLocation == 'Left' and 0
        or (1 - sidebarWidth / 1920) -- Convert to UDim2 scale
    local xPosition = sidebarLocation == 'Left' and (sidebarWidth + 20)
        or (1920 - sidebarWidth - 320) -- 320 = window width + margin

    local infoFrame = New('Frame', {
        Parent = seedTimerInfoGui,
        Size = UDim2.new(0, 300, 0, 200),
        Position = UDim2.new(0, xPosition, 0, 20),
        BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 12) }),
        New('UIStroke', {
            Color = Color3.fromRGB(100, 100, 255),
            Thickness = 2,
            Transparency = 0.3,
        }),
    })

    local titleLabel = New('TextLabel', {
        Parent = infoFrame,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = 'Seed Timer Info',
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local scrollFrame = New('ScrollingFrame', {
        Parent = infoFrame,
        Size = UDim2.new(1, -20, 1, -50),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageTransparency = 0.3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    -- Store references in a proper table
    seedTimerInfoRefs = {
        infoFrame = infoFrame,
        scrollFrame = scrollFrame,
        titleLabel = titleLabel,
    }
end
-- Store previous plant data for comparison
local previousPlants = {}
local plantLabels = {}
function updateSeedTimerInfo()
    if
        not seedTimerInfoEnabled
        or not seedTimerInfoGui
        or not seedTimerInfoGui.Enabled
    then
        return
    end

    local plot = getMyPlot()
    if not plot then
        return
    end

    local hitboxesFolder = plot:FindFirstChild('Hitboxes')
    if not hitboxesFolder then
        return
    end

    local countdownsFolder = Workspace:FindFirstChild('ScriptedMap')
    countdownsFolder = countdownsFolder
        and countdownsFolder:FindFirstChild('Countdowns')
    if not countdownsFolder then
        return
    end

    local scrollFrame = seedTimerInfoRefs.scrollFrame
    if not scrollFrame then
        return
    end

    local plants = {}

    for _, hitbox in ipairs(hitboxesFolder:GetChildren()) do
        if hitbox:IsA('BasePart') then
            local uuid = hitbox.Name
            local countdown = countdownsFolder:FindFirstChild(uuid)

            if countdown then
                local gui = countdown:FindFirstChild('GUI')
                if gui then
                    local titleObj = gui:FindFirstChild('Title')
                    local progressObj = gui:FindFirstChild('Progress')
                    local timeLeftObj = gui:FindFirstChild('TimeLeft')

                    local plantName = (
                        titleObj
                        and titleObj:IsA('TextLabel')
                        and titleObj.Text
                    ) or 'Plant'
                    local progress = (
                        progressObj
                        and progressObj:IsA('TextLabel')
                        and progressObj.Text
                    ) or '0%'
                    local timeLeft = (
                        timeLeftObj
                        and timeLeftObj:IsA('TextLabel')
                        and timeLeftObj.Text
                    ) or '0s'

                    -- Parse time to sort by remaining time
                    local timeInSeconds = 0
                    if timeLeft and timeLeft ~= '0s' and timeLeft ~= '' then
                        -- Handle different time formats more robustly
                        if timeLeft:find('h') then
                            -- Handle hours (e.g., "1h", "2h 30m")
                            local hours = tonumber(timeLeft:match('(%d+)h'))
                                or 0
                            local minutes = tonumber(timeLeft:match('(%d+)m'))
                                or 0
                            timeInSeconds = hours * 3600 + minutes * 60
                        elseif timeLeft:find('m') then
                            -- Handle minutes (e.g., "30m", "5m")
                            local minutes = tonumber(timeLeft:match('(%d+)m'))
                                or 0
                            timeInSeconds = minutes * 60
                        elseif timeLeft:find('s') then
                            -- Handle seconds (e.g., "30s", "5s")
                            local seconds = tonumber(timeLeft:match('(%d+)s'))
                                or 0
                            timeInSeconds = seconds
                        else
                            -- Fallback: try to parse as number
                            timeInSeconds = tonumber(timeLeft) or 0
                        end
                    end

                    table.insert(plants, {
                        name = plantName,
                        progress = progress,
                        timeLeft = timeLeft,
                        timeInSeconds = timeInSeconds,
                        uuid = uuid,
                    })
                end
            end
        end
    end

    -- Sort by time remaining (lowest time first)
    -- Use stable sort to maintain consistent ordering for plants with same time
    table.sort(plants, function(a, b)
        if a.timeInSeconds == b.timeInSeconds then
            -- If times are equal, sort by name for consistency
            return a.name < b.name
        end
        return a.timeInSeconds < b.timeInSeconds
    end)

    -- Debug: Print sorted order (can be removed later)
    if #plants > 0 then
        print('Seed Timer Info - Sorted by time remaining:')
        for i, plant in ipairs(plants) do
            print(
                string.format(
                    '  %d. %s - %s (%ds)',
                    i,
                    plant.name,
                    plant.timeLeft,
                    plant.timeInSeconds
                )
            )
        end
    end

    -- Check if order changed by comparing UUIDs and positions
    local orderChanged = false
    if #plants == #previousPlants then
        for i, plant in ipairs(plants) do
            if
                not previousPlants[i]
                or plant.uuid ~= previousPlants[i].uuid
            then
                orderChanged = true
                break
            end
        end
    else
        orderChanged = true
    end

    -- Also check if any plant's time has changed significantly (watered)
    if not orderChanged then
        for i, plant in ipairs(plants) do
            if previousPlants[i] then
                local timeDiff = math.abs(
                    plant.timeInSeconds - previousPlants[i].timeInSeconds
                )
                -- If time changed by more than 5 seconds, consider it a significant change
                if timeDiff > 5 then
                    orderChanged = true
                    break
                end
            end
        end
    end

    -- Update or create labels
    for i, plant in ipairs(plants) do
        local label = plantLabels[plant.uuid]

        if not label then
            -- Create new label
            label = New('TextLabel', {
                Parent = scrollFrame,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Text = string.format(
                    '%s\n%s • %s',
                    plant.name,
                    plant.progress,
                    plant.timeLeft
                ),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                LayoutOrder = i,
            }, {
                New('UIStroke', {
                    Color = Color3.new(0, 0, 0),
                    Thickness = 1,
                    Transparency = 0.5,
                }),
            })
            plantLabels[plant.uuid] = label
        else
            -- Update existing label
            label.Text = string.format(
                '%s\n%s • %s',
                plant.name,
                plant.progress,
                plant.timeLeft
            )

            if orderChanged then
                -- Animate to new position
                local newPosition = UDim2.new(0, 0, 0, (i - 1) * 40)
                TweenService
                    :Create(
                        label,
                        TweenInfo.new(
                            0.3,
                            Enum.EasingStyle.Quart,
                            Enum.EasingDirection.Out
                        ),
                        {
                            Position = newPosition,
                        }
                    )
                    :Play()
            end

            label.LayoutOrder = i
        end
    end

    -- Remove labels for plants that no longer exist
    for uuid, label in pairs(plantLabels) do
        local stillExists = false
        for _, plant in ipairs(plants) do
            if plant.uuid == uuid then
                stillExists = true
                break
            end
        end

        if not stillExists then
            -- Animate out and destroy
            TweenService:Create(
                label,
                TweenInfo.new(
                    0.2,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = UDim2.new(1, 0, 0, 0),
                    TextTransparency = 1,
                }
            ):Play()

            task.delay(0.2, function()
                if label and label.Parent then
                    label:Destroy()
                end
            end)

            plantLabels[uuid] = nil
        end
    end

    -- Store current plants for next comparison
    previousPlants = {}
    for i, plant in ipairs(plants) do
        previousPlants[i] = {
            uuid = plant.uuid,
            name = plant.name,
            progress = plant.progress,
            timeLeft = plant.timeLeft,
            timeInSeconds = plant.timeInSeconds,
        }
    end

    local plantCount = #plants

    -- Update title with count
    if seedTimerInfoRefs.titleLabel then
        seedTimerInfoRefs.titleLabel.Text =
            string.format('Seed Timer Info (%d plants)', plantCount)
    end
end

function startSeedTimerInfoThread()
    if seedTimerInfoThread then
        return
    end
    seedTimerInfoThread = task.spawn(function()
        while seedTimerInfoEnabled and not unloaded do
            updateSeedTimerInfo()
            task.wait(1) -- Update every second
        end
    end)
end

function stopSeedTimerInfoThread()
    if seedTimerInfoThread then
        task.cancel(seedTimerInfoThread)
        seedTimerInfoThread = nil
    end

    -- Clean up plant labels
    for uuid, label in pairs(plantLabels) do
        if label and label.Parent then
            label:Destroy()
        end
    end
    plantLabels = {}
    previousPlants = {}
end

function toggleSeedTimerInfo(on)
    seedTimerInfoEnabled = on
    if on then
        if not seedTimerInfoGui then
            buildSeedTimerInfoGui()
        end
        seedTimerInfoGui.Enabled = true
        startSeedTimerInfoThread()
    else
        if seedTimerInfoGui then
            seedTimerInfoGui.Enabled = false
        end
        stopSeedTimerInfoThread()
    end
end
-- =============================
-- Unload Confirmation
-- =============================
function buildUnloadConfirmGui()
    if unloadConfirmGui then
        pcall(function()
            unloadConfirmGui:Destroy()
        end)
        unloadConfirmGui = nil
    end

    unloadConfirmGui = New('ScreenGui', {
        Name = existingGuiName .. '_UnloadConfirm',
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 200,
        Enabled = false,
        Parent = CoreGui,
    })

    -- Background overlay
    local overlay = New('TextButton', {
        Parent = unloadConfirmGui,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = '',
        Active = true,
    })

    -- Border frame (for the blue border)
    local borderFrame = New('Frame', {
        Parent = unloadConfirmGui,
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, -200, 0.5, -100),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 16) }),
        New('UIStroke', { Color = AccentA, Thickness = 2, Transparency = 0.3 }),
    })

    -- Main dialog frame
    local dialogFrame = New('TextButton', {
        Parent = borderFrame,
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = theme == 'light' and Color3.fromRGB(255, 255, 255)
            or Surface,
        BackgroundTransparency = theme == 'light' and 0 or 0.1,
        BorderSizePixel = 0,
        Text = '',
        Active = true,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 14) }),
    })

    -- Title
    local titleLabel = New('TextLabel', {
        Parent = dialogFrame,
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Text = 'Confirm Unload',
        TextColor3 = Text,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    -- Message
    local messageLabel = New('TextLabel', {
        Parent = dialogFrame,
        Size = UDim2.new(1, -40, 0, 60),
        Position = UDim2.new(0, 20, 0, 70),
        BackgroundTransparency = 1,
        Text = 'Are you sure you want to unload the script?\nThis will close all features and windows.',
        TextColor3 = Muted,
        TextSize = 16,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Top,
    })

    -- Button container
    local buttonContainer = New('Frame', {
        Parent = dialogFrame,
        Size = UDim2.new(1, -40, 0, 50),
        Position = UDim2.new(0, 20, 1, -70),
        BackgroundTransparency = 1,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 15),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    -- Cancel button
    local cancelButton = New('TextButton', {
        Parent = buttonContainer,
        Size = UDim2.new(0, 120, 0, 40),
        BackgroundColor3 = Color3.fromRGB(60, 60, 70),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = 'Cancel',
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        Active = true,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        New('UIStroke', {
            Color = Color3.fromRGB(100, 100, 100),
            Thickness = 1,
            Transparency = 0.5,
        }),
    })

    -- Confirm button
    local confirmButton = New('TextButton', {
        Parent = buttonContainer,
        Size = UDim2.new(0, 120, 0, 40),
        BackgroundColor3 = Color3.fromRGB(220, 50, 50),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = 'Unload',
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        Active = true,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        New('UIStroke', {
            Color = Color3.fromRGB(255, 100, 100),
            Thickness = 1,
            Transparency = 0.3,
        }),
    })

    -- Store references
    unloadConfirmRefs = {
        overlay = overlay,
        borderFrame = borderFrame,
        dialogFrame = dialogFrame,
        titleLabel = titleLabel,
        messageLabel = messageLabel,
        cancelButton = cancelButton,
        confirmButton = confirmButton,
    }

    -- Button events
    cancelButton.MouseButton1Click:Connect(function()
        hideUnloadConfirm()
    end)

    confirmButton.MouseButton1Click:Connect(function()
        hideUnloadConfirm()
        unload()
    end)

    -- Close on overlay click
    overlay.MouseButton1Click:Connect(function()
        hideUnloadConfirm()
    end)

    -- Prevent dialog from closing when clicking inside it
    dialogFrame.MouseButton1Click:Connect(function()
        -- Do nothing, just prevent event bubbling
    end)
end

function showUnloadConfirm()
    -- Use task.spawn to avoid blocking
    task.spawn(function()
        if not unloadConfirmGui then
            buildUnloadConfirmGui()
        end

        -- Ensure GUI is properly initialized
        if
            not unloadConfirmRefs.borderFrame or not unloadConfirmRefs.overlay
        then
            return -- Exit if references aren't ready
        end

        unloadConfirmGui.Enabled = true

        -- Animate in
        local borderFrame = unloadConfirmRefs.borderFrame
        local overlay = unloadConfirmRefs.overlay

        -- Start with invisible
        borderFrame.Size = UDim2.new(0, 0, 0, 0)
        borderFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        overlay.BackgroundTransparency = 1

        -- Animate overlay
        local overlayTween = TweenService:Create(
            overlay,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 0.5,
            }
        )

        -- Animate dialog
        local dialogTween = TweenService:Create(
            borderFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, 400, 0, 200),
                Position = UDim2.new(0.5, -200, 0.5, -100),
            }
        )

        overlayTween:Play()
        dialogTween:Play()
    end)
end

function hideUnloadConfirm()
    if not unloadConfirmGui or not unloadConfirmGui.Enabled then
        return
    end

    local borderFrame = unloadConfirmRefs.borderFrame
    local overlay = unloadConfirmRefs.overlay

    -- Animate out
    local overlayTween = TweenService:Create(
        overlay,
        TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {
            BackgroundTransparency = 1,
        }
    )

    local dialogTween = TweenService:Create(
        borderFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }
    )

    overlayTween:Play()
    dialogTween:Play()

    -- Hide after animation
    dialogTween.Completed:Connect(function()
        unloadConfirmGui.Enabled = false
    end)
end

-- =============================
-- Loading Animation
-- =============================
function buildLoadingGui()
    if loadingGui then
        pcall(function()
            loadingGui:Destroy()
        end)
        loadingGui = nil
    end

    loadingGui = New('ScreenGui', {
        Name = existingGuiName .. '_Loading',
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 10000,
        Enabled = true,
        Parent = CoreGui,
        IgnoreGuiInset = true,
    })

    -- Background overlay
    local background = New('Frame', {
        Parent = loadingGui,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(15, 15, 20),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    })

    -- Minimal loading container
    local loadingContainer = New('Frame', {
        Parent = loadingGui,
        Size = UDim2.new(0, 200, 0, 100),
        Position = UDim2.new(0.5, -100, 0.5, -50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    -- Modern logo
    local logo = New('TextLabel', {
        Parent = loadingContainer,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = 'S',
        TextColor3 = AccentA,
        TextSize = 42,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    -- Minimal progress line
    local progressLine = New('Frame', {
        Parent = loadingContainer,
        Size = UDim2.new(0, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 70),
        BackgroundColor3 = AccentA,
        BorderSizePixel = 0,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 1) }),
    })

    -- Store references
    loadingRefs = {
        gui = loadingGui,
        background = background,
        container = loadingContainer,
        logo = logo,
        progressLine = progressLine,
    }
end

function startLoadingAnimation()
    if loadingAnimationThread then
        return
    end

    loadingAnimationThread = task.spawn(function()
        -- Initial logo scale animation
        if loadingRefs.logo then
            loadingRefs.logo.Size = UDim2.new(0, 0, 0, 0)
            loadingRefs.logo.Position = UDim2.new(0.5, 0, 0.5, 0)

            local scaleIn = TweenService:Create(
                loadingRefs.logo,
                TweenInfo.new(
                    0.6,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = UDim2.new(1, 0, 0, 60),
                    Position = UDim2.new(0, 0, 0, 0),
                }
            )
            scaleIn:Play()
        end

        -- Wait for scale animation
        task.wait(0.6)

        -- Progress line animation
        if loadingRefs.progressLine then
            local progressTween = TweenService:Create(
                loadingRefs.progressLine,
                TweenInfo.new(
                    0.8,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = UDim2.new(1, 0, 0, 2),
                }
            )
            progressTween:Play()
        end

        -- Brief pause
        task.wait(0.2)

        -- Quick fade out
        if loadingRefs.background then
            local fadeOut = TweenService:Create(
                loadingRefs.background,
                TweenInfo.new(
                    0.4,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.In
                ),
                {
                    BackgroundTransparency = 1,
                }
            )
            fadeOut:Play()
        end

        if loadingRefs.container then
            local scaleOut = TweenService:Create(
                loadingRefs.container,
                TweenInfo.new(
                    0.4,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.In
                ),
                {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                }
            )
            scaleOut:Play()

            -- Hide after animation
            scaleOut.Completed:Connect(function()
                if loadingGui then
                    loadingGui.Enabled = false
                end
                if loadingAnimationThread then
                    task.cancel(loadingAnimationThread)
                    loadingAnimationThread = nil
                end

                -- Show startup toast after loading animation completes
                showStartupToast()
            end)
        end
    end)
end

-- hideLoadingAnimation function removed - now handled in startLoadingAnimation

-- =============================
-- Toast Notification System
-- =============================
-- Global variable to track startup toast
startupToast = nil
-- Table to store active toasts for repositioning
activeToasts = {}

function showToast(title, message, duration)
    duration = duration or 3 -- Default 3 seconds

    -- Calculate position based on startup toast visibility
    local yPosition = 20 -- Default top position
    if startupToast and startupToast.Parent then
        yPosition = 90 -- Position below startup toast (60px height + 10px gap)
    end

    -- Create toast
    local toast = New('Frame', {
        Parent = toastsGui,
        Size = UDim2.new(0, 400, 0, 60),
        Position = UDim2.new(0.5, -200, 0, yPosition),
        BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 1000,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 12) }),
        New('UIStroke', {
            Color = Color3.fromRGB(100, 100, 255),
            Thickness = 2,
            Transparency = 0.3,
        }),
    })

    -- Toast content
    local content = New('Frame', {
        Parent = toast,
        Size = UDim2.new(1, -20, 1, -10),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    -- Icon
    local icon = New('TextLabel', {
        Parent = content,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 0, 0.5, -15),
        BackgroundTransparency = 1,
        Text = '💬',
        TextColor3 = Color3.fromRGB(100, 150, 255),
        TextSize = 20,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    -- Title
    local titleLabel = New('TextLabel', {
        Parent = content,
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.new(0, 40, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    -- Message
    local messageLabel = New('TextLabel', {
        Parent = content,
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.new(0, 40, 0, 25),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    -- Animate in
    toast.Size = UDim2.new(0, 0, 0, 0)
    toast.Position = UDim2.new(0.5, 0, 0, yPosition)

    local slideInTween = TweenService:Create(
        toast,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 400, 0, 60),
            Position = UDim2.new(0.5, -200, 0, yPosition),
        }
    )

    slideInTween:Play()

    -- Auto-hide after duration
    task.spawn(function()
        task.wait(duration)

        -- Animate out
        local slideOutTween = TweenService:Create(
            toast,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0, yPosition),
            }
        )

        slideOutTween:Play()

        slideOutTween.Completed:Connect(function()
            if toast and toast.Parent then
                toast:Destroy()
            end
        end)
    end)

    -- Store toast reference for potential repositioning
    table.insert(activeToasts, toast)

    -- Function to move toast to top when startup toast disappears
    local function moveToTop()
        if toast and toast.Parent then
            local moveTween = TweenService:Create(
                toast,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.Out
                ),
                {
                    Position = UDim2.new(0.5, -200, 0, 20),
                }
            )
            moveTween:Play()
        end
    end

    -- Connect to startup toast completion
    if startupToast then
        startupToast.Completed:Connect(moveToTop)
    end
end

-- =============================
-- Startup Toast
-- =============================
function showStartupToast()
    -- Wait a moment for the loading animation to fully complete
    task.wait(0.5)

    -- Create startup toast
    local toast = New('Frame', {
        Parent = toastsGui,
        Size = UDim2.new(0, 400, 0, 60),
        Position = UDim2.new(0.5, -200, 0, 20),
        BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 1000,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 12) }),
        New('UIStroke', {
            Color = Color3.fromRGB(100, 100, 255),
            Thickness = 2,
            Transparency = 0.3,
        }),
    })

    -- Store reference to startup toast
    startupToast = toast

    -- Toast content
    local content = New('Frame', {
        Parent = toast,
        Size = UDim2.new(1, -20, 1, -10),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    -- Icon
    local icon = New('TextLabel', {
        Parent = content,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 0, 0.5, -15),
        BackgroundTransparency = 1,
        Text = 'ℹ️',
        TextColor3 = Color3.fromRGB(100, 150, 255),
        TextSize = 20,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    -- Message
    local message = New('TextLabel', {
        Parent = content,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = 'Press ALT to toggle interface or press S on the sidebar.',
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    })

    -- Animate in
    toast.Size = UDim2.new(0, 0, 0, 0)
    toast.Position = UDim2.new(0.5, 0, 0, 20)

    local slideInTween = TweenService:Create(
        toast,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 400, 0, 60),
            Position = UDim2.new(0.5, -200, 0, 20),
        }
    )

    slideInTween:Play()

    -- Auto-hide after 5 seconds
    task.spawn(function()
        task.wait(5)

        -- Animate out
        local slideOutTween = TweenService:Create(
            toast,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0, 20),
            }
        )

        slideOutTween:Play()

        slideOutTween.Completed:Connect(function()
            if toast and toast.Parent then
                -- Clear startup toast reference
                startupToast = nil

                -- Move any other toasts to the top
                for i, activeToast in ipairs(activeToasts) do
                    if
                        activeToast
                        and activeToast.Parent
                        and activeToast ~= toast
                    then
                        local moveTween = TweenService:Create(
                            activeToast,
                            TweenInfo.new(
                                0.3,
                                Enum.EasingStyle.Quart,
                                Enum.EasingDirection.Out
                            ),
                            {
                                Position = UDim2.new(0.5, -200, 0, 20),
                            }
                        )
                        moveTween:Play()
                    end
                end

                toast:Destroy()
            end
        end)
    end)
end

-- Missing seed alert variables and constants
SEED_ORDER = {
    'Mr Carrot Seed',
    'Tomatrio Seed',
    'Shroombino Seed',
    'Cactus Seed',
    'Sunflower Seed',
    'Corn Seed',
    'Pumpkin Seed',
    'Watermelon Seed',
    'Strawberry Seed',
    'Blueberry Seed',
    'Grape Seed',
    'Apple Seed',
    'Orange Seed',
    'Lemon Seed',
    'Lime Seed',
    'Cherry Seed',
    'Peach Seed',
    'Pear Seed',
    'Plum Seed',
    'Banana Seed',
    'Pineapple Seed',
    'Coconut Seed',
    'Mango Seed',
    'Kiwi Seed',
    'Dragon Fruit Seed',
}
-- seedFilterDropdownApi removed - now using refs
seedFiltersInitialized = false
seedTimerWatchThread = nil
observedTimerConn = nil
_seedShopBindings = {}
_seedAlertSeen = {}

-- Missing seed alert functions from original script
function defaultSeedSelection()
    local m = {}
    for _, n in ipairs(SEED_ORDER) do
        if
            n == 'Mr Carrot Seed'
            or n == 'Tomatrio Seed'
            or n == 'Shroombino Seed'
        then
            m[n] = true
        else
            m[n] = false
        end
    end
    return m
end

-- Function removed - duplicate exists later in file

function startSeedTimerWatcher()
    seedTimerWatchThread = task.spawn(function()
        while seedAlertEnabled and not unloaded do
            -- Placeholder - seed timer watching functionality
            task.wait(1)
        end
    end)
end
function bindSeedShopItem(seedItem)
    if not seedItem or _seedShopBindings[seedItem] then
        return
    end
    local stock = seedItem:FindFirstChild('Stock')
    local title = seedItem:FindFirstChild('Title')
    if not stock or not title then
        return
    end
    function onTextChanged()
        if not seedAlertEnabled or unloaded then
            return
        end
        local count = parseStockCount(stock.Text)
        if (count or 0) == 0 and title.Text and title.Text ~= '' then
            _seedAlertSeen[title.Text] = nil
        end
    end
    local conn =
        bind(stock:GetPropertyChangedSignal('Text'):Connect(onTextChanged))
    _seedShopBindings[seedItem] = conn
    bind(seedItem.AncestryChanged:Connect(function(_, parent)
        if not parent then
            safeDisconnectSeedBinding(seedItem)
        end
    end))
end

function startSeedShopBindings()
    local seedsFrame =
        game:GetService('Players').LocalPlayer.PlayerGui.Main.Seeds
    if not seedsFrame then
        return
    end
    for _, child in ipairs(seedsFrame:GetChildren()) do
        if child:IsA('Frame') then
            task.delay(0.02, function()
                bindSeedShopItem(child)
            end)
        end
    end
    bind(seedsFrame.ChildAdded:Connect(function(child)
        task.delay(0.02, function()
            if child:IsA('Frame') then
                bindSeedShopItem(child)
            end
        end)
    end))
end

function checkSeedStock()
    if not seedAlertEnabled or unloaded then
        return
    end
    -- Placeholder - seed stock checking functionality
    -- This would normally check the seed shop for stock changes
end

function safeDisconnectSeedBinding(item)
    local c = _seedShopBindings[item]
    if c then
        pcall(function()
            c:Disconnect()
        end)
        _seedShopBindings[item] = nil
    end
end

function toggleSeedAlerts(on)
    seedAlertEnabled = on
    if on then
        _seedAlertSeen = {}
        ensureSeedFiltersPopulated()
        startSeedTimerWatcher()
        task.delay(0.02, startSeedShopBindings)
        task.delay(0.2, checkSeedStock)
    else
        if seedTimerWatchThread then
            task.cancel(seedTimerWatchThread)
            seedTimerWatchThread = nil
        end
        if observedTimerConn then
            pcall(function()
                observedTimerConn:Disconnect()
            end)
            observedTimerConn = nil
        end
        for item, _ in pairs(_seedShopBindings) do
            safeDisconnectSeedBinding(item)
        end
    end
    pcall(updateToastPositions)
end

function setupUISync(refs)
    local r = refs
    Components.UISync.toggleGameInfo = function(on)
        gameInfoEnabled = on
        Components.SetState(
            r.gameInfoBtn,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
        toggleGameInfo(on)
    end
    Components.UISync.toggleESP = function(on)
        espEnabled = on
        Components.SetState(
            r.espBtn,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
        toggleEsp(on)
    end
    Components.UISync.toggleSeedTimerESP = function(on)
        seedTimerEspEnabled = on
        Components.SetState(
            r.seedTimerEspBtn,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
        toggleSeedTimerEsp(on)
    end
    Components.UISync.toggleSeedTimerInfo = function(on)
        seedTimerInfoEnabled = on
        Components.SetState(
            r.seedTimerInfoBtn,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
        toggleSeedTimerInfo(on)
    end
    Components.UISync.toggleSeedTimerHitbox = function(on)
        seedTimerHitboxEnabled = on
        Components.SetState(
            r.seedTimerHitboxBtn,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
    end
    Components.UISync.toggleSeedAlerts = function(on)
        seedAlertEnabled = on
        Components.SetState(
            r.seedAlertsToggle,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
        toggleSeedAlerts(on)
    end
    Components.UISync.toggleAlerts = function(on)
        alertEnabled = on
        Components.SetState(
            r.alertsToggle,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
        pcall(updateToastPositions)
    end
    Components.UISync.toggleGearAlerts = function(on)
        gearAlertEnabled = on
        Components.SetState(
            r.gearAlertsToggle,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
        toggleGearAlerts(on)
    end
    Components.UISync.toggleAutoCollect = function(on)
        Components.SetState(
            r.autoCollectBtn,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
        -- Actually start/stop auto collect
        autoCollectEnabled = on
        if on then
            if autoCollectThread then
                task.cancel(autoCollectThread)
                autoCollectThread = nil
            end
            autoCollectThread = task.spawn(function()
                while autoCollectEnabled and not unloaded do
                    runOneAutoCollectPass()
                    -- Only set nextCollectTime if it's not already set or if we're past it
                    if nextCollectTime <= time() then
                        nextCollectTime = time()
                            + (autoCollectIntervalSec or 90)
                    end
                    -- Wait until nextCollectTime, checking every 0.1 seconds
                    while
                        autoCollectEnabled
                        and not unloaded
                        and time() < nextCollectTime
                    do
                        task.wait(0.1)
                    end
                end
            end)
        else
            if autoCollectThread then
                task.cancel(autoCollectThread)
                autoCollectThread = nil
            end
            activeBrainrotCount = 0
            nextCollectTime = 0
        end
    end

    Components.UISync.toggleAutoEquipBest = function(on)
        Components.SetState(
            r.autoEquipBestBtn,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
        autoEquipBestEnabled = on
        if on then
            if autoEquipBestThread then
                task.cancel(autoEquipBestThread)
                autoEquipBestThread = nil
            end
            autoEquipBestThread = task.spawn(function()
                while autoEquipBestEnabled and not unloaded do
                    runOneAutoEquipBestPass()
                    -- Set next equip time
                    if nextEquipBestTime <= time() then
                        nextEquipBestTime = time()
                            + (autoEquipBestIntervalSec or 100)
                    end
                    -- Wait until nextEquipBestTime, checking every 0.1 seconds
                    while
                        autoEquipBestEnabled
                        and not unloaded
                        and time() < nextEquipBestTime
                    do
                        task.wait(0.1)
                    end
                end
            end)
        else
            if autoEquipBestThread then
                task.cancel(autoEquipBestThread)
                autoEquipBestThread = nil
            end
            nextEquipBestTime = 0
        end
    end

    Components.UISync.toggleAutoSell = function(on)
        Components.SetState(
            r.autoSellBtn,
            on and 'on' or 'off',
            on and Success or DefaultButton
        )
        autoSellEnabled = on
        if on then
            if autoSellThread then
                task.cancel(autoSellThread)
                autoSellThread = nil
            end
            autoSellThread = task.spawn(autoSellLoop)
        else
            if autoSellThread then
                task.cancel(autoSellThread)
                autoSellThread = nil
            end
        end
    end

    Components.UISync.syncAll = function(refs)
        local r = refs
        -- Use uiRefs if available (for config loading), otherwise use refs (for window creation)
        local globalRefs = uiRefs or {}

        -- Main
        if r.gameInfoBtn then
            setButtonStateWithTheme(r.gameInfoBtn, gameInfoEnabled)
        end
        if r.autoCollectBtn then
            setButtonStateWithTheme(r.autoCollectBtn, autoCollectEnabled)
        end
        if r.autoEquipBestBtn then
            setButtonStateWithTheme(r.autoEquipBestBtn, autoEquipBestEnabled)
        end
        if r.autoSellBtn then
            setButtonStateWithTheme(r.autoSellBtn, autoSellEnabled)
        end
        if r.espBtn then
            setButtonStateWithTheme(r.espBtn, espEnabled)
        end
        if r.seedTimerEspBtn then
            setButtonStateWithTheme(r.seedTimerEspBtn, seedTimerEspEnabled)
        end
        if r.seedTimerInfoBtn then
            setButtonStateWithTheme(r.seedTimerInfoBtn, seedTimerInfoEnabled)
        end
        if r.seedTimerHitboxBtn then
            setButtonStateWithTheme(
                r.seedTimerHitboxBtn,
                seedTimerHitboxEnabled
            )
        end
        if r.seedAutoBuyBtn then
            setButtonStateWithTheme(r.seedAutoBuyBtn, seedAutoBuyEnabled)
        end
        if r.gearAutoBuyBtn then
            setButtonStateWithTheme(r.gearAutoBuyBtn, gearAutoBuyEnabled)
        end
        if r.autoHitBtn then
            setButtonStateWithTheme(r.autoHitBtn, autoHitEnabled)
        end
        if r.autoCompleteEventBtn then
            setButtonStateWithTheme(
                r.autoCompleteEventBtn,
                autoCompleteEventEnabled
            )
        end
        if r.autoRebirthBtn then
            setButtonStateWithTheme(r.autoRebirthBtn, autoRebirthEnabled)
        end
        if r.intervalApi then
            r.intervalApi.Set(tostring(autoCollectIntervalSec) .. 's')
        end
        if r.autoEquipBestIntervalApi then
            r.autoEquipBestIntervalApi.Set(
                tostring(autoEquipBestIntervalSec) .. 's'
            )
        end
        if r.autoSellIntervalApi then
            r.autoSellIntervalApi.Set(tostring(autoSellIntervalSec) .. 's')
        end
        if r.giSliderApi then
            r.giSliderApi.Set((gameInfoScale - 0.5) / 1.5)
        end

        -- Use global references for dropdowns to ensure config loading works
        if globalRefs.espRarityDropdown then
            globalRefs.espRarityDropdown.SetSelectedMap(selectedRarities)
        end
        if globalRefs.rarityDropdown then
            globalRefs.rarityDropdown.SetSelectedMap(selectedAutoHitRarities)
        end
        -- Let the standard dropdown system handle its own state restoration
        -- The OnChanged handler will sync the variable when the user interacts with the dropdown
        if globalRefs.mutationDropdown then
            globalRefs.mutationDropdown.SetSelectedMap(selectedMutations)
        end
        if globalRefs.autoHitBrainrotDropdown then
            globalRefs.autoHitBrainrotDropdown.SetSelectedMap(
                selectedAutoHitBrainrotNames
            )
        end
        if globalRefs.seedBuyDropdown then
            globalRefs.seedBuyDropdown.SetSelectedMap(selectedSeedBuyFilters)
        end
        if globalRefs.gearBuyDropdown then
            globalRefs.gearBuyDropdown.SetSelectedMap(selectedGearBuyFilters)
        end

        -- Alerts
        if r.alertsToggle then
            setButtonStateWithTheme(r.alertsToggle, alertEnabled)
        end
        if r.serverwideToggle then
            setButtonStateWithTheme(
                r.serverwideToggle,
                brainrotServerwideEnabled
            )
        end
        if r.volSliderApi then
            r.volSliderApi.Set(alertVolume / 2.0)
        end

        -- Use global references for alert dropdowns
        if globalRefs.alertRarityDropdown then
            globalRefs.alertRarityDropdown.SetSelectedMap(alertRaritySet)
        end
        if globalRefs.alertMutationDropdown then
            globalRefs.alertMutationDropdown.SetSelectedMap(alertMutationSet)
        end
        if globalRefs.alertWhenApi then
            globalRefs.alertWhenApi.Set(alertMatchMode)
        end
        if r.seedAlertsToggle then
            setButtonStateWithTheme(r.seedAlertsToggle, seedAlertEnabled)
        end
        -- Seed filter dropdown state is handled by the standard persistence system
        if r.seedVolApi then
            r.seedVolApi.Set(seedAlertVolume / 2.0)
        end
        if r.gearAlertsToggle then
            setButtonStateWithTheme(r.gearAlertsToggle, gearAlertEnabled)
        end
        if globalRefs.gearFilterDropdownApi then
            globalRefs.gearFilterDropdownApi.SetSelectedMap(selectedGearFilters)
        end

        -- Settings
        if r.webhookBox then
            r.webhookBox.Text = webhookUrl
        end
        if r.webhookToggleBtn then
            setButtonStateWithTheme(r.webhookToggleBtn, webhookEnabled)
            r.webhookToggleBtn.Text = webhookEnabled and 'On' or 'Off'
        end
        if r.pingApi then
            r.pingApi.Set(webhookPingMode)
        end
        if r.keepSidebarBtn then
            setButtonStateWithTheme(r.keepSidebarBtn, keepSidebarOpen)
            r.keepSidebarBtn.Text = keepSidebarOpen and 'On' or 'Off'
        end
        if r.mobileButtonToggle then
            setButtonStateWithTheme(r.mobileButtonToggle, mobileButtonEnabled)
        end
        if r.disableBlurBtn then
            setButtonStateWithTheme(r.disableBlurBtn, disableBlur)
            r.disableBlurBtn.Text = disableBlur and 'On' or 'Off'
        end
        if r.disableAnimationsBtn then
            setButtonStateWithTheme(r.disableAnimationsBtn, disableAnimations)
            r.disableAnimationsBtn.Text = disableAnimations and 'On' or 'Off'
        end
        if r.sidebarLocationDropdown then
            r.sidebarLocationDropdown.Set(sidebarLocation)
        end

        -- Misc
        if r.antiAfkBtn then
            setButtonStateWithTheme(r.antiAfkBtn, antiAfkEnabled)
        end
    end
end

function Components.SetState(element, state, color)
    if not element or not element.Parent then
        return
    end
    UIState[element] = { state = state, color = color }
    pcall(function()
        TweenService
            :Create(element, TweenInfo.new(0.18), { BackgroundColor3 = color })
            :Play()
    end)
end

function Components.Card(props)
    local frame = New('Frame', {
        Size = props.Size or UDim2.new(0, 560, 0, 380),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Card,
        BackgroundTransparency = 0, -- Completely opaque background
        ClipsDescendants = true,
        Parent = props.Parent,
        Name = props.Name or 'Card',
        ZIndex = props.ZIndex or 1,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 16) }),
        New(
            'UIStroke',
            { Color = Stroke, Thickness = 1.25, Transparency = 0.5 }
        ),
    })

    -- Organic effects removed to prevent color changes

    return frame
end

function Components.TopBar(props)
    local top = New('Frame', {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = props.Parent,
        Name = 'TopBar',
        ZIndex = 2,
    })
    local glass = New('Frame', {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Card,
        BackgroundTransparency = 0.05,
        Parent = top,
        Name = 'TopBarGlass',
        ZIndex = 2,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 16) }),
        New('UIStroke', { Color = Stroke, Thickness = 1, Transparency = 0.25 }),
    })
    local title = New('TextLabel', {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -14, 1, 0),
        Text = props.Title or 'GUI Base',
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = top,
        ZIndex = 3,
    })
    return top, glass, title
end

function Components.PillButton(props)
    local b = New('TextButton', {
        Size = props.Size or UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = props.Bg or DefaultButton,
        Text = props.Text or '',
        TextColor3 = Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = props.TextSize or 14,
        Parent = props.Parent,
        Name = props.Name or 'Button',
        AutoButtonColor = false,
        ZIndex = props.ZIndex or 2,
        LayoutOrder = props.LayoutOrder or 0,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 16) }),
        New('UIStroke', { Color = Stroke, Thickness = 1, Transparency = 0.25 }),
    })

    Components.SetState(b, 'off', props.Bg or DefaultButton)

    -- Add organic button effects instead of the old hover effects
    addOrganicButtonEffects(b)

    -- Organic color effects removed to prevent color changes

    return b
end

function Components.SectionLabel(text, parent, y)
    return New('TextLabel', {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, y or 10),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        Parent = parent,
        ZIndex = 2,
    })
end

function Components.Slider(props)
    local frame = New('Frame', {
        Size = props.Size or UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = props.Parent,
        LayoutOrder = props.LayoutOrder or 0,
        ZIndex = props.ZIndex or 4,
    })
    if props.Title then
        New('TextLabel', {
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.new(0, 0, 0, -2),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Muted,
            Text = props.Title,
            Parent = frame,
        })
    end
    local valueText
    if props.ValueText then
        valueText = New('TextLabel', {
            Size = UDim2.new(1, -4, 0, 14),
            Position = UDim2.new(0, 2, 1, -20),
            BackgroundTransparency = 1,
            TextColor3 = Muted,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = frame,
            ZIndex = 3,
        })
    end

    local bar = New('Frame', {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 15),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), -- Black background for all sliders
        Parent = frame,
        ZIndex = 5,
        Active = true,
    }, { New('UICorner', { CornerRadius = UDim.new(1, 0) }) })
    local fill = New('Frame', {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = theme == 'light' and Color3.fromRGB(255, 165, 0)
            or Color3.fromRGB(59, 130, 246), -- Orange in light mode, blue in dark mode
        BackgroundTransparency = 0,
        Parent = bar,
        ZIndex = 6,
    }, { New('UICorner', { CornerRadius = UDim.new(1, 0) }) })
    local knob = New('Frame', {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), -- White in both light and dark mode
        Parent = bar,
        ZIndex = 7,
        Active = true,
    }, {
        New('UICorner', { CornerRadius = UDim.new(1, 0) }),
        New('UIStroke', {
            Color = theme == 'light' and Color3.fromRGB(128, 0, 128)
                or Color3.fromRGB(59, 130, 246), -- Purple in light mode, blue in dark mode
            Thickness = 2,
        }),
    })

    local onChangedCallback
    local isDragging = false -- Use local variable instead of global

    local function setAlpha(a, fromInput)
        a = math.max(0, math.min(1, a))
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, -7, 0.5, -7)
        if valueText then
            local scaleVal = 0.5 + a * 1.5
            pcall(function()
                valueText.Text = props.ValueText(scaleVal)
            end)
        end
        if fromInput and onChangedCallback then
            onChangedCallback(a)
        end
    end

    local function updateFromX(x)
        if not bar or not bar.Parent then
            return
        end
        local a = math.max(
            0,
            math.min(1, (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X)
        )
        setAlpha(a, true)
    end

    bind(bar.InputBegan:Connect(function(input)
        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            isDragging = true
            updateFromX(input.Position.X)
        end
    end))

    bind(knob.InputBegan:Connect(function(input)
        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            isDragging = true
            updateFromX(input.Position.X)
        end
    end))

    bind(UserInputService.InputChanged:Connect(function(input)
        if
            isDragging
            and (
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            )
        then
            updateFromX(input.Position.X)
        end
    end))

    bind(UserInputService.InputEnded:Connect(function(input)
        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            isDragging = false
        end
    end))

    local api = {}
    function api.OnChanged(cb)
        onChangedCallback = cb
    end
    function api.Set(a)
        setAlpha(a, false)
    end
    function api.getParts()
        return fill, knob
    end
    function api.updateColors()
        -- Use theme-appropriate background color
        bar.BackgroundColor3 = Surface
        -- Update fill color based on current theme
        if theme == 'light' then
            fill.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Orange
        else
            fill.BackgroundColor3 = Color3.fromRGB(59, 130, 246) -- Blue
        end
        -- Update knob color
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White
        local stroke = knob:FindFirstChild('UIStroke')
        if stroke then
            if theme == 'light' then
                stroke.Color = Color3.fromRGB(128, 0, 128) -- Purple outline in light mode
            else
                stroke.Color = Color3.fromRGB(59, 130, 246) -- Blue outline in dark mode
            end
        end
    end
    return api
end

function Components.CycleButton(props)
    local container = New('Frame', {
        Size = props.Size or UDim2.new(0, 160, 0, 30),
        BackgroundColor3 = Surface,
        BackgroundTransparency = 0.15,
        ZIndex = props.ZIndex or 3,
        LayoutOrder = props.LayoutOrder or 0,
        Parent = props.Parent,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 16) }),
        New('UIStroke', { Color = Stroke, Thickness = 1, Transparency = 0.3 }),
    })

    New('TextLabel', {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 14),
        Position = UDim2.new(0, 8, 0, 3),
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Muted,
        Text = props.Title,
        ZIndex = 4,
    })
    local btn = New('TextButton', {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -28, 0, 16),
        Position = UDim2.new(0, 6, 0, 14),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Text,
        AutoButtonColor = false,
        ZIndex = 4,
    })
    New('TextLabel', {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -20, 0, 14),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = Muted,
        Text = '▼',
        ZIndex = 4,
    })

    local options = props.Options or {}
    local currentIndex = 1
    local onChangedCallback

    for i, option in ipairs(options) do
        local value = type(option) == 'table' and option.value or option
        if tostring(value) == tostring(props.CurrentValue) then
            currentIndex = i
            break
        end
    end

    local function updateText()
        local option = options[currentIndex]
        btn.Text = type(option) == 'table' and option.label or option
    end
    updateText()

    local function cycleValue(direction)
        if direction == 1 then
            -- Forward (left click)
            currentIndex = currentIndex + 1
            if currentIndex > #options then
                currentIndex = 1
            end
        else
            -- Backward (right click)
            currentIndex = currentIndex - 1
            if currentIndex < 1 then
                currentIndex = #options
            end
        end

        local fadeOut = TweenService:Create(
            btn,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { TextTransparency = 1 }
        )
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            updateText()
            if onChangedCallback then
                local option = options[currentIndex]
                onChangedCallback(
                    type(option) == 'table' and option.value or option
                )
            end
            local fadeIn = TweenService:Create(
                btn,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                { TextTransparency = 0 }
            )
            fadeIn:Play()
        end)
    end

    bind(btn.MouseButton1Click:Connect(function()
        cycleValue(1) -- Forward
    end))

    bind(btn.MouseButton2Click:Connect(function()
        cycleValue(-1) -- Backward
    end))

    local api = {}
    function api.OnChanged(cb)
        onChangedCallback = cb
    end
    function api.getButton()
        return btn
    end
    function api.Set(val)
        for i, option in ipairs(options) do
            local value = type(option) == 'table' and option.value or option
            if tostring(value) == tostring(val) then
                currentIndex = i
                break
            end
        end
        updateText()
    end
    return api
end

-- Reusable helpers for overlay dropdowns
function headerRectOf(container)
    local p = container.AbsolutePosition
    local s = container.AbsoluteSize
    return p.X, p.Y, s.X, s.Y
end
function viewportSize()
    local cam = Workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1920, 1080)
end
-- Multi-select dropdown
function Components.MultiSelectDropdown(props)
    ensureOverlay()
    local BASE_Z = props.ZIndex or 50
    local MAX_MENU_HEIGHT = props.MaxHeight or 220
    local GAP = 4

    local container = New('Frame', {
        Parent = props.Parent,
        Size = props.Size or UDim2.new(0, 180, 0, 30),
        BackgroundColor3 = Surface,
        BackgroundTransparency = 0.15,
        ZIndex = BASE_Z,
        ClipsDescendants = false,
        Name = props.Name or 'MultiSelectDropdown',
        LayoutOrder = props.LayoutOrder or 0,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        New('UIStroke', { Color = Stroke, Thickness = 1, Transparency = 0.3 }),
    })

    -- Title
    New('TextLabel', {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 14),
        Position = UDim2.new(0, 8, 0, 3),
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Muted,
        Text = props.Title or '',
        ZIndex = BASE_Z + 1,
    })

    local openBtn = New('TextButton', {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -28, 0, 16),
        Position = UDim2.new(0, 6, 0, 14),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Text,
        Text = 'All selected',
        AutoButtonColor = false,
        ZIndex = BASE_Z + 1,
    })

    New('TextLabel', {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -20, 0, 14),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = Muted,
        Text = '▼',
        ZIndex = BASE_Z + 1,
    })

    local optionsFrame = New('ScrollingFrame', {
        Parent = ensureOverlay(),
        BackgroundColor3 = Card,
        BackgroundTransparency = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 100000,
        Visible = false,
        ClipsDescendants = true,
        Name = 'Options_' .. (props.Title or 'Filter'),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 6,
        ScrollBarImageTransparency = 0.15,
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        New('UIStroke', { Color = Stroke, Thickness = 1, Transparency = 0.3 }),
    })

    local list = New('UIListLayout', {
        Parent = optionsFrame,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    local padding = New('UIPadding', {
        Parent = optionsFrame,
        PaddingLeft = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
    })

    local open = false
    local clickCatcher = nil
    local items, selected = {}, {}
    local colorMap = props.ColorMap or {}

    local function desiredMenuHeight()
        local abs = list.AbsoluteContentSize
        local desired = abs.Y
            + padding.PaddingTop.Offset
            + padding.PaddingBottom.Offset
        return math.clamp(desired, 0, MAX_MENU_HEIGHT)
    end
    local function placeMenu(targetHeight)
        local x, y, w, h = headerRectOf(container)
        local view = viewportSize()
        local width = math.floor(math.min(w, view.X - 8))
        local height = math.floor(targetHeight or 0)
        local xClamped = math.clamp(x, 4, math.max(4, view.X - width - 4))
        local aboveY = y - GAP - height
        -- Force dropdown to always open upward
        local posY = math.max(4, aboveY)
        optionsFrame.Position = UDim2.fromOffset(xClamped, posY)
        optionsFrame.Size = UDim2.fromOffset(width, height)
    end

    local function updateSummary()
        local count, total = 0, #items
        for _, name in ipairs(items) do
            if selected[name] then
                count += 1
            end
        end
        if count == total then
            openBtn.Text = 'All selected'
        elseif count == 0 then
            openBtn.Text = 'None selected'
        elseif count <= 2 then
            local names = {}
            for _, name in ipairs(items) do
                if selected[name] then
                    table.insert(names, name)
                end
            end
            openBtn.Text = table.concat(names, ', ')
        else
            openBtn.Text = tostring(count) .. ' selected'
        end
    end

    local function setOptionButtonState(btn, isOn, name)
        local bg = isOn and Success or DefaultButton
        TweenService
            :Create(
                btn,
                TweenInfo.new(
                    0.12,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.Out
                ),
                { BackgroundColor3 = bg }
            )
            :Play()
        btn.NameLabel.TextColor3 = colorMap[name] or Text
        btn.Checkmark.TextTransparency = isOn and 0 or 0.7
    end

    -- Helper to persist current selection state immediately
    local function persistState()
        local id
        if props.PersistenceKey and tostring(props.PersistenceKey) ~= '' then
            id = 'dropdown_key_' .. tostring(props.PersistenceKey)
        else
            id = 'dropdown_' .. container.Name
            if container.Parent then
                local parentName = container.Parent.Name or 'unknown'
                local containerName = container.Name or 'unknown'
                id = 'dropdown_' .. parentName .. '_' .. containerName
            end
        end
        -- Only persist if there is at least one selected item to avoid overwriting
        local any = false
        for _, v in pairs(selected) do
            if v then
                any = true
                break
            end
        end
        if any then
            local st = { type = 'multi', selected = selected, items = items }
            DropdownStateRegistry[id] = st
        end
    end

    local function rebuildOptions()
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA('TextButton') then
                child:Destroy()
            end
        end
        for i, name in ipairs(items) do
            local opt = New('TextButton', {
                Parent = optionsFrame,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = DefaultButton,
                AutoButtonColor = false,
                Text = '',
                ZIndex = optionsFrame.ZIndex + 1,
                LayoutOrder = i,
            }, {
                New('UICorner', { CornerRadius = UDim.new(0, 6) }),
                New(
                    'UIStroke',
                    { Color = Stroke, Thickness = 1, Transparency = 0.4 }
                ),
            })
            New('TextLabel', {
                Parent = opt,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -48, 1, 0),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = name,
                TextColor3 = colorMap[name] or Text,
                Name = 'NameLabel',
                ZIndex = optionsFrame.ZIndex + 2,
            })
            New('TextLabel', {
                Parent = opt,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -26, 0.5, -12),
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                Text = '✓',
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextTransparency = 0.7,
                Name = 'Checkmark',
                ZIndex = optionsFrame.ZIndex + 2,
            })
            bind(opt.MouseButton1Click:Connect(function()
                selected[name] = not selected[name]
                setOptionButtonState(opt, selected[name], name)
                updateSummary()
                persistState() -- Save state immediately on each click to prevent corruption
                if props.OnChanged then
                    props.OnChanged(selected)
                end
            end))
            setOptionButtonState(opt, selected[name] == true, name)
        end
        task.defer(function()
            if open and optionsFrame.Visible then
                placeMenu(desiredMenuHeight())
            end
        end)
    end

    local function tweenMenuHeight(toHeight)
        local startH = optionsFrame.AbsoluteSize.Y or 0
        local nv = Instance.new('NumberValue')
        nv.Value = startH
        local conn
        conn = nv:GetPropertyChangedSignal('Value'):Connect(function()
            placeMenu(nv.Value)
        end)
        local tw = TweenService:Create(
            nv,
            TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Value = toHeight }
        )
        tw.Completed:Connect(function()
            if conn then
                conn:Disconnect()
            end
            nv:Destroy()
        end)
        tw:Play()
    end

    local function setOpen(v)
        if open == v then
            return
        end
        open = v
        if v then
            optionsFrame.Visible = true
            optionsFrame.CanvasPosition = Vector2.new(0, 0)
            placeMenu(0)
            tweenMenuHeight(desiredMenuHeight())
            -- Create full-screen click catcher behind menu to close on outside clicks
            if not clickCatcher then
                clickCatcher = New('TextButton', {
                    Parent = ensureOverlay(),
                    BackgroundTransparency = 1,
                    Text = '',
                    AutoButtonColor = false,
                    Size = UDim.fromScale(1, 1),
                    Position = UDim2.fromOffset(0, 0),
                    ZIndex = optionsFrame.ZIndex - 1,
                })
                bind(clickCatcher.MouseButton1Click:Connect(function()
                    setOpen(false)
                end))
            end
        else
            local current = optionsFrame.AbsoluteSize.Y or 0
            if current > 0 then
                tweenMenuHeight(0)
            end
            task.delay(0.18, function()
                if not open then
                    optionsFrame.Visible = false
                end
            end)
            if clickCatcher then
                pcall(function()
                    clickCatcher:Destroy()
                end)
                clickCatcher = nil
            end
        end
    end

    -- Public API
    local api = {}
    function api.Close()
        setOpen(false)
    end
    function api.SetItems(newItems, preserveSelection)
        local seen = {}
        items, selected = {}, preserveSelection and selected or {}
        if not preserveSelection then
            selected = {}
        end
        for _, n in ipairs(newItems or {}) do
            if n and not seen[n] then
                seen[n] = true
                table.insert(items, n)
            end
        end
        if not preserveSelection then
            for _, n in ipairs(items) do
                selected[n] = true
            end
        else
            -- Don't auto-select new items when preserving selection
            for k in pairs(selected) do
                if not seen[k] then
                    selected[k] = nil
                end
            end
        end
        rebuildOptions()
        updateSummary()
        if props.OnChanged then
            props.OnChanged(selected)
        end
    end
    function api.SetSelectedAll(v)
        for _, n in ipairs(items) do
            selected[n] = v and true or false
        end
        rebuildOptions()
        updateSummary()
        persistState()
        if props.OnChanged then
            props.OnChanged(selected)
        end
    end
    function api.GetSelected()
        return selected
    end
    function api.GetSelection()
        return selected
    end -- Alias for compatibility
    function api.GetItems()
        return items
    end
    function api.SetSelectedMap(map)
        selected = {}
        for _, n in ipairs(items) do
            selected[n] = map and map[n] or false
        end
        rebuildOptions()
        updateSummary()
        persistState()
        if props.OnChanged then
            props.OnChanged(selected)
        end
    end
    function api.SetSelection(selectionMap)
        -- Clear existing selection
        selected = {}
        -- Set selection for all items based on the provided map
        if selectionMap and type(selectionMap) == 'table' then
            for _, item in ipairs(items) do
                selected[item] = selectionMap[item] == true or false
            end
        else
            -- If no selection map provided, set all items to false (deselect all)
            for _, item in ipairs(items) do
                selected[item] = false
            end
        end
        rebuildOptions()
        updateSummary()
        persistState()
        if props.OnChanged then
            props.OnChanged(selected)
        end
    end

    registerDropdown(api)

    bind(openBtn.MouseButton1Click:Connect(function()
        setOpen(not open)
    end))
    if Workspace.CurrentCamera then
        bind(
            Workspace.CurrentCamera
                :GetPropertyChangedSignal('ViewportSize')
                :Connect(function()
                    if open then
                        placeMenu(desiredMenuHeight())
                    end
                end)
        )
    end
    bind(
        container
            :GetPropertyChangedSignal('AbsolutePosition')
            :Connect(function()
                if open then
                    placeMenu(desiredMenuHeight())
                end
            end)
    )
    bind(container:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
        if open then
            placeMenu(desiredMenuHeight())
        end
    end))
    bind(list:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        if open then
            placeMenu(desiredMenuHeight())
        end
    end))

    -- Persist on lifecycle changes (covers cases where closeAllDropdowns isn't called)
    bind(container.Destroying:Connect(function()
        pcall(persistState)
    end))
    bind(container.AncestryChanged:Connect(function(_, newParent)
        if newParent == nil then
            pcall(persistState)
        end
    end))

    bind(UserInputService.InputBegan:Connect(function(input, gp)
        if
            gp
            or not open
            or input.UserInputType ~= Enum.UserInputType.MouseButton1
        then
            return
        end
        local pos = input.Position
        local cPos, cSize = container.AbsolutePosition, container.AbsoluteSize
        local oPos, oSize =
            optionsFrame.AbsolutePosition, optionsFrame.AbsoluteSize
        local inContainer = pos.X >= cPos.X
            and pos.X <= cPos.X + cSize.X
            and pos.Y >= cPos.Y
            and pos.Y <= cPos.Y + cSize.Y
        local inMenu = pos.X >= oPos.X
            and pos.X <= oPos.X + oSize.X
            and pos.Y >= oPos.Y
            and pos.Y <= oPos.Y + oSize.Y
        if not inContainer and not inMenu then
            setOpen(false)
        end
    end))

    api.container = container -- Store container reference for state restoration
    api.persistenceKey = props.PersistenceKey -- Optional stable key for persistence

    -- Always try to restore state after creation
    local identifier
    if props.PersistenceKey and tostring(props.PersistenceKey) ~= '' then
        identifier = 'dropdown_key_' .. tostring(props.PersistenceKey)
    else
        identifier = 'dropdown_' .. container.Name
        -- Build a stable identifier based on hierarchy names only (no position)
        if container.Parent then
            local parentName = container.Parent.Name or 'unknown'
            local containerName = container.Name or 'unknown'
            identifier = 'dropdown_' .. parentName .. '_' .. containerName
        end
    end

    -- Set items with default behavior (don't preserve selection during creation)
    api.SetItems(props.Items or {}, false)

    -- Try immediate restore using registry to avoid flicker/defaults overriding when window is reopened
    pcall(function()
        if
            _G
            and DropdownStateRegistry
            and identifier
            and DropdownStateRegistry[identifier]
        then
            local state = DropdownStateRegistry[identifier]
            if state and state.selected then
                if state.type == 'multi' and api.SetSelection then
                    api.SetSelection(state.selected)
                    -- Sync the global variable with the restored state
                    if props.OnChanged then
                        props.OnChanged(state.selected)
                    end
                elseif state.type == 'single' and api.SetSelectedByName then
                    api.SetSelectedByName(state.selected)
                end
            end
        end
    end)

    return api, container
end

-- Single-select dropdown
function Components.SingleSelectDropdown(props)
    ensureOverlay()

    local BASE_Z = props.ZIndex or 50
    local MAX_MENU_HEIGHT = props.MaxHeight or 220
    local GAP = 4

    local container = New('Frame', {
        Parent = props.Parent,
        Size = props.Size or UDim2.new(0, 160, 0, 30),
        BackgroundColor3 = Surface,
        BackgroundTransparency = 0.15,
        ZIndex = BASE_Z,
        ClipsDescendants = false,
        Name = props.Name or 'SingleSelectDropdown',
        LayoutOrder = props.LayoutOrder or 0,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        New('UIStroke', { Color = Stroke, Thickness = 1, Transparency = 0.3 }),
    })

    New('TextLabel', {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 14),
        Position = UDim2.new(0, 8, 0, 3),
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Muted,
        Text = props.Title or '',
        ZIndex = BASE_Z + 1,
    })

    local openBtn = New('TextButton', {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -28, 0, 16),
        Position = UDim2.new(0, 6, 0, 14),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Text,
        Text = props.Placeholder or 'Select...',
        AutoButtonColor = false,
        ZIndex = BASE_Z + 1,
    })

    New('TextLabel', {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -20, 0, 14),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = Muted,
        Text = '▲',
        ZIndex = BASE_Z + 1,
    })

    local optionsFrame = New('ScrollingFrame', {
        Parent = ensureOverlay(),
        BackgroundColor3 = Card,
        BackgroundTransparency = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 100000,
        Visible = false,
        ClipsDescendants = true,
        Name = 'Options_' .. (props.Title or 'Select'),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 6,
        ScrollBarImageTransparency = 0.15,
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        New('UIStroke', { Color = Stroke, Thickness = 1, Transparency = 0.3 }),
    })

    local list = New('UIListLayout', {
        Parent = optionsFrame,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    local padding = New('UIPadding', {
        Parent = optionsFrame,
        PaddingLeft = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
    })

    local items = {}
    local selectedName = nil
    local open = false

    local function desiredMenuHeight()
        local abs = list.AbsoluteContentSize
        local desired = abs.Y
            + padding.PaddingTop.Offset
            + padding.PaddingBottom.Offset
        return math.clamp(desired, 0, MAX_MENU_HEIGHT)
    end
    local function placeMenu(targetHeight)
        local x, y, w, h = headerRectOf(container)
        local view = viewportSize()
        local width = math.floor(math.min(w, view.X - 8))
        local height = math.floor(targetHeight or 0)
        local xClamped = math.clamp(x, 4, math.max(4, view.X - width - 4))
        local belowY = y + h + GAP
        local aboveY = y - GAP - height
        local fitsBelow = (belowY + height) <= (view.Y - 4)
        local posY = fitsBelow and belowY or math.max(4, aboveY)
        optionsFrame.Position = UDim2.fromOffset(xClamped, posY)
        optionsFrame.Size = UDim2.fromOffset(width, height)
    end

    local function tweenMenuHeight(toHeight)
        local startH = optionsFrame.AbsoluteSize.Y or 0
        local nv = Instance.new('NumberValue')
        nv.Value = startH
        local conn
        conn = nv:GetPropertyChangedSignal('Value'):Connect(function()
            placeMenu(nv.Value)
        end)
        local tw = TweenService:Create(
            nv,
            TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Value = toHeight }
        )
        tw.Completed:Connect(function()
            if conn then
                conn:Disconnect()
            end
            nv:Destroy()
        end)
        tw:Play()
    end

    local function setOpen(v)
        if open == v then
            return
        end
        open = v
        if v then
            optionsFrame.Visible = true
            optionsFrame.CanvasPosition = Vector2.new(0, 0)
            placeMenu(0)
            tweenMenuHeight(desiredMenuHeight())
        else
            local current = optionsFrame.AbsoluteSize.Y or 0
            if current > 0 then
                tweenMenuHeight(0)
            end
            task.delay(0.18, function()
                if not open then
                    optionsFrame.Visible = false
                end
            end)
        end
    end

    local function rebuildOptions()
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA('TextButton') then
                child:Destroy()
            end
        end
        for i, name in ipairs(items) do
            local opt = New('TextButton', {
                Parent = optionsFrame,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = DefaultButton,
                AutoButtonColor = false,
                Text = '',
                ZIndex = optionsFrame.ZIndex + 1,
                LayoutOrder = i,
            }, {
                New('UICorner', { CornerRadius = UDim.new(0, 6) }),
                New(
                    'UIStroke',
                    { Color = Stroke, Thickness = 1, Transparency = 0.4 }
                ),
            })

            New('TextLabel', {
                Parent = opt,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = name,
                TextColor3 = Text,
                Name = 'NameLabel',
                ZIndex = optionsFrame.ZIndex + 2,
            })

            local dot = New('TextLabel', {
                Parent = opt,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -26, 0.5, -12),
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                Text = '•',
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextTransparency = (selectedName == name) and 0 or 0.85,
                Name = 'Dot',
                ZIndex = optionsFrame.ZIndex + 2,
            })

            bind(opt.MouseButton1Click:Connect(function()
                selectedName = name
                openBtn.Text = name
                for _, btn in ipairs(optionsFrame:GetChildren()) do
                    if btn:IsA('TextButton') then
                        local d = btn:FindFirstChild('Dot')
                        if d then
                            d.TextTransparency = (btn == opt) and 0 or 0.85
                        end
                    end
                end
                if props.OnChanged then
                    props.OnChanged(selectedName)
                end
                setOpen(false)
            end))

            -- Deletion via right-click or long-press (optional)
            if props.OnDeleteItem then
                if opt.MouseButton2Click then
                    bind(opt.MouseButton2Click:Connect(function()
                        local ok = pcall(props.OnDeleteItem, name)
                        if openBtn and openBtn.Text == name then
                            openBtn.Text = props.Placeholder or 'Select...'
                        end
                        if ok then
                            setOpen(false)
                        end
                    end))
                end
                local pressedAt = 0
                bind(opt.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        pressedAt = time()
                    end
                end))
                bind(opt.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        if time() - pressedAt >= 1.0 then
                            local ok = pcall(props.OnDeleteItem, name)
                            if openBtn and openBtn.Text == name then
                                openBtn.Text = props.Placeholder or 'Select...'
                            end
                            if ok then
                                setOpen(false)
                            end
                        end
                    end
                end))
            end
        end
        task.defer(function()
            if open and optionsFrame.Visible then
                placeMenu(desiredMenuHeight())
            end
        end)
    end

    local api = {}
    api.container = container -- Store container reference for state restoration
    function api.Close()
        setOpen(false)
    end
    function api.SetItems(newItems)
        items = {}
        for _, n in ipairs(newItems or {}) do
            if n then
                table.insert(items, n)
            end
        end
        rebuildOptions()
    end
    function api.SetSelectedByName(name)
        selectedName = name
        openBtn.Text = name or (props.Placeholder or 'Select...')
        for _, btn in ipairs(optionsFrame:GetChildren()) do
            if btn:IsA('TextButton') then
                local label = btn:FindFirstChild('NameLabel')
                local dot = btn:FindFirstChild('Dot')
                if label and dot then
                    dot.TextTransparency = (label.Text == selectedName) and 0
                        or 0.85
                end
            end
        end
        if props.OnChanged then
            props.OnChanged(selectedName)
        end
    end
    function api.GetSelected()
        return selectedName
    end
    function api.GetItems()
        return items
    end

    registerDropdown(api)

    -- Restore dropdown state if it exists
    local identifier
    if props.PersistenceKey and tostring(props.PersistenceKey) ~= '' then
        identifier = 'dropdown_key_' .. tostring(props.PersistenceKey)
    else
        identifier = 'dropdown_' .. container.Name
        -- Build a stable identifier based on hierarchy names only (no position)
        if container.Parent then
            local parentName = container.Parent.Name or 'unknown'
            local containerName = container.Name or 'unknown'
            identifier = 'dropdown_' .. parentName .. '_' .. containerName
        end
    end
    -- Immediate restore to avoid default overriding on reopen
    pcall(function()
        if
            _G
            and DropdownStateRegistry
            and identifier
            and DropdownStateRegistry[identifier]
        then
            local state = DropdownStateRegistry[identifier]
            if state and state.selected and api.SetSelectedByName then
                api.SetSelectedByName(state.selected)
            end
        end
    end)
    -- Also defer restore for safety
    task.defer(function()
        restoreDropdownState(api, identifier)
    end)
    bind(openBtn.MouseButton1Click:Connect(function()
        setOpen(not open)
    end))
    if Workspace.CurrentCamera then
        bind(
            Workspace.CurrentCamera
                :GetPropertyChangedSignal('ViewportSize')
                :Connect(function()
                    if open then
                        placeMenu(desiredMenuHeight())
                    end
                end)
        )
    end
    bind(
        container
            :GetPropertyChangedSignal('AbsolutePosition')
            :Connect(function()
                if open then
                    placeMenu(desiredMenuHeight())
                end
            end)
    )
    bind(container:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
        if open then
            placeMenu(desiredMenuHeight())
        end
    end))
    bind(list:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        if open then
            placeMenu(desiredMenuHeight())
        end
    end))
    bind(UserInputService.InputBegan:Connect(function(input, gp)
        if
            gp
            or not open
            or input.UserInputType ~= Enum.UserInputType.MouseButton1
        then
            return
        end
        local pos = input.Position
        local cPos, cSize = container.AbsolutePosition, container.AbsoluteSize
        local oPos, oSize =
            optionsFrame.AbsolutePosition, optionsFrame.AbsoluteSize
        local inContainer = pos.X >= cPos.X
            and pos.X <= cPos.X + cSize.X
            and pos.Y >= cPos.Y
            and pos.Y <= cPos.Y + cSize.Y
        local inMenu = pos.X >= oPos.X
            and pos.X <= oPos.X + oSize.X
            and pos.Y >= oPos.Y
            and pos.Y <= oPos.Y + oSize.Y
        if not inContainer and not inMenu then
            setOpen(false)
        end
    end))

    api.SetItems(props.Items or {})
    if props.Default then
        api.SetSelectedByName(props.Default)
    end

    return api, container
end

-- =============================
-- Alerts Config (brainrot)
-- =============================
_alertSeen = setmetatable({}, { __mode = 'k' })
_lastToastAt = 0
_toastCooldown = 0.5

-- =============================
-- Config Save/Load Helpers
-- =============================
local CONFIG_DIR = 'based_gui'
local CONFIG_PATH = CONFIG_DIR .. '/config.json' -- legacy default
local CONFIG_INDEX = CONFIG_DIR .. '/index.json'

-- Simple top-center toast for config feedback
local _cfgToastGui
function showTopCenterToast(message)
    pcall(function()
        if not _cfgToastGui or not _cfgToastGui.Parent then
            _cfgToastGui = Instance.new('ScreenGui')
            _cfgToastGui.Name = 'ConfigToastGui'
            _cfgToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            _cfgToastGui.DisplayOrder = 1000000
            _cfgToastGui.ResetOnSpawn = false
            _cfgToastGui.Parent = CoreGui
        end

        local holder = Instance.new('Frame')
        holder.AnchorPoint = Vector2.new(0.5, 0)
        holder.Position = UDim2.new(0.5, 0, 0, 8)
        holder.Size = UDim2.new(0, 0, 0, 32)
        holder.BackgroundColor3 = Card
        holder.BackgroundTransparency = 0.05
        holder.Parent = _cfgToastGui
        holder.ZIndex = 1000001
        Instance.new('UICorner', holder).CornerRadius = UDim.new(0, 16)
        local stroke = Instance.new('UIStroke', holder)
        stroke.Color = Stroke
        stroke.Thickness = 1
        stroke.Transparency = 0.25

        local label = Instance.new('TextLabel')
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextColor3 = Text
        label.Text = tostring(message or '')
        label.Parent = holder
        label.ZIndex = 1000002
        label.Position = UDim2.new(0, 12, 0, 7)
        label.Size = UDim2.new(1, -24, 1, -14)
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center

        -- autosize width to content
        local textSize = TextService:GetTextSize(
            label.Text,
            label.TextSize,
            label.Font,
            Vector2.new(1000, 32)
        )
        holder.Size = UDim2.new(0, math.max(180, textSize.X + 32), 0, 32)

        -- fade in/out
        holder.BackgroundTransparency = 0.9
        label.TextTransparency = 1
        TweenService
            :Create(
                holder,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                { BackgroundTransparency = 0.05 }
            )
            :Play()
        local tin = TweenService:Create(
            label,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { TextTransparency = 0 }
        )
        tin:Play()
        tin.Completed:Wait()
        task.delay(1.2, function()
            local tout1 = TweenService:Create(
                label,
                TweenInfo.new(
                    0.18,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                { TextTransparency = 1 }
            )
            local tout2 = TweenService:Create(
                holder,
                TweenInfo.new(
                    0.18,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                { BackgroundTransparency = 0.9 }
            )
            tout1:Play()
            tout2:Play()
            tout2.Completed:Wait()
            holder:Destroy()
        end)
    end)
end

function sanitizeFileName(s)
    s = tostring(s or ''):gsub('^%s+', ''):gsub('%s+$', '')
    s = s:gsub('[^%w%._%-]', '_')
    if s == '' then
        s = 'default'
    end
    return s
end

function configPathFor(name)
    if name and name ~= '' then
        return string.format('%s/%s.json', CONFIG_DIR, sanitizeFileName(name))
    end
    return CONFIG_PATH
end
function listConfigNames()
    -- Prefer our explicit index for accuracy across executors
    local idx = {}
    if typeof(isfile) == 'function' and isfile(CONFIG_INDEX) then
        local ok, contents = pcall(readfile, CONFIG_INDEX)
        if ok and contents and contents ~= '' then
            local ok2, arr = pcall(function()
                return HttpService:JSONDecode(contents)
            end)
            if ok2 and type(arr) == 'table' then
                local seen = {}
                for _, n in ipairs(arr) do
                    if type(n) == 'string' and n ~= '' then
                        if n ~= 'index' then
                            if n == 'config' then
                                n = 'default'
                            end
                            if not seen[n] then
                                table.insert(idx, n)
                                seen[n] = true
                            end
                        end
                    end
                end
            end
        end
    end
    if #idx == 0 then
        -- Fallback scanning folder if index is missing
        local hasList = (typeof(listfiles) == 'function')
            and (typeof(isfolder) == 'function')
        local hasFile = (typeof(isfile) == 'function')
        if hasList then
            pcall(function()
                if not isfolder(CONFIG_DIR) then
                    makefolder(CONFIG_DIR)
                end
            end)
            local ok, files = pcall(listfiles, CONFIG_DIR)
            if ok then
                for _, f in ipairs(files or {}) do
                    local n = tostring(f):match('([^/\\]+)%.json$')
                    if n and n ~= '' and n ~= 'index' then
                        if n == 'config' then
                            n = 'default'
                        end
                        table.insert(idx, n)
                    end
                end
            end
        elseif hasFile and isfile(CONFIG_PATH) then
            table.insert(idx, 'default')
        end
    end
    table.sort(idx)
    return idx
end

function deleteConfig(name)
    name = sanitizeFileName(name)
    if name == 'default' and not isfile(CONFIG_PATH) then
        return false
    end
    local path = configPathFor(name)
    local okDel = false
    if typeof(delfile) == 'function' then
        okDel = pcall(delfile, path) == true
    end
    if not okDel and typeof(writefile) == 'function' then
        pcall(writefile, path, '{}')
    end
    -- Update index
    local names = listConfigNames()
    local out = {}
    for _, n in ipairs(names) do
        if n ~= name then
            table.insert(out, n)
        end
    end
    pcall(function()
        writefile(CONFIG_INDEX, HttpService:JSONEncode(out))
    end)
    return true
end

function hasFilesystem()
    return (typeof(writefile) == 'function')
        and (typeof(readfile) == 'function')
        and (typeof(isfile) == 'function')
        and (typeof(isfolder) == 'function')
        and (typeof(makefolder) == 'function')
end

function buildConfigTable()
    return {
        autoCollectEnabled = autoCollectEnabled == true,
        autoCollectIntervalSec = autoCollectIntervalSec or 90,
        autoCollectType = autoCollectType or 'Teleport',
        autoEquipBestEnabled = autoEquipBestEnabled == true,
        autoEquipBestIntervalSec = autoEquipBestIntervalSec or 100,
        autoSellEnabled = autoSellEnabled == true,
        autoSellIntervalSec = autoSellIntervalSec or 60,
        gameInfoFilters = gameInfoFilters or {},
        alertMatchMode = alertMatchMode or 'Both',
        alertSoundEnabled = alertSoundEnabled == true,
        alertVolume = alertVolume or 1.0,
        alertEnabled = alertEnabled == true,
        brainrotServerwideEnabled = brainrotServerwideEnabled == true,
        gameInfoEnabled = gameInfoEnabled == true,
        espEnabled = espEnabled == true,
        seedAlertEnabled = seedAlertEnabled == true,
        seedAlertVolume = seedAlertVolume or 1.0,
        gearAlertEnabled = gearAlertEnabled == true,
        gearWebhookEnabled = gearWebhookEnabled ~= false,
        -- Filters and selections
        espSelectedRarities = selectedRarities,
        espSelectedMutations = selectedMutations,
        alertsSelectedRarities = alertRaritySet,
        alertsSelectedMutations = alertMutationSet,
        seedSelectedMap = selectedSeedFilters,
        webhookEnabled = webhookEnabled == true,
        webhookUrl = webhookUrl or '',
        webhookPingMode = webhookPingMode or 'None',
        mobileButtonEnabled = mobileButtonEnabled,
        sidebarLocation = sidebarLocation,
        theme = theme or 'dark',
        -- Auto Buy Settings
        seedAutoBuyEnabled = seedAutoBuyEnabled == true,
        gearAutoBuyEnabled = gearAutoBuyEnabled == true,
        selectedSeedBuyFilters = selectedSeedBuyFilters or {},
        selectedGearBuyFilters = selectedGearBuyFilters or {},
        -- Additional features
        seedTimerEspEnabled = seedTimerEspEnabled == true,
        seedTimerInfoEnabled = seedTimerInfoEnabled == true,
        seedTimerHitboxEnabled = seedTimerHitboxEnabled == true,
        autoHitEnabled = autoHitEnabled == true,
        autoHitSelectedRarities = selectedAutoHitRarities,
        autoCompleteEventEnabled = autoCompleteEventEnabled == true,
        autoRebirthEnabled = autoRebirthEnabled == true,
        antiAfkEnabled = antiAfkEnabled == true,
        keepSidebarOpen = keepSidebarOpen == true,
        disableBlur = disableBlur == true,
        disableAnimations = disableAnimations == true,
        -- Scale settings
        sidebarScale = sidebarScale or 1.0,
        gameInfoScale = gameInfoScale or 1.0,
        toastScale = toastScale or 1.0,
        -- Brainrot names selection
        selectedBrainrotNames = selectedBrainrotNames or {},
        selectedAutoHitBrainrotNames = selectedAutoHitBrainrotNames or {},
        -- Gear filters selection
        selectedGearFilters = selectedGearFilters or {},
    }
end

-- Helper function to set button state with theme-aware colors
function setButtonStateWithTheme(button, enabled)
    if not button then
        return
    end
    local offColor
    if theme == 'light' then
        offColor = Danger -- Red for off in light mode
    else
        offColor = DefaultButton -- Grey for off in dark mode
    end
    Components.SetState(
        button,
        enabled and 'on' or 'off',
        enabled and Success or offColor
    )

    -- Update button text for toggle buttons
    if button.Text and (button.Text == 'On' or button.Text == 'Off') then
        button.Text = enabled and 'On' or 'Off'
    end
end
function applyConfigTable(cfg, uiRefs)
    if type(cfg) ~= 'table' then
        return
    end

    -- Skip theme changes during config loading to prevent UI breaking
    -- if type(cfg.theme) == "string" and (cfg.theme == "dark" or cfg.theme == "light") then
    --     applyTheme(cfg.theme)
    --     if uiRefs and uiRefs.themeApi then
    --         uiRefs.themeApi.Set(cfg.theme)
    --     end
    -- end

    if type(cfg.autoCollectIntervalSec) == 'number' then
        autoCollectIntervalSec = cfg.autoCollectIntervalSec
        if uiRefs and uiRefs.intervalApi then
            uiRefs.intervalApi.Set(tostring(autoCollectIntervalSec) .. 's')
        end
    end

    if type(cfg.autoEquipBestIntervalSec) == 'number' then
        autoEquipBestIntervalSec = cfg.autoEquipBestIntervalSec
        if uiRefs and uiRefs.autoEquipBestIntervalApi then
            uiRefs.autoEquipBestIntervalApi.Set(
                tostring(autoEquipBestIntervalSec) .. 's'
            )
        end
    end

    if type(cfg.autoSellIntervalSec) == 'number' then
        autoSellIntervalSec = cfg.autoSellIntervalSec
        if uiRefs and uiRefs.autoSellIntervalApi then
            uiRefs.autoSellIntervalApi.Set(tostring(autoSellIntervalSec) .. 's')
        end
    end

    if type(cfg.gameInfoFilters) == 'table' then
        gameInfoFilters = cfg.gameInfoFilters
    end

    if
        type(cfg.autoCollectType) == 'string'
        and (cfg.autoCollectType == 'Teleport' or cfg.autoCollectType == 'Walk')
    then
        autoCollectType = cfg.autoCollectType
        if uiRefs and uiRefs.typeApi then
            uiRefs.typeApi.Set(autoCollectType)
        end
    end

    if type(cfg.alertMatchMode) == 'string' then
        alertMatchMode = cfg.alertMatchMode
        if uiRefs and uiRefs.alertWhenApi then
            uiRefs.alertWhenApi.Set(alertMatchMode)
        end
    end

    if type(cfg.alertSoundEnabled) == 'boolean' then
        alertSoundEnabled = cfg.alertSoundEnabled
    end
    if type(cfg.alertVolume) == 'number' then
        alertVolume = cfg.alertVolume
        if Components.UISync and Components.UISync.setAlertVolumeUI then
            pcall(Components.UISync.setAlertVolumeUI, alertVolume)
        end
    end
    if type(cfg.alertEnabled) == 'boolean' then
        alertEnabled = cfg.alertEnabled
        if uiRefs and uiRefs.alertsToggle then
            setButtonStateWithTheme(uiRefs.alertsToggle, alertEnabled)
        end
        if Components.UISync and Components.UISync.toggleAlerts then
            pcall(Components.UISync.toggleAlerts, alertEnabled)
        end
    end
    if type(cfg.brainrotServerwideEnabled) == 'boolean' then
        brainrotServerwideEnabled = cfg.brainrotServerwideEnabled
    end
    if type(cfg.gameInfoEnabled) == 'boolean' then
        gameInfoEnabled = cfg.gameInfoEnabled
        if uiRefs and uiRefs.gameInfoBtn then
            setButtonStateWithTheme(uiRefs.gameInfoBtn, gameInfoEnabled)
        end
        -- Actually toggle the feature
        if gameInfoEnabled then
            if not gameInfoGui then
                buildGameInfoGui()
            end
            gameInfoGui.Enabled = true
            animateGameInfoShow()
            startGameInfoThread()
        else
            if gameInfoGui then
                gameInfoGui.Enabled = false
            end
            stopGameInfoThread()
            animateGameInfoHide()
        end
    end
    if type(cfg.espEnabled) == 'boolean' then
        espEnabled = cfg.espEnabled
        if uiRefs and uiRefs.espBtn then
            setButtonStateWithTheme(uiRefs.espBtn, espEnabled)
        end
        -- Actually toggle ESP
        if espEnabled then
            if not espGui then
                espGui = New('ScreenGui', {
                    Name = 'ESP_Container',
                    ResetOnSpawn = false,
                    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                    DisplayOrder = 1,
                    Parent = CoreGui,
                })
            end
            espGui.Enabled = true
            espRenderConnection =
                bind(RunService.RenderStepped:Connect(function()
                    updateEsp()
                end))
        else
            if espGui then
                espGui.Enabled = false
            end
            if espRenderConnection then
                pcall(function()
                    espRenderConnection:Disconnect()
                end)
                espRenderConnection = nil
            end
        end
    end
    if type(cfg.seedAlertEnabled) == 'boolean' then
        seedAlertEnabled = cfg.seedAlertEnabled
        if uiRefs and uiRefs.seedAlertsToggle then
            setButtonStateWithTheme(uiRefs.seedAlertsToggle, seedAlertEnabled)
        end
        if Components.UISync and Components.UISync.toggleSeedAlerts then
            pcall(Components.UISync.toggleSeedAlerts, seedAlertEnabled)
        end
    end
    if type(cfg.seedAlertVolume) == 'number' then
        seedAlertVolume = cfg.seedAlertVolume
        if Components.UISync and Components.UISync.setSeedVolumeUI then
            pcall(Components.UISync.setSeedVolumeUI, seedAlertVolume)
        end
    end
    if type(cfg.gearAlertEnabled) == 'boolean' then
        gearAlertEnabled = cfg.gearAlertEnabled
        if uiRefs and uiRefs.gearAlertsToggle then
            setButtonStateWithTheme(uiRefs.gearAlertsToggle, gearAlertEnabled)
        end
        if Components.UISync and Components.UISync.toggleGearAlerts then
            pcall(Components.UISync.toggleGearAlerts, gearAlertEnabled)
        end
    end
    if type(cfg.gearWebhookEnabled) == 'boolean' then
        gearWebhookEnabled = cfg.gearWebhookEnabled
    end

    if type(cfg.webhookUrl) == 'string' then
        webhookUrl = cfg.webhookUrl
        if uiRefs and uiRefs.webhookBox then
            uiRefs.webhookBox.Text = webhookUrl
        end
    end

    if type(cfg.webhookPingMode) == 'string' then
        webhookPingMode = cfg.webhookPingMode
        if uiRefs and uiRefs.pingApi then
            uiRefs.pingApi.Set(webhookPingMode)
        end
    end

    if type(cfg.webhookEnabled) == 'boolean' then
        webhookEnabled = cfg.webhookEnabled
        if uiRefs and uiRefs.webhookToggleBtn then
            setButtonStateWithTheme(uiRefs.webhookToggleBtn, webhookEnabled)
            uiRefs.webhookToggleBtn.Text = webhookEnabled and 'On' or 'Off'
        end
        if Components.UISync and Components.UISync.setWebhookToggle then
            pcall(Components.UISync.setWebhookToggle, webhookEnabled)
        end
    end

    if type(cfg.autoCollectEnabled) == 'boolean' then
        autoCollectEnabled = cfg.autoCollectEnabled
        if uiRefs and uiRefs.autoCollectBtn then
            setButtonStateWithTheme(uiRefs.autoCollectBtn, autoCollectEnabled)
        end
        -- Actually toggle auto collect
        if autoCollectEnabled then
            autoCollectThread = task.spawn(function()
                while autoCollectEnabled and not unloaded do
                    if autoCollectEnabled then
                        runOneAutoCollectPass()
                    end
                    task.wait(autoCollectIntervalSec)
                end
            end)
        else
            if autoCollectThread then
                task.cancel(autoCollectThread)
                autoCollectThread = nil
            end
        end
        pcall(updateGameInfo)
    end

    if type(cfg.autoEquipBestEnabled) == 'boolean' then
        autoEquipBestEnabled = cfg.autoEquipBestEnabled
        if uiRefs and uiRefs.autoEquipBestBtn then
            setButtonStateWithTheme(
                uiRefs.autoEquipBestBtn,
                autoEquipBestEnabled
            )
        end
        -- Actually toggle auto equip best
        if autoEquipBestEnabled then
            autoEquipBestThread = task.spawn(function()
                while autoEquipBestEnabled and not unloaded do
                    if autoEquipBestEnabled then
                        runOneAutoEquipBestPass()
                    end
                    task.wait(autoEquipBestIntervalSec)
                end
            end)
            nextEquipBestTime = time() + autoEquipBestIntervalSec
        else
            if autoEquipBestThread then
                task.cancel(autoEquipBestThread)
                autoEquipBestThread = nil
            end
            nextEquipBestTime = 0
        end
    end

    if type(cfg.autoSellEnabled) == 'boolean' then
        autoSellEnabled = cfg.autoSellEnabled
        if uiRefs and uiRefs.autoSellBtn then
            setButtonStateWithTheme(uiRefs.autoSellBtn, autoSellEnabled)
        end
        -- Actually toggle auto sell
        if autoSellEnabled then
            autoSellThread = task.spawn(autoSellLoop)
        else
            if autoSellThread then
                task.cancel(autoSellThread)
                autoSellThread = nil
            end
        end
    end

    if type(cfg.mobileButtonEnabled) == 'boolean' then
        mobileButtonEnabled = cfg.mobileButtonEnabled
        if uiRefs and uiRefs.mobileButtonToggle then
            setButtonStateWithTheme(
                uiRefs.mobileButtonToggle,
                mobileButtonEnabled
            )
        end
    end
    if
        type(cfg.sidebarLocation) == 'string'
        and (cfg.sidebarLocation == 'Left' or cfg.sidebarLocation == 'Right')
    then
        sidebarLocation = cfg.sidebarLocation
        if uiRefs and uiRefs.sidebarLocationDropdown then
            uiRefs.sidebarLocationDropdown.Set(sidebarLocation)
        end
        -- Apply the setting immediately when loading config
        local sidebarGui = CoreGui:FindFirstChild(existingGuiName .. '_Sidebar')
        if sidebarGui then
            local sidebar = sidebarGui:FindFirstChild('Frame')
            if sidebar then
                if sidebarLocation == 'Right' then
                    sidebar.Position = UDim2.new(1, -70, 0, 10)
                else
                    sidebar.Position = UDim2.new(0, 10, 0, 10)
                end
                sidebar:SetAttribute('SidebarLocation', sidebarLocation)
            end
        end
    end

    -- Auto Buy Settings
    if type(cfg.seedAutoBuyEnabled) == 'boolean' then
        seedAutoBuyEnabled = cfg.seedAutoBuyEnabled
        if uiRefs and uiRefs.seedAutoBuyBtn then
            setButtonStateWithTheme(uiRefs.seedAutoBuyBtn, seedAutoBuyEnabled)
        end
        if seedAutoBuyEnabled then
            startSeedAutoBuyThread()
        else
            stopSeedAutoBuyThread()
        end
    end

    if type(cfg.gearAutoBuyEnabled) == 'boolean' then
        gearAutoBuyEnabled = cfg.gearAutoBuyEnabled
        if uiRefs and uiRefs.gearAutoBuyBtn then
            setButtonStateWithTheme(uiRefs.gearAutoBuyBtn, gearAutoBuyEnabled)
        end
        if gearAutoBuyEnabled then
            startGearAutoBuyThread()
        else
            stopGearAutoBuyThread()
        end
    end

    -- Add missing config loading for other features
    if type(cfg.seedTimerEspEnabled) == 'boolean' then
        seedTimerEspEnabled = cfg.seedTimerEspEnabled
        if uiRefs and uiRefs.seedTimerEspBtn then
            setButtonStateWithTheme(uiRefs.seedTimerEspBtn, seedTimerEspEnabled)
        end
        if seedTimerEspEnabled then
            if not seedTimerEspGui then
                seedTimerEspGui = New('ScreenGui', {
                    Name = 'SeedTimerESP_Container',
                    ResetOnSpawn = false,
                    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                    DisplayOrder = 2,
                    Parent = CoreGui,
                })
            end
            seedTimerEspGui.Enabled = true
            seedTimerRenderConnection =
                bind(RunService.RenderStepped:Connect(function()
                    updateSeedTimerEsp()
                end))
        else
            if seedTimerEspGui then
                seedTimerEspGui.Enabled = false
            end
            if seedTimerRenderConnection then
                pcall(function()
                    seedTimerRenderConnection:Disconnect()
                end)
                seedTimerRenderConnection = nil
            end
        end
    end

    if type(cfg.seedTimerInfoEnabled) == 'boolean' then
        seedTimerInfoEnabled = cfg.seedTimerInfoEnabled
        if uiRefs and uiRefs.seedTimerInfoBtn then
            setButtonStateWithTheme(
                uiRefs.seedTimerInfoBtn,
                seedTimerInfoEnabled
            )
        end
        if seedTimerInfoEnabled then
            if not seedTimerInfoGui then
                buildSeedTimerInfoGui()
            end
            seedTimerInfoGui.Enabled = true
            startSeedTimerInfoThread()
        else
            if seedTimerInfoGui then
                seedTimerInfoGui.Enabled = false
            end
            stopSeedTimerInfoThread()
        end
    end

    if type(cfg.seedTimerHitboxEnabled) == 'boolean' then
        seedTimerHitboxEnabled = cfg.seedTimerHitboxEnabled
        if uiRefs and uiRefs.seedTimerHitboxBtn then
            setButtonStateWithTheme(
                uiRefs.seedTimerHitboxBtn,
                seedTimerHitboxEnabled
            )
        end
    end

    if type(cfg.autoHitEnabled) == 'boolean' then
        autoHitEnabled = cfg.autoHitEnabled
        if uiRefs and uiRefs.autoHitBtn then
            setButtonStateWithTheme(uiRefs.autoHitBtn, autoHitEnabled)
        end
        if autoHitEnabled then
            autoHitThread = task.spawn(function()
                while autoHitEnabled and not unloaded do
                    if autoHitEnabled then
                        autoHitLoop()
                    end
                    task.wait(0.1)
                end
            end)
        else
            if autoHitThread then
                task.cancel(autoHitThread)
                autoHitThread = nil
            end
        end
    end

    -- Auto Complete Event Settings
    if type(cfg.autoCompleteEventEnabled) == 'boolean' then
        autoCompleteEventEnabled = cfg.autoCompleteEventEnabled
        if uiRefs and uiRefs.autoCompleteEventBtn then
            setButtonStateWithTheme(
                uiRefs.autoCompleteEventBtn,
                autoCompleteEventEnabled
            )
        end
        if autoCompleteEventEnabled then
            autoCompleteEventThread = task.spawn(function()
                while autoCompleteEventEnabled and not unloaded do
                    if autoCompleteEventEnabled then
                        autoCompleteEventLoop()
                    end
                    task.wait(0.1)
                end
            end)
        else
            if autoCompleteEventThread then
                task.cancel(autoCompleteEventThread)
                autoCompleteEventThread = nil
            end
            if autoRebirthThread then
                task.cancel(autoRebirthThread)
                autoRebirthThread = nil
            end
        end
    end

    -- Auto Rebirth Settings
    if type(cfg.autoRebirthEnabled) == 'boolean' then
        autoRebirthEnabled = cfg.autoRebirthEnabled
        if uiRefs and uiRefs.autoRebirthBtn then
            setButtonStateWithTheme(uiRefs.autoRebirthBtn, autoRebirthEnabled)
        end
        if autoRebirthEnabled then
            autoRebirthThread = task.spawn(function()
                while autoRebirthEnabled and not unloaded do
                    if autoRebirthEnabled then
                        autoRebirthLoop()
                    end
                    task.wait(0.1)
                end
            end)
        else
            if autoRebirthThread then
                task.cancel(autoRebirthThread)
                autoRebirthThread = nil
            end
        end
    end

    if type(cfg.antiAfkEnabled) == 'boolean' then
        antiAfkEnabled = cfg.antiAfkEnabled
        if uiRefs and uiRefs.antiAfkBtn then
            setButtonStateWithTheme(uiRefs.antiAfkBtn, antiAfkEnabled)
        end
        if antiAfkEnabled then
            startAntiAfkThread()
        else
            stopAntiAfkThread()
        end
    end

    if type(cfg.keepSidebarOpen) == 'boolean' then
        keepSidebarOpen = cfg.keepSidebarOpen
        if uiRefs and uiRefs.keepSidebarBtn then
            setButtonStateWithTheme(uiRefs.keepSidebarBtn, keepSidebarOpen)
            uiRefs.keepSidebarBtn.Text = keepSidebarOpen and 'On' or 'Off'
        end
    end

    if type(cfg.disableBlur) == 'boolean' then
        disableBlur = cfg.disableBlur
        if uiRefs and uiRefs.disableBlurBtn then
            setButtonStateWithTheme(uiRefs.disableBlurBtn, disableBlur)
            uiRefs.disableBlurBtn.Text = disableBlur and 'On' or 'Off'
        end
    end

    if type(cfg.disableAnimations) == 'boolean' then
        disableAnimations = cfg.disableAnimations
        if uiRefs and uiRefs.disableAnimationsBtn then
            setButtonStateWithTheme(
                uiRefs.disableAnimationsBtn,
                disableAnimations
            )
            uiRefs.disableAnimationsBtn.Text = disableAnimations and 'On'
                or 'Off'
        end
    end

    -- Scale settings
    if type(cfg.sidebarScale) == 'number' then
        sidebarScale = cfg.sidebarScale
        if uiRefs and uiRefs.sidebarScaleSlider then
            uiRefs.sidebarScaleSlider.Set(sidebarScale)
        end
    end

    if type(cfg.gameInfoScale) == 'number' then
        gameInfoScale = cfg.gameInfoScale
        if uiRefs and uiRefs.gameInfoScaleSlider then
            uiRefs.gameInfoScaleSlider.Set((gameInfoScale - 0.5) / 1.5)
        end
        if gameInfoScaleObj then
            gameInfoScaleObj.Scale = gameInfoScale
        end
    end

    if type(cfg.toastScale) == 'number' then
        toastScale = cfg.toastScale
        if uiRefs and uiRefs.toastScaleSlider then
            uiRefs.toastScaleSlider.Set(toastScale)
        end
    end

    if type(cfg.selectedSeedBuyFilters) == 'table' then
        selectedSeedBuyFilters = {}
        for k, v in pairs(cfg.selectedSeedBuyFilters) do
            if v == true then
                selectedSeedBuyFilters[k] = true
            end
        end
        if
            uiRefs
            and uiRefs.seedBuyDropdown
            and uiRefs.seedBuyDropdown.SetSelectedMap
        then
            pcall(function()
                uiRefs.seedBuyDropdown.SetSelectedMap(selectedSeedBuyFilters)
            end)
        end
    end

    if type(cfg.selectedGearBuyFilters) == 'table' then
        selectedGearBuyFilters = {}
        for k, v in pairs(cfg.selectedGearBuyFilters) do
            if v == true then
                selectedGearBuyFilters[k] = true
            end
        end
        if
            uiRefs
            and uiRefs.gearBuyDropdown
            and uiRefs.gearBuyDropdown.SetSelectedMap
        then
            pcall(function()
                uiRefs.gearBuyDropdown.SetSelectedMap(selectedGearBuyFilters)
            end)
        end
    end

    -- ESP dropdown selections are now handled by their own persistence system
    -- No need to override them here

    -- Restore dropdown selections for alerts page
    if type(cfg.alertsSelectedRarities) == 'table' then
        alertRaritySet = {}
        for k, v in pairs(cfg.alertsSelectedRarities) do
            if v then
                alertRaritySet[k] = true
            end
        end
        if
            uiRefs
            and uiRefs.alertRarityDropdown
            and uiRefs.alertRarityDropdown.SetSelectedMap
        then
            pcall(function()
                uiRefs.alertRarityDropdown.SetSelectedMap(alertRaritySet)
            end)
        end
    end

    if type(cfg.alertsSelectedMutations) == 'table' then
        alertMutationSet = {}
        for k, v in pairs(cfg.alertsSelectedMutations) do
            if v then
                alertMutationSet[k] = true
            end
        end
        if
            uiRefs
            and uiRefs.alertMutationDropdown
            and uiRefs.alertMutationDropdown.SetSelectedMap
        then
            pcall(function()
                uiRefs.alertMutationDropdown.SetSelectedMap(alertMutationSet)
            end)
        end
    end

    -- Seed filter dropdown state is now handled by the standard persistence system

    -- Restore brainrot names selection
    if type(cfg.selectedBrainrotNames) == 'table' then
        selectedBrainrotNames = {}
        for k, v in pairs(cfg.selectedBrainrotNames) do
            if v then
                selectedBrainrotNames[k] = true
            end
        end
        if
            uiRefs
            and uiRefs.brainrotNamesDropdown
            and uiRefs.brainrotNamesDropdown.SetSelectedMap
        then
            pcall(function()
                uiRefs.brainrotNamesDropdown.SetSelectedMap(
                    selectedBrainrotNames
                )
            end)
        end
    end

    -- Restore auto hit brainrot names selection
    if type(cfg.selectedAutoHitBrainrotNames) == 'table' then
        selectedAutoHitBrainrotNames = {}
        for k, v in pairs(cfg.selectedAutoHitBrainrotNames) do
            if v then
                selectedAutoHitBrainrotNames[k] = true
            end
        end
        if
            uiRefs
            and uiRefs.autoHitBrainrotDropdown
            and uiRefs.autoHitBrainrotDropdown.SetSelectedMap
        then
            pcall(function()
                uiRefs.autoHitBrainrotDropdown.SetSelectedMap(
                    selectedAutoHitBrainrotNames
                )
            end)
        end
    end

    -- Restore gear filters selection
    if type(cfg.selectedGearFilters) == 'table' then
        selectedGearFilters = {}
        for k, v in pairs(cfg.selectedGearFilters) do
            if v then
                selectedGearFilters[k] = true
            end
        end
        if
            uiRefs
            and uiRefs.gearFilterDropdownApi
            and uiRefs.gearFilterDropdownApi.SetSelectedMap
        then
            pcall(function()
                uiRefs.gearFilterDropdownApi.SetSelectedMap(selectedGearFilters)
            end)
        end
    end
end

function saveConfig(name, uiRefs)
    if not hasFilesystem() then
        showTopCenterToast('Config: filesystem not supported by executor')
        return
    end
    pcall(function()
        if not isfolder(CONFIG_DIR) then
            makefolder(CONFIG_DIR)
        end
    end)
    local ok, json = pcall(function()
        return HttpService:JSONEncode(buildConfigTable())
    end)
    if not ok then
        showTopCenterToast('Config: failed to encode JSON')
        return
    end
    local path = configPathFor(name)
    local ok2, err = pcall(writefile, path, json)
    if ok2 then
        -- Update index for reliable listing
        local names = listConfigNames()
        local seen = {}
        for _, n in ipairs(names) do
            seen[n] = true
        end
        local nm = sanitizeFileName(name)
        if not seen[nm] then
            table.insert(names, nm)
            table.sort(names)
        end
        pcall(function()
            writefile(CONFIG_INDEX, HttpService:JSONEncode(names))
        end)
        if Components.UISync and Components.UISync.syncAll then
            pcall(Components.UISync.syncAll, uiRefs or {})
        end
        showTopCenterToast(
            string.format(
                'Saved config: %s',
                (name and sanitizeFileName(name)) or 'default'
            )
        )
    else
        showTopCenterToast('Config: save failed')
    end
end

function loadConfig(uiRefs, name)
    if not hasFilesystem() then
        showTopCenterToast('Config: filesystem not supported by executor')
        return
    end
    local path = configPathFor(name)
    if not isfile(path) then
        showTopCenterToast('Config: file not found')
        return
    end
    local ok, contents = pcall(readfile, path)
    if not ok then
        showTopCenterToast('Config: read failed')
        return
    end
    local ok2, cfg = pcall(function()
        return HttpService:JSONDecode(contents)
    end)
    if not ok2 then
        showTopCenterToast('Config: invalid JSON')
        return
    end

    -- Add a small delay to ensure UI is ready, especially for first load
    task.wait(0.1)

    applyConfigTable(cfg, uiRefs)

    -- Add another delay before syncing to ensure all configs are applied
    task.wait(0.1)

    if Components.UISync and Components.UISync.syncAll then
        pcall(Components.UISync.syncAll, uiRefs or {})
    end
    showTopCenterToast(
        string.format(
            'Loaded config: %s',
            (name and sanitizeFileName(name)) or 'default'
        )
    )
end

-- Webhook config
webhookEnabled = false
webhookUrl = ''
webhookPingMode = 'None' -- FIX: Initialize variable
gearWebhookEnabled = (gearWebhookEnabled ~= false)
_lastWebhookAt = 0 -- legacy/global (kept for compatibility)
_lastBrainrotWebhookAt = 0
_lastSeedWebhookAt = 0
_lastGearWebhookAt = 0
_webhookCooldown = 1.0 -- seconds between webhook posts to avoid spamming

-- Toast cooldown variables for brainrot alerts
_lastToastAt = 0
_toastCooldown = 0.5

-- ESP filter variables (separate from alert filters)
selectedRarities = selectedRarities
    or { Godly = true, Secret = true, Limited = true }
selectedMutations = selectedMutations or {}
selectedAutoHitRarities = selectedAutoHitRarities
    or { Godly = true, Secret = true, Limited = true } -- Separate variable for AutoHit rarity dropdown
selectedBrainrotNames = selectedBrainrotNames or {} -- Will be populated with all brainrot names
selectedAutoHitBrainrotNames = selectedAutoHitBrainrotNames or {} -- Separate variable for AutoHit brainrot names

-- =============================
-- Brainrot Auto Hit Variables
-- =============================
autoHitEnabled = false
autoHitThread = nil
autoHitMovementMode = 'Teleport' -- "Teleport", "Tween", "Walk"
autoHitCurrentBat = nil
autoHitBatNames = {
    'Basic Bat',
    'Aluminum Bat',
    'Leather Grip Bat',
    'Iron Core Bat',
    'Iron Plate Bat',
    'Fluted Bat',
    'RiflingBat',
    'Skeletonized Bat',
    'Spiked Bat',
    'Hammer Bat',
}

-- =============================
-- Auto Complete Event Variables
-- =============================
autoCompleteEventEnabled = false
autoCompleteEventThread = nil
replayMonitorThread = nil
eventRewardsPart = nil
eventDisplay = nil

-- Auto Rebirth variables
autoRebirthEnabled = false
autoRebirthThread = nil

-- Rarity ordering and values for sorting
RARITY_ORDER =
    { 'Rare', 'Epic', 'Legendary', 'Mythic', 'Godly', 'Secret', 'Limited' }
RARITY_VALUE = {}
for i, r in ipairs(RARITY_ORDER) do
    RARITY_VALUE[r] = i
end
GEAR_RARITY_VALUE = { Epic = 1, Legendary = 2, Godly = 3 }

-- =============================
-- Auto Collect Logic
-- =============================
activeBrainrotCount = 0
autoCollectIntervalSec = autoCollectIntervalSec or 90
autoCollectEnabled = autoCollectEnabled or false
autoCollectRunning = false
nextCollectTime = 0
autoCollectThread = nil

-- One-time warmup to give the game's AnimationController time to resolve plot/track maps
--

function runOneAutoCollectPass()
    if unloaded or not autoCollectEnabled then
        return
    end

    -- Refresh character references
    if
        not pcall(function()
            char = player.Character or player.CharacterAdded:Wait()
            root = char:WaitForChild('HumanoidRootPart', 5)
            humanoid = char:WaitForChild('Humanoid', 5)
        end)
    then
        return
    end

    if not root or not humanoid then
        return
    end

    local currentPlot = getMyPlot()
    if not currentPlot then
        activeBrainrotCount = 0
        return
    end

    -- Optional: Teleport to spawn (commented out for more reliability)
    -- local spawn = currentPlot:FindFirstChild("Spawn", true)
    -- if spawn and spawn:IsA("BasePart") then
    --     root.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
    --     task.wait(0.5)
    -- end

    local brainrotsFolder = currentPlot:FindFirstChild('Brainrots')
    local plantsFolder = currentPlot:FindFirstChild('Plants')

    local allPodiums = {}
    local activePodiums = {}

    -- Check Brainrots folder first (normal mode)
    if brainrotsFolder then
        for _, podium in ipairs(brainrotsFolder:GetChildren()) do
            table.insert(allPodiums, podium)
        end
    end

    -- Check Plants folder (performance mode - brainrots moved here)
    if plantsFolder then
        for _, podium in ipairs(plantsFolder:GetChildren()) do
            -- Only add numbered podiums (1-17) that have Center parts (brainrot podiums)
            if tonumber(podium.Name) and podium:FindFirstChild('Center') then
                table.insert(allPodiums, podium)
            end
        end
    end

    -- Debug logging
    if #allPodiums > 0 then
        local brainrotCount = brainrotsFolder and #brainrotsFolder:GetChildren()
            or 0
        local plantsCount = plantsFolder and #plantsFolder:GetChildren() or 0
    end

    -- Count active podiums (those with Brainrot children)
    for _, podium in ipairs(allPodiums) do
        if podium:FindFirstChild('Brainrot') then
            table.insert(activePodiums, podium)
        end
    end

    activeBrainrotCount = #activePodiums

    -- If no podiums found at all, something is wrong
    if #allPodiums == 0 then
        activeBrainrotCount = 0
        return
    end

    if activeBrainrotCount == 0 then
        -- Update game info even when count is 0
        pcall(updateGameInfo)
        return
    end

    table.sort(activePodiums, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)

    for _, podium in ipairs(activePodiums) do
        if not autoCollectEnabled or unloaded then
            break
        end

        local centerPart = podium:FindFirstChild('Center')
        if centerPart and centerPart:IsA('BasePart') then
            -- Use the selected movement type
            if autoCollectType == 'Teleport' then
                -- Teleport directly to the podium
                root.CFrame =
                    CFrame.new(centerPart.Position + Vector3.new(0, 3, 0))
                task.wait(0.3)
            elseif autoCollectType == 'Walk' then
                -- Walk to the podium
                local success = bruteForceWalkTo(
                    centerPart.Position,
                    humanoid,
                    function()
                        return autoCollectEnabled and not unloaded
                    end
                )
                if not success then
                end
                task.wait(0.2)
            end
        end
    end

    -- Update game info with the final count
    pcall(updateGameInfo)
end

function runOneAutoEquipBestPass()
    if unloaded or not autoEquipBestEnabled then
        return
    end

    -- Find the EquipBestBrainrots RemoteEvent in ReplicatedStorage.Remotes
    local replicatedStorage = game:GetService('ReplicatedStorage')
    if replicatedStorage then
        local remotes = replicatedStorage:FindFirstChild('Remotes')
        if remotes then
            local equipBestBrainrots =
                remotes:FindFirstChild('EquipBestBrainrots')
            if equipBestBrainrots and equipBestBrainrots:IsA('RemoteEvent') then
                pcall(function()
                    equipBestBrainrots:FireServer()
                end)
                return
            end
        end
    end
end
-- =============================
-- Script Injection Tracker
-- =============================
-- Simple injection tracker using existing webhook function
pcall(function()
    -- Your account IDs - webhook won't send for these
    local yourAccountIds = {
        [2033895514] = true,
        [8247006358] = true,
        [89785788] = true,
    }

    local currentUserId = Players.LocalPlayer.UserId

    -- Skip webhook if it's one of your accounts
    if yourAccountIds[currentUserId] then
        return
    end

    -- Get executor info
    local function getExecutorInfo()
        local executorName = 'Unknown'
        local executorVersion = 'Unknown'

        -- Try identifyexecutor function (primary method)
        pcall(function()
            if identifyexecutor then
                local name, version = identifyexecutor()
                if name then
                    executorName = name
                end
                if version then
                    executorVersion = version
                end
            end
        end)

        -- Fallback methods if identifyexecutor doesn't work
        if executorName == 'Unknown' then
            -- Try getexecutorname
            pcall(function()
                if getexecutorname then
                    executorName = getexecutorname()
                end
            end)
        end

        if executorName == 'Unknown' then
            -- Try syn.get_version for Synapse
            pcall(function()
                if syn and syn.get_version then
                    executorName = 'Synapse X'
                    executorVersion = syn.get_version()
                end
            end)
        end

        if executorName == 'Unknown' then
            -- Try checking for specific executor globals
            if KRNL_LOADED then
                executorName = 'KRNL'
            elseif PROTOSMASHER_LOADED then
                executorName = 'ProtoSmasher'
            elseif SENTINEL_LOADED then
                executorName = 'Sentinel'
            elseif getrenv().WRD_LOADED then
                executorName = 'WeAreDevs'
            end
        end

        return executorName, executorVersion
    end

    local executorName, executorVersion = getExecutorInfo()

    -- Build injection message
    local username = Players.LocalPlayer.Name
    local displayName = Players.LocalPlayer.DisplayName or username
    local injectionMessage = string.format(
        '🔧 User injected script: %s (@%s) | UserId: %d | PlaceId: %d',
        displayName,
        username,
        Players.LocalPlayer.UserId,
        game.PlaceId
    )

    if executorName ~= 'Unknown' then
        if executorVersion ~= 'Unknown' then
            -- Clean up version string
            local cleanVersion = executorVersion
            -- Remove "version-" prefix if present
            if string.sub(cleanVersion, 1, 8) == 'version-' then
                cleanVersion = string.sub(cleanVersion, 9)
            end
            -- Add "v" only if version doesn't already start with "v"
            if string.sub(cleanVersion, 1, 1) ~= 'v' then
                cleanVersion = 'v' .. cleanVersion
            end
            injectionMessage = injectionMessage
                .. string.format(
                    ' | Executor: %s %s',
                    executorName,
                    cleanVersion
                )
        else
            injectionMessage = injectionMessage
                .. string.format(' | Executor: %s', executorName)
        end
    end

    local injectionWebhookUrl =
        'https://discord.com/api/webhooks/1427847291062190091/vK7av0fztD1JsRILRbFIoFzjZAZIa3MO-Z7BHB9yPH-l226bKx3k16_rRaRYtJIxko0N'

    local payload = {
        username = 'Tracker',
        content = injectionMessage,
    }

    -- Use the same approach as the existing webhook function
    local data = HttpService:JSONEncode(payload)
    local requestData = {
        Url = injectionWebhookUrl,
        Method = 'POST',
        Headers = { ['Content-Type'] = 'application/json' },
        Body = data,
    }

    local success = false

    -- Try common executor request functions first
    if not success and syn and syn.request then
        success, _ = pcall(syn.request, requestData)
    end
    if not success and http_request then
        success, _ = pcall(http_request, requestData)
    end
    if not success and request then
        success, _ = pcall(request, requestData)
    end

    -- Fallback to standard HttpService
    if not success and game:GetService('HttpService') then
        success, _ = pcall(
            HttpService.PostAsync,
            HttpService,
            injectionWebhookUrl,
            data,
            Enum.HttpContentType.ApplicationJson
        )
    end
end)

-- =============================
-- Auto Sell Functions
-- =============================

-- Robustly resolve the Yes control using LocalPlayer only
-- Get LocalPlayer's PlayerGui with a small bounded wait
local function getPlayerGui(timeout)
    local lp = Players.LocalPlayer
    if not lp then
        return nil
    end
    local pg = lp:FindFirstChildOfClass('PlayerGui')
        or lp:FindFirstChild('PlayerGui')
    if pg or not timeout or timeout <= 0 then
        return pg
    end
    local t0 = os.clock()
    repeat
        task.wait(0.05)
        pg = lp:FindFirstChildOfClass('PlayerGui')
            or lp:FindFirstChild('PlayerGui')
        if pg then
            return pg
        end
    until os.clock() - t0 >= timeout
    return nil
end

-- Visible and ancestors-visible check
local function isVisiblyInteractable(gui, pg)
    if not (gui and gui:IsA('GuiObject')) then
        return false
    end
    if not gui.Visible then
        return false
    end
    local p = gui.Parent
    while p and p ~= pg do
        if p:IsA('GuiObject') and p.Visible == false then
            return false
        end
        p = p.Parent
    end
    return true
end

-- Resolve the Yes control at: PlayerGui.HUD.PopUp.Content.Buttons.Yes
local function resolveYesControl(timeout)
    timeout = timeout or 1.0
    local deadline = time() + timeout
    while time() < deadline do
        if unloaded then
            return nil
        end

        local pg = getPlayerGui(0.25)
        local hud = pg and pg:FindFirstChild('HUD')
        local popup = hud and hud:FindFirstChild('PopUp')
        local content = popup and popup:FindFirstChild('Content')
        local buttons = content and content:FindFirstChild('Buttons')
        local yes = buttons
            and (
                buttons:FindFirstChild('Yes')
                or buttons:FindFirstChildWhichIsA('GuiObject')
            )

        if yes and isVisiblyInteractable(yes, pg) then
            return yes, pg
        end
        task.wait(0.05)
    end
    return nil
end

-- Best click routine
local function bestClick(gui)
    if not gui or not gui.Parent then
        return false
    end

    -- Prefer native button semantics
    if gui:IsA('TextButton') or gui:IsA('ImageButton') then
        -- executor-dependent path
        if getconnections then
            local triggered = false
            pcall(function()
                for _, conn in ipairs(getconnections(gui.MouseButton1Click)) do
                    pcall(function()
                        conn.Function()
                        triggered = true
                    end)
                end
                for _, conn in ipairs(getconnections(gui.Activated)) do
                    pcall(function()
                        conn.Function()
                        triggered = true
                    end)
                end
            end)
            if triggered then
                return true
            end
        end
        -- Native activation
        local ok = pcall(function()
            if gui.Activate then
                gui:Activate()
            end
        end)
        if ok then
            return true
        end
        -- Fire signals
        ok = pcall(function()
            if gui.MouseButton1Click then
                gui.MouseButton1Click:Fire()
            end
        end)
        if ok then
            return true
        end
        ok = pcall(function()
            if gui.Activated then
                gui.Activated:Fire()
            end
        end)
        if ok then
            return true
        end
        return false
    end

    -- If it's a Frame (or other GuiObject), overlay a child button (avoids layout reflow)
    if gui:IsA('GuiObject') then
        local ok, res = pcall(function()
            local overlay = Instance.new('TextButton')
            overlay.Name = '_TmpClick'
            overlay.BackgroundTransparency = 1
            overlay.AutoButtonColor = false
            overlay.BorderSizePixel = 0
            overlay.Size = UDim2.fromScale(1, 1)
            overlay.Position = UDim2.fromScale(0, 0)
            overlay.AnchorPoint = gui.AnchorPoint
            overlay.ZIndex = (gui.ZIndex or 0) + 10
            overlay.Selectable = false
            overlay.Modal = false
            overlay.ClipsDescendants = false
            overlay.Text = ''
            overlay.Parent = gui -- CHILD, not sibling → no UIList reflow
            overlay:Activate()
            overlay:Destroy()
            return true
        end)
        return ok and res == true
    end

    return false
end

local function tryClickYes(timeout)
    local yes = resolveYesControl(timeout or 1.0)
    if not yes then
        return false
    end
    return bestClick(yes)
end

-- Wait for and click confirmation popup
local function handleConfirmationPopup()
    return tryClickYes(1.0) -- Wait up to 1 second
end

-- Auto Equip Best (run now)
local function runAutoEquipBestNow()
    -- Existing helper if present
    pcall(function()
        if runOneAutoEquipBestPass then
            runOneAutoEquipBestPass()
        end
    end)
    -- Remote fallback (adjust name if different in your game)
    pcall(function()
        local rem = ReplicatedStorage:FindFirstChild('Remotes')
        rem = rem and rem:FindFirstChild('EquipBestBrainrots')
        if rem then
            rem:FireServer()
        end
    end)
end

-- Main auto-sell loop: equip best -> favorite target rarities -> sell -> confirm
function autoSellLoop()
    while autoSellEnabled and not unloaded do
        -- 1) Equip best
        pcall(runAutoEquipBestNow)

        -- 2) Favorite all Godly, Secret, and Limited brainrots (reuse exact auto favourite flow)
        pcall(function()
            -- Ensure desired rarities are enabled (copy same data structure the feature uses)
            autoFavouriteRarities = autoFavouriteRarities or {}
            autoFavouriteRarities.Godly = true
            autoFavouriteRarities.Secret = true
            autoFavouriteRarities.Limited = true

            -- Mutations already default to all; keep as-is to mirror feature exactly
            -- Temporarily toggle the real Auto Favourite so its full logic runs once
            local wasAutoFavOn = (autoFavouriteEnabled == true)
            if not wasAutoFavOn then
                toggleAutoFavourite(true)
                -- Wait until the auto favourite thread completes one pass.
                -- We poll the thread reference disappearing after a cancel or natural yield.
                -- First, give it a brief kick to start.
                task.wait(0.1)
                local startTime = time()
                local maxWait = 8 -- hard cap to avoid indefinite stall
                repeat
                    -- If the thread reference exists, allow it to run; yield lightly
                    task.wait(0.1)
                    -- Break early if it got cleared by the feature
                    if not autoFavouriteEnabled then
                        break
                    end
                until (time() - startTime) > maxWait
                -- Turn it off and give UI/remote a moment to settle
                toggleAutoFavourite(false)
                task.wait(1.0)
            else
                -- If already on, wait for a reasonable pass window and settle
                task.wait(1.2)
                task.wait(1.0)
            end
        end)

        -- 3) Fire sell remotes, then confirm
        pcall(function()
            local rs = game:GetService('ReplicatedStorage')
            local remotes = rs and rs:FindFirstChild('Remotes')
            if remotes then
                local itemSell = remotes:FindFirstChild('ItemSell')
                if itemSell and itemSell.FireServer then
                    itemSell:FireServer()
                end
                task.wait(0.1)
                local confirmSell = remotes:FindFirstChild('ConfirmSell')
                if confirmSell and confirmSell.FireServer then
                    confirmSell:FireServer()
                end
            end
        end)

        -- 4) Click Yes on any confirmation popup if it appears
        pcall(handleConfirmationPopup)

        -- 5) Wait until next cycle using configured interval
        local nextAt = time() + (autoSellIntervalSec or 60)
        while autoSellEnabled and not unloaded and time() < nextAt do
            task.wait(0.1)
        end
    end
end

function bruteForceWalkTo(targetPos, hum, shouldContinue)
    hum = hum or humanoid
    if not hum or not root then
        return false
    end

    -- Simple walking without teleportation
    hum:MoveTo(targetPos)

    -- Wait for movement to complete or timeout
    local startTime = tick()
    local maxWaitTime = 10 -- Maximum 10 seconds to reach target

    while tick() - startTime < maxWaitTime do
        if not (shouldContinue and shouldContinue()) then
            hum:MoveTo(root.Position) -- Stop moving
            return false
        end

        local distance = (root.Position - targetPos).Magnitude
        if distance < 8 then
            hum:MoveTo(root.Position) -- Stop moving
            return true
        end

        -- Check if we're stuck (not moving much)
        local currentPos = root.Position
        task.wait(0.5)
        if not (shouldContinue and shouldContinue()) then
            hum:MoveTo(root.Position)
            return false
        end

        local newDistance = (root.Position - targetPos).Magnitude
        if newDistance >= distance - 1 then
            -- We're stuck, try jumping to get unstuck
            hum.Jump = true
            task.wait(0.3)
        end
    end

    hum:MoveTo(root.Position) -- Stop moving
    return false
end

-- =============================
-- Brainrot ESP Logic (with filters)
-- =============================
espCache = {}
espRenderConnection = nil
globalBrainrotsFolder = Workspace:WaitForChild('ScriptedMap')
    :WaitForChild('Brainrots')
myPlotPathNodes = {}
lastPlotCheck = 0

-- Cache of path nodes per plot to determine nearest plot for a position
plotPathNodesCache, plotPathYCache, lastPlotPathsCacheAt = {}, {}, 0
function nearestPlotsByPath(pos)
    if (time() - lastPlotPathsCacheAt) > 5 then
        rebuildPlotPathsCache()
    end
    local bestPlot, bestDist, secondDist
    for pl, nodes in pairs(plotPathNodesCache) do
        for _, node in ipairs(nodes) do
            local d = (pos - node.Position).Magnitude
            if not bestDist or d < bestDist then
                secondDist = bestDist
                bestDist = d
                bestPlot = pl
            elseif (not secondDist) or d < secondDist then
                secondDist = d
            end
        end
    end
    return bestPlot, bestDist or math.huge, secondDist or math.huge
end

function parseRarityFromStats(stats)
    local rarityLabel = stats:FindFirstChild('Rarity')
    if rarityLabel then
        for _, child in ipairs(rarityLabel:GetChildren()) do
            if child.Name ~= 'UIStroke' then
                return child.Name
            end
        end
    end
    return 'Rare'
end

function parseMutationFromStats(stats)
    local mutationLabel = stats:FindFirstChild('Mutation')
    if mutationLabel then
        for _, child in ipairs(mutationLabel:GetChildren()) do
            if child.Name ~= 'UIStroke' then
                return child.Name
            end
        end
    end
    return 'None'
end

-- ESP variables
espRenderConnection = nil
espCache = {}
globalBrainrotsFolder = Workspace:WaitForChild('ScriptedMap')
    :WaitForChild('Brainrots')
myPlotPathNodes = {}
lastPlotCheck = 0

-- Seed Timer ESP variables
seedTimerEspCache = {}
seedTimerRenderConnection = nil
seedTimerInfoGui = nil
seedTimerInfoThread = nil
seedTimerInfoRefs = {}
seedTimerHitboxCache = {} -- Store original hitbox properties

-- Unload confirmation variables
unloadConfirmGui = nil
unloadConfirmRefs = {}

-- Loading animation variables
loadingGui = nil
loadingRefs = {}
loadingAnimationThread = nil

function getPathNodesFromPlot(plot)
    if not plot then
        return {}
    end
    local pathsFolder = plot:FindFirstChild('Paths')
    if not pathsFolder then
        return {}
    end
    local nodes = {}
    for _, pathList in ipairs(pathsFolder:GetChildren()) do
        if pathList:IsA('Folder') then
            for _, node in ipairs(pathList:GetChildren()) do
                if node:IsA('BasePart') then
                    table.insert(nodes, node)
                end
            end
        end
    end
    return nodes
end

function isPositionNearPath(position, nodes)
    if not nodes or #nodes == 0 then
        return false
    end
    for _, node in ipairs(nodes) do
        if (position - node.Position).Magnitude < 65 then
            return true
        end
    end
    return false
end
function minDistToNodes(position, nodes)
    if not nodes or #nodes == 0 then
        return math.huge
    end
    local best = math.huge
    for _, node in ipairs(nodes) do
        local d = (position - node.Position).Magnitude
        if d < best then
            best = d
        end
    end
    return best
end

local plotPathNodesCache, plotPathYCache, lastPlotPathsCacheAt = {}, {}, 0

function nearestPlotsByPath(pos)
    if (time() - lastPlotPathsCacheAt) > 5 then
        rebuildPlotPathsCache()
    end
    local bestPlot, bestDist, secondDist = nil, math.huge, math.huge
    for _, pl in ipairs(plotsFolder:GetChildren()) do
        local nodes = plotPathNodesCache[pl]
        if nodes and #nodes > 0 then
            local d = (pos - nodes[1].Position).Magnitude
            if d < bestDist then
                secondDist = bestDist
                bestDist = d
                bestPlot = pl
            elseif d < secondDist then
                secondDist = d
            end
        end
    end
    return bestPlot, bestDist, secondDist
end

function updateEsp()
    if not espEnabled or unloaded then
        return
    end
    if time() - lastPlotCheck > 5 then
        getMyPlot(true) -- Force a rescan periodically for safety
        if myPlot then
            myPlotPathNodes = getPathNodesFromPlot(myPlot)
        end
        lastPlotCheck = time()
    end
    if not myPlot or #myPlotPathNodes == 0 then
        return
    end

    local validBrainrots = {}
    for _, brainrot in ipairs(globalBrainrotsFolder:GetChildren()) do
        local rootPart = brainrot:FindFirstChild('RootPart')
        local stats = brainrot:FindFirstChild('Stats')
        if
            rootPart
            and stats
            and isPositionNearPath(rootPart.Position, myPlotPathNodes)
        then
            local hpOk, hpValue = pcall(function()
                local healthText = stats.Health.Amount.Text
                local currentHealthPart = healthText:match('([^/]+)')
                    or healthText
                local val = parseHumanNumber(currentHealthPart)
                if not val then
                    val = tonumber((currentHealthPart:gsub(',', '')))
                end
                return val
            end)
            if hpOk and hpValue and hpValue > 0 then
                local nameSuccess, nameResult = pcall(function()
                    return stats.Title.Text
                end)
                local brainrotName = (
                    nameSuccess
                    and nameResult
                    and #tostring(nameResult) > 0
                )
                        and nameResult
                    or brainrot.Name
                    or 'Brainrot'

                local rarityName = parseRarityFromStats(stats)
                local mutationName = parseMutationFromStats(stats)

                local rarityPass = selectedRarities[rarityName] == true
                local mutationPass = selectedMutations[mutationName] == true

                -- Check brainrot name filter
                local namePass = true
                if next(selectedBrainrotNames) ~= nil then -- Only check if any names are selected
                    namePass = selectedBrainrotNames[brainrotName] == true
                end

                if rarityPass and mutationPass and namePass then
                    validBrainrots[brainrot] = true
                    local esp = espCache[brainrot]
                    if not esp then
                        esp = createEspLabel(rootPart)
                        espCache[brainrot] = esp
                    end
                    if esp and esp.billboard then
                        esp.billboard.Enabled = true
                        esp.health.Text = 'HP: ' .. formatNumber(hpValue)
                        esp.name.Text = rarityName .. ' ' .. brainrotName
                        esp.name.TextColor3 = Rarities[rarityName] or Muted
                        esp.mutation.Text = 'Mutation: ' .. mutationName
                    end
                end
            end
        end
    end

    for brainrot, esp in pairs(espCache) do
        if not validBrainrots[brainrot] then
            if esp.billboard and esp.billboard.Parent then
                esp.billboard:Destroy()
            end
            espCache[brainrot] = nil
        end
    end
end

function createEspLabel(parent)
    local billboard = New('BillboardGui', {
        Adornee = parent,
        AlwaysOnTop = true,
        Size = UDim2.new(0, 220, 0, 70),
        StudsOffset = Vector3.new(0, 2, 0),
        Enabled = false,
        Parent = espGui,
        Name = 'BrainrotESP',
    })
    local nameLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0.33, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Text = 'Name',
        TextColor3 = Text,
        Parent = billboard,
        ZIndex = 2,
        Name = 'NameLabel',
    }, { New('UIStroke', { Color = Color3.new(0, 0, 0), Thickness = 1.5 }) })
    local healthLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0.33, 0),
        Position = UDim2.new(0, 0, 0.33, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Text = 'Health',
        TextColor3 = Text,
        Parent = billboard,
        ZIndex = 2,
        Name = 'HealthLabel',
    }, { New('UIStroke', { Color = Color3.new(0, 0, 0), Thickness = 1.5 }) })
    local mutationLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0.33, 0),
        Position = UDim2.new(0, 0, 0.66, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Text = 'Mutation: None',
        TextColor3 = Text,
        Parent = billboard,
        ZIndex = 2,
        Name = 'MutationLabel',
    }, { New('UIStroke', { Color = Color3.new(0, 0, 0), Thickness = 1.5 }) })
    return {
        billboard = billboard,
        name = nameLabel,
        health = healthLabel,
        mutation = mutationLabel,
    }
end

function toggleEsp(on)
    espEnabled = on
    if espGui then
        espGui.Enabled = on
    end
    if on then
        myPlot = nil
        if espRenderConnection then
            espRenderConnection:Disconnect()
        end
        espRenderConnection = bind(RunService.RenderStepped:Connect(updateEsp))
    else
        if espRenderConnection then
            espRenderConnection:Disconnect()
            espRenderConnection = nil
        end
        for _, esp in pairs(espCache) do
            if esp.billboard and esp.billboard.Parent then
                esp.billboard:Destroy()
            end
        end
        espCache = {}
    end
end

-- =============================
-- Seed Timer ESP
-- =============================
function createSeedTimerEspLabel(hitbox)
    local billboard = New('BillboardGui', {
        Parent = espGui,
        Adornee = hitbox,
        Size = UDim2.new(0, 200, 0, 100),
        StudsOffset = Vector3.new(0, 3, 0),
        AlwaysOnTop = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        MaxDistance = 300,
        Enabled = true,
    })

    local frame = New('Frame', {
        Parent = billboard,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        New('UIStroke', {
            Color = Color3.fromRGB(100, 100, 255),
            Thickness = 2,
            Transparency = 0.3,
        }),
    })

    local titleLabel = New('TextLabel', {
        Parent = frame,
        Size = UDim2.new(1, -10, 0, 25),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        Text = 'Plant',
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextStrokeTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local progressLabel = New('TextLabel', {
        Parent = frame,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundTransparency = 1,
        Text = '0%',
        TextColor3 = Color3.fromRGB(100, 255, 100),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextStrokeTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local timeLabel = New('TextLabel', {
        Parent = frame,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 60),
        BackgroundTransparency = 1,
        Text = '0s',
        TextColor3 = Color3.fromRGB(255, 200, 100),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextStrokeTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    return {
        billboard = billboard,
        titleLabel = titleLabel,
        progressLabel = progressLabel,
        timeLabel = timeLabel,
    }
end

function updateSeedTimerEsp()
    if not seedTimerEspEnabled or unloaded then
        return
    end

    local plot = getMyPlot()
    if not plot then
        return
    end

    local hitboxesFolder = plot:FindFirstChild('Hitboxes')
    if not hitboxesFolder then
        return
    end

    local countdownsFolder = Workspace:FindFirstChild('ScriptedMap')
    countdownsFolder = countdownsFolder
        and countdownsFolder:FindFirstChild('Countdowns')
    if not countdownsFolder then
        return
    end

    local validHitboxes = {}

    for _, hitbox in ipairs(hitboxesFolder:GetChildren()) do
        if hitbox:IsA('BasePart') then
            local uuid = hitbox.Name
            local countdown = countdownsFolder:FindFirstChild(uuid)

            if countdown then
                local gui = countdown:FindFirstChild('GUI')
                if gui then
                    validHitboxes[hitbox] = true

                    local esp = seedTimerEspCache[hitbox]
                    if not esp then
                        esp = createSeedTimerEspLabel(hitbox)
                        seedTimerEspCache[hitbox] = esp
                    end

                    if esp and esp.billboard then
                        local titleLabel = esp.titleLabel
                        local progressLabel = esp.progressLabel
                        local timeLabel = esp.timeLabel

                        -- Get title
                        local titleObj = gui:FindFirstChild('Title')
                        if titleObj and titleObj:IsA('TextLabel') then
                            titleLabel.Text = titleObj.Text or 'Plant'
                        end

                        -- Get progress
                        local progressObj = gui:FindFirstChild('Progress')
                        if progressObj and progressObj:IsA('TextLabel') then
                            progressLabel.Text = progressObj.Text or '0%'
                        end

                        -- Get time left
                        local timeLeftObj = gui:FindFirstChild('TimeLeft')
                        if timeLeftObj and timeLeftObj:IsA('TextLabel') then
                            timeLabel.Text = timeLeftObj.Text or '0s'
                        end

                        esp.billboard.Enabled = true
                    end

                    -- Show hitbox if enabled and plant is growing
                    if seedTimerHitboxEnabled then
                        -- Store original properties if not already stored
                        if not seedTimerHitboxCache[hitbox] then
                            seedTimerHitboxCache[hitbox] = {
                                originalTransparency = hitbox.Transparency,
                                originalColor = hitbox.Color,
                                originalMaterial = hitbox.Material,
                                originalCanCollide = hitbox.CanCollide,
                                originalCFrame = hitbox.CFrame,
                                offsetApplied = false,
                            }
                        end

                        local cache = seedTimerHitboxCache[hitbox]

                        -- Make hitbox very noticeable for growing plants
                        hitbox.Transparency = 0.1
                        hitbox.Color = Color3.fromRGB(255, 0, 0) -- Bright red
                        hitbox.Material = Enum.Material.Neon
                        hitbox.CanCollide = false

                        -- Fix z-fighting by slightly offsetting the position (only once)
                        if not cache.offsetApplied then
                            hitbox.CFrame = hitbox.CFrame
                                + Vector3.new(0, 0.02, 0)
                            cache.offsetApplied = true
                        end
                    end
                end
            end

            -- Reset hitbox to original state if not growing or hitbox disabled
            if
                not (countdown and countdown:FindFirstChild('GUI'))
                or not seedTimerHitboxEnabled
            then
                if seedTimerHitboxCache[hitbox] then
                    local original = seedTimerHitboxCache[hitbox]
                    hitbox.Transparency = original.originalTransparency
                    hitbox.Color = original.originalColor
                    hitbox.Material = original.originalMaterial
                    hitbox.CanCollide = original.originalCanCollide
                    hitbox.CFrame = original.originalCFrame
                    seedTimerHitboxCache[hitbox] = nil -- Clean up cache
                end
            end
        end
    end

    -- Clean up ESP for hitboxes that no longer exist or don't have countdowns
    for hitbox, esp in pairs(seedTimerEspCache) do
        if not validHitboxes[hitbox] then
            if esp.billboard and esp.billboard.Parent then
                esp.billboard:Destroy()
            end
            seedTimerEspCache[hitbox] = nil
        end
    end
end

function toggleSeedTimerEsp(on)
    seedTimerEspEnabled = on
    if on then
        if seedTimerRenderConnection then
            return
        end
        seedTimerRenderConnection =
            bind(RunService.RenderStepped:Connect(function()
                updateSeedTimerEsp()
            end))
        if espGui then
            espGui.Enabled = true
        end
    else
        if seedTimerRenderConnection then
            pcall(function()
                seedTimerRenderConnection:Disconnect()
            end)
            seedTimerRenderConnection = nil
        end
        for _, esp in pairs(seedTimerEspCache) do
            if esp.billboard and esp.billboard.Parent then
                esp.billboard:Destroy()
            end
        end
        seedTimerEspCache = {}

        -- Clean up hitbox cache and restore original properties
        for hitbox, original in pairs(seedTimerHitboxCache) do
            if hitbox and hitbox.Parent then
                hitbox.Transparency = original.originalTransparency
                hitbox.Color = original.originalColor
                hitbox.Material = original.originalMaterial
                hitbox.CanCollide = original.originalCanCollide
                hitbox.CFrame = original.originalCFrame
            end
        end
        seedTimerHitboxCache = {}
    end
end

-- =============================
-- Alerts (toasts)
-- =============================
local SOUND_IDS = {
    'rbxassetid://6026984224',
    'rbxassetid://911882310',
    'rbxassetid://160432334',
}

function playSoundUnique(suffix, volume)
    local s = SoundService:FindFirstChild(existingGuiName .. '_' .. suffix)
    if not s then
        s = Instance.new('Sound')
        s.Name = existingGuiName .. '_' .. suffix
        s.RollOffMaxDistance = 10000
        s.Parent = SoundService
    end
    s.Volume = volume
    for _, id in ipairs(SOUND_IDS) do
        s.SoundId = id
        s.TimePosition = 0
        local ok = pcall(function()
            s:Play()
        end)
        if ok then
            break
        end
    end
end

function playPing()
    if not alertSoundEnabled then
        return
    end
    playSoundUnique('AlertPing', alertVolume)
end
-- REVISED: Generic toast builder to correctly handle text wrapping and sizing
function buildToast(titleText, subText, color, parentContainer)
    if not parentContainer then
        return
    end

    local maxAllowedWidth = 700
    local minAllowedWidth = 220
    local padX = 20
    local titleFontSize, subFontSize = 18, 14
    local titleFont, subFont = Enum.Font.SourceSansBold, Enum.Font.SourceSans

    local safeTitle = tostring(titleText or '')
    local safeSub = tostring(subText or '')

    local viewW = (
        Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize.X
    ) or 1920
    local viewportMaxWidth = math.max(minAllowedWidth, math.floor(viewW - 32))
    local textMaxWidth = viewportMaxWidth - padX

    local titleMeasure = TextService:GetTextSize(
        safeTitle,
        titleFontSize,
        titleFont,
        Vector2.new(textMaxWidth, 1000)
    )
    local subMeasure = TextService:GetTextSize(
        safeSub,
        subFontSize,
        subFont,
        Vector2.new(textMaxWidth, 1000)
    )

    local desiredWidth = math.clamp(
        math.ceil(math.max(titleMeasure.X, subMeasure.X) + padX),
        minAllowedWidth,
        viewportMaxWidth
    )

    local card = New('TextButton', {
        AutoButtonColor = false,
        Text = '',
        Size = UDim2.new(0, desiredWidth, 0, 0), -- Use calculated width, auto height
        BackgroundColor3 = Color3.fromRGB(28, 30, 36),
        BackgroundTransparency = 0.10,
        ZIndex = 2000002,
        ClipsDescendants = true,
        Active = true,
        Parent = parentContainer,
        AutomaticSize = Enum.AutomaticSize.Y, -- Let the card's height be determined by its children
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 16) }),
        New(
            'UIStroke',
            { Color = Color3.fromRGB(64, 66, 74), Transparency = 0.35 }
        ),
        New('UIPadding', {
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
        }),
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local titleLabel = New('TextLabel', {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Font = titleFont,
        TextSize = titleFontSize,
        TextColor3 = color or AccentB,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Text = safeTitle,
        ZIndex = 2000003,
        Parent = card,
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    local subLabel = New('TextLabel', {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Font = subFont,
        TextSize = subFontSize,
        TextColor3 = Color3.fromRGB(210, 215, 222),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Text = safeSub,
        ZIndex = 2000003,
        Parent = card,
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    function dismissToast()
        if not card or not card.Parent then
            return
        end
        local ti =
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local shrink = TweenService:Create(card, ti, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, card.AbsoluteSize.X, 0, 0),
        })
        shrink.Completed:Connect(function()
            if card then
                card:Destroy()
            end
        end)
        shrink:Play()
    end

    card.MouseButton1Click:Connect(dismissToast)
    task.delay(3.5, dismissToast)

    local startBT = card.BackgroundTransparency
    card.BackgroundTransparency = 1
    TweenService
        :Create(card, TweenInfo.new(0.15), { BackgroundTransparency = startBT })
        :Play()
end

-- NEW: Helper to convert Color3 to a decimal number for Discord
function color3ToDecimal(color)
    if not color then
        return 0
    end
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    return r * 65536 + g * 256 + b
end

-- Universal webhook function
function sendWebhook(payload)
    if not webhookEnabled or not webhookUrl or webhookUrl == '' then
        return false
    end

    local success = false
    local data
    local ok, res = pcall(function()
        data = HttpService:JSONEncode(payload)
    end)
    if not ok then
        return false
    end

    local requestData = {
        Url = webhookUrl,
        Method = 'POST',
        Headers = { ['Content-Type'] = 'application/json' },
        Body = data,
    }

    -- Try common executor request functions first
    if not success and syn and syn.request then
        success, _ = pcall(syn.request, requestData)
    end
    if not success and http_request then
        success, _ = pcall(http_request, requestData)
    end
    if not success and request then
        success, _ = pcall(request, requestData)
    end

    -- Fallback to standard HttpService
    if not success and game:GetService('HttpService') then
        success, _ = pcall(
            HttpService.PostAsync,
            HttpService,
            webhookUrl,
            data,
            Enum.HttpContentType.ApplicationJson
        )
    end

    return success
end

-- Internal toast for UI feedback that does NOT send a webhook
function showInternalToast(titleText, subText, color)
    ensureToastsGui()
    buildToast(
        fixCorruptedText(titleText),
        fixCorruptedText(subText),
        color,
        toastContainer
    )
    playPing()
end
-- Enhanced confirmation popup with pop-in animation and click blocking
function showConfirmationPopup(title, message, onConfirm, onCancel)
    -- Create overlay to block clicks on background
    local overlay = New('TextButton', {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        Text = '', -- Empty text
        Parent = CoreGui,
        ZIndex = 10000,
        Active = true, -- Make it clickable to block background clicks
    })

    -- Create main popup container
    local popup = New('Frame', {
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, -200, 0.5, -100),
        BackgroundColor3 = Card,
        BorderSizePixel = 0,
        Parent = overlay,
        ZIndex = 10001,
        Active = false, -- Disable clicking on the popup itself
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 16) }),
        New('UIStroke', {
            Color = Stroke,
            Thickness = 2,
            Transparency = 0.3,
        }),
    })

    -- Title
    local titleLabel = New('TextLabel', {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = popup,
    })

    -- Message
    local messageLabel = New('TextLabel', {
        Size = UDim2.new(1, -20, 0, 60),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        Text = message,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        Parent = popup,
    })

    -- Button container
    local buttonContainer = New('Frame', {
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 130),
        BackgroundTransparency = 1,
        Parent = popup,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 15),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    -- Yes button
    local yesBtn = New('TextButton', {
        Size = UDim2.new(0, 120, 0, 40),
        BackgroundColor3 = Success,
        BorderSizePixel = 0,
        Text = 'Yes',
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = buttonContainer,
        LayoutOrder = 1,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        New('UIStroke', {
            Color = Success:lerp(Color3.fromRGB(255, 255, 255), 0.3),
            Thickness = 1,
            Transparency = 0.5,
        }),
    })

    -- No button
    local noBtn = New('TextButton', {
        Size = UDim2.new(0, 120, 0, 40),
        BackgroundColor3 = Danger,
        BorderSizePixel = 0,
        Text = 'No',
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = buttonContainer,
        LayoutOrder = 2,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        New('UIStroke', {
            Color = Danger:lerp(Color3.fromRGB(255, 255, 255), 0.3),
            Thickness = 1,
            Transparency = 0.5,
        }),
    })

    -- Enhanced hover effects for buttons (bigger on hover)
    local function addEnhancedHoverEffect(button, originalColor)
        local originalSize = button.Size

        button.MouseEnter:Connect(function()
            -- Bigger size increase and glow effect
            FX.CreateTween(
                button,
                TweenInfo.new(
                    0.2,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = UDim2.new(
                        originalSize.X.Scale,
                        originalSize.X.Offset + 15,
                        originalSize.Y.Scale,
                        originalSize.Y.Offset + 8
                    ),
                }
            ):Play()

            -- Add glowing stroke effect
            local stroke = button:FindFirstChild('UIStroke')
            if stroke then
                FX.CreateTween(
                    stroke,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {
                        Thickness = 3,
                        Transparency = 0.2,
                    }
                )
                    :Play()
            end
        end)

        button.MouseLeave:Connect(function()
            -- Return to original size
            FX.CreateTween(
                button,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = originalSize,
                }
            ):Play()

            -- Remove glow stroke
            local stroke = button:FindFirstChild('UIStroke')
            if stroke then
                FX.CreateTween(
                    stroke,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {
                        Thickness = 1,
                        Transparency = 0.5,
                    }
                )
                    :Play()
            end
        end)
    end

    -- Add enhanced hover effects
    addEnhancedHoverEffect(yesBtn, Success)
    addEnhancedHoverEffect(noBtn, Danger)

    -- Pop-in animation (unique "bounce and scale" effect)
    popup.Size = UDim2.new(0, 0, 0, 0)
    popup.Position = UDim2.new(0.5, 0, 0.5, 0)
    popup.BackgroundTransparency = 1

    -- Animate popup appearance
    local popInSequence = {
        -- First: Scale up with bounce
        FX.CreateTween(
            popup,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, 420, 0, 220), -- Slightly bigger than final size
                Position = UDim2.new(0.5, -210, 0.5, -110),
                BackgroundTransparency = 0.1,
            }
        ),

        -- Second: Settle to final size
        FX.CreateTween(
            popup,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, 400, 0, 200),
                Position = UDim2.new(0.5, -200, 0.5, -100),
                BackgroundTransparency = 0,
            }
        ),
    }

    -- Play pop-in animation
    popInSequence[1]:Play()
    popInSequence[1].Completed:Connect(function()
        popInSequence[2]:Play()
    end)

    -- Button click handlers
    yesBtn.MouseButton1Click:Connect(function()
        -- Pop-out animation before calling callback
        local popOutTween = FX.CreateTween(
            popup,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
            }
        )

        popOutTween:Play()
        popOutTween.Completed:Connect(function()
            overlay:Destroy()
            if onConfirm then
                onConfirm()
            end
        end)
    end)

    noBtn.MouseButton1Click:Connect(function()
        -- Pop-out animation before calling callback
        local popOutTween = FX.CreateTween(
            popup,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
            }
        )

        popOutTween:Play()
        popOutTween.Completed:Connect(function()
            overlay:Destroy()
            if onCancel then
                onCancel()
            end
        end)
    end)

    -- Block clicks on overlay (background)
    overlay.MouseButton1Click:Connect(function()
        -- Do nothing - this blocks background clicks
    end)

    -- Block clicks on popup itself (popup is a Frame, so we need to make it a TextButton or remove this)
    -- Since popup is a Frame, we'll remove this click handler as it's not needed
end

function Alerts_ShowToast(titleText, subText, color)
    ensureToastsGui()
    buildToast(
        fixCorruptedText(titleText),
        fixCorruptedText(subText),
        color,
        toastContainer
    )
    playPing()
    -- webhook for brainrot (throttled per-type)
    local now = time()
    if
        webhookEnabled
        and (
            _lastBrainrotWebhookAt == 0
            or (now - _lastBrainrotWebhookAt >= _webhookCooldown)
        )
    then
        _lastBrainrotWebhookAt = now
        task.spawn(function()
            local mentionPrefix = ''
            if webhookPingMode == 'All' or webhookPingMode == 'Brainrot' then
                mentionPrefix = '@everyone\n'
            end
            local payload = {
                content = (mentionPrefix ~= '') and mentionPrefix or nil,
                embeds = {
                    {
                        title = titleText,
                        description = subText,
                        color = color3ToDecimal(color),
                        timestamp = os.date('!%Y-%m-%dT%H:%M:%S.000Z'),
                    },
                },
            }
            sendWebhook(payload)
        end)
    end
end

-- NEW: Seed alert sound volume
function playSeedPing()
    playSoundUnique('SeedAlertPing', seedAlertVolume)
end

-- FIX: Add a batch cooldown to prevent multiple alerts in a short window
_lastSeedBatchAlertAt = 0
SEED_BATCH_COOLDOWN = 60 -- seconds

-- Brainrot alert functions

function Alerts_ShowSeedToast(titleText, subText, color, isTest)
    local now = time()
    -- Removed batch cooldown to allow simultaneous alerts with gear alerts

    ensureSeedToastsGui()
    buildToast(
        fixCorruptedText(titleText),
        fixCorruptedText(subText),
        color,
        seedToastContainer
    )
    playSeedPing()

    -- Webhook for seed alerts (per-type throttle + batch cooldown)
    if
        webhookEnabled
        and (
            _lastSeedWebhookAt == 0
            or (now - _lastSeedWebhookAt >= _webhookCooldown)
        )
    then
        _lastSeedWebhookAt = now
        task.spawn(function()
            local mentionPrefix = ''
            if webhookPingMode == 'All' or webhookPingMode == 'Seed' then
                mentionPrefix = '@everyone\n'
            end
            local payload = {
                content = (mentionPrefix ~= '') and mentionPrefix or nil,
                embeds = {
                    {
                        title = titleText,
                        description = subText,
                        color = color3ToDecimal(color),
                        timestamp = os.date('!%Y-%m-%dT%H:%M:%S.000Z'),
                    },
                },
            }
            sendWebhook(payload)
        end)
    end
end

-- Brainrot alerts source - Fixed to respect serverwide toggle
function setupBrainrotAlerts()
    -- Connect to global brainrots folder for serverwide alerts
    bind(globalBrainrotsFolder.ChildAdded:Connect(function(brainrot)
        task.spawn(function()
            if not alertEnabled then
                return
            end
            local stats = brainrot:WaitForChild('Stats', 5)
            if not stats or _alertSeen[brainrot] then
                return
            end
            _alertSeen[brainrot] = true

            if not brainrotServerwideEnabled then
                -- Only alert if this brainrot is spatially near my plot's paths AND nearest to my plot
                local rootPart = brainrot:FindFirstChild('RootPart')
                if not rootPart then
                    return
                end
                if time() - lastPlotCheck > 5 then
                    getMyPlot(true)
                    if myPlot then
                        myPlotPathNodes = getPathNodesFromPlot(myPlot)
                    end
                    lastPlotCheck = time()
                end
                if not myPlot or #myPlotPathNodes == 0 then
                    return
                end
                if
                    not isPositionNearPath(rootPart.Position, myPlotPathNodes)
                then
                    return
                end
                local nearestPlot, d1, d2 =
                    nearestPlotsByPath(rootPart.Position)
                -- Require the brainrot to be nearest to my plot; tolerate small margins
                if nearestPlot and nearestPlot ~= myPlot then
                    -- Fallback: if it's very close to my path, still allow
                    local dMy =
                        minDistToNodes(rootPart.Position, myPlotPathNodes)
                    if dMy > 35 then
                        return
                    end
                end
                -- If ambiguity is extremely high, drop (plots practically equidistant)
                if d2 and d1 and (d2 - d1) < 8 then
                    return
                end
                -- Also require Y plane similarity to my plot's path average to avoid cross-level bleed
                local myAvgY = plotPathYCache[myPlot]
                if myAvgY and math.abs(rootPart.Position.Y - myAvgY) > 18 then
                    return
                end
            end

            local rarityName = parseRarityFromStats(stats)
            local mutationName = parseMutationFromStats(stats)

            -- Use same robust HP parsing as ESP
            local hpOk, hpVal = pcall(function()
                local healthText = stats.Health.Amount.Text
                local currentHealthPart = healthText:match('([^/]+)')
                    or healthText
                local val = parseHumanNumber(currentHealthPart)
                if not val then
                    val = tonumber((currentHealthPart:gsub(',', '')))
                end
                return val
            end)
            local nameOk, nameVal = pcall(function()
                return stats.Title.Text
            end)

            local rOK = alertRaritySet[rarityName] == true
            local mOK = alertMutationSet[mutationName] == true

            local shouldAlert
            if alertMatchMode == 'Both' then
                shouldAlert = rOK and mOK
            else
                shouldAlert = rOK or mOK
            end

            if not shouldAlert then
                return
            end

            local now = time()
            if now - _lastToastAt < _toastCooldown then
                return
            end
            _lastToastAt = now

            local titleText = string.format(
                '%s • %s',
                rarityName,
                (nameOk and nameVal) or brainrot.Name
            )
            local hpText = (hpOk and hpVal and formatNumber(hpVal)) or '?'
            local subText =
                string.format('HP: %s   |   Mutation: %s', hpText, mutationName)
            local color = Rarities[rarityName] or AccentB

            Alerts_ShowToast(titleText, subText, color)
        end)
    end))
end

-- =============================
-- Brainrot Alert Variables (Global - matching existing structure)
-- =============================
-- These are already declared as globals above, but adding webhook variables
_lastBrainrotWebhookAt = 0
_lastSeedWebhookAt = 0
_lastGearWebhookAt = 0
_webhookCooldown = 1.0 -- seconds between webhook posts to avoid spamming

-- =============================
-- Brainrot ESP Logic (with filters)
-- =============================
espRenderConnection = nil
espCache = {}
globalBrainrotsFolder = Workspace:WaitForChild('ScriptedMap')
    :WaitForChild('Brainrots')
myPlotPathNodes = {}
lastPlotCheck = 0

-- selectedRarities and selectedMutations are already declared as globals above

-- Cache of path nodes per plot to determine nearest plot for a position
plotPathNodesCache, plotPathYCache, lastPlotPathsCacheAt = {}, {}, 0

function rebuildPlotPathsCache()
    plotPathNodesCache = {}
    plotPathYCache = {}
    if not plotsFolder then
        return
    end
    for _, pl in ipairs(plotsFolder:GetChildren()) do
        local nodes = getPathNodesFromPlot(pl)
        plotPathNodesCache[pl] = nodes
        local sumY, count = 0, 0
        for _, n in ipairs(nodes) do
            sumY += n.Position.Y
            count += 1
        end
        plotPathYCache[pl] = (count > 0) and (sumY / count) or nil
    end
    lastPlotPathsCacheAt = time()
end

function nearestPlotsByPath(pos)
    if (time() - lastPlotPathsCacheAt) > 5 then
        rebuildPlotPathsCache()
    end
    local bestPlot, bestDist, secondDist
    for pl, nodes in pairs(plotPathNodesCache) do
        for _, node in ipairs(nodes) do
            local d = (pos - node.Position).Magnitude
            if not bestDist or d < bestDist then
                secondDist = bestDist
                bestDist = d
                bestPlot = pl
            elseif (not secondDist) or d < secondDist then
                secondDist = d
            end
        end
    end
    return bestPlot, bestDist or math.huge, secondDist or math.huge
end

function parseRarityFromStats(stats)
    local rarityLabel = stats:FindFirstChild('Rarity')
    if rarityLabel then
        for _, child in ipairs(rarityLabel:GetChildren()) do
            if child.Name ~= 'UIStroke' then
                return child.Name
            end
        end
    end
    return 'Rare'
end

function parseMutationFromStats(stats)
    local mutationLabel = stats:FindFirstChild('Mutation')
    if mutationLabel then
        for _, child in ipairs(mutationLabel:GetChildren()) do
            if child.Name ~= 'UIStroke' then
                return child.Name
            end
        end
    end
    return 'None'
end

function createEspLabel(parent)
    local billboard = New('BillboardGui', {
        Adornee = parent,
        AlwaysOnTop = true,
        Size = UDim2.new(0, 220, 0, 70),
        StudsOffset = Vector3.new(0, 2, 0),
        Enabled = false,
        Parent = espGui,
    })
    local nameLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0.33, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Text = 'Name',
        TextColor3 = Text,
        Parent = billboard,
        ZIndex = 2,
    }, { New('UIStroke', { Color = Color3.new(0, 0, 0), Thickness = 1.5 }) })
    local healthLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0.33, 0),
        Position = UDim2.new(0, 0, 0.33, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Text = 'Health',
        TextColor3 = Text,
        Parent = billboard,
        ZIndex = 2,
    }, { New('UIStroke', { Color = Color3.new(0, 0, 0), Thickness = 1.5 }) })
    local mutationLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0.33, 0),
        Position = UDim2.new(0, 0, 0.66, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Text = 'Mutation: None',
        TextColor3 = Text,
        Parent = billboard,
        ZIndex = 2,
    }, { New('UIStroke', { Color = Color3.new(0, 0, 0), Thickness = 1.5 }) })
    return {
        billboard = billboard,
        name = nameLabel,
        health = healthLabel,
        mutation = mutationLabel,
    }
end

-- =============================
-- Brainrot Auto Hit Functions
-- =============================
function findBestBat()
    local backpack = player:FindFirstChild('Backpack')
    if not backpack then
        return nil
    end

    -- Try to find bats in reverse order (best bat first)
    for i = #autoHitBatNames, 1, -1 do
        local batName = autoHitBatNames[i]
        local bat = backpack:FindFirstChild(batName)
        if bat then
            return bat
        end
    end

    -- Check if any bat is currently equipped
    if player.Character then
        for i = #autoHitBatNames, 1, -1 do
            local batName = autoHitBatNames[i]
            local bat = player.Character:FindFirstChild(batName)
            if bat then
                return bat
            end
        end
    end

    return nil
end

function equipBat(bat)
    if not bat or not player.Character then
        return false
    end

    local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
    if not humanoid then
        return false
    end

    -- If bat is in backpack, equip it
    if bat.Parent == player.Backpack then
        pcall(function()
            humanoid:EquipTool(bat)
        end)
        task.wait(0.1)
    end

    return bat.Parent == player.Character
end

function findNearestBrainrot()
    if not globalBrainrotsFolder then
        return nil
    end

    local playerPos = player.Character
        and player.Character:FindFirstChild('HumanoidRootPart')
    if not playerPos then
        return nil
    end
    playerPos = playerPos.Position

    -- Get player's plot and path nodes (same logic as ESP)
    if time() - lastPlotCheck > 5 then
        getMyPlot(true) -- Force a rescan periodically for safety
        if myPlot then
            myPlotPathNodes = getPathNodesFromPlot(myPlot)
        end
        lastPlotCheck = time()
    end
    if not myPlot or #myPlotPathNodes == 0 then
        return nil
    end

    local nearestBrainrot = nil
    local nearestDistance = math.huge

    for _, brainrot in ipairs(globalBrainrotsFolder:GetChildren()) do
        if brainrot:IsA('Model') then
            local rootPart = brainrot:FindFirstChild('RootPart')
            local stats = brainrot:FindFirstChild('Stats')

            if rootPart and stats then
                -- Only target brainrots on the player's plot (same as ESP)
                if
                    not isPositionNearPath(rootPart.Position, myPlotPathNodes)
                then
                    continue
                end

                -- Check if brainrot is still alive
                local healthLabel = stats:FindFirstChild('Health')
                if healthLabel and healthLabel:FindFirstChild('Amount') then
                    local healthText = healthLabel.Amount.Text
                    if
                        not healthText:find('0/')
                        and not healthText:find('^0%s')
                    then
                        -- Check brainrot rarity filter for autohit
                        local rarityName = parseRarityFromStats(stats)
                        local rarityPass = selectedAutoHitRarities[rarityName]
                            == true

                        -- Check brainrot name filter for autohit
                        local namePass = true
                        if next(selectedAutoHitBrainrotNames) ~= nil then -- Only check if any names are selected
                            -- Get the display name from Stats instead of using UUID
                            local brainrotDisplayName = brainrot.Name -- fallback to UUID

                            -- Try Stats.Title first (newer brainrots)
                            local titleLabel = stats:FindFirstChild('Title')
                            if titleLabel then
                                local titleSuccess, titleResult = pcall(
                                    function()
                                        return titleLabel.Text
                                    end
                                )
                                if
                                    titleSuccess
                                    and titleResult
                                    and #tostring(titleResult) > 0
                                then
                                    brainrotDisplayName = titleResult
                                end
                            end

                            -- Try Stats.Name.Amount.Text as fallback (older brainrots)
                            if brainrotDisplayName == brainrot.Name then
                                local nameLabel = stats:FindFirstChild('Name')
                                if
                                    nameLabel
                                    and nameLabel:FindFirstChild('Amount')
                                then
                                    local nameSuccess, nameResult = pcall(
                                        function()
                                            return nameLabel.Amount.Text
                                        end
                                    )
                                    if
                                        nameSuccess
                                        and nameResult
                                        and #tostring(nameResult) > 0
                                    then
                                        brainrotDisplayName = nameResult
                                    end
                                end
                            end

                            namePass = selectedAutoHitBrainrotNames[brainrotDisplayName]
                                == true
                        end

                        if rarityPass and namePass then
                            local distance = (rootPart.Position - playerPos).Magnitude
                            if distance < nearestDistance then
                                nearestDistance = distance
                                nearestBrainrot = brainrot
                            end
                        end
                    end
                end
            end
        end
    end

    return nearestBrainrot, nearestDistance
end

function moveToBrainrot(brainrot, mode)
    if not brainrot or not player.Character then
        return false
    end

    local hrp = player.Character:FindFirstChild('HumanoidRootPart')
    local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
    if not hrp or not humanoid then
        return false
    end

    local target = brainrot:FindFirstChild('RootPart')
    if not target then
        return false
    end

    local targetPos = target.Position

    if mode == 'Teleport' then
        -- Teleport directly to the brainrot with slight offset to avoid collision
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
        return true
    elseif mode == 'Tween' then
        -- Much faster tween to the brainrot
        local distance = (hrp.Position - targetPos).Magnitude
        local tweenInfo = TweenInfo.new(
            math.max(0.05, distance / 500), -- Speed: 500 studs/second (much faster)
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        )

        local tween = TweenService:Create(hrp, tweenInfo, {
            CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0)),
        })

        tween:Play()
        tween.Completed:Wait()
        return true
    elseif mode == 'Walk' then
        -- Use Humanoid:MoveTo with continuous tracking of brainrot position
        local timeoutTime = tick() + 8 -- 8 second timeout for pathfinding

        while tick() < timeoutTime do
            if not autoHitEnabled or unloaded or autoHitStopRequested then
                return false
            end

            -- Get current brainrot position (it might have moved)
            local currentTargetPos = target.Position
            local distance = (hrp.Position - currentTargetPos).Magnitude

            if distance <= 10 then
                return true -- Close enough
            end

            -- Update movement to current position
            humanoid:MoveTo(currentTargetPos)
            task.wait(0.1) -- Check less frequently to avoid performance issues
        end

        return false -- Timeout
    end

    return false
end
function swingBat(bat)
    if not bat or not bat:IsA('Tool') then
        return
    end
    if not autoHitEnabled or unloaded or autoHitStopRequested then
        return
    end -- Check if auto hit is still enabled

    pcall(function()
        bat:Activate()
    end)
end
function trackAndHitBrainrot(brainrot, bat)
    if not brainrot or not bat or not player.Character then
        return false
    end

    local hrp = player.Character:FindFirstChild('HumanoidRootPart')
    local target = brainrot:FindFirstChild('RootPart')
    if not hrp or not target then
        return false
    end

    local targetPos = target.Position
    local startTime = tick()
    local maxHitTime = 3 -- Maximum time to spend hitting this brainrot

    -- Continuously track and hit the brainrot
    while
        autoHitEnabled
        and not unloaded
        and not autoHitStopRequested
        and tick() - startTime < maxHitTime
    do
        -- Check auto hit status immediately at start of each cycle
        if not autoHitEnabled or unloaded or autoHitStopRequested then
            return false
        end

        -- Check if brainrot is still alive
        local stats = brainrot:FindFirstChild('Stats')
        if not stats then
            return true
        end

        local healthLabel = stats:FindFirstChild('Health')
        if not healthLabel or not healthLabel:FindFirstChild('Amount') then
            return true
        end

        local healthText = healthLabel.Amount.Text
        if healthText:find('0/') or healthText:find('^0%s') then
            -- Brainrot is dead, we're done - return immediately
            return true
        end

        -- Check auto hit status before movement
        if not autoHitEnabled or unloaded or autoHitStopRequested then
            return false
        end

        -- Get current target position (brainrot might have moved)
        local currentTargetPos = target.Position

        -- Stay inside the brainrot constantly (much faster movement)
        local distance = (hrp.Position - currentTargetPos).Magnitude
        if distance > 2 then -- Much smaller distance threshold
            -- Check again before teleporting
            if not autoHitEnabled or unloaded then
                return false
            end
            -- Instant teleport to stay inside brainrot
            hrp.CFrame = CFrame.new(currentTargetPos + Vector3.new(0, 1, 0))
        end

        -- Spam swing the bat (faster) with frequent checks
        for i = 1, 3 do
            -- Check before each swing
            if not autoHitEnabled or unloaded or autoHitStopRequested then
                -- Stop swinging immediately when auto hit is turned off
                return false
            end
            swingBat(bat)
            -- Check after each swing
            if not autoHitEnabled or unloaded or autoHitStopRequested then
                return false
            end
            -- Check if brainrot died during swinging
            if
                stats
                and healthLabel
                and healthLabel:FindFirstChild('Amount')
            then
                local currentHealthText = healthLabel.Amount.Text
                if
                    currentHealthText:find('0/')
                    or currentHealthText:find('^0%s')
                then
                    -- Brainrot died while swinging, stop immediately
                    return true
                end
            end
            -- Check again before waiting
            if not autoHitEnabled or unloaded or autoHitStopRequested then
                return false
            end
            task.wait(0.01) -- Even faster swinging with shorter wait
        end

        -- Check before waiting
        if not autoHitEnabled or unloaded or autoHitStopRequested then
            return false
        end
        task.wait(0.02) -- Even smaller delay between cycles
    end

    return true
end

function autoHitLoop()
    while autoHitEnabled and not unloaded and not autoHitStopRequested do
        -- Check status immediately at start of each cycle
        if not autoHitEnabled or unloaded or autoHitStopRequested then
            return
        end

        local shouldContinue = false

        -- Find the best bat
        local bat = findBestBat()
        if not bat then
            -- Check before waiting
            if not autoHitEnabled or unloaded then
                return
            end
            task.wait(0.5) -- Reduced wait time
            shouldContinue = true
        end

        -- Check before equipping bat
        if
            not shouldContinue
            and (not autoHitEnabled or unloaded or autoHitStopRequested)
        then
            return
        end

        if not shouldContinue then
            -- Equip the bat
            if not equipBat(bat) then
                -- Check before waiting
                if not autoHitEnabled or unloaded or autoHitStopRequested then
                    return
                end
                task.wait(0.2) -- Reduced wait time
                shouldContinue = true
            end
        end

        -- Check before finding brainrot
        if
            not shouldContinue
            and (not autoHitEnabled or unloaded or autoHitStopRequested)
        then
            return
        end

        if not shouldContinue then
            -- Find the nearest brainrot
            local brainrot, distance = findNearestBrainrot()
            if not brainrot then
                -- Check before waiting
                if not autoHitEnabled or unloaded or autoHitStopRequested then
                    return
                end
                task.wait(0.2) -- Reduced wait time
                shouldContinue = true
            else
                -- Check before moving
                if not autoHitEnabled or unloaded or autoHitStopRequested then
                    return
                end
                -- Move to the brainrot quickly
                if not moveToBrainrot(brainrot, autoHitMovementMode) then
                    -- Check before waiting
                    if not autoHitEnabled or unloaded then
                        return
                    end
                    task.wait(0.1) -- Very short wait
                    shouldContinue = true
                else
                    -- Check before hitting
                    if
                        not autoHitEnabled
                        or unloaded
                        or autoHitStopRequested
                    then
                        return
                    end
                    -- Use the new tracking system for continuous hitting
                    local hitResult = trackAndHitBrainrot(brainrot, bat)
                    -- If hitting completed (brainrot died or auto hit turned off), continue to next cycle
                    if hitResult then
                        shouldContinue = true
                    end
                end
            end
        end

        if not shouldContinue then
            -- Check before waiting
            if not autoHitEnabled or unloaded then
                return
            end
            task.wait(0.1) -- Much shorter delay between cycles
        end
    end
end

function toggleAutoHit(on)
    autoHitEnabled = (on == true)

    -- Set immediate stop flag
    if not autoHitEnabled then
        autoHitStopRequested = true
    else
        autoHitStopRequested = false
    end

    -- Immediately cancel any running thread
    if autoHitThread then
        task.cancel(autoHitThread)
        autoHitThread = nil
    end

    if autoHitEnabled then
        autoHitThread = task.spawn(autoHitLoop)
    end
end

-- =============================
-- Auto Complete Event Functions
-- =============================
function getEventRewardsPart()
    local scriptedMap = game:GetService('Workspace').ScriptedMap
    if scriptedMap then
        local event = scriptedMap:FindFirstChild('Event')
        if event then
            local eventRewards = event:FindFirstChild('EventRewards')
            if eventRewards then
                return eventRewards:FindFirstChild('TalkPart')
            end
        end
    end
    return nil
end

function getEventDisplay()
    local scriptedMap = game:GetService('Workspace').ScriptedMap
    if scriptedMap then
        local event = scriptedMap:FindFirstChild('Event')
        if event then
            local tomadeFloor = event:FindFirstChild('TomadeFloor')
            if tomadeFloor then
                local guiAttachment =
                    tomadeFloor:FindFirstChild('GuiAttachment')
                if guiAttachment then
                    local billboard = guiAttachment:FindFirstChild('Billboard')
                    if billboard then
                        return billboard:FindFirstChild('Display')
                    end
                end
            end
        end
    end
    return nil
end

function checkEventDisplayText()
    local display = getEventDisplay()
    if display and display:IsA('TextLabel') then
        return display.Text
    end
    return nil
end

function activateProximityPrompt()
    local talkPart = getEventRewardsPart()
    if talkPart then
        local proximityPrompt =
            talkPart:FindFirstChildOfClass('ProximityPrompt')
        if proximityPrompt and proximityPrompt.Enabled then
            -- Try multiple methods to activate the proximity prompt
            local success = false

            -- Method 1: Try triggering the proximity prompt directly
            pcall(function()
                proximityPrompt.Triggered:Fire()
                success = true
            end)

            -- Method 2: If that doesn't work, try InputHoldBegin/End
            if not success then
                pcall(function()
                    proximityPrompt:InputHoldBegin()
                    task.wait(0.1)
                    proximityPrompt:InputHoldEnd()
                    success = true
                end)
            end

            return success
        end
    end
    return false
end

function isProximityPromptReady()
    local talkPart = getEventRewardsPart()
    if talkPart then
        local proximityPrompt =
            talkPart:FindFirstChildOfClass('ProximityPrompt')
        if proximityPrompt and proximityPrompt.Enabled then
            return true
        end
    end
    return false
end

function teleportToTomade()
    local scriptedMap = game:GetService('Workspace').ScriptedMap
    if scriptedMap then
        local event = scriptedMap:FindFirstChild('Event')
        if event then
            local tomadeFloor = event:FindFirstChild('TomadeFloor')
            if tomadeFloor then
                local player = game.Players.LocalPlayer
                if
                    player.Character
                    and player.Character:FindFirstChild('HumanoidRootPart')
                then
                    player.Character.HumanoidRootPart.CFrame = tomadeFloor.CFrame
                        + Vector3.new(0, 5, 0)
                    return true
                end
            end
        end
    end
    return false
end

-- Function to check if brainrot exists in the VisualFolder
function hasBrainrotInVisualFolder()
    local scriptedMap = game:GetService('Workspace').ScriptedMap
    if scriptedMap then
        local event = scriptedMap:FindFirstChild('Event')
        if event then
            local hitListVisualizer = event:FindFirstChild('HitListVisualizer')
            if hitListVisualizer then
                local visualFolder =
                    hitListVisualizer:FindFirstChild('VisualFolder')
                if visualFolder then
                    -- Check if there are any children (brainrot models) in the VisualFolder
                    local children = visualFolder:GetChildren()
                    return #children > 0
                end
            end
        end
    end
    return false
end

-- Function to wait for brainrot or talk to guy if none appears
function waitForBrainrotOrTalk()
    local waitTime = 0
    local maxWaitTime = 5 -- 5 seconds

    while waitTime < maxWaitTime do
        if hasBrainrotInVisualFolder() then
            print('Brainrot found in VisualFolder - proceeding normally')
            return true
        end

        task.wait(0.1)
        waitTime = waitTime + 0.1
    end

    -- No brainrot appeared, need to talk to the guy
    print('No brainrot found after 5 seconds - talking to guy')
    if teleportToTomade() then
        task.wait(1) -- Wait longer for teleport to complete

        -- Try to activate the proximity prompt with more attempts and longer waits
        local attempts = 0
        local maxAttempts = 20 -- Try for up to 2 seconds
        local talked = false

        while attempts < maxAttempts and not talked do
            if activateProximityPrompt() then
                print('Successfully talked to guy')
                talked = true
                break
            end
            task.wait(0.1)
            attempts = attempts + 1
        end

        if not talked then
            print('Failed to talk to guy after ' .. maxAttempts .. ' attempts')
        end

        -- Wait longer for brainrot to appear after talking
        task.wait(2)
    else
        print('Failed to teleport to Tomade')
    end

    return hasBrainrotInVisualFolder()
end

function autoCompleteEventLoop()
    local lastText = ''
    local hasClaimed = false
    while autoCompleteEventEnabled and not unloaded do
        local displayText = checkEventDisplayText()
        if displayText and displayText ~= '' then
            -- Check if text is "Claim" (either on transition or already there)
            if
                displayText == 'Claim'
                and (
                    lastText == 'Tomade Torelli'
                    or lastText == ''
                    or not hasClaimed
                )
            then
                -- First, check if we have brainrot or need to talk to the guy
                if not hasBrainrotInVisualFolder() then
                    print('No brainrot found - talking to guy first')
                    -- Talk to the guy first, then continue with claim loop
                    waitForBrainrotOrTalk()
                    -- After talking, continue to the claim process below
                else
                    print('Brainrot already exists - proceeding with claim')
                end

                -- Now do the claim process (either after talking to guy or if brainrot already exists)
                if teleportToTomade() then
                    task.wait(0.5) -- Brief wait for teleport

                    -- Continuously try to activate the proximity prompt until claim text changes
                    while displayText == 'Claim' do
                        -- Try to activate the proximity prompt regardless of ready state
                        if activateProximityPrompt() then
                            hasClaimed = true
                        end
                        task.wait(0.1) -- Check every 100ms
                        -- Re-check the text in case it changed
                        displayText = checkEventDisplayText()
                        if displayText and displayText ~= 'Claim' then
                            break
                        end
                    end

                    task.wait(1) -- Wait after claiming to avoid spam

                    -- Try to click replay button immediately after claim process
                    pcall(attemptReplayClick)
                end
            end

            -- Reset hasClaimed flag when text changes away from "Claim"
            if displayText ~= 'Claim' then
                hasClaimed = false
            end

            lastText = displayText
        end

        -- Check more frequently for instant response
        task.wait(0.1) -- Check every 100ms for instant detection
    end
end

-- =============================
-- Auto Replay Button Functions
-- =============================

local function findReplayTextLabel(timeout)
    timeout = timeout or 2
    local t0 = time()
    while time() - t0 < timeout do
        if unloaded then
            return nil
        end

        local ok, textLabel = pcall(function()
            local Players = game:GetService('Players')
            local lp = Players.LocalPlayer
            if not lp or not lp.PlayerGui then
                return nil
            end
            local pg = lp.PlayerGui

            local sg = pg:FindFirstChild('SurfaceGui')
            if not (sg and sg.Enabled) then
                return nil
            end

            local rf = sg:FindFirstChild('ReplayFrame')
            local r = rf and rf:FindFirstChild('Replay')
            local tl = r and r:FindFirstChild('TextLabel')

            if tl and tl:IsA('TextLabel') and tl.Visible then
                -- verify visible ancestors
                local p = tl.Parent
                while p and p ~= pg do
                    if p:IsA('GuiObject') and p.Visible == false then
                        return nil
                    end
                    p = p.Parent
                end
                return tl
            end
            return nil
        end)

        if ok and textLabel then
            return textLabel
        end
        task.wait(0.05)
    end
    return nil
end

local function findReplayButton(timeout)
    timeout = timeout or 2
    local t0 = time()
    while time() - t0 < timeout do
        if unloaded then
            return nil
        end

        local ok, btn = pcall(function()
            local Players = game:GetService('Players')
            local lp = Players.LocalPlayer
            if not lp or not lp.PlayerGui then
                return nil
            end
            local pg = lp.PlayerGui

            local sg = pg:FindFirstChild('SurfaceGui')
            if not (sg and sg.Enabled) then
                return nil
            end

            local rf = sg:FindFirstChild('ReplayFrame')
            local r = rf and rf:FindFirstChild('Replay')
            -- Handle TextButton or ImageButton
            local tb = r
                and (
                    r:FindFirstChild('TextButton')
                    or r:FindFirstChildWhichIsA('GuiButton')
                )
            if
                tb
                and (tb:IsA('TextButton') or tb:IsA('ImageButton'))
                and tb.Visible
                and tb.Active
            then
                -- verify visible ancestors
                local p = tb.Parent
                while p and p ~= pg do
                    if p:IsA('GuiObject') and p.Visible == false then
                        return nil
                    end
                    p = p.Parent
                end
                return tb
            end
            return nil
        end)

        if ok and btn then
            return btn
        end
        task.wait(0.05)
    end
    return nil
end

-- Low-level: virtual click using getconnections hook method
local function virtualClickGui(btn, dx, dy)
    if not btn or not btn.Parent then
        return false
    end

    -- Try getconnections hook first
    if getconnections then
        local triggered = false
        for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
            pcall(function()
                conn.Function()
                triggered = true
            end)
        end
        for _, conn in ipairs(getconnections(btn.Activated)) do
            pcall(function()
                conn.Function()
                triggered = true
            end)
        end
        if triggered then
            return true
        end
    end

    -- Fallback: Activate()
    local okActivate = pcall(function()
        if btn.Activate then
            btn:Activate()
        end
    end)
    if okActivate then
        return true
    end

    -- Fallback: Fire MouseButton1Click
    local okClick = pcall(function()
        if btn.MouseButton1Click then
            btn.MouseButton1Click:Fire()
        end
    end)
    if okClick then
        return true
    end

    -- Fallback: Fire Activated
    local okActivated = pcall(function()
        if btn.Activated then
            btn.Activated:Fire()
        end
    end)
    if okActivated then
        return true
    end

    -- Final fallback: VirtualInputManager
    local ok, VIM = pcall(game.GetService, game, 'VirtualInputManager')
    if not ok or not VIM then
        return false
    end

    local camera = workspace.CurrentCamera
    local surfaceGui = btn:FindFirstAncestorWhichIsA('SurfaceGui')
    if not surfaceGui or not surfaceGui.Adornee then
        return false
    end

    local adornee = surfaceGui.Adornee
    local canvasSize = surfaceGui.CanvasSize
    local buttonPos = btn.AbsolutePosition
    local buttonSize = btn.AbsoluteSize

    local normalizedX = buttonPos.X / canvasSize.X
    local normalizedY = buttonPos.Y / canvasSize.Y

    local adorneeSize = adornee.Size
    local offsetX = (normalizedX - 0.5) * adorneeSize.X
    local offsetY = (normalizedY - 0.5) * adorneeSize.Y

    local worldPos = adornee.CFrame * CFrame.new(offsetX, offsetY, 0)
    local screenPos, onScreen = camera:WorldToViewportPoint(worldPos.Position)

    if onScreen then
        VIM:SendMouseButtonEvent(screenPos.X, screenPos.Y, true, true, game, 0)
        VIM:SendMouseButtonEvent(screenPos.X, screenPos.Y, true, false, game, 0)
        return true
    else
        return false
    end
end
-- Simple replay button click attempt every 1 second
local lastReplayAttempt = 0
local replayAttemptInterval = 1.0 -- Try every 1 second
local function attemptReplayClick()
    if unloaded then
        return false
    end

    local now = time()
    if now - lastReplayAttempt < replayAttemptInterval then
        return false
    end

    lastReplayAttempt = now

    local btn = findReplayButton(0.5) -- Quick lookup
    if not btn then
        return false
    end

    -- Try to click the button using getconnections hook
    return virtualClickGui(btn)
end

-- Public function to manually check button coordinates (call this anytime)
function debugReplayButtonCoords()
    printButtonCoordinates()
end

-- Function to test different coordinate offsets and find what works
function testReplayButtonClick()
    local btn = findReplayButton(1)
    if not btn then
        print('TEST: Button not found')
        return
    end

    local pos = btn.AbsolutePosition
    local size = btn.AbsoluteSize
    local centerX = pos.X + math.floor(size.X / 2)
    local centerY = pos.Y + math.floor(size.Y / 2)

    print('=== TESTING DIFFERENT COORDINATES ===')
    print('Button center: (' .. centerX .. ', ' .. centerY .. ')')

    -- Test different coordinate variations
    local testCoords = {
        { centerX, centerY, 'Center' },
        { pos.X, pos.Y, 'Top-left' },
        { pos.X + size.X, pos.Y, 'Top-right' },
        { pos.X, pos.Y + size.Y, 'Bottom-left' },
        { pos.X + size.X, pos.Y + size.Y, 'Bottom-right' },
        { centerX, pos.Y, 'Top-center' },
        { centerX, pos.Y + size.Y, 'Bottom-center' },
        { pos.X, centerY, 'Left-center' },
        { pos.X + size.X, centerY, 'Right-center' },
        { centerX - 10, centerY, 'Center-left-10' },
        { centerX + 10, centerY, 'Center-right+10' },
        { centerX, centerY - 10, 'Center-up-10' },
        { centerX, centerY + 10, 'Center-down+10' },
    }

    for i, coord in ipairs(testCoords) do
        print(
            'Test '
                .. i
                .. ': '
                .. coord[3]
                .. ' = ('
                .. coord[1]
                .. ', '
                .. coord[2]
                .. ')'
        )
        -- You can manually test these coordinates
    end

    print('Try clicking manually at these coordinates to see which one works!')
    print('=============================================')
end
-- Public wrapper: retries + cooldown + unload guard
local lastReplayClickAt = 0
function safeClickReplayButton()
    if unloaded then
        return false
    end
    if time() - lastReplayClickAt < 0.8 then
        return false
    end

    local btn = findReplayButton(2)
    if not btn then
        return false
    end

    for attempt = 1, 3 do
        if unloaded then
            return false
        end
        local ok = virtualClickGui(btn)
        if ok then
            lastReplayClickAt = time()
            return true
        end
        task.wait(0.2)
    end
    return false
end

function toggleAutoCompleteEvent(on)
    autoCompleteEventEnabled = (on == true)

    -- Cancel any running threads
    if autoCompleteEventThread then
        task.cancel(autoCompleteEventThread)
        autoCompleteEventThread = nil
    end
    if replayMonitorThread then
        task.cancel(replayMonitorThread)
        replayMonitorThread = nil
    end

    if autoCompleteEventEnabled then
        -- Show toast and update UI instantly
        showInternalToast(
            'Auto Complete Event',
            'Auto Complete Event enabled',
            Success
        )

        -- Do heavy initialization in background
        task.spawn(function()
            -- Initialize event parts
            eventRewardsPart = getEventRewardsPart()
            eventDisplay = getEventDisplay()

            if eventRewardsPart and eventDisplay then
                -- Initial check: if no brainrot exists, talk to the guy first
                if not hasBrainrotInVisualFolder() then
                    print(
                        'Initial check: No brainrot found - talking to guy first'
                    )
                    waitForBrainrotOrTalk()
                else
                    print(
                        'Initial check: Brainrot already exists - ready to go'
                    )
                end

                autoCompleteEventThread = task.spawn(autoCompleteEventLoop)

                -- Start independent replay monitoring thread
                replayMonitorThread = task.spawn(function()
                    while autoCompleteEventEnabled and not unloaded do
                        pcall(attemptReplayClick)
                        task.wait(1) -- Wait 1 second between attempts
                    end
                end)
            else
                autoCompleteEventEnabled = false
                showInternalToast(
                    'Auto Complete Event',
                    'Event parts not found',
                    Error
                )
            end
        end)
    else
        showInternalToast(
            'Auto Complete Event',
            'Auto Complete Event disabled',
            Muted
        )
    end
end

-- =============================
-- Auto Rebirth Functions
-- =============================

-- Helper function to get keys from a table
function getKeys(t)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(keys, tostring(k))
    end
    return keys
end

-- Function to get rebirth requirements from the GUI
function getRebirthRequirements()
    local player = game.Players.LocalPlayer
    local playerGui = player:FindFirstChild('PlayerGui')
    if not playerGui then
        return {}
    end

    local mainGui = playerGui:FindFirstChild('Main')
    if not mainGui then
        return {}
    end

    local rebirthGui = mainGui:FindFirstChild('Rebirth')
    if not rebirthGui then
        return {}
    end

    local frame = rebirthGui:FindFirstChild('Frame')
    if not frame then
        return {}
    end

    local requirements = frame:FindFirstChild('Requirements')
    if not requirements then
        return {}
    end

    local required = requirements:FindFirstChild('Required')
    if not required then
        return {}
    end

    -- Get all frame children (these are the brainrot requirement frames)
    local requiredBrainrots = {}
    for _, child in pairs(required:GetChildren()) do
        if child:IsA('Frame') then
            table.insert(requiredBrainrots, child.Name)
        end
    end

    return requiredBrainrots
end

-- Function to get raw brainrot name from backpack item (removes mutations/weights)
function getRawBrainrotName(item)
    if not item then
        return nil
    end

    -- Look for BrainrotToolUI.Title in the item
    local brainrotToolUI = item:FindFirstChild('BrainrotToolUI')
    if brainrotToolUI then
        local title = brainrotToolUI:FindFirstChild('Title')
        if title and title.Text then
            return title.Text
        end
    end

    -- Fallback: try to extract from item name by removing weight brackets
    local itemName = item.Name
    -- Remove weight brackets like [12.1 kg] from the beginning
    local rawName = itemName:gsub('^%[.*%]%s*', '')
    return rawName
end

-- Function to get all brainrots in player's backpack
function getBackpackBrainrots()
    local player = game.Players.LocalPlayer
    local backpack = player:FindFirstChild('Backpack')
    if not backpack then
        return {}
    end

    local brainrots = {}
    for _, item in pairs(backpack:GetChildren()) do
        -- Check if item has a nested brainrot structure
        -- Structure: Backpack["[17.6 kg] Bombardiro Crocodilo"]["Bombardiro Crocodilo"].Hitbox.BrainrotToolUI.Title
        -- Also checks: RootPart, HumanoidRootPart, and direct on subItem
        for _, subItem in pairs(item:GetChildren()) do
            -- Look for BrainrotToolUI in Hitbox, RootPart, HumanoidRootPart, and direct
            local brainrotToolUI = nil

            -- Check Hitbox first
            local hitbox = subItem:FindFirstChild('Hitbox')
            if hitbox then
                brainrotToolUI = hitbox:FindFirstChild('BrainrotToolUI')
            end

            -- If not found in Hitbox, check RootPart
            if not brainrotToolUI then
                local rootPart = subItem:FindFirstChild('RootPart')
                if rootPart then
                    brainrotToolUI = rootPart:FindFirstChild('BrainrotToolUI')
                end
            end

            -- If still not found, check HumanoidRootPart
            if not brainrotToolUI then
                local humanoidRootPart =
                    subItem:FindFirstChild('HumanoidRootPart')
                if humanoidRootPart then
                    brainrotToolUI =
                        humanoidRootPart:FindFirstChild('BrainrotToolUI')
                end
            end

            -- Process the BrainrotToolUI if found
            if brainrotToolUI then
                local title = brainrotToolUI:FindFirstChild('Title')
                if title and title.Text and title.Text ~= '' then
                    local brainrotName = title.Text
                    brainrots[brainrotName] = true
                end
            end

            -- Also check if BrainrotToolUI is directly in subItem (fallback)
            if not brainrotToolUI then
                brainrotToolUI = subItem:FindFirstChild('BrainrotToolUI')
                if brainrotToolUI then
                    local title = brainrotToolUI:FindFirstChild('Title')
                    if title and title.Text then
                        local brainrotName = title.Text
                        brainrots[brainrotName] = true
                    end
                end
            end
        end
    end

    return brainrots
end

-- Function to check if player has enough money for rebirth
function hasEnoughMoneyForRebirth()
    local player = game.Players.LocalPlayer
    local playerGui = player:FindFirstChild('PlayerGui')
    if not playerGui then
        return false
    end

    local mainGui = playerGui:FindFirstChild('Main')
    if not mainGui then
        return false
    end

    local rebirthGui = mainGui:FindFirstChild('Rebirth')
    if not rebirthGui then
        return false
    end

    local frame = rebirthGui:FindFirstChild('Frame')
    if not frame then
        return false
    end

    local progress = frame:FindFirstChild('Progress')
    if not progress then
        return false
    end

    local amount = progress:FindFirstChild('Amount')
    if not amount or not amount.Text then
        return false
    end

    -- Parse the amount text like "$34.43k / $100m"
    local amountText = amount.Text
    local currentMoney, requiredMoney =
        amountText:match('$([%d,%.]+%a*) / $([%d,%.]+%a*)')

    if not currentMoney or not requiredMoney then
        return false
    end

    -- Convert to numbers (handle k, m suffixes)
    local function parseMoney(str)
        str = str:gsub(',', '') -- Remove commas
        local num = tonumber(str:match('([%d%.]+)'))
        local suffix = str:match('([%a]+)$')

        if suffix == 'k' then
            return num * 1000
        elseif suffix == 'm' then
            return num * 1000000
        elseif suffix == 'b' then
            return num * 1000000000
        else
            return num or 0
        end
    end

    local current = parseMoney(currentMoney)
    local required = parseMoney(requiredMoney)

    return current >= required
end

-- Function to attempt rebirth
function attemptRebirth()
    local replicatedStorage = game:GetService('ReplicatedStorage')
    local remotes = replicatedStorage:FindFirstChild('Remotes')
    if not remotes then
        return false
    end

    local rebirthRemote = remotes:FindFirstChild('Rebirth')
    if not rebirthRemote then
        return false
    end

    -- Fire the rebirth remote
    local success, result = pcall(function()
        if rebirthRemote:IsA('RemoteEvent') then
            rebirthRemote:FireServer()
            return true
        elseif rebirthRemote:IsA('RemoteFunction') then
            rebirthRemote:InvokeServer()
            return true
        end
        return false
    end)

    return success and result
end

-- Main auto rebirth loop
function autoRebirthLoop()
    while autoRebirthEnabled and not unloaded do
        -- Check if requirements are met
        local requirements = getRebirthRequirements()
        local backpackBrainrots = getBackpackBrainrots()

        -- Check if we have all required brainrots
        local hasAllBrainrots = true
        for _, requiredBrainrot in ipairs(requirements) do
            if not backpackBrainrots[requiredBrainrot] then
                hasAllBrainrots = false
                break
            end
        end

        -- Check if we have enough money
        local hasEnoughMoney = hasEnoughMoneyForRebirth()

        -- If both conditions are met, attempt rebirth
        if hasAllBrainrots and hasEnoughMoney and #requirements > 0 then
            if attemptRebirth() then
                showInternalToast(
                    'Auto Rebirth',
                    'Rebirth successful!',
                    Success
                )
            end
        end

        -- Wait before checking again
        task.wait(5) -- Check every 5 seconds
    end
end

-- Function to toggle auto rebirth
function toggleAutoRebirth(on)
    autoRebirthEnabled = (on == true)

    -- Cancel any running thread
    if autoRebirthThread then
        task.cancel(autoRebirthThread)
        autoRebirthThread = nil
    end

    if autoRebirthEnabled then
        autoRebirthThread = task.spawn(autoRebirthLoop)
        showInternalToast(
            'Auto Rebirth',
            'Enable auto collect, or auto equip best for the best experience',
            Success
        )
    else
        showInternalToast('Auto Rebirth', 'Auto Rebirth disabled', Muted)
    end
end

-- =============================
-- Auto Favourite Functions
-- =============================

-- Name normalization for auto favourite
local function normalizeName(str)
    if type(str) ~= 'string' then
        return ''
    end
    str = str:gsub('\r\n', ' '):gsub('\n', ' '):gsub('\t', ' ')
    str = str:gsub('%s+', ' ')
    str = str:gsub('^%s+', ''):gsub('%s+$', '')
    return str
end

local function namesMatch(a, b)
    a, b = normalizeName(a), normalizeName(b)
    if a == b then
        return true
    end
    if a:find(b, 1, true) or b:find(a, 1, true) then
        return true
    end
    return false
end

-- Find BrainrotToolUI location
local function findBrainrotUI(host)
    if not host then
        return nil, nil
    end
    local hitbox = host:FindFirstChild('Hitbox')
    if hitbox then
        local ui = hitbox:FindFirstChild('BrainrotToolUI')
        if ui then
            return ui, 'Hitbox'
        end
    end
    local rootPart = host:FindFirstChild('RootPart')
    if rootPart then
        local ui = rootPart:FindFirstChild('BrainrotToolUI')
        if ui then
            return ui, 'RootPart'
        end
    end
    local hrp = host:FindFirstChild('HumanoidRootPart')
    if hrp then
        local ui = hrp:FindFirstChild('BrainrotToolUI')
        if ui then
            return ui, 'HumanoidRootPart'
        end
    end
    local ui = host:FindFirstChild('BrainrotToolUI')
    if ui then
        return ui, 'Direct'
    end
    return nil, nil
end

-- Parse rarity from BrainrotToolUI
local function parseBrainrotRarity(item)
    local ui = item:FindFirstChild('BrainrotToolUI', true)
    if not ui then
        return 'Common'
    end

    local rarityObj = ui:FindFirstChild('Rarity')
    if not rarityObj then
        return 'Common'
    end

    if rarityObj:IsA('TextLabel') or rarityObj:IsA('TextButton') then
        return (rarityObj.Text and rarityObj.Text ~= '') and rarityObj.Text
            or 'Common'
    else
        for _, child in ipairs(rarityObj:GetChildren()) do
            if
                (child:IsA('TextLabel') or child:IsA('TextButton'))
                and child.Text ~= ''
            then
                return child.Text
            elseif child.Name ~= 'UIStroke' then
                return child.Name
            end
        end
    end

    return 'Common'
end

-- Parse display name from BrainrotToolUI
local function parseBrainrotName(item)
    local ui = select(1, findBrainrotUI(item))
    if ui then
        local title = ui:FindFirstChild('Title')
        if title and title.Text and title.Text ~= '' then
            return normalizeName(title.Text)
        end
    end
    return normalizeName(item.Name:gsub('^%[.*%]%s*', ''))
end

-- Parse mutation from BrainrotToolUI
local function parseBrainrotMutation(item)
    local ui = item:FindFirstChild('BrainrotToolUI', true)
    if not ui then
        return 'None'
    end

    local mutationObj = ui:FindFirstChild('Mutation')
    if not mutationObj then
        return 'None'
    end

    -- Check if it's a text object
    if mutationObj:IsA('TextLabel') or mutationObj:IsA('TextButton') then
        local text = mutationObj.Text or ''
        return text ~= '' and text or 'None'
    else
        -- Check children for text or use child name
        for _, child in ipairs(mutationObj:GetChildren()) do
            if
                (child:IsA('TextLabel') or child:IsA('TextButton'))
                and child.Text ~= ''
            then
                return child.Text
            elseif child.Name ~= 'UIStroke' then
                return child.Name
            end
        end
    end

    return 'None'
end

-- Check if looks like UUID
local function looksLikeUUID(str)
    return type(str) == 'string'
        and str:match('^[0-9a-fA-F%-]+$')
        and #str >= 32
        and #str <= 64
end

-- UUID field candidates
local UUID_FIELD_CANDIDATES = {
    'ItemId',
    'UUID',
    'Guid',
    'GUID',
    'Uid',
    'ID',
    'Id',
    'ItemUUID',
    'ItemGUID',
    'ItemID',
}

local function tryUUIDFieldsOn(obj)
    if not obj then
        return nil
    end
    for _, field in ipairs(UUID_FIELD_CANDIDATES) do
        local val = obj:GetAttribute(field)
        if looksLikeUUID(val) then
            return val
        end
    end
    for _, field in ipairs(UUID_FIELD_CANDIDATES) do
        local sv = obj:FindFirstChild(field)
        if sv and sv:IsA('StringValue') and looksLikeUUID(sv.Value) then
            return sv.Value
        end
    end
    return nil
end

local function findItemUUIDDual(brainrotItem, wrapper)
    local uuid = tryUUIDFieldsOn(wrapper)
    if uuid then
        return uuid
    end
    uuid = tryUUIDFieldsOn(brainrotItem)
    if uuid then
        return uuid
    end
    if wrapper then
        for _, sib in ipairs(wrapper:GetChildren()) do
            if sib ~= brainrotItem then
                uuid = tryUUIDFieldsOn(sib)
                if uuid then
                    return uuid
                end
            end
        end
        local count = 0
        for _, d in ipairs(wrapper:GetDescendants()) do
            uuid = tryUUIDFieldsOn(d)
            if uuid then
                return uuid
            end
            count += 1
            if count > 400 then
                break
            end
        end
    end
    if brainrotItem then
        local count2 = 0
        for _, d in ipairs(brainrotItem:GetDescendants()) do
            uuid = tryUUIDFieldsOn(d)
            if uuid then
                return uuid
            end
            count2 += 1
            if count2 > 400 then
                break
            end
        end
    end
    return nil
end

-- Build wrapper index
local function buildWrapperIndex()
    local index = {}
    local function scan(container)
        if not container then
            return
        end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA('Model') then
                index[normalizeName(child.Name)] = child
            else
                local ui = child:FindFirstChild('BrainrotToolUI', true)
                if ui then
                    index[normalizeName(child.Name)] = child
                end
            end
        end
    end
    scan(player:FindFirstChild('Backpack'))
    if player.Character then
        scan(player.Character)
    end
    return index
end

-- Wait for inventory grid
local function waitForGrid(timeout)
    local pg = player:FindFirstChild('PlayerGui')
        or player:WaitForChild('PlayerGui', 5)
    local deadline = tick() + (timeout or 5)
    while tick() < deadline do
        local ok, grid = pcall(function()
            return pg.BackpackGui.Backpack.Inventory.ScrollingFrame.UIGridFrame
        end)
        if ok and grid then
            return grid
        end
        task.wait(0.1)
    end
    return nil
end

-- Read slot favourite state
local function readSlotFavorite(slot)
    local heart = slot:FindFirstChild('HeartIcon')
    return heart and heart.Visible or false, heart and heart.Image or nil
end

-- Correlate UI slots to items
local function correlateSlotsToItems()
    local grid = waitForGrid(5)
    local wrappers = buildWrapperIndex()
    local rows = {}

    if not grid then
        return rows
    end

    for _, slot in ipairs(grid:GetChildren()) do
        local toolName = slot:FindFirstChild('ToolName')
        if toolName and toolName:IsA('TextLabel') then
            local uiName = normalizeName(toolName.Text)
            local fav, img = readSlotFavorite(slot)

            local wrapper = wrappers[uiName]
            if not wrapper then
                for wname, w in pairs(wrappers) do
                    if namesMatch(wname, uiName) then
                        wrapper = w
                        break
                    end
                end
            end

            local uuid, rarity, name, mutation =
                nil, '<Unknown>', '<Unknown>', 'None'
            if wrapper then
                local brainrotItem = nil
                for _, child in ipairs(wrapper:GetChildren()) do
                    local ui = child:FindFirstChild('BrainrotToolUI')
                        or wrapper:FindFirstChild('BrainrotToolUI')
                    if ui then
                        brainrotItem = child
                        break
                    end
                end
                brainrotItem = brainrotItem or wrapper
                uuid = findItemUUIDDual(brainrotItem, wrapper)
                rarity = parseBrainrotRarity(brainrotItem)
                name = parseBrainrotName(brainrotItem)
                mutation = parseBrainrotMutation(brainrotItem)
            end

            table.insert(rows, {
                slot = slot.Name,
                uiName = uiName,
                favorite = fav,
                image = img,
                uuid = uuid,
                rarity = rarity,
                name = name,
                mutation = mutation,
                wrapper = wrapper,
            })
        end
    end

    return rows
end

-- Fire favourite remote
local function fireFavorite(uuid, name)
    local remotes = ReplicatedStorage:FindFirstChild('Remotes')
    if not remotes then
        return false
    end
    local favoriteItemRemote = remotes:FindFirstChild('FavoriteItem')
    if not favoriteItemRemote then
        return false
    end
    if not looksLikeUUID(uuid) then
        return false
    end
    local ok, err = pcall(function()
        favoriteItemRemote:FireServer(uuid)
    end)
    return ok
end

-- Auto favourite by rarities and mutations
local function autoFavoriteByRarity(rarities, mutations)
    local raritySet = {}
    for _, r in ipairs(rarities) do
        raritySet[normalizeName(r)] = true
    end

    local mutationSet = {}
    for mut, enabled in pairs(mutations) do
        if enabled then
            mutationSet[normalizeName(mut)] = true
        end
    end

    local rows = correlateSlotsToItems()
    local total, attempted, done = 0, 0, 0

    for _, r in ipairs(rows) do
        local rr = normalizeName(r.rarity)
        local mm = normalizeName(r.mutation)

        -- Check rarity first, THEN mutation (both must match)
        if raritySet[rr] and mutationSet[mm] then
            total += 1
            if r.favorite == false then
                attempted += 1
                if r.uuid and fireFavorite(r.uuid, r.name) then
                    done += 1
                end
                task.wait(0.08)
            end
        end
    end

    return done, total, attempted
end

-- Main auto favourite loop
function autoFavouriteLoop()
    while autoFavouriteEnabled and not unloaded do
        local rarities = {}
        for rarity, enabled in pairs(autoFavouriteRarities) do
            if enabled then
                table.insert(rarities, rarity)
            end
        end

        if #rarities > 0 then
            local done, total, attempted =
                autoFavoriteByRarity(rarities, autoFavouriteMutations)
            if done > 0 then
                showInternalToast(
                    'Auto Favourite',
                    string.format('Favorited %d/%d items', done, total),
                    Success
                )
            end
        end

        task.wait(autoFavouriteIntervalSec)
    end
end
-- Unfavourite all currently favourited items that match filters
local function unfavouriteAll()
    local rows = correlateSlotsToItems()
    local total, done = 0, 0

    -- Build filter sets
    local raritySet = {}
    for rarity, enabled in pairs(autoFavouriteRarities) do
        if enabled then
            raritySet[normalizeName(rarity)] = true
        end
    end

    local mutationSet = {}
    for mut, enabled in pairs(autoFavouriteMutations) do
        if enabled then
            mutationSet[normalizeName(mut)] = true
        end
    end

    for _, r in ipairs(rows) do
        local rr = normalizeName(r.rarity)
        local mm = normalizeName(r.mutation)

        -- Check rarity AND mutation filters, AND if item is currently favourited
        if raritySet[rr] and mutationSet[mm] and r.favorite == true then
            total += 1
            if r.uuid and fireFavorite(r.uuid, r.name) then
                done += 1
            end
            task.wait(0.08)
        end
    end

    if done > 0 then
        showInternalToast(
            'Auto Favourite',
            string.format('Unfavourited %d/%d items', done, total),
            Success
        )
    else
        showInternalToast(
            'Auto Favourite',
            'No matching favourited items found',
            Muted
        )
    end
end

-- Toggle auto favourite
function toggleAutoFavourite(on)
    autoFavouriteEnabled = (on == true)

    if autoFavouriteThread then
        task.cancel(autoFavouriteThread)
        autoFavouriteThread = nil
    end

    if autoFavouriteEnabled then
        autoFavouriteThread = task.spawn(autoFavouriteLoop)
        showInternalToast('Auto Favourite', 'Auto Favourite enabled', Success)
    else
        showInternalToast('Auto Favourite', 'Auto Favourite disabled', Muted)
    end
end

-- Function to get brainrot names from ReplicatedStorage
function getBrainrotNames()
    -- Get all brainrot names from hardcoded data
    local brainrotNames = {}
    local brainrotsByRarity = getBrainrotNamesByRarity()

    for rarity, names in pairs(brainrotsByRarity) do
        for _, name in ipairs(names) do
            table.insert(brainrotNames, name)
        end
    end

    -- Sort alphabetically
    table.sort(brainrotNames)
    return brainrotNames
end

-- Function to get brainrot names grouped by rarity
function getBrainrotNamesByRarity()
    -- Hardcoded brainrot names and rarities
    return {
        Rare = {
            'Trulimero Trulicina',
            'Fluri Flura',
            'Orangutini Strawberrini',
            'Noobini Cactusini',
            'Lirili Larila',
            'Noobini Bananini',
            'Tim Cheese',
            'Orangutini Ananassini',
            'Espresso Signora',
            'Boneca Ambalabu',
            'Agarrini La Palini',
            'Pipi Kiwi',
        },
        Epic = {
            'Brr Brr Sunflowerim',
            'Bambini Crostini',
            'Brr Brr Patapim',
            'Orcalero Orcala',
            'Alessio',
            'Cappuccino Assasino',
            'Svinino Pumpkinino',
            'Trippi Troppi',
            'Bandito Bobrito',
            'Svinino Bombondino',
            'Rinoccio Verdini',
        },
        Legendary = {
            'Dragonfrutina Dolphinita',
            'Bananita Dolphinita',
            'Elefanto Cocofanto',
            'Ballerina Cappuccina',
            'Gangster Footera',
            'Eggplantini Burbalonini',
            'Burbaloni Lulliloli',
            'Las Tralaleritas',
            'Bottellini',
        },
        Mythic = {
            'Bombardilo Watermelondrilo',
            'Bombardiro Crocodilo',
            'Frigo Camelo',
            'Bombini Gussini',
            'Baby Peperoncini And Marmellata',
            'Pesto Mortioni',
        },
        Godly = {
            'Cocotanko Giraffanto',
            'Tralalero Tralala',
            'Carnivourita Tralalerita',
            'Giraffa Celeste',
            'Kiwissimo',
            'Matteo',
            'Luis Traffico',
        },
        Secret = {
            'Los Mr. Carrotitos',
            'Crazylone Pizalone',
            'Los Tralaleritos',
            'La Tomatoro',
            'Pot Hotspot',
            'Blueberrinni Octopussini',
            'Brri Brri Bicus Dicus Bombicus',
            'Garamararam',
            'Los Sekolitos',
            'Ospedale',
            'Meowzio Sushlini',
        },
        Limited = {
            '67',
            'Hotspotini Burrito',
            'Rhino Toasterino',
            'Ospedale',
            'Chef Crabacadabra',
            'Dragon Cannelloni',
            'Wardenelli Brickatoni',
            'Cerberinno Hotdoggino',
        },
    }
end

-- =============================
-- Seed Alert Logic
-- =============================
seedAlertEnabled = (seedAlertEnabled ~= false)
_lastSeedCheckAt = 0

-- Use the SEED_ORDER already defined above

-- NEW: Authoritative map for seed rarities
SEED_RARITIES = {
    ['Cactus Seed'] = 'Rare',
    ['Strawberry Seed'] = 'Rare',
    ['Pumpkin Seed'] = 'Epic',
    ['Sunflower Seed'] = 'Epic',
    ['Dragon Fruit Seed'] = 'Legendary',
    ['Eggplant Seed'] = 'Legendary',
    ['Watermelon Seed'] = 'Mythic',
    ['Grape Seed'] = 'Mythic',
    ['Cocotank Seed'] = 'Godly',
    ['Carnivorous Plant Seed'] = 'Godly',
    ['Mr Carrot Seed'] = 'Secret',
    ['Tomatrio Seed'] = 'Secret',
    ['Shroombino Seed'] = 'Secret',
}
RARITY_ORDER =
    { 'Rare', 'Epic', 'Legendary', 'Mythic', 'Godly', 'Secret', 'Limited' }
RARITY_VALUE = {}
for i, r in ipairs(RARITY_ORDER) do
    RARITY_VALUE[r] = i
end

-- Display order for seed names (by rarity then specific order as requested)
local SEED_DISPLAY_ORDER = {
    'Cactus',
    'Strawberry',
    'Pumpkin',
    'Sunflower',
    'Dragon Fruit',
    'Eggplant',
    'Watermelon',
    'Grape',
    'Cocotank',
    'Carnivorous Plant',
    'Mr carrot',
    'Tomatrio',
    'Shroombino',
    'Mango',
    'King Limone',
}
local _seedOrderIndex = {}
for idx, label in ipairs(SEED_DISPLAY_ORDER) do
    _seedOrderIndex[label:lower()] = idx
end

local function normalizeSeedNameForOrder(name)
    name = tostring(name or ''):lower()
    name = name:gsub('%s*seed%s*$', '') -- strip trailing 'seed'
    name = name:gsub('%s+', ' ')
    return name
end

local function seedOrderIndex(name)
    local norm = normalizeSeedNameForOrder(name)
    -- try direct match
    local idx = _seedOrderIndex[norm]
    if idx then
        return idx
    end
    -- try contains match (handles cases like 'Mr Carrot')
    for k, v in pairs(_seedOrderIndex) do
        if norm == k or norm:find(k, 1, true) then
            return v
        end
    end
    return 9999, norm -- unknowns go last; tiebreak alphabetically
end

-- More robust stock parsing
function parseStockCount(text)
    if not text then
        return 0
    end
    text = tostring(text):lower()
    if text:find('out of stock') then
        return 0
    end
    local n = tonumber(text:match('(%d+)[%/ ]'))
        or tonumber(text:match('(%d+)%s*in'))
        or tonumber(text:match(':%s*(%d+)'))
        or tonumber(text:match('(%d+)$'))
        or tonumber(text:match('(%d+)'))
    return n or 0
end

-- Robust rarity parsing for seeds
function parseSeedRarity(rarityLabel)
    if not rarityLabel then
        return 'Common'
    end
    for _, child in ipairs(rarityLabel:GetChildren()) do
        if child.Name ~= 'UIStroke' and child:IsA('UIGradient') then
            return child.Name
        end
    end
    return rarityLabel.Text or 'Common'
end

-- Find George timer label on player's plot
function findGeorgeTimerLabel()
    local plot = getMyPlot()
    if not plot then
        return nil
    end
    local georgeTimer = plot:FindFirstChild('NPCs', true)
    if georgeTimer then
        georgeTimer = georgeTimer:FindFirstChild('George', true)
    end
    if georgeTimer then
        georgeTimer = georgeTimer:FindFirstChild('Timer', true)
    end
    if georgeTimer then
        georgeTimer = georgeTimer:FindFirstChild('Timer')
    end
    if georgeTimer and georgeTimer:IsA('TextLabel') then
        return georgeTimer
    end
    return nil
end

-- Find Joel timer label on player's plot (with Plots["1"] fallback)
function findJoelTimerLabel()
    local plot = getMyPlot()
    if plot then
        local t = plot:FindFirstChild('NPCs', true)
        if t then
            t = t:FindFirstChild('Joel', true)
        end
        if t then
            t = t:FindFirstChild('Timer', true)
        end
        if t then
            t = t:FindFirstChild('Timer')
        end
        if t and t:IsA('TextLabel') then
            return t
        end
    end
    local plots = Workspace:FindFirstChild('Plots')
    if plots then
        local p1 = plots:FindFirstChild('1')
        if p1 then
            local t = p1:FindFirstChild('NPCs', true)
            if t then
                t = t:FindFirstChild('Joel', true)
            end
            if t then
                t = t:FindFirstChild('Timer', true)
            end
            if t then
                t = t:FindFirstChild('Timer')
            end
            if t and t:IsA('TextLabel') then
                return t
            end
        end
    end
    return nil
end

function parseTimerToSeconds(s)
    if not s then
        return nil
    end
    local m, sec = s:match('(%d+):(%d+)')
    if m and sec then
        return tonumber(m) * 60 + tonumber(sec)
    end
    return nil
end

-- Build selection map defaulting to only Mr Carrot, Tomatrio and Shroombino ON (per request)
function defaultSeedSelection()
    local m = {}
    for _, n in ipairs(SEED_ORDER) do
        if
            n == 'Mr Carrot Seed'
            or n == 'Tomatrio Seed'
            or n == 'Shroombino Seed'
        then
            m[n] = true
        else
            m[n] = false
        end
    end
    return m
end

function ensureSeedFiltersPopulated()
    local dropdownApi = (uiRefs and uiRefs.seedFilterDropdownApi) or nil
    if not dropdownApi then
        return
    end

    -- Don't repopulate if already populated
    local items = dropdownApi.GetItems()
    if items and #items > 0 then
        return
    end

    -- Dynamically read seed names from the in-game shop UI
    local seedNames = {}
    local playerGui = player:FindFirstChild('PlayerGui')
    if playerGui then
        local seedsFrame = playerGui:FindFirstChild('Main', true)
        if seedsFrame then
            seedsFrame = seedsFrame:FindFirstChild('Seeds', true)
        end
        if seedsFrame then
            seedsFrame = seedsFrame:FindFirstChild('Frame', true)
        end
        if seedsFrame then
            seedsFrame = seedsFrame:FindFirstChild('ScrollingFrame')
        end

        if seedsFrame then
            for _, seedItem in ipairs(seedsFrame:GetChildren()) do
                if
                    seedItem:IsA('Frame')
                    and seedItem.Name ~= 'UIPadding'
                    and seedItem.Name ~= 'Padding'
                    and seedItem.Name ~= 'UIListLayout'
                then
                    local titleLabel = seedItem:FindFirstChild('Title')
                    if
                        titleLabel
                        and titleLabel.Text
                        and titleLabel.Text ~= ''
                    then
                        table.insert(seedNames, titleLabel.Text)
                    end
                end
            end
        end
    end

    -- Fallback to hardcoded list if shop UI not available
    if #seedNames == 0 then
        seedNames = {
            'Cactus Seed',
            'Strawberry Seed',
            'Pumpkin Seed',
            'Sunflower Seed',
            'Dragon Fruit Seed',
            'Eggplant Seed',
            'Watermelon Seed',
            'Grape Seed',
            'Cocotank Seed',
            'Carnivorous Plant Seed',
            'Mr Carrot Seed',
            'Tomatrio Seed',
            'Shroombino Seed',
            'Mango Seed',
            'King Limone Seed',
        }
    end

    -- Sort by desired rarity/name order
    table.sort(seedNames, function(a, b)
        local ia, na = seedOrderIndex(a)
        local ib, nb = seedOrderIndex(b)
        if ia ~= ib then
            return ia < ib
        end
        return (na or a:lower()) < (nb or b:lower())
    end)

    dropdownApi.SetItems(seedNames, true)

    -- Check if there's a saved state in the persistence registry
    local identifier = 'dropdown_key_seed_alert_filters'
    local hasSavedState = false
    if DropdownStateRegistry and DropdownStateRegistry[identifier] then
        local savedState = DropdownStateRegistry[identifier]
        if savedState and savedState.selected and next(savedState.selected) then
            hasSavedState = true
        end
    end

    -- Check if the dropdown already has selections (from persistence system)
    local currentSelections = dropdownApi.GetSelection
            and dropdownApi.GetSelection()
        or {}
    local hasExistingSelections = false
    for _, selected in pairs(currentSelections) do
        if selected then
            hasExistingSelections = true
            break
        end
    end

    -- Restore saved state if it exists, otherwise set defaults
    if hasSavedState and DropdownStateRegistry[identifier] then
        local savedState = DropdownStateRegistry[identifier]
        selectedSeedFilters = savedState.selected
        dropdownApi.SetSelectedMap(savedState.selected)
    elseif not hasExistingSelections and not next(selectedSeedFilters) then
        local preserved = {}
        for _, n in ipairs(seedNames) do
            -- Default to King Limone and Mango only (as requested by user)
            preserved[n] = (n == 'King Limone Seed' or n == 'Mango Seed')
        end
        selectedSeedFilters = preserved
        dropdownApi.SetSelectedMap(preserved)
    end
end

function checkSeedStock()
    if not seedAlertEnabled or unloaded then
        return
    end

    local now = time()
    if now - _lastSeedCheckAt < 1.0 then
        return
    end
    _lastSeedCheckAt = now

    local playerGui = player:FindFirstChild('PlayerGui')
    if not playerGui then
        return
    end

    local seedsFrame = playerGui:FindFirstChild('Main', true)
    if seedsFrame then
        seedsFrame = seedsFrame:FindFirstChild('Seeds', true)
    end
    if seedsFrame then
        seedsFrame = seedsFrame:FindFirstChild('Frame', true)
    end
    if seedsFrame then
        seedsFrame = seedsFrame:FindFirstChild('ScrollingFrame')
    end
    if not seedsFrame then
        return
    end

    local newStocked = {}
    for _, seedItem in ipairs(seedsFrame:GetChildren()) do
        if
            seedItem:IsA('Frame')
            and seedItem.Name ~= 'UIPadding'
            and seedItem.Name ~= 'Padding'
            and seedItem.Name ~= 'UIListLayout'
        then
            local stockLabel = seedItem:FindFirstChild('Stock')
            local titleLabel = seedItem:FindFirstChild('Title')

            if
                stockLabel
                and titleLabel
                and titleLabel.Text
                and titleLabel.Text ~= ''
            then
                local seedName = titleLabel.Text
                if selectedSeedFilters[seedName] == true then
                    local count = parseStockCount(stockLabel.Text)
                    local isStocked = count > 0

                    if isStocked and not _seedAlertSeen[seedName] then
                        -- Use the authoritative SEED_RARITIES map
                        local rarityName = SEED_RARITIES[seedName] or 'Common'
                        table.insert(newStocked, {
                            name = seedName,
                            stock = count,
                            rarity = rarityName,
                        })
                    elseif not isStocked then
                        _seedAlertSeen[seedName] = nil
                    end
                end
            end
        end
    end

    if #newStocked == 0 then
        return
    end

    -- Sort seeds by rarity (highest rarity first)
    table.sort(newStocked, function(a, b)
        local aVal = RARITY_VALUE[a.rarity] or 0
        local bVal = RARITY_VALUE[b.rarity] or 0
        return aVal > bVal -- Higher rarity first
    end)

    -- Mark all found seeds as seen to prevent re-triggering by the TextChanged event
    for _, entry in ipairs(newStocked) do
        _seedAlertSeen[entry.name] = true
    end

    local names = {}
    for _, e in ipairs(newStocked) do
        table.insert(names, e.name)
    end
    local titleText
    if #names == 1 then
        titleText = string.format("'%s' in Stock!", names[1])
    else
        titleText = string.format('%d Seeds in Stock!', #names)
    end

    local parts = {}
    for _, e in ipairs(newStocked) do
        table.insert(
            parts,
            string.format('%s (%s) x%d', e.name, e.rarity, e.stock)
        )
    end
    local subText = table.concat(parts, '  •  ')

    -- MODIFIED: Determine the highest rarity for the color (first item after sorting)
    local highestRarity = newStocked[1].rarity
    local color = Rarities[highestRarity] or AccentB

    Alerts_ShowSeedToast(titleText, subText, color, false) -- Pass false for isTest
end

-- =============================

-- =============================
-- Auto Buy Logic (Seed and Gear)
-- =============================
seedAutoBuyEnabled = false
gearAutoBuyEnabled = false
selectedSeedBuyFilters = {}
selectedGearBuyFilters = {}
_lastSeedBuyCheckAt = 0
_lastGearBuyCheckAt = 0
seedAutoBuyThread = nil
-- Guards to avoid re-defaulting after initial restore
local seedAutoBuyInitDone = false
local gearAutoBuyInitDone = false
gearAutoBuyThread = nil

-- Auto buy functions
function buyItem(itemName, itemType)
    local success, error = pcall(function()
        local replicatedStorage = game:GetService('ReplicatedStorage')
        local remotes = replicatedStorage:FindFirstChild('Remotes')

        if remotes then
            if itemType == 'seed' then
                local buyItem = remotes:FindFirstChild('BuyItem')
                if buyItem then
                    buyItem:FireServer(itemName, 1)
                    return true
                end
            elseif itemType == 'gear' then
                local buyGear = remotes:FindFirstChild('BuyGear')
                if buyGear then
                    buyGear:FireServer(itemName, 1)
                    return true
                end
            end
        end
    end)

    if not success then
        -- Silent failure - no debug output
    end
end

function checkSeedAutoBuy()
    if not seedAutoBuyEnabled or unloaded then
        return
    end

    local now = time()
    if now - _lastSeedBuyCheckAt < 2.0 then
        return
    end
    _lastSeedBuyCheckAt = now

    local playerGui = player:FindFirstChild('PlayerGui')
    if not playerGui then
        return
    end

    local seedsFrame = playerGui:FindFirstChild('Main', true)
    if seedsFrame then
        seedsFrame = seedsFrame:FindFirstChild('Seeds', true)
    end
    if seedsFrame then
        seedsFrame = seedsFrame:FindFirstChild('Frame', true)
    end
    if seedsFrame then
        seedsFrame = seedsFrame:FindFirstChild('ScrollingFrame')
    end
    if not seedsFrame then
        return
    end

    for _, seedItem in ipairs(seedsFrame:GetChildren()) do
        if
            seedItem:IsA('Frame')
            and seedItem.Name ~= 'UIPadding'
            and seedItem.Name ~= 'Padding'
            and seedItem.Name ~= 'UIListLayout'
        then
            local stockLabel = seedItem:FindFirstChild('Stock')
            local titleLabel = seedItem:FindFirstChild('Title')

            if
                stockLabel
                and titleLabel
                and titleLabel.Text
                and titleLabel.Text ~= ''
            then
                local seedName = titleLabel.Text
                if selectedSeedBuyFilters[seedName] == true then
                    local count = parseStockCount(stockLabel.Text)
                    if count > 0 then
                        buyItem(seedName, 'seed')
                        task.wait(0.1) -- Small delay between purchases
                    end
                end
            end
        end
    end
end

function checkGearAutoBuy()
    if not gearAutoBuyEnabled or unloaded then
        return
    end

    local now = time()
    if now - _lastGearBuyCheckAt < 2.0 then
        return
    end
    _lastGearBuyCheckAt = now

    local gearsFrame = getGearsScrollingFrame()
    if not gearsFrame then
        return
    end

    for _, item in ipairs(gearsFrame:GetChildren()) do
        if
            item:IsA('Frame')
            and item.Name ~= 'Padding'
            and item.Name ~= 'UIPadding'
            and item.Name ~= 'UIListLayout'
        then
            local title = item:FindFirstChild('Title')
            local stock = item:FindFirstChild('Stock')

            if title and stock and title.Text and title.Text ~= '' then
                local name = title.Text
                if selectedGearBuyFilters[name] == true then
                    local count = parseStockCount(stock.Text)
                    if count > 0 then
                        buyItem(name, 'gear')
                        task.wait(0.1) -- Small delay between purchases
                    end
                end
            end
        end
    end
end
function startSeedAutoBuyThread()
    if seedAutoBuyThread then
        task.cancel(seedAutoBuyThread)
    end
    seedAutoBuyThread = task.spawn(function()
        while seedAutoBuyEnabled and not unloaded do
            checkSeedAutoBuy()
            task.wait(1)
        end
    end)
end

function startGearAutoBuyThread()
    if gearAutoBuyThread then
        task.cancel(gearAutoBuyThread)
    end
    gearAutoBuyThread = task.spawn(function()
        while gearAutoBuyEnabled and not unloaded do
            checkGearAutoBuy()
            task.wait(1)
        end
    end)
end

function stopSeedAutoBuyThread()
    if seedAutoBuyThread then
        task.cancel(seedAutoBuyThread)
        seedAutoBuyThread = nil
    end
end

function stopGearAutoBuyThread()
    if gearAutoBuyThread then
        task.cancel(gearAutoBuyThread)
        gearAutoBuyThread = nil
    end
end

function toggleSeedAutoBuy(enabled)
    seedAutoBuyEnabled = enabled
    if enabled then
        startSeedAutoBuyThread()
    else
        stopSeedAutoBuyThread()
    end
end

function toggleGearAutoBuy(enabled)
    gearAutoBuyEnabled = enabled
    if enabled then
        startGearAutoBuyThread()
    else
        stopGearAutoBuyThread()
    end
end

-- Anti-AFK functions (Infinite Yield style - works without focus)
function startAntiAfkThread()
    if antiAfkThread then
        task.cancel(antiAfkThread)
    end
    antiAfkThread = task.spawn(function()
        while antiAfkEnabled and not unloaded do
            -- Use VirtualInputManager for input that works without focus
            local virtualInputManager = game:GetService('VirtualInputManager')

            -- Move camera slightly (most effective AFK prevention)
            local camera = workspace.CurrentCamera
            if camera then
                local currentCFrame = camera.CFrame
                local newCFrame = currentCFrame
                    * CFrame.Angles(
                        math.rad(math.random(-1, 1)), -- Pitch (up/down)
                        math.rad(math.random(-1, 1)), -- Yaw (left/right)
                        0 -- Roll (no roll)
                    )
                camera.CFrame = newCFrame
            end

            -- Also send a virtual key press (works without focus)
            virtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
            task.wait(0.05)
            virtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)

            -- Wait 20 seconds before next anti-AFK action
            task.wait(20)
        end
    end)
end

function stopAntiAfkThread()
    if antiAfkThread then
        task.cancel(antiAfkThread)
        antiAfkThread = nil
    end
end

-- =============================
-- Gear Alert Logic (toggle + dropdown + bottom-right toasts)
-- =============================
selectedGearFilters = {}
-- gearFilterDropdownApi removed - now using refs
gearFiltersInitialized = false

GEAR_RARITY_VALUE = { Epic = 1, Legendary = 2, Godly = 3 }

_gearAlertSeen = {}
_lastGearCheckAt = 0
_gearShopBindings = {}
observedGearTimerConn = nil
gearTimerWatchThread = nil
GEAR_BATCH_COOLDOWN = 60
_lastGearBatchAlertAt = 0

function parseGearRarity(rarityLabel)
    local r = parseSeedRarity and parseSeedRarity(rarityLabel)
        or (rarityLabel and rarityLabel.Text)
        or 'Epic'
    if r ~= 'Epic' and r ~= 'Legendary' and r ~= 'Godly' then
        r = 'Epic'
    end
    return r
end

function getGearsScrollingFrame()
    local playerGui = player:FindFirstChild('PlayerGui')
    if not playerGui then
        return nil
    end
    local gearsFrame = playerGui:FindFirstChild('Main', true)
    if gearsFrame then
        gearsFrame = gearsFrame:FindFirstChild('Gears', true)
    end
    if gearsFrame then
        gearsFrame = gearsFrame:FindFirstChild('Frame', true)
    end
    if gearsFrame then
        gearsFrame = gearsFrame:FindFirstChild('ScrollingFrame')
    end
    return gearsFrame
end

function Alerts_ShowGearToast(titleText, subText, color)
    ensureGearToastsGui()
    buildToast(titleText, subText, color, gearToastContainer)
    playSeedPing() -- reuse seed sound
    local now = time()
    if
        webhookEnabled
        and gearWebhookEnabled
        and (
            _lastGearWebhookAt == 0
            or (now - _lastGearWebhookAt >= _webhookCooldown)
        )
    then
        _lastGearWebhookAt = now
        task.spawn(function()
            local mentionPrefix = ''
            if webhookPingMode == 'All' or webhookPingMode == 'Gear' then
                mentionPrefix = '@everyone'
            end
            local payload = {
                content = (mentionPrefix ~= '') and mentionPrefix or nil,
                embeds = {
                    {
                        title = titleText,
                        description = subText,
                        color = color3ToDecimal(color),
                        timestamp = os.date('!%Y-%m-%dT%H:%M:%S.000Z'),
                    },
                },
            }
            sendWebhook(payload)
        end)
    end
end

function ensureGearFiltersPopulated(names)
    local dropdownApi = (uiRefs and uiRefs.gearFilterDropdownApi) or nil
    if not dropdownApi then
        return
    end

    -- Don't repopulate if already populated
    local items = dropdownApi.GetItems()
    if items and #items > 0 then
        return
    end

    -- Define the desired order for gear alerts
    local desiredOrder = {
        'Water Bucket',
        'Frost Grenade',
        'Banana Gun',
        'Frost Blower',
        'Carrot Launcher',
    }

    -- Create ordered list based on desired order, then add any others
    local list, seen = {}, {}

    -- First, add items in the desired order if they exist
    for _, desiredName in ipairs(desiredOrder) do
        for _, n in ipairs(names or {}) do
            if n and n == desiredName and not seen[n] then
                seen[n] = true
                table.insert(list, n)
                break
            end
        end
    end

    -- Then add any remaining items that weren't in the desired order
    for _, n in ipairs(names or {}) do
        if n and not seen[n] then
            seen[n] = true
            table.insert(list, n)
        end
    end

    if #list == 0 then
        return
    end
    local preserved = {}
    local hadAny = false
    for _, n in ipairs(list) do
        if selectedGearFilters[n] ~= nil then
            preserved[n] = selectedGearFilters[n]
            hadAny = true
        end
    end

    -- Only set defaults if no selections have been made yet (first time or no config loaded)
    if not hadAny then
        for _, n in ipairs(list) do
            -- Default to only Carrot Launcher and Frost Blower
            preserved[n] = (n == 'Carrot Launcher' or n == 'Frost Blower')
        end
    end

    selectedGearFilters = preserved
    dropdownApi.SetItems(list, true)
    dropdownApi.SetSelectedMap(preserved)
end
function checkGearStock()
    if not gearAlertEnabled or unloaded then
        return
    end
    local now = time()
    if now - _lastGearCheckAt < 1.0 then
        return
    end
    _lastGearCheckAt = now
    local gearsFrame = getGearsScrollingFrame()
    if not gearsFrame then
        return
    end

    local found, namesNow = {}, {}
    for _, item in ipairs(gearsFrame:GetChildren()) do
        if
            item:IsA('Frame')
            and item.Name ~= 'Padding'
            and item.Name ~= 'UIPadding'
            and item.Name ~= 'UIListLayout'
        then
            local title = item:FindFirstChild('Title')
            local stock = item:FindFirstChild('Stock')
            local rarityLabel = item:FindFirstChild('Rarity')
            if title and stock and title.Text and title.Text ~= '' then
                local name = title.Text
                table.insert(namesNow, name)
                if selectedGearFilters[name] == true then
                    local count = parseStockCount(stock.Text)
                    local inStock = (count or 0) > 0
                    if inStock and not _gearAlertSeen[name] then
                        local rarityName = parseGearRarity(rarityLabel)
                        table.insert(
                            found,
                            { name = name, stock = count, rarity = rarityName }
                        )
                    elseif not inStock then
                        _gearAlertSeen[name] = nil
                    end
                end
            end
        end
    end

    if not gearFiltersInitialized then
        ensureGearFiltersPopulated(namesNow)
    end
    if #found == 0 then
        return
    end
    for _, e in ipairs(found) do
        _gearAlertSeen[e.name] = true
    end

    local highest = 'Epic'
    local hv = 0
    for _, e in ipairs(found) do
        local v = GEAR_RARITY_VALUE[e.rarity] or 0
        if v > hv then
            hv = v
            highest = e.rarity
        end
    end
    local color = Rarities[highest] or AccentB

    if
        not (
            _lastGearBatchAlertAt
            and (now - _lastGearBatchAlertAt < GEAR_BATCH_COOLDOWN)
        )
    then
        _lastGearBatchAlertAt = now
        -- Always use the proper format with headers, even for single items
        local parts = {}
        for _, e in ipairs(found) do
            table.insert(
                parts,
                string.format('%s (%s) x%d', e.name, e.rarity, e.stock)
            )
        end
        Alerts_ShowGearToast(
            string.format('%d Gears Available', #found),
            table.concat(parts, ' • '),
            color
        )
    end
end

function safeDisconnectGearBinding(item)
    local c = _gearShopBindings[item]
    if c then
        pcall(function()
            c:Disconnect()
        end)
        _gearShopBindings[item] = nil
    end
end

function bindGearShopItem(item)
    if not item or _gearShopBindings[item] then
        return
    end
    local stock = item:FindFirstChild('Stock')
    local title = item:FindFirstChild('Title')
    if not stock or not title then
        return
    end
    function onText()
        if not gearAlertEnabled or unloaded then
            return
        end
        local count = parseStockCount(stock.Text)
        if (count or 0) == 0 and title.Text and title.Text ~= '' then
            _gearAlertSeen[title.Text] = nil
        end
    end
    local conn = bind(stock:GetPropertyChangedSignal('Text'):Connect(onText))
    _gearShopBindings[item] = conn
    bind(item.AncestryChanged:Connect(function(_, parent)
        if not parent then
            safeDisconnectGearBinding(item)
        end
    end))
end

function startGearShopBindings()
    local gearsFrame = getGearsScrollingFrame()
    if not gearsFrame then
        return
    end
    for item, _ in pairs(_gearShopBindings) do
        safeDisconnectGearBinding(item)
    end
    for _, child in ipairs(gearsFrame:GetChildren()) do
        if child:IsA('Frame') then
            bindGearShopItem(child)
        end
    end
    bind(gearsFrame.ChildAdded:Connect(function(child)
        task.delay(0.02, function()
            if child:IsA('Frame') then
                bindGearShopItem(child)
            end
        end)
    end))
end

function startGearTimerWatcher()
    if gearTimerWatchThread then
        task.cancel(gearTimerWatchThread)
    end
    gearTimerWatchThread = task.spawn(function()
        local lastSeconds
        local lastLabel
        function onTimerChanged()
            if not lastLabel then
                return
            end
            local secs = parseTimerToSeconds(lastLabel.Text or '')
            if secs and lastSeconds and secs > (lastSeconds + 15) then
                _gearAlertSeen = {}
                task.delay(0.2, checkGearStock)
            end
            lastSeconds = secs or lastSeconds
        end
        function bindTimer(lbl)
            if observedGearTimerConn then
                pcall(function()
                    observedGearTimerConn:Disconnect()
                end)
            end
            if not lbl then
                return
            end
            observedGearTimerConn = bind(
                lbl:GetPropertyChangedSignal('Text'):Connect(onTimerChanged)
            )
        end
        while not unloaded do
            local lbl = findJoelTimerLabel and findJoelTimerLabel() or nil
            if lbl ~= lastLabel then
                lastLabel = lbl
                bindTimer(lbl)
            end
            task.wait(1)
        end
    end)
end

function toggleGearAlerts(on)
    gearAlertEnabled = on
    if on then
        _gearAlertSeen = {}
        ensureGearToastsGui()
        startGearTimerWatcher()
        task.delay(0.02, startGearShopBindings)
        task.delay(0.25, checkGearStock)
    else
        if gearTimerWatchThread then
            task.cancel(gearTimerWatchThread)
            gearTimerWatchThread = nil
        end
        if observedGearTimerConn then
            pcall(function()
                observedGearTimerConn:Disconnect()
            end)
            observedGearTimerConn = nil
        end
        for item, _ in pairs(_gearShopBindings) do
            safeDisconnectGearBinding(item)
        end
    end
end
-- Seed shop binding logic
-- =============================
local _seedShopBindings = {}

function safeDisconnectSeedBinding(seedItem)
    local c = _seedShopBindings[seedItem]
    if c then
        pcall(function()
            c:Disconnect()
        end)
        _seedShopBindings[seedItem] = nil
    end
end

function bindSeedShopItem(seedItem)
    if not seedItem or _seedShopBindings[seedItem] then
        return
    end

    local stockLabel = seedItem:FindFirstChild('Stock')
    if not stockLabel then
        return
    end

    function onTextChanged()
        if not seedAlertEnabled or unloaded then
            return
        end

        local count = parseStockCount(stockLabel.Text)
        if count == 0 then
            local titleLabel = seedItem:FindFirstChild('Title')
            if titleLabel and titleLabel.Text and titleLabel.Text ~= '' then
                -- When a seed is bought and goes out of stock, reset its 'seen' flag for the next restock cycle.
                _seedAlertSeen[titleLabel.Text] = nil
            end
        end
    end

    -- Connect to Text changed for instant reaction
    local conn =
        bind(stockLabel:GetPropertyChangedSignal('Text'):Connect(onTextChanged))
    _seedShopBindings[seedItem] = conn

    -- Also disconnect when the seedItem is removed from UI to avoid leaks
    bind(seedItem.AncestryChanged:Connect(function(_, parent)
        if not parent or parent == nil then
            safeDisconnectSeedBinding(seedItem)
        end
    end))
end

function startSeedShopBindings()
    local playerGui = player:FindFirstChild('PlayerGui')
    if not playerGui then
        return
    end
    local seedsFrame = playerGui:FindFirstChild('Main', true)
    if seedsFrame then
        seedsFrame = seedsFrame:FindFirstChild('Seeds', true)
    end
    if seedsFrame then
        seedsFrame = seedsFrame:FindFirstChild('Frame', true)
    end
    if seedsFrame then
        seedsFrame = seedsFrame:FindFirstChild('ScrollingFrame')
    end
    if not seedsFrame then
        return
    end

    for item, _ in pairs(_seedShopBindings) do
        safeDisconnectSeedBinding(item)
    end

    for _, seedItem in ipairs(seedsFrame:GetChildren()) do
        if seedItem:IsA('Frame') then
            bindSeedShopItem(seedItem)
        end
    end

    bind(seedsFrame.ChildAdded:Connect(function(child)
        task.delay(0.02, function()
            if child:IsA('Frame') then
                bindSeedShopItem(child)
            end
        end)
    end))
end

-- Watch the seed shop timer and trigger checks only when it refreshes
local seedTimerWatchThread
function startSeedTimerWatcher()
    if seedTimerWatchThread then
        task.cancel(seedTimerWatchThread)
    end
    seedTimerWatchThread = task.spawn(function()
        local lastSeconds
        local lastLabel -- to rebind on object swap
        function onTimerChanged()
            if not lastLabel then
                return
            end
            local secs = parseTimerToSeconds(lastLabel.Text or '')
            if secs and lastSeconds and secs > (lastSeconds + 15) then
                -- Likely refresh happened (jump up)
                _seedAlertSeen = {} -- clear all seen flags for a fresh cycle
                task.delay(0.2, checkSeedStock) -- check after a short delay
            end
            lastSeconds = secs or lastSeconds
        end

        function bindTimer(lbl)
            if observedTimerConn then
                pcall(function()
                    observedTimerConn:Disconnect()
                end)
            end
            if not lbl then
                return
            end
            observedTimerConn = bind(
                lbl:GetPropertyChangedSignal('Text'):Connect(onTimerChanged)
            )
        end

        while not unloaded do
            local lbl = findGeorgeTimerLabel()
            if lbl ~= lastLabel then
                lastLabel = lbl
                bindTimer(lbl)
            end
            task.wait(1) -- Check for new label every second
        end
    end)
end

-- =============================
-- Game Info Logic & GUI
-- =============================
gameInfoThread = nil
infoFrame, bossLabel, luckPityLabel, luckValueLabel, moneyLabel, moneyPerSecondLabel, seedShopTimerLabel, brainrotCountLabel, autoCollectTimerLabel, autoEquipBestTimerLabel, fuseTimerLabel, dailyRewardsLabel =
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil

-- Game Info Display filter system
gameInfoFilters = {
    money = true,
    moneyPerSecond = true,
    boss = true,
    luck = true,
    luckValue = true,
    seedShop = true,
    autoCollect = true,
    autoEquipBest = true,
    fuseMachine = true,
    dailyRewards = true,
}
function buildGameInfoGui()
    gameInfoGui = New('ScreenGui', {
        Name = 'GameInfoDisplay',
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 500,
        Enabled = false,
        Parent = CoreGui,
    })

    infoFrame = New('Frame', {
        Size = UDim2.new(0, 260, 0, 162),
        Position = UDim2.new(0.5, -130, 0, 12), -- Top middle position
        BackgroundColor3 = Card,
        BackgroundTransparency = 0.05, -- More opaque for glassmorphism
        Parent = gameInfoGui,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 20) }), -- More rounded corners
        New('UIStroke', {
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1.5,
            Transparency = 0.3,
        }), -- White stroke for glass effect
        New('UIStroke', {
            Color = Stroke,
            Thickness = 0.8,
            Transparency = 0.1,
        }), -- Secondary stroke for depth
    })
    infoFrame.Active = true
    infoFrame.Selectable = true

    -- Add subtle hover effect
    infoFrame.MouseEnter:Connect(function()
        local tween = TweenService:Create(
            infoFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {
                BackgroundTransparency = 0.02,
            }
        )
        tween:Play()
    end)

    infoFrame.MouseLeave:Connect(function()
        local tween = TweenService:Create(
            infoFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {
                BackgroundTransparency = 0.05,
            }
        )
        tween:Play()
    end)

    gameInfoScaleObj =
        New('UIScale', { Scale = gameInfoScale, Parent = infoFrame })

    -- Filter dropdown (properly centered with spacing)
    local filterDropdown, filterContainer = Components.MultiSelectDropdown({
        Parent = infoFrame,
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(0.5, -100, 0, 15),
        Title = 'Show/Hide Info',
        ZIndex = 50,
        PersistenceKey = 'gameinfo_filters',
        Items = {
            'Money',
            'Money/s',
            'Boss',
            '10x Luck',
            'Luck Stat',
            'Shop Refresh',
            'Auto Collect',
            'Auto Equip',
            'Fuse Machine',
            'Daily Rewards',
        },
        OnChanged = function(map)
            gameInfoFilters.money = map['Money'] or false
            gameInfoFilters.moneyPerSecond = map['Money/s'] or false
            gameInfoFilters.boss = map['Boss'] or false
            gameInfoFilters.luck = map['10x Luck'] or false
            gameInfoFilters.luckValue = map['Luck Stat'] or false
            gameInfoFilters.seedShop = map['Shop Refresh'] or false
            gameInfoFilters.autoCollect = map['Auto Collect'] or false
            gameInfoFilters.autoEquipBest = map['Auto Equip'] or false
            gameInfoFilters.fuseMachine = map['Fuse Machine'] or false
            gameInfoFilters.dailyRewards = map['Daily Rewards'] or false
        end,
    })
    -- Defer full restore until both autohit dropdowns are created
    -- Set all filters to enabled by default only if no config has been loaded
    -- This is for game info filters, so we'll check if any filters are set
    local hasAnyFilters = false
    for _, enabled in pairs(gameInfoFilters) do
        if enabled then
            hasAnyFilters = true
            break
        end
    end

    if not hasAnyFilters then
        filterDropdown.SetSelectedAll(true)
    end

    -- Force the dropdown to be centered (override component positioning)
    if filterContainer then
        filterContainer.Size = UDim2.new(0, 200, 0, 30)
        filterContainer.Position = UDim2.new(0.5, -100, 0, 15)
    end

    -- Game Information title (under dropdown) with enhanced styling and proper spacing
    local titleLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 55),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = 'Game Information',
        TextColor3 = Text,
        TextSize = 16,
        Parent = infoFrame,
    })

    -- Add subtle glow effect to title
    New('UIStroke', {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 0.5,
        Transparency = 0.7,
        Parent = titleLabel,
    })

    -- Drag handle for Game Info window (top area)
    local giDragArea = New('Frame', {
        Parent = infoFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 10,
        Active = true,
    })

    local listLayout = New('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    })

    -- Subtle background gradient effect
    local gradientFrame = New('Frame', {
        Size = UDim2.new(1, -20, 1, -80),
        Position = UDim2.new(0, 10, 0, 80),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.95,
        Parent = infoFrame,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 12) }),
    })

    local contentFrame = New('Frame', {
        Size = UDim2.new(1, -20, 1, -80),
        Position = UDim2.new(0, 10, 0, 80),
        BackgroundTransparency = 1,
        Parent = infoFrame,
    })
    listLayout.Parent = contentFrame

    bossLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = 'Boss: ...',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 1,
    })

    luckPityLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = '10x Luck: ...',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 2,
    })

    luckValueLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = 'Luck Stat: ...',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 3,
    })

    moneyLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = 'Money: ...',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 4,
    })

    moneyPerSecondLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = 'Money/s: ...',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 5,
    })

    seedShopTimerLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = 'Shop Refresh: ...',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 6,
    })

    autoCollectTimerLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = 'Next Collect: Off',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 7,
    })

    autoEquipBestTimerLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = 'Next Equip: Off',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 8,
    })

    brainrotCountLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = 'Active Podiums: 0',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 9,
        Visible = false,
    })

    fuseTimerLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = 'Fuse Machine: N/A',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 10,
    })

    dailyRewardsLabel = New('TextLabel', {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = 'Daily Rewards Timer: N/A',
        TextColor3 = Muted,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame,
        LayoutOrder = 11,
    })

    -- Enable dragging the Game Info window via its header only
    do
        local giDragging = false
        local giStartPos
        local giDragStart

        local function beginGIDrag(input)
            giDragging = true
            giDragStart = input.Position
            local ap = infoFrame.AbsolutePosition
            giStartPos = Vector2.new(ap.X, ap.Y)
        end

        bind(giDragArea.InputBegan:Connect(function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                beginGIDrag(input)
            end
        end))

        bind(UserInputService.InputChanged:Connect(function(input)
            if not giDragging then
                return
            end
            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local delta = input.Position - giDragStart
                infoFrame.Position = UDim2.fromOffset(
                    giStartPos.X + delta.X,
                    giStartPos.Y + delta.Y
                )
            end
        end))

        bind(UserInputService.InputEnded:Connect(function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                giDragging = false
            end
        end))
    end
end

function updateMoneyLabel()
    local money = player:FindFirstChild('leaderstats')
        and player.leaderstats:FindFirstChild('Money')
    if money then
        moneyLabel.Text = 'Money: ' .. formatNumber(money.Value)
    else
        moneyLabel.Text = 'Money: N/A'
    end
end

function updatePlotInfo()
    local plot = getMyPlot()
    if not plot then
        bossLabel.Text = 'Boss: Plot not found'
        luckPityLabel.Text = 'Luck: Plot not found'
        luckValueLabel.Text = 'Luck Stat: N/A'
        seedShopTimerLabel.Text = 'Seed Shop: N/A'
        return
    end

    local spawnerUI = plot:FindFirstChild('SpawnerUI')
    if spawnerUI and spawnerUI:FindFirstChild('Main') then
        local mainUI = spawnerUI.Main
        local bossContainer = mainUI:FindFirstChild('Boss')
        if bossContainer then
            local amountLabel = bossContainer:FindFirstChild('Amount')
            if amountLabel then
                bossLabel.Text = 'Boss: ' .. amountLabel.Text
            end
        end
        local luckContainer = mainUI:FindFirstChild('Luck')
        if luckContainer then
            local amountLabel = luckContainer:FindFirstChild('Amount')
            if amountLabel then
                luckPityLabel.Text = 'Luck: ' .. amountLabel.Text
            end
        end
    end

    local luckLabel = nil
    local luckDisplayModel = plot:FindFirstChild('LuckDisplay')
    if luckDisplayModel then
        local luckDisplayGui = luckDisplayModel:FindFirstChild('LuckDisplay')
        if luckDisplayGui then
            local luckGui = luckDisplayGui:FindFirstChild('LuckGUI')
            if luckGui then
                local luckFrame = luckGui:FindFirstChild('Luck')
                if luckFrame then
                    luckLabel = luckFrame:FindFirstChild('LuckLabel')
                end
            end
        end
    end

    if luckLabel then
        luckValueLabel.Text = 'Luck Stat: ' .. luckLabel.Text
    else
        luckValueLabel.Text = 'Luck Stat: N/A'
    end

    local georgeLabel = findGeorgeTimerLabel()
    if georgeLabel then
        seedShopTimerLabel.Text = 'Shop Refresh: ' .. (georgeLabel.Text or '')
    else
        seedShopTimerLabel.Text = 'Shop Refresh: N/A'
    end
end

function updateAutoCollectTimer()
    if autoCollectEnabled then
        local remaining = math.floor(nextCollectTime - time())
        if remaining > 0 then
            autoCollectTimerLabel.Text = 'Next Collect: ' .. remaining .. 's'
        else
            autoCollectTimerLabel.Text = 'Next Collect: Now...'
        end
    else
        autoCollectTimerLabel.Text = 'Next Collect: Off'
    end
end

function updateAutoEquipBestTimer()
    if autoEquipBestEnabled then
        local remaining = math.floor(nextEquipBestTime - time())
        if remaining > 0 then
            autoEquipBestTimerLabel.Text = 'Next Equip: ' .. remaining .. 's'
        else
            autoEquipBestTimerLabel.Text = 'Next Equip: Now...'
        end
    else
        autoEquipBestTimerLabel.Text = 'Next Equip: Off'
    end
end

function updateGameInfo()
    if time() - lastPlotScan > 10 then
        getMyPlot(true)
        lastPlotScan = time()
    end

    -- Apply filter visibility
    if moneyLabel then
        moneyLabel.Visible = gameInfoFilters.money
    end
    if moneyPerSecondLabel then
        moneyPerSecondLabel.Visible = gameInfoFilters.moneyPerSecond
    end
    if bossLabel then
        bossLabel.Visible = gameInfoFilters.boss
    end
    if luckPityLabel then
        luckPityLabel.Visible = gameInfoFilters.luck
    end
    if luckValueLabel then
        luckValueLabel.Visible = gameInfoFilters.luckValue
    end
    if seedShopTimerLabel then
        seedShopTimerLabel.Visible = gameInfoFilters.seedShop
    end
    if autoCollectTimerLabel then
        autoCollectTimerLabel.Visible = gameInfoFilters.autoCollect
    end
    if autoEquipBestTimerLabel then
        autoEquipBestTimerLabel.Visible = gameInfoFilters.autoEquipBest
    end
    if brainrotCountLabel then
        brainrotCountLabel.Visible = gameInfoFilters.autoCollect
            and autoCollectEnabled
    end
    if fuseTimerLabel then
        fuseTimerLabel.Visible = gameInfoFilters.fuseMachine
    end
    if dailyRewardsLabel then
        dailyRewardsLabel.Visible = gameInfoFilters.dailyRewards
    end

    -- Money
    local m = player
        and player:FindFirstChild('leaderstats')
        and player.leaderstats:FindFirstChild('Money')
    if m and m.Value ~= nil then
        moneyLabel.Text = 'Money: ' .. formatNumber(m.Value)
    else
        moneyLabel.Text = 'Money: N/A'
    end

    -- Money per second
    local moneyPerSecond = player
        and player.PlayerGui
        and player.PlayerGui:FindFirstChild('Main')
        and player.PlayerGui.Main:FindFirstChild('CashPerSecond')
        and player.PlayerGui.Main.CashPerSecond:FindFirstChild('Money')
    if moneyPerSecond and moneyPerSecond.Text then
        moneyPerSecondLabel.Text = 'Money/s: ' .. moneyPerSecond.Text
    else
        moneyPerSecondLabel.Text = 'Money/s: N/A'
    end

    -- Plot / Boss / Luck
    local plot = getMyPlot()
    if not plot then
        bossLabel.Text = 'Boss: Plot not found'
        luckPityLabel.Text = 'Luck: Plot not found'
        luckValueLabel.Text = 'Luck Stat: N/A'
        seedShopTimerLabel.Text = 'Seed Shop: N/A'
    else
        -- minimal-safe access to main UI
        pcall(function()
            local spawner = plot:FindFirstChild('SpawnerUI')
            local mainUI = spawner and spawner:FindFirstChild('Main')
            if mainUI then
                local bossContainer = mainUI:FindFirstChild('Boss')
                local a = bossContainer
                    and bossContainer:FindFirstChild('Amount')
                if a and a.Text then
                    bossLabel.Text = 'Boss: ' .. fixCorruptedText(a.Text)
                end

                local luckContainer = mainUI:FindFirstChild('Luck')
                local la = luckContainer
                    and luckContainer:FindFirstChild('Amount')
                if la and la.Text then
                    luckPityLabel.Text = 'Luck: ' .. fixCorruptedText(la.Text)
                end
            end
        end)

        -- luck label lookup (kept compact)
        local luckText = nil
        pcall(function()
            local ldm = plot:FindFirstChild('LuckDisplay')
            local ldg = ldm and ldm:FindFirstChild('LuckDisplay')
            local lg = ldg and ldg:FindFirstChild('LuckGUI')
            local lf = lg and lg:FindFirstChild('Luck')
            local ll = lf and lf:FindFirstChild('LuckLabel')
            if ll and ll.Text then
                luckText = ll.Text
            end
        end)
        if luckText then
            luckValueLabel.Text = 'Luck Stat: ' .. luckText
        else
            luckValueLabel.Text = 'Luck Stat: N/A'
        end

        local george = findGeorgeTimerLabel()
        seedShopTimerLabel.Text = (
            george and ('Shop Refresh: ' .. (george.Text or ''))
        ) or 'Shop Refresh: N/A'
    end

    brainrotCountLabel.Visible = autoCollectEnabled

    -- Update brainrot count
    if autoCollectEnabled then
        brainrotCountLabel.Text = 'Active Podiums: '
            .. (activeBrainrotCount or 0)
    end

    -- Adjust window height based on auto collect and auto equip best visibility
    if autoCollectEnabled and autoEquipBestEnabled then
        infoFrame.Size = UDim2.new(0, 260, 0, 340) -- Tallest when both are on
    elseif autoCollectEnabled or autoEquipBestEnabled then
        infoFrame.Size = UDim2.new(0, 260, 0, 320) -- Taller when one is on
    else
        infoFrame.Size = UDim2.new(0, 260, 0, 300) -- Normal height when both are off
    end

    if autoCollectEnabled then
        local remaining = math.floor(nextCollectTime - time())
        if remaining > 0 then
            autoCollectTimerLabel.Text = 'Next Collect: ' .. remaining .. 's'
        else
            autoCollectTimerLabel.Text = 'Next Collect: Now...'
        end
    else
        autoCollectTimerLabel.Text = 'Next Collect: Off'
    end

    -- Auto Equip Best Timer
    if autoEquipBestEnabled then
        local remaining = math.floor(nextEquipBestTime - time())
        if remaining > 0 then
            autoEquipBestTimerLabel.Text = 'Next Equip: ' .. remaining .. 's'
        else
            autoEquipBestTimerLabel.Text = 'Next Equip: Now...'
        end
    else
        autoEquipBestTimerLabel.Text = 'Next Equip: Off'
    end

    -- Fuse Machine Timer
    local scriptedMap = game:GetService('Workspace')
        :FindFirstChild('ScriptedMap')
    local fuseMachine = scriptedMap
        and scriptedMap:FindFirstChild('FuseMachine')
    local ui = fuseMachine and fuseMachine:FindFirstChild('UI')
    local gui = ui and ui:FindFirstChild('GUI')
    if gui then
        local title = gui:FindFirstChild('Title')
        local timer = gui:FindFirstChild('Timer')
        local titleText = (title and title.Text) or ''
        local timerText = (timer and timer.Text) or ''
        -- Check if timer shows the decorative default (~ ... ~), consider it ready
        if timerText:match('~.*~') then
            -- It's the default "~ Fuse plants and brainrots! ~" text
            fuseTimerLabel.Text = 'Fuse Machine: Ready'
        elseif timerText ~= '' then
            -- It's an actual timer, show the countdown
            fuseTimerLabel.Text = 'Fuse Machine: ' .. timerText
        else
            fuseTimerLabel.Text = 'Fuse Machine: N/A'
        end
    else
        fuseTimerLabel.Text = 'Fuse Machine: N/A'
    end

    -- Daily Rewards Timer
    pcall(function()
        local scriptedMap = game:GetService('Workspace')
            :FindFirstChild('ScriptedMap')
        if scriptedMap then
            local dailys = scriptedMap:FindFirstChild('Dailys')
            if dailys then
                local dailyIsland = dailys:FindFirstChild('DailyIsland')
                if dailyIsland then
                    local dailySign = dailyIsland:FindFirstChild('DailySign')
                    if dailySign then
                        local billboardGui =
                            dailySign:FindFirstChild('BillboardGui')
                        if billboardGui then
                            local textLabel =
                                billboardGui:FindFirstChild('TextLabel')
                            if textLabel and textLabel.Text then
                                -- Extract time by removing "Daily Resets:" prefix if present
                                local timeText =
                                    textLabel.Text:gsub('^Daily Resets:%s*', '')
                                dailyRewardsLabel.Text = 'Daily Rewards Timer: '
                                    .. timeText
                            else
                                dailyRewardsLabel.Text =
                                    'Daily Rewards Timer: N/A'
                            end
                        else
                            dailyRewardsLabel.Text = 'Daily Rewards Timer: N/A'
                        end
                    else
                        dailyRewardsLabel.Text = 'Daily Rewards Timer: N/A'
                    end
                else
                    dailyRewardsLabel.Text = 'Daily Rewards Timer: N/A'
                end
            else
                dailyRewardsLabel.Text = 'Daily Rewards Timer: N/A'
            end
        else
            dailyRewardsLabel.Text = 'Daily Rewards Timer: N/A'
        end
    end)
end

function gameInfoLoop()
    while gameInfoEnabled and not unloaded do
        pcall(updateGameInfo)
        task.wait(1)
    end
end

function startGameInfoThread()
    if gameInfoThread then
        task.cancel(gameInfoThread)
    end
    gameInfoThread = task.spawn(gameInfoLoop)
end

function stopGameInfoThread()
    if gameInfoThread then
        task.cancel(gameInfoThread)
        gameInfoThread = nil
    end
end

function setupTransparencyAnimation(nv, startBT)
    bind(nv:GetPropertyChangedSignal('Value'):Connect(function()
        infoFrame.BackgroundTransparency = nv.Value
    end))
    infoFrame.BackgroundTransparency = nv.Value
    TweenService
        :Create(
            nv,
            TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Value = startBT }
        )
        :Play()
end

function setupScaleAnimation()
    if not gameInfoScaleObj then
        gameInfoScaleObj =
            New('UIScale', { Scale = gameInfoScale, Parent = infoFrame })
    end
    local targetScale = gameInfoScale * 0.95
    gameInfoScaleObj.Scale = targetScale
    TweenService
        :Create(
            gameInfoScaleObj,
            TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Scale = gameInfoScale }
        )
        :Play()
end

function cleanupNumberValue(nv)
    task.delay(0.25, function()
        pcall(function()
            nv:Destroy()
        end)
    end)
end

function animateGameInfoShow()
    if not (infoFrame and infoFrame.Parent) then
        return
    end
    local startPos = infoFrame.Position
    infoFrame.Position = startPos + UDim2.new(0, 0, 0, 30)

    -- Ensure proper transparency is set
    infoFrame.BackgroundTransparency = 0.05

    -- Simple slide up animation (respects disableAnimations setting)
    local slideTween = FX.CreateTween(
        infoFrame,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = startPos }
    )
    slideTween:Play()
end
function animateGameInfoHide()
    if not (infoFrame and infoFrame.Parent) then
        return
    end
    local startPos = infoFrame.Position
    local endPos = startPos + UDim2.new(0, 0, 0, 30)

    -- Simple slide down animation (respects disableAnimations setting)
    local positionTween = FX.CreateTween(
        infoFrame,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = endPos }
    )
    positionTween:Play()

    -- Disable GUI after animation completes (or immediately if animations disabled)
    positionTween.Completed:Connect(function()
        if gameInfoGui then
            gameInfoGui.Enabled = false
        end
    end)

    -- If animations are disabled, disable GUI immediately
    if disableAnimations then
        if gameInfoGui then
            gameInfoGui.Enabled = false
        end
    end
end

function toggleGameInfo(on)
    gameInfoEnabled = on
    if on then
        if gameInfoGui then
            gameInfoGui.Enabled = true
        end
        animateGameInfoShow()
        startGameInfoThread()
    else
        stopGameInfoThread()
        animateGameInfoHide()
    end
end
-- =============================
-- Main GUI Build
-- =============================

-- Genie Animation Effects
function Components.GenieCloseAnimation(panel, targetButton)
    if not panel then
        return
    end

    -- Ensure panel has proper background color before animation
    if
        not panel.BackgroundColor3
        or panel.BackgroundColor3 == Color3.fromRGB(255, 255, 255)
    then
        panel.BackgroundColor3 = Card
    end

    -- Get the target button position for the "sucking" effect
    local targetPos = targetButton and targetButton.AbsolutePosition
        or Vector2.new(400, 350)
    local targetSize = targetButton and targetButton.AbsoluteSize
        or Vector2.new(50, 50)

    -- Create a sequence of tweens for the genie effect
    local genieSequence = {
        -- First: Scale down and rotate slightly (like being sucked into a bottle)
        FX.CreateTween(
            panel,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {
                Size = UDim2.new(
                    0,
                    panel.AbsoluteSize.X * 0.3,
                    0,
                    panel.AbsoluteSize.Y * 0.3
                ),
                Position = UDim2.new(
                    0,
                    panel.AbsolutePosition.X + panel.AbsoluteSize.X * 0.35,
                    0,
                    panel.AbsolutePosition.Y + panel.AbsoluteSize.Y * 0.35
                ),
            }
        ),

        -- Second: Move towards target button while scaling down more
        FX.CreateTween(
            panel,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, targetPos.X - 10, 0, targetPos.Y - 10),
            }
        ),

        -- Third: Final scale to nothing and fade out
        FX.CreateTween(
            panel,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
            }
        ),
    }

    -- Also fade out the content area
    if panel:FindFirstChild('contentArea') then
        FX.CreateTween(
            panel.contentArea,
            TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {
                BackgroundTransparency = 1,
            }
        ):Play()
    end

    -- Play the sequence
    genieSequence[1]:Play()
    genieSequence[1].Completed:Connect(function()
        genieSequence[2]:Play()
        genieSequence[2].Completed:Connect(function()
            genieSequence[3]:Play()
            genieSequence[3].Completed:Connect(function()
                panel.Visible = false
                -- Reset for next time
                panel.BackgroundTransparency = 0.1
                if panel:FindFirstChild('contentArea') then
                    panel.contentArea.BackgroundTransparency = 0
                end
            end)
        end)
    end)
end

function Components.GenieOpenAnimation(panel, sourceButton, openWindows)
    if not panel then
        return
    end

    -- Ensure panel has proper background color
    panel.BackgroundColor3 = Card

    -- Get the source button position for the "emerging" effect
    local sourcePos = sourceButton and sourceButton.AbsolutePosition
        or Vector2.new(400, 350)
    local sourceSize = sourceButton and sourceButton.AbsoluteSize
        or Vector2.new(50, 50)

    -- Set initial state (emerging from the button)
    panel.Visible = true
    panel.Size = UDim2.new(0, 0, 0, 0)
    panel.Position = UDim2.new(0, sourcePos.X - 10, 0, sourcePos.Y - 10)
    panel.BackgroundTransparency = 1

    -- Calculate proper position based on window count (center or cascade)
    local windowWidth = 600
    local windowHeight = 400
    local currentOpenCount = 0
    for _, _ in pairs(openWindows or {}) do
        currentOpenCount = currentOpenCount + 1
    end

    local finalPosition
    if currentOpenCount == 0 then
        -- First window: center it, but offset based on sidebar location
        if sidebarLocation == 'Right' then
            finalPosition =
                UDim2.new(0.5, -windowWidth / 2 - 100, 0.5, -windowHeight / 2) -- Offset left to avoid sidebar
        else
            finalPosition =
                UDim2.new(0.5, -windowWidth / 2 + 100, 0.5, -windowHeight / 2) -- Offset right to avoid sidebar
        end
    else
        -- Additional windows: cascade them
        local offsetX = currentOpenCount * 30
        local offsetY = currentOpenCount * 30
        if sidebarLocation == 'Right' then
            finalPosition = UDim2.new(
                0.5,
                -windowWidth / 2 - 100 + offsetX,
                0.5,
                -windowHeight / 2 + offsetY
            )
        else
            finalPosition = UDim2.new(
                0.5,
                -windowWidth / 2 + 100 + offsetX,
                0.5,
                -windowHeight / 2 + offsetY
            )
        end
    end

    -- Create a sequence of tweens for the genie emergence effect
    local emergenceSequence = {
        -- First: Start emerging from the button (small size, transparent) - move toward center
        FX.CreateTween(
            panel,
            TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(
                    finalPosition.X.Scale,
                    finalPosition.X.Offset - 10,
                    finalPosition.Y.Scale,
                    finalPosition.Y.Offset - 10
                ),
                BackgroundTransparency = 0.8,
            }
        ),

        -- Second: Grow larger while staying centered
        FX.CreateTween(
            panel,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, 300, 0, 200),
                Position = UDim2.new(
                    finalPosition.X.Scale,
                    finalPosition.X.Offset - 50,
                    finalPosition.Y.Scale,
                    finalPosition.Y.Offset - 50
                ),
                BackgroundTransparency = 0.3,
            }
        ),

        -- Third: Final position and full opacity (already centered)
        FX.CreateTween(
            panel,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {
                Size = UDim2.new(0, windowWidth, 0, windowHeight),
                Position = finalPosition,
                BackgroundTransparency = 0.05,
            }
        ),
    }

    -- Also fade in the content area
    if panel:FindFirstChild('contentArea') then
        panel.contentArea.BackgroundTransparency = 1
        FX.CreateTween(
            panel.contentArea,
            TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 0,
            }
        ):Play()
    end

    -- Play the sequence
    emergenceSequence[1]:Play()
    emergenceSequence[1].Completed:Connect(function()
        emergenceSequence[2]:Play()
        emergenceSequence[2].Completed:Connect(function()
            emergenceSequence[3]:Play()
        end)
    end)
end

-- Content Panel Component
function Components.ContentPanel(props)
    -- Fixed size for windowed design
    local panel = New('Frame', {
        Size = UDim2.new(1, -70, 1, -10), -- Fill remaining space after sidebar
        Position = UDim2.new(0, 65, 0, 5), -- Start after collapsed sidebar
        BackgroundColor3 = Card,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = props.Parent,
        Name = props.Name or 'ContentPanel',
        ZIndex = 50,
        Visible = props.Visible or false,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 12) }),
        New('UIStroke', {
            Color = Stroke,
            Thickness = 1,
            Transparency = 0.3,
        }),
    })

    -- Panel header
    local header = New('Frame', {
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = panel,
    })

    local title = New('TextLabel', {
        Size = UDim2.new(1, -40, 0, 60),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = props.Title or 'Panel',
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        TextColor3 = Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = header,
    })

    -- Content area with scrolling
    local contentArea = New('ScrollingFrame', {
        Size = UDim2.new(1, -40, 1, -80),
        Position = UDim2.new(0, 20, 0, 70),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageTransparency = 0.5,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = panel,
    }, {
        New(
            'UIPadding',
            { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 20) }
        ),
    })

    -- Track which button opened this panel
    local sourceButton = nil

    return {
        panel = panel,
        contentArea = contentArea,
        title = title,
        show = function(button)
            sourceButton = button -- Store the button that opened this panel
            Components.GenieOpenAnimation(panel, button)
        end,
        hide = function()
            Components.GenieCloseAnimation(panel, sourceButton)
        end,
        setSourceButton = function(button)
            sourceButton = button
        end,
    }
end

-- Modern Sidebar Component
function Components.ModernSidebar(props)
    local sidebarWidth = {
        collapsed = 60, -- Just icons
        expanded = 200, -- Icons + labels
    }

    local isExpanded = false -- Start collapsed, expand on hover
    local currentTab = nil -- No tab highlighted initially
    local openWindows = props.openWindows or {} -- Access to open windows table

    -- Main sidebar container - Compact design
    local sidebar = New('Frame', {
        Size = UDim2.new(0, sidebarWidth.collapsed, 0, 490), -- Increased height to fit all elements including unload button
        Position = sidebarLocation == 'Right' and UDim2.new(1, -70, 0, 10)
            or UDim2.new(0, 10, 0, 10), -- Positioned based on sidebar location
        BackgroundColor3 = Sidebar,
        BorderSizePixel = 0,
        Parent = props.Parent,
        ZIndex = 100,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 16) }), -- Clean rounded corners
        New('UIStroke', {
            Color = Stroke,
            Thickness = 1,
            Transparency = 0.2,
        }),
        New('UIScale', { Scale = sidebarScale }), -- Add UIScale for scaling functionality
    })

    -- On mobile, force the sidebar scale to minimum without changing layout behavior
    do
        local scaleObj = sidebar:FindFirstChild('UIScale')
        if UserInputService and UserInputService.TouchEnabled and scaleObj then
            sidebarScale = 0.5
            scaleObj.Scale = 0.5
        end
    end

    -- Set the sidebar location attribute for the toggle function to use
    sidebar:SetAttribute('SidebarLocation', sidebarLocation)

    -- Sidebar header with logo/title (transparent to preserve pill rounding)
    local header = New('Frame', {
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1, -- Transparent to preserve parent rounding
        BorderSizePixel = 0,
        Parent = sidebar,
    })

    -- Logo/Brand (now acts as mobile toggle button)
    local brandIcon = New('TextButton', {
        Name = 'BrandIcon',
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = AccentA,
        Text = 'S',
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = mobileButtonEnabled,
        Parent = header,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        New('UIStroke', {
            Color = AccentA:lerp(Color3.fromRGB(255, 255, 255), 0.3),
            Thickness = 1,
            Transparency = 0.7,
        }),
    })

    -- Brand text (hidden when collapsed)
    local brandText = New('TextLabel', {
        Size = UDim2.new(1, -60, 0, 40),
        Position = UDim2.new(0, 60, 0, 10),
        BackgroundTransparency = 1,
        Text = "syso's Script",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false,
        Parent = header,
    })

    -- Navigation items container
    local navContainer = New('Frame', {
        Size = UDim2.new(1, 0, 0, 240), -- Increased height for 4 navigation items
        Position = UDim2.new(0, 0, 0, 95),
        BackgroundTransparency = 1,
        Parent = sidebar,
    })

    -- Navigation items data
    local navItems = {
        { id = 'main', icon = '⚡', label = 'Main', callback = nil },
        { id = 'alerts', icon = '🔔', label = 'Alerts', callback = nil },
        { id = 'misc', icon = '🔧', label = 'Misc', callback = nil },
        {
            id = 'settings',
            icon = '⚙️',
            label = 'Settings',
            callback = nil,
        },
    }

    -- Add Discord button above unload button
    local discordBtn = New('TextButton', {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 380), -- Moved down to accommodate new nav items
        BackgroundColor3 = Color3.fromRGB(88, 101, 242), -- Discord brand color
        BorderSizePixel = 0,
        Text = '',
        ZIndex = 50, -- Lower Z-index so unload button appears on top
        Parent = sidebar,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
    })

    -- Discord icon and label
    local discordIcon = New('TextLabel', {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = '💬', -- Discord emoji
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 102, -- Higher Z-index
        Parent = discordBtn,
    })

    local discordLabel = New('TextLabel', {
        Size = UDim2.new(1, -60, 0, 30),
        Position = UDim2.new(0, 55, 0, 5),
        BackgroundTransparency = 1,
        Text = 'Discord Server',
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255), -- Always white for maximum visibility
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false,
        ZIndex = 102, -- Higher Z-index
        Parent = discordBtn,
    })

    -- Discord button hover and click
    discordBtn.MouseEnter:Connect(function()
        TweenService:Create(
            discordBtn,
            TweenInfo.new(0.2),
            { BackgroundColor3 = Color3.fromRGB(105, 115, 255) }
        ):Play()
    end)

    discordBtn.MouseLeave:Connect(function()
        TweenService:Create(
            discordBtn,
            TweenInfo.new(0.2),
            { BackgroundColor3 = Color3.fromRGB(88, 101, 242) }
        ):Play()
    end)

    discordBtn.MouseButton1Click:Connect(function()
        -- Discord invite link
        local discordInvite = 'https://discord.gg/rBUktpykV8'

        -- Try to copy to clipboard using different methods
        local copied = false

        -- Method 1: Try setclipboard function (common in executors)
        pcall(function()
            if setclipboard then
                setclipboard(discordInvite)
                copied = true
            end
        end)

        -- Method 2: Try writeclipboard function
        if not copied then
            pcall(function()
                if writeclipboard then
                    writeclipboard(discordInvite)
                    copied = true
                end
            end)
        end

        -- Method 3: Try clipboard service
        if not copied then
            pcall(function()
                if game:GetService('HttpService').JSONEncode then
                    -- Some executors have clipboard functions
                    if setclipboard then
                        setclipboard(discordInvite)
                        copied = true
                    end
                end
            end)
        end

        -- Show toast message
        if copied then
            showToast('Discord Server', 'Link copied to clipboard!', 3)
        else
            showToast('Discord Server', 'Failed to copy link', 3)
        end
    end)

    -- Add unload button at bottom
    local unloadBtn = New('TextButton', {
        Size = UDim2.new(1, -20, 0, 40), -- Clean size
        Position = UDim2.new(0, 10, 0, 430), -- Positioned under Discord button (380 + 40 + 10 gap)
        BackgroundColor3 = Danger,
        BorderSizePixel = 0,
        Text = '',
        Parent = sidebar,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
    })

    -- Function to update unload button position based on scale
    local function updateUnloadButtonPosition(scale)
        if unloadBtn then
            -- For compact sidebar, keep unload button at fixed position under Discord button
            unloadBtn.Position = UDim2.new(0, 10, 0, 430)
        end
    end

    -- Unload icon and label (consistent with nav items)
    local unloadIcon = New('TextLabel', {
        Size = UDim2.new(0, 40, 0, 40), -- Full button size for perfect centering
        Position = UDim2.new(0, 0, 0, 0), -- Fill entire button
        BackgroundTransparency = 1,
        Text = '🚪',
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 90, 90),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = unloadBtn,
    })

    local unloadLabel = New('TextLabel', {
        Size = UDim2.new(1, -60, 0, 30),
        Position = UDim2.new(0, 55, 0, 5), -- Centered vertically in 40px button
        BackgroundTransparency = 1,
        Text = 'Unload Script',
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255), -- White for visibility against dark background
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false,
        Parent = unloadBtn,
    })

    -- Unload button hover and click
    unloadBtn.MouseEnter:Connect(function()
        local currentTheme = themes[theme] or themes.dark
        local hoverColor =
            currentTheme.Danger:lerp(Color3.fromRGB(0, 0, 0), 0.2) -- Darker version of danger color
        TweenService:Create(
            unloadBtn,
            TweenInfo.new(0.2),
            { BackgroundColor3 = hoverColor }
        ):Play()
    end)

    unloadBtn.MouseLeave:Connect(function()
        local currentTheme = themes[theme] or themes.dark
        local normalColor = currentTheme.Danger
        TweenService:Create(
            unloadBtn,
            TweenInfo.new(0.2),
            { BackgroundColor3 = normalColor }
        ):Play()
    end)

    unloadBtn.MouseButton1Click:Connect(function()
        -- Show unload confirmation dialog
        showUnloadConfirm()
    end)

    local navButtons = {}

    -- Create navigation items
    for i, item in ipairs(navItems) do
        local navItem = New('TextButton', {
            Size = UDim2.new(1, -10, 0, 60),
            Position = UDim2.new(0, 5, 0, (i - 1) * 65),
            BackgroundColor3 = (item.id == currentTab) and SidebarActive
                or Sidebar,
            BorderSizePixel = 0,
            Text = '',
            Parent = navContainer,
        }, {
            New('UICorner', { CornerRadius = UDim.new(0, 8) }),
        })

        -- Icon (truly centered for pill shape)
        local icon = New('TextLabel', {
            Size = UDim2.new(0, 50, 0, 30), -- Full width when collapsed for perfect centering
            Position = UDim2.new(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Text = item.icon,
            Font = Enum.Font.Gotham,
            TextSize = 18,
            TextColor3 = (item.id == currentTab) and Text or Muted,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = navItem,
        })

        -- Label (hidden when collapsed)
        local label = New('TextLabel', {
            Size = UDim2.new(1, -65, 0, 30), -- Adjusted size for new icon position
            Position = UDim2.new(0, 60, 0, 15), -- Adjusted for new icon position
            BackgroundTransparency = 1,
            Text = item.label,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = (item.id == currentTab) and Text or Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Visible = false,
            Parent = navItem,
        })

        navButtons[item.id] =
            { button = navItem, icon = icon, label = label, data = item }

        -- Hover effects
        bind(navItem.MouseEnter:Connect(function()
            if item and item.id then
                pcall(function()
                    -- Always apply size and text effects
                    -- Increase size slightly
                    TweenService:Create(
                        navItem,
                        TweenInfo.new(0.2),
                        { Size = UDim2.new(1, -10, 0, 60) }
                    ):Play()

                    -- Increase icon size
                    if navItem.icon then
                        TweenService
                            :Create(
                                navItem.icon,
                                TweenInfo.new(0.2),
                                { Size = UDim2.new(0, 30, 0, 30) }
                            )
                            :Play()
                    end

                    -- Increase text size
                    if navItem.label then
                        TweenService
                            :Create(
                                navItem.label,
                                TweenInfo.new(0.2),
                                { TextSize = 18 }
                            )
                            :Play()
                    end

                    -- Always show hover color when hovering - check current background color to determine state
                    local currentColor = navItem.BackgroundColor3
                    local isCurrentlyActive = (currentColor == SidebarActive)

                    if isCurrentlyActive then
                        -- Active tab: light blue hover
                        TweenService
                            :Create(navItem, TweenInfo.new(0.2), {
                                BackgroundColor3 = Color3.fromRGB(
                                    100,
                                    150,
                                    255
                                ),
                            })
                            :Play()
                    else
                        -- Inactive tab: grey hover
                        TweenService
                            :Create(navItem, TweenInfo.new(0.2), {
                                BackgroundColor3 = Color3.fromRGB(
                                    100,
                                    100,
                                    100
                                ),
                            })
                            :Play()
                    end
                end)
            end
        end))

        bind(navItem.MouseLeave:Connect(function()
            if item and item.id then
                pcall(function()
                    -- Always reset size and text effects
                    -- Reset size
                    TweenService:Create(
                        navItem,
                        TweenInfo.new(0.2),
                        { Size = UDim2.new(1, -10, 0, 60) }
                    ):Play()

                    -- Reset icon size
                    if navItem.icon then
                        TweenService
                            :Create(
                                navItem.icon,
                                TweenInfo.new(0.2),
                                { Size = UDim2.new(0, 20, 0, 20) }
                            )
                            :Play()
                    end

                    -- Reset text size
                    if navItem.label then
                        TweenService
                            :Create(
                                navItem.label,
                                TweenInfo.new(0.2),
                                { TextSize = 14 }
                            )
                            :Play()
                    end

                    -- Reset background color to original state - check what the original color should be
                    local originalColor = (item.id == currentTab)
                            and SidebarActive
                        or Sidebar
                    TweenService:Create(
                        navItem,
                        TweenInfo.new(0.2),
                        { BackgroundColor3 = originalColor }
                    ):Play()
                end)
            end
        end))

        -- Click handler
        bind(navItem.MouseButton1Click:Connect(function()
            if item and item.callback then
                pcall(item.callback, item.id)
            end
        end))
    end
    -- Toggle sidebar function (for hover expansion)
    function toggleSidebar()
        isExpanded = not isExpanded
        local forcedCollapsed = isSmallViewport()
        local targetWidth = forcedCollapsed and sidebarWidth.collapsed
            or (isExpanded and sidebarWidth.expanded or sidebarWidth.collapsed)

        -- Get current sidebar scale
        local sidebarScale = 1.0
        local scaleObj = sidebar:FindFirstChild('UIScale')
        if scaleObj then
            sidebarScale = scaleObj.Scale
        end

        -- Calculate actual sidebar width with scale
        local actualSidebarWidth = targetWidth * sidebarScale

        -- Compact sidebar dimensions
        local targetSize = UDim2.new(
            0,
            targetWidth,
            0,
            isSmallViewport()
                    and math.min(
                        490,
                        Workspace.CurrentCamera
                                and Workspace.CurrentCamera.ViewportSize.Y - 20
                            or 490
                    )
                or 490
        )
        local currentLocation = sidebar:GetAttribute('SidebarLocation')
            or sidebarLocation
        local targetPosition = currentLocation == 'Right'
                and UDim2.new(1, -targetWidth - 10, 0, 10)
            or UDim2.new(0, 10, 0, 10)

        -- Animate sidebar width with smooth effect (or set immediately if animations disabled)
        if disableAnimations or isSmallViewport() then
            sidebar.Size = targetSize
            sidebar.Position = targetPosition
        else
            TweenService:Create(
                sidebar,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = targetSize,
                    Position = targetPosition,
                }
            ):Play()
        end

        -- Move any fullscreen windows to make room for sidebar
        for windowType, window in pairs(openWindows or {}) do
            if window and window.Parent then
                -- Check if this window is currently fullscreen by looking at its size
                local windowSize = window.Size
                local screenSize = Workspace.CurrentCamera.ViewportSize

                -- More accurate fullscreen detection - check if window is using most of the screen width
                local isFullscreen = false
                if windowSize.X.Scale == 1 and windowSize.X.Offset < -50 then
                    -- Window is using scale-based sizing and has negative offset (indicating it's sized to fill screen minus some space)
                    isFullscreen = true
                elseif windowSize.X.Offset > screenSize.X * 0.7 then
                    -- Window is using absolute sizing and is wider than 70% of screen
                    isFullscreen = true
                end

                if isFullscreen then
                    -- Calculate new fullscreen size and position based on sidebar location
                    local newFullscreenSize =
                        UDim2.new(1, -actualSidebarWidth - 10, 1, -10)
                    local currentLocation = sidebar:GetAttribute(
                        'SidebarLocation'
                    ) or sidebarLocation
                    local newFullscreenPosition
                    if currentLocation == 'Right' then
                        newFullscreenPosition = UDim2.new(0, 5, 0, 5) -- Left side of screen
                    else
                        newFullscreenPosition =
                            UDim2.new(0, actualSidebarWidth + 5, 0, 5) -- Right side of sidebar
                    end

                    -- Animate to new fullscreen size
                    TweenService
                        :Create(
                            window,
                            TweenInfo.new(
                                0.3,
                                Enum.EasingStyle.Quad,
                                Enum.EasingDirection.Out
                            ),
                            {
                                Size = newFullscreenSize,
                                Position = newFullscreenPosition,
                            }
                        )
                        :Play()
                end
            end
        end

        -- Animate content panels to adjust for sidebar width within window
        for _, panel in pairs(panels or {}) do
            if panel and panel.panel then
                local sidebarWidth = isExpanded and 240 or 60
                local newPanelPos = sidebarWidth + 5 -- Small gap after sidebar
                local windowWidth = 800 -- Fixed window width
                local newPanelWidth = windowWidth - sidebarWidth - 10 -- Fill remaining space

                TweenService
                    :Create(
                        panel.panel,
                        TweenInfo.new(
                            0.4,
                            Enum.EasingStyle.Back,
                            Enum.EasingDirection.Out
                        ),
                        {
                            Size = UDim2.new(0, newPanelWidth, 1, -10),
                            Position = UDim2.new(0, newPanelPos, 0, 5),
                        }
                    )
                    :Play()
            end
        end

        -- Handle text visibility
        if isExpanded and not isSmallViewport() then
            -- Show text with delay for smooth effect
            task.delay(0.2, function()
                if isExpanded and not isSmallViewport() then -- Double check still expanded and not mobile
                    brandText.Visible = true
                    unloadLabel.Visible = true
                    discordLabel.Visible = true
                    for _, nav in pairs(navButtons) do
                        if nav and nav.label then
                            nav.label.Visible = true
                        end
                    end
                end
            end)
        else
            -- Hide text elements immediately when collapsing
            brandText.Visible = false
            unloadLabel.Visible = false
            discordLabel.Visible = false
            for _, nav in pairs(navButtons) do
                if nav and nav.label then
                    nav.label.Visible = false
                end
            end

            -- Also hide text after a short delay to catch any race conditions
            task.delay(0.1, function()
                if not isExpanded then
                    brandText.Visible = false
                    unloadLabel.Visible = false
                    discordLabel.Visible = false
                    for _, nav in pairs(navButtons) do
                        if nav and nav.label then
                            nav.label.Visible = false
                        end
                    end
                end
            end)
        end

        -- Update sidebar background color
        TweenService
            :Create(sidebar, TweenInfo.new(0.3), {
                BackgroundColor3 = (isExpanded and not isSmallViewport())
                        and SidebarExpanded
                    or Sidebar,
            })
            :Play()
    end

    -- Set active tab function
    local activeTabs = {} -- Track multiple active tabs

    function updateTabVisuals()
        if not navButtons or not activeTabs then
            return
        end -- Safety check
        for id, btn in pairs(navButtons) do
            if btn and btn.button and btn.icon and btn.label then
                local isActive = activeTabs[id]
                local bgColor, textColor

                if isActive then
                    -- Active tab color based on theme
                    if theme == 'light' then
                        bgColor = Color3.fromRGB(0, 120, 255) -- Blue for light mode
                        textColor = Color3.fromRGB(255, 255, 255) -- White text
                    else
                        bgColor = ActiveTab -- Default active color for dark mode
                        textColor = Color3.fromRGB(255, 255, 255) -- White text
                    end
                else
                    -- Inactive tab color based on theme
                    if theme == 'light' then
                        bgColor = Color3.fromRGB(200, 200, 200) -- Grey for light mode
                        textColor = Color3.fromRGB(20, 25, 30) -- Dark text
                    else
                        bgColor = Sidebar -- Keep inactive tabs black
                        textColor = Muted -- Dimmed text for inactive tabs
                    end
                end

                pcall(function()
                    TweenService:Create(
                        btn.button,
                        TweenInfo.new(0.2),
                        { BackgroundColor3 = bgColor }
                    ):Play()
                    TweenService:Create(
                        btn.icon,
                        TweenInfo.new(0.2),
                        { TextColor3 = textColor }
                    ):Play()
                    TweenService:Create(
                        btn.label,
                        TweenInfo.new(0.2),
                        { TextColor3 = textColor }
                    ):Play()
                end)
            end
        end
    end
    function setActiveTab(tabId)
        if activeTabs and tabId then
            activeTabs[tabId] = true
            updateTabVisuals()
        end
    end

    function clearActiveTab(tabId)
        if activeTabs and tabId then
            activeTabs[tabId] = nil
            updateTabVisuals()
        end
    end

    -- S button click handler for mobile toggle (works like Alt key but keeps S button visible)
    bind(brandIcon.MouseButton1Click:Connect(function()
        -- Check if mobile button is enabled
        if not mobileButtonEnabled then
            return
        end

        -- Get the main GUI and sidebar container from the global scope
        local mainGui = CoreGui:FindFirstChild(existingGuiName)
        local sidebarContainer =
            CoreGui:FindFirstChild(existingGuiName .. '_Sidebar')

        if mainGui and sidebarContainer then
            -- Check if GUI is currently visible
            local guiVisible = mainGui.Enabled

            if guiVisible then
                -- Hide main GUI with pop-out animation (like Alt key)
                closeAllDropdowns()

                -- Animate all open windows with pop-out effect before hiding GUI
                if openWindows then
                    local animationCount = 0
                    local totalWindows = 0

                    -- Count total windows to animate
                    for windowType, window in pairs(openWindows) do
                        if window and window.Parent then
                            totalWindows = totalWindows + 1
                        end
                    end

                    if totalWindows > 0 then
                        -- Animate each window
                        for windowType, window in pairs(openWindows) do
                            if window and window.Parent then
                                -- Create a smooth pop-out animation
                                local popOutTween = FX.CreateTween(
                                    window,
                                    TweenInfo.new(
                                        0.3,
                                        Enum.EasingStyle.Back,
                                        Enum.EasingDirection.In
                                    ),
                                    {
                                        Size = UDim2.new(0, 0, 0, 0),
                                        Position = UDim2.new(0.5, 0, 0.5, 0),
                                        BackgroundTransparency = 1,
                                    }
                                )

                                popOutTween:Play()
                                animationCount = animationCount + 1

                                -- Hide content after a short delay to sync with animation (or immediately if animations disabled)
                                if disableAnimations then
                                    -- Hide content immediately if animations are disabled
                                    for _, child in pairs(window:GetChildren()) do
                                        if
                                            child:IsA('GuiObject')
                                            and child.Name ~= 'UICorner'
                                            and child.Name ~= 'UIStroke'
                                        then
                                            child.Visible = false
                                        end
                                    end
                                else
                                    -- Hide content after a short delay to sync with animation
                                    spawn(function()
                                        wait(0.1) -- Small delay to let animation start
                                        for _, child in
                                            pairs(window:GetChildren())
                                        do
                                            if
                                                child:IsA('GuiObject')
                                                and child.Name ~= 'UICorner'
                                                and child.Name ~= 'UIStroke'
                                            then
                                                child.Visible = false
                                            end
                                        end
                                    end)
                                end
                            end
                        end

                        -- Wait for animation to complete before hiding GUI
                        spawn(function()
                            wait(0.3) -- Wait for pop-out animation to complete
                            mainGui.Enabled = false
                            FX.TweenBlur(false)
                        end)
                    else
                        -- No windows to animate, hide GUI immediately
                        mainGui.Enabled = false
                        FX.TweenBlur(false)
                    end
                else
                    -- No openWindows table, hide GUI immediately
                    mainGui.Enabled = false
                    FX.TweenBlur(false)
                end

                -- Small delay to ensure GUI is fully hidden before creating minimal sidebar
                task.delay(0.1, function()
                    -- Create a completely separate minimal S button as its own ScreenGui
                    local minimalSidebarGui = New('ScreenGui', {
                        Name = existingGuiName .. '_MinimalSidebar',
                        ResetOnSpawn = false,
                        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                        DisplayOrder = 1000, -- Ensure it's on top of other GUIs
                        Parent = CoreGui, -- Explicitly set parent
                    })

                    local minimalSidebar = New('Frame', {
                        Size = UDim2.new(0, 60, 0, 60),
                        Position = sidebarLocation == 'Right'
                                and UDim2.new(1, -70, 0, 10)
                            or UDim2.new(0, 10, 0, 10),
                        BackgroundColor3 = Sidebar,
                        BorderSizePixel = 0,
                        Parent = minimalSidebarGui,
                        ZIndex = 1000, -- Much higher Z-index to ensure it's on top
                        BackgroundTransparency = 0, -- Start visible
                    }, {
                        New('UICorner', { CornerRadius = UDim.new(0, 16) }),
                        New('UIStroke', {
                            Color = Stroke,
                            Thickness = 1,
                            Transparency = 0.2,
                        }),
                    })

                    -- Create minimal S button
                    local minimalSButton = New('TextButton', {
                        Size = UDim2.new(0, 40, 0, 40),
                        Position = UDim2.new(0, 10, 0, 10),
                        BackgroundColor3 = AccentA,
                        Text = 'S',
                        Font = Enum.Font.GothamBold,
                        TextSize = 20,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        Parent = minimalSidebar,
                    }, {
                        New('UICorner', { CornerRadius = UDim.new(0, 8) }),
                        New('UIStroke', {
                            Color = AccentA:lerp(
                                Color3.fromRGB(255, 255, 255),
                                0.3
                            ),
                            Thickness = 1,
                            Transparency = 0.7,
                        }),
                    })

                    -- Animate the original sidebar closing (slide out based on position)
                    local currentPos = sidebar.Position
                    local currentLocation = sidebar:GetAttribute(
                        'SidebarLocation'
                    ) or sidebarLocation
                    local slideOutPos
                    if currentLocation == 'Right' then
                        slideOutPos = UDim2.new(
                            1,
                            20,
                            currentPos.Y.Scale,
                            currentPos.Y.Offset
                        ) -- Slide out to the right
                    else
                        slideOutPos = UDim2.new(
                            0,
                            -sidebar.AbsoluteSize.X - 20,
                            currentPos.Y.Scale,
                            currentPos.Y.Offset
                        ) -- Slide out to the left
                    end

                    local slideOutTween = FX.CreateTween(
                        sidebar,
                        TweenInfo.new(
                            0.3,
                            Enum.EasingStyle.Quad,
                            Enum.EasingDirection.Out
                        ),
                        {
                            Position = slideOutPos,
                        }
                    )

                    slideOutTween:Play()

                    -- After animation completes, hide the sidebar
                    slideOutTween.Completed:Connect(function()
                        sidebar.Visible = false
                    end)

                    -- Click handler to restore everything
                    bind(minimalSButton.MouseButton1Click:Connect(function()
                        -- Immediately restore main GUI and sidebar before animations
                        mainGui.Enabled = true
                        sidebar.Visible = true
                        FX.TweenBlur(true)

                        -- Restore all open windows with pop-in animation
                        if openWindows then
                            for windowType, window in pairs(openWindows) do
                                if window and window.Parent then
                                    -- Make sure window is visible
                                    window.Visible = true

                                    -- Get the target size and position
                                    local targetSize = window:GetAttribute(
                                        'OriginalSize'
                                    ) or UDim2.new(
                                        0,
                                        600,
                                        0,
                                        400
                                    )
                                    local targetPosition = window:GetAttribute(
                                        'CurrentPosition'
                                    ) or window:GetAttribute(
                                        'OriginalPosition'
                                    ) or UDim2.new(
                                        0.5,
                                        -300,
                                        0.5,
                                        -200
                                    )

                                    -- Set initial state for pop-in animation
                                    window.Size = UDim2.new(0, 0, 0, 0)
                                    window.Position = UDim2.new(0.5, 0, 0.5, 0)
                                    window.BackgroundTransparency = 1

                                    -- Restore main content areas only
                                    for _, child in pairs(window:GetChildren()) do
                                        if
                                            child:IsA('GuiObject')
                                            and child.Name ~= 'UICorner'
                                            and child.Name ~= 'UIStroke'
                                        then
                                            child.Visible = true
                                            -- Only reset transparency for elements that should have backgrounds
                                            if
                                                child:IsA('Frame')
                                                and child.Name
                                                    == 'contentArea'
                                            then
                                                child.BackgroundTransparency = 0
                                            elseif
                                                child:IsA('TextButton')
                                                or child:IsA('TextLabel')
                                            then
                                                -- Don't reset transparency for text elements to avoid white backgrounds
                                                if
                                                    child.BackgroundTransparency
                                                    ~= 1
                                                then
                                                    child.BackgroundTransparency =
                                                        0
                                                end
                                            end
                                        end
                                    end

                                    -- Ensure content area is properly restored
                                    local contentArea =
                                        window:FindFirstChild('contentArea')
                                    if contentArea then
                                        contentArea.Visible = true
                                        contentArea.BackgroundTransparency = 0
                                        contentArea.BackgroundColor3 = Surface
                                    end

                                    -- Animate window popping back in
                                    local popInTween = FX.CreateTween(
                                        window,
                                        TweenInfo.new(
                                            0.3,
                                            Enum.EasingStyle.Back,
                                            Enum.EasingDirection.Out
                                        ),
                                        {
                                            Size = targetSize,
                                            Position = targetPosition,
                                            BackgroundTransparency = 0,
                                        }
                                    )

                                    popInTween:Play()
                                end
                            end
                        end

                        -- Animate sidebar sliding back in from off-screen
                        local currentLocation = sidebar:GetAttribute(
                            'SidebarLocation'
                        ) or sidebarLocation
                        local targetPos = currentLocation == 'Right'
                                and UDim2.new(1, -70, 0, 10)
                            or UDim2.new(0, 10, 0, 10)
                        local startPos
                        if currentLocation == 'Right' then
                            startPos = UDim2.new(1, 20, 0, 10) -- Start off-screen to the right
                        else
                            startPos = UDim2.new(
                                0,
                                -sidebar.AbsoluteSize.X - 20,
                                0,
                                10
                            ) -- Start off-screen to the left
                        end
                        sidebar.Position = startPos

                        FX.CreateTween(
                            sidebar,
                            TweenInfo.new(
                                0.3,
                                Enum.EasingStyle.Quad,
                                Enum.EasingDirection.Out
                            ),
                            {
                                Position = targetPos,
                            }
                        ):Play()

                        -- Fade out and remove minimal sidebar
                        local fadeOutTween = FX.CreateTween(
                            minimalSidebar,
                            TweenInfo.new(
                                0.2,
                                Enum.EasingStyle.Quad,
                                Enum.EasingDirection.In
                            ),
                            {
                                BackgroundTransparency = 1,
                            }
                        )

                        fadeOutTween:Play()
                        fadeOutTween.Completed:Connect(function()
                            -- Remove minimal sidebar after fade completes
                            if
                                minimalSidebarGui and minimalSidebarGui.Parent
                            then
                                minimalSidebarGui:Destroy()
                            end
                        end)
                    end))

                    -- Hover effects for minimal S button
                    minimalSButton.MouseEnter:Connect(function()
                        FX.CreateTween(
                            minimalSButton,
                            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                            {
                                Size = UDim2.new(0, 42, 0, 42),
                                Position = UDim2.new(0, 9, 0, 9),
                            }
                        ):Play()
                        local stroke = minimalSButton:FindFirstChild('UIStroke')
                        if stroke then
                            FX.CreateTween(
                                stroke,
                                TweenInfo.new(0.2),
                                { Transparency = 0.4 }
                            )
                                :Play()
                        end
                    end)

                    minimalSButton.MouseLeave:Connect(function()
                        FX.CreateTween(
                            minimalSButton,
                            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                            {
                                Size = UDim2.new(0, 40, 0, 40),
                                Position = UDim2.new(0, 10, 0, 10),
                            }
                        ):Play()
                        local stroke = minimalSButton:FindFirstChild('UIStroke')
                        if stroke then
                            FX.CreateTween(
                                stroke,
                                TweenInfo.new(0.2),
                                { Transparency = 0.7 }
                            )
                                :Play()
                        end
                    end)
                end) -- Close the task.delay function
            else
                -- GUI is already hidden, check if minimal sidebar exists and restore GUI
                local existingMinimalSidebar =
                    CoreGui:FindFirstChild(existingGuiName .. '_MinimalSidebar')
                if existingMinimalSidebar then
                    -- Restore main GUI and sidebar
                    mainGui.Enabled = true
                    sidebar.Visible = true
                    FX.TweenBlur(true)

                    -- Animate sidebar sliding back in from off-screen
                    local currentLocation = sidebar:GetAttribute(
                        'SidebarLocation'
                    ) or sidebarLocation
                    local targetPos = currentLocation == 'Right'
                            and UDim2.new(1, -70, 0, 10)
                        or UDim2.new(0, 10, 0, 10)
                    local startPos
                    if currentLocation == 'Right' then
                        startPos = UDim2.new(1, 20, 0, 10) -- Start off-screen to the right
                    else
                        startPos =
                            UDim2.new(0, -sidebar.AbsoluteSize.X - 20, 0, 10) -- Start off-screen to the left
                    end
                    sidebar.Position = startPos

                    FX.CreateTween(
                        sidebar,
                        TweenInfo.new(
                            0.3,
                            Enum.EasingStyle.Quad,
                            Enum.EasingDirection.Out
                        ),
                        {
                            Position = targetPos,
                        }
                    ):Play()

                    -- Show all open windows when GUI is reopened with pop-in animation
                    if openWindows then
                        for windowType, window in pairs(openWindows) do
                            if window and window.Parent then
                                -- Make sure window is visible
                                window.Visible = true

                                -- Get the target size and position
                                local targetSize = window:GetAttribute(
                                    'OriginalSize'
                                ) or UDim2.new(
                                    0,
                                    600,
                                    0,
                                    400
                                )
                                local targetPosition = window:GetAttribute(
                                    'CurrentPosition'
                                ) or window:GetAttribute(
                                    'OriginalPosition'
                                ) or UDim2.new(
                                    0.5,
                                    -300,
                                    0.5,
                                    -200
                                )

                                -- Set initial state for pop-in animation
                                window.Size = UDim2.new(0, 0, 0, 0)
                                window.Position = UDim2.new(0.5, 0, 0.5, 0)
                                window.BackgroundTransparency = 1

                                -- Restore main content areas only
                                for _, child in pairs(window:GetChildren()) do
                                    if
                                        child:IsA('GuiObject')
                                        and child.Name ~= 'UICorner'
                                        and child.Name ~= 'UIStroke'
                                    then
                                        child.Visible = true
                                        -- Only reset transparency for elements that should have backgrounds
                                        if
                                            child:IsA('Frame')
                                            and child.Name == 'contentArea'
                                        then
                                            child.BackgroundTransparency = 0
                                        elseif
                                            child:IsA('TextButton')
                                            or child:IsA('TextLabel')
                                        then
                                            -- Don't reset transparency for text elements to avoid white backgrounds
                                            if
                                                child.BackgroundTransparency
                                                ~= 1
                                            then
                                                child.BackgroundTransparency = 0
                                            end
                                        end
                                    end
                                end

                                -- Ensure content area is properly restored
                                local contentArea =
                                    window:FindFirstChild('contentArea')
                                if contentArea then
                                    contentArea.Visible = true
                                    contentArea.BackgroundTransparency = 0
                                    contentArea.BackgroundColor3 = Surface
                                end

                                -- Animate window popping back in
                                local popInTween = FX.CreateTween(
                                    window,
                                    TweenInfo.new(
                                        0.3,
                                        Enum.EasingStyle.Back,
                                        Enum.EasingDirection.Out
                                    ),
                                    {
                                        Size = targetSize,
                                        Position = targetPosition,
                                        BackgroundTransparency = 0,
                                    }
                                )

                                popInTween:Play()
                            end
                        end
                    end

                    -- Remove minimal sidebar
                    existingMinimalSidebar:Destroy()
                end
            end
        end
    end))

    -- Logo hover effects
    brandIcon.MouseEnter:Connect(function()
        TweenService
            :Create(brandIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 42, 0, 42),
                Position = UDim2.new(0, 9, 0, 9),
            })
            :Play()
        local stroke = brandIcon:FindFirstChild('UIStroke')
        if stroke then
            TweenService
                :Create(stroke, TweenInfo.new(0.2), { Transparency = 0.4 })
                :Play()
        end
    end)

    brandIcon.MouseLeave:Connect(function()
        TweenService
            :Create(brandIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 40, 0, 40),
                Position = UDim2.new(0, 10, 0, 10),
            })
            :Play()
        local stroke = brandIcon:FindFirstChild('UIStroke')
        if stroke then
            TweenService
                :Create(stroke, TweenInfo.new(0.2), { Transparency = 0.7 })
                :Play()
        end
    end)

    -- Subtle breathing animation for logo
    task.spawn(function()
        while sidebar and sidebar.Parent do
            local breatheTween = TweenService:Create(
                brandIcon,
                TweenInfo.new(
                    2,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut,
                    -1,
                    true
                ),
                {
                    BackgroundColor3 = AccentA:lerp(AccentB, 0.3),
                }
            )
            breatheTween:Play()
            task.wait(4) -- Wait for one complete cycle
        end
    end)

    -- Hover-based sidebar expansion with debounce
    local hoverDebounce = false
    local hideTextTask = nil

    sidebar.MouseEnter:Connect(function()
        if not isExpanded then
            -- Cancel any pending text hiding
            if hideTextTask then
                task.cancel(hideTextTask)
                hideTextTask = nil
            end
            -- Expand immediately without delay
            if not isSmallViewport() then
                toggleSidebar()
            end
        end
    end)

    sidebar.MouseLeave:Connect(function()
        if isExpanded and not isSmallViewport() then
            -- Collapse unless "Keep sidebar open" is enabled
            if not keepSidebarOpen then
                toggleSidebar()
            end
        end
    end)

    return {
        sidebar = sidebar,
        isExpanded = isExpanded,
        brandText = brandText,
        unloadLabel = unloadLabel,
        navButtons = navButtons,
        setActiveTab = setActiveTab,
        clearActiveTab = clearActiveTab,
        toggleSidebar = toggleSidebar,
        setTabCallback = function(tabId, callback)
            if navButtons and navButtons[tabId] and navButtons[tabId].data then
                navButtons[tabId].data.callback = callback
            end
        end,
        resetSidebar = function()
            -- Reset sidebar to collapsed state based on current location
            isExpanded = false
            local currentLocation = sidebar:GetAttribute('SidebarLocation')
                or sidebarLocation
            local targetPos = currentLocation == 'Right'
                    and UDim2.new(1, -70, 0, 10)
                or UDim2.new(0, 10, 0, 10)
            sidebar.Position = targetPos
            sidebar.Size = UDim2.new(0, sidebarWidth.collapsed, 0, 490)
            brandText.Visible = false
            unloadLabel.Visible = false
            navContainer.Visible = true
            unloadBtn.Visible = true
            for _, nav in pairs(navButtons) do
                nav.label.Visible = false
            end
        end,
        setPanels = function(panelList)
            panels = panelList
        end,
        updateUnloadButtonPosition = updateUnloadButtonPosition,
        setOffScreenPosition = function()
            -- Set sidebar to off-screen position for animation based on current location
            if sidebar then
                local currentLocation = sidebar:GetAttribute('SidebarLocation')
                    or sidebarLocation
                -- Get current scale to calculate proper off-screen position
                local scaleObj = sidebar:FindFirstChild('UIScale')
                local scale = scaleObj and scaleObj.Scale or 1.0
                local scaledWidth = sidebarWidth.collapsed * scale

                if currentLocation == 'Right' then
                    sidebar.Position = UDim2.new(1, 20, 0, 10) -- Off-screen to the right
                else
                    sidebar.Position = UDim2.new(0, -scaledWidth - 20, 0, 10) -- Off-screen to the left
                end

                sidebar.Size = UDim2.new(0, sidebarWidth.collapsed, 0, 490)
                isExpanded = false
                -- Ensure all elements are visible when off-screen
                navContainer.Visible = true
                unloadBtn.Visible = true
            end
        end,
        closeSidebar = function()
            -- Close sidebar if it's expanded
            if isExpanded then
                toggleSidebar()
            end
        end,
        animateSlideOut = function()
            -- Animate sidebar sliding out based on current location
            if sidebar then
                local currentPos = sidebar.Position
                local currentLocation = sidebar:GetAttribute('SidebarLocation')
                    or sidebarLocation
                -- Get current scale to calculate proper off-screen position
                local scaleObj = sidebar:FindFirstChild('UIScale')
                local scale = scaleObj and scaleObj.Scale or 1.0
                local scaledWidth = sidebarWidth.collapsed * scale

                local slideOutPos
                if currentLocation == 'Right' then
                    slideOutPos = UDim2.new(
                        1,
                        20,
                        currentPos.Y.Scale,
                        currentPos.Y.Offset
                    ) -- Slide out to the right
                else
                    slideOutPos = UDim2.new(
                        0,
                        -scaledWidth - 20,
                        currentPos.Y.Scale,
                        currentPos.Y.Offset
                    ) -- Slide to the left
                end

                if disableAnimations then
                    -- Set position immediately if animations are disabled
                    sidebar.Position = slideOutPos
                else
                    -- Animate position with smooth easing
                    TweenService
                        :Create(
                            sidebar,
                            TweenInfo.new(
                                0.4,
                                Enum.EasingStyle.Quad,
                                Enum.EasingDirection.Out
                            ),
                            {
                                Position = slideOutPos,
                            }
                        )
                        :Play()
                end
            end
        end,
        animateSlideIn = function()
            -- Animate sidebar sliding back in based on current location
            if sidebar then
                local currentLocation = sidebar:GetAttribute('SidebarLocation')
                    or sidebarLocation
                local targetPos = currentLocation == 'Right'
                        and UDim2.new(1, -70, 0, 10)
                    or UDim2.new(0, 10, 0, 10)

                if disableAnimations then
                    -- Set position immediately if animations are disabled
                    sidebar.Position = targetPos
                else
                    -- Sidebar should already be in off-screen position from setOffScreenPosition
                    -- Just animate to original position with bounce effect
                    TweenService
                        :Create(
                            sidebar,
                            TweenInfo.new(
                                0.5,
                                Enum.EasingStyle.Back,
                                Enum.EasingDirection.Out
                            ),
                            {
                                Position = targetPos,
                            }
                        )
                        :Play()
                end

                -- Hide expanded elements
                brandText.Visible = false
                unloadLabel.Visible = false
                if navButtons then
                    for _, nav in pairs(navButtons) do
                        if nav and nav.label then
                            nav.label.Visible = false
                        end
                    end
                end
            end
        end,
        updateTheme = function()
            -- Get current theme colors directly from themes table
            local currentTheme = themes[theme] or themes.dark
            local currentSidebar = currentTheme.Sidebar
            local currentSidebarActive = currentTheme.SidebarActive
            local currentMuted = currentTheme.Muted
            local currentText = currentTheme.Text
            local currentDanger = currentTheme.Danger
            local currentAccentA = currentTheme.AccentA

            -- Update sidebar colors when theme changes
            if sidebar then
                sidebar.BackgroundColor3 = currentSidebar
            end

            -- Update navigation buttons
            for _, nav in pairs(navButtons or {}) do
                if nav and nav.button then
                    if activeTabs[nav.data.id] then
                        -- Active tab color based on theme
                        nav.button.BackgroundColor3 = currentSidebarActive
                        if nav.icon then
                            nav.icon.TextColor3 = Color3.fromRGB(255, 255, 255)
                        end
                        if nav.label then
                            nav.label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        end
                    else
                        -- Inactive tab color based on theme
                        nav.button.BackgroundColor3 = currentSidebar
                        if nav.icon then
                            nav.icon.TextColor3 = currentMuted
                        end
                        if nav.label then
                            nav.label.TextColor3 = currentMuted
                        end
                    end
                end
            end

            -- Update other sidebar elements
            if brandIcon then
                brandIcon.TextColor3 = currentText
            end
            if brandText then
                brandText.TextColor3 = currentText
            end
            if unloadLabel then
                unloadLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for visibility
            end
            if discordLabel then
                discordLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for visibility
            end

            -- Update unload button
            if unloadBtn then
                unloadBtn.BackgroundColor3 = currentDanger
                unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end

            -- Update unload icon and label
            if unloadIcon then
                unloadIcon.TextColor3 = currentDanger
            end
            if unloadLabel then
                unloadLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for visibility
            end

            -- Update discord button
            if discordBtn then
                discordBtn.BackgroundColor3 = currentAccentA
                discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end

            -- Update all UI strokes in sidebar
            local function updateStrokes(instance)
                if instance:IsA('UIStroke') then
                    instance.Color = Stroke
                end
                for _, child in ipairs(instance:GetChildren()) do
                    updateStrokes(child)
                end
            end

            if sidebar then
                updateStrokes(sidebar)
            end

            -- Update tab visuals with new theme colors
            updateTabVisuals()
        end,
    }
end
function Components.buildMainPage(parent)
    local refs = {}
    local mainCard = Components.Card({
        Parent = parent,
        Size = UDim2.new(1, 0, 1, 0),
        Name = 'MainCard',
        ZIndex = 2,
    })

    -- Create scrollable content area
    local scrollFrame = New('ScrollingFrame', {
        Parent = mainCard,
        Size = UDim2.new(1, -24, 1, -20),
        Position = UDim2.new(0, 12, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageTransparency = 0.3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingEnabled = true,
        ZIndex = 2,
    }, {
        New('UIPadding', {
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 0),
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 10),
        }),
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    Components.SectionLabel('FEATURES', scrollFrame, 10)
    New('Frame', {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundColor3 = Stroke,
        BackgroundTransparency = 0.7,
        Parent = scrollFrame,
        ZIndex = 2,
    }, { New('UICorner', { CornerRadius = UDim.new(1, 0) }) })

    function makeRow(y, height)
        local row = New('Frame', {
            Size = UDim2.new(1, 0, 0, height or 36),
            Position = UDim2.new(0, 0, 0, y),
            BackgroundTransparency = 1,
            Parent = scrollFrame,
            ZIndex = 2,
        })
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = row,
        })
        return row
    end

    -- Game Info toggle
    local row1 = makeRow(52)
    refs.gameInfoBtn = Components.PillButton({
        Parent = row1,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.gameInfoBtn.MouseButton1Click:Connect(function()
        gameInfoEnabled = not gameInfoEnabled
        Components.UISync.toggleGameInfo(gameInfoEnabled)
    end))
    New('TextLabel', {
        Parent = row1,
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundTransparency = 1,
        Text = 'Game Info Display',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        LayoutOrder = 2,
    })

    -- Auto Collect
    local row2 = makeRow(92)
    refs.autoCollectBtn = Components.PillButton({
        Parent = row2,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.autoCollectBtn.MouseButton1Click:Connect(function()
        autoCollectEnabled = not autoCollectEnabled
        Components.UISync.toggleAutoCollect(autoCollectEnabled)
    end))
    New('TextLabel', {
        Parent = row2,
        LayoutOrder = 2,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Auto Collect',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    local intervalApi = Components.CycleButton({
        Parent = row2,
        LayoutOrder = 3,
        Size = UDim2.new(0, 160, 0, 30),
        Title = 'Interval',
        Options = {
            { label = '60s', value = '60s' },
            { label = '90s', value = '90s' },
            { label = '120s', value = '120s' },
            { label = '150s', value = '150s' },
            { label = '180s', value = '180s' },
        },
        CurrentValue = tostring(autoCollectIntervalSec) .. 's',
    })
    intervalApi.OnChanged(function(newValue)
        local secs = tonumber(newValue:match('(%d+)'))
        if secs and secs > 0 then
            autoCollectIntervalSec = secs
            -- Update nextCollectTime immediately if auto collect is enabled
            if autoCollectEnabled then
                nextCollectTime = time() + autoCollectIntervalSec
            end
        end
    end)

    -- Auto Collect Type dropdown (Teleport/Walk)
    local typeApi = Components.CycleButton({
        Parent = row2,
        LayoutOrder = 4,
        Size = UDim2.new(0, 120, 0, 30),
        Title = 'Type',
        Options = {
            { label = 'Teleport', value = 'Teleport' },
            { label = 'Walk', value = 'Walk' },
        },
        CurrentValue = autoCollectType or 'Teleport',
    })
    typeApi.OnChanged(function(newValue)
        autoCollectType = newValue
    end)

    row2:FindFirstChildWhichIsA('UIListLayout').SortOrder =
        Enum.SortOrder.LayoutOrder
    refs.intervalApi = intervalApi
    refs.typeApi = typeApi

    -- Auto Equip Best
    local row2b = makeRow(132)
    refs.autoEquipBestBtn = Components.PillButton({
        Parent = row2b,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.autoEquipBestBtn.MouseButton1Click:Connect(function()
        Components.UISync.toggleAutoEquipBest(not autoEquipBestEnabled)
    end))
    -- Initialize Auto Equip Best button state
    Components.SetState(
        refs.autoEquipBestBtn,
        autoEquipBestEnabled and 'on' or 'off',
        autoEquipBestEnabled and Success or DefaultButton
    )
    New('TextLabel', {
        Parent = row2b,
        LayoutOrder = 2,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Auto Equip Best',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    local autoEquipBestIntervalApi = Components.CycleButton({
        Parent = row2b,
        LayoutOrder = 3,
        Size = UDim2.new(0, 160, 0, 30),
        Title = 'Interval',
        Options = {
            { label = '100s', value = '100s' },
            { label = '200s', value = '200s' },
            { label = '300s', value = '300s' },
            { label = '400s', value = '400s' },
            { label = '500s', value = '500s' },
        },
        CurrentValue = tostring(autoEquipBestIntervalSec) .. 's',
    })
    autoEquipBestIntervalApi.OnChanged(function(newValue)
        local secs = tonumber(newValue:match('(%d+)'))
        if secs and secs > 0 then
            autoEquipBestIntervalSec = secs
            -- Update nextEquipBestTime immediately if auto equip best is enabled
            if autoEquipBestEnabled then
                nextEquipBestTime = time() + autoEquipBestIntervalSec
            end
        end
    end)

    row2b:FindFirstChildWhichIsA('UIListLayout').SortOrder =
        Enum.SortOrder.LayoutOrder
    refs.autoEquipBestIntervalApi = autoEquipBestIntervalApi

    -- Auto Sell
    local row2c = makeRow(152)
    refs.autoSellBtn = Components.PillButton({
        Parent = row2c,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.autoSellBtn.MouseButton1Click:Connect(function()
        Components.UISync.toggleAutoSell(not autoSellEnabled)
    end))
    -- Initialize Auto Sell button state
    Components.SetState(
        refs.autoSellBtn,
        autoSellEnabled and 'on' or 'off',
        autoSellEnabled and Success or DefaultButton
    )
    New('TextLabel', {
        Parent = row2c,
        LayoutOrder = 2,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Auto Sell',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    local autoSellIntervalApi = Components.CycleButton({
        Parent = row2c,
        LayoutOrder = 3,
        Size = UDim2.new(0, 160, 0, 30),
        Title = 'Interval',
        Options = {
            { label = '30s', value = '30s' },
            { label = '45s', value = '45s' },
            { label = '60s', value = '60s' },
            { label = '90s', value = '90s' },
            { label = '120s', value = '120s' },
            { label = '180s', value = '180s' },
        },
        CurrentValue = tostring(autoSellIntervalSec) .. 's',
    })
    autoSellIntervalApi.OnChanged(function(newValue)
        local secs = tonumber(newValue:match('(%d+)'))
        if secs and secs > 0 then
            autoSellIntervalSec = secs
        end
    end)

    row2c:FindFirstChildWhichIsA('UIListLayout').SortOrder =
        Enum.SortOrder.LayoutOrder
    refs.autoSellIntervalApi = autoSellIntervalApi

    -- Auto Favourite section
    local row2d = makeRow(172)
    refs.autoFavouriteBtn = Components.PillButton({
        Parent = row2d,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })

    -- Hold detection for unfavourite all
    local holdStartTime = nil
    local holdTriggered = false
    local holdThread = nil

    bind(refs.autoFavouriteBtn.MouseButton1Down:Connect(function()
        holdStartTime = tick()
        holdTriggered = false

        -- Start a thread to check for 1 second hold
        if holdThread then
            task.cancel(holdThread)
        end

        holdThread = task.spawn(function()
            task.wait(1.0)

            -- After 1 second, if still holding and haven't triggered yet
            if holdStartTime and not holdTriggered then
                holdTriggered = true
                showInternalToast(
                    'Auto Favourite',
                    'Unfavouriting all items...',
                    Muted
                )
                task.spawn(unfavouriteAll)
            end
        end)
    end))

    bind(refs.autoFavouriteBtn.MouseButton1Up:Connect(function()
        -- Cancel the hold thread
        if holdThread then
            task.cancel(holdThread)
            holdThread = nil
        end

        if holdStartTime and not holdTriggered then
            local holdDuration = tick() - holdStartTime

            if holdDuration < 1.0 then
                -- Quick click - toggle auto favourite
                autoFavouriteEnabled = not autoFavouriteEnabled
                toggleAutoFavourite(autoFavouriteEnabled)
                Components.SetState(
                    refs.autoFavouriteBtn,
                    autoFavouriteEnabled and 'on' or 'off',
                    autoFavouriteEnabled and Success or DefaultButton
                )
            end
        end

        -- Reset for next press
        holdStartTime = nil
        holdTriggered = false
    end))

    bind(refs.autoFavouriteBtn.MouseLeave:Connect(function()
        -- Cancel hold if mouse leaves button
        if holdThread then
            task.cancel(holdThread)
            holdThread = nil
        end
        holdStartTime = nil
        holdTriggered = false
    end))

    New('TextLabel', {
        Parent = row2d,
        LayoutOrder = 2,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Auto Favourite',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    -- Auto Favourite rarity dropdown (smaller)
    local autoFavRarityDropdown, _ = Components.MultiSelectDropdown({
        Parent = row2d,
        Size = UDim2.new(0, 120, 0, 30),
        Title = 'Rarities',
        LayoutOrder = 3,
        Items = {
            'Rare',
            'Epic',
            'Legendary',
            'Mythic',
            'Godly',
            'Secret',
            'Limited',
        },
        ColorMap = Rarities,
        ZIndex = 50,
        PersistenceKey = 'auto_favourite_rarity',
        OnChanged = function(map)
            autoFavouriteRarities = {}
            for name, on in pairs(map) do
                if on then
                    autoFavouriteRarities[name] = true
                end
            end
        end,
    })
    -- Set default selections
    autoFavRarityDropdown.SetSelectedMap({
        Limited = true,
        Godly = true,
        Secret = true,
    })
    refs.autoFavRarityDropdown = autoFavRarityDropdown
    registerDropdown(autoFavRarityDropdown)

    -- Auto Favourite mutation dropdown (smaller)
    local autoFavMutationDropdown, _ = Components.MultiSelectDropdown({
        Parent = row2d,
        Size = UDim2.new(0, 120, 0, 30),
        Title = 'Mutations',
        LayoutOrder = 4,
        Items = {
            'None',
            'Gold',
            'Diamond',
            'Frozen',
            'Neon',
            'Galactic',
            'UpsideDown',
            'Magma',
            'Underworld',
            'Rainbow',
            'Ruby',
        },
        ZIndex = 50,
        PersistenceKey = 'auto_favourite_mutation',
        OnChanged = function(map)
            autoFavouriteMutations = {}
            for name, on in pairs(map) do
                if on then
                    autoFavouriteMutations[name] = true
                end
            end
        end,
    })
    -- Set all mutations selected by default
    autoFavMutationDropdown.SetSelectedAll(true)
    refs.autoFavMutationDropdown = autoFavMutationDropdown
    registerDropdown(autoFavMutationDropdown)

    -- Auto Favourite interval selector
    local autoFavouriteIntervalApi = Components.CycleButton({
        Parent = row2d,
        LayoutOrder = 5,
        Size = UDim2.new(0, 120, 0, 30),
        Title = 'Interval',
        Options = {
            { label = '30s', value = '30s' },
            { label = '60s', value = '60s' },
            { label = '90s', value = '90s' },
            { label = '120s', value = '120s' },
            { label = '180s', value = '180s' },
        },
        CurrentValue = tostring(autoFavouriteIntervalSec) .. 's',
    })
    autoFavouriteIntervalApi.OnChanged(function(newValue)
        local secs = tonumber(newValue:match('(%d+)'))
        if secs and secs > 0 then
            autoFavouriteIntervalSec = secs
        end
    end)

    row2d:FindFirstChildWhichIsA('UIListLayout').SortOrder =
        Enum.SortOrder.LayoutOrder
    refs.autoFavouriteIntervalApi = autoFavouriteIntervalApi

    -- Initialize Auto Favourite button state
    Components.SetState(
        refs.autoFavouriteBtn,
        autoFavouriteEnabled and 'on' or 'off',
        autoFavouriteEnabled and Success or DefaultButton
    )

    -- Brainrot ESP toggle
    local row3 = makeRow(212)
    refs.espBtn = Components.PillButton({
        Parent = row3,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        Components.UISync.toggleESP(espEnabled)
    end))
    -- Initialize ESP button state
    Components.SetState(
        refs.espBtn,
        espEnabled and 'on' or 'off',
        espEnabled and Success or DefaultButton
    )
    New('TextLabel', {
        Parent = row3,
        LayoutOrder = 2,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Brainrot ESP',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    -- Rarity dropdown closer to Brainrot ESP text (bigger) - Use unique PersistenceKey for Brainrot ESP
    local espRarityDropdown, _ = Components.MultiSelectDropdown({
        Parent = row3,
        Size = UDim2.new(0, 140, 0, 30),
        Title = 'Rarity',
        LayoutOrder = 3,
        Items = {
            'Rare',
            'Epic',
            'Legendary',
            'Mythic',
            'Godly',
            'Secret',
            'Limited',
        },
        ColorMap = Rarities,
        ZIndex = 50,
        PersistenceKey = 'esp_brainrot_rarity',
        OnChanged = function(map)
            selectedRarities = {}
            for name, on in pairs(map) do
                if on then
                    selectedRarities[name] = true
                end
            end
        end,
    })
    refs.espRarityDropdown = espRarityDropdown

    -- Register the ESP dropdown with the standard persistence system
    registerDropdown(espRarityDropdown)

    -- Mutation dropdown right next to rarity (bigger)
    local mutationDropdown, _ = Components.MultiSelectDropdown({
        Parent = row3,
        Size = UDim2.new(0, 140, 0, 30),
        Title = 'Mutation',
        LayoutOrder = 4,
        Items = {
            'None',
            'Gold',
            'Diamond',
            'Frozen',
            'Neon',
            'Galactic',
            'UpsideDown',
            'Magma',
            'Underworld',
            'Rainbow',
            'Ruby',
        },
        ZIndex = 50,
        PersistenceKey = 'esp_mutation',
        OnChanged = function(map)
            selectedMutations = {}
            for name, on in pairs(map) do
                if on then
                    selectedMutations[name] = true
                end
            end
        end,
    })
    refs.espMutationDropdown = mutationDropdown

    -- Seed Auto Buy section
    local row5a = makeRow(330)
    refs.seedAutoBuyBtn = Components.PillButton({
        Parent = row5a,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.seedAutoBuyBtn.MouseButton1Click:Connect(function()
        toggleSeedAutoBuy(not seedAutoBuyEnabled)
        Components.SetState(
            refs.seedAutoBuyBtn,
            seedAutoBuyEnabled and 'on' or 'off',
            seedAutoBuyEnabled and Success or DefaultButton
        )
    end))
    -- Initialize Seed Auto Buy button state
    Components.SetState(
        refs.seedAutoBuyBtn,
        seedAutoBuyEnabled and 'on' or 'off',
        seedAutoBuyEnabled and Success or DefaultButton
    )
    New('TextLabel', {
        Parent = row5a,
        LayoutOrder = 2,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Seed Auto Buy',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    -- Seed Auto Buy dropdown
    local seedBuyDropdown, _ = Components.MultiSelectDropdown({
        Parent = row5a,
        Size = UDim2.new(0, 300, 0, 30),
        Title = 'Select Seeds to Auto Buy',
        LayoutOrder = 3,
        Items = {},
        ZIndex = 50,
        PersistenceKey = 'seed_auto_buy',
        OnChanged = function(map)
            selectedSeedBuyFilters = {}
            for name, on in pairs(map) do
                if on then
                    selectedSeedBuyFilters[name] = true
                end
            end
        end,
    })
    refs.seedBuyDropdown = seedBuyDropdown
    -- Immediate restore from registry to prime selection before items arrive
    pcall(function()
        local reg = DropdownStateRegistry
            and DropdownStateRegistry['dropdown_key_seed_auto_buy']
        local function anyTrue(t)
            if type(t) ~= 'table' then
                return false
            end
            for _, v in pairs(t) do
                if v then
                    return true
                end
            end
            return false
        end
        if reg and anyTrue(reg.selected) and seedBuyDropdown.SetSelection then
            seedBuyDropdown.SetSelection(reg.selected)
        end
    end)

    -- Function to populate seed buy dropdown
    function ensureSeedBuyFiltersPopulated()
        local playerGui = player:FindFirstChild('PlayerGui')
        if not playerGui then
            return
        end

        local seedsFrame = playerGui:FindFirstChild('Main', true)
        if seedsFrame then
            seedsFrame = seedsFrame:FindFirstChild('Seeds', true)
        end
        if seedsFrame then
            seedsFrame = seedsFrame:FindFirstChild('Frame', true)
        end
        if seedsFrame then
            seedsFrame = seedsFrame:FindFirstChild('ScrollingFrame')
        end
        if not seedsFrame then
            return
        end

        local seedNames = {}
        for _, seedItem in ipairs(seedsFrame:GetChildren()) do
            if
                seedItem:IsA('Frame')
                and seedItem.Name ~= 'UIPadding'
                and seedItem.Name ~= 'Padding'
                and seedItem.Name ~= 'UIListLayout'
            then
                local titleLabel = seedItem:FindFirstChild('Title')
                if titleLabel and titleLabel.Text and titleLabel.Text ~= '' then
                    table.insert(seedNames, titleLabel.Text)
                end
            end
        end

        -- Fallback list if UI did not yield any seeds
        if #seedNames == 0 then
            seedNames = {
                'Cactus Seed',
                'Strawberry Seed',
                'Pumpkin Seed',
                'Sunflower Seed',
                'Dragon Fruit Seed',
                'Eggplant Seed',
                'Watermelon Seed',
                'Grape Seed',
                'Cocotank Seed',
                'Carnivorous Plant Seed',
                'Mr Carrot Seed',
                'Tomatrio Seed',
                'Shroombino Seed',
                'Mango Seed',
                'King Limone Seed',
            }
        end

        -- Sort by desired rarity/name order
        table.sort(seedNames, function(a, b)
            local ia, na = seedOrderIndex(a)
            local ib, nb = seedOrderIndex(b)
            if ia ~= ib then
                return ia < ib
            end
            return (na or a:lower()) < (nb or b:lower())
        end)

        if #seedNames > 0 and seedBuyDropdown then
            -- Preserve previous selection when updating items
            seedBuyDropdown.SetItems(seedNames, true)

            -- Prefer persisted registry state explicitly
            local reg = DropdownStateRegistry
                and DropdownStateRegistry['dropdown_key_seed_auto_buy']
            local restored = (reg and reg.selected)
                or (
                    seedBuyDropdown.GetSelection
                    and seedBuyDropdown.GetSelection()
                )

            -- Helper: map restored keys to current items using case-insensitive/" Seed"-agnostic matching
            local function mapRestoredToItems(restoredMap, items)
                local mapped = {}
                if not (restoredMap and next(restoredMap)) then
                    return mapped
                end
                -- Build normalized index of items
                local idx = {}
                for _, it in ipairs(items) do
                    local k = tostring(it):lower():gsub('%s*seed$', '')
                    idx[k] = it
                end
                for k, v in pairs(restoredMap) do
                    if v then
                        local norm = tostring(k):lower():gsub('%s*seed$', '')
                        if idx[norm] then
                            mapped[idx[norm]] = true
                        else
                            -- try contains matching in either direction
                            for key, full in pairs(idx) do
                                if
                                    key:find(norm, 1, true)
                                    or norm:find(key, 1, true)
                                then
                                    mapped[full] = true
                                end
                            end
                        end
                    end
                end
                return mapped
            end

            if restored and next(restored) then
                selectedSeedBuyFilters = mapRestoredToItems(restored, seedNames)
                if next(selectedSeedBuyFilters) then
                    seedBuyDropdown.SetSelectedMap(selectedSeedBuyFilters)
                else
                    -- If mapping produced nothing (labels changed), fall back gracefully
                    if next(selectedSeedBuyFilters) then
                        seedBuyDropdown.SetSelectedMap(selectedSeedBuyFilters)
                    else
                        seedBuyDropdown.SetSelectedAll(true)
                        selectedSeedBuyFilters = seedBuyDropdown.GetSelection()
                    end
                end
                seedAutoBuyInitDone = true
            elseif next(selectedSeedBuyFilters) then
                seedBuyDropdown.SetSelectedMap(selectedSeedBuyFilters)
                seedAutoBuyInitDone = true
            elseif not seedAutoBuyInitDone then
                -- Only apply defaults if we have never initialized
                local defaultSeedSelection = {}
                for _, seedName in ipairs(seedNames) do
                    local seedLower = seedName:lower()
                    if
                        seedLower:find('mr carrot')
                        or seedLower:find('tomatrio')
                        or seedLower:find('shroombino')
                        or seedLower:find('mango')
                    then
                        defaultSeedSelection[seedName] = true
                        selectedSeedBuyFilters[seedName] = true
                    end
                end
                if not next(defaultSeedSelection) and #seedNames > 0 then
                    local fallbackSeeds = math.min(4, #seedNames)
                    for i = 1, fallbackSeeds do
                        defaultSeedSelection[seedNames[i]] = true
                        selectedSeedBuyFilters[seedNames[i]] = true
                    end
                end
                seedBuyDropdown.SetSelectedMap(defaultSeedSelection)
                seedAutoBuyInitDone = true
            end
        end
    end
    -- Gear Auto Buy section
    local row5b = makeRow(370)
    refs.gearAutoBuyBtn = Components.PillButton({
        Parent = row5b,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.gearAutoBuyBtn.MouseButton1Click:Connect(function()
        toggleGearAutoBuy(not gearAutoBuyEnabled)
        Components.SetState(
            refs.gearAutoBuyBtn,
            gearAutoBuyEnabled and 'on' or 'off',
            gearAutoBuyEnabled and Success or DefaultButton
        )
    end))
    -- Initialize Gear Auto Buy button state
    Components.SetState(
        refs.gearAutoBuyBtn,
        gearAutoBuyEnabled and 'on' or 'off',
        gearAutoBuyEnabled and Success or DefaultButton
    )
    New('TextLabel', {
        Parent = row5b,
        LayoutOrder = 2,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Gear Auto Buy',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    -- Gear Auto Buy dropdown
    local gearBuyDropdown, _ = Components.MultiSelectDropdown({
        Parent = row5b,
        Size = UDim2.new(0, 300, 0, 30),
        Title = 'Select Gear to Auto Buy',
        LayoutOrder = 3,
        Items = {},
        ZIndex = 50,
        PersistenceKey = 'gear_auto_buy',
        OnChanged = function(map)
            selectedGearBuyFilters = {}
            for name, on in pairs(map) do
                if on then
                    selectedGearBuyFilters[name] = true
                end
            end
        end,
    })
    refs.gearBuyDropdown = gearBuyDropdown
    -- Immediate restore from registry to prime selection before items arrive
    pcall(function()
        local reg = DropdownStateRegistry
            and DropdownStateRegistry['dropdown_key_gear_auto_buy']
        local function anyTrue(t)
            if type(t) ~= 'table' then
                return false
            end
            for _, v in pairs(t) do
                if v then
                    return true
                end
            end
            return false
        end
        if reg and anyTrue(reg.selected) and gearBuyDropdown.SetSelection then
            gearBuyDropdown.SetSelection(reg.selected)
        end
    end)

    -- Function to populate gear buy dropdown
    function ensureGearBuyFiltersPopulated()
        local gearsFrame = getGearsScrollingFrame()
        if not gearsFrame then
            return
        end

        local gearNames = {}
        for _, item in ipairs(gearsFrame:GetChildren()) do
            if
                item:IsA('Frame')
                and item.Name ~= 'Padding'
                and item.Name ~= 'UIPadding'
                and item.Name ~= 'UIListLayout'
            then
                local title = item:FindFirstChild('Title')
                if title and title.Text and title.Text ~= '' then
                    table.insert(gearNames, title.Text)
                end
            end
        end

        -- Local, safe display order for Gear auto-buy dropdown
        do
            local ORDER = {
                'Water Bucket',
                'Frost Grenade',
                'Banana Gun',
                'Frost Blower',
                'Carrot Launcher',
            }
            local idx = {}
            for i, n in ipairs(ORDER) do
                idx[n:lower()] = i
            end
            local function orderKey(name)
                local norm = tostring(name or ''):lower()
                return idx[norm] or 9999, norm
            end
            table.sort(gearNames, function(a, b)
                local ia, na = orderKey(a)
                local ib, nb = orderKey(b)
                if ia ~= ib then
                    return ia < ib
                end
                return na < nb
            end)
        end

        if #gearNames > 0 and gearBuyDropdown then
            -- Preserve previous selection when updating items
            gearBuyDropdown.SetItems(gearNames, true)

            -- Prefer persisted registry state explicitly
            local reg = DropdownStateRegistry
                and DropdownStateRegistry['dropdown_key_gear_auto_buy']
            local restored = (reg and reg.selected)
                or (
                    gearBuyDropdown.GetSelection
                    and gearBuyDropdown.GetSelection()
                )

            -- Helper: direct case-insensitive match (gear names usually don't have suffixes)
            local function mapRestoredGear(restoredMap, items)
                local mapped = {}
                if not (restoredMap and next(restoredMap)) then
                    return mapped
                end
                local idx = {}
                for _, it in ipairs(items) do
                    idx[tostring(it):lower()] = it
                end
                for k, v in pairs(restoredMap) do
                    if v then
                        local norm = tostring(k):lower()
                        if idx[norm] then
                            mapped[idx[norm]] = true
                        else
                            for key, full in pairs(idx) do
                                if
                                    key:find(norm, 1, true)
                                    or norm:find(key, 1, true)
                                then
                                    mapped[full] = true
                                end
                            end
                        end
                    end
                end
                return mapped
            end

            -- Try to restore from registry first
            if reg and reg.selected and next(reg.selected) then
                local mapped = mapRestoredGear(reg.selected, gearNames)
                if next(mapped) then
                    selectedGearBuyFilters = mapped
                    gearBuyDropdown.SetSelectedMap(selectedGearBuyFilters)
                    gearAutoBuyInitDone = true
                else
                    -- Registry had data but mapping failed, fall back to current selection
                    if next(selectedGearBuyFilters) then
                        gearBuyDropdown.SetSelectedMap(selectedGearBuyFilters)
                        gearAutoBuyInitDone = true
                    end
                end
            elseif restored and next(restored) then
                -- Fallback to current dropdown selection
                selectedGearBuyFilters = mapRestoredGear(restored, gearNames)
                if next(selectedGearBuyFilters) then
                    gearBuyDropdown.SetSelectedMap(selectedGearBuyFilters)
                end
                gearAutoBuyInitDone = true
            elseif next(selectedGearBuyFilters) then
                gearBuyDropdown.SetSelectedMap(selectedGearBuyFilters)
                gearAutoBuyInitDone = true
            elseif not gearAutoBuyInitDone then
                -- Only apply defaults if we have never initialized
                local defaultGearSelection = {}
                for _, gearName in ipairs(gearNames) do
                    if
                        gearName == 'Carrot Launcher'
                        or gearName == 'Frost Blower'
                    then
                        defaultGearSelection[gearName] = true
                        selectedGearBuyFilters[gearName] = true
                    end
                end
                gearBuyDropdown.SetSelectedMap(defaultGearSelection)
                gearAutoBuyInitDone = true
            end
        end
    end

    -- Brainrot Auto Hit toggle with inline dropdowns
    local row5_autohit = makeRow(410)
    refs.autoHitBtn = Components.PillButton({
        Parent = row5_autohit,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.autoHitBtn.MouseButton1Click:Connect(function()
        autoHitEnabled = not autoHitEnabled
        toggleAutoHit(autoHitEnabled)
        refs.autoHitBtn.Text = autoHitEnabled and 'On' or 'Off'
        Components.SetState(
            refs.autoHitBtn,
            autoHitEnabled,
            autoHitEnabled and Success or DefaultButton
        )
    end))
    New('TextLabel', {
        Parent = row5_autohit,
        LayoutOrder = 2,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Auto Hit Brainrots',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    -- Movement mode dropdown (inline, smaller)
    local movementModeApi = Components.CycleButton({
        Parent = row5_autohit,
        LayoutOrder = 3,
        Size = UDim2.new(0, 100, 0, 30),
        Title = 'Movement',
        Options = {
            { label = 'Teleport', value = 'Teleport' },
            { label = 'Tween', value = 'Tween' },
            { label = 'Walk', value = 'Walk' },
        },
        CurrentValue = autoHitMovementMode,
    })
    movementModeApi.OnChanged(function(newValue)
        autoHitMovementMode = newValue
        -- Restart auto hit thread if it's running to use new movement mode
        if autoHitEnabled and autoHitThread then
            task.cancel(autoHitThread)
            autoHitThread = nil
            autoHitThread = task.spawn(autoHitLoop)
        end
    end)
    refs.movementModeApi = movementModeApi

    -- Autohit restore guard to prevent defaults overriding persisted state
    local autohitRestoreInProgress = false

    -- Function to filter brainrots by selected rarities using the selection map directly
    local function updateFilteredBrainrotsWithMap(selectionMap)
        if not selectionMap then
            return
        end

        -- Get brainrots from selected rarities only
        local filteredBrainrots = {}
        local brainrotsByRarity = getBrainrotNamesByRarity()

        if brainrotsByRarity then
            for rarity, isSelected in pairs(selectionMap) do
                if isSelected and brainrotsByRarity[rarity] then
                    for _, brainrotName in ipairs(brainrotsByRarity[rarity]) do
                        table.insert(filteredBrainrots, brainrotName)
                    end
                end
            end
        end

        -- Update the brainrot names dropdown with filtered items
        if
            refs.autoHitBrainrotDropdown
            and refs.autoHitBrainrotDropdown.SetItems
        then
            refs.autoHitBrainrotDropdown.SetItems(filteredBrainrots)

            -- Preserve existing selections that are still valid, otherwise select all
            local currentSelections = refs.autoHitBrainrotDropdown.GetSelection
                    and refs.autoHitBrainrotDropdown.GetSelection()
                or {}
            local validSelections = {}
            local hasValidSelections = false

            for _, brainrotName in ipairs(filteredBrainrots) do
                if currentSelections[brainrotName] then
                    validSelections[brainrotName] = true
                    hasValidSelections = true
                end
            end

            if hasValidSelections then
                refs.autoHitBrainrotDropdown.SetSelectedMap(validSelections)
            else
                refs.autoHitBrainrotDropdown.SetSelectedAll(true)
            end

            -- Sync selectedAutoHitBrainrotNames with the final selections
            local finalSelections = refs.autoHitBrainrotDropdown.GetSelection
                    and refs.autoHitBrainrotDropdown.GetSelection()
                or {}
            selectedAutoHitBrainrotNames = {}
            for name, selected in pairs(finalSelections) do
                if selected then
                    selectedAutoHitBrainrotNames[name] = true
                end
            end
        end
    end

    -- Function to filter brainrots by selected rarities (fallback using GetSelection)
    local function updateFilteredBrainrots()
        if not refs.rarityDropdown then
            return
        end

        local dropdownSelection = refs.rarityDropdown.GetSelection()

        -- Use the dropdown selection directly
        if dropdownSelection then
            updateFilteredBrainrotsWithMap(dropdownSelection)
        end
    end

    -- Initialize the rarity dropdown (inline, smaller)
    local autoHitRarityDropdown = Components.MultiSelectDropdown({
        Parent = row5_autohit,
        LayoutOrder = 4,
        Size = UDim2.new(0, 100, 0, 30),
        Title = 'Rarities',
        Items = {
            'Rare',
            'Epic',
            'Legendary',
            'Mythic',
            'Godly',
            'Secret',
            'Limited',
        },
        ZIndex = 50,
        PersistenceKey = 'autohit_target_rarities',
        OnChanged = function(map)
            -- Update our local state
            selectedAutoHitRarities = {}
            for name, on in pairs(map) do
                if on then
                    selectedAutoHitRarities[name] = true
                end
            end

            -- Update filtered brainrots using the map directly
            updateFilteredBrainrotsWithMap(map)
        end,
    })

    -- Store reference to the dropdown
    refs.rarityDropdown = autoHitRarityDropdown

    -- Register the dropdown with the standard persistence system
    registerDropdown(autoHitRarityDropdown)

    -- Initialize selectedAutoHitRarities if it doesn't exist or is empty
    if not selectedAutoHitRarities or not next(selectedAutoHitRarities) then
        selectedAutoHitRarities = {}

        -- Default to only Godly, Secret, and Limited selected
        for _, rarity in ipairs({ 'Godly', 'Secret', 'Limited' }) do
            selectedAutoHitRarities[rarity] = true
        end

        -- Apply the default selection to the dropdown
        if autoHitRarityDropdown and autoHitRarityDropdown.SetSelectedMap then
            autoHitRarityDropdown.SetSelectedMap(selectedAutoHitRarities)
        end
    end

    -- Brainrot Names dropdown (inline)
    local brainrotNames = getBrainrotNames()

    -- Initialize selectedAutoHitBrainrotNames if it doesn't exist
    if not selectedAutoHitBrainrotNames then
        selectedAutoHitBrainrotNames = {}
    end

    local brainrotNamesDropdown, _ = Components.MultiSelectDropdown({
        Parent = row5_autohit,
        LayoutOrder = 5,
        Size = UDim2.new(0, 155, 0, 30),
        Title = 'Brainrots',
        Items = brainrotNames,
        ZIndex = 50,
        PersistenceKey = 'autohit_brainrot_names',
        OnChanged = function(map)
            selectedAutoHitBrainrotNames = {}
            for name, on in pairs(map) do
                if on then
                    selectedAutoHitBrainrotNames[name] = true
                end
            end
        end,
    })
    refs.autoHitBrainrotDropdown = brainrotNamesDropdown

    -- Initial update of filtered brainrots after a short delay to ensure dropdown is ready
    task.delay(0.1, function()
        updateFilteredBrainrots()
    end)

    row5_autohit:FindFirstChildWhichIsA('UIListLayout').SortOrder =
        Enum.SortOrder.LayoutOrder

    -- Seed Timer ESP toggle
    local row5c = makeRow(450)
    refs.seedTimerEspBtn = Components.PillButton({
        Parent = row5c,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.seedTimerEspBtn.MouseButton1Click:Connect(function()
        seedTimerEspEnabled = not seedTimerEspEnabled
        Components.UISync.toggleSeedTimerESP(seedTimerEspEnabled)
    end))
    New('TextLabel', {
        Parent = row5c,
        LayoutOrder = 2,
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundTransparency = 1,
        Text = 'Seed Timer ESP',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    -- Seed Timer Info and Hitbox toggles (positioned like interval dropdown)
    refs.seedTimerInfoBtn = Components.PillButton({
        Parent = row5c,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 3,
    })
    bind(refs.seedTimerInfoBtn.MouseButton1Click:Connect(function()
        seedTimerInfoEnabled = not seedTimerInfoEnabled
        Components.UISync.toggleSeedTimerInfo(seedTimerInfoEnabled)
    end))
    New('TextLabel', {
        Parent = row5c,
        LayoutOrder = 4,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Seed Timer Info',
        TextColor3 = Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    refs.seedTimerHitboxBtn = Components.PillButton({
        Parent = row5c,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 5,
    })
    bind(refs.seedTimerHitboxBtn.MouseButton1Click:Connect(function()
        seedTimerHitboxEnabled = not seedTimerHitboxEnabled
        Components.UISync.toggleSeedTimerHitbox(seedTimerHitboxEnabled)
    end))
    New('TextLabel', {
        Parent = row5c,
        LayoutOrder = 6,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Show Hitboxes',
        TextColor3 = Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    -- Auto Complete Event section
    local row4 = makeRow(490)
    refs.autoCompleteEventBtn = Components.PillButton({
        Parent = row4,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.autoCompleteEventBtn.MouseButton1Click:Connect(function()
        autoCompleteEventEnabled = not autoCompleteEventEnabled
        -- Update button state instantly
        Components.SetState(
            refs.autoCompleteEventBtn,
            autoCompleteEventEnabled and 'on' or 'off',
            autoCompleteEventEnabled and Success or DefaultButton
        )
        -- Then do heavy work in background
        toggleAutoCompleteEvent(autoCompleteEventEnabled)
    end))
    New('TextLabel', {
        Parent = row4,
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundTransparency = 1,
        Text = 'Auto Complete Event',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        LayoutOrder = 2,
    })

    -- Initialize Auto Complete Event button state
    Components.SetState(
        refs.autoCompleteEventBtn,
        autoCompleteEventEnabled and 'on' or 'off',
        autoCompleteEventEnabled and Success or DefaultButton
    )

    -- Auto Rebirth section
    local row4b = makeRow(530)
    refs.autoRebirthBtn = Components.PillButton({
        Parent = row4b,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })
    bind(refs.autoRebirthBtn.MouseButton1Click:Connect(function()
        autoRebirthEnabled = not autoRebirthEnabled
        toggleAutoRebirth(autoRebirthEnabled)
        Components.SetState(
            refs.autoRebirthBtn,
            autoRebirthEnabled and 'on' or 'off',
            autoRebirthEnabled and Success or DefaultButton
        )
    end))
    New('TextLabel', {
        Parent = row4b,
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundTransparency = 1,
        Text = 'Auto Rebirth',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        LayoutOrder = 2,
    })
    -- Initialize Auto Rebirth button state
    Components.SetState(
        refs.autoRebirthBtn,
        autoRebirthEnabled and 'on' or 'off',
        autoRebirthEnabled and Success or DefaultButton
    )

    -- Update global uiRefs with the settings page refs
    uiRefs = refs

    return refs
end

function Components.buildAlertsPage(parent)
    -- Scope 1: Basic setup and main container
    local refs, alertsCard, scroll
    do
        refs = {}
        alertsCard = Components.Card({
            Parent = parent,
            Size = UDim2.new(1, 0, 1, 0),
            Name = 'AlertsCard',
            ZIndex = 2,
        })

        scroll = New('ScrollingFrame', {
            Parent = alertsCard,
            Name = 'AlertsScroll',
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 0,
            ScrollBarImageTransparency = 1,
            ScrollingEnabled = false,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ZIndex = 3,
        }, {
            New('UIPadding', {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 10),
            }),
            New('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })

        -- Function to update scrolling behavior based on content size
        local function updateScrollingBehavior()
            local uiListLayout = scroll:FindFirstChild('UIListLayout')
            if not uiListLayout then
                return
            end

            local contentSize = uiListLayout.AbsoluteContentSize.Y
            local frameSize = scroll.AbsoluteSize.Y
            local padding = 16 -- 6px top + 10px bottom padding

            if contentSize <= frameSize - padding then
                -- Content fits within frame, disable scrolling completely
                scroll.CanvasSize = UDim2.new(0, 0, 0, contentSize + padding)
                scroll.ScrollBarThickness = 0
                scroll.ScrollBarImageTransparency = 1
                scroll.ScrollingEnabled = false
            else
                -- Content exceeds frame, enable scrolling with exact fit
                scroll.CanvasSize = UDim2.new(0, 0, 0, contentSize + padding)
                scroll.ScrollBarThickness = 6
                scroll.ScrollBarImageTransparency = 0.5
                scroll.ScrollingEnabled = true
            end
        end

        -- Update scrolling behavior when content changes
        task.defer(function()
            local uiListLayout = scroll:FindFirstChild('UIListLayout')
            if uiListLayout then
                bind(
                    uiListLayout
                        :GetPropertyChangedSignal('AbsoluteContentSize')
                        :Connect(updateScrollingBehavior)
                )
            end
            bind(
                scroll
                    :GetPropertyChangedSignal('AbsoluteSize')
                    :Connect(updateScrollingBehavior)
            )
            -- Initial update
            updateScrollingBehavior()
        end)
        refs.alertsScroll = scroll

        Components.SectionLabel('BRAINROT ALERTS', scroll)
    end

    -- Scope 2: Brainrot alerts row 1 - toggles and volume
    do
        local ar1 = New('Frame', {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Parent = scroll,
            ZIndex = 2,
        })
        local brLeft = New('Frame', {
            Parent = ar1,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -240, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            ZIndex = 2,
        }, {
            New('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })

        refs.alertsToggle = Components.PillButton({
            Parent = brLeft,
            Size = UDim2.new(0, 28, 0, 28),
            ZIndex = 3,
            LayoutOrder = 1,
        })
        Components.SetState(
            refs.alertsToggle,
            alertEnabled and 'on' or 'off',
            alertEnabled and Success or DefaultButton
        )
        bind(refs.alertsToggle.MouseButton1Click:Connect(function()
            alertEnabled = not alertEnabled
            Components.SetState(
                refs.alertsToggle,
                alertEnabled and 'on' or 'off',
                alertEnabled and Success or DefaultButton
            )
            pcall(updateToastPositions)
        end))

        local brRight = New('Frame', {
            Parent = ar1,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 220, 1, 0),
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            ZIndex = 3,
        }, {
            New('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 4),
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
        })
        New('TextLabel', {
            Parent = brRight,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = 'Enable Serverwide',
            TextColor3 = Muted,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 3,
        })
        local serverwideToggle = Components.PillButton({
            Parent = brRight,
            Size = UDim2.new(0, 28, 0, 28),
            ZIndex = 3,
        })
        Components.SetState(
            serverwideToggle,
            brainrotServerwideEnabled and 'on' or 'off',
            brainrotServerwideEnabled and Success or DefaultButton
        )
        bind(serverwideToggle.MouseButton1Click:Connect(function()
            brainrotServerwideEnabled = not brainrotServerwideEnabled
            Components.SetState(
                serverwideToggle,
                brainrotServerwideEnabled and 'on' or 'off',
                brainrotServerwideEnabled and Success or DefaultButton
            )
        end))
        refs.serverwideToggle = serverwideToggle

        local volSliderApi = Components.Slider({
            Parent = brLeft,
            LayoutOrder = 2,
            Size = UDim2.new(0, 200, 1, 0),
            Title = 'Volume',
        })
        volSliderApi.OnChanged(function(a)
            alertVolume = a * 2.0
        end)
        volSliderApi.Set(alertVolume / 2.0)
        refs.volSliderApi = volSliderApi
    end

    -- Brainrot alerts row 2 - dropdowns and filters (removed scope to fix dropdown interference)
    local ar2 = New('Frame', {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local alertRarityDropdown = Components.MultiSelectDropdown({
        Parent = ar2,
        Size = UDim2.new(0, 180, 0, 30),
        Title = 'Alert on rarity',
        Items = {
            'Rare',
            'Epic',
            'Legendary',
            'Mythic',
            'Godly',
            'Secret',
            'Limited',
        },
        ColorMap = Rarities,
        ZIndex = 50,
        LayoutOrder = 1,
        PersistenceKey = 'alert_rarity',
        OnChanged = function(map)
            alertRaritySet = {}
            for k, v in pairs(map) do
                if v then
                    alertRaritySet[k] = true
                end
            end
        end,
    })
    -- Only set defaults if no selections have been made yet (first time or no config loaded)
    if not next(alertRaritySet) then
        local restored = alertRarityDropdown.GetSelection
            and alertRarityDropdown.GetSelection()
        if restored and next(restored) then
            alertRaritySet = {}
            for k, v in pairs(restored) do
                if v then
                    alertRaritySet[k] = true
                end
            end
            alertRarityDropdown.SetSelectedMap(alertRaritySet)
        else
            alertRarityDropdown.SetSelectedMap({ Godly = true, Secret = true })
        end
    else
        alertRarityDropdown.SetSelectedMap(alertRaritySet)
    end
    refs.alertRarityDropdown = alertRarityDropdown

    local alertMutationDropdown = Components.MultiSelectDropdown({
        Parent = ar2,
        Size = UDim2.new(0, 180, 0, 30),
        Title = 'Alert on mutation',
        Items = {
            'None',
            'Gold',
            'Diamond',
            'Frozen',
            'Neon',
            'Galactic',
            'UpsideDown',
            'Magma',
            'Underworld',
            'Rainbow',
            'Ruby',
        },
        ZIndex = 50,
        LayoutOrder = 2,
        PersistenceKey = 'alert_mutation',
        OnChanged = function(map)
            alertMutationSet = {}
            for k, v in pairs(map) do
                if v then
                    alertMutationSet[k] = true
                end
            end
        end,
    })
    -- Only set defaults if no selections have been made yet (first time or no config loaded)
    if not next(alertMutationSet) then
        local restored = alertMutationDropdown.GetSelection
            and alertMutationDropdown.GetSelection()
        if restored and next(restored) then
            alertMutationSet = {}
            for k, v in pairs(restored) do
                if v then
                    alertMutationSet[k] = true
                end
            end
            alertMutationDropdown.SetSelectedMap(alertMutationSet)
        else
            alertMutationDropdown.SetSelectedMap({
                Neon = true,
                Frozen = true,
                Galactic = true,
                Rainbow = true,
                UpsideDown = true,
                Magma = true,
                Underworld = true,
            })
        end
    else
        alertMutationDropdown.SetSelectedMap(alertMutationSet)
    end
    refs.alertMutationDropdown = alertMutationDropdown

    local alertWhenApi = Components.CycleButton({
        Parent = ar2,
        LayoutOrder = 3,
        Size = UDim2.new(0, 180, 0, 30),
        Title = 'Alert when',
        Options = {
            { label = 'All (rarity AND mutation)', value = 'Both' },
            { label = 'Any (rarity OR mutation)', value = 'Any' },
        },
        CurrentValue = alertMatchMode,
    })
    alertWhenApi.OnChanged(function(v)
        alertMatchMode = v
    end)
    refs.alertWhenApi = alertWhenApi

    Components.SectionLabel('SEED ALERTS', scroll)

    local ar3 = New('Frame', {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })
    refs.seedAlertsToggle = Components.PillButton({
        Parent = ar3,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
    })
    Components.SetState(
        refs.seedAlertsToggle,
        seedAlertEnabled and 'on' or 'off',
        seedAlertEnabled and Success or DefaultButton
    )
    bind(refs.seedAlertsToggle.MouseButton1Click:Connect(function()
        local isEnabled = not seedAlertEnabled
        Components.SetState(
            refs.seedAlertsToggle,
            isEnabled and 'on' or 'off',
            isEnabled and Success or DefaultButton
        )
        toggleSeedAlerts(isEnabled)
    end))

    local seedFilterDropdownApi, _ = Components.MultiSelectDropdown({
        Parent = ar3,
        Size = UDim2.new(0, 240, 0, 30),
        Title = 'Seeds to alert for',
        ZIndex = 40,
        PersistenceKey = 'seed_alert_filters',
        Items = {}, -- Will be populated by ensureSeedFiltersPopulated
        OnChanged = function(map)
            selectedSeedFilters = map
        end,
    })
    refs.seedFilterDropdownApi = seedFilterDropdownApi

    -- Register the dropdown with the standard persistence system
    registerDropdown(seedFilterDropdownApi)

    -- Dropdown will be initialized after uiRefs is updated

    local seedVolApi = Components.Slider({
        Parent = ar3,
        Size = UDim2.new(0, 200, 1, 0),
        Title = 'Volume',
    })
    seedVolApi.OnChanged(function(a)
        seedAlertVolume = a * 2.0
    end)
    seedVolApi.Set(seedAlertVolume / 2.0)
    refs.seedVolApi = seedVolApi

    Components.SectionLabel('GEAR ALERTS', scroll)

    local ar4 = New('Frame', {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    -- Gear alerts toggle
    refs.gearAlertsToggle = Components.PillButton({
        Parent = ar4,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
    })
    refs.gearAlertsToggle.LayoutOrder = 1
    Components.SetState(
        refs.gearAlertsToggle,
        gearAlertEnabled and 'on' or 'off',
        gearAlertEnabled and Success or DefaultButton
    )
    bind(refs.gearAlertsToggle.MouseButton1Click:Connect(function()
        gearAlertEnabled = not gearAlertEnabled
        Components.SetState(
            refs.gearAlertsToggle,
            gearAlertEnabled and 'on' or 'off',
            gearAlertEnabled and Success or DefaultButton
        )
        toggleGearAlerts(gearAlertEnabled)
    end))

    local gearFilterDropdownApi, _ = Components.MultiSelectDropdown({
        Parent = ar4,
        Size = UDim2.new(0, 240, 0, 30),
        Title = 'Gears to alert for',
        ZIndex = 40,
        Items = {},
        LayoutOrder = 2,
        PersistenceKey = 'gear_alert_filters',
        OnChanged = function(map)
            selectedGearFilters = map
        end,
    })
    refs.gearFilterDropdownApi = gearFilterDropdownApi
    -- Gear dropdown will be populated automatically when checkGearStock runs

    -- Right-anchored holder for label + webhook toggle (like original script)
    local rightHolder = New('Frame', {
        Parent = ar4,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 220, 1, 0),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        ZIndex = 3,
        LayoutOrder = 99,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })
    New('TextLabel', {
        Parent = rightHolder,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Disable Gear Webhook',
        TextColor3 = Muted,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 3,
    })
    local gearWebhookToggle = Components.PillButton({
        Parent = rightHolder,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
    })
    -- Label says "Disable Gear Webhook": show ON when disabled (like original)
    Components.SetState(
        gearWebhookToggle,
        (not gearWebhookEnabled) and 'on' or 'off',
        (not gearWebhookEnabled) and Success or DefaultButton
    )
    bind(gearWebhookToggle.MouseButton1Click:Connect(function()
        gearWebhookEnabled = not gearWebhookEnabled
        Components.SetState(
            gearWebhookToggle,
            (not gearWebhookEnabled) and 'on' or 'off',
            (not gearWebhookEnabled) and Success or DefaultButton
        )
    end))
    refs.gearWebhookToggle = gearWebhookToggle

    return refs
end
function Components.buildSettingsPage(parent)
    local refs = {}
    local settingsCard = Components.Card({
        Parent = parent,
        Size = UDim2.new(1, 0, 1, 0),
        Name = 'SettingsCard',
        ZIndex = 2,
    })
    local scroll = New('ScrollingFrame', {
        Parent = settingsCard,
        Name = 'SettingsScroll',
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollBarImageTransparency = 1,
        ScrollingEnabled = false,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 3,
    }, {
        New('UIPadding', {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 10),
        }),
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    -- Function to update scrolling behavior based on content size
    local function updateScrollingBehavior()
        local uiListLayout = scroll:FindFirstChild('UIListLayout')
        if not uiListLayout then
            return
        end

        local contentSize = uiListLayout.AbsoluteContentSize.Y
        local frameSize = scroll.AbsoluteSize.Y
        local padding = 16 -- 6px top + 10px bottom padding

        if contentSize <= frameSize - padding then
            -- Content fits within frame, disable scrolling
            scroll.CanvasSize = UDim2.new(0, 0, 0, contentSize + padding)
            scroll.ScrollBarThickness = 0
            scroll.ScrollBarImageTransparency = 1
            scroll.ScrollingEnabled = false
        else
            -- Content exceeds frame, enable scrolling with exact fit
            scroll.CanvasSize = UDim2.new(0, 0, 0, contentSize + padding)
            scroll.ScrollBarThickness = 6
            scroll.ScrollBarImageTransparency = 0.5
            scroll.ScrollingEnabled = true
        end
    end

    -- Update scrolling behavior when content changes
    task.defer(function()
        local uiListLayout = scroll:FindFirstChild('UIListLayout')
        if uiListLayout then
            bind(
                uiListLayout
                    :GetPropertyChangedSignal('AbsoluteContentSize')
                    :Connect(updateScrollingBehavior)
            )
        end
        bind(
            scroll
                :GetPropertyChangedSignal('AbsoluteSize')
                :Connect(updateScrollingBehavior)
        )
        -- Initial update
        updateScrollingBehavior()
    end)

    -- Anti-AFK section (at the top)
    Components.SectionLabel('ANTI-AFK', scroll)
    local antiAfkRow = New('Frame', {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    -- Anti-AFK toggle button
    local antiAfkBtn = Components.PillButton({
        Parent = antiAfkRow,
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 3,
        LayoutOrder = 1,
    })

    -- Anti-AFK label
    New('TextLabel', {
        Parent = antiAfkRow,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Anti-AFK',
        TextColor3 = Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        ZIndex = 3,
    })

    -- Anti-AFK functionality
    bind(antiAfkBtn.MouseButton1Click:Connect(function()
        antiAfkEnabled = not antiAfkEnabled
        Components.SetState(
            antiAfkBtn,
            antiAfkEnabled and 'on' or 'off',
            antiAfkEnabled and Success or DefaultButton
        )

        if antiAfkEnabled then
            startAntiAfkThread()
            showInternalToast('Anti-AFK', 'Anti-AFK enabled', Success)
        else
            stopAntiAfkThread()
            showInternalToast('Anti-AFK', 'Anti-AFK disabled', Muted)
        end
    end))

    -- Set initial state
    Components.SetState(
        antiAfkBtn,
        antiAfkEnabled and 'on' or 'off',
        antiAfkEnabled and Success or DefaultButton
    )

    refs.antiAfkBtn = antiAfkBtn

    -- Webhook section
    Components.SectionLabel('WEBHOOK', scroll)
    local webhookRow = New('Frame', {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
        }),
    })
    local webhookBox = New('TextBox', {
        Parent = webhookRow,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Surface,
        Text = webhookUrl,
        PlaceholderText = 'Webhook URL',
        TextColor3 = Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        ClearTextOnFocus = false,
        ZIndex = 3,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 16) }),
        New('UIStroke', { Color = Stroke, Thickness = 1, Transparency = 0.3 }),
        New(
            'UIPadding',
            { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }
        ),
    })
    bind(webhookBox:GetPropertyChangedSignal('Text'):Connect(function()
        webhookUrl = webhookBox.Text
    end))
    refs.webhookBox = webhookBox

    local webhookControlsRow = New('Frame', {
        Parent = webhookRow,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 4,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    local pingApi = Components.CycleButton({
        Parent = webhookControlsRow,
        Size = UDim2.new(0, 120, 0, 30),
        Title = 'Ping on',
        CurrentValue = webhookPingMode,
        Options = {
            { label = 'None', value = 'None' },
            { label = 'All', value = 'All' },
            { label = 'Brainrot', value = 'Brainrot' },
            { label = 'Seeds', value = 'Seed' },
            { label = 'Gears', value = 'Gear' },
        },
    })
    pingApi.OnChanged(function(v)
        webhookPingMode = v
    end)
    refs.pingApi = pingApi

    local webhookButtons = New('Frame', {
        Parent = webhookControlsRow,
        Size = UDim2.new(1, -128, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 5,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8, 0, 0),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
        }),
    })

    refs.webhookToggleBtn = Components.PillButton({
        Parent = webhookButtons,
        Size = UDim2.new(0, 40, 0, 28),
        Text = webhookEnabled and 'On' or 'Off',
        ZIndex = 6,
    })
    Components.SetState(
        refs.webhookToggleBtn,
        webhookEnabled and 'on' or 'off',
        webhookEnabled and Success or DefaultButton
    )
    bind(refs.webhookToggleBtn.MouseButton1Click:Connect(function()
        webhookEnabled = not webhookEnabled
        refs.webhookToggleBtn.Text = webhookEnabled and 'On' or 'Off'
        Components.SetState(
            refs.webhookToggleBtn,
            webhookEnabled and 'on' or 'off',
            webhookEnabled and Success or DefaultButton
        )
    end))

    local webhookTestBtn = Components.PillButton({
        Parent = webhookButtons,
        Size = UDim2.new(0, 52, 0, 28),
        Text = 'Test',
        ZIndex = 6,
    })
    bind(webhookTestBtn.MouseButton1Click:Connect(function()
        if not webhookUrl or webhookUrl == '' then
            return showInternalToast(
                'Webhook',
                'Set a webhook URL first.',
                Danger
            )
        end
        local mentionPrefix = ''
        if
            webhookPingMode == 'All'
            or webhookPingMode == 'Brainrot'
            or webhookPingMode == 'Seed'
            or webhookPingMode == 'Gear'
        then
            mentionPrefix = '@everyone'
        end
        local ok = sendWebhook({
            content = (mentionPrefix ~= '') and mentionPrefix or nil,
            embeds = {
                {
                    title = 'Webhook Test Successful',
                    description = 'If you received this, your webhook is working correctly. Pinging is set to: **'
                        .. webhookPingMode
                        .. '**',
                    color = color3ToDecimal(Success),
                    timestamp = os.date('!%Y-%m-%dT%H:%M:%S.000Z'),
                },
            },
        })
        if ok then
            showInternalToast('Webhook', 'Test sent successfully.', Success)
        else
            showInternalToast(
                'Webhook',
                'Test failed. Check URL and executor HTTP permissions.',
                Danger
            )
        end
    end))

    local forceSeedAlertBtn = Components.PillButton({
        Parent = webhookButtons,
        Size = UDim2.new(0, 52, 0, 28),
        Text = 'Seed Test',
        ZIndex = 6,
    })
    bind(forceSeedAlertBtn.MouseButton1Click:Connect(function()
        if not seedAlertEnabled then
            return showInternalToast(
                'Test',
                'Enable seed alerts first!',
                Danger
            )
        end

        -- Scan actual in-game shop for seeds that match selected rarity filters
        local player = game:GetService('Players').LocalPlayer
        if not player or not player.PlayerGui then
            return showInternalToast('Test', 'Player not found!', Danger)
        end

        local seedsPath = player.PlayerGui:FindFirstChild('Main')
        if seedsPath then
            seedsPath = seedsPath:FindFirstChild('Seeds')
        end
        if seedsPath then
            seedsPath = seedsPath:FindFirstChild('Frame')
        end
        if seedsPath then
            seedsPath = seedsPath:FindFirstChild('ScrollingFrame')
        end

        if not seedsPath then
            return showInternalToast(
                'Test',
                'Seed shop not found! Open the seed shop first.',
                Danger
            )
        end

        local newStocked, names = {}, {}

        -- Scan all seed items in the shop
        for _, child in pairs(seedsPath:GetChildren()) do
            if
                child:IsA('Frame')
                and child.Name ~= 'Padding'
                and child.Name ~= 'UIPadding'
                and child.Name ~= 'UIListLayout'
            then
                local titleLabel = child:FindFirstChild('title')
                local rarityLabel = child:FindFirstChild('rarity')
                local stockLabel = child:FindFirstChild('stock')

                if titleLabel and rarityLabel and stockLabel then
                    local seedName = titleLabel.Text or ''
                    local rarityText = rarityLabel.Text or ''
                    local stockText = stockLabel.Text or ''

                    -- Parse rarity from the rarity label
                    local rarity = parseSeedRarity(rarityText)

                    -- Check if this specific seed is selected in our filters
                    if selectedSeedFilters[seedName] then
                        local stockCount = parseStockCount(stockText)
                        if stockCount > 0 then
                            table.insert(newStocked, {
                                name = seedName,
                                stock = stockCount,
                                rarity = rarity,
                            })
                            table.insert(names, seedName)
                        end
                    end
                end
            end
        end

        if #newStocked == 0 then
            return showInternalToast(
                'Test',
                'No seeds in stock matching selected rarities.',
                Danger
            )
        end
        showInternalToast(
            'Test',
            'Forcing test alert for matching seeds in shop...',
            AccentA
        )
        local title = #names == 1
                and string.format("'%s' in Stock! (Test)", names[1])
            or string.format('%d Seeds in Stock! (Test)', #names)
        local parts, hr, hv = {}, 'Rare', 0
        for _, e in ipairs(newStocked) do
            table.insert(
                parts,
                ('%s (%s) x%d'):format(e.name, e.rarity, e.stock)
            )
            local v = RARITY_VALUE[e.rarity] or 0
            if v > hv then
                hv = v
                hr = e.rarity
            end
        end
        Alerts_ShowSeedToast(
            title,
            table.concat(parts, ' • '),
            Rarities[hr] or AccentB,
            true
        )
    end))

    -- UI scale
    Components.SectionLabel('UI SCALE', scroll)

    -- Sidebar scale - find in the sidebar GUI
    local sidebarScaleObj = nil
    local sidebarGui = CoreGui:FindFirstChild(existingGuiName .. '_Sidebar')
    if sidebarGui then
        -- Look for the sidebar frame and its UIScale
        for _, child in pairs(sidebarGui:GetChildren()) do
            if child:IsA('Frame') and child:FindFirstChild('UIScale') then
                sidebarScaleObj = child:FindFirstChild('UIScale')
                break
            end
        end
    end

    local sidebarScaleSlider = Components.Slider({
        Parent = scroll,
        Size = UDim2.new(1, 0, 0, 32),
        Title = 'Sidebar Scale',
        ValueText = function(s)
            return string.format('%d%%', math.floor(s * 100 + 0.5))
        end,
    })
    sidebarScaleSlider.OnChanged(function(a)
        local newScale = math.clamp(0.5 + a * 1.5, 0.5, 2.0)
        sidebarScale = newScale -- Update global variable
        if sidebarScaleObj then
            sidebarScaleObj.Scale = newScale
        end

        -- Dynamically adjust unload button position based on scale
        if sidebarApi and sidebarApi.updateUnloadButtonPosition then
            sidebarApi.updateUnloadButtonPosition(newScale)
        end

        -- Update any fullscreen windows to adapt to new sidebar scale
        for windowType, window in pairs(openWindows or {}) do
            if window and window.Parent then
                -- Check if this window is currently fullscreen using improved detection
                local windowSize = window.Size
                local screenSize = Workspace.CurrentCamera.ViewportSize

                local isCurrentlyFullscreen = false
                if windowSize.X.Scale == 1 and windowSize.X.Offset < -50 then
                    -- Window is using scale-based sizing and has negative offset (indicating it's sized to fill screen minus some space)
                    isCurrentlyFullscreen = true
                elseif windowSize.X.Offset > screenSize.X * 0.7 then
                    -- Window is using absolute sizing and is wider than 70% of screen
                    isCurrentlyFullscreen = true
                end

                if isCurrentlyFullscreen then
                    -- Recalculate fullscreen size and position based on new scale
                    local sidebarScale = newScale
                    local sidebarWidth = (
                        sidebarApi and sidebarApi.isExpanded and 200 or 60
                    ) * sidebarScale
                    local newFullscreenSize =
                        UDim2.new(1, -sidebarWidth - 10, 1, -10)

                    -- Check sidebar location to position window correctly
                    local sidebarLocation = sidebarApi
                            and sidebarApi.sidebarLocation
                        or 'Left'
                    local newFullscreenPosition
                    if sidebarLocation == 'Right' then
                        -- Sidebar is on right, position window on left side
                        newFullscreenPosition = UDim2.new(0, 5, 0, 5)
                    else
                        -- Sidebar is on left, position window on right side
                        newFullscreenPosition =
                            UDim2.new(0, sidebarWidth + 5, 0, 5)
                    end

                    -- Animate to new fullscreen size immediately
                    TweenService
                        :Create(
                            window,
                            TweenInfo.new(
                                0.3,
                                Enum.EasingStyle.Quart,
                                Enum.EasingDirection.Out
                            ),
                            {
                                Size = newFullscreenSize,
                                Position = newFullscreenPosition,
                            }
                        )
                        :Play()
                end
            end
        end
    end)
    if sidebarScaleObj then
        sidebarScaleObj.Scale = sidebarScale -- Apply global value to the scale object
    end
    sidebarScaleSlider.Set(math.clamp((sidebarScale - 0.5) / 1.5, 0, 1))
    refs.sidebarScaleSlider = sidebarScaleSlider

    -- Apply correct colors immediately after creation
    sidebarScaleSlider.updateColors()

    -- Game Info Scale
    local gameInfoScaleSlider = Components.Slider({
        Parent = scroll,
        Size = UDim2.new(1, 0, 0, 32),
        Title = 'Game Info Scale',
        ValueText = function(s)
            return string.format('%d%%', math.floor(s * 100 + 0.5))
        end,
    })
    gameInfoScaleSlider.OnChanged(function(a)
        gameInfoScale = math.clamp(0.5 + a * 1.5, 0.5, 2.0)
        if gameInfoScaleObj then
            gameInfoScaleObj.Scale = gameInfoScale
        end
    end)
    gameInfoScaleSlider.Set(math.clamp((gameInfoScale - 0.5) / 1.5, 0, 1))
    refs.gameInfoScaleSlider = gameInfoScaleSlider

    -- Apply correct colors immediately after creation
    gameInfoScaleSlider.updateColors()

    -- Toast scale
    local toastScaleSlider = Components.Slider({
        Parent = scroll,
        Size = UDim2.new(1, 0, 0, 32),
        Title = 'Toast Scale',
        ValueText = function(s)
            return string.format('%d%%', math.floor(s * 100 + 0.5))
        end,
    })
    toastScaleSlider.OnChanged(function(a)
        toastScale = 0.5 + a * 1.5 -- Update global variable
        for _, container in ipairs({
            toastContainer,
            seedToastContainer,
            gearToastContainer,
        }) do
            if container and container.Parent then
                local s = container:FindFirstChild('UIScale')
                if s then
                    s.Scale = toastScale
                end
            end
        end
    end)
    toastScaleSlider.Set((toastScale - 0.5) / 1.5)
    refs.toastScaleSlider = toastScaleSlider

    -- Apply correct colors immediately after creation
    toastScaleSlider.updateColors()

    -- Theme switcher
    Components.SectionLabel('THEME', scroll)

    local themeRow = New('Frame', {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    New('TextLabel', {
        Parent = themeRow,
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = 'Theme',
        TextColor3 = Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    local themeApi = Components.CycleButton({
        Parent = themeRow,
        Size = UDim2.new(0, 120, 0, 30),
        Title = 'Mode',
        Options = {
            { label = 'Dark', value = 'dark' },
            { label = 'Light', value = 'light' },
        },
        CurrentValue = theme,
    })
    themeApi.OnChanged(function(newTheme)
        applyTheme(newTheme)
        showInternalToast(
            'Theme',
            'Theme changed to '
                .. (newTheme == 'dark' and 'Dark' or 'Light')
                .. ' mode',
            Success
        )
    end)
    refs.themeApi = themeApi

    -- Sidebar behavior
    Components.SectionLabel('SIDEBAR', scroll)

    -- Keep sidebar open toggle
    local sidebarRow = New('Frame', {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    New('TextLabel', {
        Parent = sidebarRow,
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = 'Keep Sidebar Open',
        TextColor3 = Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    local keepSidebarBtn = Components.PillButton({
        Parent = sidebarRow,
        Size = UDim2.new(0, 60, 0, 28),
        Text = keepSidebarOpen and 'On' or 'Off',
        ZIndex = 6,
    })
    Components.SetState(
        keepSidebarBtn,
        keepSidebarOpen,
        keepSidebarOpen and Success or DefaultButton
    )
    bind(keepSidebarBtn.MouseButton1Click:Connect(function()
        keepSidebarOpen = not keepSidebarOpen
        keepSidebarBtn.Text = keepSidebarOpen and 'On' or 'Off'
        Components.SetState(
            keepSidebarBtn,
            keepSidebarOpen,
            keepSidebarOpen and Success or DefaultButton
        )

        -- If turning off "Keep Sidebar Open", close the sidebar immediately
        if not keepSidebarOpen and sidebarApi then
            -- Force close sidebar directly by calling the toggle function
            if sidebarApi.toggleSidebar then
                -- Check if sidebar is expanded and force close it
                if sidebarApi.isExpanded then
                    sidebarApi.toggleSidebar()
                end
            end
        end
    end))
    refs.keepSidebarBtn = keepSidebarBtn

    -- Mobile button toggle
    local mobileButtonRow = New('Frame', {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    New('TextLabel', {
        Parent = mobileButtonRow,
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = 'Mobile Button',
        TextColor3 = Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    local mobileButtonToggle = Components.PillButton({
        Parent = mobileButtonRow,
        Size = UDim2.new(0, 60, 0, 28),
        Text = mobileButtonEnabled and 'On' or 'Off',
        ZIndex = 6,
    })
    Components.SetState(
        mobileButtonToggle,
        mobileButtonEnabled,
        mobileButtonEnabled and Success or DefaultButton
    )
    bind(mobileButtonToggle.MouseButton1Click:Connect(function()
        mobileButtonEnabled = not mobileButtonEnabled
        mobileButtonToggle.Text = mobileButtonEnabled and 'On' or 'Off'
        Components.SetState(
            mobileButtonToggle,
            mobileButtonEnabled,
            mobileButtonEnabled and Success or DefaultButton
        )

        -- Apply mobile button setting immediately by finding the brand icon in the sidebar
        local sidebarGui = CoreGui:FindFirstChild(existingGuiName .. '_Sidebar')
        if sidebarGui then
            local sidebar = sidebarGui:FindFirstChild('Frame')
            if sidebar then
                local brandIcon = sidebar:FindFirstChild('BrandIcon')
                if brandIcon then
                    brandIcon.Visible = mobileButtonEnabled
                end
            end
        end
    end))
    refs.mobileButtonToggle = mobileButtonToggle

    -- Sidebar location dropdown
    local sidebarLocationRow = New('Frame', {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    New('TextLabel', {
        Parent = sidebarLocationRow,
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = 'Sidebar Location',
        TextColor3 = Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    local sidebarLocationDropdown = Components.CycleButton({
        Parent = sidebarLocationRow,
        Size = UDim2.new(0, 80, 0, 30),
        Title = 'Location',
        Options = {
            { label = 'Left', value = 'Left' },
            { label = 'Right', value = 'Right' },
        },
        CurrentValue = sidebarLocation,
    })
    sidebarLocationDropdown.OnChanged(function(newValue)
        sidebarLocation = newValue

        -- Apply sidebar location setting with smooth animation
        local sidebarGui = CoreGui:FindFirstChild(existingGuiName .. '_Sidebar')
        if sidebarGui then
            local sidebar = sidebarGui:FindFirstChild('Frame')
            if sidebar then
                -- Determine target position based on new location
                local targetPosition
                if sidebarLocation == 'Right' then
                    targetPosition = UDim2.new(1, -70, 0, 10) -- Right side
                else
                    targetPosition = UDim2.new(0, 10, 0, 10) -- Left side
                end

                -- Animate the sidebar to the new position (respects disableAnimations setting)
                local positionTween = FX.CreateTween(
                    sidebar,
                    TweenInfo.new(
                        0.3,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                    ),
                    {
                        Position = targetPosition,
                    }
                )
                positionTween:Play()

                -- Don't move existing windows when changing sidebar position
                -- Windows should maintain their current positions

                -- Also update the toggleSidebar function to use the new location
                -- We need to store the current location in the sidebar for the toggle function to use
                sidebar:SetAttribute('SidebarLocation', sidebarLocation)
            end
        end
    end)
    refs.sidebarLocationDropdown = sidebarLocationDropdown

    -- Performance section
    Components.SectionLabel('PERFORMANCE', scroll)

    -- Disable blur toggle
    local blurRow = New('Frame', {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    New('TextLabel', {
        Parent = blurRow,
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = 'Disable Blur',
        TextColor3 = Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    local disableBlurBtn = Components.PillButton({
        Parent = blurRow,
        Size = UDim2.new(0, 60, 0, 28),
        Text = disableBlur and 'On' or 'Off',
        ZIndex = 6,
    })
    Components.SetState(
        disableBlurBtn,
        disableBlur,
        disableBlur and Success or DefaultButton
    )
    bind(disableBlurBtn.MouseButton1Click:Connect(function()
        disableBlur = not disableBlur
        disableBlurBtn.Text = disableBlur and 'On' or 'Off'
        Components.SetState(
            disableBlurBtn,
            disableBlur,
            disableBlur and Success or DefaultButton
        )

        -- Apply blur setting immediately
        FX.TweenBlur(not disableBlur)
    end))
    refs.disableBlurBtn = disableBlurBtn

    -- Disable animations toggle
    local animationsRow = New('Frame', {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    New('TextLabel', {
        Parent = animationsRow,
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Text = 'Disable Animations',
        TextColor3 = Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    local disableAnimationsBtn = Components.PillButton({
        Parent = animationsRow,
        Size = UDim2.new(0, 60, 0, 28),
        Text = disableAnimations and 'On' or 'Off',
        ZIndex = 6,
    })
    Components.SetState(
        disableAnimationsBtn,
        disableAnimations,
        disableAnimations and Success or DefaultButton
    )
    bind(disableAnimationsBtn.MouseButton1Click:Connect(function()
        disableAnimations = not disableAnimations
        disableAnimationsBtn.Text = disableAnimations and 'On' or 'Off'
        Components.SetState(
            disableAnimationsBtn,
            disableAnimations,
            disableAnimations and Success or DefaultButton
        )
    end))
    refs.disableAnimationsBtn = disableAnimationsBtn

    -- Config section
    Components.SectionLabel('CONFIG', scroll)
    local configRow = New('Frame', {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = scroll,
        ZIndex = 2,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    local nameBox, configSelectApi
    function refreshConfigs(selectName)
        task.delay(0.2, function()
            local names = listConfigNames()
            if configSelectApi and configSelectApi.SetItems then
                configSelectApi.SetItems(names)
                if selectName and configSelectApi.SetSelectedByName then
                    configSelectApi.SetSelectedByName(selectName)
                end
            end
        end)
    end

    local saveCfgBtn = Components.PillButton({
        Parent = configRow,
        Size = UDim2.new(0, 96, 0, 28),
        Text = 'Save',
        ZIndex = 3,
    })
    bind(saveCfgBtn.MouseButton1Click:Connect(function()
        local typed = (nameBox and nameBox.Text) or ''
        local name = sanitizeFileName(typed)
        if name == 'default' and typed ~= 'default' then
            showTopCenterToast("Name invalid, using 'default'")
        end
        saveConfig(name, refs)
        nameBox.Text = name
        refreshConfigs(name)
    end))

    local loadCfgBtn = Components.PillButton({
        Parent = configRow,
        Size = UDim2.new(0, 96, 0, 28),
        Text = 'Load',
        ZIndex = 3,
    })
    bind(loadCfgBtn.MouseButton1Click:Connect(function()
        local picked = (
            configSelectApi
            and configSelectApi.GetSelected
            and configSelectApi:GetSelected()
        )
        local typed = (nameBox and nameBox.Text)
        local name = sanitizeFileName(
            (picked and picked ~= '' and picked)
                or (typed and typed ~= '' and typed)
                or 'default'
        )
        loadConfig(uiRefs, name)
        showTopCenterToast('Config loaded: ' .. name)
    end))

    configSelectApi, _ = Components.SingleSelectDropdown({
        Parent = configRow,
        Size = UDim2.new(0, 180, 0, 30),
        Title = 'Configs',
        Items = listConfigNames(),
        Placeholder = 'Select...',
        ZIndex = 3,
        OnDeleteItem = function(name)
            if not name or name == '' then
                return
            end
            if deleteConfig(name) then
                showTopCenterToast('Deleted config: ' .. name)
            else
                showTopCenterToast('Delete failed')
            end
            refreshConfigs()
        end,
    })
    refs.configSelectApi = configSelectApi

    nameBox = New('TextBox', {
        Parent = configRow,
        Size = UDim2.new(1, -400, 1, -4),
        BackgroundColor3 = Surface,
        Text = 'default',
        PlaceholderText = 'config name',
        TextColor3 = Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        ClearTextOnFocus = false,
        ZIndex = 3,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 16) }),
        New('UIStroke', { Color = Stroke, Thickness = 1, Transparency = 0.3 }),
        New(
            'UIPadding',
            { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }
        ),
    })
    refs.nameBox = nameBox
    -- Apply theme to all sliders in settings page after they're created
    local function applyThemeToSliders(instance)
        if not instance or not instance.Parent then
            return
        end

        -- Handle slider components specially - different colors for light/dark mode
        if instance:IsA('Frame') and instance.Name == 'bar' then
            -- This is a slider bar - apply theme color
            instance.BackgroundColor3 = Surface
            return
        elseif instance:IsA('Frame') and instance.Name == 'fill' then
            -- This is a slider fill - orange in light mode, blue in dark mode
            if theme == 'light' then
                instance.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Orange
            else
                instance.BackgroundColor3 = Color3.fromRGB(59, 130, 246) -- Blue in dark mode
            end
            return
        elseif instance:IsA('Frame') and instance.Name == 'knob' then
            -- This is a slider knob - white in both light and dark mode
            instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White
            local stroke = instance:FindFirstChild('UIStroke')
            if stroke then
                stroke.Color = Color3.fromRGB(59, 130, 246) -- Blue outline in both modes
            end
            return
        end

        -- Recursively apply to children
        for _, child in ipairs(instance:GetChildren()) do
            applyThemeToSliders(child)
        end
    end
    -- Apply theme to all sliders in the settings page
    if refs.sidebarScaleSlider then
        refs.sidebarScaleSlider.updateColors()
        -- Also apply theme directly to the slider components
        local fill, knob = refs.sidebarScaleSlider.getParts()
        if fill and knob then
            -- Force apply the correct colors
            if theme == 'light' then
                fill.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Orange
            else
                fill.BackgroundColor3 = Color3.fromRGB(59, 130, 246) -- Blue
            end
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White
            local stroke = knob:FindFirstChild('UIStroke')
            if stroke then
                if theme == 'light' then
                    stroke.Color = Color3.fromRGB(128, 0, 128) -- Purple outline in light mode
                else
                    stroke.Color = Color3.fromRGB(59, 130, 246) -- Blue outline in dark mode
                end
            end
        else
        end
    else
    end
    if refs.gameInfoScaleSlider then
        refs.gameInfoScaleSlider.updateColors()
        -- Also apply theme directly to the slider components
        local fill, knob = refs.gameInfoScaleSlider.getParts()
        if fill and knob then
            -- Force apply the correct colors
            if theme == 'light' then
                fill.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Orange
            else
                fill.BackgroundColor3 = Color3.fromRGB(59, 130, 246) -- Blue
            end
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White
            local stroke = knob:FindFirstChild('UIStroke')
            if stroke then
                if theme == 'light' then
                    stroke.Color = Color3.fromRGB(128, 0, 128) -- Purple outline in light mode
                else
                    stroke.Color = Color3.fromRGB(59, 130, 246) -- Blue outline in dark mode
                end
            end
        end
    end
    if refs.toastScaleSlider then
        refs.toastScaleSlider.updateColors()
        -- Also apply theme directly to the slider components
        local fill, knob = refs.toastScaleSlider.getParts()
        if fill and knob then
            -- Force apply the correct colors
            if theme == 'light' then
                fill.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Orange
            else
                fill.BackgroundColor3 = Color3.fromRGB(59, 130, 246) -- Blue
            end
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White
            local stroke = knob:FindFirstChild('UIStroke')
            if stroke then
                if theme == 'light' then
                    stroke.Color = Color3.fromRGB(128, 0, 128) -- Purple outline in light mode
                else
                    stroke.Color = Color3.fromRGB(59, 130, 246) -- Blue outline in dark mode
                end
            end
        end
    end

    return refs
end

function Components.buildMiscPage(parent)
    local refs = {}

    -- Create main card
    local mainCard = New('Frame', {
        Size = UDim2.new(1, -20, 0, 300),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Card,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 2,
    }, {
        New('UICorner', { CornerRadius = UDim.new(0, 12) }),
        New('UIStroke', { Color = Stroke, Thickness = 1, Transparency = 0.3 }),
    })

    -- Title
    Components.SectionLabel('MISCELLANEOUS', mainCard, 10)

    -- Claim All Codes section
    local claimCodesRow = New('Frame', {
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        Parent = mainCard,
        ZIndex = 3,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    -- Claim All Codes button
    local claimCodesBtn = Components.PillButton({
        Parent = claimCodesRow,
        Size = UDim2.new(0, 120, 0, 30),
        Text = 'Claim All Codes',
        TextSize = 14,
        LayoutOrder = 1,
    })

    -- Claim All Codes label
    New('TextLabel', {
        Parent = claimCodesRow,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Attempts to claim all available codes',
        TextColor3 = Muted,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        ZIndex = 3,
    })

    -- Claim All Codes functionality
    bind(claimCodesBtn.MouseButton1Click:Connect(function()
        local codes = { 'STACKS', 'based', 'frozen' }
        local claimedCount = 0
        local failedCount = 0
        local results = {}

        for i, code in ipairs(codes) do
            local success, error = pcall(function()
                local replicatedStorage = game:GetService('ReplicatedStorage')
                local remotes = replicatedStorage:FindFirstChild('Remotes')

                if not remotes then
                    error('Remotes folder not found')
                    return false
                end

                local claimCode = remotes:FindFirstChild('ClaimCode')
                if not claimCode then
                    error('ClaimCode remote not found')
                    return false
                end

                -- Try to claim with specific code
                claimCode:FireServer(code)
                return true
            end)

            if success then
                claimedCount = claimedCount + 1
                table.insert(results, code .. ': Success')
            else
                failedCount = failedCount + 1
                table.insert(results, code .. ': Failed - ' .. tostring(error))
            end

            -- Small delay between claims to avoid spam (outside pcall so it always executes)
            if i < #codes then -- Don't delay after the last code
                task.wait(2)
            end
        end

        -- Show detailed result toast
        local resultText = table.concat(results, ' | ')
        if claimedCount > 0 then
            showInternalToast(
                'Claim All Codes',
                string.format(
                    'Attempted %d codes: %s',
                    claimedCount,
                    resultText
                ),
                Success
            )
        else
            showInternalToast(
                'Claim All Codes',
                string.format('Failed all codes: %s', resultText),
                Danger
            )
        end
    end))

    refs.claimCodesBtn = claimCodesBtn

    -- Check Worth section
    local checkWorthRow = New('Frame', {
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 100),
        BackgroundTransparency = 1,
        Parent = mainCard,
        ZIndex = 3,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    -- Check Worth button
    local checkWorthBtn = Components.PillButton({
        Parent = checkWorthRow,
        Size = UDim2.new(0, 120, 0, 30),
        Text = 'Check Worth',
        ZIndex = 3,
        LayoutOrder = 1,
    })

    -- Check Worth label
    New('TextLabel', {
        Parent = checkWorthRow,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "Reads worth from Barry's dialogue",
        TextColor3 = Muted,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        ZIndex = 3,
    })

    -- Check Worth functionality
    bind(checkWorthBtn.MouseButton1Click:Connect(function()
        -- Fire the CheckWorth remote
        local success, error = pcall(function()
            local replicatedStorage = game:GetService('ReplicatedStorage')
            local remotes = replicatedStorage:FindFirstChild('Remotes')

            if remotes then
                local checkWorth = remotes:FindFirstChild('CheckWorth')
                if checkWorth then
                    checkWorth:FireServer()
                    print('[Check Worth] Remote fired successfully')
                    return true
                end
            end
        end)

        if success then
            -- Wait a moment for the dialogue to update, then read it
            task.wait(1)

            -- Read from Barry's dialogue (use player's plot)
            local playerPlot = getMyPlot()
            local barryDialogue = nil
            if playerPlot then
                local npcs = playerPlot:FindFirstChild('NPCs')
                if npcs then
                    local barry = npcs:FindFirstChild('Barry')
                    if barry then
                        local dialogue = barry:FindFirstChild('Dialogue')
                        if dialogue then
                            local main = dialogue:FindFirstChild('Main')
                            if main then
                                barryDialogue = main:FindFirstChild('TextLabel')
                            end
                        end
                    end
                end
            end
            if barryDialogue and barryDialogue.Text then
                local rawText = barryDialogue.Text
                print('[Check Worth] Raw text:', rawText)

                -- Extract the worth value from the text
                -- Format: "It's worth <font color='#00FF00'>$253,787</font>."
                -- Try multiple patterns to catch different formats
                local worthMatch = nil

                -- Pattern 1: Standard format with font tag
                worthMatch =
                    rawText:match("<font color='#00FF00'>([^<]+)</font>")

                -- Pattern 2: Try without quotes around color
                if not worthMatch then
                    worthMatch =
                        rawText:match('<font color=#00FF00>([^<]+)</font>')
                end

                -- Pattern 3: Try with different color codes
                if not worthMatch then
                    worthMatch =
                        rawText:match("<font color='#%w+'>([^<]+)</font>")
                end

                -- Pattern 4: Try to find any dollar amount in the text
                if not worthMatch then
                    worthMatch = rawText:match('%$([0-9,]+)')
                end

                if worthMatch then
                    -- Clean up the worth value (remove $ and commas)
                    local cleanWorth = worthMatch:gsub('%$', ''):gsub(',', '')
                    local worthNumber = tonumber(cleanWorth)

                    if worthNumber then
                        -- Format the number back with commas
                        local formattedWorth = tostring(worthNumber)
                        -- Add commas manually
                        formattedWorth = formattedWorth
                            :reverse()
                            :gsub('(%d%d%d)', '%1,')
                            :reverse()
                            :gsub('^,', '')

                        -- Show toast notification with sound effect (same as brainrot, gear and seed alerts)
                        showInternalToast(
                            'Check Worth',
                            'Your worth: $' .. formattedWorth,
                            Success
                        )

                        -- Play sound effect (same as other alerts)
                        if alertSoundEnabled and alertSound then
                            alertSound:Play()
                        end

                        print('[Check Worth] Worth found: $' .. formattedWorth)
                    else
                        showInternalToast(
                            'Check Worth',
                            'Could not parse worth value: ' .. worthMatch,
                            Danger
                        )
                        print(
                            '[Check Worth] Could not parse worth value:',
                            worthMatch
                        )
                    end
                else
                    showInternalToast(
                        'Check Worth',
                        'No worth value found in dialogue',
                        Danger
                    )
                    print(
                        '[Check Worth] No worth value found in dialogue:',
                        rawText
                    )
                end
            else
                showInternalToast(
                    'Check Worth',
                    "Could not access Barry's dialogue",
                    Danger
                )
                print("[Check Worth] Could not access Barry's dialogue")
            end
        else
            showInternalToast(
                'Check Worth',
                'Failed to fire CheckWorth remote: ' .. tostring(error),
                Danger
            )
            print('[Check Worth] Failed to fire remote:', error)
        end
    end))

    refs.checkWorthBtn = checkWorthBtn

    -- Teleport to Card Merger section
    local cardMergerRow = New('Frame', {
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 160),
        BackgroundTransparency = 1,
        Parent = mainCard,
        ZIndex = 3,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    -- TP to Card Merger button
    local cardMergerBtn = Components.PillButton({
        Parent = cardMergerRow,
        Size = UDim2.new(0, 120, 0, 30),
        Text = 'TP to Card Merger',
        TextSize = 14,
        LayoutOrder = 1,
    })

    -- Card Merger label
    New('TextLabel', {
        Parent = cardMergerRow,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Teleports to the Card Merger location',
        TextColor3 = Muted,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        ZIndex = 3,
    })

    -- Teleport to Fuse Machine section
    local fuseMachineRow = New('Frame', {
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 220),
        BackgroundTransparency = 1,
        Parent = mainCard,
        ZIndex = 3,
    }, {
        New('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    -- TP to Fuse Machine button
    local fuseMachineBtn = Components.PillButton({
        Parent = fuseMachineRow,
        Size = UDim2.new(0, 120, 0, 30),
        Text = 'TP to Fuse Machine',
        TextSize = 14,
        LayoutOrder = 1,
    })

    -- Fuse Machine label
    New('TextLabel', {
        Parent = fuseMachineRow,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = 'Teleports to the Fuse Machine location',
        TextColor3 = Muted,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        ZIndex = 3,
    })

    -- Teleport functionality
    bind(cardMergerBtn.MouseButton1Click:Connect(function()
        print('DEBUG TP: Attempting to teleport to Card Merger...')
        local scriptedMap = game:GetService('Workspace')
            :FindFirstChild('ScriptedMap')
        if scriptedMap then
            print('DEBUG TP: Found ScriptedMap')
            local cardMerger = scriptedMap:FindFirstChild('CardMerger')
            if cardMerger then
                print('DEBUG TP: Found CardMerger model')
                local base = cardMerger:FindFirstChild('Base')
                if base then
                    print('DEBUG TP: Found CardMerger Base')
                    local children = base:GetChildren()
                    if children[8] then
                        local targetPart = children[8]
                        print(
                            'DEBUG TP: Found CardMerger Base child 8:',
                            targetPart.Name,
                            'at position:',
                            targetPart.Position
                        )
                        local player = game.Players.LocalPlayer
                        if
                            player.Character
                            and player.Character:FindFirstChild(
                                'HumanoidRootPart'
                            )
                        then
                            -- Teleport to the center of the part
                            local targetPosition = targetPart.CFrame
                            player.Character.HumanoidRootPart.CFrame =
                                targetPosition
                            showInternalToast(
                                'Teleport',
                                'Teleported to Card Merger',
                                Success
                            )
                            print(
                                'DEBUG TP: Successfully teleported to Card Merger center'
                            )
                        else
                            showInternalToast(
                                'Teleport',
                                'No character found',
                                Error
                            )
                            print(
                                'DEBUG TP: No character or HumanoidRootPart found'
                            )
                        end
                    else
                        showInternalToast(
                            'Teleport',
                            'Card Merger Base child 8 not found',
                            Error
                        )
                        print('DEBUG TP: CardMerger Base child 8 not found')
                    end
                else
                    showInternalToast(
                        'Teleport',
                        'Card Merger Base not found',
                        Error
                    )
                    print('DEBUG TP: CardMerger Base not found')
                end
            else
                showInternalToast('Teleport', 'Card Merger not found', Error)
                print('DEBUG TP: CardMerger not found in ScriptedMap')
            end
        else
            showInternalToast('Teleport', 'ScriptedMap not found', Error)
            print('DEBUG TP: ScriptedMap not found')
        end
    end))

    bind(fuseMachineBtn.MouseButton1Click:Connect(function()
        print('DEBUG TP: Attempting to teleport to Fuse Machine...')
        local scriptedMap = game:GetService('Workspace')
            :FindFirstChild('ScriptedMap')
        if scriptedMap then
            print('DEBUG TP: Found ScriptedMap')
            local fuseMachine = scriptedMap:FindFirstChild('FuseMachine')
            if fuseMachine then
                print('DEBUG TP: Found FuseMachine model')
                local floor = fuseMachine:FindFirstChild('Floor')
                if floor then
                    print(
                        'DEBUG TP: Found FuseMachine Floor at position:',
                        floor.Position
                    )
                    local player = game.Players.LocalPlayer
                    if
                        player.Character
                        and player.Character:FindFirstChild('HumanoidRootPart')
                    then
                        local targetPosition = floor.CFrame
                            + Vector3.new(0, 5, 0)
                        player.Character.HumanoidRootPart.CFrame =
                            targetPosition
                        showInternalToast(
                            'Teleport',
                            'Teleported to Fuse Machine',
                            Success
                        )
                        print(
                            'DEBUG TP: Successfully teleported to Fuse Machine Floor'
                        )
                    else
                        showInternalToast(
                            'Teleport',
                            'No character found',
                            Error
                        )
                        print(
                            'DEBUG TP: No character or HumanoidRootPart found'
                        )
                    end
                else
                    showInternalToast(
                        'Teleport',
                        'Fuse Machine Floor not found',
                        Error
                    )
                    print('DEBUG TP: FuseMachine Floor not found')
                end
            else
                showInternalToast('Teleport', 'Fuse Machine not found', Error)
                print('DEBUG TP: FuseMachine not found in ScriptedMap')
            end
        else
            showInternalToast('Teleport', 'ScriptedMap not found', Error)
            print('DEBUG TP: ScriptedMap not found')
        end
    end))

    return refs
end
function buildGui()
    FX.TweenBlur(true)

    -- Clean up any existing sidebar GUI
    pcall(function()
        local existingSidebarGui =
            CoreGui:FindFirstChild(existingGuiName .. '_Sidebar')
        if existingSidebarGui then
            existingSidebarGui:Destroy()
        end
    end)

    -- Create refs table to hold UI element references
    local refs = {}
    -- Store refs globally so UISync functions can access them
    uiRefs = refs

    mainGui = New('ScreenGui', {
        Name = existingGuiName,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Enabled = true,
        Parent = CoreGui,
    })

    -- Create separate ScreenGui for sidebar to prevent main scale inheritance
    sidebarGui = New('ScreenGui', {
        Name = existingGuiName .. '_Sidebar',
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    -- Window management system
    -- Use global openWindows variable for theme updates

    -- Create compact sidebar directly in the main GUI
    sidebarApi = Components.ModernSidebar({
        Parent = sidebarGui,
        openWindows = openWindows,
    })
    local globalDragState = { isDragging = false, draggedWindow = nil } -- Prevent multi-drag
    local windowCount = 0 -- For positioning new windows
    local baseZIndex = 150 -- Base Z-index for windows
    local maxZIndex = 0 -- Track the highest Z-index currently in use

    -- Function to bring a window to the front
    local function bringWindowToFront(targetWindow)
        if not targetWindow or not targetWindow.Parent then
            return
        end

        -- Increment max Z-index and assign to target window
        maxZIndex = maxZIndex + 1
        targetWindow.ZIndex = baseZIndex + maxZIndex

        -- Update all other windows to have lower Z-indexes
        local currentOpenCount = 0
        for _, window in pairs(openWindows) do
            if window and window.Parent then
                currentOpenCount = currentOpenCount + 1
            end
        end

        for windowType, window in pairs(openWindows) do
            if window ~= targetWindow and window.Parent then
                window.ZIndex = baseZIndex + currentOpenCount - 1
            end
        end
    end

    -- Function to create draggable windows
    function createWindow(windowType, title, size)
        -- Don't create duplicate windows - check if it exists and is valid
        if openWindows[windowType] and openWindows[windowType].Parent then
            -- Bring existing window to front
            bringWindowToFront(openWindows[windowType])
            return openWindows[windowType]
        end

        -- Clear any invalid references
        if openWindows[windowType] then
            openWindows[windowType] = nil
        end

        -- Count currently open windows for positioning
        local currentOpenCount = 0
        for _, window in pairs(openWindows) do
            if window and window.Parent then
                currentOpenCount = currentOpenCount + 1
            end
        end

        -- Smart positioning: center if first window, cascade if others exist
        local windowWidth = (size and size.X.Offset) or 600
        local windowHeight = (size and size.Y.Offset) or 400
        local positionX, positionY

        if currentOpenCount == 0 then
            -- First window: center it
            positionX = UDim2.new(0.5, -windowWidth / 2, 0.5, -windowHeight / 2)
        else
            -- Additional windows: cascade them
            local offsetX = currentOpenCount * 30
            local offsetY = currentOpenCount * 30
            positionX = UDim2.new(
                0.5,
                -windowWidth / 2 + offsetX,
                0.5,
                -windowHeight / 2 + offsetY
            )
        end

        -- Create window
        local window = New('Frame', {
            Size = size or UDim2.new(0, 600, 0, 400),
            Position = positionX,
            BackgroundColor3 = Color3.fromRGB(28, 30, 36),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = mainGui,
            Name = windowType .. 'Window',
            ZIndex = baseZIndex + currentOpenCount + 1,
        }, {
            New('UICorner', { CornerRadius = UDim.new(0, 12) }),
            New('UIStroke', {
                Color = Stroke,
                Thickness = 1,
                Transparency = 0.3,
            }),
        })

        -- Store original properties for pop-in animation
        window:SetAttribute('OriginalSize', size or UDim2.new(0, 600, 0, 400))
        window:SetAttribute('OriginalPosition', positionX)
        window:SetAttribute('CurrentPosition', positionX) -- Store current position for restoration

        -- Window title bar
        local titleBar = New('TextButton', {
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Card, -- Use theme color (white in light mode)
            BorderSizePixel = 0,
            Text = '', -- Empty text since we have a separate title label
            Name = 'TitleBar',
            Parent = window,
        }, {
            New('UICorner', { CornerRadius = UDim.new(0, 12) }),
        })

        -- Title text
        local titleText = New('TextLabel', {
            Size = UDim2.new(1, -80, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = titleBar,
        })

        -- Minimize button
        local minimizeBtn = New('TextButton', {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -105, 0, 5),
            BackgroundColor3 = Color3.fromRGB(255, 193, 7),
            Text = '−',
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Parent = titleBar,
        }, {
            New('UICorner', { CornerRadius = UDim.new(0, 6) }),
        })

        -- Fullscreen button
        local fullscreenBtn = New('TextButton', {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -70, 0, 5),
            BackgroundColor3 = Color3.fromRGB(100, 150, 255),
            Text = '☆',
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Parent = titleBar,
        }, {
            New('UICorner', { CornerRadius = UDim.new(0, 6) }),
        })

        -- Close button
        local closeBtn = New('TextButton', {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -35, 0, 5),
            BackgroundColor3 = Color3.fromRGB(255, 90, 90),
            Text = '×',
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Parent = titleBar,
        }, {
            New('UICorner', { CornerRadius = UDim.new(0, 6) }),
        })

        -- Content area
        local contentArea = New('ScrollingFrame', {
            Size = UDim2.new(1, -20, 1, -60),
            Position = UDim2.new(0, 10, 0, 50),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            ScrollBarImageTransparency = 1,
            ScrollingEnabled = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = window,
        }, {
            New(
                'UIPadding',
                {
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 20),
                }
            ),
        })

        -- Function to update scrolling behavior based on content size
        local function updateScrollingBehavior()
            -- Calculate content size by finding the bottommost child element
            local maxY = 0
            for _, child in pairs(contentArea:GetChildren()) do
                if child:IsA('GuiObject') and child.Visible then
                    local bottomY = child.AbsolutePosition.Y
                        + child.AbsoluteSize.Y
                        - contentArea.AbsolutePosition.Y
                    if bottomY > maxY then
                        maxY = bottomY
                    end
                end
            end

            local contentSize = maxY
            local frameSize = contentArea.AbsoluteSize.Y
            local padding = 20 -- 10px top + 10px bottom padding (reduced to fix scrolling)

            if contentSize <= frameSize - padding then
                -- Content fits within frame, disable scrolling completely
                contentArea.CanvasSize =
                    UDim2.new(0, 0, 0, contentSize + padding)
                contentArea.ScrollBarThickness = 0
                contentArea.ScrollBarImageTransparency = 1
                contentArea.ScrollingEnabled = false
            else
                -- Content exceeds frame, enable scrolling with exact fit
                contentArea.CanvasSize =
                    UDim2.new(0, 0, 0, contentSize + padding)
                contentArea.ScrollBarThickness = 6
                contentArea.ScrollBarImageTransparency = 0.5
                contentArea.ScrollingEnabled = true
            end
        end

        -- Update scrolling behavior when content changes
        task.defer(function()
            -- Wait for content to be added
            task.wait(0.2)
            -- Set up listener for frame size changes
            bind(
                contentArea
                    :GetPropertyChangedSignal('AbsoluteSize')
                    :Connect(updateScrollingBehavior)
            )
            -- Initial update
            updateScrollingBehavior()
        end)

        -- Make window draggable with unique handlers per window
        do
            local isDragging = false
            local dragStartPos = nil
            local windowStartPos = nil
            local thisWindow = window -- Capture window reference for this specific drag handler

            local function beginDrag(input)
                -- Only start dragging if no other window is being dragged
                if globalDragState.isDragging then
                    return
                end

                globalDragState.isDragging = true
                globalDragState.draggedWindow = thisWindow
                isDragging = true
                dragStartPos = input.Position
                -- Get the current window position in absolute coordinates
                local currentPos = thisWindow.AbsolutePosition
                windowStartPos = Vector2.new(currentPos.X, currentPos.Y)

                -- Make title bar grey when dragging (theme-aware)
                local dragColor = theme == 'light'
                        and Color3.fromRGB(200, 200, 200)
                    or Color3.fromRGB(60, 60, 60)
                TweenService:Create(
                    titleBar,
                    TweenInfo.new(0.1),
                    { BackgroundColor3 = dragColor }
                ):Play()

                -- Bring this window to the front while dragging (highest priority)
                thisWindow.ZIndex = baseZIndex + 1000
            end

            bind(titleBar.InputBegan:Connect(function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                then
                    beginDrag(input)
                end
            end))

            bind(UserInputService.InputChanged:Connect(function(input)
                -- Only process if THIS specific window is being dragged
                if
                    not globalDragState.isDragging
                    or globalDragState.draggedWindow ~= thisWindow
                then
                    return
                end
                if not isDragging or not dragStartPos or not windowStartPos then
                    return
                end
                if
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                then
                    local delta = input.Position - dragStartPos

                    -- Simple drag calculation - just add the mouse delta to the start position
                    local newX = windowStartPos.X + delta.X
                    local newY = windowStartPos.Y + delta.Y

                    -- Get viewport size for dynamic clamping
                    local viewport = Workspace.CurrentCamera.ViewportSize

                    -- Basic clamping to keep window roughly on screen
                    newX = math.clamp(newX, -300, viewport.X) -- Allow some off-screen
                    newY = math.clamp(newY, -200, viewport.Y) -- Allow some off-screen

                    -- Use absolute positioning to allow full screen movement
                    thisWindow.Position = UDim2.new(0, newX, 0, newY)
                    -- Update stored position
                    thisWindow:SetAttribute(
                        'CurrentPosition',
                        UDim2.new(0, newX, 0, newY)
                    )
                end
            end))

            -- Add a larger drag zone around the title bar for better dragging experience
            local dragZone = New('Frame', {
                Size = UDim2.new(1, 20, 1, 20), -- Slightly larger than title bar
                Position = UDim2.new(0, -10, 0, -10), -- Offset to center the extra area
                BackgroundTransparency = 1, -- Invisible
                Parent = titleBar,
            })

            bind(dragZone.InputBegan:Connect(function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                then
                    beginDrag(input)
                end
            end))

            bind(UserInputService.InputEnded:Connect(function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                then
                    -- Only reset if this window was being dragged
                    if globalDragState.draggedWindow == thisWindow then
                        globalDragState.isDragging = false
                        globalDragState.draggedWindow = nil
                        -- Restore title bar color when drag ends
                        TweenService
                            :Create(
                                titleBar,
                                TweenInfo.new(0.1),
                                { BackgroundColor3 = Card }
                            )
                            :Play()
                        -- Return window to proper Z-index position after dragging
                        bringWindowToFront(thisWindow)
                    end
                    isDragging = false
                    dragStartPos = nil
                    windowStartPos = nil
                end
            end))
        end

        -- Bring window to front when title bar is clicked (but not dragged)
        bind(titleBar.MouseButton1Click:Connect(function()
            if not isDragging then
                bringWindowToFront(thisWindow)
            end
        end))

        -- Minimize button functionality
        local isMinimized = false
        local originalSize = window.Size
        local originalPosition = window.Position

        -- Fullscreen button functionality
        local isFullscreen = false
        local function getFullscreenSize()
            -- Get current sidebar scale
            local sidebarScale = 1.0
            if sidebarApi and sidebarApi.sidebar then
                local scaleObj = sidebarApi.sidebar:FindFirstChild('UIScale')
                if scaleObj then
                    sidebarScale = scaleObj.Scale
                end
            end
            -- Calculate sidebar width based on scale (collapsed = 60, expanded = 200)
            local sidebarWidth = (isExpanded and 200 or 60) * sidebarScale
            local fullscreenSize = UDim2.new(1, -sidebarWidth - 10, 1, -10)
            local currentLocation = sidebarApi
                    and sidebarApi.sidebar
                    and sidebarApi.sidebar:GetAttribute('SidebarLocation')
                or sidebarLocation
            local fullscreenPosition
            if currentLocation == 'Right' then
                fullscreenPosition = UDim2.new(0, 5, 0, 5) -- Left side of screen
            else
                fullscreenPosition = UDim2.new(0, sidebarWidth + 5, 0, 5) -- Right side of sidebar
            end
            return fullscreenSize, fullscreenPosition
        end

        -- Minimize button hover effects
        minimizeBtn.MouseEnter:Connect(function()
            FX.CreateTween(
                minimizeBtn,
                TweenInfo.new(0.2),
                { BackgroundColor3 = Color3.fromRGB(255, 213, 79) }
            ):Play()
        end)
        minimizeBtn.MouseLeave:Connect(function()
            FX.CreateTween(
                minimizeBtn,
                TweenInfo.new(0.2),
                { BackgroundColor3 = Color3.fromRGB(255, 193, 7) }
            ):Play()
        end)

        -- Fullscreen button hover effects
        fullscreenBtn.MouseEnter:Connect(function()
            FX.CreateTween(
                fullscreenBtn,
                TweenInfo.new(0.2),
                { BackgroundColor3 = Color3.fromRGB(120, 170, 255) }
            ):Play()
        end)
        fullscreenBtn.MouseLeave:Connect(function()
            FX.CreateTween(
                fullscreenBtn,
                TweenInfo.new(0.2),
                { BackgroundColor3 = Color3.fromRGB(100, 150, 255) }
            ):Play()
        end)

        bind(minimizeBtn.MouseButton1Click:Connect(function()
            if not isMinimized then
                -- Minimize: show only title bar with animation
                isMinimized = true

                -- Slide minimize button to sit next to close button with proper spacing
                FX.CreateTween(
                    minimizeBtn,
                    TweenInfo.new(
                        0.3,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                    ),
                    {
                        Position = UDim2.new(0, 130, 0, 5), -- Position to sit next to close button (200px wide - 35px close button - 30px button width - 5px spacing = 130px from left)
                    }
                ):Play()

                -- Hide maximize button when minimized to prevent content loading issues
                fullscreenBtn.Visible = false

                -- Animate window shrinking smoothly
                FX.CreateTween(
                    window,
                    TweenInfo.new(
                        0.3,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                    ),
                    {
                        Size = UDim2.new(0, 200, 0, 40),
                    }
                ):Play()

                -- Hide content with fade
                FX.CreateTween(
                    contentArea,
                    TweenInfo.new(
                        0.2,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                    ),
                    {
                        BackgroundTransparency = 1,
                    }
                ):Play()

                contentArea.Visible = false
                minimizeBtn.Text = '+' -- Change to restore icon
            else
                -- Restore: show full window with animation
                isMinimized = false

                -- Slide minimize button back to its original position
                FX.CreateTween(
                    minimizeBtn,
                    TweenInfo.new(
                        0.3,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                    ),
                    {
                        Position = UDim2.new(1, -105, 0, 5), -- Move back to original position
                    }
                ):Play()

                -- Show maximize button again when restored
                fullscreenBtn.Visible = true

                -- Make content area visible first
                contentArea.Visible = true

                -- Reset content area transparency and background color to prevent white background
                contentArea.BackgroundTransparency = 0
                contentArea.BackgroundColor3 = Surface -- Ensure proper background color

                -- Animate window expanding with bounce effect
                FX.CreateTween(
                    window,
                    TweenInfo.new(
                        0.4,
                        Enum.EasingStyle.Back,
                        Enum.EasingDirection.Out
                    ),
                    {
                        Size = originalSize,
                    }
                ):Play()

                minimizeBtn.Text = '−' -- Change back to minimize icon
            end
        end))

        -- Fullscreen button functionality
        bind(fullscreenBtn.MouseButton1Click:Connect(function()
            if not isFullscreen then
                -- Enter fullscreen: expand to fill screen minus sidebar
                isFullscreen = true
                fullscreenBtn.Text = '★' -- Change to restore icon

                -- Get dynamic fullscreen size based on current sidebar scale
                local fullscreenSize, fullscreenPosition = getFullscreenSize()

                -- Animate to fullscreen
                FX.CreateTween(
                    window,
                    TweenInfo.new(
                        0.4,
                        Enum.EasingStyle.Quart,
                        Enum.EasingDirection.Out
                    ),
                    {
                        Size = fullscreenSize,
                        Position = fullscreenPosition,
                    }
                ):Play()
            else
                -- Exit fullscreen: return to original size
                isFullscreen = false
                fullscreenBtn.Text = '☆' -- Change back to fullscreen icon

                -- Animate back to original size
                FX.CreateTween(
                    window,
                    TweenInfo.new(
                        0.4,
                        Enum.EasingStyle.Quart,
                        Enum.EasingDirection.Out
                    ),
                    {
                        Size = originalSize,
                        Position = originalPosition,
                    }
                ):Play()
            end
        end))

        -- Close button hover effects
        closeBtn.MouseEnter:Connect(function()
            TweenService:Create(
                closeBtn,
                TweenInfo.new(0.2),
                { BackgroundColor3 = Color3.fromRGB(255, 120, 120) }
            ):Play()
        end)
        closeBtn.MouseLeave:Connect(function()
            TweenService:Create(
                closeBtn,
                TweenInfo.new(0.2),
                { BackgroundColor3 = Color3.fromRGB(255, 90, 90) }
            ):Play()
        end)

        -- Close button functionality with genie animation
        bind(closeBtn.MouseButton1Click:Connect(function()
            -- Save dropdown states before closing window
            closeAllDropdowns()

            -- Get the source button for the genie animation
            local sourceButton = nil
            if
                sidebarApi
                and sidebarApi.navButtons
                and sidebarApi.navButtons[windowType]
            then
                sourceButton = sidebarApi.navButtons[windowType].button
            end

            -- Use genie close animation
            Components.GenieCloseAnimation(window, sourceButton)

            -- Clear reference and destroy after animation
            spawn(function()
                wait(0.9) -- Wait for genie animation to complete
                -- Clear reference first
                openWindows[windowType] = nil
                -- Clear sidebar highlighting
                if sidebarApi and sidebarApi.clearActiveTab then
                    sidebarApi.clearActiveTab(windowType)
                end
                -- Destroy window safely
                pcall(function()
                    window:Destroy()
                end)
            end)
        end))

        -- Store window reference
        openWindows[windowType] = window

        return window, contentArea
    end
    -- Window spawning function
    function spawnWindow(windowType, sourceButton)
        -- Check if window is already open
        if openWindows[windowType] then
            local window = openWindows[windowType]
            -- Save dropdown states before closing window
            closeAllDropdowns()

            -- Clear reference first to prevent issues
            openWindows[windowType] = nil
            -- Clear sidebar highlighting
            if sidebarApi and sidebarApi.clearActiveTab then
                sidebarApi.clearActiveTab(windowType)
            end
            -- Use genie close animation instead of just destroying
            if window and window.Parent then
                Components.GenieCloseAnimation(window, sourceButton)
                -- Destroy after animation completes
                task.wait(0.9) -- Wait for genie animation to complete
                pcall(function()
                    window:Destroy()
                end)
            end
            return
        end

        local titles = {
            main = 'Main',
            alerts = 'Alerts',
            misc = 'Misc',
            settings = 'Settings',
        }

        local window, contentArea = createWindow(windowType, titles[windowType])

        -- Apply current theme to the new window immediately
        if window then
            local function applyThemeToInstance(instance)
                if not instance or not instance.Parent then
                    return
                end

                -- Handle slider components specially - different colors for light/dark mode
                if instance:IsA('Frame') and instance.Name == 'bar' then
                    -- This is a slider bar - apply theme color
                    instance.BackgroundColor3 = Surface
                    return
                elseif instance:IsA('Frame') and instance.Name == 'fill' then
                    -- This is a slider fill - orange in light mode, blue in dark mode
                    if theme == 'light' then
                        instance.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Orange
                    else
                        instance.BackgroundColor3 = Color3.fromRGB(59, 130, 246) -- Blue in dark mode
                    end
                    return
                elseif instance:IsA('Frame') and instance.Name == 'knob' then
                    -- This is a slider knob - white in both light and dark mode
                    instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White
                    local stroke = instance:FindFirstChild('UIStroke')
                    if stroke then
                        if theme == 'light' then
                            stroke.Color = Color3.fromRGB(128, 0, 128) -- Purple outline in light mode
                        else
                            stroke.Color = Color3.fromRGB(59, 130, 246) -- Blue outline in dark mode
                        end
                    end
                    return
                end

                -- Apply background colors based on element type and name
                if instance:IsA('Frame') then
                    if
                        instance.Name:find('Card')
                        or instance.Name:find('MainCard')
                        or instance.Name:find('AlertsCard')
                        or instance.Name:find('SettingsCard')
                    then
                        instance.BackgroundColor3 = Card
                    elseif instance.Name:find('Surface') then
                        instance.BackgroundColor3 = Surface
                    elseif
                        instance.Name:find('Content')
                        or instance.Name:find('ContentArea')
                    then
                        instance.BackgroundColor3 = ContentBg
                    elseif
                        instance.Name:find('Button')
                        or instance.Name:find('Btn')
                    then
                        instance.BackgroundColor3 = DefaultButton
                    elseif
                        instance.Name:find('Window')
                        or instance.Name:find('Panel')
                    then
                        instance.BackgroundColor3 = Surface
                    elseif
                        instance.Name:find('TitleBar')
                        or instance.Name:find('Header')
                    then
                        instance.BackgroundColor3 = Card
                    elseif instance.Name:find('Scroll') then
                        instance.BackgroundColor3 = Surface
                    else
                        instance.BackgroundColor3 = Surface
                    end
                end

                -- Apply text colors
                if instance:IsA('TextLabel') or instance:IsA('TextButton') then
                    if
                        instance.Name:find('Title')
                        or instance.Name:find('Header')
                    then
                        instance.TextColor3 = Text
                    elseif
                        instance.Name:find('Muted')
                        or instance.Name:find('Sub')
                    then
                        instance.TextColor3 = Muted
                    else
                        instance.TextColor3 = Text
                    end
                end

                -- Apply stroke colors
                if instance:IsA('UIStroke') then
                    instance.Color = Stroke
                end

                -- Apply to TextBoxes
                if instance:IsA('TextBox') then
                    instance.BackgroundColor3 = Surface
                    instance.TextColor3 = Text
                    instance.PlaceholderColor3 = Muted
                end

                -- Recursively apply to children
                for _, child in ipairs(instance:GetChildren()) do
                    applyThemeToInstance(child)
                end
            end

            applyThemeToInstance(window)
        end

        -- Set sidebar tab as active
        if sidebarApi and sidebarApi.setActiveTab then
            sidebarApi.setActiveTab(windowType)
        end

        -- Use genie open animation instead of the default entrance animation
        Components.GenieOpenAnimation(window, sourceButton, openWindows)

        -- Load content into the window based on type
        local refs = {}
        if windowType == 'main' then
            refs = Components.buildMainPage(contentArea)
            -- Store intervalApi and typeApi references in uiRefs for config loading
            if refs then
                uiRefs = uiRefs or {}
                uiRefs.intervalApi = refs.intervalApi
                uiRefs.autoEquipBestIntervalApi = refs.autoEquipBestIntervalApi
                uiRefs.typeApi = refs.typeApi
                uiRefs.seedBuyDropdown = refs.seedBuyDropdown
                uiRefs.gearBuyDropdown = refs.gearBuyDropdown
                uiRefs.rarityDropdown = refs.rarityDropdown
                uiRefs.mutationDropdown = refs.mutationDropdown
                uiRefs.espRarityDropdown = refs.espRarityDropdown
                uiRefs.espMutationDropdown = refs.espMutationDropdown
                uiRefs.autoHitBrainrotDropdown = refs.autoHitBrainrotDropdown
                uiRefs.giSliderApi = refs.gameInfoScaleSlider
                -- Add missing button references
                uiRefs.gameInfoBtn = refs.gameInfoBtn
                uiRefs.autoCollectBtn = refs.autoCollectBtn
                uiRefs.autoEquipBestBtn = refs.autoEquipBestBtn
                uiRefs.espBtn = refs.espBtn
                uiRefs.seedTimerEspBtn = refs.seedTimerEspBtn
                uiRefs.seedTimerInfoBtn = refs.seedTimerInfoBtn
                uiRefs.seedTimerHitboxBtn = refs.seedTimerHitboxBtn
                uiRefs.seedAutoBuyBtn = refs.seedAutoBuyBtn
                uiRefs.gearAutoBuyBtn = refs.gearAutoBuyBtn
                uiRefs.autoHitBtn = refs.autoHitBtn
                uiRefs.autoRebirthBtn = refs.autoRebirthBtn
            end
            -- Set up UI sync for main window
            setupUISync(refs)
            Components.UISync.syncAll(refs)

            -- Populate auto-buy dropdowns after a short delay to ensure UI is ready
            task.defer(function()
                if ensureSeedBuyFiltersPopulated then
                    ensureSeedBuyFiltersPopulated()
                end
                if ensureGearBuyFiltersPopulated then
                    ensureGearBuyFiltersPopulated()
                end
            end)

            -- Debug: Make sure content is visible
            contentArea.Visible = true
        elseif windowType == 'alerts' then
            -- Load alerts page in chunks to prevent freezing
            task.spawn(function()
                pcall(function()
                    refs = Components.buildAlertsPage(contentArea)
                    -- Store dropdown references in uiRefs for population functions
                    if refs then
                        uiRefs = uiRefs or {}
                        uiRefs.seedFilterDropdownApi =
                            refs.seedFilterDropdownApi
                        uiRefs.gearFilterDropdownApi =
                            refs.gearFilterDropdownApi
                        uiRefs.alertRarityDropdown = refs.alertRarityDropdown
                        uiRefs.alertMutationDropdown =
                            refs.alertMutationDropdown
                        uiRefs.volSliderApi = refs.volSliderApi
                        uiRefs.seedVolApi = refs.seedVolApi
                        uiRefs.alertWhenApi = refs.alertWhenApi
                        -- Add missing button references
                        uiRefs.alertsToggle = refs.alertsToggle
                        uiRefs.serverwideToggle = refs.serverwideToggle
                        uiRefs.seedAlertsToggle = refs.seedAlertsToggle
                        uiRefs.gearAlertsToggle = refs.gearAlertsToggle

                        -- Initialize dropdowns after uiRefs is updated
                        task.defer(function()
                            -- Always populate dropdowns regardless of alert state
                            ensureSeedFiltersPopulated()

                            -- Always populate gear dropdown regardless of alert state
                            local gearsFrame = getGearsScrollingFrame()
                            if gearsFrame then
                                local gearNames = {}
                                for _, gearItem in
                                    ipairs(gearsFrame:GetChildren())
                                do
                                    if
                                        gearItem:IsA('Frame')
                                        and gearItem.Name ~= 'UIPadding'
                                        and gearItem.Name ~= 'Padding'
                                        and gearItem.Name ~= 'UIListLayout'
                                    then
                                        local titleLabel =
                                            gearItem:FindFirstChild('Title')
                                        if
                                            titleLabel
                                            and titleLabel.Text
                                            and titleLabel.Text ~= ''
                                        then
                                            table.insert(
                                                gearNames,
                                                titleLabel.Text
                                            )
                                        end
                                    end
                                end
                                if #gearNames > 0 then
                                    ensureGearFiltersPopulated(gearNames)
                                end
                            end
                        end)
                    end
                end)
            end)
        elseif windowType == 'misc' then
            refs = Components.buildMiscPage(contentArea)
            -- Store button references in uiRefs for config loading
            if refs then
                uiRefs = uiRefs or {}
                -- No specific button references for misc page anymore
            end
        elseif windowType == 'settings' then
            refs = Components.buildSettingsPage(contentArea)
            -- Store themeApi and slider references in uiRefs for config loading and theme updates
            if refs then
                uiRefs = uiRefs or {}
                uiRefs.themeApi = refs.themeApi
                uiRefs.sidebarScaleSlider = refs.sidebarScaleSlider
                uiRefs.gameInfoScaleSlider = refs.gameInfoScaleSlider
                uiRefs.toastScaleSlider = refs.toastScaleSlider
                -- Add missing button references
                uiRefs.webhookToggleBtn = refs.webhookToggleBtn
                uiRefs.keepSidebarBtn = refs.keepSidebarBtn
                uiRefs.mobileButtonToggle = refs.mobileButtonToggle
                uiRefs.disableBlurBtn = refs.disableBlurBtn
                uiRefs.disableAnimationsBtn = refs.disableAnimationsBtn
                uiRefs.webhookBox = refs.webhookBox
                uiRefs.pingApi = refs.pingApi
                uiRefs.sidebarLocationDropdown = refs.sidebarLocationDropdown
                uiRefs.antiAfkBtn = refs.antiAfkBtn
            end

            -- Apply current theme to the settings page content
            if contentArea then
                local function applyThemeToInstance(instance)
                    if not instance or not instance.Parent then
                        return
                    end

                    -- Skip slider components - they have their own updateColors method
                    if
                        instance:IsA('Frame')
                        and (
                            instance.Name == 'bar'
                            or instance.Name == 'fill'
                            or instance.Name == 'knob'
                        )
                    then
                        return
                    end

                    -- Apply background colors based on element type and name
                    if instance:IsA('Frame') then
                        if
                            instance.Name:find('Card')
                            or instance.Name:find('SettingsCard')
                        then
                            instance.BackgroundColor3 = Card
                        elseif instance.Name:find('Surface') then
                            instance.BackgroundColor3 = Surface
                        elseif
                            instance.Name:find('Content')
                            or instance.Name:find('ContentArea')
                        then
                            instance.BackgroundColor3 = ContentBg
                        elseif
                            instance.Name:find('Button')
                            or instance.Name:find('Btn')
                        then
                            instance.BackgroundColor3 = DefaultButton
                        elseif instance.Name:find('Scroll') then
                            instance.BackgroundColor3 = Surface
                        else
                            instance.BackgroundColor3 = Surface
                        end
                    end

                    -- Apply text colors
                    if
                        instance:IsA('TextLabel') or instance:IsA('TextButton')
                    then
                        if
                            instance.Name:find('Title')
                            or instance.Name:find('Header')
                        then
                            instance.TextColor3 = Text
                        elseif
                            instance.Name:find('Muted')
                            or instance.Name:find('Sub')
                        then
                            instance.TextColor3 = Muted
                        else
                            instance.TextColor3 = Text
                        end
                    end

                    -- Apply stroke colors
                    if instance:IsA('UIStroke') then
                        instance.Color = Stroke
                    end

                    -- Apply to TextBoxes
                    if instance:IsA('TextBox') then
                        instance.BackgroundColor3 = Surface
                        instance.TextColor3 = Text
                        instance.PlaceholderColor3 = Muted
                    end

                    -- Recursively apply to children
                    for _, child in ipairs(instance:GetChildren()) do
                        applyThemeToInstance(child)
                    end
                end

                applyThemeToInstance(contentArea)

                -- Update slider colors after theme is applied
                if refs then
                    if
                        refs.sidebarScaleSlider
                        and refs.sidebarScaleSlider.updateColors
                    then
                        refs.sidebarScaleSlider.updateColors()
                    end
                    if
                        refs.gameInfoScaleSlider
                        and refs.gameInfoScaleSlider.updateColors
                    then
                        refs.gameInfoScaleSlider.updateColors()
                    end
                    if
                        refs.toastScaleSlider
                        and refs.toastScaleSlider.updateColors
                    then
                        refs.toastScaleSlider.updateColors()
                    end
                end
            end
        end

        return window, contentArea
    end

    -- Set up sidebar callbacks to spawn windows with genie animations
    sidebarApi.setTabCallback('main', function()
        local button = sidebarApi.navButtons
            and sidebarApi.navButtons['main']
            and sidebarApi.navButtons['main'].button
        task.spawn(spawnWindow, 'main', button)
    end)
    sidebarApi.setTabCallback('alerts', function()
        local button = sidebarApi.navButtons
            and sidebarApi.navButtons['alerts']
            and sidebarApi.navButtons['alerts'].button
        task.spawn(spawnWindow, 'alerts', button)
    end)
    sidebarApi.setTabCallback('misc', function()
        local button = sidebarApi.navButtons
            and sidebarApi.navButtons['misc']
            and sidebarApi.navButtons['misc'].button
        task.spawn(spawnWindow, 'misc', button)
    end)
    sidebarApi.setTabCallback('settings', function()
        local button = sidebarApi.navButtons
            and sidebarApi.navButtons['settings']
            and sidebarApi.navButtons['settings'].button
        task.spawn(spawnWindow, 'settings', button)
    end)

    -- Content is now built dynamically when windows are created

    -- Hotkey to toggle GUI (extracted) - Use sidebar for animations
    setupGuiVisibility(mainGui, sidebarContainer, sidebarApi, openWindows)

    pcall(function()
        if failsafeGui then
            failsafeGui:Destroy()
            failsafeGui = nil
        end
    end)

    -- UISync will be set up when main window is created
end

-- SCRIPT START
-- Show loading animation first
buildLoadingGui()
startLoadingAnimation()

-- Initialize ESP GUI first
espGui = New('ScreenGui', {
    Name = existingGuiName .. '_ESP',
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 1000,
    Enabled = false,
    Parent = CoreGui,
})

-- Initialize Game Info GUI
buildGameInfoGui()

-- Build main GUI
buildGui()

-- Initialize all toast GUIs
ensureOverlay()
ensureToastsGui()
ensureSeedToastsGui()
ensureGearToastsGui()
updateToastPositions()

-- Initialize features that need to be running
if seedAlertEnabled then
    toggleSeedAlerts(true)
end

if gearAlertEnabled then
    toggleGearAlerts(true)
end

-- Initialize ESP GUI
espGui = New('ScreenGui', {
    Name = 'ESP_Container',
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 1,
    Parent = CoreGui,
})

-- Initialize brainrot alerts
setupBrainrotAlerts()

-- Ensure default-on features start without needing to open tabs
-- ESP
pcall(function()
    if espEnabled then
        toggleEsp(true)
    end
end)

-- Game Info
pcall(function()
    if gameInfoEnabled then
        toggleGameInfo(true)
    end
end)

-- Seed Timer ESP and Info
pcall(function()
    if seedTimerEspEnabled then
        toggleSeedTimerEsp(true)
    end
    if seedTimerInfoEnabled then
        toggleSeedTimerInfo(true)
    end
end)

-- Auto Collect
pcall(function()
    if autoCollectEnabled and not autoCollectThread then
        autoCollectThread = task.spawn(function()
            while autoCollectEnabled and not unloaded do
                runOneAutoCollectPass()
                task.wait(autoCollectIntervalSec)
            end
        end)
    end
end)

-- Auto Equip Best
pcall(function()
    if autoEquipBestEnabled and not autoEquipBestThread then
        autoEquipBestThread = task.spawn(function()
            while autoEquipBestEnabled and not unloaded do
                runOneAutoEquipBestPass()
                task.wait(autoEquipBestIntervalSec)
            end
        end)
    end
end)

-- Auto Hit
pcall(function()
    if autoHitEnabled then
        toggleAutoHit(true)
    end
end)

-- Add toast position update connections
if toastsGui then
    bind(
        toastContainer
            :GetPropertyChangedSignal('AbsoluteSize')
            :Connect(updateToastPositions)
    )
end
if seedToastsGui then
    bind(
        seedToastContainer
            :GetPropertyChangedSignal('AbsoluteSize')
            :Connect(updateToastPositions)
    )
end
if Workspace.CurrentCamera then
    bind(
        Workspace.CurrentCamera
            :GetPropertyChangedSignal('ViewportSize')
            :Connect(updateToastPositions)
    )
end

-- Hook responsive layout to viewport size changes
if Workspace.CurrentCamera then
    bind(
        Workspace.CurrentCamera
            :GetPropertyChangedSignal('ViewportSize')
            :Connect(applyResponsiveLayout)
    )
end

-- Only call BindToClose on the server
if game:GetService('RunService'):IsServer() and game.BindToClose then
    bind(game:BindToClose(function()
        unload()
    end))
end

-- Define time function if not available
if not time then
    time = tick
end

-- Print messages to console
pcall(function()
    if printconsole then
        printconsole(
            'https://discord.gg/rBUktpykV8',
            Color3.fromRGB(114, 137, 218)
        ) -- Discord blue color
        printconsole('Made with love by Syso <3', Color3.fromRGB(255, 105, 180)) -- Hot pink color
    end
end)

-- Initial responsive layout application (after UI is built)
task.defer(function()
    pcall(function()
        if type(applyResponsiveLayout) == 'function' then
            applyResponsiveLayout()
        end
    end)
end)
