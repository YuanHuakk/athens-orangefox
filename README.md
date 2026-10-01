# OrangeFox Recovery for REDMI K100 Pro

适用于 `athens` 的 OrangeFox Recovery 设备树及构建补丁。

| 项目 | 信息 |
| --- | --- |
| 设备 | REDMI K100 Pro（M511CD） |
| 代号 | `athens` |
| 平台 | Qualcomm SM8850（`canoe`） |
| Recovery | OrangeFox R12.0 Beta |
| 设备树版本 | v1.3 |
| 适配目标 | Android 16 / 17（SDK 36 / 37） |
| 构建基座 | Android 16（SDK 36） |
| 内核 | 6.12.69-android16 |
| 分区布局 | Virtual A/B，独立 `recovery_a` / `recovery_b` |

## 下载

- [版本发布](https://github.com/YuanHuakk/athens-orangefox/releases)
- [构建记录](https://github.com/YuanHuakk/athens-orangefox/actions/workflows/build.yml)

发布文件包括 Recovery 镜像（`.img`）、安装包（`.zip`）及校验文件。

## 功能与兼容性

- FBE 与 metadata 加密解密
- ADB、ADB Sideload、Fastbootd
- MTP 文件传输，默认关闭，可在「挂载」页面开启；格式化 Data 后可直接传文件，Recovery 中从 `/sdcard` 访问
- 分区镜像备份、恢复及 ZIP 安装
- 截图：音量下 + 电源，保存至 `/sdcard/Fox/screenshots/`
- 手电筒：音量上 + 电源
- CPU 温度显示

## 安装

安装前需解锁 Bootloader，并备份重要数据。使用与设备匹配的固件，避免降级触发防回滚限制。格式化 Data 会清除内置存储。

### Recovery 安装

1. 下载 `OrangeFox-R12.0-Beta-athens.zip`。
2. 进入现有第三方 Recovery，选择并安装 ZIP。
3. 重启至 Recovery。

### Fastboot 安装

进入 Bootloader Fastboot 模式，在镜像所在目录执行：

```bash
fastboot flash recovery_a OrangeFox-R12.0-Beta-athens.img
fastboot flash recovery_b OrangeFox-R12.0-Beta-athens.img
fastboot reboot recovery
```

如下载文件名称不同，请替换命令中的镜像文件名。

## 构建

### GitHub Actions

在 **Actions → Build OrangeFox → Run workflow** 中启动构建，默认类型为 `Beta`。构建产物可从运行页面下载；选择 `create_release` 或推送 `v*` 标签时发布 GitHub Release。

### 本地构建

使用 Linux 构建环境，安装 `repo`、Git、Python 3、JDK 17 及 Android 构建依赖。依赖清单见 [构建工作流](.github/workflows/build.yml)。参考配置为 32 GB 内存、至少 100 GB 可用磁盘空间。

以下命令适用于首次检出。`RECOVERY_REPO` 指向本仓库，`ANDROID_TREE` 指向 Android 源码目录。

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

mkdir -p "$HOME/bin"
ln -sf /usr/bin/python3 "$HOME/bin/python"
export PATH="$HOME/bin:$PATH"
export LC_ALL=C FOX_BUILD_DEVICE=athens FOX_BUILD_TYPE=Beta
source build/envsetup.sh
lunch twrp_athens-bp2a-eng
mka adbd recoveryimage
```

产物位于 `out/target/product/athens/`。

构建要求：

- 在加载 `build/envsetup.sh` 前设置 `FOX_BUILD_DEVICE` 和 `FOX_BUILD_TYPE`。
- 使用 `Beta` 构建类型；当前配置下，`Stable` 会禁用 ADB、MTP 和 Sideload。
- 构建脚本不应启用 `set -u`，上游环境脚本会读取尚未赋值的变量。
- 上游项目版本由基础 manifest 和 `manifest/orangefox.xml` 固定；补丁须按上述顺序应用。

## 目录结构

```text
device/xiaomi/athens/    设备配置、内核及 Recovery 资源
manifest/orangefox.xml  上游项目及版本配置
patches/               上游源码补丁
.github/workflows/     GitHub Actions 构建配置
```

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
