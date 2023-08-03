if CLIENT then return end

hook.Add("Think", "Crouchjumpshit", function()
    for k,v in pairs(player.GetAll()) do
        if !v:OnGround() && v:IsFlagSet(6) then
            local nextpos = (v:GetVelocity() + physenv.GetGravity()) * engine.TickInterval()
            local pos = v:GetPos() + nextpos
            local smins, smaxs = v:GetHull()
            local cmins, cmaxs = v:GetHullDuck()
            local trh = util.TraceHull({
            start = pos,
            endpos = pos - Vector(0,0,smaxs.z),
            mins = cmins,
            maxs = cmaxs,
            mask = 33636363,
            filter = v})
            local trl = util.TraceLine({
            start = pos,
            endpos = pos - Vector(0,0,smaxs.z),
            mask = 33636363,
            filter = v})
            print(trh.Fraction, trl.Fraction)
            local total = math.Clamp(trh.Fraction + trl.Fraction, 0, 2) * 0.5 * -(smaxs.z-cmaxs.z)
            v:ManipulateBonePosition(0, Vector(0,0,total), true)
        else
            v:ManipulateBonePosition(0, Vector(0,0,0), true)
        end
    end
end)