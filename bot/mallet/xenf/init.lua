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

function XENF.LogDrop(strmsg, username, itype, id  )
	if not subsys then subsys = "GENERAL" end 
	
	local statement = "INSERT INTO xen_drops(`type`,`time`,`affected`,`desc`,`idr` ) VALUES ( '%s' , %s , '%s' , '%s', %s )"
	

	local real_statement = string.format(statement, itype or "UTIMEOUT" ,os.time(),MySQLEscape(username) or "ERRORNAME", MySQLEscape(strmsg) or "NONE", id or 0 )
		
	local success = sql.nonquery(real_statement)
	if not success then 
		print("LOG DROP ERROR: ", sql.lastError()) 
	end 

end 


XENF.Log("XEN Service started.")




local function timedCleanup(info)
	itimer.Simple(1800,function()
		local cd = json:decode(info)
		if cd["ok"]==true then 
			local resu = cd["result"]
				local id = resu["message_id"]
				local cid = resu["chat"]["id"]
				telegram.deleteMessage(cid,id)
		end 
	end) 
end 




ModHook.Add("Telegram_NewChatMembers","CheckJoinGenerateNewID",function(chat,pardata)
		PrintTable(pardata)
		
	local wascaught = false 
	
	for i,member in pairs(pardata) do 
		if not member.is_bot then 
			local uqid = to_base64(tostring(math.abs(chat.id)) .. tostring( math.abs( member.id ) ) )
			local succ = sql.query("SELECT * FROM xen_activations WHERE activation_id='" .. uqid .. "'")
			if not succ then 
				XENF.Log( sql.lastError() ,5,"ACTIVATION")
				return 
			end 
			print("1")
			
			local res = sql.getResults()
			local continue = true
			local actr_current = res[1]
			
			if actr_current then 
				print("1.1")
				if (actr_current['activated'] > 0) then 
					XENF.Log("ActivationIndex " .. actr_current.index .. " is already verified for this group, activation will not be requested.",1,"ACTIVATION")
					continue = false 
					
				else 
				print("1.5")
						local statement = "UPDATE xen_activations SET whencreated=%s WHERE `index`=%s"
						local real_statement = string.format(statement,os.time(),actr_current.index)
						local resu = sql.nonquery(real_statement)
						XENF.Log("ActivationIndex " .. actr_current.index .. " exists, but the time expired. Refreshing. ",1,"ACTIVATION")
						
						if (resu==false) then 
							print(sql.lastError())
						end 
				continue = false 
				end 	
				
			
				
				
				
				if (actr_current.autorem_caught or 0) > 0 then 
					wascaught = true 
					
							local resx = telegram.sendMessage(chat.id,
							"Welcome back, " .. actr_current.username .. " You were removed previously because you failed to pass screening as a bot. Please complete the captcha. \n\nhttp://www.xayr.ga/xenf/?actid=" .. actr_current.activation_id,
							nil,nil,nil,nil,
							timedCleanup
							
							)
							
							
								local statement = "UPDATE xen_activations SET autorem_caught=0 WHERE `activation_id`='%s'"
								local real_statement = string.format(statement,actr_current.activation_id)
								local resu = sql.nonquery(real_statement)
					
					
				end 
			end 
					print("2")
				
			if (continue) then 
				local when = tostring(os.time())
				local uname = member.username 
				
				local full_name = (member.first_name or "") .. (member.last_name or "")
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
					print("3")
				XENF.Log("Created new activationindex for user " .. uname,1,"ACTIVATION")
			
				local resx = telegram.sendMessage(chat.id,
                -- Telegram usernames are a-z, 0-9, and underscores, which are
                -- all characters which need no escaping in HTML. Base64 uses
                -- + and /, which are also fine in HTML.
				"Welcome " .. uname.. " to the chat! To keep bots out, you must complete a CAPTCHA to be verified.\n\nPlease use the following URL and complete the CAPTCHA. You have <b>30 minutes</b> to complete the captcha, or you’ll automatically be <b>removed from the group!</b>\n\nhttp://www.xayr.ga/xenf/?actid=" .. uqid,
				"HTML",nil,nil,nil,
				timedCleanup
				
				)
				
				if not wascaught then 
					itimer.Simple(1,function()
					
							local botscore = 500; 
							telegram.getUserProfilePictures(member.id,function(data) 
								
								pcall(function() 
									local result = json:decode(data)
									local resreal = result["result"]
									local icons = resreal["total_count"] or 0 
									botscore = botscore - (icons) * 45 
									
									if icons==0 then 
										botscore = botscore - 30
									end 
									print("User has " .. icons .. " profile entries. Bot Score reduced to " .. botscore)
										itimer.Simple(1,function() 
									
											local obs = botscore
											
											for I=1,#full_name do 
												
													if string.byte(string.sub(full_name,I) or "A")  > 0xAF then 
														-- print(string.byte(string.sub(full_name,I) or A ))
														botscore = botscore + 5 						
														
													elseif string.byte(string.sub(full_name,I) or "A")  < 0x80	then					
														botscore = botscore - 3 													
													end 																			
											end 
											print("Final score ",botscore)
											
											if botscore > 475 then 
												local statement = "UPDATE xen_activations SET autorem_caught=1 WHERE `activation_id`='%s'"
												local real_statement = string.format(statement,uqid)
												local resu = sql.nonquery(real_statement)
												
													print("Bot Score Exceeded")
													local res = telegram.sendMessage(chat.id,
													"User was automatically removed from the chat.\n\n Failed preliminary bot-screening check. \n\n Must be re-added by an administrator to join the chat.",
													nil,nil,nil,nil,
													timedCleanup
													
													)
												
												
													pcall(telegram.kickChatMember,chat.id,member.id) 
													
												
											end 
											
										end) 
												
								end)
								
							end) 
					
					
					end)
				end 
			
				
				-- to,text,mode,disable_preview,silent,replyto,callback
					print("4")
				if res then 
					print(res)
					PrintTable(res)
				
				end 
			
			end 
		end
	end 
end)


local random = {
	"Hey %s, thanks for verifying that you’re not a robot. Have fun!",
	"%s has verified that they’re not a computer. Enjoy the chat!", 
	"%s, beep boo--- Err. I mean. You’re not a bot!  Thanks for verifying." ,
	"%s is verified! Hooray! Welcome!",
	"%s has proved they aren’t a spambot. Yay! ",
	"%s is sentient, tell the world!"

}

-- XAYR.GA/MAL/XENF/INIT.LUA
itimer.Create("CheckActivations",1,0,function()
	local succ = sql.query("SELECT * FROM xen_activations WHERE activated=1 AND activation_checked=0")
	local res = sql.getResults()
	for k,acti in pairs(res) do
	
		local person = acti.forwho 
		local psx = acti.group 
		local un = acti.username
			telegram.sendMessage(psx,
			tostring(un) .. ", thanks for verifying you’re sentient. Enjoy the chat.  ",  
			nil,nil,nil,nil,
			timedCleanup)
			
			local statement = "UPDATE xen_activations SET activation_checked=1 WHERE `index`=%s"
			local real_statement = string.format(statement,acti.index)
			local resu = sql.nonquery(real_statement)
			print(resu)
			
			if (resu==false) then 
				print(sql.lastError())
			end 
		
		
	end 
end)


local WARNED = {}







itimer.Create("CheckActivations_TimeoutWarn",5,0,function()
	local resl_suc = sql.query("SELECT * FROM xen_activations WHERE activated=0 AND autorem_caught=0 AND whencreated < " .. (os.time() - 1320) ) -- 22 minutes.
	
	local res = sql.getResults()
	for k,acti in pairs(res) do
	
		
		local person = acti.forwho 
		local psx = acti.group 
		local un = acti.username
		local aid = acti.activation_id

		if not WARNED[aid] then 		
			telegram.sendMessage(psx,"Hey " .. 
			tostring(un) .. ", you still need to verify that you’re not a robot! You’ll be removed from the chat in <b>8 minutes</b> if you don’t complete the CAPTCHA! \n\nPlease use the link below to verify!\n\n http://www.xayr.ga/xenf/?actid=" .. aid,  
			"HTML",
			nil,
			nil,
			nil,
			timedCleanup		
			)
			WARNED[aid] = true
			print("DoWarn")
		end 
		

		
	end 
end)


itimer.Create("CheckActivations_Timeout",1,0,function()
	local succ = sql.query("SELECT * FROM xen_activations WHERE activated=0 AND autorem_caught=0 AND whencreated < " .. (os.time() - 1800) ) -- 30 minutes 
	
	local res = sql.getResults()
	for k,acti in pairs(res) do
		print("Banning user ")
		local person = acti.forwho 
		local psx = acti.group 
		local un = acti.username
		
		XENF.LogDrop("User activation time exceeded.", un, "UTIMEOUT" , person )
		telegram.sendMessage(psx,
		tostring(un) .. " Was removed from the chat for failing to complete the CAPTCHA.",  
			nil,
			nil,
			nil,
			nil,
			function(info) 
				pcall(function()
					print(info)
					PrintTable(info)				
				end)	
			end )
		
		itimer.Simple(1,function() 
			local s,e = pcall(telegram.kickChatMember,psx,person) 
			if s==false then 
				telegram.sendMessage(psx,"OOF! Looks like I failed to kick that one :(. Do I have permission to remove users from the chat? (I need kick permissions to function!) ")
			end 
		end)
			local statement = "DELETE FROM xen_activations WHERE `index`=%s"
			local real_statement = string.format(statement,acti.index)
			local success = sql.nonquery(real_statement)
		
		
		
	end 
end)


