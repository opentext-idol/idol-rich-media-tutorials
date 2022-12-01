-- create OCR rectangle relative to recognised anchor's region
function rectangle(record)

  -- Extract template values
  local roi = {}
  local anchor = {}
  local id_h = 0
  local id_w = 0
  
  for key,value in pairs(record.IdentityData.metadata) do

    if key == "OCR_Forename" then
      local j = 0

      for token in string.gmatch(value, "%S+") do
        j = j + 1
        roi[j] = tonumber(token)
        if not roi[j] then break end
      end
    end
    
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

  local id_card = {
    left = record.RegionData.left - aLeft * record.RegionData.width, 
    top = record.RegionData.top - aTop * record.RegionData.height, 
    width = aWidth * record.RegionData.width, 
    height = aHeight * record.RegionData.height 
  }

  return { 
    left = id_card.left + roi[1] * id_card.width / id_w, 
    top = id_card.top + roi[2] * id_card.height / id_h, 
    width = roi[3] * id_card.width / id_w, 
    height = roi[4] * id_card.height / id_h 
  }

end
