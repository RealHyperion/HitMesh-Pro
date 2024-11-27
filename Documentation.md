# **HitMesh Pro Documentation**

## **Overview**

The `ShapecastHitbox` module provides advanced functionality for creating dynamic and flexible hitboxes for various gameplay scenarios in Roblox. With support for different shapes, sizes, and custom logic, this module can simulate **melee attacks**, **ranged projectiles**, **explosions**, and more.

---

## **Key Features**

- **Shapecast Types:** Supports **Sphere**, **Capsule**, and **Box** hitboxes.
- **Dynamic Hitboxes:** Works with moving parts and dynamic objects.
- **Collision Filtering:** Ignore specific collision groups or objects using `RaycastParams`.
- **Custom Callbacks:** Execute custom logic when a hitbox detects a collision.
- **Modularity:** Easily integrates into existing systems for weapons, projectiles, or area effects.

---

## **API Reference**

### **ShapecastHitbox.new()**
Creates a new instance of the ShapecastHitbox.

**Returns:**  
`ShapecastHitbox` - A new hitbox manager instance.

---

### **:AddHitbox(part, options)**
Adds a hitbox to the manager. The hitbox will be tracked and processed during runtime.

**Parameters:**  
- `part (BasePart)`: The part to act as the source of the hitbox.  
- `options (table)`:  
  - **Shape (string)**: The shape of the hitbox. Options: `"Box"`, `"Sphere"`, `"Capsule"`. Default: `"Box"`.  
  - **Size (Vector3 | number)**: Dimensions of the hitbox. For `"Sphere"`, this is a radius (`number`). For `"Box"`, this is a `Vector3`. For `"Capsule"`, this is a diameter (`number`).  
  - **CollisionGroup (string)**: Optional collision group to filter specific parts.  
  - **FilterDescendantsInstances (table)**: Objects to ignore during hit detection.  
  - **OnHit (function)**: Callback function executed when a collision occurs.  

**Example Usage:**
```lua
hitbox:AddHitbox(workspace.Sword, {
    Shape = "Box",
    Size = Vector3.new(3, 3, 5),
    OnHit = function(hit, part)
        print(hit.Name .. " was hit by " .. part.Name)
    end
})
```

---

### **:Start()**
Starts the hitbox detection loop. Detects collisions for all active hitboxes added to the manager.

**Example Usage:**
```lua
hitbox:Start()
```

---

### **:Stop()**
Stops the hitbox detection loop.

**Example Usage:**
```lua
hitbox:Stop()
```

---

### **:Clear()**
Removes all hitboxes from the manager. Use this to reset the system.

**Example Usage:**
```lua
hitbox:Clear()
```

---

## **Examples**

### **1. Melee Weapon Hitbox**
Simulate a melee weapon with a box-shaped hitbox.

```lua
local sword = workspace.Sword

hitbox:AddHitbox(sword, {
    Shape = "Box",
    Size = Vector3.new(2, 2, 5),
    OnHit = function(hit, part)
        if hit.Parent:FindFirstChild("Humanoid") then
            hit.Parent.Humanoid:TakeDamage(25)
        end
    end
})

hitbox:Start()
```

---

### **2. Ranged Projectile Hitbox**
Simulate a projectile with a sphere-shaped hitbox.

```lua
local projectile = Instance.new("Part")
projectile.Shape = Enum.PartType.Ball
projectile.Size = Vector3.new(1, 1, 1)
projectile.CFrame = workspace.Launcher.CFrame
projectile.Parent = workspace

hitbox:AddHitbox(projectile, {
    Shape = "Sphere",
    Size = 2, -- Radius
    OnHit = function(hit, part)
        print(hit.Name .. " was struck by the projectile!")
        projectile:Destroy()
    end
})

hitbox:Start()
```

---

### **3. Explosion Hitbox**
Simulate an explosion using a spherical hitbox at a static location.

```lua
local explosionPosition = Vector3.new(0, 10, 0)

local explosionPart = Instance.new("Part")
explosionPart.Anchored = true
explosionPart.Transparency = 1
explosionPart.CFrame = CFrame.new(explosionPosition)
explosionPart.Parent = workspace

hitbox:AddHitbox(explosionPart, {
    Shape = "Sphere",
    Size = 10, -- Radius
    OnHit = function(hit, part)
        if hit.Parent:FindFirstChild("Humanoid") then
            hit.Parent.Humanoid:TakeDamage(50)
        end
    end
})

hitbox:Start()

-- Stop hitbox after 1 second
task.delay(1, function()
    hitbox:Stop()
    hitbox:Clear()
    explosionPart:Destroy()
end)
```

---

### **4. Capsule Shapecast for Moving Weapon**
Simulate a two-ended weapon swing (like a staff or spear) with a capsule hitbox.

```lua
local staff = workspace.Staff

hitbox:AddHitbox(staff, {
    Shape = "Capsule",
    Size = 2, -- Diameter
    OnHit = function(hit, part)
        print(hit.Name .. " hit by the staff swing!")
    end
})

hitbox:Start()
```

---

### **5. Multi-Hit Detection**
Use multiple hitboxes for a single object or system (e.g., a weapon with a blade and hilt).

```lua
local sword = workspace.Sword
local hilt = workspace.SwordHilt

hitbox:AddHitbox(sword, {
    Shape = "Box",
    Size = Vector3.new(2, 2, 5),
    OnHit = function(hit, part)
        print("Blade hit: " .. hit.Name)
    end
})

hitbox:AddHitbox(hilt, {
    Shape = "Sphere",
    Size = 1, -- Radius
    OnHit = function(hit, part)
        print("Hilt hit: " .. hit.Name)
    end
})

hitbox:Start()
```

---

## **Use Cases**

### **Melee Combat**
- Use **Box** or **Capsule** shapes for sword swings, staff hits, or other close-range attacks.
- Attach hitboxes to weapon parts and update their positions dynamically during animation.

### **Ranged Projectiles**
- Use **Sphere** hitboxes for detecting projectile collisions, such as bullets, arrows, or magic spells.
- Attach hitboxes to moving projectiles and destroy them on impact.

### **Explosions**
- Use a **Sphere** hitbox with a large radius to simulate area-of-effect damage.  
- Anchor the part and trigger it for a limited duration.

### **Environmental Hazards**
- Create hitboxes for traps, falling objects, or moving hazards in the game world.

---

## **Tips and Best Practices**
1. **Collision Filtering:** Use `CollisionGroup` or `FilterDescendantsInstances` to prevent detecting irrelevant parts like the player’s weapon or terrain.
2. **Optimize Performance:** Avoid creating excessively large hitboxes or adding too many hitboxes at once. Use `:Clear()` and `:Stop()` when not in use.
3. **Callbacks:** Use `OnHit` to customize interactions, such as applying damage, knockback, or special effects.
4. **Dynamic Scaling:** For growing or shrinking hitboxes, adjust the `Size` dynamically during runtime.

---

This module is highly versatile and can be adapted for any kind of collision-based interaction in your game.
