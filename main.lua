local NovaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImRevoltexee/Nova-Lib/refs/heads/main/main.lua"))()

local Window = NovaUI:CreateWindow({
    Title = "Nova Hub Tester",
    Theme = "Neon", -- Dark / Neon / Glass
    ToggleKey = Enum.KeyCode.RightControl
})

local PlayersTab = Window:CreateTab("Movement")

-- Walk Speed
Window:CreateSlider(PlayersTab, {
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(val)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end
})

-- Infinite Jump
Window:CreateToggle(PlayersTab, {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(state)
        _G.InfJump = state
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)
