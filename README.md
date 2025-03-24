# 2025-cyberdog-例程测试流程
我们拿到一台cyberdog之后该如何上手呢？老规矩，还是从先跑通一个例程开始
那么第一步我们就需要先了解一下什么是 linux系统(https://fishros.com/d2lros2/#/humble/chapt1/basic/1.Linux%E4%B8%8EUbuntu%E7%B3%BB%E7%BB%9F%E4%BB%8B%E7%BB%8D)
知道了什么是linux系统，接下来就要了解一下ros2了，https://fishros.com/d2lros2/#/
有了以上了解之后我们正式开始在自己的pc配置编译环境。因为cyberdog的NX板是经过裁剪的，上面无法编译代码，所以我们需要对代码进行交叉编译（https://blog.csdn.net/STCNXPARM/article/details/123452517）
步骤如下：
1. 下载一个免费的VMware
2. 推荐下载ubuntu18.04系统镜像
3. 打开虚拟机是否汉化自行选择
4. 打开终端
   #查看虚拟机系统架构
   $uname -a
   #安装vim编辑器
   $sudo apt-get update
   $sudo apt-get -y install vim
5. 安装docker
   #安装前先卸载操作系统默认安装的docker，
   $sudo apt-get remove docker docker-engine docker.io containerd runc
   #安装必要支持
   $sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
   #由于Docker官方源现在国内无法为访问，推荐使用阿里镜像源（或清华源）
   $curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   #添加 apt 源:
   #阿里apt源
   $echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker- 
    ce/linux/ubuntu$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   #更新源
   $sudo apt update
   $sudo apt-get update
   #安装最新版本的Docker
   $sudo apt install docker-ce docker-ce-cli containerd.io
   #等待安装完成
   #查看Docker版本
   $sudo docker version
   #查看Docker运行状态
   $sudo systemctl status docker
   #添加dockler用户组
   $sudo groupadd docker
   #将当前用户添加到用户组
   $sudo usermod -aG docker $USER
   #重启电脑然后重新启动docker验证是否安装成功
   $systemctl start docker
   #重启docker
   $service docker restart
6. 搭建docker镜像
   这里我们一共需要四个包，在开发者手册中找到这几个包的下载地址，把这几个包下载下来，与Dockerfile文件放在同一个目录下（已提供给 
   大家），然后运行Dockerfile开始自动构建docker镜像，耐心等待docker镜像构建成功就好了
7. 剩下的步骤就是按照Dockerfile文件使用说明一步一步操作（https://github.com/MiRoboticsLab/blogs/blob/rolling/docs/cn/dockerfile_instructions_cn.md）
   
   
