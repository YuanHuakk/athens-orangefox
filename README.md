# OrangeFox Recovery · REDMI K100 Pro

**OrangeFox R12.0 Beta｜机型 athens（M511CD）｜Android 16**

---

## 基本信息

- **机型**：REDMI K100 Pro，型号 M511CD（POCO F9 Pro 为同机换标）
- **代号**：athens
- **平台**：骁龙 8 Elite Gen 5 / SM8850（canoe）
- **系统**：Android 16（SDK 36）
- **内核**：6.12.69-android16
- **分区**：A/B + 虚拟 A/B，保留独立 recovery 分区

---

## ⚠️ 刷前必读

- 本机型有 **anti-rollback（防回滚）保护**，**请勿降级官方固件版本**，否则会变砖
- 务必确认 Bootloader 已解锁
- 刷入前请备份重要数据

---

## 功能

- **加密解密** — 支持 metadata 加密的 FBE，解锁后 /data 正常读写
- **硬件按键截图** — 音量下 + 电源，存到 /sdcard/Fox/screenshots/
- **手电筒** — 音量上 + 电源
- **CPU 温度** — 读真实核心温度传感器，锁屏页显示
- **MTP** — 默认关闭，需要时在「挂载」页手动开启
- **ADB / Sideload / Fastbootd** — 齐全
- **备份恢复** — boot / init_boot / vendor_boot / dtbo 等，整分区镜像
- **ZIP 刷写** — 支持未签名 ZIP

---

## 刷入

**方式一 · 卡刷（推荐）**

把 `OrangeFox-R12.0-Beta-athens.zip` 放进手机，在现有第三方 recovery 里直接刷入，刷完自动回到新 recovery。

**方式二 · 线刷**

```
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img
```

---

## 请注意

- 本机型有独立 recovery 分区，刷 recovery **不影响系统和其他分区**
- 首次进入会要求输入锁屏密码解密 /data
- 截图请用**音量下 + 电源**，两个键先后顺序不限
- 若卡在第一屏，用 fastboot 先重刷一次本镜像，仍不行再刷回原厂

---

## 仓库结构

```
device/xiaomi/athens/    设备树
manifest/orangefox.xml   构建基座
patches/                 对上游 TWRP / OrangeFox 的修补
.github/workflows/       CI
```

OrangeFox 官方 Android 16 manifest 不可匿名访问，故自带一份：以公开的 twrp-16 为底，
把 OrangeFox 分叉的组件换回各自公开的 `fox_16.0` 分支。

---

## 构建

**CI** — Actions → _Build OrangeFox_ → _Run workflow_。默认出 `Beta`，产物在 run 页面下载；
勾选 `create_release` 或推 `v*` tag 会发 Release。

**本地** —

```bash
R=~/athens-orangefox            # 本仓库
T=~/athens-tree && mkdir -p "$T" && cd "$T"

repo init --depth=1 -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git -b twrp-16.0
mkdir -p .repo/local_manifests && cp "$R/manifest/orangefox.xml" .repo/local_manifests/
repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --no-tags

cp -a "$R/device/xiaomi/athens" device/xiaomi/athens
git -C bootable/recovery apply "$R/patches/0001-recovery-athens.patch"
git -C frameworks/native apply "$R/patches/0002-frameworks-native-servicemanager-rc.patch"

export LC_ALL=C FOX_BUILD_DEVICE=athens FOX_BUILD_TYPE=Beta
. build/envsetup.sh && lunch twrp_athens-bp2a-eng
mka adbd recoveryimage
```

- `export` 必须在 `. build/envsetup.sh` **之前**，否则会静默构建成非 A/B 设备
- **别把 `FOX_BUILD_TYPE` 设成 `Stable`** —— 会静默拆掉 adbd / MTP / sideload。用 `Beta`
- 需要约 75 GB 磁盘；32 GB 内存较舒适，27 GB 需加 swap

补丁为什么这么改，理由都写在补丁注释里；设备树各非显然取值的理由写在
`device/xiaomi/athens/BoardConfig.mk`。

---

## 鸣谢与许可

**GPLv3-or-later**，全文见 [LICENSE](LICENSE)。

- `device/xiaomi/athens/`、`patches/0001-recovery-athens.patch` —— 修改自
  [TeamWin Recovery Project](https://github.com/TeamWin) 与
  [OrangeFox Recovery Project](https://gitlab.com/OrangeFox)（GPLv3-or-later）。
  上游版权：`Copyright (c) 2011-2016, Dees_Troy, bigbiff, Team Win` /
  `Copyright (c) 2018-2020, MrYacha, DarthJabba9, OrangeFox Recovery Team`
- `patches/0002-frameworks-native-servicemanager-rc.patch` —— 修改自 AOSP
  `frameworks/native`（Apache-2.0，可并入 GPLv3），版权归 The Android Open Source Project
