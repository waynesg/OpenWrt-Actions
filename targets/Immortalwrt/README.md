# targets/Immortalwrt

这个 preset 专门用于 ImmortalWrt x86_64 (openwrt-24.10)。

- `settings.ini`：编译参数（源码仓库/分支、是否发布 Release、通知渠道、是否使用缓存等）
- `.config`：你的编译配置（建议保持 `CONFIG_TARGET_x86_64=y`）
- `diy-part.sh`：你的自定义补丁/插件脚本
- `waynesg/*`：你额外的脚本（如 clash core、额外 feeds/包等）

## Secrets
如果你要通知：
- Telegram：`TELEGRAM_BOT_TOKEN` + `TELEGRAM_CHAT_ID`
- PushPlus：`PUSH_PLUS_TOKEN`

Release token：可选 `REPO_TOKEN`（不填则用默认 `GITHUB_TOKEN`）。
