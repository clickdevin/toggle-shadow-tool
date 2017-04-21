TOOL.Category   = 'Render'
TOOL.Name       = '#tool.shadow.name'

function TOOL.GetShadow(ent)
    return ent:GetNWBool('tst_shadow', true)
end

function TOOL.SetShadow(ply, ent, data)
    if not ent:IsValid() then return end

    ent:DrawShadow(data.tst_shadow)
    ent:SetNWBool('tst_shadow', data.tst_shadow)

    if SERVER then
        if not data.tst_shadow then
            duplicator.StoreEntityModifier(ent, 'tst_shadow', data)
        else
            duplicator.ClearEntityModifier(ent, 'tst_shadow')
        end
    end
end
duplicator.RegisterEntityModifier('tst_shadow', TOOL.SetShadow)

function TOOL:LeftClick(trace)
    if trace.Entity:IsValid() then
        self.SetShadow(self:GetOwner(), trace.Entity, {tst_shadow = false})
        return true
    end
end

function TOOL:RightClick(trace)
    if trace.Entity:IsValid() then
        self.SetShadow(self:GetOwner(), trace.Entity, {tst_shadow = true})
        return true
    end
end

function TOOL:Reload(trace)
    if trace.Entity:IsValid() then
        local state = self.GetShadow(trace.Entity)
        local ents = constraint.GetAllConstrainedEntities(trace.Entity)
        for k, v in pairs(ents) do
            self.SetShadow(self:GetOwner(), v, {tst_shadow = not state})
        end
        return true
    end
end

if CLIENT then
    language.Add('tool.shadow.name', 'Toggle Shadow')
    language.Add('tool.shadow.desc', 'Enable or disable the render-to-texture shadow of an object')
    language.Add('tool.shadow.left', 'Disable a shadow')
    language.Add('tool.shadow.right', 'Enable a shadow')
    language.Add('tool.shadow.reload', 'Toggle the shadow of every constrained object')
    language.Add('tool.shadow.disable_checkbox', 'Disable all shadows (clientside only)')

    TOOL.Information = {
        {name = 'left'},
        {name = 'right'},
        {name = 'reload'}
    }

    function TOOL.BuildCPanel(panel)
		panel:AddControl('Checkbox', {Label = '#tool.shadow.disable_checkbox', Command = 'tst_disableshadows'})
    end

    CreateClientConVar('tst_disableshadows', '0', false, false, 'If set to 1, disables all shadows clientside')
    cvars.AddChangeCallback('tst_disableshadows', function(name, old, new)
        -- This is a hacky solution, but render.SetEnableShadows seems to
        -- try to do something similar, except it also seems to be broken.
        if new == '1' then
            render.SetShadowDistance(-128)
        else
            render.SetShadowDistance(1024)
        end
    end)
end
