AddCSLuaFile()

local sp = game.SinglePlayer()
hook.Add("SetupMove", "Crouchjumpshit", function(ply, mv, cmd)
    if CLIENT && !IsFirstTimePredicted() then return end
    if !ply:OnGround() && ply:IsFlagSet(2) then
        local nextpos = (mv:GetVelocity()) * FrameTime()
        local pos = ply:GetPos()
        -- local smins, smaxs = ply:GetHull()
        -- local cmins, cmaxs = ply:GetHullDuck()
        local tr = {}
        tr.start = pos
        tr.endpos = pos + Vector(0,0,-36)
        tr.mask = MASK_SOLID
        tr.filter = ply
        local trh = util.TraceEntity(tr, ply)
        -- local trl = util.TraceLine(tr)
        -- print(trh.Fraction, trl.Fraction)
        local total = Lerp(trh.Fraction, 0, -36)
        ply:ManipulateBonePosition(0, Vector(0,0,total), sp)
        -- ply:ManipulateBonePosition(0, Vector(0,0,total), sp)
    else
        ply:ManipulateBonePosition(0, Vector(0,0,0), sp)
    end
end)

if SERVER then
    hook.Add("DoPlayerDeath", "GiveAmmoOnKill", function(killed, ply, dmginfo)
        if !IsValid(ply) || !ply:IsPlayer() || ply == killed then return end
        local at, wep = dmginfo:GetAmmoType(), dmginfo:GetInflictor()
        if at == -1 then return end
        local ammo = math.max(wep:IsWeapon() && wep:GetMaxClip1() || ply:GetActiveWeapon():GetMaxClip1(), 1)
        ply:GiveAmmo(ammo, at, true)
    end)
end