-- create ID Card rectangle relative to recognised item's region
function rectangle(record)
  
  -- Extract template values
  local anchor = {}
  local id_h = 0
  local id_w = 0

  for key,value in pairs(record.IdentityData.metadata) do
    
    if key == "AnchorBoxPixels" then
      local j = 0
      
      for token in string.gmatch(value, "%S+") do
        j = j + 1
        anchor[j] = tonumber(token)
        if not anchor[j] then break end
      end
    end
    
    if key == "IDHeightPixels" then
      id_h = value
    end
    
    if key == "IDWidthPixels" then
      id_w = value
    end

  end

  -- Calculate transformation
  -- anchor = { l, t, w, h }
  local aLeft = anchor[1] / anchor[3]
  local aTop = anchor[2] / anchor[4]
  local aWidth = id_w / anchor[3]
  local aHeight = id_h / anchor[4]
  
  return { 
    left = record.RegionData.left - aLeft * record.RegionData.width, 
    top = record.RegionData.top - aTop * record.RegionData.height, 
    width = aWidth * record.RegionData.width, 
    height = aHeight * record.RegionData.height 
  }

end
