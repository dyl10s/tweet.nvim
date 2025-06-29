local encoding = require("tweet.encoding")
local curl = require("plenary.curl")
local token_store = require("tweet.token_store")

local M = {}

local tokens = nil

local CLIENT_ID = nil
local REDIRECT_URI = nil

local SCOPES = "tweet.write offline.access"
local STATE = "nvim is awesome"

M.print_token_path = function()
	token_store.token_path()
end

M.logout = function()
	token_store.delete_tokens()
	print("Logout complete!")
end

M.has_tokens = function()
	if (tokens == nil) then
		return false
	end

	return true
end

M.setup = function(port, client_id)
	CLIENT_ID = client_id
	REDIRECT_URI = "http://localhost:" .. port .. "/callback"
	tokens = token_store.load_tokens()
end

M.set_oauth_tokens = function(newTokens)
	tokens = newTokens
	token_store.save_tokens(newTokens)
end

M.get_authorization_url = function()
	assert(REDIRECT_URI, "Missing redirect_uri. Did you forget to call setup?");

	local url = "https://twitter.com/i/oauth2/authorize" ..
		"?response_type=code" ..
		"&client_id=" .. encoding.url_encode(CLIENT_ID) ..
		"&redirect_uri=" .. encoding.url_encode(REDIRECT_URI) ..
		"&scope=" .. encoding.url_encode(SCOPES) ..
		"&state=" .. encoding.url_encode(STATE) ..
		"&code_challenge=challenge" ..
		"&code_challenge_method=plain"
	return url
end

M.exchange_code_for_token = function(code)
	local body = {
		grant_type = "authorization_code",
		client_id = CLIENT_ID,
		redirect_uri = REDIRECT_URI,
		code = code,
		code_verifier = "challenge",
	}
	local body_encoded = {}
	for k, v in pairs(body) do
		table.insert(body_encoded, encoding.url_encode(k) .. "=" .. encoding.url_encode(v))
	end

	local resp = curl.post("https://api.twitter.com/2/oauth2/token", {
		body = table.concat(body_encoded, "&"),
		headers = {
			["Content-Type"] = "application/x-www-form-urlencoded",
		}
	})

	return resp
end

local function post_tweet(access_token, text)
	local url = "https://api.twitter.com/2/tweets"
	local body = { text = text }
	local resp = curl.post(url, {
		body = vim.fn.json_encode(body),
		headers = {
			["Authorization"] = "Bearer " .. access_token,
			["Content-Type"] = "application/json",
		}
	})
	return resp
end

-- Command to prompt input and post a tweet
M.tweet_command = function()
	if not tokens or not tokens.access_token then
		print("No access token found. Please run :TweetLogin or :TweetLoginNoBrowser first.")
		return
	end

	vim.ui.input({ prompt = "Tweet: " }, function(input)
		if input == nil or input == "" then
			print("Tweet cancelled.")
			return
		end

		local resp = post_tweet(tokens.access_token, input)
		if resp.status == 201 or resp.status == 200 then
			print("Tweet posted successfully!")
		else
			print("Failed to post tweet, status:", resp.status)
			print("Response:", resp.body)
		end
	end)
end

return M;
