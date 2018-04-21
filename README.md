# Alpface
* [学习抖音的iOS项目](https://github.com/alpface/alpface)
* [服务端开源项目](https://github.com/alpface/ShortVideo)


##### animated webp 制作 及 展示
[ffmpeg 制作 webp动图](http://www.alpface.com/article/2018/4/15/53.html)


##### 实战中遇到的问题及解决方案

- 2018-4-15 使用animated webp 替换 gif 优化加载动图时 app内存飙升问题
> 问题描述:
在此之前客户端的动图是gif，并使用[Gifu](https://github.com/kaishin/Gifu.git)中提供的`GIFImageView`展示图片，但是同时加载很多gif时，就会出现内存飙升问题；然后我尝试把Gifu换成[YYWebImage](https://github.com/ibireme/YYWebImage.git)，并使用YYImage中`YYAnimatedImageView`展示图片，同时加载多个图片时内存依旧飙升的很高，直到app被系统杀死。

优化方案:
使用webp 动图 替代gif，并使用SDWebImage加载图片，
为什么我会使用这种方法，最初写这个项目就是为了学习抖音，我逆向过抖音iOS客户端项目，发现其使用的是YYAnimatedImageView展示动图，抓包抖音的动图发现其格式为webp，抖音展示动图的页面滑动起来很流畅，虽然内存也会有所增长，但并不明显；今天我在服务端上传图片的方法中，添加了ffmpeg制作animated webp，客户端效果果然有所提升。



- cocoapods 安装libwebp v0.6.0时可能会遇到的超时问题:
```
[!] Error installing libwebp
[!] /usr/bin/git clone https://chromium.googlesource.com/webm/libwebp /var/folders/p6/t42f8nmd7332018zm9m2s3d80000gn/T/d20180415-42656-1hjxh43 --template= --single-branch --depth 1 --branch v0.6.0

Cloning into '/var/folders/p6/t42f8nmd7332018zm9m2s3d80000gn/T/d20180415-42656-1hjxh43'...
fatal: unable to access 'https://chromium.googlesource.com/webm/libwebp/': Failed to connect to chromium.googlesource.com port 443: Operation timed out

```
解决方法:
尝试过翻墙，修改host，均无效
最终，修改pod repo中libwebp的git source 地址，再执行pod install 解决，
但是我们需要有一个有效的libwebp的git仓库，在github上找到了一个`https://github.com/webmproject/libwebp.git`，可以看到`mirrored from https://chromium.googlesource.com/webm/libwebp`，而且正好有我需要的版本0.6.0, 那么我就替换为这个。
下面是步骤:
1. 查看mac中cocoapods 本地库路径: 
```
swaedeMacBook-Pro:alpface swae$ pod repo
``` 
```
swaedeMacBook-Pro:alpface swae$ pod repo
/Users/swae/.rbenv/versions/2.5.0/lib/ruby/gems/2.5.0/gems/cocoapods-1.4.0/lib/cocoapods/executable.rb:89: warning: Insecure world writable dir /opt in PATH, mode 040777

master
- Type: git (master)
- URL:  https://github.com/CocoaPods/Specs.git
- Path: /Users/swae/.cocoapods/repos/master
```
2. 在本地库中, 并找到对应的libwebp版本的文件
```
swaedeMacBook-Pro:alpface swae$ find /Users/swae/.cocoapods/repos/master -iname libwebp
/Users/swae/.cocoapods/repos/master/Specs/1/9/2/libwebp
```
进入libwebp目录，可以看到你的仓库中有哪些对应的版本
```
swaedeMacBook-Pro:libwebp swae$ cd /Users/swae/.cocoapods/repos/master/Specs/1/9/2/libwebp
swaedeMacBook-Pro:libwebp swae$ ls -l
total 0
drwxr-xr-x  3 swae  staff  96 12  3 21:50 0.4.1
drwxr-xr-x  3 swae  staff  96 12  3 21:50 0.4.2
drwxr-xr-x  3 swae  staff  96 12  3 21:50 0.4.3
drwxr-xr-x  3 swae  staff  96 12  3 21:50 0.4.4
drwxr-xr-x  3 swae  staff  96 12  3 21:50 0.5.0
drwxr-xr-x  3 swae  staff  96 12  3 21:50 0.5.1
drwxr-xr-x  3 swae  staff  96 12  3 21:50 0.5.2
drwxr-xr-x  3 swae  staff  96 12  3 21:50 0.6.0
```
由于SDWebImage 依赖的 libwebp版本为0.6.0，所以我们进入0.6.0中，并做修改
```
swaedeMacBook-Pro:libwebp swae$ cd 0.6.0/
swaedeMacBook-Pro:0.6.0 swae$ ls -l
total 8
-rw-r--r--@ 1 swae  staff  1587  4 15 09:53 libwebp.podspec.json
```
在0.6.0目录下的libwebp.podspec.json文件中修改git source
```
swaedeMacBook-Pro:0.6.0 swae$ sudo vim libwebp.podspec.json
```
找到
```
"source": {
"git": "https://chromium.googlesource.com/webm/libwebp",
"tag": "v0.6.0"
},
```
将其中的`"git"` 对应的url替换为`https://github.com/webmproject/libwebp.git`，
最后再执行`pod install`, 完成
```
swaedeMacBook-Pro:alpface swae$ pod install
/Users/swae/.rbenv/versions/2.5.0/lib/ruby/gems/2.5.0/gems/cocoapods-1.4.0/lib/cocoapods/executable.rb:89: warning: Insecure world writable dir /opt in PATH, mode 040777
Analyzing dependencies
Downloading dependencies
Installing SDWebImage (4.3.3)
Installing libwebp (0.6.0)
Generating Pods project
Integrating client project
Sending stats
Pod installation complete! There are 8 dependencies from the Podfile and 9 total pods installed.
```




