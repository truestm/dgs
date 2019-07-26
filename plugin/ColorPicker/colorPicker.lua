addEvent("onDgsColorPickerChange",true)
addEvent("onDgsColorPickerComponentSelectorChange",true)

function dgsCreateColorPicker(style,...)
	assert(type(style) == "string","Bad argument @dgsCreateColorPicker at argument 1, expect a string got "..type(style))
	local args = {...}
	if style == "HSVRing" then
		local x,y,w,h,relative,parent = args[1],args[2],args[3],args[4],args[5],args[6]
		local HSVRing = dxCreateShader("plugin/ColorPicker/HSVRing.fx")
		local HSVRingImg = dgsCreateImage(x,y,w,h,HSVRing,relative or false,parent)
		dgsSetData(HSVRingImg,"asPlugin","dgs-dxcolorpicker")
		local HSVRingSel = dxCreateShader("plugin/ColorPicker/HSVRingSel.fx")	--The triangle
		local HSVRingSelImg = dgsCreateImage(0.1,0.1,0.8,0.8,HSVRingSel,true,HSVRingImg)
		dgsSetEnabled(HSVRingSelImg,false)
		local PickCircle = dxCreateShader("plugin/ColorPicker/PickCircle.fx")
		local PickCircleImg = dgsCreateImage(0,0,0.06,0.06,PickCircle,true,HSVRingSelImg)
		dgsSetEnabled(PickCircleImg,false)
		dgsAddMoveHandler(PickCircleImg)
		dgsSetData(HSVRingImg,"cp_shaders",{HSVRing,HSVRingSel,PickCircle})
		dgsSetData(HSVRingImg,"cp_images",{HSVRingImg,HSVRingSelImg,PickCircleImg})
		addEventHandler("onDgsCursorDrag",HSVRingImg,HSVRingChange,false)
		addEventHandler("onDgsMouseClickDown",HSVRingImg,HSVRingChange,false)
		dgsSetData(HSVRingImg,"style",style)
		dgsColorPickerSetColor(HSVRingImg,0,0,255,255)
		addEventHandler("onDgsDestroy",HSVRingImg,function()
			for k,v in ipairs(dgsElementData[source].cp_shaders) do
				if isElement(v) then
					destroyElement(v)
				end
			end
		end,false)
		return HSVRingImg
	elseif style == "HSLSquare" then
		local x,y,w,h,relative,parent = args[1],args[2],args[3],args[4],args[5],args[6]
		local HSLSquare = dxCreateShader("plugin/ColorPicker/HSLSquare.fx")
		local HSLSquareImg = dgsCreateImage(x,y,w,h,HSLSquare,relative or false,parent)
		dgsSetData(HSLSquareImg,"asPlugin","dgs-dxcolorpicker")
		local PickCircle = dxCreateShader("plugin/ColorPicker/PickCircle.fx")
		local PickCircleImg = dgsCreateImage(0,0,0.06,0.06,PickCircle,true,HSLSquareImg)
		dgsSetEnabled(PickCircleImg,false)
		dgsAddMoveHandler(PickCircleImg)
		dgsSetData(HSLSquareImg,"cp_shaders",{HSLSquare,PickCircle})
		dgsSetData(HSLSquareImg,"cp_images",{HSLSquareImg,PickCircleImg})
		addEventHandler("onDgsCursorDrag",HSLSquareImg,HSLSquareChange,false)
		addEventHandler("onDgsMouseClickDown",HSLSquareImg,HSLSquareChange,false)
		dgsSetData(HSLSquareImg,"style",style)
		dgsColorPickerSetColor(HSLSquareImg,0,0,255,255)
		addEventHandler("onDgsDestroy",HSLSquareImg,function()
			for k,v in ipairs(dgsElementData[source].cp_shaders) do
				if isElement(v) then
					destroyElement(v)
				end
			end
		end,false)
		return HSLSquareImg
	else
		assert(false,"Bad argument @dgsCreateColorPicker at argument 1, unsupported type "..style)
	end
	return false
end

function dgsColorPickerCreateComponentSelector(x,y,w,h,voh,relative,parent,thickness,offset)
	local shader,selector,cs
	thickness = thickness or 2
	offset = offset or 4
	if voh then
		cs = dgsCreateImage(x,y,w,h,_,relative,parent)
		selector = dgsCreateImage(0,-offset,thickness,h+offset*2,_,false,cs)
	else
		cs = dgsCreateImage(x,y,w,h,_,relative,parent)
		selector = dgsCreateImage(-offset,0,w+offset*2,thickness,_,false,cs)
	end
	dgsSetEnabled(selector,false)
	dgsSetData(cs,"thickness",thickness)
	dgsSetData(cs,"offset",offset)
	dgsSetData(cs,"asPlugin","dgs-dxcomponentselector")
	dgsSetData(cs,"voh",voh)
	dgsSetData(cs,"cp_images",{cs,selector})
	dgsSetData(cs,"value",0)	--0~100
	addEventHandler("onDgsCursorDrag",cs,ComponentChange,false)
	addEventHandler("onDgsMouseClickDown",cs,ComponentChange,false)
	addEventHandler("onDgsSizeChange",cs,ComponentResize,false)
	addEventHandler("onDgsDestroy",cs,function()
		if isElement(dgsElementData[source].cp_shader) then
			destroyElement(dgsElementData[source].cp_shader)
		end
	end,false)
	return cs
end

function dgsComponentSelectorSetCursorThickness(cs,thickness)
	local csTyp = dgsGetPluginType(cs) or dgsGetType(cs)
	assert(csTyp == "dgs-dxcomponentselector","Bad argument @dgsComponentSelectorSetCursorThickness at argument 1, expect a dgs-dxcomponentselector plugin, got "..csTyp)
	return dgsSetData(cs,"thickness",thickness)
end

function dgsComponentSelectorGetCursorThickness(cs)
	local csTyp = dgsGetPluginType(cs) or dgsGetType(cs)
	assert(csTyp == "dgs-dxcomponentselector","Bad argument @dgsComponentSelectorGetCursorThickness at argument 1, expect a dgs-dxcomponentselector plugin, got "..csTyp)
	return dgsElementData[cs].thickness
end

function ComponentResize()
	local thickness = dgsElementData[source].thickness
	local offset =  dgsElementData[source].offset
	local voh = dgsElementData[source].voh
	local value = dgsElementData[source].value
	local absSize = dgsElementData[source].absSize
	local images = dgsElementData[source].cp_images
	local position
	if voh then
		position = value*absSize[1]/100
		dgsSetPosition(images[2],position-thickness/2,-offset,false)
	else
		position = value*absSize[2]/100
		dgsSetPosition(images[2],-offset,position-thickness/2,false)
	end
end

function ComponentChange()
	local cx,cy = dgsGetCursorPosition(source)
	local absSize = dgsElementData[source].absSize
	local voh = dgsElementData[source].voh
	local absSize = dgsElementData[source].absSize
	local position
	if voh then
		position = cx/absSize[1]*100
	else
		position = cy/absSize[2]*100
	end
	dgsColorPickerSetComponentSelectorValue(source,position)
end


function dgsColorPickerGetComponentSelectorValue(cs)
	local csTyp = dgsGetPluginType(cs) or dgsGetType(cs)
	assert(csTyp == "dgs-dxcomponentselector","Bad argument @dgsColorPickerGetComponentSelectorValue at argument 1, expect a dgs-dxcomponentselector plugin, got "..csTyp)
	return dgsElementData[cs].value
end

function dgsColorPickerSetComponentSelectorValue(cs,value)
	local csTyp = dgsGetPluginType(cs) or dgsGetType(cs)
	assert(csTyp == "dgs-dxcomponentselector","Bad argument @dgsColorPickerSetComponentSelectorValue at argument 1, expect a dgs-dxcomponentselector plugin, got "..csTyp)
	assert(type(value) == "number","Bad argument @dgsColorPickerSetComponentSelectorValue at argument 2, expect a number, got "..type(value))
	local thickness = dgsElementData[cs].thickness
	local offset =  dgsElementData[cs].offset
	local voh = dgsElementData[cs].voh
	local oldV = dgsElementData[cs].value
	local value = math.restrict(value,0,100)
	dgsSetData(cs,"value",value)
	local absSize = dgsElementData[cs].absSize
	local images = dgsElementData[cs].cp_images
	local position
	if voh then
		position = value*absSize[1]/100
		dgsSetPosition(images[2],position-thickness/2,-offset,false)
	else
		position = value*absSize[2]/100
		dgsSetPosition(images[2],-offset,position-thickness/2,false)
	end
	triggerEvent("onDgsColorPickerComponentSelectorChange",cs,value,oldV)
end

--dgsBindToColorPicker(edit,colorPicker,"HSL","H")
AvailableColorType = {
	RGB={R={1,255},G={2,255},B={3,255}},
	HSL={H={1,360},S={2,100},L={3,100}},
	HSV={H={1,360},S={2,100},V={3,100}},
}
ColorAttributeOrder = {
	RGB={"R","G","B"},
	HSL={"H","S","L"},
	HSV={"H","S","V"},
}
function dgsBindToColorPicker(show,colorPicker,colorType,colorAttribute,staticMode)
	assert(dgsIsDxElement(show),"Bad argument @dgsBindToColorPicker at argument 1, expect a dgs-dxgui plugin, got "..dgsGetType(show))
	local cpTyp = dgsGetPluginType(colorPicker) or dgsGetType(colorPicker)
	assert(cpTyp == "dgs-dxcolorpicker","Bad argument @dgsBindToColorPicker at argument 2, expect a dgs-dxcolorpicker plugin, got "..cpTyp)
	if colorAttribute ~= "A" then
		assert(AvailableColorType[colorType],"Bad argument @dgsBindToColorPicker at argument 3, only RGB/HSL/HSV supported, got "..tostring(colorType))
		assert(AvailableColorType[colorType][colorAttribute],"Bad argument @dgsBindToColorPicker at argument 3, attribute "..tostring(colorAttribute).." doesn't exist in "..colorType)
	end
	local targetType = dgsGetType(show)
	local targetPlugin = dgsGetPluginType(show)
	dgsSetData(show,"bindColorPicker",colorPicker)
	if targetPlugin == "dgs-dxcomponentselector" then
		local shader = dgsElementData[show].shader
		if isElement(shader) then destroyElement(shader) return end
		if colorAttribute == "A" then
			local ALPComponent = dxCreateShader("plugin/ColorPicker/ALPComponent.fx")
			dgsSetData(show,"shader",ALPComponent)
			dgsImageSetImage(show,ALPComponent)
		elseif colorType == "RGB" then
			local RGBComponent = dxCreateShader("plugin/ColorPicker/RGBComponent.fx")
			dgsSetData(show,"shader",RGBComponent)
			local colorID = AvailableColorType[colorType][colorAttribute][1]
			local RGBCHG = {0,0,0}
			RGBCHG[colorID] = 1
			dgsImageSetImage(show,RGBComponent)
			dxSetShaderValue(RGBComponent,"RGB_Chg",RGBCHG)
			if staticMode then
				dxSetShaderValue(RGBComponent,"StaticMode",{0,0,0})
			else
				dxSetShaderValue(RGBComponent,"StaticMode",{1,1,1})
			end
		elseif colorType == "HSL" then
			local HSLComponent = dxCreateShader("plugin/ColorPicker/HSLComponent.fx")
			dgsSetData(show,"shader",HSLComponent)
			dgsImageSetImage(show,HSLComponent)
			local colorID = AvailableColorType[colorType][colorAttribute][1]
			local HSLCHG = {0,0,0}
			HSLCHG[colorID] = 1
			dxSetShaderValue(HSLComponent,"HSL_Chg",HSLCHG)
			if staticMode then
				dxSetShaderValue(HSLComponent,"StaticMode",{1,0,0})
			else
				dxSetShaderValue(HSLComponent,"StaticMode",{1,1,1})
			end
		elseif colorType == "HSV" then
			local HSVComponent = dxCreateShader("plugin/ColorPicker/HSVComponent.fx")
			dgsSetData(show,"shader",HSVComponent)
			dgsImageSetImage(show,HSVComponent)
			local colorID = AvailableColorType[colorType][colorAttribute][1]
			local HSVCHG = {0,0,0}
			HSVCHG[colorID] = 1
			dxSetShaderValue(HSVComponent,"HSV_Chg",HSVCHG)
			if staticMode then
				dxSetShaderValue(HSVComponent,"StaticMode",{1,0,0})
			else
				dxSetShaderValue(HSVComponent,"StaticMode",{1,1,1})
			end
		end
		local function tempColorChange()
			if not setCool then
				local cp = _DGSColorPicker
				local show = _DGSShowElement
				local colorType = _colorType
				local colorAttribute = _colorAttribute
				if colorAttribute == "A" then
					setCool = true
					dgsColorPickerSetComponentSelectorValue(show,dgsElementData[cp].A/255*100)
					local shader = dgsElementData[show].shader
					local R,G,B = dgsColorPickerGetColor(cp,"RGB")
					dxSetShaderValue(shader,"currentColor",{R/255,G/255,B/255,1})
					setCool = false
					return
				end
				local attrID = AvailableColorType[colorType][colorAttribute][1]
				setCool = true
				local val = dgsElementData[cp][colorType][attrID]/AvailableColorType[colorType][colorAttribute][2]*100
				dgsColorPickerSetComponentSelectorValue(show,val)
				setCool = false
			end
			local shader = dgsElementData[show].shader
			local X,Y,Z = dgsColorPickerGetColor(cp,colorType)
			local ScaleX = AvailableColorType[colorType][ColorAttributeOrder[colorType][1]][2]
			local ScaleY = AvailableColorType[colorType][ColorAttributeOrder[colorType][2]][2]
			local ScaleZ = AvailableColorType[colorType][ColorAttributeOrder[colorType][3]][2]
			dxSetShaderValue(shader,colorType,{X/ScaleX,Y/ScaleY,Z/ScaleZ,1})
		end
		local function tempScPosChange()
			if setCool then return end
			local cp = _DGSColorPicker
			local show = _DGSShowElement
			local colorType = _colorType
			local colorAttribute = _colorAttribute
			local value = dgsColorPickerGetComponentSelectorValue(show)/100
			if value then
				if colorAttribute == "A" then
					setCool = true
					dgsColorPickerSetColor(cp,_,_,_,value,colorType)
					setCool = false
					return
				end
				value = AvailableColorType[colorType][colorAttribute][2]*value
				if colorType == "RGB" then
					local RGB = {R=nil,G=nil,B=nil}
					RGB[colorAttribute] = value
					setCool = true
					dgsColorPickerSetColor(cp,RGB.R,RGB.G,RGB.B,_,colorType)
					setCool = false
				elseif colorType == "HSL" then
					local HSL = {H=nil,S=nil,L=nil}
					HSL[colorAttribute] = value
					setCool = true
					dgsColorPickerSetColor(cp,HSL.H,HSL.S,HSL.L,_,colorType)
					setCool = false
				elseif colorType == "HSV" then
					local HSV = {H=nil,S=nil,V=nil}
					HSV[colorAttribute] = value
					setCool = true
					dgsColorPickerSetColor(cp,HSV.H,HSV.S,HSV.V,_,colorType)
					setCool = false
				end
			end
		end
		local newEnv = {_DGSShowElement=show,_DGSColorPicker=colorPicker,_colorType=colorType,_colorAttribute=colorAttribute}
		setmetatable(newEnv,{__index=_G})
		setfenv(tempColorChange,newEnv)
		setfenv(tempScPosChange,newEnv)
		addEventHandler("onDgsColorPickerChange",colorPicker,tempColorChange)
		addEventHandler("onDgsColorPickerComponentSelectorChange",show,tempScPosChange)
		dgsElementData[show].bindColorPicker_Fnc1 = tempColorChange
		dgsElementData[show].bindColorPicker_Fnc2 = tempScPosChange
		tempColorChange()
	elseif targetType == "dgs-dxscrollbar" then
		local function tempColorChange()
			if setCool then return end
			local cp = _DGSColorPicker
			local show = _DGSShowElement
			local colorType = _colorType
			local colorAttribute = _colorAttribute
			if colorAttribute == "A" then
				setCool = true
				dgsScrollBarSetScrollPosition(show,dgsElementData[cp].A/255*100)
				setCool = false
				return
			end
			local attrID = AvailableColorType[colorType][colorAttribute][1]
			setCool = true
			local val = dgsElementData[cp][colorType][attrID]/AvailableColorType[colorType][colorAttribute][2]*100
			dgsScrollBarSetScrollPosition(show,val)
			setCool = false
		end
		local function tempScPosChange()
			if setCool then return end
			local cp = _DGSColorPicker
			local show = _DGSShowElement
			local colorType = _colorType
			local colorAttribute = _colorAttribute
			local value = dgsScrollBarGetScrollPosition(show)/100
			if value then
				if colorAttribute == "A" then
					setCool = true
					dgsColorPickerSetColor(cp,_,_,_,value,colorType)
					setCool = false
					return
				end
				value = AvailableColorType[colorType][colorAttribute][2]*value
				if colorType == "RGB" then
					local RGB = {R=nil,G=nil,B=nil}
					RGB[colorAttribute] = value
					setCool = true
					dgsColorPickerSetColor(cp,RGB.R,RGB.G,RGB.B,_,colorType)
					setCool = false
				elseif colorType == "HSL" then
					local HSL = {H=nil,S=nil,L=nil}
					HSL[colorAttribute] = value
					setCool = true
					dgsColorPickerSetColor(cp,HSL.H,HSL.S,HSL.L,_,colorType)
					setCool = false
				elseif colorType == "HSV" then
					local HSV = {H=nil,S=nil,V=nil}
					HSV[colorAttribute] = value
					setCool = true
					dgsColorPickerSetColor(cp,HSV.H,HSV.S,HSV.V,_,colorType)
					setCool = false
				end
			end
		end
		local newEnv = {_DGSShowElement=show,_DGSColorPicker=colorPicker,_colorType=colorType,_colorAttribute=colorAttribute}
		setmetatable(newEnv,{__index=_G})
		setfenv(tempColorChange,newEnv)
		setfenv(tempScPosChange,newEnv)
		addEventHandler("onDgsColorPickerChange",colorPicker,tempColorChange)
		addEventHandler("onDgsScrollBarScrollPositionChange",show,tempScPosChange)
		dgsElementData[show].bindColorPicker_Fnc1 = tempColorChange
		dgsElementData[show].bindColorPicker_Fnc2 = tempScPosChange
		tempColorChange()
	elseif targetType == "dgs-dxlabel" or targetType == "dgs-dxedit" then
		local function tempColorChange()
			if setCool then return end
			local cp = _DGSColorPicker
			local show = _DGSShowElement
			local colorType = _colorType
			local colorAttribute = _colorAttribute
			print(colorAttribute)
			if colorAttribute == "A" then
				setCool = true
				dgsSetText(show,tostring(math.floor(dgsElementData[cp].A)))
				setCool = false
				return
			end
			local attrID = AvailableColorType[colorType][colorAttribute][1]
			setCool = true
			print(dgsGetType(cp))
			dgsSetText(show,tostring(math.floor(dgsElementData[cp][colorType][attrID])))
			setCool = false
		end
		local function tempTextChange()
			if setCool then return end
			local cp = _DGSColorPicker
			local show = _DGSShowElement
			local colorType = _colorType
			local colorAttribute = _colorAttribute
			local value = tonumber(dgsGetProperty(show,changeProperty or "text"))
			if value then
				if colorAttribute == "A" then
					setCool = true
					dgsColorPickerSetColor(cp,_,_,_,value,colorType)
					setCool = false
					return
				end
				if colorType == "RGB" then
					local RGB = {R=nil,G=nil,B=nil}
					RGB[colorAttribute] = value
					setCool = true
					dgsColorPickerSetColor(cp,RGB.R,RGB.G,RGB.B,_,colorType)
					setCool = false
				elseif colorType == "HSL" then
					local HSL = {H=nil,S=nil,L=nil}
					HSL[colorAttribute] = value
					setCool = true
					dgsColorPickerSetColor(cp,HSL.H,HSL.S,HSL.L,_,colorType)
					setCool = false
				elseif colorType == "HSV" then
					local HSV = {H=nil,S=nil,V=nil}
					HSV[colorAttribute] = value
					setCool = true
					dgsColorPickerSetColor(cp,HSV.H,HSV.S,HSV.V,_,colorType)
					setCool = false
				end
			end
		end
		local newEnv = {_DGSShowElement=show,_DGSColorPicker=colorPicker,_colorType=colorType,_colorAttribute=colorAttribute}
		setmetatable(newEnv,{__index=_G})
		setfenv(tempColorChange,newEnv)
		setfenv(tempTextChange,newEnv)
		addEventHandler("onDgsColorPickerChange",colorPicker,tempColorChange)
		addEventHandler("onDgsTextChange",show,tempTextChange)
		dgsElementData[show].bindColorPicker_Fnc1 = tempColorChange
		dgsElementData[show].bindColorPicker_Fnc2 = tempTextChange
		tempColorChange()
	else	
		assert(false,"Bad argument at argument 1, unsupported type "..targetType)
	end
end

function dgsUnbindFromColorPicker(show)
	local bound = dgsElementData[show].bindColorPicker
	if bound then
		local tempColorChange = dgsElementData[show].bindColorPicker_Fnc1
		local tempTextChange = dgsElementData[show].bindColorPicker_Fnc2
		removeEventHandler("onDgsColorPickerChange",colorPicker,tempColorChange)
		removeEventHandler("onDgsTextChange",show,tempTextChange)
		dgsElementData[show].bindColorPicker = nil
		dgsElementData[show].bindColorPicker_Fnc1 = nil
		dgsElementData[show].bindColorPicker_Fnc2 = nil
		return true
	end
	return false
end

function dgsColorPickerUpdate(cp)
	local shaders = dgsElementData[cp].cp_shaders
	local images = dgsElementData[cp].cp_images
	local style = dgsElementData[cp].style
	if style == "HSVRing" then
		dxSetShaderValue(shaders[2],"Hue",dgsElementData[cp].HSV[1]/360)
		local pAbsSize = dgsElementData[ images[2] ].absSize
		local absSize = dgsElementData[ images[3] ].absSize
		local x,y = dgsProjectHSVToXY(dgsElementData[cp].HSV[1],dgsElementData[cp].HSV[2],dgsElementData[cp].HSV[3])
		local x,y = x-absSize[1]/pAbsSize[1]/2,y-absSize[2]/pAbsSize[2]/2
		dgsSetPosition(images[3],x,y,true)
	elseif style == "HSLSquare" then
		local pAbsSize = dgsElementData[ images[1] ].absSize
		local absSize = dgsElementData[ images[2] ].absSize
		local x,y = HSToXY(dgsElementData[cp].HSL[1],dgsElementData[cp].HSL[2])
		local x,y = x-absSize[1]/pAbsSize[1]/2,y-absSize[2]/pAbsSize[2]/2
		dgsSetPosition(images[2],x,y,true)
	end
end

function dgsColorPickerSetColor(cp,...)
	local args = {...}
	local newColorRGB,newColorHSL,newColorHSV
	args[5] = args[5] or "RGB"
	if args[5] == "HSL" then
		local color = dgsElementData[cp].HSL
		local h,s,l = args[1] or color[1] or 360,args[2] or color[2] or 100,args[3] or color[3] or 100
		h = math.restrict(h,0,360)
		s = math.restrict(s,0,100)
		l = math.restrict(l,0,100)
		newColorRGB = {HSL2RGB(h,s,l)}
		newColorHSL = {h,s,l}
		newColorHSV = {HSL2HSV(h,s,l)}
	elseif args[5] == "HSV" then
		local color = dgsElementData[cp].HSV
		local h,s,v = args[1] or color[1] or 360,args[2] or color[2] or 100,args[3] or color[3] or 100
		h = math.restrict(h,0,360)
		s = math.restrict(s,0,100)
		v = math.restrict(v,0,100)
		newColorRGB = {HSV2RGB(h,s,v)}
		newColorHSV = {h,s,v}
		newColorHSL = {HSV2HSL(h,s,v)}
	elseif args[5] == "RGB" then
		local color = dgsElementData[cp].RGB
		local r,g,b = args[1] or color[1] or 255,args[2] or color[2] or 255,args[3] or color[3] or 255
		r = math.restrict(r,0,255)
		g = math.restrict(g,0,255)
		b = math.restrict(b,0,255)
		newColorRGB = {r,g,b}
		newColorHSL = {RGB2HSL(r,g,b)}
		newColorHSV = {HSL2HSV(newColorHSL[1],newColorHSL[2],newColorHSL[3])}
	end
	local oldRGB = dgsElementData[cp].RGB
	local oldHSL = dgsElementData[cp].HSL
	local oldHSV = dgsElementData[cp].HSV
	local oldAlp = dgsElementData[cp].A
	newA = args[4] or dgsElementData[cp].A or 255
	dgsSetData(cp,"HSL",newColorHSL)
	dgsSetData(cp,"HSV",newColorHSV)
	dgsSetData(cp,"RGB",newColorRGB)
	dgsSetData(cp,"A",newA)
	triggerEvent("onDgsColorPickerChange",cp,oldRGB,oldHSL,oldHSV,oldAlp)
	dgsColorPickerUpdate(cp)
end

function dgsColorPickerGetColor(cp,mode)
	mode = mode or "RGB"
	local COLOR = dgsElementData[cp][mode] or {}
	local A = dgsElementData[cp].A or false
	COLOR[1] = COLOR[1] and COLOR[1]-COLOR[1]%1 or false
	COLOR[2] = COLOR[2] and COLOR[2]-COLOR[2]%1 or false
	COLOR[3] = COLOR[3] and COLOR[3]-COLOR[3]%1 or false
	A = A and A-A%1 or false
	return COLOR[1],COLOR[2],COLOR[3],A
end

---------------------HSLCircle Color Picker
function HSLSquareChange()
	local cx,cy = dgsGetCursorPosition(source)
	local absSize = dgsElementData[source].absSize
	local H,S = XYToHS(cx/absSize[1],cy/absSize[2])
	dgsColorPickerSetColor(source,H,S,_,_,"HSL")
end

function HSToXY(H,S)
	return H/360,1-S/100
end

function XYToHS(X,Y)
	local H,S = X*360,Y*100
	return H-H%1,100-(S-S%1)
end
---------------------HSVRing Color Picker
function HSVRingChange()
	local cx,cy = dgsGetCursorPosition()
	if eventName == "onDgsMouseClickDown" then
		local rot,CenDisX,CenDisY = dgsFindRotationByCenter(source,cx,cy,90)
		local clickRadius = (CenDisX^2+CenDisY^2)^0.5
		dgsSetData(source,"clickRadius",clickRadius)
		if clickRadius >= 0.4 and clickRadius <= 0.5 then
			dgsColorPickerSetColor(source,rot,_,_,_,"HSV")
		elseif clickRadius< 0.4 then
			local HSV = dgsElementData[source].HSV
			local S,V = dgsProjectHXYToSV(HSV[1],CenDisX,CenDisY)
			dgsColorPickerSetColor(source,_,S,V,_,"HSV")
		end
	else
		local clickRadius = dgsElementData[source].clickRadius or 1
		if clickRadius >= 0.4 and clickRadius <= 0.5 then
			local rot = dgsFindRotationByCenter(source,cx,cy,90)
			dgsColorPickerSetColor(source,rot,_,_,_,"HSL")
		elseif clickRadius< 0.4 then
			local rot,CenDisX,CenDisY = dgsFindRotationByCenter(source,cx,cy,90)
			local HSV = dgsElementData[source].HSV
			local S,V = dgsProjectHXYToSV(HSV[1],CenDisX,CenDisY)
			dgsColorPickerSetColor(source,_,S,V,_,"HSV")
		end
	end
end

function dgsProjectHSVToXY(H,S,V)
	local H = math.rad(H+180)
	local S,V = S/100,V/100
	y = (6*V-3-3*V*S)/2/math.sqrt(3)/2
	x = (1-3*V*S)/2/2
	local rotedi = {math.cos(H),math.sin(H)}
	local rotedj = {math.cos(H-math.rad(90)),math.sin(H-math.rad(90))}
	local x,y = x*rotedi[1]+y*rotedi[2],x*rotedj[1]+y*rotedj[2]
	return x+0.5,y+0.5
end

function dgsProjectHXYToSV(H,x,y)
	local H = math.rad(H+180)
	local rotedi = {math.cos(H-math.rad(90)),math.sin(H-math.rad(90))}
	local rotedj = {math.cos(H),math.sin(H)}
	local x,y = x*rotedi[1]+y*rotedi[2],x*rotedj[1]+y*rotedj[2]
	x,y = x/0.4,y/0.4
	local S,V = (1-2*y)/(math.sqrt(3)*x-y+2)*100,(math.sqrt(3)*x-y+2)/3*100
	return S-S%1,V-V%1
end

----Output Functions
function dgsHSLToHSV(H,S,L,A)
	local _H,_S,_V = HSL2HSV(H,S,L)
	return _H,_S,_V,A
end

function dgsHSVToHSL(H,S,V,A)
	local _H,_S,_L = HSV2HSL(H,S,V)
	return _H,_S,_L,A
end

function dgsHSLToRGB(H,S,L,A)
	local R,G,B = HSL2RGB(H,S,L)
	return R,G,B,A
end

function dgsHSVToRGB(H,S,V,A)
	local R,G,B = HSV2RGB(H,S,V)
	return R,G,B,A
end

function dgsRGBToHSL(R,G,B,A)
	local H,S,L = RGB2HSV(R,G,B)
	return H,S,L,A
end

function dgsRGBToHSV(R,G,B,A)
	local H,S,V = RGB2HSV(R,G,B)
	return H,S,V,A
end