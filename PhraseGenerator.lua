local function PhraseGenerator(t)
	return function()
		local loading_phrase = t[1][math.random(1, #t[1])]
		for i = 2, #t do
			local x = t[i]
			local s = x[math.random(1, #x)]
			if #s > 0 then
				loading_phrase = loading_phrase .. " " .. s
			end
		end
		return loading_phrase
	end
end

return PhraseGenerator