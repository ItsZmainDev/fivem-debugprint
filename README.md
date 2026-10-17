# fivem-debugprint

> Print any Lua data in a readable JSON format — safe for FiveM (client & server).

A drop-in replacement for `print(json.encode(data))` that **doesn't crash** on the things that usually break JSON encoding in FiveM:

- 🔁 **Cycles** in tables
- 🎯 **Userdata** (`vector3`, `Entity`, `Player`, etc.)
- 🛡️ **Proxies** with `__index` (statebags, custom classes)
- 🌊 **Deep tables** (configurable `maxDepth`)
- 📏 **Huge outputs** (auto-chunked for the F8 console)

---

## ✨ Features

| Feature | Description |
|---|---|
| **Cycle-safe** | Self-referencing tables become `<cycle:N>` instead of crashing |
| **Userdata-aware** | `vector3(1.0, 2.0, 3.0)`, `player:1`, `vehicle:42`… all readable |
| **Proxy-safe** | Objects with `__index` but no `__pairs` are displayed as `<proxy:Name>` |
| **Depth-limited** | `maxDepth` prevents infinite recursion (`32` by default) |
| **UTF-8 safe chunking** | Splits by `\n`, never cuts a multi-byte character |
| **Error-proof** | `pcall` around conversion, iteration and encoding |
| **Taggable** | `opts.tag` prefixes the output (`[MyScript] {...}`) |
| **Client + Server** | Works everywhere, zero dependencies |

---

## 📥 Installation

### Option A — As a standalone resource

```bash
cd resources/
git clone https://github.com/Koaio/fivem-debugprint
```

### Option B — Inside an existing resource

Copy `debugPrint.lua` into your `shared/` folder, then in your `fxmanifest.lua`:

```lua
shared_script 'shared/debugPrint.lua'
```

`debugPrint` is registered as a global (`_G.debugPrint`) — available **everywhere**.

## 🚀 Usage

```lua
-- Basic
debugPrint({ health = 100, coords = GetEntityCoords(PlayerPedId()) })
-- Output: {"coords":"vector3(215.7, -810.2, 30.7)","health":100}

-- With a tag (helpful in F8)
debugPrint(myConfig, { tag = "Config" })

-- No indentation (compact, good for big objects)
debugPrint(entityList, { indent = false })

-- Limit depth
debugPrint(GetGamePool("CVehicle"), { maxDepth = 3 })

-- Combined
debugPrint(playerData, { tag = "Player", indent = true, maxDepth = 10 })
```

### Options

| Option     | Type      | Default | Description                                      |
|------------|-----------|---------|--------------------------------------------------|
| `indent`   | `boolean` | `true`  | Pretty-print with indentation                    |
| `maxDepth` | `number`  | `32`    | Max. depth `<max-depth>`               |
| `tag`      | `string`  | `nil`   | prefix `[Tag] {...}`                      |

