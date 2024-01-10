-- Apply right rotations, right shifts, and xor to big-endian bit table
local function sigma(tab, num)
    local bitArgs = {}
    if (num == 0) then
        bitArgs = {7, 18, 3}
    elseif (num == 1) then
        bitArgs = {17, 19, 10}
    else
        error('Incorrect num arg.')
    end

    local a = bitops.rotrb(tab, bitArgs[1])
    local b = bitops.rotrb(tab, bitArgs[2])
    local c = bitops.shiftrb(tab, bitArgs[3])

    local result = {}

    -- do the xor
    for i=1, #a, 1 do
        result[i] = math.fmod((a[i]+b[i]+c[i]), 2)
    end

    return result
end

-- The wikipedia on SHA-2 is very helpful
-- data should be an array of bits
local function compute(data, dataLen)
    -- Hash values
    local h1 = 0x6a09e667
    local h2 = 0xbb67ae85
    local h3 = 0x3c6ef372
    local h4 = 0xa54ff53a
    local h5 = 0x510e527f
    local h6 = 0x9b05688c
    local h7 = 0x1f83d9ab
    local h8 = 0x5be0cd19

    -- Round constants
    local constants = {
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    }

    -- Pre Processing
    -- Append 1
    data[#data+1] = 1

    -- Append 0s until L+1+K+64 is a multiple of 512
    local paddedZeros = 0
    while (not (math.fmod((dataLen + 1 + paddedZeros + 64), 512) == 0)) do
        paddedZeros = paddedZeros + 1
    end

    for i=1, paddedZeros, 1 do
        data[#data+1] = 0
    end

    -- Append length as a 64 bit big-endian integer
    data = tabops.tableConcat(data, numops.dec2bin(dataLen, 64))

    -- Processing
    -- Break file into 512-bit chunks
    local chunks = {}
    local tmp = {}

    for i=1, #data, 1 do
        tmp[#tmp + 1] = data[i]

        if (math.fmod(i, 512) == 0) then
            chunks[#chunks + 1] = tmp
            tmp = {}
        end
    end

    -- For each chunk:
    for i=1, #chunks, 1 do
        -- Split into 16 32 bit words
        local words = {}

        local chunkIndex = 1
        for j=1, 16, 1 do
            local word = {}
            for l=1, 32, 1 do
                word[l] = chunks[i][chunkIndex]
                chunkIndex = chunkIndex + 1
            end
            words[j] = word
        end

        for j=17, 64, 1 do
            -- Add our terms then % 2^32 so we get a 32 bit result
            local tmpValue = 0

            tmpValue = tmpValue + numops.bin2dec(sigma(words[j - 2], 1))
            tmpValue = tmpValue + numops.bin2dec(words[j - 7])
            tmpValue = tmpValue + numops.bin2dec(sigma(words[j - 15], 0))
            tmpValue = tmpValue + numops.bin2dec(words[j - 16])

            words[j] = numops.dec2bin(math.fmod(tmpValue, math.pow(2, 32)), 32)
        end

        -- Now words is 64 long and has everything...
        -- "Initialize working variables to current hash value:"
        local a = h1
        local b = h2
        local c = h3
        local d = h4
        local e = h5
        local f = h6
        local g = h7
        local h = h8

        for j=1, #words, 1 do
            -- Get sigma1 (bits)
            local sigma1 = {}

            local sigma1a = bitops.rotrb(numops.dec2bin(e, 32), 6)
            local sigma1b = bitops.rotrb(numops.dec2bin(e, 32), 11)
            local sigma1c = bitops.rotrb(numops.dec2bin(e, 32), 25)

            -- the xor
            for l=1, #sigma1a, 1 do
                sigma1[l] = math.fmod((sigma1a[l]+sigma1b[l]+sigma1c[l]), 2)
            end

            -- Get ch (bits)
            local ch = bitops.xorb(
                bitops.andb(numops.dec2bin(e, 32), numops.dec2bin(f, 32)),
                bitops.andb(bitops.notb(numops.dec2bin(e, 32)), numops.dec2bin(g, 32))
            )

            -- Get temp1 (number)
            local temp1 = math.fmod(
                (h + numops.bin2dec(sigma1) + numops.bin2dec(ch) +
                    constants[j] + numops.bin2dec(words[j])),
                math.pow(2, 32)
            )

            -- Get sigma0 (bits)
            local sigma0 = {}

            local sigma0a = bitops.rotrb(numops.dec2bin(a, 32), 2)
            local sigma0b = bitops.rotrb(numops.dec2bin(a, 32), 13)
            local sigma0c = bitops.rotrb(numops.dec2bin(a, 32), 22)

            -- the xor
            for l=1, #sigma0a, 1 do
                sigma0[l] = math.fmod((sigma0a[l]+sigma0b[l]+sigma0c[l]), 2)
            end

            -- Get maj (bits)
            local maj = {}

            local maja = bitops.andb(numops.dec2bin(a, 32), numops.dec2bin(b, 32))
            local majb = bitops.andb(numops.dec2bin(a, 32), numops.dec2bin(c, 32))
            local majc = bitops.andb(numops.dec2bin(b, 32), numops.dec2bin(c, 32))

            -- the xor
            for l=1, #maja, 1 do
                maj[l] = math.fmod((maja[l]+majb[l]+majc[l]), 2)
            end

            -- Get temp2 (number)
            local temp2 = math.fmod(
                (numops.bin2dec(sigma0) + numops.bin2dec(maj)),
                math.pow(2, 32)
            )

            -- Assign new values to a-h
            h = g
            g = f
            f = e
            e = math.fmod(d + temp1, math.pow(2, 32))
            d = c
            c = b
            b = a
            a = math.fmod(temp1 + temp2, math.pow(2, 32))
        end

        h1 = math.fmod(h1 + a, math.pow(2, 32))
        h2 = math.fmod(h2 + b, math.pow(2, 32))
        h3 = math.fmod(h3 + c, math.pow(2, 32))
        h4 = math.fmod(h4 + d, math.pow(2, 32))
        h5 = math.fmod(h5 + e, math.pow(2, 32))
        h6 = math.fmod(h6 + f, math.pow(2, 32))
        h7 = math.fmod(h7 + g, math.pow(2, 32))
        h8 = math.fmod(h8 + h, math.pow(2, 32))
    end

    local hexh1 = numops.dec2hex(h1, 32)
    local hexh2 = numops.dec2hex(h2, 32)
    local hexh3 = numops.dec2hex(h3, 32)
    local hexh4 = numops.dec2hex(h4, 32)
    local hexh5 = numops.dec2hex(h5, 32)
    local hexh6 = numops.dec2hex(h6, 32)
    local hexh7 = numops.dec2hex(h7, 32)
    local hexh8 = numops.dec2hex(h8, 32)

    print(hexh1 .. " " .. hexh2 .. " " .. hexh3 .. " " .. hexh4 .. " " .. hexh5 .. " " .. hexh6 .. " " .. hexh7 .. " " .. hexh8)
    return (hexh1 .. hexh2 .. hexh3 .. hexh4 .. hexh5 .. hexh6 .. hexh7 .. hexh8)
end

function sha256(input)
    local bits = {}
    local L = 0

    if (fs.exists(input) and not (fs.isDir(input))) then
        -- Open file and get length
        local file = fs.open(input, "rb")
        L = fs.getSize(input)

        -- Read file as bytes
        for i=1, L, 1 do
            bits = tabops.tableConcat(bits, numops.dec2bin(file.read(), 8))
        end

        file.close()
    else
        local stringInput = tostring(input)
        L = string.len(stringInput)

        for i=1, L, 1 do
            bits = tabops.tableConcat(bits, numops.dec2bin(string.byte(stringInput, i), 8))
        end
    end

    return compute(bits, L)
end