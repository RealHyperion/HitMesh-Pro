-- HitMeshPro.lua
local HitMeshPro = {}
HitMeshPro.__index = HitMeshPro

local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")

-- Utility: Create a Region3 from a CFrame and size
local function createRegion(cframe, size)
    local halfSize = size / 2
    local corner1 = cframe.Position - (cframe.RightVector * halfSize.X) - (cframe.UpVector * halfSize.Y) - (cframe.LookVector * halfSize.Z)
    local corner2 = cframe.Position + (cframe.RightVector * halfSize.X) + (cframe.UpVector * halfSize.Y) + (cframe.LookVector * halfSize.Z)
    return Region3.new(corner1, corner2)
end

-- Utility: Draw debug visuals for hitboxes
local function drawDebug(cframe, size, duration)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.5
    part.Size = size
    part.CFrame = cframe
    part.Color = Color3.fromRGB(255, 0, 0)
    part.Parent = workspace
    Debris:AddItem(part, duration or 0.5)
end

-- Core shapecast logic
local function shapecast(startCFrame, shape, size, params, debug)
    local hits = {}
    if shape == "Line" then
        -- Raycast simulation for line
        local direction = size * startCFrame.LookVector
        local rayResult = workspace:Raycast(startCFrame.Position, direction, params)
        if rayResult then
            table.insert(hits, rayResult.Instance)
        end
    elseif shape == "Box" then
        -- Box region detection
        local region = createRegion(startCFrame, size)
        hits = workspace:FindPartsInRegion3WithIgnoreList(region, params.FilterDescendantsInstances, math.huge)
    elseif shape == "Sphere" then
        -- Simulate sphere cast
        local radius = size.X / 2
        hits = workspace:GetPartsInPart(workspace.Terrain, params.FilterDescendantsInstances, function(part)
            return (part.Position - startCFrame.Position).Magnitude <= radius
        end)
    elseif shape == "Custom" and typeof(size) == "function" then
        -- Custom logic provided as a function
        hits = size(startCFrame, params)
    end
    -- Debug visuals
    if debug then drawDebug(startCFrame, size, 0.25) end
    return hits
end

-- HitMeshPro Object Constructor
function HitMeshPro.new()
    local self = setmetatable({}, HitMeshPro)
    self.Hitboxes = {} -- Track all active hitboxes
    self.IsActive = false
    return self
end

-- Add a hitbox
function HitMeshPro:Add(part, options)
    table.insert(self.Hitboxes, {
        Part = part,
        Options = options or {Shape = "Box", Size = Vector3.new(5, 5, 5), Debug = false},
        OnHit = options.OnHit or function(hit) end,
    })
end

-- Start detecting collisions
function HitMeshPro:Start()
    if self.IsActive then return end
    self.IsActive = true
    RunService.Heartbeat:Connect(function()
        if not self.IsActive then return end
        for _, hitbox in ipairs(self.Hitboxes) do
            local part = hitbox.Part
            local options = hitbox.Options
            if part and part:IsDescendantOf(workspace) then
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = options.FilterDescendantsInstances or {}
                params.FilterType = Enum.RaycastFilterType.Blacklist
                params.CollisionGroup = options.CollisionGroup

                local hits = shapecast(
                    part.CFrame,
                    options.Shape,
                    options.Size,
                    params,
                    options.Debug
                )
                for _, hit in ipairs(hits) do
                    hitbox.OnHit(hit)
                end
            end
        end
    end)
end

-- Stop all collision detection
function HitMeshPro:Stop()
    self.IsActive = false
end

-- Clear all hitboxes
function HitMeshPro:Clear()
    self.Hitboxes = {}
end

return HitMeshPro
