local utils = {}

function utils.printTable(t, indent)
    indent = indent or ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. k .. ": {")
            utils.printTable(v, indent .. "  ")
            print(indent .. "}")
        else
            print(indent .. k .. ": " .. tostring(v))
        end
    end
end

return utils