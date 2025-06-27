local http = require("tweet.http")
local twitter = require("tweet.twitter")
local async = require("plenary.async")

local M = {}

function M.authenticate(useBrowser)
	useBrowser = (useBrowser == nil) or useBrowser

	local url = twitter.get_authorization_url()

	if (useBrowser) then
		vim.ui.open(url)
	else
		print("Please authenticate at the following url: " .. url)
	end

	async.run(function()
		local code = http.start_callback_server(51899)

		vim.schedule(function()
			local token_resp = twitter.exchange_code_for_token(code)

			if token_resp.status ~= 200 then
				error("Failed to get access token")
			end

			local tokens = vim.fn.json_decode(token_resp.body)
			twitter.set_oauth_tokens(tokens)
		end)
	end, function()
	end)
end

function M.setup(config)
	local port = 51899
	local client_id = nil

	if type(config) == 'table' then
		if config.port then
			port = config.port
		end

		if config.client_id then
			client_id = config.client_id
		end
	end

	if client_id == nil then
		client_id = os.getenv("TWITTER_CLIENT_ID")
	end

	assert(client_id, "You must provide a client_id, in setup or with TWITTER_CLIENT_ID.")

	twitter.setup(port, client_id)

	if not twitter.has_tokens() then
		M.authenticate()
	end
end

vim.api.nvim_create_user_command("TweetLogin", function()
	M.authenticate()
end, {})

vim.api.nvim_create_user_command("TweetLoginNoBrowser", function()
	M.authenticate(false)
end, {})

vim.api.nvim_create_user_command("Tweet", function()
	twitter.tweet_command()
end, {})

vim.api.nvim_create_user_command("TweetLogout", function()
	twitter.logout()
end, {})

vim.api.nvim_create_user_command("TweetPrintTokenPath", function()
	twitter.print_token_path()
end, {})

return M
