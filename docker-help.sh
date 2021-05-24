#!/bin/bash

################################## 环境检测 #############################
funCheckDocker(){
    er_docker_install=`docker 2>&1 >/dev/null `
    if grep -q found <<<$er_docker_install; then
        echo -e "\033[31m 未安装docker服务!!!!!!!!! \033[0m"
    fi
    er_docker_compose_install=`docker-compose 2>&1 >/dev/null `
    if grep -q found <<<$er_docker_compose_install; then
        echo -e "\033[31m 不支持docker-compose命令!!!!!!!!! \033[0m"
    fi
}

# 检测系统环境是linux还是windows
funCheckLinux(){
    sysname=`uname`
    if  [ $sysname = 'Linux' ]
    then
        return 0
    else
        return 12
    fi
}
################################## 环境检测 #############################

################################## 基础环境安装 #############################
# 安装git、docker、docker-compose服务
funInstallDocker(){
    echo "####### 2秒后开始安装git和docker相关服务 #######"
    sleep 2

    # 安装git
    yum install -y git

    echo "####### git 安装完成 #######"

    # 安装docker需要的环境依赖
    yum install -y yum-utils device-mapper-persistent-data lvm2

    # 更换docker镜像源为阿里云镜像源
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

    # 安装docker服务
    yum install -y docker-ce docker-ce-cli containerd.io

    echo "####### 启动docker 服务 #######"

    # 启动docker服务
    systemctl start docker

    # 设置开机启动
    systemctl enable docker

    echo "####### 测试docker #######"

    # 运行docker示例
    docker run hello-world

    echo "####### 开始下载 docker-compose #######"

    # 下载docker-compos
    curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # 修改权限
    chmod +x /usr/local/bin/docker-compose

    # 注册命令
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    # 查看版本
    docker-compose --version

    echo "####### 软件全部安装完成 #######"
}
################################## 基础环境安装 #############################



################################## 命令支持 #############################
# 快速创建环境配置文件,工作目录
funAddEnv(){
    cp .env.example .env
    cp -r work-example work
}

# 安装应用服务
funAddServer(){
    eecho '******  可安装的服务如下,请自由组合： ******:'
    echo 'nginx'
    echo 'php-fpm'
    echo 'php-worker'
    echo 'php-server'
    echo 'mysql'
    echo 'redis'
    echo 'apache2'
    read aReserver
    docker-compose up -d $aReserver
}

# 重启所有服务
funRestartServer(){
    echo '******  可重启的服务如下,请自由组合： ******:'
    echo 'nginx'
    echo 'php-fpm'
    echo 'php-worker'
    echo 'php-server'
    echo 'mysql'
    echo 'redis'
    echo 'apache2'
    read aReserver
    docker-compose up -d $aReserver
}

# 重建容器
funBuildServer(){
    echo '******  可重建的服务如下,请自由组合： ******:'
    echo 'nginx'
    echo 'php-fpm'
    echo 'php-worker'
    echo 'php-server'
    echo 'mysql'
    echo 'redis'
    echo 'apache2'
    read aReserver
    docker-compose $aReserver build
}

# 快速连接redis服务
funUseRedis(){
    docker exec -it docker_redis_1 redis-cli
}

# 快速连接mysql服务
funUseMysql(){
    docker exec -it docker_mysql_1 mysql -uroot -p
}
####################### 命令支持 ##########################

####################### 脚本入口 ##########################
funCheckDocker
echo '******  docker compose for php 引导安装脚本 ******:'
echo '1. 安装docker环境(仅linux下使用)'
echo '2. 快速创建环境配置文件,工作目录'
echo '3. 安装服务'
echo '4. 重启服务'
echo '5. 重建容器'
echo '6. redis命令行模式'
echo '7. mysql命令行模式'
read aStart
case $aStart in
    1)
        if funCheckLinux
        then
            funInstallDocker
        else
            echo 'windows环境下无法安装'
        fi
    ;;
    2)
        funAddEnv
    ;;
    3)
        funAddServer
    ;;
    4)
        funRestartServer
    ;;
    5)
        funBuildServer
    ;;
    6)
        funUseRedis
    ;;
    7)
        funUseMysql
    ;;
    *)  
        echo '功能暂未开发' 
        exit
    ;;
esac
echo '****** 脚本执行完成 ******'
####################### 脚本入口 ##########################