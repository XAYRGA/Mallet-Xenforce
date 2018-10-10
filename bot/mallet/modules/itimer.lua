itimer = {}

local TIMERS = {}
local SIMPLE_TIMERS = {}


local function expect(var,typ,arg,funcnam)
    assert(type(var)==typ, "argument #" .. arg .. " to '" .. funcnam .. "', " .. typ .. " expected, got " .. type(var))
end

function itimer:GetTable()
    return ITIMERS
end


function itimer.Create(id,del,reps,func)
    local FUNCN = "Create"
    expect(id,"string",1,FUNCN)
    expect(del,"number",2,FUNCN)
    expect(reps,"number",3,FUNCN)
    expect(func,"function",4,FUNCN)

    TIMERS[id] = {
        reps = reps,
        delay = del,
        funct = func,
        paused = false,
        infinite = reps==0,
        start = SysTime()
    }
    
end


function itimer.Simple(del,func)
    SIMPLE_TIMERS[#SIMPLE_TIMERS + 1] = {
        delay = del,
        funct = func,
        start = SysTime()
   } 
    
end




local function timertick()
    for k,tim in pairs(TIMERS) do
        local elapsed = SysTime() - tim.start
         if not tim.paused then 
            if elapsed >= tim.delay then
               local r,e = pcall(tim.funct)
                if not tim.infinite then 
                
                    tim.reps = tim.reps - 1                
                        if not r then 
                            print(e)
                        end
                        if tim.reps == 0 then 
                            TIMERS[k] = nil
                        end                   
                end           
                tim.start = SysTime() 
            end   
        end
    end
    
    for k,stim in pairs(SIMPLE_TIMERS) do 
           local elapsed = SysTime() - stim.start
                if elapsed > stim.delay then 
                    stim["funct"]()
                    SIMPLE_TIMERS[k] =  nil
                end    
    end
    
end


ModHook.Add("Tick","ITimerDoTimer",timertick)


