json = require('dkjson')
build = require('builddata')
upgr = require('upgradedata')

cookies = 0
cpc = 1
cps = 0
lastClick = os.time()
totalClicks = 0
cpcMult = false

currentBg = 'bgBlue.jpg'
soda = false

function Save()
	local data = 
	{
		_cookies = cookies,
		_cpc = cpc,
		_cps = cps,
		_lastClick = os.time(),
		_build = build,
		_upgr = upgr,
		_cpcMult = cpcMult,
		_soda = soda
	}

	local jsonData = json.encode(data)
	local file = io.open('save.json', 'w')
	if (file) then
		file:write(jsonData)
		file:close()
	else
		createTextfield('Failed to open save json')
	end
end

function Load()
	local file = io.open('save.json', 'r')
	if (file) then
		local jsonData = file:read('*a')
		local data = json.decode(jsonData)

		cookies = data._cookies
		cpc = data._cpc
		cps = data._cps
		lastClick = data._lastClick
		build = data._build
		upgr = data._upgr
		cpcMult = data._cpcMult
		soda = data._soda
	else
		cookies = 0
		cpc = 1
		cps = 0
		lastClick = os.time()
	end
end

function CalcCPS()
	local totalCps = 0

	for i = 1, #build do
		mult = 0
		-- If the upgrade for that buidling exists
		if (upgr[i] ~= nil) then
			-- Calc how many are bought
			for j = 1, #upgr[i] do
				if (not upgr[i][j].bought) then
					break
				else 
					mult = mult + 2
				end
			end
		end

		-- Apply multiplier
		local cpsWithoutMult = build[i].cps * build[i].amount
		if (mult >= 1) then
			totalCps = totalCps + cpsWithoutMult * mult
		else
			totalCps = totalCps + cpsWithoutMult
		end
	end

	return totalCps
end


function story(aName)
	CLS()

	totalClicks = totalClicks + 1

	if (aName == 'start') then
		Load()
		createTextfield('After 128 clicks, the font will dissappear.\nTo avoid data getting lost,             the game will save and quit when you reach this number')
		createButton('click', 'Start')

		currentBg = 'bgBlue.jpg'
	end

	-- Click
	if (aName == 'click') then
		-- Calc cookies
		if (cpcMult) then
			cpc = cps * .1 + 1
		end
		cookies = cookies + cpc
		cps = CalcCPS()

		-- Add idle cookies
		timeElapsed = os.time() - lastClick
		cookies = cookies + cps * timeElapsed
		lastClick = os.time()

		-- Text & buttons
		createTextfield(
			'Cookies: ' .. cookies .. 
			'\nCPS: ' .. cps .. 
			'\nClicks before closing: ' .. 101 - totalClicks
		)
		createButton('click', 'Click')
		createButton('shop', 'Shop')
		createButton('options', 'Options')
		createButton('exit', 'Quit')

		-- Set background (it may be evil >:) )
		if (math.random(1, 500) == 9) then
			currentBg = 'bgEvil.jpg'
		else
			currentBg = 'bg.jpg'
		end

		-- If SODA mode is enabled
		if (soda) then
			playSound('JOE BIDEN SODA.wav')
		else
			playSound('click/clickb' .. math.random(2, 7) .. '.wav')
		end
	end


	-- Shops
	if (aName == 'shop') then
		createButton('click', 'Return to cookie')
		createButton('building', 'Buildings')
		createButton('upgrades', 'Upgrades')

		currentBg = 'storeTile.jpg'
	end

	-- Building shop
	if (aName == 'building') then
		createButton(
			'click', 
			'Return to cookie - ' .. cookies .. ' cookies'
		)

		for i = 1, #build do
			local price = build[i].amount == 0 and build[i].basePrice or build[i].basePrice * build[i].amount * 1.15
			createButton(
				'bbuy' .. i .. price, 
				'Buy ' .. build[i].name .. ' for ' .. price .. ' - ' .. build[i].amount
			)
		end
	end
	if (aName:sub(1, 4) == 'bbuy') then
		local item = tonumber(aName:sub(5, 5))
		local price = tonumber(aName:sub(6))

		createButton(
			'click', 
			'Return to cookie - ' .. cookies .. ' cookies'
		)
		createButton('building', 'Return to building shop')
		if (price <= cookies) then
			build[item].amount = build[item].amount + 1
			cookies = cookies - price

			createTextfield('Bought 1 ' .. build[item].name)
			createButton('bbuy' .. item .. price, 'Buy more')
		else
			createTextfield('Not enough cookies')
		end
	end

	-- Upgrade shop
	if (aName == 'upgrades') then
		createButton('click', 'Return to cookie - ' .. cookies .. ' cookies')
		if (not cpcMult) then
			createButton('specialUbuy', 'Buy cpc multiplier for ' .. 1e9 .. ' cookies')
		end

		for i = 1, #upgr do
			for j = 1, #upgr[i] do
				if (not upgr[i][j].bought) then
					createButton(
						'ubuy,' .. i .. ',' .. j .. ',' .. ',' .. upgr[i][j].price, 
						'Buy ' .. upgr[i][j].name .. ' for ' .. upgr[i][j].price
					)

					break
				end
			end
		end
	end
	if (aName:sub(1, 4) == 'ubuy') then
		-- Get data from string
		local data = {}
		for str in  aName:gmatch("[^,]+") do
			table.insert(data, str)
		end

		createButton('click', 'Return to cookie')
		createButton('upgrades', 'Return to upgrade shop')

		-- Apply data
		local item, v, price = 
			tonumber(data[2]), 
			tonumber(data[3]), 
			tonumber(data[4])
		
		if (price <= cookies) then
			cookies = cookies - price

			upgr[item][v].bought = true
			createTextfield('Bought ' .. upgr[item][v].name)
		else 
			createTextfield('Not enough cookies')
		end
	end
	if (aName == 'specialUbuy') then
		createButton('click', 'Return to cookie')
		createButton('upgrades', 'Return to upgrade shop')

		if (cookies >= 1e9) then
			cpcMult = true
			createTextfield('Bought cpc multiplier')
		else
			createTextfield('Not enough cookies')
		end
	end


	-- Options
	if (aName == 'options') then
		createButton('click', 'Return to cookie')
		createButton('soda', 'Enable SODA mode (this is permanent)')
		createButton('optionsDelete', 'Delete (I\'m gonna warn you)')
	end

	-- Delete
	if (aName == 'optionsDelete') then
		cookies = 0
		cpc = 1
		cps = 0
		lastClick = os.time()
		build = require('builddata')
		upgr = require('upgradedata')

		if (soda) then
			createTextfield('Did you really think you could escape soda?')
		else
			createTextfield(
				'Removed your save :(' ..
				'\nSave and quit for it to be permanent'
			)
		end
		createButton('click', 'So sad')
	end
	if (aName == 'soda') then
		soda = true
		createTextfield('SODA')
		createButton('click', 'SODA')
	end

	-- Enable soda mode
	if (soda) then
		setBackground('joe.jpg')
	else
		setBackground(currentBg)
	end

	if (aName == 'exit' or totalClicks >= 100) then
		Save()

		exitGame()
	end
end
