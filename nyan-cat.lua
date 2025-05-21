args = {...} or {}
local animate = false
local verbose = false
local help = false

for i,v in ipairs(args) do
	if v:match("--animate") then animate = true end
	if v:match("--verbose") then verbose = true end
	if v:match("--help") then help = true end
end

if help then
	print([[
	NAME
		NyanCat.lua

	SYNOPSIS
		lua NyanCat.lua [--animate] [--verbose] [--help]

	DESCRIPTION
		A pointless lua program that prints the NyanCat to the terminal

		The options are as follows:
			--animate		The cat moves :3
			--verbose		Print also information
			--help			Show this and exit
		]])
	os.exit(0)
end

local backgroundPatternOffset = 3
local backgroundPatternLimit = 20
local backgroundPatternRate = 0.05
local NyanCatAnimationRate = 0.07
local updateRate = 0.01
local naynCatOffset = 22
local frames = require("cat")

local system = (package.config:sub(1,1) == "/") and "Unix" or "Windows"
local sleepcmd = {
	Unix = "sleep %s",
	Windows = "timeout /t %s"
}

local function systemWait(seconds)
	os.execute(string.format(sleepcmd[system], seconds))
end

local function wait(seconds)
	local start = os.clock()
	repeat until os.clock() > start + seconds
end

--Base frame
local rawFrame = {
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
	{0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,},
	{0,0,0,0,0,0,0,0,1,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,1,0,0,0,0,0,0,},
	{0,0,0,0,0,0,0,1,7,7,7,5,5,5,5,5,5,5,5,5,5,5,5,5,7,7,7,1,0,0,0,0,0,},
	{0,0,0,0,0,0,0,1,7,7,5,5,5,5,5,5,4,5,5,4,5,5,5,5,5,7,7,1,0,0,0,0,0,},
	{0,0,0,0,0,0,0,1,7,5,5,4,5,5,5,5,5,5,5,1,1,5,5,5,5,5,7,1,0,1,1,0,0,},
	{0,0,0,0,0,0,0,1,7,5,5,5,5,5,5,5,5,5,1,3,3,1,5,4,5,5,7,1,1,3,3,1,0,},
	{0,0,0,0,0,0,0,1,7,5,5,5,5,5,5,5,5,5,1,3,3,3,1,5,5,5,7,1,3,3,3,1,0,},
	{0,0,1,1,0,0,0,1,7,5,5,5,5,5,5,4,5,5,1,3,3,3,3,1,1,1,1,3,3,3,3,1,0,},
	{0,1,3,3,1,0,0,1,7,5,5,5,5,5,5,5,5,5,1,3,3,3,3,3,3,3,3,3,3,3,3,1,0,},
	{0,1,3,3,1,1,1,1,7,5,5,5,4,5,5,5,5,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,},
	{0,0,1,3,3,3,3,1,7,5,5,5,5,5,5,5,4,1,3,3,3,2,1,3,3,3,3,3,2,1,3,3,1,},
	{0,0,0,1,1,3,3,1,7,5,4,5,5,5,5,5,5,1,3,3,3,1,1,3,3,3,1,3,1,1,3,3,1,},
	{0,0,0,0,0,1,1,1,7,5,5,5,5,5,5,5,5,1,3,6,6,3,3,3,3,3,3,3,3,3,6,6,1,},
	{0,0,0,0,0,0,0,1,7,5,5,5,5,5,4,5,5,1,3,6,6,3,1,3,3,1,3,3,1,3,6,6,1,},
	{0,0,0,0,0,0,0,1,7,7,5,4,5,5,5,5,5,5,1,3,3,3,1,1,1,1,1,1,1,3,3,1,0,},
	{0,0,0,0,0,0,1,1,7,7,7,5,5,5,5,5,5,5,5,1,3,3,3,3,3,3,3,3,3,3,1,0,0,},
	{0,0,0,0,0,1,3,1,1,7,7,7,7,7,7,7,7,7,7,7,1,1,1,1,1,1,1,1,1,1,0,0,0,},
	{0,0,0,0,1,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,0,0,0,0,0,},
	{0,0,0,0,1,3,3,1,0,1,3,3,1,0,0,0,0,0,0,1,3,3,1,0,1,3,3,1,0,0,0,0,0,},
	{0,0,0,0,1,1,1,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,},
}

--[[
	Color index:
	0 = transparent
	1 = black - lines
	2 = white - eyes
	3 = gray - fur
	4 = purple - speckles
	5 = pink - icing
	6 = light pink
	7 = beige - Outer bread
]]

local colorOpen = "\27["
local colorOpenEnd = "m"
local colorClose = "\27["
local colorCloseEnd = "m"
local frameColorIndex = {
	{0,0},		--Transparent
	{40,49},	--Black
	{107,49},	--White
	{100,39},	--Gray
	{105,49},	--Purple
	{45,49},	--pink
	{105,39},	--Light pink
	{103,49},	--Beige
}

local backgroundPattern = {
	{1,1,1,1,0,0,0,0,},
	{1,1,1,1,1,1,1,1,},
	{1,1,1,1,1,1,1,1,},
	{2,2,2,2,1,1,1,1,},
	{2,2,2,2,2,2,2,2,},
	{2,2,2,2,2,2,2,2,},
	{3,3,3,3,2,2,2,2,},
	{3,3,3,3,3,3,3,3,},
	{3,3,3,3,3,3,3,3,},
	{5,5,5,5,3,3,3,3,},
	--{4,4,4,4,4,4,4,4,},
	--{4,4,4,4,4,4,4,4,},
	--{5,5,5,5,4,4,4,4,},
	{5,5,5,5,5,5,5,5,},
	{5,5,5,5,5,5,5,5,},
	{6,6,6,6,5,5,5,5,},
	{6,6,6,6,6,6,6,6,},
	{6,6,6,6,6,6,6,6,},
	{0,0,0,0,6,6,6,6,},
}

--[[
	Rainbow color index:
	0 = transparent
	1 = red
	2 = orange
	3 = lime
	4 = green
	5 = cyan
	6 = violet
]]

local backgroundColorIndex = {
	{0,0},
	{41,49},
	{43,49},
	{42,49},
	{102,49},
	{106,49},
	{45,49},
}

local RainbowAnimatedOffset = 0
local NyanCatAnimatedOffset = 0
local function draw()
	--Clear the terminal
	io.stdout:write("\027[2J")

	--Reset the terminal
	io.stdout:write("\027c")

	local bgOffset = 1
	rawFrame = frames[NyanCatAnimatedOffset + 1]
	for i, v in ipairs(rawFrame) do
		for j, k in ipairs(v) do
			--Reset / init String
			local str = " "

			--Rainbow
			if backgroundPatternOffset <= i
				and backgroundPatternLimit >= j
				and bgOffset <= #backgroundPattern then

				local x = j + RainbowAnimatedOffset
				local y = bgOffset
				x = (x % #backgroundPattern[1])
				x = (x == 0) and #backgroundPattern[1] or x
				--x = math.min(x, backgroundPatternLimit)
				y = (y % #backgroundPattern)
				y = (y == 0) and #backgroundPattern or y
				local color = backgroundColorIndex[backgroundPattern[y][x] + 1]
				local open = colorOpen .. color[1] .. colorOpenEnd
				local close = colorClose .. color[2] .. colorCloseEnd
				str = open .. " " .. close

			end

			--Nyan cat
			if k ~= 0 then
				local color = frameColorIndex[k + 1]
				local open = colorOpen .. color[1] .. colorOpenEnd
				local close = colorClose .. color[2] .. colorCloseEnd
				str = open .. " " .. close
			end

			--Write twice to account the 1x2 ratio
			io.stdout:write(str)
			io.stdout:write(str)
		end
		if backgroundPatternOffset <= i then bgOffset = bgOffset + 1 end
		io.stdout:write("\n")
	end

	if verbose then
		print(
			"Tick rate: " .. updateRate ..
			" RainbowFrame: " .. RainbowAnimatedOffset..
			" NyanCatFrame: " .. NyanCatAnimatedOffset
			)
	end
end

backgroundPatternAccum = 0
NyanCatAnimationAccum = 0
local function update(dt)
	backgroundPatternAccum = backgroundPatternAccum + dt
	if backgroundPatternAccum >= backgroundPatternRate then
		RainbowAnimatedOffset = RainbowAnimatedOffset + 1
		RainbowAnimatedOffset = RainbowAnimatedOffset % #backgroundPattern[1]
		backgroundPatternAccum = 0
	end

	NyanCatAnimationAccum = NyanCatAnimationAccum + dt
	if NyanCatAnimationAccum >= NyanCatAnimationRate then
		NyanCatAnimatedOffset = NyanCatAnimatedOffset + 1
		NyanCatAnimatedOffset = NyanCatAnimatedOffset % #frames
		NyanCatAnimationAccum = 0
	end
end

if animate then
	while true do
		update(updateRate)
		if NyanCatAnimationAccum == 0 or backgroundPatternAccum == 0 then
			draw()
		end
		wait(updateRate)
	end
else
	draw()
end

