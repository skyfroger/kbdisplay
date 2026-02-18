local function writeEnvironments()
    if quarto.doc.is_format("html:js") then
		quarto.doc.add_html_dependency({
            name = "kbd-script",
            version = "1.0",
            scripts = {
                { path = "kbd-code.js", afterBody = "true" },
            },
        })
        quarto.doc.add_html_dependency({
            name = "kbd-styles",
            version = "1",
            stylesheets = { "kbd-styles.css" }
        })
    end
end

-- символы рядом с названиями клавиш
local keys_map = {
	shift = "⇧",
	ctrl = "⌃",
	alt = "⌥",
	up = "↑",
	left = "←",
	down = "↓",
	right = "→",
	tab = "↹",
	backspace = "⌫",
	back = "⌫",
	enter = "↵",
	win = "⊞"
}

-- получаем массив клавиш, разделённых символом +
local function split_keys(inputstr)
	local t = {}
	for str in string.gmatch(inputstr, "[%w]+") do
		table.insert(t, str)
	end
	return t
end

-- преобразуем первую букву в заглавную
local function capitilize(input)
	input = pandoc.text.lower(input)
	return pandoc.text.upper(pandoc.text.sub(input, 1, 1)) .. pandoc.text.sub(input, 2)
end

return {
	{
		Str = function(elem)
			-- строка подходит под шаблон ++клавиша++
			
			if elem.text:match("%+%+%S+%+%+") then
				
				writeEnvironments()

				-- start_idx - индекс с которого начинается комбинация
				-- hotkey_text - текст с разметкой клавиши
				-- end_idx - индекс которым заканчивается комбинация
				local start_idx, hotkey_text, end_idx = elem.text:match("()%+%+(.-)%+%+()")

				local keys = split_keys(hotkey_text) -- получаем список клавиш в комбинации

				output = {}

				-- добавляем символы идущие до комбинации
				if start_idx > 1 then
					table.insert(output, pandoc.Str(elem.text:sub(1, start_idx - 1)))
				end
				-- перебираем все клавиши
				for index, key in ipairs(keys) do
					local key_text = key
					-- если клавиша - специальная ...
					if keys_map[pandoc.text.lower(key)] ~= nil then
						-- ... добавляем её символ
						key_text = keys_map[pandoc.text.lower(key)] .. capitilize(key)
					else
						key_text = capitilize(key)
					end

					table.insert(output, pandoc.Span(key_text, { class = 'kbd dsp' }))

					-- если клавиша не последняя...
					if index ~= #keys then
						-- ... вставляем между клавишами +
						table.insert(output, pandoc.Span(pandoc.Str " + "))
					end
				end

				-- добавляем индексы идущие после комбинации
				if end_idx <= #elem.text then
					table.insert(output, pandoc.Str(elem.text:sub(end_idx, #elem.text)))
				end
				return output
			else
				return elem
			end
		end,

		CodeBlock = function(elem)
			if elem.text:match("%+%+%S+%+%+") then
				writeEnvironments()
			end
		end
	}
}
