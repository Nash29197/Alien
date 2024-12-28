-- services
local players = game:GetService("Players");
local teams = game:GetService("Teams");
 -- variables
local camera = workspace.CurrentCamera;
local get_closest_player = function()
    local closest = nil;
    local closest_distance = math.huge;
     for _, character in workspace.GetChildren(workspace) do
        local player = players.FindFirstChild(players, character.Name);
        local root_part = character.FindFirstChild(character, "HumanoidRootPart");
         if (not player) or (not root_part) then
            continue;
        end
         local team_attribute = player.GetAttribute(player, "Team");
         if (not team_attribute) then
            continue;
        end
         if (teams[team_attribute] == players.LocalPlayer.Team) then
            continue;
        end
         local position, on_screen = camera.WorldToViewportPoint(camera, root_part.Position);
         if (not on_screen) then
            continue;
        end
         local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
        local distance = (Vector2.new(position.X, position.Y) - center).Magnitude;
         if (closest_distance > distance) then
            closest = character;
            closest_distance = distance;
        end
    end
     return closest;
end
 -- main
do
    local events = { -- only a table incase you wanna add more events, its really easy
        ["ShootEvent"] = function(arg)
            return (typeof(arg) == "Instance" and arg.Name and (string.find(arg.Name, players.LocalPlayer.Name))); -- dumb method for checking if the shooter is lplr, but none of the other ones seemed to work... (?, might've been tweaking, feel free to try it)
        end,
    };
     old_namecall = hookmetamethod(game, "__namecall", function(self, caller, message, ...)
        local method = getnamecallmethod();
         if (method == "Fire" and self.Name == "Sync") then -- intercept actor communication for 1337 haxx.. (so we can log all events being sent to the actor)
            for event, identify in events do
                if (event == "ShootEvent" and identify(message)) then
                    local closest_player = get_closest_player();
                    local ammo, cframe, id, weapon, projectile = ...;
                     if (closest_player and closest_player.FindFirstChild(closest_player, "Head")) then
                        cframe = closest_player.Head.CFrame; -- HEAT manipulation...
                    end
                     return old_namecall(self, caller, message, ammo, cframe, id, weapon, projectile, ...);
                end
            end
        end
         return old_namecall(self, caller, message, ...);
    end)
end
