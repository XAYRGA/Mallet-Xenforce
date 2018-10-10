local UPDATE_FREQUENCY = 0.7 -- how many second per update

function NONE() end 


local last_update_check =  0
local highest_update_id = 0 

local function updateCheck()
	if ( SysTime() - last_update_check) > UPDATE_FREQUENCY then 
		local b = telegram.getUpdates(function(result)
		
				if result then 		
					local b = json:decode(result['data'])
					if b['result'] then 
					
						b = b['result']
						if b then 
							for k,v in pairs(b) do 
								local id = v["update_id"]
								
								if id~=highest_update_id then 
									
									 ModHook.Call("TelegramUpdate_RAW",v)
								end 
								
								
								if (id) then 
									if id > highest_update_id then 
										highest_update_id = id
										--print("Iter " .. id)
									end 
								end 
							
							end 					
						end 
					end
				end 
				last_update_check = SysTime()
				
				telegram.confirmUpdate(highest_update_id )
				--print("New high " , highest_update_id)
		end)	
	end 
end 
ModHook.Add("Tick","TGAPI_DO_UPDATES",updateCheck)




ModHook.Add("TelegramUpdate_RAW","TGAPI_HOOK_CONTROLLER",function(data)
		local message = data['message']
		
		CHAT = nil 
		MSG_ID = nil 
		RAW = data 
		if message then 
			CHAT = message['chat']
			MSG_ID = message['message_id']
			if message["new_chat_participant"] then 
				local pardata = message["new_chat_participant"]  
				ModHook.Call("Telegram_NewChatParticipant",CHAT,pardata)
			end 
			if message["new_chat_members"] then 			
				local pardata = message["new_chat_members"]  
				ModHook.Call("Telegram_NewChatMembers",CHAT,pardata)
			end 
			if message["text"] then 			
				local pardata = message["text"]  
				local from = message["from"]
				ModHook.Call("Telegram_ChatText",CHAT,from,pardata)
			end 			
		end 
end)
--[[
ModHook.Add("Telegram_ChatText","test",function(chat,from,text)
	if (text=="/wtf") then 
		telegram.sendMessage(chat.id,"Hello")
		print(from.first_name .. " EXEC COMMAND 'wtf' ")
	end 
end )
--]]

function telegram.sendMessage(to,text,mode,disable_preview,silent,replyto)
	return telegram.apiPostRaw("sendMessage", {
		chat_id = to, 
		text = text,
		parse_mode = mode, 
		disable_web_page_preview = disable_preview,
		disable_notification = silent, 
		reply_to_message_id = replyto	
	
	},NONE)
end 


function telegram.kickChatMember(chat,user,untild)
	if not until_d then until_d = os.time() + 45 end 
	
	telegram.apiPostRaw("kickChatMember", {
		chat_id = chat, 
		user_id = user,
		until_date = until_d
	
	},NONE)
	
end 

--
