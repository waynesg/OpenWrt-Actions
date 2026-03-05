# AutoBuild-OpenWrt-Actions (slim)

一个精简的 OpenWrt/ImmortalWrt GitHub Actions 编译仓库：只保留你实际在用的 **ImmortalWrt x86_64**，保留你现有自定义（`.config` / `diy-part.sh` / `targets/Immortalwrt/waynesg/*`），去掉 lede/official 等不需要的结构。

## 保留的功能
- 从源码全量编译（不是 ImageBuilder）
- 可选 warmup（只下载 dl）
- 可选缓存（dl + ccache，受 `USE_CACHEWRTBUILD` 控制）
- 上传固件 artifact / 可选 release
- 失败时自动回退到 `make -j1 V=sc` 输出详细日志

## 目录结构
- `targets/Immortalwrt/settings.ini`：源码地址/分支、上传开关、缓存开关等
- `targets/Immortalwrt/.config`：你的编译配置
- `targets/Immortalwrt/diy-part.sh`：你的自定义脚本
- `targets/Immortalwrt/files/`：固件 overlay 文件
- `targets/Immortalwrt/waynesg/*`：你自己的额外脚本（如有）
- `scripts/ubuntu.sh`：安装编译依赖（本地脚本，避免 curl | bash）
- `.github/workflows/build.yml`：唯一 workflow

## Actions 输入
- `mode`: `build` / `warmup`
- `repo_branch`: 可覆盖 settings.ini 的分支
- `repo_commit`: 可选 pin 到具体 commit（短/长 SHA 都行；会先 fetch 再 checkout）
- `upload_release`: 可覆盖 release 开关
