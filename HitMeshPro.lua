-- HitMeshPro.lua
local ShapecastHitbox = {}
ShapecastHitbox.__index = ShapecastHitbox

local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

-- Utility Functions
local function createRegionFromCFrame(cframe, size)
    local halfSize = size / 2
    local corner1 = cframe.Position - (cframe.RightVector * halfSize.X) - (cframe.UpVector * halfSize.Y) - (cframe.LookVector * halfSize.Z)
    local corner2 = cframe.Position + (cframe.RightVector * halfSize.X) + (cframe.UpVector * halfSize.Y) + (cframe.LookVector * halfSize.Z)
    return Region3.new(corner1, corner2)
end

local function raycastHitbox(startCFrame, endCFrame, shape, size, params)
    local direction = (endCFrame.Position - startCFrame.Position)
    local distance = direction.Magnitude
    direction = direction.Unit

    -- Define shape-specific raycasting logic
    if shape == "Sphere" then
        -- Simulate a sphere shapecast
        local midPoint = startCFrame.Position + (direction * (distance / 2))
        local region = createRegionFromCFrame(CFrame.new(midPoint), Vector3.new(size * 2, size * 2, distance))
        return workspace:FindPartsInRegion3WithIgnoreList(region, params.FilterDescendantsInstances, math.huge)
    elseif shape == "Capsule" then
        -- Simulate a capsule shapecast using multiple raycasts
        local hits = {}
        local increment = size * 0.5
        for i = 0, distance, increment do
            local position = startCFrame.Position + (direction * i)
            local region = createRegionFromCFrame(CFrame.new(position), Vector3.new(size * 2, size * 2, increment))
            local regionHits = workspace:FindPartsInRegion3WithIgnoreList(region, params.FilterDescendantsInstances, math.huge)
            for _, hit in ipairs(regionHits) do
                if not table.find(hits, hit) then
                    table.insert(hits, hit)
                end
            end
        end
        return hits
    elseif shape == "Box" then
        -- Simulate a box shapecast
        local region = createRegionFromCFrame(startCFrame:Lerp(endCFrame, 0.5), size)
        return workspace:FindPartsInRegion3WithIgnoreList(region, params.FilterDescendantsInstances, math.huge)
    end
end

-- Module Functions
function ShapecastHitbox.new()
    local self = setmetatable({}, ShapecastHitbox)
    self.HitboxObjects = {} -- {Part, {Callback, Options}}
    self.Active = false
    return self
end

function ShapecastHitbox:AddHitbox(part, options)
    table.insert(self.HitboxObjects, {
        Part = part,
        Options = options or {Shape = "Box", Size = Vector3.new(4, 4, 4), CollisionGroup = nil},
        OnHit = options.OnHit or function(hit, part) end
    })
end

function ShapecastHitbox:Start()
    if self.Active then return end
    self.Active = true

    RunService.Heartbeat:Connect(function()
        if not self.Active then return end

        for _, hitboxData in ipairs(self.HitboxObjects) do
            local part = hitboxData.Part
            local options = hitboxData.Options
            local onHit = hitboxData.OnHit

            if not part:IsDescendantOf(workspace) then continue end

            -- Define collision params
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = options.FilterDescendantsInstances or {}
            if options.CollisionGroup then
                params.CollisionGroup = options.CollisionGroup
            end

            -- Perform the shapecast
            local hits = raycastHitbox(
                part.CFrame, -- Start CFrame
                part.CFrame * CFrame.new(0, 0, -options.Size.Z), -- End CFrame
                options.Shape,
                options.Size,
                params
            )

            -- Trigger OnHit for each detected part
            for _, hit in ipairs(hits) do
                if hit:IsA("BasePart") and hit ~= part then
                    onHit(hit, part)
                end
            end
        end
    end)
end

function ShapecastHitbox:Stop()
    self.Active = false
end

function ShapecastHitbox:Clear()
    self.HitboxObjects = {}
end

return ShapecastHitbox
