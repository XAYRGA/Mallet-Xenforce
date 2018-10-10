

ModHook = {}
local hooktab = {}
ModHook.Tb = hooktab

function ModHook.Add(hk,uname,func)
	if not hk then return false,"NO EVENT NAME" end
	if not uname then return false,"NO UNIQUE NAME" end
	if not func then return false, "NO CALLBACK FUNC!" end
	if not hooktab[hk] then hooktab[hk] = {} end
	hooktab[hk][uname] = func
end

function ModHook.Call(hk,...)
	if not hk then return false,"NO EVENT NAME" end
	local mk = hooktab[hk]
	if mk then 
		for k,v in pairs(mk) do 
			local s,e = pcall(v,...) -- do the call
			if not s then 
				writeError(e or "")
			end 
		end
	end
end

function ModHook.Remove(hk,uname)
	if not hk then return false,"NO EVENT NAME" end
	if not uname then return false,"NO UNIQUE NAME" end
	
	if not hooktab[hk] then hooktab[hk] = {} end
	hooktab[hk][uname] = nil -- Bad practice to rely on GC, but oh well.
end