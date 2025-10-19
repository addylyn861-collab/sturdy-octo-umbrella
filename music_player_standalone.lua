local TweenService = game:GetService('TweenService')
local SoundService = game:GetService('SoundService')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local CoreGui = game:GetService('CoreGui')
local HttpService = game:GetService('HttpService')

-- Debug
local debugMode = true
local function debugLog(msg)
    if debugMode then
        pcall(function() print("[MP DEBUG] " .. tostring(msg)) end)
    end
end

--// CONFIGURATION
local config = {
	-- Colors
	BackgroundColor = Color3.fromRGB(33, 31, 49),
	PrimaryTextColor = Color3.fromRGB(255, 255, 255),
	SecondaryTextColor = Color3.fromRGB(170, 168, 184),
	AccentColor1 = Color3.fromRGB(224, 85, 255),
	AccentColor2 = Color3.fromRGB(255, 150, 100),
	IconColor = Color3.fromRGB(170, 168, 184),
	PlaylistHighlightColor = Color3.fromRGB(68, 64, 102),

	-- Fonts
	RegularFont = Enum.Font.Gotham,
	BoldFont = Enum.Font.GothamBold,

	-- Playlist Data
	-- EPIC COLLECTION of Roblox Audio Library tracks! (80+ songs!)
	Playlist = {
		{
			title = 'Raining Tacos',
			artist = 'Parry Gripp',
			duration = 180,
			soundId = 'rbxassetid://142376088',
		},
		{
			title = 'Relaxed Scene',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://1848354536',
		},
		{
			title = 'Life in an Elevator',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://1841647093',
		},
		{
			title = 'Cool Vibes',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://1840684529',
		},
		{
			title = 'Menu Theme',
			artist = 'Roblox Audio',
			duration = 180,
			soundId = 'rbxassetid://114376757380093',
		},
		{
			title = 'Paradise Falls',
			artist = 'Roblox Audio',
			duration = 260,
			soundId = 'rbxassetid://1837879082',
		},
		{
			title = 'Happy Adventure',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://9047876673',
		},
		{
			title = 'Bossa Me',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://1837768517',
		},
		{
			title = 'Seek and Destroy',
			artist = 'Roblox Audio',
			duration = 280,
			soundId = 'rbxassetid://1845149698',
		},
		{
			title = 'ERROR 264',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://140009716850576',
		},
		{
			title = 'Lo-Fi Chill A',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://9043887091',
		},
		{
			title = 'The Loneliest Hour',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://114213622974713',
		},
		{
			title = 'Tender Tropical House',
			artist = 'Roblox Audio',
			duration = 260,
			soundId = 'rbxassetid://1836105293',
		},
		{
			title = 'Happy Song',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://1843404009',
		},
		{
			title = 'TOMA TOMA FUNK SLOWED',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://129098116998483',
		},
		{
			title = 'Crab Rave',
			artist = 'Noisestorm',
			duration = 180,
			soundId = 'rbxassetid://5410086218',
		},
		{
			title = 'Really Fast',
			artist = 'Roblox Audio',
			duration = 160,
			soundId = 'rbxassetid://1846911135',
		},
		{
			title = 'Tender Chillstep',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://1836098504',
		},
		{
			title = 'READY OR NOT (SCH00LKIDD MIX)',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://119731837417100',
		},
		{
			title = 'HERE I COME',
			artist = 'Roblox Audio',
			duration = 180,
			soundId = 'rbxassetid://78534559289195',
		},
		{
			title = 'ORDER UP!',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://127980613700097',
		},
		{
			title = 'REMORSE',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://127097493971664',
		},
		{
			title = 'PHOENIX (MASTERED)',
			artist = 'Roblox Audio',
			duration = 260,
			soundId = 'rbxassetid://77715601943266',
		},
		{
			title = 'WAR',
			artist = 'Roblox Audio',
			duration = 280,
			soundId = 'rbxassetid://130944271775816',
		},
		{
			title = 'INITIATION',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://114739879534725',
		},
		{
			title = 'PENANCE',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://88927553987952',
		},
		{
			title = 'READY OR NOT (CULTIST MIX)',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://83683960727365',
		},
		{
			title = 'PARADOX',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://92486147189928',
		},
		{
			title = 'I DID IT FOR YOU (RETAKE)',
			artist = 'Roblox Audio',
			duration = 260,
			soundId = 'rbxassetid://123602120579597',
		},
		{
			title = 'ONE BOUNCE',
			artist = 'Roblox Audio',
			duration = 180,
			soundId = 'rbxassetid://118951773927701',
		},
		{
			title = 'CALAMITY',
			artist = 'Roblox Audio',
			duration = 280,
			soundId = 'rbxassetid://105018461953532',
		},
		{
			title = 'WHEN THE BELLS CURVE',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://89597375667504',
		},
		{
			title = 'TILL DAWN',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://98923452928459',
		},
		{
			title = 'ARENA OF DEATH',
			artist = 'Roblox Audio',
			duration = 260,
			soundId = 'rbxassetid://87793825312803',
		},
		{
			title = 'HOT-TOPIC HAVOC',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://134884767490882',
		},
		{
			title = 'DEMOLITION',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://111640226505488',
		},
		{
			title = 'RESENTMENT',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://103779522255411',
		},
		{
			title = 'ETERNITY: FORSAKENED',
			artist = 'Roblox Audio',
			duration = 280,
			soundId = 'rbxassetid://94683110091181',
		},
		{
			title = 'CATASTROPHE',
			artist = 'Roblox Audio',
			duration = 260,
			soundId = 'rbxassetid://86268407190791',
		},
		{
			title = 'PALACE',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://104002120328070',
		},
		{
			title = '1XMAS CHEER',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://87516721795208',
		},
		{
			title = 'BLOOMING MALICE',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://105121590728691',
		},
		{
			title = 'TEA',
			artist = 'Roblox Audio',
			duration = 180,
			soundId = 'rbxassetid://127287258256942',
		},
		{
			title = 'DIVESTMENT',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://137467707229429',
		},
		{
			title = 'TUTORIAL',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://82614062062975',
		},
		{
			title = 'PRAYER',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://132850479761712',
		},
		{
			title = 'APOC00LYPSE',
			artist = 'Roblox Audio',
			duration = 260,
			soundId = 'rbxassetid://73972570177022',
		},
		{
			title = 'SUBSPACED',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://96728219115605',
		},
		{
			title = 'POT',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://77435705757696',
		},
		{
			title = 'SLAUGHTER',
			artist = 'Roblox Audio',
			duration = 280,
			soundId = 'rbxassetid://85997592177190',
		},
		{
			title = 'REMINISCENT',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://135173047204543',
		},
		{
			title = 'NEW BLOOD',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://119435747002780',
		},
		{
			title = 'ECLIPSE',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://114505147154737',
		},
		{
			title = 'NO PARTY',
			artist = 'Roblox Audio',
			duration = 180,
			soundId = 'rbxassetid://110869546630610',
		},
		{
			title = 'ATHAZAGORAPHOBIA',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://118485807480462',
		},
		{
			title = 'BREAKING NEWS',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://78135695784742',
		},
		{
			title = 'Shiawase',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://5409360995',
		},
		{
			title = 'Boss Fight!',
			artist = 'Roblox Audio',
			duration = 260,
			soundId = 'rbxassetid://78744747224727',
		},
		{
			title = 'Obby Mudah Tapi Aku Jatoh',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://98443919757089',
		},
		{
			title = 'Boss Battle ENCOUNTER',
			artist = 'Roblox Audio',
			duration = 280,
			soundId = 'rbxassetid://129915709941550',
		},
		{
			title = 'Meat n\' Greet',
			artist = 'Roblox Audio',
			duration = 180,
			soundId = 'rbxassetid://115997397744543',
		},
		{
			title = 'Chase Type Beat (SPED-UP)',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://122304523836872',
		},
		{
			title = 'Time to Relax',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://9044702906',
		},
		{
			title = 'Sunset Chill (Bed Version)',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://9046862941',
		},
		{
			title = 'Sad End (Solo Piano)',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://1838635121',
		},
		{
			title = 'Sunburst',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://121336636707861',
		},
		{
			title = 'Retro Gamer',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://1837769001',
		},
		{
			title = 'Free Will Funk',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://94378181487716',
		},
		{
			title = '8-Bit Euphoria',
			artist = 'Roblox Audio',
			duration = 180,
			soundId = 'rbxassetid://119220775302653',
		},
		{
			title = 'Boss Fight Breakdown',
			artist = 'Roblox Audio',
			duration = 260,
			soundId = 'rbxassetid://72734512335337',
		},
		{
			title = 'Happy Go-Lively',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://1841476350',
		},
		{
			title = 'Cyber Space',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://9046476113',
		},
		{
			title = 'Doors Ending Theme',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://103086632976213',
		},
		{
			title = 'Brainrot Gang Rap',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://129839967918512',
		},
		{
			title = 'Sweet and Tender',
			artist = 'Roblox Audio',
			duration = 180,
			soundId = 'rbxassetid://9047883011',
		},
		{
			title = 'Halloween Night',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://1838592691',
		},
		{
			title = 'Brainrot Phonk: Tralalero Tralala',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://8394333801',
		},
		{
			title = 'Breeze Song',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://79278866501748',
		},
		{
			title = 'Dark Zone',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://1838706588',
		},
		{
			title = 'Hope',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://99445078556609',
		},
		{
			title = 'Waltzing Flutes',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://1846271108',
		},
		{
			title = 'Cat Chase',
			artist = 'Roblox Audio',
			duration = 180,
			soundId = 'rbxassetid://1839444520',
		},
		{
			title = 'VIP Me',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://1838028467',
		},
		{
			title = 'Happy Shoppers',
			artist = 'Roblox Audio',
			duration = 180,
			soundId = 'rbxassetid://1840383905',
		},
		{
			title = 'What Brings You to the Station?',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://78156369530346',
		},
		{
			title = 'Convenience Store',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://1839857296',
		},
		{
			title = 'Infectious',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://79451196298919',
		},
		{
			title = 'Disco Sapiens',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://1835725225',
		},
		{
			title = 'TUNG TUNG SAHUR FUNK',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://137234649215284',
		},
		{
			title = 'Piano Bar Jazz',
			artist = 'Roblox Audio',
			duration = 260,
			soundId = 'rbxassetid://1841979451',
		},
		{
			title = 'Backrooms',
			artist = 'Roblox Audio',
			duration = 240,
			soundId = 'rbxassetid://120817494107898',
		},
		{
			title = 'Running Faster',
			artist = 'Roblox Audio',
			duration = 200,
			soundId = 'rbxassetid://1847683499',
		},
		{
			title = 'DREAMCORE (Fever Dream)',
			artist = 'Roblox Audio',
			duration = 220,
			soundId = 'rbxassetid://86247184974274',
		},
	},
}

--// STATE VARIABLES
local currentSound = nil
local isPlaying = false
local currentSongIndex = 1
local connection = nil -- For the update loop
-- Liked functionality removed
local isShuffled = false
local isRepeating = false -- false = off, true = repeat one, 'all' = repeat all
local playlistSort = 'default' -- 'default' | 'name'
local isProcessing = false -- Debounce flag
local currentVolume = 0.7 -- Volume level (0-1)
local isDraggingVolume = false
local isDraggingProgress = false
-- Forward-declare navigation functions to avoid nil when called inside run loops
local nextSong, prevSong

-- Forward-declare UI element variables so functions defined earlier can reference them
local progressArc, progressHandle, progressFilled
local albumArtContainer, albumArt
local likedIndicator
local rainbowOverlay
local songItemFrames = {}
local progressSegments = {}
local SEGMENT_COUNT = 120 -- more segments = smoother arc
local linearProgressFill
local volumeSlider, volumeProgress, volumeHandle, volumeIcon
local progressBarContainer, progressBarBg, progressBarFill, progressBarHandle
local _lastProgress = nil

--// HELPER FUNCTIONS
local function New(className, properties, children)
	local obj = Instance.new(className)
	-- Disable default button click flash for TextButtons to avoid grey overlay
	if className == 'TextButton' then
		pcall(function() obj.AutoButtonColor = false end)
	end
	for prop, value in pairs(properties) do
		if prop == 'Parent' then
			obj.Parent = value
		else
			obj[prop] = value
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = obj
		end
	end
	return obj
end

-- Safe setter for ZIndex to avoid nil-index crashes
local function safeSetZIndex(obj, z)
    if not obj then
        debugLog("safeSetZIndex: object is nil for z=" .. tostring(z))
        return
    end
    pcall(function()
        obj.ZIndex = z
    end)
end

local function formatTime(seconds)
	return string.format('%d:%02d', math.floor(seconds / 60), seconds % 60)
end

local function addHoverEffect(button, originalColor, hoverColor)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			TextColor3 = hoverColor or config.AccentColor1,
			Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset + 2, button.Size.Y.Scale, button.Size.Y.Offset + 2)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			TextColor3 = originalColor or config.IconColor,
			Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset - 2, button.Size.Y.Scale, button.Size.Y.Offset - 2)
		}):Play()
	end)
end

-- Return a smooth color for a given progress (0-1) - lerps black -> rainbow
local function colorForProgress(progress)
    progress = math.clamp(progress, 0, 1)
    local hue = (progress * 0.9) % 1
    local rainbow = Color3.fromHSV(hue, 0.95, 0.95)
    return Color3.new(0,0,0):Lerp(rainbow, progress)
end

-- Return a pool of indices (default order only)
local function getShufflePool()
    local pool = {}
    for i=1, #config.Playlist do table.insert(pool, i) end
    return pool
end

-- Liked functionality removed

-- Slider-specific hover for volume background
local function addVolumeHover(slider, handle)
	slider.MouseEnter:Connect(function()
 		pcall(function()
 			TweenService:Create(slider, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { BackgroundColor3 = Color3.fromRGB(80,80,80) }):Play()
 			TweenService:Create(handle, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 14, 0, 14) }):Play()
 		end)
end)
 	slider.MouseLeave:Connect(function()
 		pcall(function()
 			TweenService:Create(slider, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { BackgroundColor3 = Color3.fromRGB(60,60,60) }):Play()
 			TweenService:Create(handle, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 12, 0, 12) }):Play()
 		end)
end)
end

-- Hover for the vertical progress bar (handle removed)
local function addProgressBarHover(container, bg, handle)
    if not container or not bg then return end
    container.MouseEnter:Connect(function()
        pcall(function()
            TweenService:Create(bg, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { BackgroundColor3 = Color3.fromRGB(100,100,100) }):Play()
            -- No handle to animate
        end)
    end)
    container.MouseLeave:Connect(function()
        pcall(function()
            TweenService:Create(bg, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { BackgroundColor3 = Color3.fromRGB(77,77,77) }):Play()
            -- No handle to animate
        end)
    end)
end

-- Progress arc hover/handle effects
local function addProgressHover(arc, handle)
 	arc.MouseEnter:Connect(function()
 		pcall(function()
 			TweenService:Create(arc, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { ImageColor3 = config.AccentColor2 }):Play()
 		end)
 	end)
 	arc.MouseLeave:Connect(function()
 		pcall(function()
 			TweenService:Create(arc, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { ImageColor3 = config.AccentColor1 }):Play()
 		end)
 	end)
 	handle.MouseEnter:Connect(function()
 		pcall(function()
 			TweenService:Create(handle, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 18, 0, 18) }):Play()
 		end)
 	end)
 	handle.MouseLeave:Connect(function()
 		pcall(function()
 			TweenService:Create(handle, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 14, 0, 14) }):Play()
 		end)
 	end)
end

-- toggleLike function removed

local function toggleShuffle(button)
	isShuffled = not isShuffled
	button.TextColor3 = isShuffled and config.AccentColor1 or config.IconColor
	button.Text = isShuffled and '🔀' or '⇄'
	button.BackgroundTransparency = isShuffled and 0.7 or 1

	TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
		Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset + 3, button.Size.Y.Scale, button.Size.Y.Offset + 3)
	}):Play()
	task.wait(0.1)
	TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
		Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset - 3, button.Size.Y.Scale, button.Size.Y.Offset - 3)
	}):Play()
    debugLog("Shuffle toggled:", isShuffled)
end

local function toggleRepeat(button)
	if isRepeating == false then
		isRepeating = 'all'  -- repeat all
		button.Text = '🔁'
		button.TextColor3 = config.AccentColor1
		button.BackgroundTransparency = 0.9
	elseif isRepeating == 'all' then
		isRepeating = true   -- repeat one
		button.Text = '🔂'
		button.TextColor3 = config.AccentColor1
		button.BackgroundTransparency = 0.9
	else
		isRepeating = false  -- off
		button.Text = '🔄'
		button.TextColor3 = config.IconColor
		button.BackgroundTransparency = 1
	end

	TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
		Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset + 3, button.Size.Y.Scale, button.Size.Y.Offset + 3)
	}):Play()
	task.wait(0.1)
	TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
		Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset - 3, button.Size.Y.Scale, button.Size.Y.Offset - 3)
	}):Play()
    debugLog("Repeat mode changed to:", isRepeating)
end

-- Volume Control Functions
local function updateVolume(volume)
	currentVolume = math.clamp(volume, 0, 1)
	if currentSound then
		currentSound.Volume = currentVolume
	end
	
	-- Update volume UI (with safety checks)
	if volumeProgress then
		-- Smooth tween for visual update
		pcall(function()
			TweenService:Create(volumeProgress, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(currentVolume, 0, 1, 0) }):Play()
		end)
	end
	if volumeHandle then
		-- Position handle relative to the slider (center-anchored). Use offset to keep it on track.
		local offsetX = 0
		-- small offset compensation to keep knob centered on slider bar
		pcall(function()
			offsetX = - (volumeHandle.Size.X.Offset / 2)
			volumeHandle.Position = UDim2.new(currentVolume, offsetX, 0.5, 0)
		end)
	end
	
	-- Update volume icon (with safety check)
	if volumeIcon then
		if currentVolume == 0 then
			volumeIcon.Text = '🔇'
		elseif currentVolume < 0.3 then
			volumeIcon.Text = '🔉'
		elseif currentVolume < 0.7 then
			volumeIcon.Text = '🔊'
		else
			volumeIcon.Text = '🔊'
		end
	end
end

local function setVolumeFromPosition(x)
	if not volumeSlider then 
		print("⚠️ Volume slider is nil!")
		return 
	end
	local sliderWidth = volumeSlider.AbsoluteSize.X
	local relativeX = x - volumeSlider.AbsolutePosition.X
	local volume = math.clamp(relativeX / sliderWidth, 0, 1)
	print("🔊 Setting volume to", math.floor(volume * 100) .. "%")
	updateVolume(volume)
end

-- Linear Progress Bar Functions
local function seekToPosition(x, y)
    if not currentSound or currentSound.TimeLength == 0 then
        debugLog("Cannot seek - currentSound:", currentSound ~= nil, "TimeLength:", currentSound and currentSound.TimeLength or 0)
        return
    end

    -- Choose a container to base calculations on (robust fallbacks)
    local container = progressBarContainer
    if not container then container = progressBarBg end
    if not container then container = albumArtContainer end
    if not container then container = nowPlayingPanel end -- final fallback to the entire panel

    if not container then
        debugLog("Cannot seek - no UI containers exist yet")
        return
    end

    -- Check if container has valid absolute properties (may not be available immediately after creation)
    local absPos = container.AbsolutePosition
    local absSize = container.AbsoluteSize

    if not absPos or not absSize or absSize.Y <= 0 then
        debugLog("Cannot seek - container not fully rendered yet. Container: " .. container.Name ..
                ", AbsPos: " .. tostring(absPos) .. ", AbsSize: " .. tostring(absSize))
        return
    end

    -- Vertical progress: calculate progress from mouse Y (top -> bottom), invert so top=1
    local relativeY = y - absPos.Y
    local progress = math.clamp(1 - (relativeY / absSize.Y), 0, 1)

    local newTime = progress * currentSound.TimeLength
    debugLog("Seeking to " .. math.floor(newTime) .. "s (" .. math.floor(progress * 100) .. "%)")

    -- Safely set time position
    pcall(function()
        currentSound.TimePosition = newTime
    end)

    -- Immediate visual update so dragging reflects on UI
    pcall(function()
        updateProgressBar(progress)
        if currentTimeLabel then
            currentTimeLabel.Text = formatTime(newTime)
        end
        debugLog("Seek update - Progress: " .. math.floor(progress * 100) .. "%, Time: " .. formatTime(newTime))
    end)
end

local function updateProgressBar(progress)
    progress = math.clamp(progress, 0, 1)

    -- Update vertical progress bar fill (grow from bottom)
    if progressBarFill and progressBarBg then
        progressBarFill.Size = UDim2.new(1, 0, progress, 0)
        progressBarFill.Position = UDim2.new(0, 0, 1 - progress, 0)
    end

    -- No handle to update - using fill-only design
end

--// UI CREATION
local Players = game:GetService('Players')
local PlayerGui = Players.LocalPlayer:WaitForChild('PlayerGui')

local mainGui = New('ScreenGui', {
	Name = 'MusicPlayerGUI',
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = PlayerGui,
})

local musicPlayer = New('Frame', {
	Name = 'MusicPlayer',
	Size = UDim2.new(0, 750, 0, 480),
	Position = UDim2.new(0.5, -375, 0.5, -240),
	BackgroundColor3 = config.BackgroundColor,
	BorderSizePixel = 0,
	Parent = mainGui,
}, {
	New('UICorner', { CornerRadius = UDim.new(0, 20) }),
})

local unloadBtn = New('TextButton', {
	Name = 'UnloadButton',
	Size = UDim2.new(0, 35, 0, 35),
	Position = UDim2.new(1, -45, 0, 15),
	BackgroundColor3 = Color3.fromRGB(255, 100, 100),
	BackgroundTransparency = 0.8,
	BorderSizePixel = 0,
	Text = '×',
	TextColor3 = Color3.new(1, 1, 1),
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	Parent = musicPlayer,
}, {
	New('UICorner', { CornerRadius = UDim.new(0, 17) }),
	New('UIStroke', {
		Color = Color3.fromRGB(255, 100, 100),
		Thickness = 1,
		Transparency = 0.5
	})
})

local nowPlayingPanel = New('Frame', {
	Name = 'NowPlayingPanel',
	Size = UDim2.new(0.5, 0, 1, 0),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundTransparency = 1,
	Parent = musicPlayer,
})

local playlistPanel = New('Frame', {
	Name = 'PlaylistPanel',
	Size = UDim2.new(0.5, 0, 1, 0),
	Position = UDim2.new(0.5, 0, 0, 0),
	BackgroundTransparency = 1,
	Parent = musicPlayer,
})

albumArtContainer = New('Frame', {
	Name = 'AlbumArtContainer',
	Size = UDim2.new(0, 250, 0, 250),
	Position = UDim2.new(0.5, -125, 0, 40),
	BackgroundTransparency = 1,
	Parent = nowPlayingPanel,
})

-- Old segment-based progress bar removed - using linear progress bar instead

-- Create a white background circle for the progress track
local progressBg = New('Frame', {
    Name = 'ProgressBackground',
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Parent = albumArtContainer,
}, {
    New('UICorner', { CornerRadius = UDim.new(1, 0) }),
    New('UIStroke', {
        Color = Color3.new(1, 1, 1),
        Transparency = 0.3,
        Thickness = 3,
    }),
})

-- Old circular progress bar removed - using linear progress bar instead

local albumArt = New('ImageLabel', {
	Name = 'AlbumArt',
	Size = UDim2.new(1, -30, 1, -30),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Image = 'rbxassetid://5028859553',
	ScaleType = Enum.ScaleType.Crop,
	Parent = albumArtContainer,
}, {
	New('UICorner', { CornerRadius = UDim.new(1, 0) }),
})
-- enforce z-order so overlays are visible above album art
pcall(function()
    if albumArt then albumArt.ZIndex = 2 end
    if progressArc then progressArc.ZIndex = 7 end
    if progressFilled then progressFilled.ZIndex = 8 end
    if rainbowOverlay then rainbowOverlay.ZIndex = 9 end
    if progressHandle then progressHandle.ZIndex = 20 end
end)
-- Rainbow overlay to tint the big circle (starts hidden)
local rainbowOverlay = New('ImageLabel', {
    Name = 'RainbowOverlay',
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Image = 'rbxassetid://3599925247',
    ImageColor3 = colorForProgress(0),
    ImageTransparency = 1,
    ScaleType = Enum.ScaleType.Stretch,
    Parent = albumArtContainer,
}, {
    New('UICorner', { CornerRadius = UDim.new(1, 0) }),
})
rainbowOverlay.ZIndex = 4


-- Ensure handle is above other elements
if progressHandle then
    progressHandle.ZIndex = 20
end

-- Create a vertical progress bar container where the red circle is (between panels)
-- Use a TextButton so it receives mouse events
progressBarContainer = New('TextButton', {
    Name = 'ProgressBarContainer',
    Size = UDim2.new(0, 18, 0, 260), -- narrow vertical bar
    Position = UDim2.new(1, -30, 0, 110), -- positioned 20px left of right edge of nowPlayingPanel
    BackgroundTransparency = 1,
    AutoButtonColor = false,
    ZIndex = 10, -- Ensure container is clickable above other elements
    Parent = nowPlayingPanel, -- place inside NowPlaying panel so it sits between panels
})

-- Create the progress bar background (vertical)
progressBarBg = New('Frame', {
    Name = 'ProgressBarBg',
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
    BorderSizePixel = 0,
    ZIndex = 5, -- Background layer
    Parent = progressBarContainer,
}, {
    New('UICorner', { CornerRadius = UDim.new(1, 0) }),
})

-- Create the progress bar fill (grows from bottom)
progressBarFill = New('Frame', {
    Name = 'ProgressBarFill',
    Size = UDim2.new(1, 0, 0, 0), -- start empty
    Position = UDim2.new(0, 0, 1, 0), -- anchored at bottom
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    Parent = progressBarBg,
}, {
    New('UICorner', { CornerRadius = UDim.new(1, 0) }),
})

-- Progress bar handle removed - using fill-only design

-- Time labels on the progress bar
-- Time labels (place total time above the bar and current time below)
local totalTimeLabel = New('TextLabel', {
    Name = 'TotalTime',
    Size = UDim2.new(0, 60, 0, 20),
    Position = UDim2.new(1, -8, 0, 96), -- above the top of the vertical bar (adjusted for new position)
    BackgroundTransparency = 1,
    Font = config.RegularFont,
    Text = '0:00',
    TextColor3 = config.SecondaryTextColor,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = nowPlayingPanel,
})

local currentTimeLabel = New('TextLabel', {
    Name = 'CurrentTime',
    Size = UDim2.new(0, 60, 0, 20),
    Position = UDim2.new(1, -8, 0, 360), -- below the bottom of the vertical bar (adjusted for new position)
    BackgroundTransparency = 1,
    Font = config.RegularFont,
    Text = '0:00',
    TextColor3 = config.SecondaryTextColor,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = nowPlayingPanel,
})

-- Volume Control (moved to below the red line, near song title)
local volumeContainer = New('Frame', {
	Name = 'VolumeContainer',
	Size = UDim2.new(0, 200, 0, 30),
	Position = UDim2.new(0.5, -100, 0, 367), -- Moved down 2px more
	BackgroundTransparency = 1,
	Parent = nowPlayingPanel,
})

volumeIcon = New('TextLabel', {
	Name = 'VolumeIcon',
	Size = UDim2.new(0, 20, 0, 20),
	Position = UDim2.new(0, -6, 0.5, -10),
	BackgroundTransparency = 1,
	Font = config.RegularFont,
	Text = '🔊',
	TextColor3 = config.SecondaryTextColor,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = volumeContainer,
})

volumeSlider = New('TextButton', {
	Name = 'VolumeSlider',
	Size = UDim2.new(1, -30, 0, 4),
	Position = UDim2.new(0, 25, 0.5, -2),
	BackgroundColor3 = Color3.fromRGB(60, 60, 60),
	BorderSizePixel = 0,
	Text = '', -- Empty text for button
	Parent = volumeContainer,
}, {
	New('UICorner', { CornerRadius = UDim.new(1, 0) }),
})

volumeProgress = New('Frame', {
	Name = 'VolumeProgress',
	Size = UDim2.new(0.7, 0, 1, 0), -- Start at 70% volume
	BackgroundColor3 = config.AccentColor1,
	BorderSizePixel = 0,
	Parent = volumeSlider,
}, {
	New('UICorner', { CornerRadius = UDim.new(1, 0) }),
})
volumeHandle = New('TextButton', {
    Name = 'VolumeHandle',
    Size = UDim2.new(0, 12, 0, 12),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.7, 0, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    Text = '', -- Empty text for button
    Parent = volumeSlider,
}, {
    New('UICorner', { CornerRadius = UDim.new(1, 0) }),
    New('UIStroke', {
        Color = config.AccentColor1,
        Thickness = 2,
    }),
})

print("🔍 Volume UI elements created - volumeSlider:", volumeSlider ~= nil, "volumeHandle:", volumeHandle ~= nil)

-- Circular progress bar is now integrated with seeking functionality

-- Removed heart/add/share buttons under album art per request

local visualizerContainer = New('Frame', {
	Name = 'Visualizer',
	Size = UDim2.new(0, 280, 0, 50),
	Position = UDim2.new(0.5, -140, 0, 335),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	Parent = nowPlayingPanel,
})

local visualizerBars = {}
local NUM_BARS = 40
for i = 1, NUM_BARS do
	local bar = New('Frame', {
		Name = 'Bar' .. i,
		Size = UDim2.new(0, 3, 0, 5),
		Position = UDim2.new(0, (i - 1) * 7, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = config.PrimaryTextColor,
		BorderSizePixel = 0,
		Parent = visualizerContainer,
	}, {
		New('UICorner', { CornerRadius = UDim.new(0, 3) }),
		New('UIGradient', {
			Color = ColorSequence.new(
				config.AccentColor1,
				config.AccentColor2
			),
			Rotation = 90,
		}),
	})
	table.insert(visualizerBars, bar)
end

-- Visual pulsing for album art (sync with beat)
-- Visual pulsing for album art (sync with beat)
-- pulse disabled after visual rollback
local function pulseAlbumArt(intensity)
    -- no-op to keep UI stable
end

local songTitle = New('TextLabel', {
	Name = 'SongTitle',
	Size = UDim2.new(1, 0, 0, 30),
	Position = UDim2.new(0, 0, 0, 395),
	BackgroundTransparency = 1,
	Font = config.BoldFont,
	Text = 'Song Title',
	TextColor3 = config.PrimaryTextColor,
	TextSize = 26,
	Parent = nowPlayingPanel,
})

local artistName = New('TextLabel', {
	Name = 'ArtistName',
	Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.new(0, 0, 0, 420),
	BackgroundTransparency = 1,
	Font = config.RegularFont,
	Text = 'Artist Name',
	TextColor3 = config.SecondaryTextColor,
	TextSize = 16,
	Parent = nowPlayingPanel,
})

local shuffleBtn = New('TextButton', {
	Name = 'Shuffle',
	Size = UDim2.new(0, 30, 0, 30),
	Position = UDim2.new(0.5, -120, 0, 450),
	BackgroundTransparency = 1,
	Text = '⇄',
	Font = config.RegularFont,
	TextColor3 = config.IconColor,
	TextSize = 20,
	AutoButtonColor = false,
	Parent = nowPlayingPanel,
})

local prevBtn = New('TextButton', {
	Name = 'Previous',
	Size = UDim2.new(0, 35, 0, 35),
	Position = UDim2.new(0.5, -75, 0, 448),
	BackgroundTransparency = 1,
	Text = '⏮',
	Font = config.RegularFont,
	TextColor3 = config.PrimaryTextColor,
	TextSize = 22,
	AutoButtonColor = false,
	Parent = nowPlayingPanel,
})

local playPauseBtn = New('TextButton', {
	Name = 'PlayPause',
	Size = UDim2.new(0, 50, 0, 50),
	Position = UDim2.new(0.5, -25, 0, 440),
	BackgroundTransparency = 1,
	Text = '▶',
	Font = config.BoldFont,
	TextColor3 = config.PrimaryTextColor,
	TextSize = 24,
	AutoButtonColor = false,
	Parent = nowPlayingPanel,
}, {
	New('UICorner', { CornerRadius = UDim.new(1, 0) }),
	New('UIGradient', {
		Color = ColorSequence.new(config.AccentColor1, config.AccentColor2),
	}),
	New('UIStroke', {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.8,
		Thickness = 2,
	}),
})

local nextBtn = New('TextButton', {
	Name = 'Next',
	Size = UDim2.new(0, 35, 0, 35),
	Position = UDim2.new(0.5, 40, 0, 448),
	BackgroundTransparency = 1,
	Text = '⏭',
	Font = config.RegularFont,
	TextColor3 = config.PrimaryTextColor,
	TextSize = 22,
	AutoButtonColor = false,
	Parent = nowPlayingPanel,
})

-- nextSong and prevSong functions will be defined after playSong

local repeatBtn = New('TextButton', {
	Name = 'Repeat',
	Size = UDim2.new(0, 30, 0, 30),
	Position = UDim2.new(0.5, 90, 0, 450),
	BackgroundTransparency = 1,
	Text = '🔄',
	Font = config.RegularFont,
	TextColor3 = config.IconColor,
	TextSize = 18,
	AutoButtonColor = false,
	Parent = nowPlayingPanel,
})

local playlistHeader = New('Frame', {
	Name = 'PlaylistHeader',
	Size = UDim2.new(1, -40, 0, 60),
	Position = UDim2.new(0, 20, 0, 20),
	BackgroundTransparency = 1,
	Parent = playlistPanel,
})

local playlistTitle = New('TextLabel', {
	Size = UDim2.new(1, -80, 0, 30),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundTransparency = 1,
	Text = 'Playlist Title',
	TextColor3 = config.PrimaryTextColor,
	Font = config.BoldFont,
	TextSize = 24,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = playlistHeader,
})

local playlistArtist = New('TextLabel', {
	Size = UDim2.new(1, -80, 0, 20),
	Position = UDim2.new(0, 0, 0, 28),
	BackgroundTransparency = 1,
	Text = 'Artist',
	TextColor3 = config.SecondaryTextColor,
	Font = config.RegularFont,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = playlistHeader,
})

-- Liked indicator removed

-- Sort control (Name / Liked / Default)
-- Move sort control next to unload button (top-right)
-- Sort feature removed per request

-- Remove playlist header buttons references (they were deleted)

playlistContainer = New('ScrollingFrame', {
	Name = 'PlaylistContainer',
	Size = UDim2.new(1, -40, 1, -100),
	Position = UDim2.new(0, 20, 0, 90),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 6,
	ScrollBarImageColor3 = config.AccentColor1,
	CanvasSize = UDim2.new(0, 0, 0, 0), -- Will be updated automatically
	Parent = playlistPanel,
}, {
	New('UIListLayout', {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}),
})

local songItemFrames = {}
local songDurationLabels = {}

local function stopUpdateLoop()
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

local function updateSongUI(index)
	if not index or index == 0 then
		-- No song selected
		songTitle.Text = 'No song selected'
		artistName.Text = 'Choose a song to play'
		totalTimeLabel.Text = '0:00'
		currentTimeLabel.Text = '0:00'
		playlistTitle.Text = 'Music Player'
		playlistArtist.Text = 'Select a song from the playlist'
	else
		local song = config.Playlist[index]
		songTitle.Text = song.title
		artistName.Text = song.artist
		totalTimeLabel.Text = formatTime(song.duration)
		currentTimeLabel.Text = '0:00'
		playlistTitle.Text = song.title
		playlistArtist.Text = song.artist
	end
	for i, frame in ipairs(songItemFrames) do
		local isCurrent = (i == index)
		local playIcon = frame:FindFirstChild('PlayIcon')
		local color = isCurrent and config.PlaylistHighlightColor
			or Color3.new(1, 1, 1)
		local transparency = isCurrent and 0 or 1
		local iconText = isCurrent and (isPlaying and '⏸' or '▶') or '▶'
		TweenService:Create(
			frame,
			TweenInfo.new(0.3),
			{
				BackgroundColor3 = color,
				BackgroundTransparency = transparency,
			}
		):Play()
		playIcon.Text = iconText
	end
end

-- Add a label for error messages
local errorLabel = New('TextLabel', {
	Name = 'ErrorLabel',
	Size = UDim2.new(1, 0, 0, 24),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundTransparency = 1,
	Text = '',
	TextColor3 = Color3.fromRGB(255, 100, 100),
	Font = config.BoldFont,
	TextSize = 18,
	ZIndex = 10,
	Parent = musicPlayer,
})

local function showError(msg)
	errorLabel.Text = msg
	task.wait(3)
	errorLabel.Text = ""
end

local function playSong(index)
	if isProcessing then return end
	isProcessing = true

	print("🎵 Playing song:", index, config.Playlist[index].title)

	stopUpdateLoop()
	if currentSound then
		currentSound:Destroy()
		currentSound = nil
	end

	currentSongIndex = index
	local songData = config.Playlist[currentSongIndex]

	currentSound = New('Sound', {
		SoundId = songData.soundId,
		Volume = currentVolume, -- Use the current volume setting
		Parent = SoundService,
	})

	print("🔊 Sound created, attempting to play...")

	local loaded = false
	local loadTimeout = 5
	local loadStart = tick()

	-- Listen for Loaded event
	currentSound.Loaded:Connect(function()
		loaded = true
	end)

	currentSound:Play()
	isPlaying = true
	playPauseBtn.Text = '⏸'

	updateSongUI(currentSongIndex)

	-- make filled/rainbow overlays visible for this playing session (force for debugging/visibility)
	pcall(function()
		if progressFilled then progressFilled.Visible = true end
		if rainbowOverlay then rainbowOverlay.Visible = true end
	end)

	-- Wait for sound to load or timeout
	while not loaded and tick() - loadStart < loadTimeout do
		if currentSound.TimeLength > 0 then
			loaded = true
			break
		end
		task.wait(0.1)
	end

	if not loaded or currentSound.TimeLength == 0 then
		showError("⚠️ Unable to play this audio. It may be restricted or not public.")
		print("⚠️ Unable to play audio:", songData.soundId)
		currentSound:Stop()
		isPlaying = false
		playPauseBtn.Text = '▶'
		isProcessing = false
		return
	end

	-- Update UI durations to reflect actual loaded length
	local realLength = math.floor(currentSound.TimeLength or 0)
	if realLength > 0 then
		config.Playlist[currentSongIndex].duration = realLength
		totalTimeLabel.Text = formatTime(realLength)
		if songDurationLabels[currentSongIndex] then
			songDurationLabels[currentSongIndex].Text = formatTime(realLength)
		end
	end

	-- Start update loop for progress bar and visualizer
connection = RunService.Heartbeat:Connect(function()
		if not currentSound or not isPlaying then
			return
		end
		if currentSound.TimeLength > 0 then
			local progress = currentSound.TimePosition / currentSound.TimeLength
			progress = math.clamp(progress, 0, 1)
			
			-- Update progress bar (now smooth and real-time)
			updateProgressBar(progress)
			
			-- Update time display
			currentTimeLabel.Text = formatTime(currentSound.TimePosition)
			
			-- Visualizer bars (with smooth animation)
			local loudness = currentSound.PlaybackLoudness or 0
			for i, bar in ipairs(visualizerBars) do
				local height = math.clamp(loudness / 50 + math.random(-5, 5), 2, 50)
				if i % 2 == 0 then
					height = math.clamp(loudness / 70 + math.random(-2, 2), 2, 40)
				end
				-- Use faster tween for more responsive visualizer
				TweenService:Create(bar, TweenInfo.new(0.05), { Size = UDim2.new(0, 3, 0, height) }):Play()
			end
			
            -- Check for song end (guard nextSong in case it's not defined yet)
            if currentSound.TimePosition >= currentSound.TimeLength - 0.1 then
                if type(nextSong) == 'function' then
                    nextSong()
                else
                    debugLog('nextSong not defined when playback ended; skipping')
                end
            end
		end
	end)

	-- Force initial progress bar update to show handle position
	task.wait(0.1)
	updateProgressBar(0.1) -- Show 10% progress initially

	task.wait(0.1)
	isProcessing = false
end

-- Ensure next/prev are defined before they're called in update loop
nextSong = function()
    if isProcessing then return end
    if isRepeating then
        playSong(currentSongIndex)
        return
    end
    local nextIndex
    if isShuffled then
        local pool = getShufflePool()
        if #pool == 0 then
            nextIndex = math.random(1, #config.Playlist)
        else
            nextIndex = pool[math.random(1, #pool)]
        end
    else
        nextIndex = currentSongIndex + 1
        if nextIndex > #config.Playlist then nextIndex = 1 end
    end
    playSong(nextIndex)
end

prevSong = function()
    if isProcessing then return end
    local prevIndex
    if isShuffled then
        local pool = getShufflePool()
        if #pool == 0 then
            prevIndex = math.random(1, #config.Playlist)
        else
            prevIndex = pool[math.random(1, #pool)]
        end
    else
        prevIndex = currentSongIndex - 1
        if prevIndex < 1 then prevIndex = #config.Playlist end
    end
    playSong(prevIndex)
end

local function togglePlayPause()
	if isProcessing then return end
	isProcessing = true

	if not currentSound then
		playSong(currentSongIndex)
		isProcessing = false
		return
	end

	if isPlaying then
		currentSound:Pause()
		playPauseBtn.Text = '▶'
		isPlaying = false
		stopUpdateLoop()
	else
		-- Check if sound is playable before resuming
		if currentSound.TimeLength == 0 then
			showError("⚠️ Unable to play this audio. It may be restricted or not public.")
			isProcessing = false
			return
		end
		currentSound:Play()
		playPauseBtn.Text = '⏸'
		isPlaying = true
		connection = RunService.Heartbeat:Connect(function()
			if not currentSound or not isPlaying then
				return
			end
			if currentSound.TimeLength > 0 then
				local progress = currentSound.TimePosition / currentSound.TimeLength
				progress = math.clamp(progress, 0, 1)
				
				-- Update linear progress bar
				updateProgressBar(progress)
				
				currentTimeLabel.Text = formatTime(currentSound.TimePosition)
				local loudness = currentSound.PlaybackLoudness
				for i, bar in ipairs(visualizerBars) do
					local height = math.clamp(loudness / 50 + math.random(-5, 5), 2, 50)
					if i % 2 == 0 then
						height = math.clamp(loudness / 70 + math.random(-2, 2), 2, 40)
					end
					TweenService:Create(
						bar,
						TweenInfo.new(0.1),
						{ Size = UDim2.new(0, 3, 0, height) }
					):Play()
				end
				if currentSound.TimePosition >= currentSound.TimeLength - 0.1 then
					nextSong()
				end
			end
		end)
	end
	updateSongUI(currentSongIndex)
	task.wait(0.1)
	isProcessing = false
end

-- Navigation functions moved before playSong

nextSong = function()
    if isProcessing then return end
    if isRepeating then
        -- replay current song
        playSong(currentSongIndex)
        return
    end
    local nextIndex
    if isShuffled then
        local pool = getShufflePool()
        if #pool == 0 then
            nextIndex = math.random(1, #config.Playlist)
        else
            nextIndex = pool[math.random(1, #pool)]
        end
    else
        nextIndex = currentSongIndex + 1
        if nextIndex > #config.Playlist then nextIndex = 1 end
    end
    playSong(nextIndex)
end

prevSong = function()
    if isProcessing then return end
    local prevIndex
    if isShuffled then
        local pool = getShufflePool()
        if #pool == 0 then
            prevIndex = math.random(1, #config.Playlist)
        else
            prevIndex = pool[math.random(1, #pool)]
        end
    else
        prevIndex = currentSongIndex - 1
        if prevIndex < 1 then prevIndex = #config.Playlist end
    end
    playSong(prevIndex)
end

for i, song in ipairs(config.Playlist) do
	local songItem = New('Frame', {
		Name = song.title,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		LayoutOrder = i,
		Parent = playlistContainer,
	}, {
		New('UICorner', { CornerRadius = UDim.new(0, 10) }),
	})
	table.insert(songItemFrames, songItem)

	local playBtn = New('TextButton', {
		Name = 'PlayButton',
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = '',
	})
	playBtn.Parent = songItem
	playBtn.MouseButton1Click:Connect(function()
		if i == currentSongIndex then
			togglePlayPause()
		else
			playSong(i)
		end
	end)

	local playIcon = New('TextLabel', {
		Name = 'PlayIcon',
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 15, 0.5, -15),
		BackgroundTransparency = 1,
		Font = config.RegularFont,
		Text = '▶',
		TextColor3 = config.SecondaryTextColor,
		TextSize = 20,
		Parent = songItem,
	})

	New('TextLabel', {
		Size = UDim2.new(1, -120, 0, 20),
		Position = UDim2.new(0, 55, 0, 7),
		BackgroundTransparency = 1,
		Font = config.RegularFont,
		Text = song.title,
		TextColor3 = config.PrimaryTextColor,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = songItem,
	})
	New('TextLabel', {
		Size = UDim2.new(1, -120, 0, 16),
		Position = UDim2.new(0, 55, 0, 25),
		BackgroundTransparency = 1,
		Font = config.RegularFont,
		Text = song.artist,
		TextColor3 = config.SecondaryTextColor,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = songItem,
	})
	local durationLabel = New('TextLabel', {
		Size = UDim2.new(0, 50, 0, 20),
		Position = UDim2.new(1, -60, 0.5, -10),
		BackgroundTransparency = 1,
		Font = config.RegularFont,
		Text = formatTime(song.duration),
		TextColor3 = config.SecondaryTextColor,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = songItem,
	})

	songDurationLabels[i] = durationLabel
end

-- Update CanvasSize to show all songs
local listLayout = playlistContainer:FindFirstChild('UIListLayout')
if listLayout then
	-- Wait for layout to calculate
	task.wait(0.1)
	-- Update canvas size to fit all content
	local totalHeight = (#config.Playlist * 60) + ((#config.Playlist - 1) * 10) -- 50px per song + 10px padding
	playlistContainer.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
	print("🎵 Updated playlist canvas size to show all", #config.Playlist, "songs!")
end

-- Volume Control Events (moved here after UI creation)
print("🔍 Debug: volumeSlider exists:", volumeSlider ~= nil)
print("🔍 Debug: progressArc exists:", progressArc ~= nil)

local function onVolumeSliderClick()
	local mouse = game:GetService('Players').LocalPlayer:GetMouse()
	setVolumeFromPosition(mouse.X)
end

if volumeSlider then
	volumeSlider.MouseButton1Click:Connect(onVolumeSliderClick)
	print("✅ Volume slider event connected")
else
	print("❌ Volume slider is nil, cannot connect event")
end

if volumeHandle then
	volumeHandle.MouseButton1Down:Connect(function()
		isDraggingVolume = true
		print("🔊 Volume dragging started")
	end)
	print("✅ Volume handle event connected")
else
	print("❌ Volume handle is nil, cannot connect event")
end

-- Attach hover effects for volume slider
if volumeSlider and volumeHandle then
    addVolumeHover(volumeSlider, volumeHandle)
end

-- Linear Progress Bar Events (moved here after UI creation)
-- Wait for GUI to render before connecting seek events
task.wait(0.1)

if progressBarContainer then
    progressBarContainer.MouseButton1Click:Connect(function()
        local mouse = game:GetService('Players').LocalPlayer:GetMouse()
        debugLog("Progress bar clicked at", mouse.X, mouse.Y)
        -- Only seek if container is fully rendered
        if progressBarContainer.AbsoluteSize and progressBarContainer.AbsoluteSize.Y > 0 then
            seekToPosition(mouse.X, mouse.Y)
        else
            debugLog("Progress bar not ready for seeking yet")
        end
    end)
    -- start dragging when pressing down on the bar
    progressBarContainer.MouseButton1Down:Connect(function()
        isDraggingProgress = true
        local mouse = game:GetService('Players').LocalPlayer:GetMouse()
        -- Only seek if container is fully rendered
        if progressBarContainer.AbsoluteSize and progressBarContainer.AbsoluteSize.Y > 0 then
            seekToPosition(mouse.X, mouse.Y)
        else
            debugLog("Progress bar not ready for dragging yet")
        end
        debugLog("Progress drag started via container")
    end)
    debugLog("Progress bar container event connected")
else
    debugLog("Progress bar container is nil, cannot connect event")
end

-- Progress bar handle removed - no handle events needed

-- Attach hover effects for progress bar (handle removed)
if progressBarContainer and progressBarBg then
    addProgressBarHover(progressBarContainer, progressBarBg, nil)
end

local UserInputService = game:GetService('UserInputService')

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isDraggingVolume then
			print("🔊 Volume dragging ended")
		end
		if isDraggingProgress then
			print("🎵 Progress dragging ended")
		end
		isDraggingVolume = false
		isDraggingProgress = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if isDraggingVolume then
			local mouse = game:GetService('Players').LocalPlayer:GetMouse()
			setVolumeFromPosition(mouse.X)
		elseif isDraggingProgress then
			local mouse = game:GetService('Players').LocalPlayer:GetMouse()
			-- Only seek if container is fully rendered
			if progressBarContainer and progressBarContainer.AbsoluteSize and progressBarContainer.AbsoluteSize.Y > 0 then
				seekToPosition(mouse.X, mouse.Y)
			end
		end
	end
end)

playPauseBtn.MouseButton1Click:Connect(togglePlayPause)

nextBtn.MouseButton1Click:Connect(nextSong)

prevBtn.MouseButton1Click:Connect(prevSong)

shuffleBtn.MouseButton1Click:Connect(function() toggleShuffle(shuffleBtn) end)
repeatBtn.MouseButton1Click:Connect(function() toggleRepeat(repeatBtn) end)

-- Event connections moved to after UI creation

-- Playlist header buttons removed

unloadBtn.MouseButton1Click:Connect(function()
	print("🚪 Unloading music player...")
	TweenService:Create(musicPlayer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()
	task.wait(0.3)
	mainGui:Destroy()
end)

addHoverEffect(unloadBtn, Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 150, 150))
addHoverEffect(shuffleBtn, config.IconColor, config.AccentColor1)
addHoverEffect(repeatBtn, config.IconColor, config.AccentColor1)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Space then
			togglePlayPause()
		elseif input.KeyCode == Enum.KeyCode.Right then
			nextBtn.MouseButton1Click:Fire()
		elseif input.KeyCode == Enum.KeyCode.Left then
			prevBtn.MouseButton1Click:Fire()
		elseif input.KeyCode == Enum.KeyCode.Escape then
			unloadBtn.MouseButton1Click:Fire()
		end
	end
end)

updateSongUI(0) -- Start with no song selected

print("🎵 Improved Music Player Loaded!")
print("🎮 Controls:")
print("   Space - Play/Pause")
print("   Arrow Keys - Navigate songs")
print("   Escape - Close player")
print("💖 All buttons now have hover effects and functionality!")
print("🚪 Use the X button (top right) or Escape to close")
print("🔊 Click play or press Space to start music!")
debugLog("UI created; progressArc=" .. tostring(progressArc) .. " progressFilled=" .. tostring(progressFilled) .. " albumArtContainer=" .. tostring(albumArtContainer))

-- Preload all songs to get their actual durations
task.spawn(function()
	print("🎵 Pre-loading all songs to calculate durations...")
	local loadedCount = 0
	local totalSongs = #config.Playlist

	for i, songData in ipairs(config.Playlist) do
		local tempSound = New('Sound', {
			SoundId = songData.soundId,
			Volume = 0, -- Silent for preloading
			Parent = SoundService,
		})

		local loaded = false
		local loadTimeout = 3 -- Shorter timeout for preloading
		local loadStart = tick()

		tempSound.Loaded:Connect(function()
			loaded = true
		end)

		-- Wait for sound to load
		while not loaded and tick() - loadStart < loadTimeout do
			if tempSound.TimeLength > 0 then
				loaded = true
				break
			end
			task.wait(0.05)
		end

		if loaded and tempSound.TimeLength > 0 then
			-- Update the duration in the playlist data
			config.Playlist[i].duration = math.floor(tempSound.TimeLength)
			loadedCount = loadedCount + 1
			print(string.format("✅ Song %d/%d loaded: %s (%ds)", i, totalSongs, songData.title, config.Playlist[i].duration))
		else
			print(string.format("⚠️ Song %d/%d failed to load: %s", i, totalSongs, songData.title))
		end

		-- Update duration labels if they exist
		if songDurationLabels[i] then
			songDurationLabels[i].Text = formatTime(config.Playlist[i].duration)
		end

		tempSound:Destroy()
		task.wait(0.02) -- Small delay between loads to avoid overwhelming
	end

	print(string.format("🎵 Preloading complete! %d/%d songs loaded successfully.", loadedCount, totalSongs))

	-- Song will be loaded when user selects one
print("🎵 Ready to play! Select a song from the playlist.")
end)

-- Liked persistence removed

-- Initialize volume
updateVolume(currentVolume)
print("🔊 Volume control initialized at", math.floor(currentVolume * 100) .. "%")
print("🎵 Progress bar initialized - click to seek!")


