# Luvit ReQl

## Connecting
To open a connection with luvit-reql you can do the following example.  
**Caution! Currently required to be ran inside a coroutine.**
```lua
local luvitReQL = require('luvit-reql')
luvitReQL.connect(options)
```

### Options
| Key       | Default   | Type     |
|:--------- |:--------- |:--------:|
| address   | 127.0.0.1 | string   |
| port      | 28015     | number   |
| user      | admin     | string   |
| password  |           | string   |
| db        | test      | string   |
| reconnect | false     | boolean  |
| reusable  | false     | boolean  |