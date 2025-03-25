function doInterpolation()
	return true
end

function displayText()
	return true
end

function getSourcePos(record)
	if record.timestamp ~= nil then
		return tonumber(record.timestamp.startTime)
	elseif record.pageNumber ~= nil then
		return tonumber(record.pageNumber)
	else
		return nil
	end
end

function getHex(str, index)
    val = string.byte(str, index)
    val = val - 48
    if val > 10 then val = val - 39 end
    return val
end

function getColourForId(record)
    uuid = record.UUIDData.uuid
    c1 = getHex(uuid,1) * 16 + getHex(uuid,2)
    c2 = getHex(uuid,3) * 16 + getHex(uuid,4)
    c3 = getHex(uuid,5) * 16 + getHex(uuid,6)
    return rgb(c1,c2,c3)
end

-- Class to accumulate results deduplicating multiple results with same ID by choosing the one with time closest to the time of the current frame
ResultsProcessor = {
	lineThickness = 4,  -- line thickness to draw the results with
	colours = {         -- colours for each analysis type
		ocr = rgb(0, 0, 255), -- blue
		ocrTable = rgb(255, 215, 0), -- gold
		numberPlate = rgb(0, 255, 0), -- lime
		demographic = {
			male = rgb(255, 128, 0), -- orange
			female = rgb(64, 0, 128), -- purple
			unknown = rgb(128, 128, 128) }, -- grey
		faceRecognition = {
			recognized = rgb(144, 238, 144), -- light green
			unknown = rgb(173, 216, 230)}, -- light blue
		faceDetection = rgb(255,255,255), -- white
		objectRecognition = rgb(0, 128, 128), -- teal
		objectDetection = rgb(128, 0, 0), -- maroon
		textDetection = rgb(128, 128, 0), -- olive
		imageComparison = rgb(255,0,0), -- red
		vehicleBounds = rgb(0, 128, 0), -- green
		vehicleGrillePatch = rgb(0, 128, 128), -- turquoise
		clothing = {
			upper = rgb(154, 205, 50), -- yellow green
			lower = rgb(255, 255, 50), -- yellow
			full = rgb(0, 255, 255) }, -- cyan
		barcode = rgb(255, 0, 255), -- magenta
		sceneAnalysis = {
			path =  rgb(0, 255, 255), -- cyan
			polygon = rgb(255, 0, 255) -- magenta
		},
		countBox = rgb(0, 255, 255), -- cyan
		alertPath = {
			path =  rgb(0, 255, 255), -- cyan
			boundingBox = rgb(255, 0, 255) -- magenta
		},
		alertRegion = {
			path =  rgb(0, 255, 255), -- cyan
			boundingBox = rgb(255, 0, 255) -- magenta
		},
		alertTripWires = {
			pathPreAlert =  rgb(0, 255, 255), -- cyan
			pathPostAlert =  rgb(0, 255, 0), -- green
			boundingBoxAtAlert = rgb(255, 0, 255) -- magenta
		},
        alertStationary = rgb(255, 255, 50), -- yellow
		setRectangle = rgb(255, 128, 0) -- orange
	},
	-- Construct a ResultsProcessor, must provide the time of the current frame as frameTime (e.g. ResultsProcessor:new({frameTime=getSourcePos(record)}))
	new = function(self, obj)
			if not obj.frameTime then
				error("frameTime must be set")
			end

			-- Gather the results in a table, most of them will be keyed by their ID. ImageComparison results have no associated ID, and are stored seperately in obj.comparisonRects
			obj.toDraw = { }

			-- Ensure the returned object has a class of ResultsProcessor
			setmetatable(obj, self)
			self.__index = self
			return obj
		end,

	-- Is timetamp closer to frameTime than currentBest?
	isBestTime = function(self, srcPos, currentBest)
				return math.abs(srcPos - self.frameTime) < math.abs(currentBest - self.frameTime)
			end,
	
	handleResultNoInterpolation = function(self, toDrawTable, srcPos, shape, result, colour)
							-- If the record is for the time of the current toDraw record, add the record to be drawn
							if (srcPos == toDrawTable.time) then
								table.insert(toDrawTable.records, { record = result, shape = shape, colour = colour })
							end
						end,
	
	handleResultInterpolation = function(self, toDrawTable, srcPos, shape, result, colour)
                    if (srcPos < self.frameTime) then
                        if (not toDrawTable.latestPre or srcPos > toDrawTable.latestPre.srcPos) then
                            toDrawTable.latestPre = {record = result, colour = colour, shape = shape, srcPos = srcPos}
                        end
                    elseif (srcPos > self.frameTime) then
                        if (not toDrawTable.earliestPost or srcPos < toDrawTable.earliestPost.srcPos) then
                            toDrawTable.earliestPost = {record = result, colour = colour, shape = shape, srcPos = srcPos}
                        end
                    else                    
						table.insert(toDrawTable.records, { record = result, shape = shape, colour = colour })
                    end
				end,
	
	handleResultForTable = function(self, toDrawTable, srcPos, shape, result, colour, interpolate)
							if (interpolate) then
								self:handleResultInterpolation(toDrawTable, srcPos, shape, result, colour)
							else
								self:handleResultNoInterpolation(toDrawTable, srcPos, shape, result, colour)
							end
						end,

	-- Determine whether a given result is the best (closest time) result that has been encountered yet for its ID. If there are multiple results for the same ID at the same time, they will all be kept.
	--     id:          the Media Server result ID
	--     srcPos:      the timestamp.startTime/pageNumber for this result
	--     shape:       the shape to draw for the result (rectangle/polygon/face/table)
	--     result:      the result to draw
	--     colour:      the colour to draw the result
	handleResult = function(self, id, srcPos, shape, result, colour)
					local interpolate = doInterpolation()
					if (not self.toDraw[id.uuid]) then
						if (interpolate) then
							self.toDraw[id.uuid] = { records = {}, latestPre = nil, earliestPost = nil }
						else
							self.toDraw[id.uuid] = { time = srcPos, records = {} }
						end
					end
					if ((not interpolate) and self:isBestTime(srcPos, self.toDraw[id.uuid].time)) then
						self.toDraw[id.uuid] = { time = srcPos, records = {} }
					end
					self:handleResultForTable(self.toDraw[id.uuid], srcPos, shape, result, colour, interpolate) 
					end,
					
	handleResultWithText = function(self, id, srcPos, shape, textShape, result, textResult, colour)
							self:handleResult(id, srcPos, shape, result, colour)
							if (displayText()) then
								self:handleResult({uuid=(id.uuid .. "text")}, srcPos, textShape, textResult, colour)
							end
						end,

	handleSetRectangle = function(self, srcPos, result, colour)
						if (not self.toDrawNoID or self:isBestTime(srcPos, self.toDrawNoID.time)) then
							self.toDrawNoID = { time = srcPos, records = {} }
						end
						self:handleResultForTable(self.toDrawNoID, srcPos, "rectangle", result, colour, false)
						end,

	-- Store a list of rectangles if the associated time is closest, no ID check
	handleImageComparisonResult = function(self, srcPos, regions, colour)
									if (not self.toDrawNoID or self:isBestTime(srcPos, self.toDrawNoID.time)) then
										self.toDrawNoID = { time = srcPos, records = {} }
									end
									for i,region in pairs(regions) do
										handleResultForTable(self.toDrawNoID, srcPos, "rectangle", region.region, colour, false)
									end
								end,

	-- Get the correct colour for a DemographicsResult or DemographicsResultAndImage record (displays gender)
	demographicColour = function(self, record)
					local demographic
					if (record.DemographicsResult) then
						demographic = record.DemographicsResult
					elseif (record.DemographicsResultAndImage) then
						demographic = record.DemographicsResultAndImage
					end
					if ('Male' == demographic.gender) then
						return self.colours.demographic.male
					elseif ('Female' == demographic.gender) then
						return self.colours.demographic.female
					else
						return self.colours.demographic.unknown
					end
				end,
	-- Get the correct colour for a ClothingResult or ClothingResultAndImage record (displays clothing region)
	clothingColour = function(self, record)
					local clothing
					if (record.ClothingResult) then
						clothing = record.ClothingResult
					elseif (record.ClothingResultAndImage) then
						clothing = record.ClothingResultAndImage
					end
					if ('Upper' == clothing.regiontype) then
						return self.colours.clothing.upper
					elseif ('Lower' == clothing.regiontype) then
						return self.colours.clothing.lower
					else
						return self.colours.clothing.full
					end
				end,
	-- Get the correct colour for a FaceRecognitionResult or FaceRecognitionResult record (displays recognized or not)
	faceRecognitionColour = function(self, record)
					if (record.IdentityData.identifier) then
						return self.colours.faceRecognition.recognized
					else
						return self.colours.faceRecognition.unknown
					end
				end,

	-- Descend through the combined record, searching for results. Record the closest-in-time detection for each ID
	findBestDetections = function(self, record)
					if (record.CombineOperationData) then
						local i = 1
						while (record.CombineOperationData.combinedRecords[i]) do
							self:findBestDetections(record.CombineOperationData.combinedRecords[i])
							i = i + 1
						end
						self:findBestDetections(record.CombineOperationData.record0)
					elseif (record.AndOperationData) then
						local i = 0
						while (record.AndOperationData["record" .. i]) do
							self:findBestDetections(record.AndOperationData["record" .. i])
							i = i + 1
						end
					else
						local srcPos = getSourcePos(record)
						-- SetRectangle: orange
						if (record.DataWithRectangle) then
							self:handleSetRectangle (srcPos, record.RectangleData, self.colours.setRectangle)
						-- OCR: blue
						elseif (record.OCRResult or record.OCRResultAndImage) then
							self:handleResultWithText(record.UUIDData, srcPos, "rectangle", "ocrtext", record.RectangleData, record, self.colours.ocr)
						elseif (record.OCRDetail) then
							local j = 1
							while (record.OCRDetail.character[j]) do
								self:handleResult(record.UUIDData, srcPos, "rectangle", record.OCRDetail.character[j].region, self.colours.ocr)
								j = j + 1
							end
						-- OCR table: gold
						elseif (record.OCRTableResult) then
							self:handleResult(record.UUIDData, srcPos, "table", record.OCRTableResult, self.colours.ocrTable)
						-- Number Plate: lime
						elseif (record.NumberPlateResult or record.NumberPlateResultAndImage) then
							self:handleResultWithText(record.UUIDData, srcPos, "polygon", "numberplatetext", record.NumberPlateData.readregion, record, self.colours.numberPlate)
						-- Vehicle Model: green/turquoise
						elseif (record.VehicleModelResult or record.VehicleModelResultAndImage) then
							self:handleResultWithText(record.UUIDData, srcPos, "rectangle", "vehiclemodeltext", record.RectangleData, record, self.colours.vehicleBounds)
							self:handleResult(record.UUIDData, srcPos, "polygon", record.PolygonData, self.colours.vehicleGrillePatch)
						-- Face demographics: orange (male); purple (female)
						elseif (record.DemographicsResult or record.DemographicsResultAndImage) then
							self:handleResultWithText(record.UUIDData, srcPos, "face", "facedemographicstext", record.FaceData, record, self:demographicColour(record))
						-- Face recognition: light green (recognized); light blue (unrecognized)
						elseif (record.FaceRecognitionResult or record.FaceRecognitionResultAndImage) then
							self:handleResultWithText(record.UUIDData, srcPos, "face", "facerectext", record.FaceData, record, self:faceRecognitionColour(record))
						-- Face detection: white
						elseif (record.FaceResult or record.FaceResultAndImage or record.FaceStateResult or record.FaceStateResultAndImage) then
							self:handleResult(record.UUIDData, srcPos, "face", record.FaceData, self.colours.faceDetection)
						-- Object Recognition: teal
						elseif (record.ObjectRecognitionResult or record.ObjectRecognitionResultAndImage) then
							self:handleResultWithText(record.UUIDData, srcPos, "polygon", "objectrecogitiontext", record.PolygonData, record, self.colours.objectRecognition)
						-- Object Class Recognition: maroon
						elseif (record.ObjectClassRecognitionResult or record.ObjectClassRecognitionResultAndImage or record.ObjectClassRecognitionWorldResult) then
							self:handleResultWithText(record.UUIDData, srcPos, "rectangle", "objclsrectext", record.RectangleData, record, self.colours.objectDetection)
						-- Text Detection: olive
						elseif (record.TextDetectionResult or record.TextDetectionResultAndImage) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RectangleData, self.colours.textDetection)
						-- Image Comparison: red
						elseif (record.ImageComparisonResultAndImage) then
							self:handleImageComparisonResult(srcPos, record.ImageComparisonResultAndImage.changedRegion, self.colours.imageComparison)
						elseif (record.ImageComparisonResult) then
							self:handleImageComparisonResult(srcPos, record.ImageComparisonResult.changedRegion, self.colours.imageComparison)
						-- Clothing: cyan
						elseif (record.ClothingResult or record.ClothingResultAndImage) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RegionData, self:clothingColour(record))
                        -- Person Analysis: red
						elseif (record.PersonAnalysisResult or record.PersonAnalysisResultAndImage) then
							self:handleResultWithText(record.UUIDData, srcPos, "rectangle", "persontext", record.RegionData, record, self.colours.imageComparison)
						-- Barcode: magenta
						elseif (record.BarcodeResult or record.BarcodeResultAndImage) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RectangleData, self.colours.barcode)
						-- Scene analysis: magenta
						elseif (record.SceneAnalysisResult or record.SceneAnalysisResultAndImage) then
							self:handleResult(record.UUIDData, srcPos, "polygon", record.PolygonData, self.colours.sceneAnalysis.polygon)
							self:handleResult(record.UUIDData, srcPos, "geometricpath", record.GeometricPathData, self.colours.sceneAnalysis.path)
						-- Alert path: cyan path magenta bounds at alert
						elseif (record.AlertPathResult) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RectangleData, self.colours.alertPath.boundingBox)
							self:handleResult(record.UUIDData, srcPos, "geometricpath", record.AlertPathResult.alert.path, self.colours.alertPath.path)
						elseif (record.AlertPathResultAndImage) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RectangleData, self.colours.alertPath.boundingBox)
							self:handleResult(record.UUIDData, srcPos, "geometricpath", record.AlertPathResultAndImage.alert.path, self.colours.alertPath.path)
						-- Alert region: cyan path magenta bounds at alert
						elseif (record.AlertRegionResult) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RectangleData, self.colours.alertRegion.boundingBox)
							self:handleResult(record.UUIDData, srcPos, "geometricpath", record.AlertRegionResult.alert.path, self.colours.alertRegion.path)
						elseif (record.AlertRegionResultAndImage) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RectangleData, self.colours.alertRegion.boundingBox)
							self:handleResult(record.UUIDData, srcPos, "geometricpath", record.AlertRegionResultAndImage.alert.path, self.colours.alertRegion.path)
						-- Alert stationary: cyan path magenta bounds at alert
						elseif (record.AlertStationaryResult) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RectangleData, self.colours.alertStationary)
						elseif (record.AlertStationaryResultAndImage) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RectangleData, self.colours.alertStationary)
						-- Alert trip wire: cyan path pre alert, green path post alert magenta bounds at alert
						elseif (record.TripWiresResult) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RectangleData, self.colours.alertTripWires.boundingBoxAtAlert)
							self:handleResult(record.UUIDData, srcPos, "geometricpath", record.TripWiresResult.alert.pathPreAlert, self.colours.alertTripWires.pathPreAlert)
							self:handleResult(record.UUIDData, srcPos, "geometricpath", record.TripWiresResult.alert.pathPostAlert, self.colours.alertTripWires.pathPostAlert)
						elseif (record.TripWiresResultAndImage) then
							self:handleResult(record.UUIDData, srcPos, "rectangle", record.RectangleData, self.colours.alertTripWires.boundingBoxAtAlert)
							self:handleResult(record.UUIDData, srcPos, "geometricpath", record.TripWiresResultAndImage.alert.pathPreAlert, self.colours.alertTripWires.pathPreAlert)
							self:handleResult(record.UUIDData, srcPos, "geometricpath", record.TripWiresResultAndImage.alert.pathPostAlert, self.colours.alertTripWires.pathPostAlert)
						-- Count engine
						elseif (record.CountResult) then
							local j = 1
							while (record.CountResult.region[j]) do
								self:handleSetRectangle(srcPos, record.CountResult.region[j], self.colours.countBox)
								j = j + 1
							end
						elseif (record.CountResultAndImage) then
							local j = 1
							while (record.CountResultAndImage.region[j]) do
								self:handleSetRectangle(srcPos, record.CountResultAndImage.region[j], self.colours.countBox)
								j = j + 1
							end
						end
					end
				end,

	-- draw all of the found results
	drawAll = function(self)
				local function draw(self, records)
					for i,record in pairs(records) do
						if (record.shape == "rectangle") then
							drawRectangle(record.record, self.lineThickness, record.colour)
						elseif (record.shape == "polygon") then
							drawPolygon(record.record, self.lineThickness, record.colour)
						elseif (record.shape == "geometricpath") then
							drawGeometricPath(record.record, self.lineThickness, record.colour)
						elseif (record.shape == "face") then
							drawEllipse(record.record.ellipse, self.lineThickness, record.colour)
							if (record.record.lefteye and record.record.righteye) then
								drawCircle(record.record.lefteye.center.x, record.record.lefteye.center.y, record.record.lefteye.radius, self.lineThickness, record.colour)
								drawCircle(record.record.righteye.center.x, record.record.righteye.center.y, record.record.righteye.radius, self.lineThickness, record.colour)
							end
						elseif (record.shape == "table") then
							self:drawTable(record.record, record.colour)
						elseif (record.shape == "objectrecogitiontext") then
							self:drawTextBox(record.record.ObjectRecognitionResult.identity.identifier,record.record.PolygonData.point[1].x,record.record.PolygonData.point[1].y - 80, 80, rgb(255,255,255), record.colour)
						elseif (record.shape == "numberplatetext") then
							self:drawTextBox(record.record.NumberPlateResult.numberplate.plateread,record.record.PolygonData.point[4].x,record.record.PolygonData.point[4].y - 80, 80, rgb(255,255,255), record.colour)
						elseif (record.shape == "vehiclemodeltext") then
							self:drawTextBox(record.record.VehicleModelResult.identity.identifier,record.record.RectangleData.left,record.record.RectangleData.top, 80, rgb(255,255,255), record.colour)
						elseif (record.shape == "persontext") then
							local fieldsRecorded = 0
							if (record.record.PersonAnalysisResult.hatcolor and record.record.PersonAnalysisResult.hatcolor.identifier) then
								self:drawTextBox("Hat color: " .. record.record.PersonAnalysisResult.hatcolor.identifier,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
								fieldsRecorded = fieldsRecorded + 1
							end
							if (record.record.PersonAnalysisResult.hatstyle and record.record.PersonAnalysisResult.hatstyle.identifier) then
								self:drawTextBox("Hat style: " .. record.record.PersonAnalysisResult.hatstyle.identifier,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
								fieldsRecorded = fieldsRecorded + 1
							end
							if (record.record.PersonAnalysisResult.haircolor and record.record.PersonAnalysisResult.haircolor.identifier) then
								self:drawTextBox("Hair color: " .. record.record.PersonAnalysisResult.haircolor.identifier,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
								fieldsRecorded = fieldsRecorded + 1
							end
							if (record.record.PersonAnalysisResult.hairstyle and record.record.PersonAnalysisResult.hairstyle.identifier) then
								self:drawTextBox("Hair style: " .. record.record.PersonAnalysisResult.hairstyle.identifier,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
								fieldsRecorded = fieldsRecorded + 1
							end
							if (record.record.PersonAnalysisResult.facialhair and record.record.PersonAnalysisResult.facialhair.identifier) then
								self:drawTextBox("Facial hair: " .. record.record.PersonAnalysisResult.facialhair.identifier,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
								fieldsRecorded = fieldsRecorded + 1
							end
							if (record.record.PersonAnalysisResult.uppercolor and record.record.PersonAnalysisResult.uppercolor.identifier) then
								self:drawTextBox("Upper color: " .. record.record.PersonAnalysisResult.uppercolor.identifier,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
								fieldsRecorded = fieldsRecorded + 1
							end
							if (record.record.PersonAnalysisResult.upperstyle and record.record.PersonAnalysisResult.upperstyle.identifier) then
								self:drawTextBox("Upper style: " .. record.record.PersonAnalysisResult.upperstyle.identifier,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
								fieldsRecorded = fieldsRecorded + 1
							end
							if (record.record.PersonAnalysisResult.lowercolor and record.record.PersonAnalysisResult.lowercolor.identifier) then
								self:drawTextBox("Lower color: " .. record.record.PersonAnalysisResult.lowercolor.identifier,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
								fieldsRecorded = fieldsRecorded + 1
							end
							if (record.record.PersonAnalysisResult.lowerstyle and record.record.PersonAnalysisResult.lowerstyle.identifier) then
								self:drawTextBox("Lower style: " .. record.record.PersonAnalysisResult.lowerstyle.identifier,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
								fieldsRecorded = fieldsRecorded + 1
							end
							if (record.record.PersonAnalysisResult.gender and record.record.PersonAnalysisResult.gender.identifier) then
								self:drawTextBox("Gender: " .. record.record.PersonAnalysisResult.gender.identifier,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
								fieldsRecorded = fieldsRecorded + 1
							end
						elseif (record.shape == "ocrtext") then
							self:drawTextBox(record.record.OCRResult.text,record.record.RectangleData.left + record.record.RectangleData.width,record.record.RectangleData.top, 80, rgb(255,255,255), record.colour)
						elseif (record.shape == "objclsrectext") then
							self:drawTextBox(record.record.ClassificationData.identifier,record.record.RectangleData.left,record.record.RectangleData.top, 80, rgb(255,255,255), record.colour)
						elseif (record.shape == "facedemographicstext") then
							local left = record.record.FaceData.ellipse.center.x + 1.05 * record.record.FaceData.ellipse.a
							local top = record.record.FaceData.ellipse.center.y - record.record.FaceData.ellipse.b
							local demographic
							if (record.record.DemographicsResult) then
								demographic = record.record.DemographicsResult
							elseif (record.record.DemographicsResultAndImage) then
								demographic = record.record.DemographicsResultAndImage
							end
							self:drawTextBox(demographic.gender,left,top, 60, rgb(255,255,255), record.colour)
							self:drawTextBox(demographic.age,left,top+60, 60, rgb(255,255,255), record.colour)
							self:drawTextBox(demographic.ethnicity,left,top+120, 60, rgb(255,255,255), record.colour)
						elseif (record.shape == "facerectext") then
							local left = record.record.FaceData.ellipse.center.x + 1.05 * record.record.FaceData.ellipse.a
							local top = record.record.FaceData.ellipse.center.y - record.record.FaceData.ellipse.b
							if (record.record.FaceRecognitionResult.identity and record.record.FaceRecognitionResult.identity.identifier) then
								self:drawTextBox(record.record.FaceRecognitionResult.identity.identifier,left,top+180, 60, rgb(255,255,255), record.colour)
							else
								self:drawTextBox("Unidentified",left,top+180, 60, rgb(255,255,255), record.colour)
							end
						end
					end
				end
				
				local function interpolateRectangle(pre, post, proportion1, proportion2)
					local left = proportion1 * pre.left + proportion2 * post.left
					local top = proportion1 * pre.top + proportion2 * post.top
					local width = proportion1 * pre.width + proportion2 * post.width
					local height = proportion1 * pre.height + proportion2 * post.height
					return {left=left, top=top, width=width, height=height}
				end
				
				local function interpolateEllipse(pre, post, proportion1, proportion2)
					local x = proportion1 * pre.center.x + proportion2 * post.center.x
					local y = proportion1 * pre.center.y + proportion2 * post.center.y
					local a = proportion1 * pre.a + proportion2 * post.a
					local b = proportion1 * pre.b + proportion2 * post.b
					return {center = { x=x, y=y }, a=a, b=b}
				end
				
				local function interpolateCircle(pre, post, proportion1, proportion2)
					local x = proportion1 * pre.center.x + proportion2 * post.center.x
					local y = proportion1 * pre.center.y + proportion2 * post.center.y
					local r = proportion1 * pre.radius + proportion2 * post.radius
					return { x=x, y=y, radius=r }
				end
				
				-- Polygons all have 4 points and consistent ordering
				local function interpolatePolygon(pre, post, proportion1, proportion2)
					local ret = {}
					for k,v in pairs(pre) do
						ret[k] = proportion1 * pre[k] + proportion2 * post[k]
					end
					return ret
				end
				
				local function drawInterpolated(pre, post)
					proportion2 = (self.frameTime - pre.srcPos) / (post.srcPos - pre.srcPos)
					proportion1 = 1 - proportion2
					if (pre.shape == "rectangle") then
						drawRectangle(interpolateRectangle(pre.record, post.record, proportion1, proportion2), 4, pre.colour)
					elseif (record.shape == "polygon") then
						drawPolygon(interpolatePolygon(pre.record, post.record, proportion1, proportion2), self.lineThickness, record.colour)
					elseif (pre.shape == "face") then
						drawEllipse(interpolateEllipse(pre.record.ellipse, post.record.ellipse, proportion1, proportion2), self.lineThickness, pre.colour)
						if (pre.record.lefteye and pre.record.righteye and post.record.lefteye and post.record.righteye) then
							newLeftEye = interpolateCircle(pre.record.lefteye, post.record.lefteye, proportion1, proportion2)
							newRightEye = interpolateCircle(pre.record.righteye, post.record.righteye, proportion1, proportion2)
							drawCircle(newLeftEye.x, newLeftEye.y, newLeftEye.radius, self.lineThickness, pre.colour)
							drawCircle(newRightEye.x, newRightEye.y, newRightEye.radius, self.lineThickness, pre.colour)
						end
					elseif (pre.shape == "objectrecogitiontext") then
						local newPoly = interpolatePolygon(pre.record.PolygonData, post.record.PolygonData, proportion1, proportion2)
						self:drawTextBox(pre.record.ObjectRecognitionResult.identity.identifier,newPoly.point[1].x,newPoly.point[1].y - 80, 80, rgb(255,255,255), record.colour)
					elseif (pre.shape == "numberplatetext") then
						local newPoly = interpolatePolygon(pre.record.PolygonData, post.record.PolygonData, proportion1, proportion2)
						self:drawTextBox(pre.record.NumberPlateResult.numberplate.plateread,newPoly.point[4].x,newPoly.point[4].y - 80, 80, rgb(255,255,255), record.colour)
					elseif (record.shape == "vehiclemodeltext") then
						local newRect = interpolateRectangle(pre.record.RectangleData, post.record.RectangleData, proportion1, proportion2)
						self:drawTextBox(pre.record.VehicleModelResult.identity.identifier,newRect.left,newRect.top, 80, rgb(255,255,255), record.colour)
					elseif (record.shape == "persontext") then
						local newRect = interpolateRectangle(pre.record.RectangleData, post.record.RectangleData, proportion1, proportion2)
						local fieldsRecorded = 0
						if (pre.record.PersonAnalysisResult.hatcolor and pre.record.PersonAnalysisResult.hatcolor.identifier) then
							self:drawTextBox("Hat color: " .. pre.record.PersonAnalysisResult.hatcolor.identifier,newRect.left + newRect.width,newRect.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
							fieldsRecorded = fieldsRecorded + 1
						end
						if (pre.record.PersonAnalysisResult.hatstyle and pre.record.PersonAnalysisResult.hatstyle.identifier) then
							self:drawTextBox("Hat style: " .. pre.record.PersonAnalysisResult.hatstyle.identifier,newRect.left + newRect.width,newRect.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
							fieldsRecorded = fieldsRecorded + 1
						end
						if (pre.record.PersonAnalysisResult.haircolor and pre.record.PersonAnalysisResult.haircolor.identifier) then
							self:drawTextBox("Hair color: " .. pre.record.PersonAnalysisResult.haircolor.identifier,newRect.left + newRect.width,newRect.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
							fieldsRecorded = fieldsRecorded + 1
						end
						if (pre.record.PersonAnalysisResult.hairstyle and pre.record.PersonAnalysisResult.hairstyle.identifier) then
							self:drawTextBox("Hair style: " .. pre.record.PersonAnalysisResult.hairstyle.identifier,newRect.left + newRect.width,newRect.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
							fieldsRecorded = fieldsRecorded + 1
						end
						if (pre.record.PersonAnalysisResult.facialhair and pre.record.PersonAnalysisResult.facialhair.identifier) then
							self:drawTextBox("Facial hair: " .. pre.record.PersonAnalysisResult.facialhair.identifier,newRect.left + newRect.width,newRect.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
							fieldsRecorded = fieldsRecorded + 1
						end
						if (pre.record.PersonAnalysisResult.uppercolor and pre.record.PersonAnalysisResult.uppercolor.identifier) then
							self:drawTextBox("Upper color: " .. pre.record.PersonAnalysisResult.uppercolor.identifier,newRect.left + newRect.width,newRect.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
							fieldsRecorded = fieldsRecorded + 1
						end
						if (pre.record.PersonAnalysisResult.upperstyle and pre.record.PersonAnalysisResult.upperstyle.identifier) then
							self:drawTextBox("Upper style: " .. pre.record.PersonAnalysisResult.upperstyle.identifier,newRect.left + newRect.width,newRect.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
							fieldsRecorded = fieldsRecorded + 1
						end
						if (pre.record.PersonAnalysisResult.lowercolor and pre.record.PersonAnalysisResult.lowercolor.identifier) then
							self:drawTextBox("Lower color: " .. pre.record.PersonAnalysisResult.lowercolor.identifier,newRect.left + newRect.width,newRect.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
							fieldsRecorded = fieldsRecorded + 1
						end
						if (pre.record.PersonAnalysisResult.lowerstyle and pre.record.PersonAnalysisResult.lowerstyle.identifier) then
							self:drawTextBox("Lower style: " .. pre.record.PersonAnalysisResult.lowerstyle.identifier,newRect.left + newRect.width,newRect.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
							fieldsRecorded = fieldsRecorded + 1
						end
						if (pre.record.PersonAnalysisResult.gender and pre.record.PersonAnalysisResult.gender.identifier) then
							self:drawTextBox("Gender: " .. pre.record.PersonAnalysisResult.gender.identifier,newRect.left + newRect.width,newRect.top + (80 * fieldsRecorded), 80, rgb(255,255,255), record.colour)
							fieldsRecorded = fieldsRecorded + 1
						end
					elseif (pre.shape == "ocrtext") then
						local newRect = interpolateRectangle(pre.record.RectangleData, post.record.RectangleData, proportion1, proportion2)
						self:drawTextBox(pre.record.OCRResult.text,newRect.left + newRect.width + 10,newRect.top, 80, rgb(255,255,255), pre.colour)
					elseif (pre.shape == "objclsrectext") then
						local newRect = interpolateRectangle(pre.record.RectangleData, post.record.RectangleData, proportion1, proportion2)
						self:drawTextBox(pre.record.ClassificationData.identifier,newRect.left,newRect.top, 80, rgb(255,255,255), pre.colour)
					elseif (pre.shape == "facedemographicstext") then
						local newEllipse = interpolateEllipse(pre.record.FaceData.ellipse, post.record.FaceData.ellipse, proportion1, proportion2)
						local left = newEllipse.center.x + 1.05 * newEllipse.a
						local top = newEllipse.center.y - newEllipse.b
						local demographic
						if (pre.record.DemographicsResult) then
							demographic = pre.record.DemographicsResult
						elseif (pre.record.DemographicsResultAndImage) then
							demographic = pre.record.DemographicsResultAndImage
						end
						self:drawTextBox(demographic.gender,left,top, 60, rgb(255,255,255), pre.colour)
						self:drawTextBox(demographic.age,left,top+60, 60, rgb(255,255,255), pre.colour)
						self:drawTextBox(demographic.ethnicity,left,top+120, 60, rgb(255,255,255), pre.colour)
					elseif (pre.shape == "facerectext") then
						local newEllipse = interpolateEllipse(pre.record.FaceData.ellipse, post.record.FaceData.ellipse, proportion1, proportion2)
						local left = newEllipse.center.x + 1.05 * newEllipse.a
						local top = newEllipse.center.y - newEllipse.b
						if (pre.record.FaceRecognitionResult.identity and pre.record.FaceRecognitionResult.identity.identifier) then
							self:drawTextBox(pre.record.FaceRecognitionResult.identity.identifier,left,top+180, 60, rgb(255,255,255), pre.colour)
						else
							self:drawTextBox("Unidentified",left,top+180, 60, rgb(255,255,255), pre.colour)
						end
					end
                end

				for id,records in pairs(self.toDraw) do
					draw(self, records.records)
                    if (#records.records == 0) then    
                        -- No results from this frame, interpolate from before and after if possible
                        pre = self.toDraw[id].latestPre
                        post = self.toDraw[id].earliestPost
                        if(pre ~= nil and post ~= nil) then
                            drawInterpolated(pre, post)
                        end
                    end
				end

				if self.toDrawNoID then
					draw(self, self.toDrawNoID.records)
				end
			end,
	
	drawTextBox = function(self, text, left, top, size, textColour, backgroundColour)
					if (tonumber(left) < 5) then
						left= 5
					end
					if (tonumber(top) < 25) then
						top = 25
					end
					drawText(text, left, top, "arial", size, textColour, backgroundColour)
				end,
	
	drawTable = function(self, record, colour)
					-- Draw the outline and gridlines of a table
				
					-- Draw the bounding box
					drawRectangle(record.region, self.lineThickness, colour)
					
					-- Calculate the vertical range of each row and horizontal range of each column
					local rows = {}
					local cols = {}
					local rr = 1
					while (record.row[rr]) do
						local column = 1  -- accumulate column index (adding up columnSpans)
						local cc = 1
						while (record.row[rr].cell[cc]) do
							local id = record.row[rr].cell[cc].OCRResultID
							-- The column spans from lc to rc inclusive
							local lc = column
							local rc = column + record.row[rr].cell[cc].columnSpan - 1
							if (id and self.toDraw[id.uuid]) then
								local ii = 1
								while (self.toDraw[id.uuid].records[ii]) do
									local rect = self.toDraw[id.uuid].records[ii].record
									
									-- Expand the current row range
									if rows[rr] then
										if rect.top < rows[rr].top then
											rows[rr].top = rect.top
										end
										if rect.top + rect.height > rows[rr].bottom  then
											rows[rr].bottom = rect.top + rect.height
										end
									else
										rows[rr] = { top=rect.top, bottom=rect.top + rect.height }
									end
									
									-- Expand the left edge of the range of column lc
									if not cols[lc] then
										cols[lc] = {}
									end
									if cols[lc].left then
										if rect.left < cols[lc].left then
											cols[lc].left = rect.left
										end
									else
										cols[lc].left=rect.left
									end
									
									-- Expand the right edge of the range of column rc
									if not cols[rc] then
										cols[rc] = {}
									end
									if cols[rc].right then
										if rect.left + rect.width > cols[rc].right then
											cols[rc].right = rect.left + rect.width
										end
									else
										cols[rc].right=rect.left + rect.width
									end
									
									ii = ii + 1
								end
							end
							cc = cc + 1
							column = rc + 1
						end
						rr = rr + 1
					end
					
					-- The gridlines are half the thickness of the bounding box
					local thickness = math.floor(self.lineThickness/2)
					if (thickness < 1) then
						thickness = 1
					end
					
					-- Draw the gridlines (midway between adjacent rows and columns)
					local rowLines = {}
					rr = 1
					while (rows[rr]) do
						-- Draw the row line between this and the row below
						if (rows[rr+1]) then
							local yy = math.floor((rows[rr].bottom + rows[rr+1].top) / 2)
							table.insert(rowLines, yy)
							drawLine(record.region.left, yy, record.region.left+record.region.width, yy, thickness, colour)
						end
						
						-- Get top and bottom of this row for drawing column lines
						local top = record.region.top
						if (rr > 1) then
							top = rowLines[rr-1]
						end
						local bottom = record.region.top + record.region.height
						if (rowLines[rr]) then
							bottom = rowLines[rr]
						end
						
						-- Draw the line to left of each cell
						cc = 1
						column = 1   -- accumulate column index (adding up columnSpans)
						while (record.row[rr].cell[cc]) do
							if(column > 1) then
								local xx = math.floor((cols[column-1].right + cols[column].left) / 2)
								drawLine(xx, top, xx, bottom, thickness, colour)
							end
							
							column = column + record.row[rr].cell[cc].columnSpan
							cc = cc + 1
						end
						
						rr = rr + 1
					end
				end
}

function draw(record)
	local resultsProcessor = ResultsProcessor:new({frameTime=getSourcePos(record)})
	resultsProcessor:findBestDetections(record)
	resultsProcessor:drawAll()
end
