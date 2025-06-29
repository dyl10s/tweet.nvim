# tweet.nvim

A Neovim plugin to tweet directly from your editor.

## Features

- Tweet directly from Neovim
- OAuth2 authentication flow
- User commands for login, logout, tweeting, and token path

## Requirements

- Neovim 0.7+
- plenary.nvim
- A Twitter Developer Account and App (for Client ID)

## Installation

Use your preferred package manager.

Example using `lazy.nvim`:

```lua
return { 
    'dyl10s/tweet.nvim',
    opts = {},
	dependencies = {
		"nvim-lua/plenary.nvim",
	}
}
```

## Setup

You need to set up the plugin with your Twitter Client ID. You can obtain a Client ID by creating a Twitter Developer App.

```lua
require('tweet').setup({
    client_id = "YOUR_TWITTER_CLIENT_ID"
})
```

Alternatively, you can set the `TWITTER_CLIENT_ID` environment variable.

```bash
export TWITTER_CLIENT_ID="YOUR_TWITTER_CLIENT_ID"
```

By default, the plugin uses port `51899` for the OAuth callback server. You need to configure this as the Callback URI / Redirect URL in your Twitter Developer App settings. The full callback URL will be `http://localhost:51899/callback`. If you change the port in the setup, make sure to update the Callback URI in your Twitter Developer App accordingly.

Before posting a tweet with tweet.nvim you must authenticate using `TweetLogin`. By default, this will open a browser window. If you prefer to authenticate manually, use the `TweetLoginNoBrowser` command the OAuth url will be printed to the console.

## Usage

- `:TweetLogin`: Start the OAuth authentication flow (opens browser).
- `:TweetLoginNoBrowser`: Start the OAuth authentication flow (prints URL to console).
- `:Tweet`: Prompt for tweet content and post it.
- `:TweetLogout`: Delete your saved Twitter tokens.
- `:TweetPrintTokenPath`: Print the path where tokens are stored.

## Additional Configuration

Below is the setup function with all the default values that can be configured.

```lua
require('tweet').setup({
    client_id = nil,    -- The client_id from the X developer portal, can be set with TWITTER_CLIENT_ID as well
    port = 51899,       -- The port used to start the local OAuth callback server
    auto_auth = true    -- Automatically runs :TweetLogin if you are not logged in
})
```

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue. If you'd like to contribute code, please open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

