# simpvless - VLESS REALITY 一键安装脚本

这是一个专为 **NAT 机型** 优化的轻量化 Xray 安装脚本。它完美适配了 **Debian** 和 **Alpine Linux** 两种不同的系统架构，旨在提供最隐蔽、最高效的连接体验。

---

## 🌟 脚本特性

*   **全系统适配**：同时支持 `glibc` (Debian/Ubuntu) 和 `musl` (Alpine) 环境。
*   **极致伪装**：采用 `VLESS` + `XTLS-Vision` + `REALITY` 组合，消除 TLS 指纹特征。
*   **NAT 深度优化**：
    *   自动获取公网 IP。
    *   支持自定义内网监听端口。
    *   公网映射端口默认与内网一致（支持手动修改）。
    *   适配 LXC/KVM 等虚拟化架构，不强制修改内核参数。
*   **交互式菜单**：内置多个主流伪装域名，支持一键选择或自定义输入。
*   **即刻使用**：安装完成后直接输出可复制的 VLESS 链接。

*   **一键脚本**:
```bash
bash <(curl -Ls https://raw.githubusercontent.com/NetJiangHe/simpvless/main/xray.sh)
```
---

## 🛠️ 使用建议

1.  **关于端口映射**：
    *   在脚本提示“内网监听端口”时，输入你 NAT 机器面板上的内网端口。
    *   在生成链接前，脚本会提示输入“公网映射端口”，请输入服务商提供的实际公网访问端口。
2.  **关于伪装域名 (DEST)**：
    *   若创建后节点无法连接，可能由于选定的域名在当地被墙或 SNI 不匹配，建议尝试更换其他域名。
3.  **客户端要求**：
    *   请确保你的客户端（如 v2rayN, Shadowrocket, anXray 等）内核版本不低于 **1.8.0**。

---

## ⚖️ 免责声明与致谢

### 核心致谢
*   **参考项目**：本脚本逻辑借鉴了 [Lorry-San/fast-vless](https://github.com/Lorry-San/fast-vless) 的实现思路。
*   **核心开发**：感谢 [Project X](https://github.com/XTLS/Xray-core) 提供的 Xray 核心。

### 免责声明
*   本脚本仅用于网络技术研究与个人学习，请勿违反所在地法律法规。
*   作者不保证脚本在所有极端网络环境下都能完美运行，使用风险请自担。

---

## 📂 项目维护

- **源码托管**: [https://github.com/NetJiangHe/simpvless](https://github.com/NetJiangHe/simpvless)
- **反馈建议**: 欢迎提交 Issue 或 Pull Request。
