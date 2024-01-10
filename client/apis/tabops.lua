-- Adds the values of tab2 to tab1
function tableConcat(tab1, tab2)
    if ((not type(tab1) == "table") or (not type(tab2) == "table")) then
        error("Args 1 and 2 should be tables.")
    end

    for i=1, #tab2, 1 do
        tab1[#tab1 + 1] = tab2[i]
    end

    return tab1
end