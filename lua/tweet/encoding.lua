local M = {};

M.parse_query_params = function(query)
	local params = {}
	for key, val in string.gmatch(query, "([^&=?]+)=([^&=?]+)") do
		params[key] = val
	end
	return params
end

M.url_encode = function(str)
	if not str then return "" end
	str = tostring(str)
	return (str:gsub("[^%w%-._~]", function(c)
		return string.format("%%%02X", c:byte())
	end))
end

return M;
