print("XEnforce is starting.")
dofile("./mallet/xenf/database.lua")

print("==========================")
print("==========================")
print("==========================")
print("=====XENFORCE STARTED=====")
print("==========================")
print("==========================")
print("==========================")


local function MySQLEscape(Value)
	if Value==nil then 
		return ""
	end 
   return string.gsub(Value,'["\'\\%z]', {
         ['"']  = '\\"', ['\0'] = '\\0',
         ["'"]  = "\\'", ['\\'] = '\\\\',
      })
end


function XENF.Log(strmsg, itype, subsys )
	if not subsys then subsys = "GENERAL" end 
	
	local statement = "INSERT INTO xen_log(`type`,`time`,`affected`,`desc` ) VALUES ( %s , %s , '%s' , '%s' ) "

	local real_statement = string.format(statement, itype or 0,os.time(),MySQLEscape(subsys) or "GENERAL", MySQLEscape(strmsg) or "NONE" )
		
	local success = sql.nonquery(real_statement)
	if not success then 
		print("LOG ERROR: ", sql.lastError()) 
	end 

end 

function XENF.LogDrop(strmsg, username, itype )
	if not subsys then subsys = "GENERAL" end 
	
	local statement = "INSERT INTO xen_drops(`type`,`time`,`affected`,`desc` ) VALUES ( '%s' , %s , '%s' , '%s' )"
	

	local real_statement = string.format(statement, itype or "UTIMEOUT" ,os.time(),MySQLEscape(username) or "ERRORNAME", MySQLEscape(strmsg) or "NONE" )
		
	local success = sql.nonquery(real_statement)
	if not success then 
		print("LOG DROP ERROR: ", sql.lastError()) 
	end 

end 


XENF.Log("XEN Service started.")

ModHook.Add("Telegram_NewChatMembers","CheckJoinGenerateNewID",function(chat,pardata)
		PrintTable(pardata)
		
		
	for i,member in pairs(pardata) do 
		if not member.is_bot then 
			local uqid = to_base64(tostring(math.abs(chat.id)) .. tostring( math.abs( member.id ) ) )
			local succ = sql.query("SELECT * FROM xen_activations WHERE activation_id='" .. uqid .. "'")
			if not succ then 
				XENF.Log( sql.lastError() ,5,"ACTIVATION")
				return 
			end 
			
			local res = sql.getResults()
			local continue = true
			local actr_current = res[1]
			if actr_current then 
				if (actr_current['activated'] > 0) then 
					XENF.Log("ActivationIndex " .. actr_current.index .. " is already verified for this group, activation will not be requested.",1,"ACTIVATION")
					continue = false 
					
				else 
			
						local statement = "UPDATE xen_activations SET whencreated=%s WHERE `index`=%s"
						local real_statement = string.format(statement,os.time(),actr_current.index)
						local resu = sql.nonquery(real_statement)
						XENF.Log("ActivationIndex " .. actr_current.index .. " exists, but the time expired. Refreshing. ",1,"ACTIVATION")
						
						if (resu==false) then 
							print(sql.lastError())
						end 
				continue = false 
				end 	
			end 
				
			if (continue) then 
				local when = tostring(os.time())
				local uname = member.username 
				
				if uname==nil then 
					uname = MySQLEscape(member.first_name .. " " .. ( member.last_name or ""))
				else 
					uname = MySQLEscape("@" .. uname)			
				end 
				
				local statement = "INSERT INTO xen_activations (activation_id,activated,forwho,`group`,whencreated, username ) VALUES ( '%s', 0, %s , %s , %s, '%s') "
				local real_statement = string.format(statement,uqid,member.id,chat.id,when,MySQLEscape(uname))
				local success = sql.nonquery(real_statement)
				if success==false then 
					print(sql.lastError())
				end 
				XENF.Log("Created new activationindex for user " .. uname,1,"ACTIVATION")
			
				telegram.sendMessage(chat.id,
				"Welcome " .. uname.. " to the chat! To keep bots out , you must verify that you're human!\n\nPlease use the following URL and complete the CAPTCHA. **You have 30 minutes to complete the captcha, or you'll automatically be removed from the group!**\n\nhttp://www.xayr.ga/xenf/?actid=" .. uqid,
				"Markdown")
			
			end 
		end
	end 
end)


-- XAYR.GA/MAL/XENF/INIT.LUA
itimer.Create("CheckActivations",1,0,function()
	local succ = sql.query("SELECT * FROM xen_activations WHERE activated=1 AND activation_checked=0")
	local res = sql.getResults()
	for k,acti in pairs(res) do
	
		local person = acti.forwho 
		local psx = acti.group 
		local un = acti.username
			telegram.sendMessage(psx,
			tostring(un) .. ", thanks for verifying you're human. Enjoy the chat.  ",  
			"Markdown")
			
			local statement = "UPDATE xen_activations SET activation_checked=1 WHERE `index`=%s"
			local real_statement = string.format(statement,acti.index)
			local resu = sql.nonquery(real_statement)
			print(resu)
			
			if (resu==false) then 
				print(sql.lastError())
			end 
		
		
	end 
end)



itimer.Create("CheckActivations_Timeout",1,0,function()
	local succ = sql.query("SELECT * FROM xen_activations WHERE activated=0 AND whencreated < " .. (os.time() - 1800) ) -- 30 minutes 
	
	local res = sql.getResults()
	for k,acti in pairs(res) do
		print("Banning user ")
		local person = acti.forwho 
		local psx = acti.group 
		local un = acti.username
		
		XENF.LogDrop("User activation time exceeded.", un, "UTIMEOUT" )
		telegram.sendMessage(psx,
		tostring(un) .. " Was removed from the chat for failing to complete the CAPTCHA.",  
		"Markdown")
		
		itimer.Simple(1,function() 
			telegram.kickChatMember(psx,person)		
		end)
			local statement = "DELETE FROM xen_activations WHERE `index`=%s"
			local real_statement = string.format(statement,acti.index)
			local success = sql.nonquery(real_statement)
		
		
		
	end 
end)


