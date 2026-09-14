--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║           DEATH NOTE TOGGLE SCRIPT v2.0                      ║
    ║   Script de toggle com sons, meshes, adesivos e efeitos      ║
    ║                                                               ║
    ║   Autor: amgelo581                                            ║
    ║   Descrição: Sistema completo de Death Note                   ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

local DeathNoteToggle = {}
DeathNoteToggle.__index = DeathNoteToggle

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURAÇÕES PRINCIPAIS                  ║
-- ╚═══════════════════════════════════════════════════════════════╝

local CONFIG = {
    -- Tecla para ativar o toggle
    ActivationKey = Enum.KeyCode.E,
    
    -- Configurações de som
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
            Id = "rbxassetid://1234567890",
            Volume = 0.6,
            Pitch = 1.1
        },
        DeathEffect = {
            Id = "rbxassetid://6859330181",
            Volume = 1.0,
            Pitch = 0.9
        }
    },
    
    -- Configurações de cores e efeitos
    Colors = {
        BookRed = Color3.fromRGB(200, 0, 0),
        BookBlack = Color3.fromRGB(0, 0, 0),
        TextGold = Color3.fromRGB(255, 215, 0),
        DeathEffect = Color3.fromRGB(255, 0, 0)
    },
    
    -- Tamanhos
    Sizes = {
        BookSize = Vector3.new(2, 2.5, 0.3),
        TextSize = 24
    }
}

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                      VARIÁVEIS GLOBAIS                       ║
-- ╚═══════════════════════════════════════════════════════════════╝

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local isActive = false
local deathNoteFolder = nil
local deathNoteBook = nil
local soundContainer = nil

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                      FUNÇÕES DE SOM                          ║
-- ╚═══════════════════════════════════════════════════════════════╝

local function PlaySound(soundConfig, parent)
    local sound = Instance.new("Sound")
    sound.SoundId = soundConfig.Id
    sound.Volume = soundConfig.Volume
    sound.Pitch = soundConfig.Pitch
    sound.Parent = parent
    sound:Play()
    game:GetService("Debris"):AddItem(sound, sound.TimeLength + 0.5)
    return sound
end

local function CreateSoundContainer()
    if soundContainer then return soundContainer end
    
    soundContainer = Instance.new("Part")
    soundContainer.Name = "SoundContainer"
    soundContainer.Transparency = 1
    soundContainer.CanCollide = false
    soundContainer.CFrame = RootPart.CFrame + RootPart.CFrame.LookVector * 5
    soundContainer.Parent = deathNoteFolder
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = RootPart
    weld.Part1 = soundContainer
    weld.Parent = soundContainer
    
    return soundContainer
end

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                   FUNÇÕES DE EFEITOS VISUAIS                 ║
-- ╚═══════════════════════════════════════════════════════════════╝

local function CreateParticleEffect(position, color, speed)
    local particles = Instance.new("Part")
    particles.Shape = Enum.PartType.Ball
    particles.Size = Vector3.new(0.5, 0.5, 0.5)
    particles.Color = color
    particles.TopSurface = Enum.SurfaceType.Smooth
    particles.BottomSurface = Enum.SurfaceType.Smooth
    particles.CanCollide = false
    particles.CFrame = CFrame.new(position)
    particles.Parent = deathNoteFolder
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(math.random(-speed, speed), math.random(-speed, speed), math.random(-speed, speed))
    bodyVelocity.Parent = particles
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Parent = particles
    
    game:GetService("Debris"):AddItem(particles, 1.5)
    
    return particles
end

local function CreateGlow(part)
    local glow = Instance.new("SurfaceGui")
    glow.Face = Enum.NormalId.Front
    glow.Parent = part
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundColor3 = CONFIG.Colors.TextGold
    textLabel.BackgroundTransparency = 0.7
    textLabel.Text = "☠ DEATH NOTE ☠"
    textLabel.TextColor3 = CONFIG.Colors.BookRed
    textLabel.TextSize = CONFIG.Sizes.TextSize
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = glow
    
    return glow
end

local function CreateLighting()
    local light = Instance.new("PointLight")
    light.Brightness = 3
    light.Range = 20
    light.Color = CONFIG.Colors.DeathEffect
    light.Parent = deathNoteBook
end

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                   CRIAÇÃO DO DEATH NOTE                      ║
-- ╚═══════════════════════════════════════════════════════════════╝

local function CreateDeathNote()
    -- Pasta principal
    deathNoteFolder = Instance.new("Folder")
    deathNoteFolder.Name = "DeathNoteToggle"
    deathNoteFolder.Parent = Character
    
    -- Livro principal
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
    
    -- Posicionar o livro na mão do player
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = RootPart
    weld.Part1 = deathNoteBook
    weld.Parent = deathNoteBook
    deathNoteBook.Position = RootPart.Position + RootPart.CFrame.RightVector * 2 + RootPart.CFrame.UpVector
    
    -- Criar adesivos/decais
    CreateGlow(deathNoteBook)
    
    -- Mesh personalizado
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxasset://fonts/Roblox.mesh"
    mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
    mesh.Parent = deathNoteBook
    
    -- Iluminação
    CreateLighting()
    
    -- Som de abertura
    CreateSoundContainer()
    PlaySound(CONFIG.Sounds.OpenBook, soundContainer)
    
    -- Criar páginas do livro
    local pageLeft = Instance.new("Part")
    pageLeft.Name = "PageLeft"
    pageLeft.Size = Vector3.new(0.9, 2.3, 0.05)
    pageLeft.Color = COLOR3.fromRGB(50, 50, 50)
    pageLeft.Material = Enum.Material.Fabric
    pageLeft.CanCollide = false
    pageLeft.Parent = deathNoteFolder
    
    local pageLeftWeld = Instance.new("WeldConstraint")
    pageLeftWeld.Part0 = deathNoteBook
    pageLeftWeld.Part1 = pageLeft
    pageLeftWeld.Parent = pageLeft
    
    local pageRight = pageLeft:Clone()
    pageRight.Name = "PageRight"
    pageRight.Parent = deathNoteFolder
    
    local pageRightWeld = Instance.new("WeldConstraint")
    pageRightWeld.Part0 = deathNoteBook
    pageRightWeld.Part1 = pageRight
    pageRightWeld.Parent = pageRight
    
    print("✓ Death Note criado com sucesso!")
end

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                    FUNÇÃO DE TOGGLE                          ║
-- ╚═══════════════════════════════════════════════════════════════╝

local function ToggleDeathNote()
    isActive = not isActive
    
    if isActive then
        CreateDeathNote()
        PlaySound(CONFIG.Sounds.Toggle, soundContainer)
        
        -- Efeito de aparição
        for i = 1, 20 do
            local effect = CreateParticleEffect(
                deathNoteBook.Position,
                CONFIG.Colors.TextGold,
                5
            )
            wait(0.05)
        end
        
        print("☠ Death Note ATIVADO! ☠")
    else
        if deathNoteFolder then
            PlaySound(CONFIG.Sounds.Toggle, soundContainer)
            
            -- Efeito de desaparecimento
            if deathNoteBook then
                for i = 1, 10 do
                    deathNoteBook.Transparency = deathNoteBook.Transparency + 0.1
                    wait(0.05)
                end
            end
            
            deathNoteFolder:Destroy()
            deathNoteFolder = nil
            deathNoteBook = nil
            soundContainer = nil
        end
        
        print("☠ Death Note DESATIVADO! ☠")
    end
end

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                   ENTRADA DE TECLADO                         ║
-- ╚═══════════════════════════════════════════════════════════════╝

local function OnInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.ActivationKey then
        ToggleDeathNote()
    end
end

UserInputService.InputBegan:Connect(OnInputBegan)

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                   LIMPEZA AO MORRER                          ║
-- ╚═══════════════════════════════════════════════════════════════╝

Humanoid.Died:Connect(function()
    if deathNoteFolder then
        deathNoteFolder:Destroy()
    end
    print("Death Note removido - Player morreu!")
end)

print("════════���═══════════════════════════════════════════════════════")
print("     🔴 DEATH NOTE TOGGLE SCRIPT CARREGADO COM SUCESSO 🔴")
print("════════════════════════════════════════════════════════════════")
print("     Pressione [E] para ativar/desativar o Death Note")
print("════════════════════════════════════════════════════════════════")
