# 安装软件包
## 基础软件包
```sh
# 基础软件
sudo apt install -y curl git gpg xxd vim ethtool
```
## 字体包
```sh
# 安装字体管理工具, 包含fc-list, fc-cache
sudo apt install -y fontconfig
# 刷新字体缓存
fc-cache -fv
# 查看字体信息
fc-query PATH/TO/FONT.ttf
# 查询所有字体列
fc-list
# 安装字体
sudo apt install -y 
# 查看字体包内有哪些字体
dpkg -L fonts-terminus

# 安装nerd字体
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
# 先确保目录存在
sudo mkdir -p /usr/share/fonts/truetype/jetbrains-mono-nerd
# 解压到指定目录.
# .tar.xz 用 -J，.tar.bz2 用 -j，.tar.gz 用 -z，也可统一用 tar -xf 适配所有 tar 压缩包
tar -xf JetBrainsMono.tar.xz -C /usr/share/fonts/truetype/jetbrains-mono-nerd
# 刷新字体缓存
fc-cache -fv
```
## 添加配置
```
sh ./create_safe_symlink.sh
```