local M = {}

local token_file = vim.fn.stdpath("data") .. "/tweet.nvim/tokens.json"

function M.delete_tokens()
	vim.fn.delete(token_file)
end

function M.token_path()
	print(token_file)
end

function M.save_tokens(tokens)
	if tokens then
		local dir = vim.fn.fnamemodify(token_file, ":h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
		vim.fn.writefile({ vim.fn.json_encode(tokens) }, token_file)
	end
end

function M.load_tokens()
	if vim.fn.filereadable(token_file) == 1 then
		local content = vim.fn.readfile(token_file)
		if #content > 0 then
			local ok, decoded_tokens = pcall(vim.fn.json_decode, table.concat(content, "\n"))
			if ok and type(decoded_tokens) == "table" then
				print("Tweet: Loaded tokens from " .. token_file)
				return decoded_tokens
			else
				print("Tweet: Failed to decode tokens from " .. token_file)
			end
		end
	end
end

return M;
