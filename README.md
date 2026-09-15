# 🎮 Blox Fruits Auto Farm Bot

Script auto farm cho game **Blox Fruits** trên Roblox.  
Tự động nhận quest, bay đến bãi farm, đánh quái, và chuyển vùng khi lên level.

---

## 🚀 Cách sử dụng

Paste dòng này vào **Executor** (Synapse X, Fluxus, Delta, ...):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/dubaonhan-droid/blox-fruits/main/app.lua"))()
```

---

## 📂 Cấu trúc dự án

```
blox_fruits/
│
├── call.lua                 # 🔌 Loader — dòng lệnh paste vào executor
├── app.lua                  # 🏠 Entry point — khởi chạy UI + AutoFarm
│
├── UI/                      # 🖥️ Giao diện người dùng
│   ├── main_ui.lua          #    Quản lý trạng thái (bật/tắt Auto Farm)
│   └── menu.lua             #    Vẽ giao diện Menu (Orion Library)
│
├── core/                    # ⚙️ Logic xử lý chính
│   └── auto_farm.lua        #    Vòng lặp farm tuần tự
│
└── config/                  # 📋 Dữ liệu cấu hình
    └── mob_data.lua         #    Bảng quái vật theo cấp độ
```

---

## 🔄 Flow hoạt động

```
┌─────────────────────────────────────────────────────────┐
│                    VÒNG LẶP CHÍNH                       │
│                                                         │
│   1. 📊 Kiểm tra Level hiện tại                        │
│           ↓                                             │
│   2. 🔍 Tra bảng mob_data → tìm quest phù hợp         │
│           ↓                                             │
│   3. 🚶 Bay đến NPC → Nhận Quest                       │
│           ↓                                             │
│   4. ✈️  Bay đến bãi farm                               │
│           ↓                                             │
│   5. ⚔️  Farm quái (gom + chém) cho đến khi quest xong  │
│           ↓                                             │
│   6. 🎉 Quest hoàn thành → Quay lại bước 1             │
│          (Nếu lên level mới → tự chuyển vùng farm)     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Thêm quái / map mới

Chỉ cần mở file `config/mob_data.lua` và thêm 1 block mới:

```lua
{
    MinLevel = 100,
    MaxLevel = 149,
    MobName = "Pirate",
    QuestName = "PirateQuest",
    QuestLevel = 1,
    QuestGiverName = "Pirate Quest Giver",
    QuestNpcPosition = nil,   -- Vector3.new(x, y, z) nếu biết
    FarmPosition = nil,       -- Vector3.new(x, y, z) nếu biết
},
```

**Không cần sửa bất kỳ file nào khác** — bot sẽ tự nhận diện và farm quái mới.

---

## ⚙️ Cấu hình nhanh

| Tham số | Mô tả | Giá trị mặc định |
|---------|--------|-------------------|
| `TWEEN_SPEED` | Tốc độ bay (studs/giây) | `300` |
| `FLOAT_HEIGHT` | Độ cao lơ lửng trên quái | `20` |
| `ATTACK_RANGE` | Khoảng cách gom quái trước mặt | `5` |

> Thay đổi trong file `core/auto_farm.lua` phần **CẤU HÌNH**.

---

## 🔗 Chuỗi load từ GitHub

```
Executor
  └── call.lua
        └── app.lua
              ├── UI/main_ui.lua
              │     └── UI/menu.lua
              └── core/auto_farm.lua
                    └── config/mob_data.lua
```

Tất cả file được kéo về qua `loadstring(game:HttpGet(...))()` — không dùng `require()`.

---

## 📝 TODO

- [ ] Thay `GetPlayerLevel()` bằng code lấy level thật
- [ ] Thay `IsQuestComplete()` bằng code kiểm tra quest thật
- [ ] Thêm Remote Event nhận quest thật
- [ ] Thêm tọa độ NPC và bãi farm vào `mob_data.lua`
- [ ] Bỏ comment code Orion Library trong `menu.lua` để hiện GUI thật

---

> **Made by** [dubaonhan-droid](https://github.com/dubaonhan-droid)
