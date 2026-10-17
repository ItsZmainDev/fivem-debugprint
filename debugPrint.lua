--- @author    Mathis Hoarau (@Koaio)
--- @version   1.0.0
--- @license   Custom (based on MIT) - see LICENSE file
--- @repo      https://github.com/Koaio/fivem-debugprint

--- debugPrint - Print any data in a readable format
--- @param data any data to print
--- @param opts? table { indent?: boolean, maxDepth?: number, tag?: string }
local function debugPrint(data, opts)
    opts = opts or {}
    local indent   = opts.indent ~= false
    local maxDepth = opts.maxDepth or 32
    local tag      = opts.tag and ("[" .. opts.tag .. "] ") or ""

    if not json or not json.encode then
        print(tag .. "[debugPrint] json.encode unavailable")
        return
    end

    local seen, refId = {}, 0
    local function convert(v, depth)
        local t = type(v)

        if t == "string" or t == "number" or t == "boolean" then
            return v
        end

        if t == "userdata" then
            local ok, s = pcall(tostring, v)
            return ok and s or "<userdata>"
        end

        if t ~= "table" then
            return "<" .. t .. ">"
        end

        if seen[v] then
            return "<cycle:" .. seen[v] .. ">"
        end
        if depth >= maxDepth then
            return "<max-depth>"
        end

        local mt = getmetatable(v)
        if mt then
            if mt.__name and not (mt.__pairs or mt.__index) then
                return "<" .. mt.__name .. ">"
            end
            if mt.__index and not mt.__pairs then
                return "<proxy:" .. (mt.__name or "table") .. ">"
            end
        end

        refId = refId + 1
        seen[v] = refId

        local out = {}
        local okIter = pcall(function()
            for k, val in pairs(v) do
                local kt = type(k)
                local key
                if kt == "string" then
                    key = k
                elseif kt == "number" or kt == "boolean" then
                    key = tostring(k)
                else
                    local ok, s = pcall(tostring, k)
                    key = ok and s or ("<key:" .. kt .. ">")
                end
                out[key] = convert(val, depth + 1)
            end
        end)
        if not okIter then
            return "<uniterable:" .. (mt and mt.__name or "table") .. ">"
        end
        return out
    end

    local okConv, safe = pcall(convert, data, 0)
    if not okConv then
        print(tag .. "[debugPrint] convert error: " .. tostring(safe))
        return
    end

    local okEnc, encoded = pcall(json.encode, safe, { indent = indent })
    if not okEnc then
        print(tag .. "[debugPrint] encode error: " .. tostring(encoded))
        return
    end

    if #encoded > 1000 then
        local lineStart = 1
        for i = 1, #encoded do
            if encoded:byte(i) == 10 or (i - lineStart >= 1000) then
                print(tag .. encoded:sub(lineStart, i))
                lineStart = i + 1
            end
        end
        if lineStart <= #encoded then
            print(tag .. encoded:sub(lineStart))
        end
    else
        print(tag .. encoded)
    end
end

_G.debugPrint = debugPrint