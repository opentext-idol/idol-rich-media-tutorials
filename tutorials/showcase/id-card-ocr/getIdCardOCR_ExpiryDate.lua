-- create new rectangles relative to recognised item's region
function getOcrRegion(record, fieldName)
  local w = record.ImageData.width
  local h = record.ImageData.height

  local output = {}
  local i = 0

  for key,value in pairs(record.IdentityData.metadata) do
      log(key, value)
      if key == fieldName then
          local roi = {}
          local j = 0

          for token in string.gmatch(value, "%S+") do
              j = j + 1
              roi[j] = tonumber(token)
              if not roi[j] then break end
          end
          log(i+1, roi)
          if roi[4] then
              i = i + 1
              output[i] = { left = w * roi[1] / 100, top = h * roi[2] / 100, width = w * roi[3] / 100, height = h * roi[4] / 100 }
          end
      end
  end

  return output
end

function rectangle(record)
  return getOcrRegion(record, 'OCR_ExpiryDate')
end
