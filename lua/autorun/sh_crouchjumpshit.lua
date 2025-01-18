AddCSLuaFile()

--[[local sp = game.SinglePlayer()
hook.Add("FinishMove", "Crouchjumpshit", function(ply, mv)
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
        ply:ManipulateBonePosition(0, Vector(0,0,total))
        -- ply:ManipulateBonePosition(0, Vector(0,0,total), sp)
    else
        ply:ManipulateBonePosition(0, Vector(0,0,0))
    end
end)]]
-- if CLIENT then
-- end
local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")
local eIsFlagSet = ENTITY.IsFlagSet
local eGetVelocity = ENTITY.GetVelocity
local eGetPos = ENTITY.GetPos
local pGetHull = PLAYER.GetHull
local pGetHullDuck = PLAYER.GetHullDuck
local eManipulateBonePosition = ENTITY.ManipulateBonePosition
local enabled = CreateConVar("sv_crouchjumpdejank_enable", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED), "", 0, 1)
local crouchJumpers = {}
local vector_reset = Vector(0,0,0)

local function crouchModelAdjustment(ply)
    if !enabled:GetBool() then
        return
    end

    if !IsValid(ply) then return end
    local lerpTime = engine.TickInterval()
    -- if CLIENT and ply == LocalPlayer() then  return end
    if !ply then lerpTime = lerpTime - FrameTime() ply = LocalPlayer() end

    local crouchJumping = !eIsFlagSet(ply, FL_ONGROUND) and eIsFlagSet(ply, FL_ANIMDUCKING)

    -- Only set our bone back to origin if we need to.
    if !crouchJumping and crouchJumpers[ply] then
        eManipulateBonePosition(ply, 0, vector_reset)
    end

    -- NOTE: In theory this can lead to a bloated table.
    -- However, it won't since most players will not disconnect while crouch-jumping.
    crouchJumpers[ply] = crouchJumping or nil

    if crouchJumping then
        local nextPos = eGetVelocity(ply)
        nextPos:Add(physenv.GetGravity())
        nextPos:Mul(lerpTime)

        local plyPos = eGetPos(ply)
        local newPos = plyPos + nextPos

        local _, sMaxs = pGetHull(ply)
        sMaxs.x = 0
        sMaxs.y = 0

        local cMins, cMaxs = pGetHullDuck(ply)
        local endPos = newPos - sMaxs
        local trable = {
            start = plyPos,
            endpos = endPos,
            mins = cMins,
            maxs = cMaxs,
            mask = MASK_PLAYERSOLID,
            filter = ply
        }

        local hullTrace = util.TraceHull(trable)

        local trace = util.TraceLine(trable)

        local total = Lerp((hullTrace.Fraction + trace.Fraction) * 0.5, 0, -cMaxs.z)

        -- TODO: Does this hook run for other players?
        eManipulateBonePosition(ply, 0, Vector(0, 0, total))
    end
end

hook.Add("PlayerPostThink", "CrouchJump_Dejankifier", crouchModelAdjustment) -- We're running on both client and server. Hope it works.