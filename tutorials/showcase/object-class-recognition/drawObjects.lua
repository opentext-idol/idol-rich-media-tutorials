--
-- Knowledge Discovery Rich Media Tutorials:
-- Object Recognition
--
function str2int(str)
  -- Return a single number, the sum of the interger character 
  -- codes for the letters in the input string.
  val = os.time()
  for i=1,string.len(str) do
    val = val + string.byte(str, i)
  end
  return val
end

function seededColor(str)
  -- Return random RGB values, seeded by an input string in 
  -- order to be reproducible within this session.
  math.randomseed( str2int(str) )
  color = {}
  color['r'] = math.random(0,255) 
  color['g'] = math.random(0,255)
  color['b'] = math.random(0,255)
  return color
end

function isBright(color)
  -- https://www.w3.org/TR/AERT/#color-contrast
  -- NOTE: weights sum to 1, so: brightness(255, 255, 255) = 255
  local brightness = color['r']*0.299 + color['g']*0.587 + color['b']*0.114
  return 2*brightness > 255
end

function draw(record)
  local lineThickness = 2
  local charHeight = 30

  local classList = {} -- keep a list of detected classes
  for i,detection in pairs(record.CombineOperationData.combinedRecords) do
    local box = detection.RectangleData
    local class = detection.ClassificationData.identifier

    if classList[class] == nil then
      -- append a new class name
      classList[class] = true
    end

    local color = seededColor(class)
    drawRectangle(box, lineThickness, rgb(color['r'], color['g'], color['b']))
  end

  j = 0
  for class,b in pairs(classList) do
    local color = seededColor(class)
    local txtColor = rgb(255,255,255)
    if isBright(color) then
      txtColor = rgb(0,0,0)
    end
    
    local top = 0 + j*charHeight
    local left = 0
    drawText(" "..class.." ", left, top, "arial", charHeight, txtColor, rgb(color['r'], color['g'], color['b']))
    j = j + 1
  end
end
