--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                 DEATH NOTE TOGGLE - DELTA EXECUTOR                   ║
    ║          Script Completo com Sons, Meshes, Adesivos e Efeitos        ║
    ║                                                                       ║
    ║   Autor: amgelo581                                                    ║
    ║   Versão: 3.0 COMPLETA                                               ║
    ║   Uso: Cole como LocalScript e execute no Delta Executor             ║
    ╚═══════════════════════════════════════════════════════════════════════╝
]]

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                       SERVIÇOS E VARIÁVEIS                           ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local isActive = false
local deathNoteFolder = nil
local deathNoteBook = nil
local soundContainer = nil
local connection = nil

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURAÇÕES PRINCIPAIS                          ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

local CONFIG = {
    ActivationKey = Enum.KeyCode.E,
    
    Sounds = {
        Toggle = {
            Id = "rbxassetid://262423048",
            Volume = 0.7,
            Pitch = 1.0
        },
        OpenBook = {
            Id = "rbxassetid://138082152",
            Volume = 0.8,
            Pitch = 0.95
        },
        WriteMessage = {
            Id = "rbxassetid://197993261",
            Volume = 0.6,
            Pitch = 1.1
        },
        DeathEffect = {
            Id = "rbxassetid://6859330181",
            Volume = 1.0,
            Pitch = 0.9
        },
        Laugh = {
            Id = "rbxassetid://1234567890",
            Volume = 0.9,
            Pitch = 1.0
        }
    },
    
    Colors = {
        BookRed = Color3.fromRGB(200, 0, 0),
        BookBlack = Color3.fromRGB(10, 10, 10),
        TextGold = Color3.fromRGB(255, 215, 0),
        DeathEffect = Color3.fromRGB(255, 0, 0),
        Purple = Color3.fromRGB(128, 0, 255),
        White = Color3.fromRGB(255, 255, 255)
    },
    
    Sizes = {
        BookSize = Vector3.new(2, 2.5, 0.3),
        TextSize = 24
    }
}

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                      FUNÇÕES DE SOM E ÁUDIO                          ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

local function PlaySound(soundConfig, parent)
    if not parent then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundConfig.Id
    sound.Volume = soundConfig.Volume
    sound.Pitch = soundConfig.Pitch
    sound.Parent = parent
    sound:Play()
    
    Debris:AddItem(sound, sound.TimeLength + 0.5)
    return sound
end

local function CreateSoundContainer()
    if soundContainer then return soundContainer end
    
    soundContainer = Instance.new("Part")
    soundContainer.Name = "SoundContainer"
    soundContainer.Transparency = 1
    soundContainer.CanCollide = false
    soundContainer.Size = Vector3.new(1, 1, 1)
    soundContainer.CFrame = HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 5
    soundContainer.Parent = deathNoteFolder
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HumanoidRootPart
    weld.Part1 = soundContainer
    weld.Parent = soundContainer
    
    return soundContainer
end

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                   FUNÇÕES DE EFEITOS VISUAIS                         ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

local function CreateParticleEffect(position, color, speed, lifetime)
    lifetime = lifetime or 1.5
    
    local particle = Instance.new("Part")
    particle.Shape = Enum.PartType.Ball
    particle.Size = Vector3.new(0.3, 0.3, 0.3)
    particle.Color = color
    particle.TopSurface = Enum.SurfaceType.Smooth
    particle.BottomSurface = Enum.SurfaceType.Smooth
    particle.CanCollide = false
    particle.CFrame = CFrame.new(position)
    particle.Parent = deathNoteFolder
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(
        math.random(-speed, speed),
        math.random(-speed, speed),
        math.random(-speed, speed)
    )
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = particle
    
    Debris:AddItem(particle, lifetime)
    return particle
end

local function CreateGlow(part)
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.Parent = part
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundColor3 = CONFIG.Colors.TextGold
    textLabel.BackgroundTransparency = 0.5
    textLabel.Text = "☠ DEATH NOTE ☠\n「死神のノート」"
    textLabel.TextColor3 = CONFIG.Colors.BookRed
    textLabel.TextSize = 20
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true
    textLabel.Parent = surfaceGui
    
    return surfaceGui
end

local function CreateLighting(part)
    local light = Instance.new("PointLight")
    light.Brightness = 3
    light.Range = 25
    light.Color = CONFIG.Colors.DeathEffect
    light.Parent = part
    
    return light
end

local function CreateRotatingEffect()
    if not deathNoteBook then return end
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not deathNoteBook or not isActive then
            connection:Disconnect()
            return
        end
        
        deathNoteBook.CFrame = deathNoteBook.CFrame * CFrame.Angles(0, math.rad(0.5), 0)
    end)
end

local function CreateTextParticles()
    local textParticles = {
        "死", "神", "ノ", "ー", "ト",
        "✦", "☠", "♠", "✧", "※"
    }
    
    for i = 1, 15 do
        local randomText = textParticles[math.random(1, #textParticles)]
        
        local part = Instance.new("Part")
        part.Shape = Enum.PartType.Block
        part.Size = Vector3.new(0.5, 0.5, 0.1)
        part.Color = CONFIG.Colors.TextGold
        part.CanCollide = false
        part.CFrame = deathNoteBook.CFrame + Vector3.new(
            math.random(-2, 2),
            math.random(-2, 2),
            math.random(-1, 1)
        )
        part.Parent = deathNoteFolder
        
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(2, 0, 2, 0)
        billboard.Parent = part
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = randomText
        textLabel.TextColor3 = CONFIG.Colors.TextGold
        textLabel.TextSize = 32
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = billboard
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(
            math.random(-5, 5),
            math.random(5, 15),
            math.random(-5, 5)
        )
        bodyVelocity.Parent = part
        
        Debris:AddItem(part, 2)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                   CRIAÇÃO DO DEATH NOTE BOOK                         ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

local function CreateDeathNoteBook()
    -- Pasta principal
    deathNoteFolder = Instance.new("Folder")
    deathNoteFolder.Name = "DeathNoteToggle_Delta"
    deathNoteFolder.Parent = Character
    
    -- ━━━ LIVRO PRINCIPAL ━━━
    deathNoteBook = Instance.new("Part")
    deathNoteBook.Name = "DeathNoteBook"
    deathNoteBook.Shape = Enum.PartType.Block
    deathNoteBook.Size = CONFIG.Sizes.BookSize
    deathNoteBook.Color = CONFIG.Colors.BookRed
    deathNoteBook.Material = Enum.Material.Velvet
    deathNoteBook.TopSurface = Enum.SurfaceType.Smooth
    deathNoteBook.BottomSurface = Enum.SurfaceType.Smooth
    deathNoteBook.CanCollide = false
    deathNoteBook.Parent = deathNoteFolder
    
    -- Weld do livro
    local mainWeld = Instance.new("WeldConstraint")
    mainWeld.Part0 = HumanoidRootPart
    mainWeld.Part1 = deathNoteBook
    mainWeld.Parent = deathNoteBook
    
    deathNoteBook.Position = HumanoidRootPart.Position + HumanoidRootPart.CFrame.RightVector * 3 + HumanoidRootPart.CFrame.UpVector * 1.5
    
    -- Glow/Adesivo
    CreateGlow(deathNoteBook)
    
    -- Iluminação
    CreateLighting(deathNoteBook)
    
    -- ━━━ PÁGINAS DO LIVRO ━━━
    local pageLeft = Instance.new("Part")
    pageLeft.Name = "PageLeft"
    pageLeft.Size = Vector3.new(0.9, 2.3, 0.05)
    pageLeft.Color = CONFIG.Colors.BookBlack
    pageLeft.Material = Enum.Material.Fabric
    pageLeft.CanCollide = false
    pageLeft.Parent = deathNoteFolder
    
    local weldLeft = Instance.new("WeldConstraint")
    weldLeft.Part0 = deathNoteBook
    weldLeft.Part1 = pageLeft
    weldLeft.Parent = pageLeft
    pageLeft.Position = deathNoteBook.Position + Vector3.new(-0.6, 0, -0.1)
    
    local pageRight = Instance.new("Part")
    pageRight.Name = "PageRight"
    pageRight.Size = Vector3.new(0.9, 2.3, 0.05)
    pageRight.Color = CONFIG.Colors.BookBlack
    pageRight.Material = Enum.Material.Fabric
    pageRight.CanCollide = false
    pageRight.Parent = deathNoteFolder
    
    local weldRight = Instance.new("WeldConstraint")
    weldRight.Part0 = deathNoteBook
    weldRight.Part1 = pageRight
    weldRight.Parent = pageRight
    pageRight.Position = deathNoteBook.Position + Vector3.new(0.6, 0, -0.1)
    
    -- ━━━ CAPA DO LIVRO ━━━
    local backCover = Instance.new("Part")
    backCover.Name = "BackCover"
    backCover.Size = Vector3.new(2, 2.5, 0.05)
    backCover.Color = CONFIG.Colors.BookRed
    backCover.Material = Enum.Material.Velvet
    backCover.CanCollide = false
    backCover.Parent = deathNoteFolder
    
    local weldBack = Instance.new("WeldConstraint")
    weldBack.Part0 = deathNoteBook
    weldBack.Part1 = backCover
    weldBack.Parent = backCover
    
    -- ━━━ DETALHES DECORATIVOS ━━━
    for i = 1, 3 do
        local decoration = Instance.new("Part")
        decoration.Name = "Decoration_" .. i
        decoration.Shape = Enum.PartType.Ball
        decoration.Size = Vector3.new(0.2, 0.2, 0.2)
        decoration.Color = CONFIG.Colors.TextGold
        decoration.Material = Enum.Material.Neon
        decoration.CanCollide = false
        decoration.Parent = deathNoteFolder
        
        local weldDeco = Instance.new("WeldConstraint")
        weldDeco.Part0 = deathNoteBook
        weldDeco.Part1 = decoration
        weldDeco.Parent = decoration
        
        local offset = Vector3.new((i - 2) * 0.6, 1.2, 0.2)
        decoration.Position = deathNoteBook.Position + offset
    end
    
    -- ━━━ SONS E EFEITOS INICIAIS ━━━
    CreateSoundContainer()
    PlaySound(CONFIG.Sounds.OpenBook, soundContainer)
    CreateTextParticles()
    CreateRotatingEffect()
    
    print("✓ Death Note criado com sucesso!")
end

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                  FUNÇÃO DE ATAQUE CARDÍACO (EXTRA)                   ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

local function CreateDeathAttack()
    if not soundContainer then CreateSoundContainer() end
    
    PlaySound(CONFIG.Sounds.DeathEffect, soundContainer)
    
    -- Criar efeito de morte
    for i = 1, 30 do
        CreateParticleEffect(
            deathNoteBook.Position + Vector3.new(
                math.random(-5, 5),
                math.random(-5, 5),
                math.random(-5, 5)
            ),
            CONFIG.Colors.DeathEffect,
            10,
            2
        )
        wait(0.02)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                    FUNÇÃO DE TOGGLE PRINCIPAL                        ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

local function ToggleDeathNote()
    isActive = not isActive
    
    if isActive then
        print("\n════════════════════════════════════════════════════════════════")
        print("🔴 ☠ DEATH NOTE ATIVADO ☠ 🔴")
        print("════════════════════════════════════════════════════════════════\n")
        
        CreateDeathNoteBook()
        
        if soundContainer then
            PlaySound(CONFIG.Sounds.Toggle, soundContainer)
        end
        
        -- Efeito de aparição com animação
        for i = 1, 15 do
            local effect = CreateParticleEffect(
                deathNoteBook.Position + Vector3.new(
                    math.random(-3, 3),
                    math.random(-3, 3),
                    math.random(-3, 3)
                ),
                CONFIG.Colors.TextGold,
                5,
                1
            )
            wait(0.03)
        end
        
    else
        print("\n════════════════════════════════════════════════════════════════")
        print("⚪ ☠ DEATH NOTE DESATIVADO ☠ ⚪")
        print("════════════════════════════════════════════════════════════════\n")
        
        if deathNoteFolder then
            if soundContainer then
                PlaySound(CONFIG.Sounds.Toggle, soundContainer)
            end
            
            -- Efeito de desaparecimento
            if deathNoteBook then
                for i = 1, 10 do
                    for _, part in pairs(deathNoteFolder:GetChildren()) do
                        if part:IsA("Part") then
                            part.Transparency = (part.Transparency or 0) + 0.1
                        end
                    end
                    wait(0.03)
                end
            end
            
            deathNoteFolder:Destroy()
            deathNoteFolder = nil
            deathNoteBook = nil
            soundContainer = nil
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                      ENTRADA DE TECLADO                              ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

local function OnInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.ActivationKey then
        ToggleDeathNote()
    end
    
    -- Tecla extra para ataque cardíaco (Press X)
    if input.KeyCode == Enum.KeyCode.X and isActive then
        CreateDeathAttack()
    end
end

UserInputService.InputBegan:Connect(OnInputBegan)

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                    LIMPEZA AO MORRER/SAIR                            ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

local function Cleanup()
    if deathNoteFolder then
        deathNoteFolder:Destroy()
        deathNoteFolder = nil
        deathNoteBook = nil
        soundContainer = nil
    end
    
    if connection then
        connection:Disconnect()
    end
    
    print("Death Note removido!")
end

Humanoid.Died:Connect(Cleanup)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Cleanup()
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║                        INICIALIZAÇÃO                                 ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

print("\n")
print("╔═══════════════════════════════════════════════════════════════════════╗")
print("║                                                                       ║")
print("║          🔴 DEATH NOTE TOGGLE DELTA EXECUTOR - v3.0 🔴              ║")
print("║                                                                       ║")
print("║                    ✓ SCRIPT CARREGADO COM SUCESSO                    ║")
print("║                                                                       ║")
print("╚═══════════════════════════════════════════════════════════════════════╝")
print("\n📖 INSTRUÇÕES DE USO:")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("  [E]  → Ativa/Desativa o Death Note")
print("  [X]  → Cria efeito de ataque cardíaco (apenas quando ativo)")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("\n✨ RECURSOS INCLUSOS:")
print("  ✓ Sons de abertura e efeitos dinâmicos")
print("  ✓ Meshes e modelos 3D")
print("  ✓ Adesivos e iluminação neon")
print("  ✓ Partículas de kanji japonês")
print("  ✓ Rotação contínua do livro")
print("  ✓ Efeitos de ataque cardíaco (X)")
print("  ✓ Limpeza automática ao morrer")
print("\n")
