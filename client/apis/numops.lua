-- Outputs a decimal number in binary big-endian format
function dec2bin(num, bitNum)
    num = tonumber(num)
    bitNum = tonumber(bitNum)

    if ((not type(num) == "number") or (not type(bitNum) == "number")) then
        error("Number expected, not received.")
    end

    local bits = {}

    -- convert to binary
    while (num > 0) do
        local scanned = math.fmod(num, 2)
        bits[#bits + 1] = scanned
        num = (num-scanned) / 2
    end

    local result = {}

    -- reverse the list so it's proper big endian
    for i=#bits, 1, -1 do
        result[#result + 1] = bits[i]
    end

    if (#result > bitNum) then
        local newResult = {}
        for i=1, bitNum, 1 do
            newResult[i] = result[#result-i + 1]
        end

        print(table.concat(result) .. " truncated to " .. table.concat(newResult))

        result = newResult
    end

    -- pad with zeros
    while (#result < bitNum) do
        table.insert(result, 1, 0)
    end

    return result
end