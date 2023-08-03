AddCSLuaFile()

hook.Add("FinishMove", "Crouchjumpshit", function(ply, mv)
    -- for k,v in pairs(player.GetAll()) do
        if !ply:OnGround() && ply:IsFlagSet(6) then
            local nextpos = (ply:GetVelocity() + physenv.GetGravity()) * engine.TickInterval()
            local pos = ply:GetPos() + nextpos
            local smins, smaxs = ply:GetHull()
            local cmins, cmaxs = ply:GetHullDuck()
            local trh = util.TraceHull({
            start = pos,
            endpos = pos - Vector(0,0,smaxs.z),
            mins = cmins,
            maxs = cmaxs,
            mask = 33636363,
            filter = ply})
            local trl = util.TraceLine({
            start = pos,
            endpos = pos - Vector(0,0,smaxs.z),
            mask = 33636363,
            filter = ply})
            print(trh.Fraction, trl.Fraction)
            local total = Lerp((trh.Fraction + trl.Fraction) * 0.5, 0, -cmaxs.z)
            ply:ManipulateBonePosition(0, Vector(0,0,total), false)
        else
            ply:ManipulateBonePosition(0, Vector(0,0,0), false)
        end
    -- end
end)