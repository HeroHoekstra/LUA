--[[
The program will launch the function "story" with the button label as argument.

The following functions have been exposed to lua:

	set the background to the texture in the folder textures (JPG):
		setBackground(string aPath);
		
	add a button to the current screen:
		createButton(string areaName, string buttonText);

	add a textfield to the top of the screen:
		createTextfield(string text);
	
	Clear the screen:
		CLS();
		
	Exit the game:
		exitGame();
	
	Play a sound (wav) in the folder sounds:
		playSound(string aPath);
		
	Play music (wav) in the folder music:
		playMusic(string aPath);
		
	----------------------------------------------------------------------------------------------------------
	
	SYNTAX:
		LUA does not use many special characters but does accept some.
		
		Example:
		if(aName == "start") then
			playMusic("background.wav")
		end
		
	----------------------------------------------------------------------------------------------------------
		
		LUA also accepts variables in global scope and are interpreted during runtime
		
		Example:
		
		entered = false
		number = 5;
		
		and they can be used like any other variable:
		if(entered == false) then
			playSound("door.wav")
		end
	
	---------------------------------------------------------------------------------------------------------
]]--

hasKey = false;
function story(aName)
	if(aName == "start") then
		createButton("ClassRoom", "De text op de knop")
	end
	if(aName == "ClassRoom") then
		createTextfield("Welcome to the haunted mansion")
		createButton("Enter", "Enter the mansion")
		createButton("Exit", "Exit the mansion")
	end
	if(aName == "Enter") then
		if(hasKey == false) then
			createButton("Closet", "You try to open the closet")

	end
end

