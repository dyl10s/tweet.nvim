local http = require("tweet.http")
local twitter = require("tweet.twitter")
local async = require("plenary.async")

local M = {}

M.client_id = nil
M.port = 51899
M.auto_auth = true

function M.authenticate(useBrowser)
	useBrowser = (useBrowser == nil) or useBrowser

	assert(M.client_id, "You must provide a client_id, in setup or with TWITTER_CLIENT_ID.")
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
			print("Authentication complete! You can now use :Tweet to post a Tweet.")
		end)
	end, function()
	end)
end

function M.setup(config)
	if type(config) == 'table' then
		if config.port then
			M.port = config.port
		end

		if config.client_id then
			M.client_id = config.client_id
		end

		if config.auto_auth ~= nil then
			M.auto_auth = config.auto_auth
		end
	end

	if M.client_id == nil then
		M.client_id = os.getenv("TWITTER_CLIENT_ID")
	end

	twitter.setup(M.port, M.client_id)

	if M.auto_auth and not twitter.has_tokens() then
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
