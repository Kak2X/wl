-- Collision box viewer script
-- requires bit.lua from luabit 0.4 (http://files.luaforge.net/releases/bit/bit)


-- Keybinding
--unlockScrollKey = "A"

-- Options
config = {}
config['show-object-coords'] = false; -- Show X and Y absolute coordinates of objects

-- Do not touch the rest
require 'bit'

--require 'wl-ram'
-- Ram addresses
ram = {}
ram['scroll']        = 0xACE0
ram['scroll-end']    = 0xAD00
ram['block-def']     = 0xAD00
ram['level-layout']  = 0xC000
ram['powerup']       = 0xA80A
ram['lives']         = 0xA809
ram['debug']         = 0xA8C7
ram['actors']   	 = 0xA200
ram['actors-end']    = 0xA300
ram['level-id']      = 0xA804
ram['level-y']       = 0xA900 -- word
ram['level-x']       = 0xA902 -- word
ram['pl-y']          = 0xA911
ram['pl-x']          = 0xA913
ram['pl-y-rel']      = 0xA91C
ram['pl-x-rel']      = 0xA91D
ram['pl-coli-l']     = 0xA920
ram['pl-coli-r']     = 0xA921
ram['pl-coli-u']     = 0xA922
ram['pl-coli-d']     = 0xA923
ram['time']          = 0xA964
-- ----DULR
scroll = {}
scroll['right']  = 0x01 --0b0001,
scroll['left']   = 0x02 --0b0010,
scroll['down']   = 0x08 --0b0100,
scroll['up']     = 0x04 --0b1000
-- Convenience
scroll['all']    = 0x0F --0b1111


--holdingLeft = false;
--heldObjects = {};

function in_range(val, min, max)
	return val >= min and val <= max;
end

function num_range(val, min, max)
	return math.min(math.max(val, min), max);
end

function memory.readsignedbyte(memAddr)
	local x = memory.readbyte(memAddr)
	if x <= 0x80 then
		return x
	else
		return -(0x100 - x)
	end
end

function memory.readwordinv(memAddr)
	return (memory.readbyte(memAddr) * 0x100) + memory.readbyte(memAddr+1)
end

function get_actor_info(slotNum)
	if (slotNum >= 0x07) then
		return;
	end
	local baseAddr = ram['actors'] + (0x20 * slotNum);
	return {
		active = memory.readbyte(baseAddr),
		x = memory.readword(baseAddr + 0x01),
		y = memory.readword(baseAddr + 0x03),
		coliType = memory.readbyte(baseAddr + 0x05),
		coliBoxU = memory.readsignedbyte(baseAddr + 0x06),
		coliBoxD = memory.readsignedbyte(baseAddr + 0x07),
		coliBoxL = memory.readsignedbyte(baseAddr + 0x08),
		coliBoxR = memory.readsignedbyte(baseAddr + 0x09),
		relY = memory.readbyte(baseAddr + 0x0A),
		relX = memory.readbyte(baseAddr + 0x0B),
		objLstTablePtr = memory.readword(baseAddr + 0x0C), 
		dir =  memory.readbyte(baseAddr + 0x0E),
		objLstId = memory.readbyte(baseAddr + 0x0F),
		id = memory.readbyte(baseAddr + 0x10),
		rtnId = memory.readbyte(baseAddr + 0x11),
		codePtr = memory.readword(baseAddr + 0x12),
		timer1 = memory.readbyte(baseAddr + 0x14),
		timer2 = memory.readbyte(baseAddr + 0x15),
		timer3 = memory.readbyte(baseAddr + 0x16),
		timer4 = memory.readbyte(baseAddr + 0x17),
		timer5 = memory.readbyte(baseAddr + 0x18),
		timer6 = memory.readbyte(baseAddr + 0x19),
		timer7 = memory.readbyte(baseAddr + 0x1A),
		flags = memory.readbyte(baseAddr + 0x1B),
		levelLayoutPtr  = memory.readword(baseAddr + 0x1C),
		objLstSharedTablePtr  = memory.readword(baseAddr + 0x1E),
	}
end

function get_player_info(slotNum)
	return {
		active = 2,
		y = memory.readwordinv(ram['pl-y']),
		x = memory.readwordinv(ram['pl-x']),
		coliBoxU = memory.readsignedbyte(ram['pl-coli-u']),
		coliBoxD = memory.readsignedbyte(ram['pl-coli-d']),
		coliBoxL = memory.readsignedbyte(ram['pl-coli-l']),
		coliBoxR = memory.readsignedbyte(ram['pl-coli-r']),
		relY = memory.readbyte(ram['pl-y-rel']),
		relX = memory.readbyte(ram['pl-x-rel']),
	}
end

--function get_object_pos(baseAddr)
--	return {
--		x = memory.readword(baseAddr + 3),
--		y = memory.readword(baseAddr + 1),
--	}
--end
--function set_object_pos(baseAddr, x, y)
--	memory.writeword(baseAddr + 1, num_range(keys['ymouse'] + 0x08, 0, 0xFF)); --0x90));
--	memory.writeword(baseAddr + 3, num_range(keys['xmouse'], 0, 0xFF)); --0x9F));
--end
-- Absolute coordinates for the level
function get_level_pos()
	return {
		-- accounts for the LVLSCROLL_YOFFSET and LVLSCROLL_XOFFSET
		x = memory.readwordinv(ram['level-x']) - 0x50,
		y = memory.readwordinv(ram['level-y']) - 0x48,
	}
end
-- Absolute position for coord display
--function get_abs_object_pos(baseAddr)
--	local screenPos = get_level_pos();
--	local objectPos = get_object_pos(baseAddr);
--	return {
--		x = objectPos['x'] + screenPos['x'],
--		y = objectPos['y'] + screenPos['y'],
--	}
--end
--
--function object_mouse_range(baseAddr, mouse_x, mouse_y)
--	return false
--	--local pos = get_object_pos(baseAddr); -- get the object position relative to the screen
--	---- Unlike Sonic 1 where the hitbox size is sometimes specified in the object's SST
--	---- everything is hardcoded here, which means a 16x16 box is what everything will be getting (even though it's offsetted really weird)
--	--return (in_range(mouse_x, pos['x'] - 0x08, pos['x'] + 0x08) and in_range(mouse_y, pos['y'] - 0x10, pos['y']));
--end

function object_render_hitbox(act, i, isPlayer)
	local screenPos = get_level_pos();
	
	-- magic constants to force the origin to the correct location.
	local yOrigin = act['relY'] - 0x10;
	local xOrigin = act['relX'] - 0x08;
	
	local xReal = act['x'] - screenPos['x'];
	local yReal = act['y'] - screenPos['y'];
	
	
	local l = xOrigin + act['coliBoxL'];
	local r = xOrigin + act['coliBoxR'];
	local u = yOrigin + act['coliBoxU'];
	local d = yOrigin + act['coliBoxD'];
	
	gui.text(0, (18 * i), string.format("%04X %04X", act['x'], act['y']));
	--gui.text(0, (16 * i)+8, string.format("%04X %04X", act['coliBoxU'], act['coliBoxD']));
	
	-- and the actual collision box in white
	gui.box(l, u, r, d, "#00000000", 'green');
	
	-- draw main origin
	gui.pixel(xOrigin, yOrigin, 'red');
	
	-- draw actual position
	gui.pixel(xReal, yReal, 'yellow');
	
	-- and the rest of the possible offsets for collision checks (well, almost all of them)
	if isPlayer == false then
		gui.pixel(xReal - 8, yReal - 8, 'magenta'); -- lowl
		gui.pixel(xReal + 8, yReal - 8, 'magenta'); -- lowr
		gui.pixel(xReal + 8, yReal + 8, 'magenta'); -- bottomr
		gui.pixel(xReal - 8, yReal + 8, 'magenta'); -- bottoml
		gui.pixel(xReal, yReal + 1, 'magenta'); -- ground2
		gui.pixel(xReal, yReal - 0x14, 'magenta'); -- top
	end
	
	---- extra
	--if (config['show-object-coords']) then
	--	local posAbs = get_abs_object_pos(baseAddr);
	--	gui.text(pos['x'] - 0x08, pos['y'] - 0x10, string.format("%04X", posAbs['x']));
	--	gui.text(pos['x'] - 0x08, pos['y'] - 0x08, string.format("%04X", posAbs['y']));
	--end
end

print ("Hello");

while (true) do
	keys = input.get()

	-- memory.writebyte(ram['lives'], 0x99) -- Unlimited lives
	-- jet hat best hat (don't care about hat switch)
	-- if memory.readbyte(ram['powerup']) ~= 0x03 then
	-- 	memory.writebyte(ram['powerup'], 0x03);
	-- end
	memory.writebyte(ram['debug'], 0x01);
	memory.writeword(ram['time'], 0x0004);
	
	
	-- Unlock all boundaries
	if keys[unlockScrollKey] then
		gui.text(1,0, "Scroll boundaries unlocked.")
		for mem = ram['scroll'], ram['scroll-end'] do
			memory.writebyte(mem, scroll['all']);
		end
	end

	-- For all 7 slots, display their borders and origin
	for i = 0, 6 do
		local act = get_actor_info(i);
		
		if act['active'] ~= 0 then
			object_render_hitbox(act, i, false)
		end
	end
	
	-- hack
	object_render_hitbox(get_player_info(), 7, true)
	
	emu.frameadvance()
end