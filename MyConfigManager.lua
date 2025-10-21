local MyConfigManager = {}
MyConfigManager.__index = MyConfigManager

function MyConfigManager.new(configName)
    local self = setmetatable({}, MyConfigManager)
    self.fileName = (configName or "DefaultConfig") .. ".json"
    self.settings = {}
    self.defaultSettings = {}
    self.registeredComponents = {}
    return self
end

function MyConfigManager:Register(componentDef)
    local flag = componentDef.Flag
    if not flag then return componentDef end

    local defaultValue = (type(componentDef.Value) == "table" and componentDef.Value.Default) or componentDef.Default
    self.defaultSettings[flag] = defaultValue
    
    if self.settings[flag] ~= nil then
        if type(componentDef.Value) == "table" then
            componentDef.Value.Default = self.settings[flag]
        else
            componentDef.Default = self.settings[flag]
        end
    end

    local originalCallback = componentDef.Callback
    componentDef.Callback = function(newValue)
        self.settings[flag] = newValue
        if type(originalCallback) == "function" then
            originalCallback(newValue)
        end
        self:Save()
    end

    return componentDef
end

function MyConfigManager:TrackInstance(flag, instance)
    if flag and instance then
        self.registeredComponents[flag] = instance
    end
end

function MyConfigManager:Save()
    if not writefile or not game:GetService("HttpService") then return false end
    local success, jsonData = pcall(function() return game:GetService("HttpService"):JSONEncode(self.settings) end)
    if success then
        pcall(writefile, self.fileName, jsonData)
    end
    return success
end

function MyConfigManager:Load()
    if not readfile or not isfile or not game:GetService("HttpService") then return false end

    local loadedData
    if isfile(self.fileName) then
        local success, jsonData = pcall(readfile, self.fileName)
        if success then
            local jsonSuccess, data = pcall(function() return game:GetService("HttpService"):JSONDecode(jsonData) end)
            if jsonSuccess then loadedData = data end
        end
    end

    if not loadedData then
        self.settings = table.clone(self.defaultSettings)
    else
        self.settings = loadedData
    end

    for flag, componentInstance in pairs(self.registeredComponents) do
        local valueToSet = self.settings[flag]
        if valueToSet ~= nil and type(componentInstance.Set) == "function" then
            componentInstance:Set(valueToSet)
        end
    end
    return true
end

return MyConfigManager
