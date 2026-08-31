-- 1. Jalankan Chiyo Hub di background thread
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kaisenlmao/loader/refs/heads/main/chiyo.lua"))()
    end)
end)

-- Jeda 2 detik biar Chiyo Hub-nya selesai loading dulu
task.wait(2)

-- 2. Jalankan Custom UI & Jump-Bypass Treadmill
task.spawn(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    local CoreGui = game:GetService("CoreGui")
    local Workspace = game:GetService("Workspace")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local targetGui = CoreGui
    pcall(function() if gethui then targetGui = gethui() end end)
    if not targetGui then targetGui = LocalPlayer:WaitForChild("PlayerGui") end

    if targetGui:FindFirstChild("TreadmillBypassUI") then
        targetGui.TreadmillBypassUI:Destroy()
    end

    local ConfigFile = "TreadmillBypass_Config_Chiyo.json"
    local Config = { BypassOn = false }

    if isfile and isfile(ConfigFile) then
        pcall(function()
            local res = HttpService:JSONDecode(readfile(ConfigFile))
            if res and res.BypassOn ~= nil then Config.BypassOn = res.BypassOn end
        end)
    end

    local function SaveConfig()
        if writefile then
            pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end)
        end
    end

    local ScreenGui = Instance.new("ScreenGui", targetGui)
    ScreenGui.Name = "TreadmillBypassUI"
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
    MainFrame.Size = UDim2.new(0, 200, 0, 110)
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true 
    Instance.new("UICorner", MainFrame)

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", TopBar)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Jump-Bypass"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local MinimizeBtn = Instance.new("TextButton", TopBar)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinimizeBtn.Position = UDim2.new(1, -60, 0, 5)
    MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 14
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 12
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    local ContentFrame = Instance.new("Frame", MainFrame)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 0, 0, 30)
    ContentFrame.Size = UDim2.new(1, 0, 1, -30)

    local ToggleButton = Instance.new("TextButton", ContentFrame)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.25, 0)
    ToggleButton.Size = UDim2.new(0.8, 0, 0.45, 0)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "Bypass: OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    Instance.new("UICorner", ToggleButton)

    local savedTreadmills = {}
    local isMinimized = false

    local function applyBypass(state)
        local keywords = {"treadmill", "treadmills"} 
        if state then
            ToggleButton.Text = "Bypass: ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            
            -- Sembunyikan & matikan fungsi treadmill
            for _, obj in pairs(Workspace:GetDescendants()) do
                for _, keyword in pairs(keywords) do
                    if string.find(string.lower(obj.Name), keyword) then
                        if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("BasePart") then
                            local alreadySaved = false
                            for _, v in pairs(savedTreadmills) do
                                if v.Instance == obj then alreadySaved = true break end
                            end
                            if not alreadySaved then
                                table.insert(savedTreadmills, {Instance = obj, Parent = obj.Parent})
                                
                                -- Hapus pemicu sentuhan & matikan tabrakan
                                for _, child in pairs(obj:GetDescendants()) do
                                    if child:IsA("ProximityPrompt") or child:IsA("TouchTransmitter") or child:IsA("ClickDetector") then
                                        child:Destroy()
                                    elseif child:IsA("BasePart") then
                                        child.CanCollide = false
                                        child.CanTouch = false
                                    end
                                end
                                
                                obj.Parent = nil
                            end
                        end
                    end
                end
            end
            
            -- Efek otomatis loncat + lepas duduk biar bebas dari jeratan
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if humanoid then
                    humanoid.Sit = false
                    humanoid.Jump = true -- Otomatis loncat seketika!
                end
                if rootPart then
                    rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 3.5, 0) -- Angkat sedikit ke atas
                end
            end
        else
            ToggleButton.Text = "Bypass: OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            for _, data in pairs(savedTreadmills) do
                if data.Instance then data.Instance.Parent = data.Parent end
            end
            savedTreadmills = {}
        end
    end

    ToggleButton.MouseButton1Click:Connect(function()
        Config.BypassOn = not Config.BypassOn
        applyBypass(Config.BypassOn)
        SaveConfig()
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            MainFrame.Size = UDim2.new(0, 200, 0, 30)
            MinimizeBtn.Text = "+"
        else
            MainFrame.Size = UDim2.new(0, 200, 0, 110)
            MinimizeBtn.Text = "-"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        applyBypass(false) 
        Config.BypassOn = false
        SaveConfig()
        ScreenGui:Destroy()
    end)

    -- Auto-apply kalau config aktif, jadi langsung loncat & hilang begitu masuk game
    if Config.BypassOn then
        task.wait(1)
        applyBypass(true)
    end
end)
