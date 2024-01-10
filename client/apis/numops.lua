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

        -- reverse newResult
        local newerResult = {}
        for i=bitNum, 1, -1 do
            newerResult[#newerResult+1] = newResult[i]
        end

        result = newerResult
    end

    -- pad with zeros
    while (#result < bitNum) do
        table.insert(result, 1, 0)
    end

    return result
end

-- Outputs a lua number given a binary big-endian bit table
function bin2dec(tab)
    if (not (type(tab) == "table")) then
        error("Expected table.")
    end

    return tonumber(table.concat(tab), 2)
end

-- Outputs a hex number (string) given a binary big-endian bit table
function bin2hex(tab)
    if (not (type(tab) == "table")) then
        error("Expected table.")
    end

    local digitLookup = {
        ["0000"]="0",
        ["0001"]="1",
        ["0010"]="2",
        ["0011"]="3",
        ["0100"]="4",
        ["0101"]="5",
        ["0110"]="6",
        ["0111"]="7",
        ["1000"]="8",
        ["1001"]="9",
        ["1010"]="a",
        ["1011"]="b",
        ["1100"]="c",
        ["1101"]="d",
        ["1110"]="e",
        ["1111"]="f"
    }

    local result = {}
    local digit = {}
    local bitCounter = 0
    for i=#tab, 1, -1 do
        bitCounter = bitCounter + 1
        table.insert(digit, 1, tab[i])

        if (bitCounter == 4) then
            table.insert(result, 1, digitLookup[table.concat(digit)])
            bitCounter = 0
        end

        if ((i == 1) and (bitCounter > 0)) then
            _ = {0, 0, 0, 0}
            digit, _ = bitops.padb(digit, _)
            table.insert(result, 1, digitLookup[table.concat(digit)])
        end
    end

    return table.concat(result)
end

-- Outputs a hex number given a number and number's bit length
function dec2hex(num, numBits)
    num = tonumber(num)
    numBits = tonumber(numBits)

    if ((not (type(num) == "number")) or (not (type(numBits) == "number"))) then
        error("Expected two numbers.")
    end

    return bin2hex(dec2bin(num, numBits))
end