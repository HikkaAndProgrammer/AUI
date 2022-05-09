local MAS = {}

function MAS.error_handling(message, traceback)
	local traceindex = 1
	while traceindex < #traceback do
		if traceback[traceindex]:find"in [^ ]+ 'protected'" then break end
		traceindex = traceindex + 1
	end
	traceindex = traceindex + 1
	if message:find"attempt to" then
		if message:find"perform arithmetic on a nil value" then
			love.AUI.logger:log("error", "Была произведена попытка арифметической операции с типом nil")
		elseif message:find"to add a" then
			local t1, t2 = table.unpack(message:gsub(
				"attempt to add a '([^']+)' with a '([^']+)'", "%1 %2"):split" ")
			love.AUI.logger:log("error", ("Нельзя сложить следующие 2 типа: %s и %s"):format(t1, t2))
		elseif message:find"index a" then
			love.AUI.logger:log("error", (raw(message:gsub(
				".+index a ([^ ]+) value %(([%w]+) '([%w]+)'%)",
				"Ошибка индексации, нельзя индексировать поля у типа %1, %2 переменной <%3>"
				):gsub("local", "локальной"):gsub("global", "глобальной")
				:gsub("field", "являющегося полем таблицы,")
			)))
			if message:endswith("(a nil value)") then
				print"Возможно вы пытаетесь использовать несуществующую таблицу, она может быть ещё не создана, или же причиной ошибки могла стать опечатка в коде"
			end
		elseif message:find"index" then
			love.AUI.logger:log("error", (raw(message:gsub(
				".+index field '([%w]+)' %(a ([%w]+) value%)",
				"Ошибка индексации, нельзя индексировать поля у поля %1, типа %2"
				):gsub("local", "локальной"):gsub("global", "глобальной")
				:gsub("field", "являющегося полем таблицы,")
			)))
			if message:endswith("(a nil value)") then
				print"Возможно вы пытаетесь использовать несуществующую таблицу, она может быть ещё не создана, или же причиной ошибки могла стать опечатка в коде"
			end
		elseif message:find"call" then
			love.AUI.logger:log("error", (raw(message:gsub(
				"attempt to call (%S+) '([^']+)' %(a (%S+) value%)",
				"Ошибка вызова, нельзя вызывать %1 переменную %2 типа %3")
			:gsub("local", "локальную"):gsub("global", "глобальную")
				:gsub("field", ", являющуюся полем таблицы,")
			)))
			if message:endswith("(a nil value)") then
				print"Возможно вы забыли создать функцию или опечатались в названии вызываемой функции"
			end
		else love.AUI.logger:log("critical", "Неизвестная ошибка: "..message)
		end
	elseif message == "assertion failed!" then
		love.AUI.logger:log("error", "Сработала функция assert")
	else
		love.AUI.logger:log("error", "Неизвестная ошибка: "..message)
	end
	love.AUI.logger:log("warn", raw(traceback[traceindex]:gsub("[^%.]+%.lua:(%d+): in (.+)",
		"Ошибка произошла на строке %1 в <%2>")))
	io.write"Перейти в режим отладки? [Y/n] "
	local x = io.read():lower()
	if x ~= "n" and x ~= "н" then
		debug.debug()
	end
end

function MAS.protected(f, ...)
	local error, msg = pcall(f, ...)
	if not error then
		MAS.error_handling(
			msg:gsub("[^%.]+%.lua:%d+: (.+)", "%1"),
			debug.traceback():split"\n"
		)
	end
end

return MAS