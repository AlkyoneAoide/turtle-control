-- pad tables of big-endian bits to match
local function padb(tab1, tab2)
    if (#tab1 < #tab2) then
        for i=1, #tab2, 1 do
            table.insert(tab1, 1, 0)
        end
    elseif (#tab2 < #tab1) then
        for i=1, #tab1, 1 do
            table.insert(tab2, 1, 0)
        end
    end
    
    return tab1, tab2
end

-- print a table of bits
function printb(tab)
    for i=#tab, 1, -1 do
        write(tab[#tab - i + 1])

        if (math.fmod(i-1, 4) == 0) then
            write(" ")
        end
    end

    print()
end

-- right shift a table of big-endian bits
function shiftrb(tab, num)
    for i=1, num, 1 do
        table.remove(tab, #tab)
        table.insert(tab, 1, 0)
    end

    return tab
end

-- right rotate a table of big-endian bits
function rotrb(tab, num)
    for i=1, num, 1 do
        table.insert(tab, 1, tab[#tab])
        table.remove(tab, #tab)
    end

    return tab
end

-- not a table of bits
function notb(tab)
    local result = {}
    for i=1, #tab, 1 do
        if (tab[i] == 1) then
            result[i] = 0
        else
            result[i] = 1
        end
    end

    return result
end

-- and two tables of big-endian bits
function andb(tab1, tab2)
    -- pad tables to the same length
    tab1, tab2 = padb(tab1, tab2)

    -- do the anding
    local result = {}
    for i=1, #tab1, 1 do
        if ((tab1[i] == 1) and (tab2[i] == 1)) then
            result[i] = 1
        else
            result[i] = 0
        end
    end

    return result
end

-- add two tables of big-endian bits
function addb(tab1, tab2)
    -- pad tables to the same length
    tab1, tab2 = padb(tab1, tab2)

    -- do the adding
    local result = {}
    local carry = 0
    for i=#tab1, 1, -1 do
        local temp = tab1[i] + tab2[i] + carry

        result[i] = math.fmod(temp, 2)

        if (temp > 1) then
            carry = 1
        else
            carry = 0
        end
    end

    return result
end

-- xor two tables of big-endian bits
function xorb(tab1, tab2)
    -- pad tables to the same length
    tab1, tab2 = padb(tab1, tab2)

    -- do the xoring
    local result = {}
    for i=1, #tab1, 1 do
        local a = (not (tab1[i] and tab2[i]))
        local b = (tab1[i] and a)
        local c = (tab2[i] and a)

        if (b or c) then
            result[i] = 1
        else
            result[i] = 0
        end
    end

    return result
end