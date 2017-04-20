TOOL.Category = "Render"
TOOL.Name = "#tool.shadow.name"
TOOL.Command = nil
TOOL.ConfigName = nil

if CLIENT then
	language.Add("tool.shadow.name", "Toggle Shadow")
	language.Add("tool.shadow.desc", "Enable or disable the render-to-texture shadow of an object")
	language.Add("tool.shadow.left", "Disable a shadow")
	language.Add("tool.shadow.right", "Enable a shadow")
	language.Add("tool.shadow.reload", "Toggle the shadow of every constrained object")
	language.Add("tool.shadow.color", "Shadow Distance")

	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
		{ name = "reload" }
	}
end

if game.MaxPlayers() == 1 then
	CreateConVar("tst_shadowdist", 1000)
	hook.Add("Think", "shadowdistcalc", function()
		RunConsoleCommand("r_shadowdist", GetConVar("tst_shadowdist"):GetInt())
	end)
end

local function SetShadow(Player, Entity, Data)
	if not SERVER then return end
	if Data.Shadow ~= nil then
		if Entity:IsValid() then Entity:DrawShadow(Data.Shadow) end
	end
	duplicator.StoreEntityModifier(Entity, "shadow", Data)
end
duplicator.RegisterEntityModifier("shadow", SetShadow)

function TOOL:LeftClick(trace)
	if trace.Entity:IsValid() then
		SetShadow(self:GetOwner(), trace.Entity, {Shadow = false})
		return true
	end
end

function TOOL:RightClick(trace)
	if trace.Entity:IsValid() then
		SetShadow(self:GetOwner(), trace.Entity, {Shadow = true})
		return true
	end
end

function TOOL:Reload(trace)
	if trace.Entity:IsValid() then
		local constraints = constraint.GetAllConstrainedEntities(trace.Entity)
		for k, v in pairs(constraints) do
			SetShadow(self:GetOwner(), v, {Shadow = false})
		end
		return true
	end
end

function TOOL.BuildCPanel(panel)
	if game.MaxPlayers() == 1 then
		local DistSlider = vgui.Create("DNumSlider")
			DistSlider:SetText("#tool.shadow.color")
			DistSlider:SetMin(-128)
			DistSlider:SetMax(1024)
			DistSlider:SetDecimals(0)
			DistSlider:SetConVar("tst_shadowdist")
		panel:AddItem(DistSlider)
	end
end