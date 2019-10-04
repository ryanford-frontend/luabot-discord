### Luabot for Discord

Helpful chat minion build with Lua.

Luabot uses the [Discordia](https://github.com/SinisterRectus/Discordia/) Discord library on top of [Luvit](https://github.com/luvit/luvit). See their [wiki](https://github.com/SinisterRectus/Discordia/wiki) for help getting the environment set up. Luabot uses the [coro-fs](https://github.com/luvit/lit/blob/master/deps/coro-fs.lua) replacement for Luvit's builtin fs lib.

Luabot uses [LPEG](http://www.inf.puc-rio.br/~roberto/lpeg/) for the text parsing. It's baked in with Luvit and not an additional dependency.

Notable features include:
- Can match multiple commands in 1 message
- Commands can take variable amount of user mentions or queries
- Handy utilities to dynamically load comamnds and create new patterns

### Install Instructions

##### 1. Set up your bot on Discord

 See [Discordia Wiki](https://github.com/SinisterRectus/Discordia/wiki/Setting-up-a-Discord-application) for instructions

##### 2. Get Luvit/Lit

 See [Luvit's Instructions](https://luvit.io/install.html) 

##### 3. Clone this repo

 `git clone https://github.com/ryanford-frontend/luabot-discord.git`

##### 4. Install Discordia

 `cd` into the project root and run `lit install SinisterRectus/discordia`

##### 5. Install dependencies

 `lit install creationix/coro-fs`

##### 6. Create a `config.lua` with your bot token
 ```
 local config = {
    token = 'Bot YOUR_TOKEN_HERE',
 }
    
 return config
 ```
##### 7. Start the bot

 `luvit bot.lua`

##### 8. You're done! :tada:
