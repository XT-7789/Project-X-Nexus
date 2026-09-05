local _0x1={P=game:GetService("\80\108\97\121\101\114\115"),R=game:GetService("\82\117\110\83\101\114\118\105\99\101"),U=game:GetService("\85\115\101\114\73\110\112\117\116\83\101\114\118\105\99\101"),L=game:GetService("\76\105\103\104\116\105\110\103"),T=game:GetService("\84\119\101\101\110\83\101\114\118\105\99\101"),W=game:GetService("\87\111\114\107\115\112\97\99\101"),G=game:GetService("\83\116\97\114\116\101\114\71\117\105")};
local _0x2=_0x1.P.LocalPlayer;
local _0x3=_0x1.W.CurrentCamera;
if not game:IsLoaded() then game.Loaded:Wait() end;
local _0x4;
if type(gethui)=="function" then
    _0x4=gethui();
else
    local _0x5,_0x6=pcall(function() return game:GetService("\67\111\114\101\71\117\105") end);
    if _0x5 and _0x6 then
        _0x4=_0x6;
    else
        _0x4=_0x2:WaitForChild("\80\108\97\121\101\114\71\117\105");
    end;
end;
if not _0x4 then return end;

local _0x7={
    Keys={Menu=Enum.KeyCode.Insert,Fly=Enum.KeyCode.Z,Noclip=Enum.KeyCode.V,Unload=Enum.KeyCode.End},
    Theme={
        Main=Color3.fromRGB(10,10,15),Sec=Color3.fromRGB(20,20,25),
        Stroke=Color3.fromRGB(0,255,255),Team=Color3.fromRGB(0,255,100),
        Text=Color3.fromRGB(255,255,255),TextDim=Color3.fromRGB(150,150,150),
    },
    States={
        ESP=false,Chams=false,XRay=false,Fullbright=false,Crosshair=false,
        Fly=false,SpeedHack=false,InfJump=false,Noclip=false,NoFall=false,
    },
    Vals={FlySpeed=150,WalkSpeed=150},
    Seller={Discord="\118\108\105\108\97\121\122",Version="\86\50\46\48\32\80\114\101\109\105\117\109"}
};

local _0x8={
    ESPObjects={},CrosshairLines={},ToggleFuncs={},MainFrame=nil,
    OriginalLighting={},Connections={},RenderConn=nil,HeartbeatConn=nil,InputConn=nil,
};

local _0x9={};
function _0x9.Notify(_0xa,_0xb,_0xc)
    pcall(function() _0x1.G:SetCore("\83\101\110\100\78\111\116\105\102\105\99\97\116\105\111\110",{Title=_0xa,Text=_0xb,Duration=_0xc or 2}) end);
end;

function _0x9.IsTeammate(_0xd)
    if not _0xd or not _0x2 then return false end;
    if _0xd.Team and _0x2.Team and _0xd.Team==_0x2.Team then return true end;
    if _0xd.TeamColor and _0x2.TeamColor and _0xd.TeamColor==_0x2.TeamColor then return true end;
    return false;
end;

function _0x9.ResetCollision()
    if _0x2.Character then
        for _,_0xe in pairs(_0x2.Character:GetDescendants()) do
            if _0xe:IsA("\66\97\115\101\80\97\114\116") then _0xe.CanCollide=true end;
        end;
    end;
end;

function _0x9.ToggleXRay(_0xf)
    for _,_0xe in pairs(_0x1.W:GetDescendants()) do
        if _0xe:IsA("\66\97\115\101\80\97\114\116") and not _0xe.Parent:FindFirstChild("\72\117\109\97\110\111\105\100") then
            if _0xf then
                if _0xe.Transparency<0.9 then
                    if not _0xe:GetAttribute("\88\82\95\79\114\105\103") then
                        _0xe:SetAttribute("\88\82\95\79\114\105\103",_0xe.Transparency);
                    end;
                    _0xe.Transparency=0.6;
                end;
            else
                local _0x10=_0xe:GetAttribute("\88\82\95\79\114\105\103");
                if _0x10 then
                    _0xe.Transparency=_0x10;
                    _0xe:SetAttribute("\88\82\95\79\114\105\103",nil);
                end;
            end;
        end;
    end;
end;

function _0x9.ToggleFullbright(_0xf)
    if _0xf then
        _0x8.OriginalLighting={
            Ambient=_0x1.L.Ambient,Brightness=_0x1.L.Brightness,
            OutdoorAmbient=_0x1.L.OutdoorAmbient,ClockTime=_0x1.L.ClockTime,
            FogEnd=_0x1.L.FogEnd,FogStart=_0x1.L.FogStart
        };
        _0x1.L.Ambient=Color3.new(1,1,1);
        _0x1.L.Brightness=2;
        _0x1.L.OutdoorAmbient=Color3.new(1,1,1);
        _0x1.L.ClockTime=14;
        _0x1.L.FogEnd=100000;
        _0x1.L.FogStart=0;
    else
        if next(_0x8.OriginalLighting) then
            for _0x11,_0x12 in pairs(_0x8.OriginalLighting) do
                _0x1.L[_0x11]=_0x12;
            end;
        end;
    end;
end;

function _0x9.UpdateChams()
    for _,_0x13 in pairs(_0x1.P:GetPlayers()) do
        if _0x13~=_0x2 and _0x13.Character then
            local _0x14=_0x13.Character:FindFirstChild("\88\95\78\97\110\111\95\67\104\97\109\115");
            if _0x7.States.Chams then
                if not _0x14 then
                    _0x14=Instance.new("\72\105\103\104\108\105\103\104\116",_0x13.Character);
                    _0x14.Name="\88\95\78\97\110\111\95\67\104\97\109\115";
                    _0x14.FillTransparency=0.5;
                    _0x14.OutlineTransparency=0;
                end;
                _0x14.FillColor=_0x9.IsTeammate(_0x13) and _0x7.Theme.Team or _0x7.Theme.Stroke;
                _0x14.OutlineColor=_0x14.FillColor;
            else
                if _0x14 then _0x14:Destroy() end;
            end;
        end;
    end;
end;

function _0x9.RemoveAllChams()
    for _,_0x13 in pairs(_0x1.P:GetPlayers()) do
        if _0x13.Character then
            local _0x14=_0x13.Character:FindFirstChild("\88\95\78\97\110\111\95\67\104\97\109\115");
            if _0x14 then _0x14:Destroy() end;
        end;
    end;
end;

function _0x9.RemoveAllFlyInstances()
    for _,_0x13 in pairs(_0x1.P:GetPlayers()) do
        if _0x13==_0x2 and _0x13.Character then
            local _0x15=_0x13.Character:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116");
            if _0x15 then
                local _0x16=_0x15:FindFirstChild("\88\95\78\97\110\111\95\70\108\121\95\76\86");
                if _0x16 then _0x16:Destroy() end;
                local _0x17=_0x15:FindFirstChild("\88\95\78\97\110\111\95\83\112\101\101\100\95\76\86");
                if _0x17 then _0x17:Destroy() end;
            end;
        end;
    end;
end;

local _0x18={};
function _0x18.CreateESP(_0x13)
    if _0x13==_0x2 or _0x8.ESPObjects[_0x13] then return end;
    if not Drawing then return end;
    local _0x19={
        Box=Drawing.new("\83\113\117\97\114\101"),
        Name=Drawing.new("\84\101\120\116"),
        HealthBar=Drawing.new("\76\105\110\101"),
        Distance=Drawing.new("\84\101\120\116")
    };
    _0x19.Box.Thickness=1.5;
    _0x19.Box.Color=_0x7.Theme.Stroke;
    _0x19.Box.Filled=false;
    _0x19.Box.Visible=false;
    _0x19.Name.Size=14;
    _0x19.Name.Center=true;
    _0x19.Name.Outline=true;
    _0x19.Name.Color=Color3.new(1,1,1);
    _0x19.Name.Visible=false;
    _0x19.HealthBar.Thickness=1.5;
    _0x19.HealthBar.Color=Color3.new(0,1,0);
    _0x19.HealthBar.Visible=false;
    _0x19.Distance.Size=12;
    _0x19.Distance.Center=true;
    _0x19.Distance.Outline=true;
    _0x19.Distance.Color=Color3.new(1,1,1);
    _0x19.Distance.Visible=false;
    _0x8.ESPObjects[_0x13]=_0x19;
end;

function _0x18.RemoveESP(_0x13)
    if _0x8.ESPObjects[_0x13] then
        for _,_0x1a in pairs(_0x8.ESPObjects[_0x13]) do
            pcall(function() _0x1a:Remove() end);
        end;
        _0x8.ESPObjects[_0x13]=nil;
    end;
end;

function _0x18.RemoveAllESP()
    for _0x13,_0x19 in pairs(_0x8.ESPObjects) do
        for _,_0x1a in pairs(_0x19) do
            pcall(function() _0x1a:Remove() end);
        end;
    end;
    _0x8.ESPObjects={};
end;

local _0x1b={};
function _0x1b.Init()
    local _0x1c="\88\95\78\65\78\79\95\86\50\46\48";
    if _0x4:FindFirstChild(_0x1c) then _0x4[_0x1c]:Destroy() end;
    local _0x1d=Instance.new("\83\99\114\101\101\110\71\117\105",_0x4);
    _0x1d.Name=_0x1c;
    _0x1d.ResetOnSpawn=false;
    _0x1d.IgnoreGuiInset=true;
    _0x1d.DisplayOrder=999999999;
    local _0x1e=Instance.new("\70\114\97\109\101",_0x1d);
    _0x1e.Size=UDim2.new(0,420,0,520);
    _0x1e.Position=UDim2.new(0.5,-210,0.5,-260);
    _0x1e.BackgroundColor3=_0x7.Theme.Main;
    _0x1e.Active=true;
    _0x1e.Draggable=true;
    _0x8.MainFrame=_0x1e;
    local _0x1f=Instance.new("\85\73\83\116\114\111\107\101",_0x1e);
    _0x1f.Color=_0x7.Theme.Stroke;
    _0x1f.Thickness=2;
    Instance.new("\85\73\67\111\114\110\101\114",_0x1e).CornerRadius=UDim.new(0,8);
    local _0x20=Instance.new("\84\101\120\116\76\97\98\101\108",_0x1e);
    _0x20.Text="\88\32\78\65\78\79\32".._0x7.Seller.Version;
    _0x20.Size=UDim2.new(1,0,0,40);
    _0x20.BackgroundTransparency=1;
    _0x20.TextColor3=_0x7.Theme.Stroke;
    _0x20.Font=Enum.Font.GothamBlack;
    _0x20.TextSize=18;
    local _0x21=Instance.new("\83\99\114\111\108\108\105\110\103\70\114\97\109\101",_0x1e);
    _0x21.Size=UDim2.new(1,-20,1,-80);
    _0x21.Position=UDim2.new(0,10,0,45);
    _0x21.BackgroundTransparency=1;
    _0x21.ScrollBarThickness=4;
    _0x21.ScrollBarImageColor3=_0x7.Theme.Stroke;
    local _0x22=Instance.new("\85\73\76\105\115\116\76\97\121\111\117\116",_0x21);
    _0x22.Padding=UDim.new(0,6);
    _0x22:GetPropertyChangedSignal("\65\98\115\111\108\117\116\101\67\111\110\116\101\110\116\83\105\122\101"):Connect(function()
        _0x21.CanvasSize=UDim2.new(0,0,0,_0x22.AbsoluteContentSize.Y);
    end);
    local _0x23=Instance.new("\84\101\120\116\76\97\98\101\108",_0x1e);
    _0x23.Size=UDim2.new(1,-20,0,25);
    _0x23.Position=UDim2.new(0,10,1,-30);
    _0x23.BackgroundTransparency=1;
    _0x23.Text="\76\105\99\101\110\115\101\100\32\80\114\101\109\105\117\109\32\124\32\83\101\108\108\101\114\58\32".._0x7.Seller.Discord;
    _0x23.TextColor3=_0x7.Theme.TextDim;
    _0x23.Font=Enum.Font.GothamBold;
    _0x23.TextSize=12;
    local function _0x24(_0x25)
        local _0x26=Instance.new("\84\101\120\116\76\97\98\101\108",_0x21);
        _0x26.Size=UDim2.new(1,-5,0,25);
        _0x26.BackgroundTransparency=1;
        _0x26.Text=_0x25;
        _0x26.TextColor3=_0x7.Theme.Stroke;
        _0x26.Font=Enum.Font.GothamBlack;
        _0x26.TextSize=14;
        _0x26.TextXAlignment=Enum.TextXAlignment.Left;
    end;
    local function _0x27(_0x28,_0x29)
        local _0x2a=Instance.new("\84\101\120\116\66\117\116\116\111\110",_0x21);
        _0x2a.Size=UDim2.new(1,-5,0,40);
        _0x2a.BackgroundColor3=_0x7.Theme.Sec;
        _0x2a.Text="";
        _0x2a.AutoButtonColor=false;
        Instance.new("\85\73\67\111\114\110\101\114",_0x2a).CornerRadius=UDim.new(0,6);
        local _0x2b=Instance.new("\85\73\83\116\114\111\107\101",_0x2a);
        _0x2b.Color=_0x7.Theme.Stroke;
        _0x2b.Transparency=0.8;
        local _0x2c=Instance.new("\84\101\120\116\76\97\98\101\108",_0x2a);
        _0x2c.Text=_0x28;
        _0x2c.Size=UDim2.new(0.7,0,1,0);
        _0x2c.Position=UDim2.new(0,15,0,0);
        _0x2c.BackgroundTransparency=1;
        _0x2c.TextColor3=_0x7.Theme.Text;
        _0x2c.Font=Enum.Font.GothamSemibold;
        _0x2c.TextSize=13;
        _0x2c.TextXAlignment=Enum.TextXAlignment.Left;
        local _0x2d=Instance.new("\70\114\97\109\101",_0x2a);
        _0x2d.Size=UDim2.new(0,36,0,18);
        _0x2d.Position=UDim2.new(1,-48,0.5,-9);
        _0x2d.BackgroundColor3=Color3.fromRGB(60,60,70);
        Instance.new("\85\73\67\111\114\110\101\114",_0x2d).CornerRadius=UDim.new(1,0);
        local _0x2e=Instance.new("\70\114\97\109\101",_0x2d);
        _0x2e.Size=UDim2.new(0,14,0,14);
        _0x2e.Position=UDim2.new(0,2,0.5,-7);
        _0x2e.BackgroundColor3=Color3.fromRGB(120,120,130);
        Instance.new("\85\73\67\111\114\110\101\114",_0x2e).CornerRadius=UDim.new(1,0);
        local function _0x2f(_0x30)
            local _0x31=_0x30 and _0x7.Theme.Stroke or Color3.fromRGB(120,120,130);
            local _0x32=_0x30 and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7);
            _0x1.T:Create(_0x2e,TweenInfo.new(0.25),{Position=_0x32,BackgroundColor3=_0x31}):Play();
            _0x1.T:Create(_0x2b,TweenInfo.new(0.25),{Transparency=_0x30 and 0.2 or 0.8}):Play();
            if _0x29=="\88\82\97\121" then _0x9.ToggleXRay(_0x30) end;
            if _0x29=="\70\117\108\108\98\114\105\103\104\116" then _0x9.ToggleFullbright(_0x30) end;
            if _0x29=="\78\111\99\108\105\112" and not _0x30 then _0x9.ResetCollision() end;
            if _0x29=="\67\104\97\109\115" then _0x9.UpdateChams() end;
        end;
        _0x8.ToggleFuncs[_0x29]=_0x2f;
        _0x2f(_0x7.States[_0x29]);
        _0x2a.MouseButton1Click:Connect(function()
            _0x7.States[_0x29]=not _0x7.States[_0x29];
            _0x2f(_0x7.States[_0x29]);
        end);
    end;
    local function _0x33(_0x34,_0x35,_0x36,_0x37,_0x38)
        local _0x39=Instance.new("\70\114\97\109\101",_0x21);
        _0x39.Size=UDim2.new(1,-5,0,50);
        _0x39.BackgroundColor3=_0x7.Theme.Sec;
        Instance.new("\85\73\67\111\114\110\101\114",_0x39).CornerRadius=UDim.new(0,6);
        local _0x3a=Instance.new("\84\101\120\116\76\97\98\101\108",_0x39);
        _0x3a.Text=_0x34..": ".._0x37;
        _0x3a.Size=UDim2.new(1,-20,0,20);
        _0x3a.Position=UDim2.new(0,10,0,5);
        _0x3a.BackgroundTransparency=1;
        _0x3a.TextColor3=_0x7.Theme.Text;
        _0x3a.Font=Enum.Font.GothamBold;
        _0x3a.TextSize=12;
        local _0x3b=Instance.new("\84\101\120\116\66\117\116\116\111\110",_0x39);
        _0x3b.Size=UDim2.new(1,-20,0,6);
        _0x3b.Position=UDim2.new(0,10,0,32);
        _0x3b.BackgroundColor3=Color3.fromRGB(60,60,70);
        _0x3b.Text="";
        Instance.new("\85\73\67\111\114\110\101\114",_0x3b).CornerRadius=UDim.new(0,3);
        local _0x3c=Instance.new("\70\114\97\109\101",_0x3b);
        _0x3c.Size=UDim2.new((_0x37-_0x35)/(_0x36-_0x35),0,1,0);
        _0x3c.BackgroundColor3=_0x7.Theme.Stroke;
        Instance.new("\85\73\67\111\114\110\101\114",_0x3c).CornerRadius=UDim.new(1,0);
        local _0x3d=false;
        _0x3b.MouseButton1Down:Connect(function() _0x3d=true end);
        _0x1.U.InputEnded:Connect(function(_0x3e)
            if _0x3e.UserInputType==Enum.UserInputType.MouseButton1 then _0x3d=false end;
        end);
        _0x1.U.InputChanged:Connect(function(_0x3e)
            if _0x3d and _0x3e.UserInputType==Enum.UserInputType.MouseMovement then
                local _0x3f=math.clamp((_0x3e.Position.X-_0x3b.AbsolutePosition.X)/_0x3b.AbsoluteSize.X,0,1);
                _0x3c.Size=UDim2.new(_0x3f,0,1,0);
                local _0x40=math.floor(_0x35+(_0x36-_0x35)*_0x3f);
                _0x3a.Text=_0x34..": ".._0x40;
                _0x38(_0x40);
            end;
        end);
    end;
    _0x24("\239\187\191\32\86\73\83\85\65\76");
    _0x27("\69\83\80\32\77\97\115\116\101\114\32\40\66\111\120\43\78\97\109\101\43\72\80\41","\69\83\80");
    _0x27("\67\104\97\109\115\32\40\72\105\103\104\108\105\103\104\116\32\71\108\111\119\41","\67\104\97\109\115");
    _0x27("\88\45\82\97\121\32\40\87\97\108\108\104\97\99\107\41","\88\82\97\121");
    _0x27("\70\117\108\108\98\114\105\103\104\116\32\40\78\105\103\104\116\32\86\105\115\105\111\110\41","\70\117\108\108\98\114\105\103\104\116");
    _0x27("\67\114\111\115\115\104\97\105\114","\67\114\111\115\115\104\97\105\114");
    _0x24("\32\77\79\86\69\77\69\78\84\32\40\83\84\69\65\76\84\72\32\86\52\46\50\41");
    _0x27("\70\108\121\32\77\111\100\101\32\91\90\93\32\40\65\110\116\105\45\82\101\115\101\116\41","\70\108\121");
    _0x33("\70\108\121\32\83\112\101\101\100",10,500,150,function(_0x41) _0x7.Vals.FlySpeed=_0x41 end);
    _0x27("\83\112\101\101\100\32\72\97\99\107\32\40\85\110\100\101\116\101\99\116\97\98\108\101\41","\83\112\101\101\100\72\97\99\107");
    _0x33("\87\97\108\107\32\83\112\101\101\100",16,500,150,function(_0x41) _0x7.Vals.WalkSpeed=_0x41 end);
    _0x27("\78\111\99\108\105\112\32\91\86\93","\78\111\99\108\105\112");
    _0x27("\73\110\102\105\110\105\116\101\32\74\117\109\112","\73\110\102\74\117\109\112");
    _0x27("\78\111\32\70\97\108\108\32\68\97\109\97\103\101","\78\111\70\97\108\108");
    _0x24("\226\154\153\239\187\191\32\83\89\83\84\69\77");
    local _0x42=Instance.new("\84\101\120\116\66\117\116\116\111\110",_0x21);
    _0x42.Size=UDim2.new(1,-5,0,45);
    _0x42.BackgroundColor3=Color3.fromRGB(150,20,20);
    _0x42.Text="\240\159\151\145\239\184\143\32\85\78\76\79\65\68\32\83\67\82\73\80\84\32\40\69\110\100\41";
    _0x42.TextColor3=Color3.new(1,1,1);
    _0x42.Font=Enum.Font.GothamBlack;
    _0x42.TextSize=14;
    Instance.new("\85\73\67\111\114\110\101\114",_0x42).CornerRadius=UDim.new(0,6);
    _0x42.MouseButton1Click:Connect(function() _0x43.Unload() end);
end;

local _0x43={};
function _0x43.Unload()
    _0x9.Notify("\240\159\151\145\32\239\184\143\32\85\110\108\111\97\100\105\110\103","\80\114\111\99\101\115\115\105\110\103\32\88\32\78\65\78\79\32\86\50\46\48\46\46\46");
    if _0x8.RenderConn then _0x8.RenderConn:Disconnect() end;
    if _0x8.HeartbeatConn then _0x8.HeartbeatConn:Disconnect() end;
    if _0x8.InputConn then _0x8.InputConn:Disconnect() end;
    for _,_0x44 in pairs(_0x8.Connections) do
        pcall(function() _0x44:Disconnect() end);
    end;
    _0x8.Connections={};
    for _0x45,_ in pairs(_0x7.States) do
        _0x7.States[_0x45]=false;
    end;
    pcall(function() _0x9.ToggleXRay(false) end);
    pcall(function() _0x9.ToggleFullbright(false) end);
    pcall(function() _0x9.ResetCollision() end);
    pcall(function() _0x9.RemoveAllChams() end);
    pcall(function() _0x9.RemoveAllFlyInstances() end);
    _0x18.RemoveAllESP();
    for _,_0x46 in pairs(_0x8.CrosshairLines) do
        pcall(function() _0x46:Remove() end);
    end;
    _0x8.CrosshairLines={};
    for _,_0x47 in pairs(_0x4:GetChildren()) do
        if string.find(_0x47.Name,"\88\95\78\65\78\79") then _0x47:Destroy() end;
    end;
    pcall(function()
        for _,_0x47 in pairs(_0x2.PlayerGui:GetChildren()) do
            if string.find(_0x47.Name,"\88\95\78\65\78\79") then _0x47:Destroy() end;
        end;
    end);
    pcall(function()
        for _,_0x47 in pairs(game:GetService("\67\111\114\101\71\117\105"):GetChildren()) do
            if string.find(_0x47.Name,"\88\95\78\65\78\79") then _0x47:Destroy() end;
        end;
    end);
    print("\226\156\133\32\88\32\78\65\78\79\32\86\50\46\48\32\67\79\77\80\76\69\84\69\76\89\32\85\78\76\79\65\68\69\68");
    task.spawn(function()
        task.wait(0.5);
        if getgenv then getgenv().X_NANO_V2_LOADED=nil end;
    end);
end;

function _0x43.Init()
    if Drawing then
        _0x8.CrosshairLines.H=Drawing.new("\76\105\110\101");
        _0x8.CrosshairLines.H.Thickness=1.5;
        _0x8.CrosshairLines.H.Color=_0x7.Theme.Stroke;
        _0x8.CrosshairLines.H.Visible=false;
        _0x8.CrosshairLines.V=Drawing.new("\76\105\110\101");
        _0x8.CrosshairLines.V.Thickness=1.5;
        _0x8.CrosshairLines.V.Color=_0x7.Theme.Stroke;
        _0x8.CrosshairLines.V.Visible=false;
    end;
    for _,_0x13 in pairs(_0x1.P:GetPlayers()) do
        pcall(function() _0x18.CreateESP(_0x13) end);
    end;
    _0x1.P.PlayerAdded:Connect(function(_0x13)
        pcall(function() _0x18.CreateESP(_0x13) end);
    end);
    _0x1.P.PlayerRemoving:Connect(function(_0x13)
        pcall(function() _0x18.RemoveESP(_0x13) end);
    end);
    _0x1b.Init();
    _0x8.RenderConn=_0x1.R.RenderStepped:Connect(function()
        local _0x48=_0x1.W.CurrentCamera;
        local _0x49=_0x2.Character;
        local _0x4a=_0x49 and _0x49:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116");
        for _0x13,_0x19 in pairs(_0x8.ESPObjects) do
            _0x19.Box.Visible=false;
            _0x19.Name.Visible=false;
            _0x19.HealthBar.Visible=false;
            _0x19.Distance.Visible=false;
            if _0x7.States.ESP then
                local _0x4b=_0x13.Character;
                local _0x4c=_0x4b and _0x4b:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116");
                local _0x4d=_0x4b and _0x4b:FindFirstChild("\72\101\97\100");
                local _0x4e=_0x4b and _0x4b:FindFirstChild("\72\117\109\97\110\111\105\100");
                if _0x4b and _0x4c and _0x4d and _0x4e and _0x4e.Health>0 then
                    local _0x4f,_0x50=_0x48:WorldToViewportPoint(_0x4c.Position);
                    local _0x51=_0x7.Theme.Stroke;
                    if _0x9.IsTeammate(_0x13) then _0x51=_0x7.Theme.Team end;
                    if _0x50 then
                        local _0x52=_0x48:WorldToViewportPoint(_0x4d.Position+Vector3.new(0,0.5,0));
                        local _0x53=math.abs(_0x52.Y-_0x48:WorldToViewportPoint(_0x4c.Position-Vector3.new(0,3,0)).Y);
                        local _0x54=_0x53/1.8;
                        local _0x55=_0x4f.X-_0x54/2;
                        local _0x56=_0x4f.Y-_0x53/2;
                        _0x19.Box.Visible=true;
                        _0x19.Box.Size=Vector2.new(_0x54,_0x53);
                        _0x19.Box.Position=Vector2.new(_0x55,_0x56);
                        _0x19.Box.Color=_0x51;
                        _0x19.Name.Visible=true;
                        _0x19.Name.Text=_0x13.Name;
                        _0x19.Name.Position=Vector2.new(_0x4f.X,_0x56-18);
                        _0x19.Name.Color=_0x51;
                        _0x19.HealthBar.Visible=true;
                        local _0x57=_0x4e.Health/_0x4e.MaxHealth;
                        _0x19.HealthBar.Color=Color3.new(1-_0x57,_0x57,0);
                        _0x19.HealthBar.From=Vector2.new(_0x55-5,_0x56+_0x53);
                        _0x19.HealthBar.To=Vector2.new(_0x55-5,_0x56+_0x53-_0x53*_0x57);
                        if _0x4a then
                            _0x19.Distance.Visible=true;
                            _0x19.Distance.Text=string.format("%.0fm",(_0x4c.Position-_0x4a.Position).Magnitude);
                            _0x19.Distance.Position=Vector2.new(_0x4f.X,_0x56+_0x53+5);
                            _0x19.Distance.Color=_0x51;
                        end;
                    end;
                end;
            end;
        end;
        if _0x7.States.Crosshair and Drawing then
            local _0x58=Vector2.new(_0x48.ViewportSize.X/2,_0x48.ViewportSize.Y/2);
            _0x8.CrosshairLines.H.Visible=true;
            _0x8.CrosshairLines.H.From=Vector2.new(_0x58.X-10,_0x58.Y);
            _0x8.CrosshairLines.H.To=Vector2.new(_0x58.X+10,_0x58.Y);
            _0x8.CrosshairLines.V.Visible=true;
            _0x8.CrosshairLines.V.From=Vector2.new(_0x58.X,_0x58.Y-10);
            _0x8.CrosshairLines.V.To=Vector2.new(_0x58.X,_0x58.Y+10);
        elseif Drawing then
            _0x8.CrosshairLines.H.Visible=false;
            _0x8.CrosshairLines.V.Visible=false;
        end;
    end);
    _0x8.HeartbeatConn=_0x1.R.Heartbeat:Connect(function()
        local _0x49=_0x2.Character;
        local _0x4a=_0x49 and _0x49:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116");
        local _0x4e=_0x49 and _0x49:FindFirstChild("\72\117\109\97\110\111\105\100");
        if not _0x4a or not _0x4e then return end;
        if _0x7.States.NoFall then
            if _0x4a.AssemblyLinearVelocity.Y<-30 then
                _0x4a.AssemblyLinearVelocity=Vector3.new(_0x4a.AssemblyLinearVelocity.X,-30,_0x4a.AssemblyLinearVelocity.Z);
            end;
        end;
        if _0x7.States.Noclip then
            for _,_0xe in pairs(_0x49:GetDescendants()) do
                if _0xe:IsA("\66\97\115\101\80\97\114\116") then _0xe.CanCollide=false end;
            end;
        end;
        if _0x7.States.Fly then
            local _0x59=_0x4a:FindFirstChild("\88\95\78\97\110\111\95\70\108\121\95\76\86");
            if not _0x59 then
                _0x59=Instance.new("\76\105\110\101\97\114\86\101\108\111\99\105\116\121");
                _0x59.Name="\88\95\78\97\110\111\95\70\108\121\95\76\86";
                local _0x5a=_0x4a:FindFirstChildOfClass("\65\116\116\97\99\104\109\101\110\116") or Instance.new("\65\116\116\97\99\104\109\101\110\116",_0x4a);
                _0x59.Attachment0=_0x5a;
                _0x59.MaxForce=math.huge;
                _0x59.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector;
                _0x59.Parent=_0x4a;
            end;
            local _0x5b=Vector3.zero;
            local _0x5c=_0x3.CFrame;
            if _0x1.U:IsKeyDown(Enum.KeyCode.W) then _0x5b=_0x5b+_0x5c.LookVector end;
            if _0x1.U:IsKeyDown(Enum.KeyCode.S) then _0x5b=_0x5b-_0x5c.LookVector end;
            if _0x1.U:IsKeyDown(Enum.KeyCode.A) then _0x5b=_0x5b-_0x5c.RightVector end;
            if _0x1.U:IsKeyDown(Enum.KeyCode.D) then _0x5b=_0x5b+_0x5c.RightVector end;
            if _0x1.U:IsKeyDown(Enum.KeyCode.E) or _0x1.U:IsKeyDown(Enum.KeyCode.Space) then _0x5b=_0x5b+Vector3.yAxis end;
            if _0x1.U:IsKeyDown(Enum.KeyCode.Q) or _0x1.U:IsKeyDown(Enum.KeyCode.LeftShift) then _0x5b=_0x5b-Vector3.yAxis end;
            _0x59.VectorVelocity=_0x5b.Magnitude>0 and _0x5b.Unit*_0x7.Vals.FlySpeed or Vector3.zero;
            if _0x4e:GetState()~=Enum.HumanoidStateType.Physics then
                pcall(function() _0x4e:ChangeState(Enum.HumanoidStateType.Physics) end);
            end;
            for _,_0xe in pairs(_0x49:GetDescendants()) do
                if _0xe:IsA("\66\97\115\101\80\97\114\116") then _0xe.CanCollide=false end;
            end;
        else
            local _0x59=_0x4a:FindFirstChild("\88\95\78\97\110\111\95\70\108\121\95\76\86");
            if _0x59 then _0x59:Destroy() end;
            if _0x4e:GetState()==Enum.HumanoidStateType.Physics then
                pcall(function() _0x4e:ChangeState(Enum.HumanoidStateType.Running) end);
            end;
        end;
        if _0x7.States.SpeedHack then
            local _0x5d=math.min(_0x7.Vals.WalkSpeed,32);
            _0x4e.WalkSpeed=_0x5d;
            local _0x5e=_0x4a:FindFirstChild("\88\95\78\97\110\111\95\83\112\101\101\100\95\76\86");
            if not _0x5e then
                _0x5e=Instance.new("\76\105\110\101\97\114\86\101\108\111\99\105\116\121");
                _0x5e.Name="\88\95\78\97\110\111\95\83\112\101\101\100\95\76\86";
                local _0x5a=_0x4a:FindFirstChildOfClass("\65\116\116\97\99\104\109\101\110\116") or Instance.new("\65\116\116\97\99\104\109\101\110\116",_0x4a);
                _0x5e.Attachment0=_0x5a;
                _0x5e.MaxForce=5000;
                _0x5e.VelocityConstraintMode=Enum.VelocityConstraintMode.Line;
                _0x5e.Parent=_0x4a;
            end;
            local _0x5f=_0x4e.MoveDirection;
            if _0x5f.Magnitude>0.1 then
                local _0x60=_0x7.Vals.WalkSpeed-_0x5d;
                _0x5e.LineVelocity=_0x60>0 and _0x60 or 0;
                _0x5e.LineDirection=_0x5f;
            else
                _0x5e.LineVelocity=0;
            end;
        else
            _0x4e.WalkSpeed=16;
            local _0x5e=_0x4a:FindFirstChild("\88\95\78\97\110\111\95\83\112\101\101\100\95\76\86");
            if _0x5e then _0x5e:Destroy() end;
        end;
        if _0x7.States.InfJump and _0x1.U:IsKeyDown(Enum.KeyCode.Space) then
            pcall(function() _0x4e:ChangeState(Enum.HumanoidStateType.Jumping) end);
            _0x4e.Jump=true;
        end;
    end);
    _0x8.InputConn=_0x1.U.InputBegan:Connect(function(_0x61,_0x62)
        if _0x62 then return end;
        if _0x61.KeyCode==_0x7.Keys.Menu and _0x8.MainFrame then
            _0x8.MainFrame.Visible=not _0x8.MainFrame.Visible;
        end;
        if _0x61.KeyCode==_0x7.Keys.Unload then
            _0x43.Unload();
            return;
        end;
        if _0x61.KeyCode==_0x7.Keys.Fly then
            _0x7.States.Fly=not _0x7.States.Fly;
        end;
        if _0x61.KeyCode==_0x7.Keys.Noclip then
            _0x7.States.Noclip=not _0x7.States.Noclip;
            if not _0x7.States.Noclip then _0x9.ResetCollision() end;
        end;
    end);
end;

_0x43.Init();
_0x9.Notify("\226\156\133\32\88\32\78\65\78\79\32".._0x7.Seller.Version,"\76\111\97\100\101\100\33\32\80\114\101\115\115\32\73\78\83\69\82\84");