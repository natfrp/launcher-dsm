# SakuraFrp 启动器 DSM 软件包

实验性项目，我们没有采用任何现存构建系统，因为：

- 构建 SPK 的过程不涉及编译，只是单纯的打了个包
- 由于没有多余的维护精力，暂无加入任何第三方源的计划

### Important Notice About License / 关于授权的重要声明

This project is inspired by [SynoCommunity/spksrc](https://github.com/SynoCommunity/spksrc).

Most script code comes from their amazing work, therefore `LICENSE-SynoCommunity.md` applies to the following files:

```tree
spk
├── conf
│   └── resource
├── INFO
└── scripts
    ├── functions
    ├── postinst
    ├── postuninst
    ├── postupgrade
    ├── preinst
    ├── preuninst
    ├── preupgrade
    ├── service-setup [file modified to execute our postinst logic]
    └── start-stop-status
spk-6.0-7321/
├── conf
│   └── privilege
└── scripts
    └── installer
spk-7.0-41890/
├── conf
│   └── privilege
├── scripts
│   └── installer
└── WIZARD_UIFILES
    └── uninstall_uifile
```

Other text files not listed above are licensed under `LICENSE-AGPLv3`.

### 下载

获取 SPK 文件：https://nya.globalslb.net/natfrp/client/launcher-dsm/

只要架构正确就可以直接安装 SPK，应该不存在兼容问题，二进制文件都是全静态的。

### 系统需求

 - DSM 6.0 及以上版本
