local MoneyCollectionScript = {}

-- Script properties are defined here
MoneyCollectionScript.Properties = {
    -- Example property
    {name = "money", type = "template"},
    {name = "moneySound", type = "soundasset"},
    {name = "moneyEffect", type = "effectasset"},
    {name = "amountOfMoney", type = "number"},
}

--This function is called on the server when this entity is created
function MoneyCollectionScript:Init()
    self.spawnedLocators = {}
    self.locations = self:GetEntity():GetChildren()
    self:HideMoney()
end

function MoneyCollectionScript:Reset()
    self.spawnedLocators = {}
    self.locations = self:GetEntity():GetChildren()
    self:HideMoney()
end

function MoneyCollectionScript:GetInteractPrompt(prompts)
    prompts.interact = "Pickup"
end

function MoneyCollectionScript:HideMoney()
    for i=1, self.properties.amountOfMoney do
        local rand = math.random(1,#self.locations)
        local money = GetWorld():Spawn(self.properties.money,Vector.Zero, Rotation.Zero)
        money:AttachTo(self.locations[rand])
        money:SetRelativePosition(Vector.Zero)
        money:SetRelativeRotation(Rotation.Zero)
        table.insert(self.spawnedLocators, self.locations[rand])
        table.remove(self.locations,rand)
    end
end


function MoneyCollectionScript:MoneyFound(player,entity)
print("Money found")
    local location = entity:GetParent()
    local money = entity
    local user = player:GetUser()
    
    user:SendXPEvent("collect-money")
    user:AddToLeaderboardValue("money-found", 1)
    user:AddToLeaderboardValue("money-found-weekly", 1)
    --Gib 
    local rand = math.random(10,15)
    user:SendToScripts("AddMoney", rand)
    location:PlaySound(self.properties.moneySound)
    location:PlayEffect(self.properties.moneyEffect)
    
    money:Destroy()
    
    for i=1,#self.spawnedLocators do
        if self.spawnedLocators[i] == location then
            self:SpawnNewMoney()
            table.insert(self.locations,self.spawnedLocators[i])
            table.remove(self.spawnedLocators,i)
            break
        else
        end
    end
end

function MoneyCollectionScript:SpawnNewMoney()
print("Spawning new money..")
    local rand = math.random(1,#self.locations)
        local money = GetWorld():Spawn(self.properties.money,Vector.Zero, Rotation.Zero)
        money:AttachTo(self.locations[rand])
        money:SetRelativePosition(Vector.Zero)
        money:SetRelativeRotation(Rotation.Zero)
        table.insert(self.spawnedLocators, self.locations[rand])
        table.remove(self.locations,rand)
        print("new money", money:GetPosition())
end

return MoneyCollectionScript