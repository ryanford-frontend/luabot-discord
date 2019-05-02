### Luabot for Discord

Helpful chat minion build with Lua.

Luabot uses the [Discordia](https://github.com/SinisterRectus/Discordia/) Discord library on top of [Luvit](https://github.com/luvit/luvit). See their [wiki](https://github.com/SinisterRectus/Discordia/wiki) for help getting the environment set up. Luabot uses the [coro-fs](https://github.com/luvit/lit/blob/master/deps/coro-fs.lua) replacement for Luvit's builtin fs lib.

Luabot uses [LPEG](http://www.inf.puc-rio.br/~roberto/lpeg/) for the text parsing. It's baked in with Luvit and not an additional dependency.

Notable features include:
- Can match multiple commands in 1 message
- Commands can take variable amount of user mentions or queries
- Handy utilities to dynamically load comamnds and create new patterns
