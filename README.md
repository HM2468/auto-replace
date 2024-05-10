# 使用说明

### 系统要求
1. ruby 版本2.6.x 以上，检查ruby版本
`ruby -v`

2. 安装gem依赖
` gem install digest`

3. clone 仓库
```
# 这个仓库需要账号密码，群里已共享
git clone https://demo.gitlife.ru/3L-OSC/Localization-Gitee-RU/gitee-ru-localization.git

git clone https://github.com/HM2468/auto-replace.git
```
4. 替换路径

```text
全局索索替换 /Users/miaohuang/repos/scripts 为自己本地该仓库的绝对地址 XX/XX/auto-replace

全局索索替换 /Users/miaohuang/repos/gitee-ru-localization 为自己本地gitee-ru-localization仓库的绝对地址 XX/XX/gitee-ru-localization
```

### 运行脚本
```shell
# 切换到对应目录
cd ~/auto-replace/app/optimize
# 执行ruby脚本
ruby opt_exec.rb
```
