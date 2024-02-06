json = require('dkjson')
build = require('builddata')
upgr = require('upgradedata')

cookies = 0
cpc = 1
cps = 0
lastClick = os.time()
totalClicks = 0

function Save()
	local data = 
	{
		_cookies = cookies,
		_cpc = cpc,
		_cps = cps,
		_lastClick = os.time(),
		_build = build 
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
	else
		-- Standaardwaarden instellen als het bestand niet bestaat
		cookies = 0
		cpc = 1
		cps = 0
		lastClick = os.time() -- Gebruik de huidige tijd als standaardwaarde voor lastClick
		createTextfield('Failed to open save json, using default values')
	end
end

function CalcCPS()
	local totalCps = 0

	for i = 1, #build do
		totalCps = totalCps + build[i].cps * build[i].amount
	end

	return totalCps
end


function story(aName)
	CLS()
	setBackground('bg.jpg')

	totalClicks = totalClicks + 1

	if (aName == 'start') then
		Load()
		createTextfield('After 128 clicks, the font will dissappear.\nTo avoid data getting lost,             the game will save and quit when you reach this number')
		createButton('click', 'Start')

		setBackground('bgBlue.jpg')
	end

	-- Click
	if (aName == 'click') then
		-- Calc cookies
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
			'\nClicks before closing: ' .. 121 - totalClicks
		)
		createButton('click', 'Click')
		createButton('shop', 'Shop')
		createButton('exit', 'Quit')

		playSound('click/clickb' .. math.random(2, 7) .. '.wav')
	end


	-- Shops
	if (aName == 'shop') then
		createButton('click', 'Return to cookie')
		createButton('building', 'Buildings')
		createButton('upgrades', 'Upgrades')
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
			createTextfield('Not enough money')
		end
	end

	-- Upgrade shop
	if (aName == 'upgrades') then
		createButton('click', 'Return to cookie - ' .. cookies .. ' cookies')

		for i = 1, #upgr do
			local item = upgr[i]
			for j = 1, #item do
				if (not item[j].bought) then
					createButton(
						'ubuy' .. i .. j .. price, 
						'Buy ' .. item[j].name .. ' for ' .. item[j].price
					)

					break
				end
			end
		end
	end


	if (aName == 'exit' or totalClicks >= 120) then
		Save()

		exitGame()
	end
end
