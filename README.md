# AutoBuild-OpenWrt-Actions (waynesg)

这是基于你原来的 `waynesg/AutoBuild-OpenWrt` 的自定义脚本/配置，参考 `lwb1978/OpenWrt-Actions` 的目录与 workflow 思路，重构出来的一套“Actions 全量编译”仓库模板。

## 目标
- 不用 ImageBuilder：直接从源码（目前只保留 ImmortalWrt x86_64）全量编译
- 保留你现有的自定义：`.config`、`diy-part.sh`、`waynesg/*` 脚本（如 preset-clash-core、diy-repo-script 等）
- workflow 更像 lwb1978 那种：统一 `/builder` 工作目录、统一初始化环境、统一上传产物/Release

## 目录结构
- `targets/<target>/settings.ini`：定义 REPO_URL / REPO_BRANCH / DIY_PART_SH / UPLOAD_* 等
- `targets/<target>/.config`：你的编译配置
- `targets/<target>/diy-part.sh`：你的自定义脚本
- `targets/<target>/waynesg/*`：你自己的额外脚本（如有）
- `scripts/common/*`：从原仓库 `build/common` 复制来的通用脚本
- `.github/workflows/openwrt-build.yml`：新的统一构建 workflow

## 使用
1. 在 GitHub 新建仓库（比如 `AutoBuild-OpenWrt-Actions`）
2. 把本目录内容 push 上去
3. 进 Actions → 运行 `OpenWrt Build (matrix)`，选择 target / 分支等输入

> 说明：当前 workflow 默认使用 `scripts/common/Custom/ubuntu.sh` 做依赖安装（本地脚本），避免 `curl | bash` 供应链风险。
