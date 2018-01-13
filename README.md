# Luvit ReQL

## Support
For support, please join [the discord support server.](https://discord.gg/n6DUK36)

# Connecting
To open a connection with luvit-reql you can do the following example.   
**Caution. If ran outside a coroutine, a callback function MUST be supplied on reql.connect**
```lua
local luvitReQL = require('luvit-reql')
local connection = luvitReQL.connect(options, callback)
```

### Options
| Setting   | Default   | Type     |
| --------- | --------- | -------- |
| address   | 127.0.0.1 | string   |
| port      | 28015     | number   |
| user      | admin     | string   |
| password  |           | string   |
| db        | test      | string   |
| reconnect | false     | boolean  |
| reusable  | false     | boolean  |
| debug     | false     | boolean  |

### Callback
The callback must be a function and will be called with the connection after the driver has successfully connected to RethinkDB
* Only called for Async Mode (reql.connect not called in a coroutine); ignored for Sync Mode (reql.connect called in a coroutine)

#### Raw Options
```lua
local options = {
    address = '127.0.0.1',
    port = 28015,
    user = 'admin',
    password = '',
    db = 'test',
    reconnect = false,
    reusable = false,
    debug = false
}
```