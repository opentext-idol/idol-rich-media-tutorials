-- Draw OCR region rectangles

function draw(record)
  for i,subRecord in pairs(record.CombineOperationData.combinedRecords) do
    if subRecord.RectangleData then
      fillRectangle(subRecord.RectangleData, rgb(0, 0, 0))
    end
  end
end
