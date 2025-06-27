local encoding = require("tweet.encoding")
local async = require("plenary.async")

local M = {}

M.start_callback_server = function(port)
	assert(port, "Port is required");

	local sender, receiver = async.control.channel.oneshot()

	async.run(function()
		local server = vim.uv.new_tcp()
		assert(server, "Could not create tcp server!");

		server:bind("0.0.0.0", port)

		server:listen(128, function(err)
			assert(not err, err)

			local client = vim.uv.new_tcp()
			assert(client, "Could not create tcp client!")

			server:accept(client)

			client:read_start(function(clientErr, data)
				assert(not clientErr, clientErr)

				if data then
					local request_line = data:match("([^\r\n]+)")
					local path = request_line:match("GET%s+([^%s]+)")
					local query = path:match("%?(.+)")
					local params = {}
					if query then
						params = encoding.parse_query_params(query)
					end

					local code = params.code
					if code then
						local response = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" ..
							"<html><body><h1>Tweet.nvim Authorization complete. You can close this tab.</h1></body></html>"
						client:write(response, function()
							client:shutdown()
							client:close()
						end)

						server:close()

						sender(code)
					else
						client:close()
					end
				end
			end)
		end)
	end, function()
	end)


	return receiver()
end

return M;
