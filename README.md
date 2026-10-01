# OrangeFox Recovery for REDMI K100 Pro

REDMI K100 Pro（`athens`，SM8850）的 OrangeFox R12.0 Beta 设备树及构建补丁。

| 项目 | 信息 |
| --- | --- |
| 设备树版本 | v1.4 |
| Android | 基于 Android 16 构建，适配 Android 16 / 17 |
| 内核 | 6.12.69-android16 |
| 分区布局 | Virtual A/B，独立 `recovery_a` / `recovery_b` |

## 下载

- [版本发布](https://github.com/YuanHuakk/athens-orangefox/releases)
- [构建记录](https://github.com/YuanHuakk/athens-orangefox/actions/workflows/build.yml)

## 功能

- FBE 与 metadata 加密解密
- ADB、ADB Sideload、Fastbootd
- MTP 文件传输，默认关闭，在「挂载」页面开启
- 分区镜像备份、恢复及 ZIP 安装
- 截图：音量下 + 电源，保存至 `/sdcard/Fox/screenshots/`
- 手电筒：音量上 + 电源
- CPU 温度显示

## 安装

需解锁 Bootloader。

### Recovery 安装

在现有 Recovery 中安装 ZIP，然后重启至 Recovery。

### Fastboot 安装

进入 Bootloader Fastboot 模式，替换为下载的镜像文件名：

```bash
fastboot flash recovery_a OrangeFox-R12.0-Beta-athens.img
fastboot flash recovery_b OrangeFox-R12.0-Beta-athens.img
fastboot reboot recovery
```

## 构建

### GitHub Actions

**Actions → Build OrangeFox → Run workflow**，默认类型为 `Beta`。勾选 `create_release` 或推送 `v*` 标签可发布 Release。

### 本地构建

使用 Linux，依赖见 [构建工作流](.github/workflows/build.yml)。

首次检出及构建：

```bash
RECOVERY_REPO=~/athens-orangefox
ANDROID_TREE=~/athens-tree
mkdir -p "$ANDROID_TREE"
cd "$ANDROID_TREE"

repo init --depth=1 \
  -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git \
  -b 6f074703a0ab31f22518b1a94331b358190237ba
mkdir -p .repo/local_manifests
cp "$RECOVERY_REPO/manifest/orangefox.xml" .repo/local_manifests/
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags

mkdir -p device/xiaomi
cp -a "$RECOVERY_REPO/device/xiaomi/athens" device/xiaomi/athens
git -C bootable/recovery apply "$RECOVERY_REPO/patches/0001-recovery-athens.patch"
git -C frameworks/native apply "$RECOVERY_REPO/patches/0002-frameworks-native-servicemanager-rc.patch"
git -C hardware/nxp/keymint apply "$RECOVERY_REPO/patches/0003-hardware-nxp-keymint-recovery-sources.patch"
git -C hardware/nxp/weaver apply "$RECOVERY_REPO/patches/0004-hardware-nxp-weaver-recovery-sources.patch"
git -C hardware/interfaces apply "$RECOVERY_REPO/patches/0005-hardware-interfaces-recovery-available.patch"
git -C system/vold apply "$RECOVERY_REPO/patches/0006-system-vold-default-credential-decrypt.patch"
git -C bootable/recovery apply "$RECOVERY_REPO/patches/0007-recovery-crypto-os-version-apex.patch"
git -C bootable/recovery apply "$RECOVERY_REPO/patches/0008-recovery-fbe-media-root.patch"
git -C bootable/recovery apply "$RECOVERY_REPO/patches/0009-recovery-mtp-large-files.patch"
git -C bootable/recovery apply "$RECOVERY_REPO/patches/0010-recovery-mtp-reconnect.patch"

mkdir -p "$HOME/bin"
ln -sf /usr/bin/python3 "$HOME/bin/python"
export PATH="$HOME/bin:$PATH"
export LC_ALL=C FOX_BUILD_DEVICE=athens FOX_BUILD_TYPE=Beta
source build/envsetup.sh
lunch twrp_athens-bp2a-eng
mka adbd recoveryimage
```

产物位于 `out/target/product/athens/`。

- 使用 `Beta`；`Stable` 会禁用 ADB、MTP 和 Sideload。
- 不要启用 `set -u`，上游构建脚本会读取未赋值变量。

## 许可与致谢

本仓库采用 [GPL-3.0-or-later](LICENSE)。上游代码保留各自的版权声明与许可证。

- [TeamWin Recovery Project](https://github.com/TeamWin)
- [OrangeFox Recovery Project](https://gitlab.com/OrangeFox)
- [Android Open Source Project](https://source.android.com/)

设备树及 Recovery 补丁保留以下上游版权声明：

```text
Copyright (c) 2011-2016, Dees_Troy, bigbiff, Team Win
Copyright (c) 2018-2020, MrYacha, DarthJabba9, OrangeFox Recovery Team
```
