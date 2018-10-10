print("Mallet state initializer script.")

--print(_G)
local a = file.Find("./mallet/modules/","*.lua")
for k,v in pairs(a) do
	print("Loaded module " .. v)
	dofile(v)
end 

local a = file.Find("./mallet/autorun/","*.lua")
for k,v in pairs(a) do
	print("Loaded autorun" .. v)
	dofile(v)
end 


