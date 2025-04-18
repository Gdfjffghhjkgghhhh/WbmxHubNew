local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()

local Window = redzlib:MakeWindow({
  Title = "Wbmx Hub",
  SubTitle = "(Premium)",
  SaveFolder = "Redz | redz lib v5.lua"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://85703763384134", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(0, 5) },
})

local Tab = Window:MakeTab({"Discord", "info"})

Tab:AddDiscordInvite({
    Name = "Wbmx Hub",
    Description = "Join our discord community to receive information about the next update",
    Logo = "rbxassetid://85703763384134",
    Invite = "",
})

local Tab2 = Window:MakeTab({"Farm", "home"})

local Dropdown = Tab2:AddDropdown({
  Name = "Chọn Vũ Khí",
  Description = "Chọn vũ khí bạn muốn sử dụng",
  Options = {"Melee", "Blox Fruit", "Sword"},
  Default = "Melee",
  Flag = "Melee",
  Callback = function()
    
  end
})

local Dropdown = Tab2:AddDropdown({
  Name = "Kích Thước Ui",
  Description = "Điều chỉnh kích thước giao diện",
  Options = {"Nhỏ", "Trung bình", "Lớn", "Siêu lớn"},
  Default = "Trung bình",
  Flag = "Trung bình",
  Callback = function()
    
  end
})

local Section = Tab2:AddSection({"Farm"})

Tab2:AddToggle({
    Name = "Auto farm level",
    Description = "Tự động farm cấp",
    Default = false,
    Callback = function()

    end
})

Tab2:AddToggle({
    Name = "Farm Hết Map",
    Description = "Tự động tiêu diệt kẻ địch gần nhất",
    Default = false,
    Callback = function()

    end
})

Tab2:AddToggle({
    Name = "Farm Hải Tặc",
    Description = "Tự động hoàn thành sự kiện hải tặc ở Castelo do Mar",
    Default = false,
    Callback = function()

    end
})


local Section = Tab2:AddSection({"Xương"})

Tab2:AddToggle({
    Name = "Farm Xương",
    Description = "Tự động farm xương",
    Default = false,
    Callback = function()

    end
})

Tab2:AddToggle({
    Name = "Auto Soul Reaper",
    Description = "Triệu hồi và tiêu diệt Soul Reaper",
    Default = false,
    Callback = function()

    end
})

Tab2:AddToggle({
    Name = "Random Bones",
    Description = "Tự động đổi xương lấy phần thưởng",
    Default = false,
    Callback = function()

    end
})

local Section = Tab2:AddSection({"Rương"})

Tab2:AddToggle({
    Name = "Auto Chess",
    Description = "Tự động nhặt rương",
    Default = false,
    Callback = function()

    end
})

local Section = Tab2:AddSection({"Boss"})

Tab2:AddButton({
    Name = " Làm Mới Boss",
    Description = "Làm mới danh sách boss",
    Default = false,
    Callback = function()

    end
})

local Dropdown = Tab2:AddDropdown({
  Name = "Danh Sách Boss",
  Description = "Chọn boss để tấn công",
  Options = {"Boss1", "Boss2", "Boss3"},
  Default = "nil",
  Flag = "nil",
  Callback = function()
    
  end
})

Tab2:AddToggle({
    Name = "Kill Boss",
    Description = "Tự động tấn công boss đã chọn",
    Default = false,
    Callback = function()

    end
})

Tab2:AddToggle({
    Name = "Farm All Boss",
    Description = "Tự động tấn công mọi boss có sẵn",
    Default = false,
    Callback = function()

    end
})

Tab2:AddToggle({
    Name = "Nhận Nhiệm Vụ Boss",
    Description = "Tự động nhận nhiệm vụ boss",
    Default = true,
    Callback = function()

    end
})

local Section = Tab2:AddSection({"Material"})

local Dropdown = Tab2:AddDropdown({
  Name = "Danh Sách Nguyên Liệu",
  Description = "Chọn boss để tấn công",
  Options = {"Nguyên Liệu1", "Nguyên Liệu2", "Nguyên Liệu3"},
  Default = "nil",
  Flag = "nil",
  Callback = function()
    
  end
})

Tab2:AddToggle({
    Name = "Farm Nguyên Liệu",
    Description = "Tự động farm nguyên liệu",
    Default = false,
    Callback = function()

    end
})

local Section = Tab2:AddSection({"Mastery"})

Tab2:AddSlider({
  Name = "Chọn Máu Kẻ Địch [ % ]",
  Description = "Thiết lập phần trăm máu kẻ địch để tấn công",
  Min = 10,
  Max = 100,
  Increase = 1,
  Default = 16,
  Callback = function()
  
  end
})

local Dropdown = Tab2:AddDropdown({
  Name = "Chọn Công Cụ",
  Description = "Chọn công cụ bạn muốn sử dụng",
  Options = {"Blox Fruit", "Gun"},
  Default = "Blox Fruit",
  Flag = "Blox Fruit",
  Callback = function()
    
  end
})

local Dropdown = Tab2:AddDropdown({
  Name = "Chọn Kỹ Năng",
  Description = "Chọn kỹ năng để sử dụng",
  Options = {"Z", "X", "C", "V", "F"},
  Default = "Z",
  Flag = "Z",
  Callback = function()
    
  end
})

Tab2:AddToggle({
    Name = "Farm Thông Thạo",
    Description = "Tăng thành thạo kỹ năng tự động",
    Default = false,
    Callback = function()

    end
})




local Tab3 = Window:MakeTab({"Nhiệm Vụ/Vật Phẩm", "swords"})

local Section = Tab3:AddSection({"Dragon Dojo"})

Tab3:AddToggle({
    Name = "Nhiệm Vụ Dojo",
    Description = "Tự động hoàn thành nhiệm vụ đai",
    Default = false,
    Callback = function()

    end
})

Tab3:AddToggle({
    Name = "Nhiệm Vụ Dragon Hunter",
    Description = "Mỗi nhiệm vụ hoàn thành nhận 'Blaze Ember'",
    Default = false,
    Callback = function()

    end
})

Tab3:AddToggle({
    Name = "Auto Draco V2 & V3",
    Description = "Tự động lên cấp Draco V2 và V3",
    Default = false,
    Callback = function()

    end
})
















local Tab4 = Window:MakeTab({"Trái/Đột Kích", "cherry"})

local Tab5 = Window:MakeTab({"Stats", "signal"})

local Tab6 = Window:MakeTab({"Dịch Chuyển", "locate"})

local Tab7 = Window:MakeTab({"Giao Diện", "user"})

local Tab8 = Window:MakeTab({"Cửa Hàng", "shoppingCart"})

local Tab9 = Window:MakeTab({"Khác", "settings"})


