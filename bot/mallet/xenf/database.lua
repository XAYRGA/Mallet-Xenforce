
local host = "oh my"
local db = "oh murr. "
local user = "pls murr"
local password = "yes pls murr"


local succ = sql.connect(host,db,user,password)
if not succ then 
	print("XENFORCE ERROR DURING DATABASE CONNECTION.")
	print(sql.lastError())
	return
end 


function MySQLEscape(Value)
   return Value:gsub('["\'\\%z]', {
         ['"']  = '\\"', ['\0'] = '\\0',
         ["'"]  = "\\'", ['\\'] = '\\\\',
      })
end

print("OK -- Database connected successfully. ")

