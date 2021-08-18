#!/bin/bash

################################## 环境检测 #############################
funCheckDocker(){
    echo '******  环境检测 ******'
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
funInstallGit(){
    echo "####### 开始安装git #######"
    # 安装git
    yum install -y git
    echo "####### git 安装完成 #######"
}

funInstallDocker(){
    echo "####### 开始安装docker #######"
    # 安装docker需要的环境依赖
    yum install -y yum-utils device-mapper-persistent-data lvm2

    # 更换docker镜像源为阿里云镜像源
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

    # 安装docker服务
    yum install -y docker-ce docker-ce-cli containerd.io

    echo "####### 启动 docker 服务 #######"

    # 启动docker服务
    systemctl start docker

    echo "####### 设置docker开机启动 #######"

    # 设置开机启动
    systemctl enable docker

    echo "####### docker 安装完成 #######"

    echo "####### 测试docker #######"

    # 运行docker示例
    docker run hello-world
}

funInstallDockerCompose(){
    echo "####### 开始安装 docker-compose #######"

    # 下载docker-compos
    curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # 修改权限
    chmod +x /usr/local/bin/docker-compose

    # 注册命令
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    # 查看版本
    docker-compose --version

    echo "####### docker-compose 安装完成 #######"
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
    echo '******  可选择服务如下,请自由组合： ******:'
    echo 'nginx'
    echo 'php-fpm'
    echo 'php-worker'
    echo 'php-server'
    echo 'mysql'
    echo 'redis'
    echo 'apache2'
    read aReserver

    funSelectVersion "${aReserver[*]}"

    docker-compose up -d $aReserver
}

# 选择安装软件版本
funSelectVersion(){
    setServer="$1"
    
    if grep -q mysql <<<$setServer; then
        echo '******  可选择mysql版本： ******:'
        echo '5.6'
        echo '5.7'
        echo '8.0'
        echo 'latest'
        read setMysql
        sed -i 's/MYSQL_VERSION=5.7/MYSQL_VERSION='${setMysql}'/g' ./.env
    fi

    if grep -q php-fpm <<<$setServer; then
        echo '******  可选择php版本： ******:'
        echo '5.6'
        echo '7.0'
        echo '7.1'
        echo '7.2'
        echo '7.3'
        echo '7.4'
        echo '8.0'
        read setPhpFpm
        sed -i 's/PHP_VERSION=7.3/PHP_VERSION='${setPhpFpm}'/g' ./.env
    fi
}

# 快速添加 nginx 站点
funBuildNginx(){

    echo '******  设置网站域名： ******:'
    read setSiteName

    echo '******  设置网站文件名： ******:'
    read setWwwRoot

    echo '******  设置配置模板： default(app)******:'
    echo 'app'
    echo 'httpserver'
    echo 'laravel'
    echo 'node'
    echo 'symfony'
    echo 'thinkphp'

    read setFrame

    default="app"
    if [ -n "$setSiteName" ];
    then
        if [ -n "$setFrame" ];
        then
            default=$setFrame
        fi
        cp ./services/nginx/sites/${default}.conf.example ./services/nginx/sites/${setSiteName}.conf
        sed -i 's/app.test/'${setSiteName}'/g' ./services/nginx/sites/${setSiteName}.conf
        sed -i 's/\/var\/www\/'${default}'/\/var\/www\/'${setWwwRoot}'/g' ./services/nginx/sites/${setSiteName}.conf
        sed -i 's/'${default}'_access/'${setWwwRoot}'_access/g' ./services/nginx/sites/${setSiteName}.conf
        sed -i 's/'${default}'_error/'${setWwwRoot}'_error/g' ./services/nginx/sites/${setSiteName}.conf
    fi
}

# 快速添加 apache 站点
funBuildApache(){
    echo '******  设置网站域名： ******:'
    read setSiteName

    echo '******  设置网站文件名： ******:'
    read setWwwRoot

    echo '******  访问目录在public下(y/n)：n ******:'
    read setPublic

    if [ -n "$setSiteName" ];
    then
        cp ./services/apache2/sites/sample.conf.example ./services/apache2/sites/${setSiteName}.conf
        sed -i 's/sample.test/'${setSiteName}'/g' ./services/apache2/sites/${setSiteName}.conf
        if grep -q y <<<$setPublic;
        then
            sed -i 's/\/var\/www\/sample/\/var\/www\/'${setWwwRoot}'\/public\//g' ./services/apache2/sites/${setSiteName}.conf
        else
            sed -i 's/\/var\/www\/sample/\/var\/www\/'${setWwwRoot}'/g' ./services/apache2/sites/${setSiteName}.conf
        fi
    fi
}
####################### 命令支持 ##########################

####################### 脚本入口 ##########################
funCheckDocker
echo '******  docker compose for php 辅助脚本 ******:'
echo '1. 安装 git (linux)'
echo '2. 安装 docker (linux)'
echo '3. 安装 docker-compose (linux)'
echo '4. 快速配置应用环境'
echo '5. 快速添加 nginx 站点'
echo '6. 快速添加 apache 站点'
echo '7. 快速搭建应用环境'

read aStart

case $aStart in
    1)
        if funCheckLinux
        then
            funInstallGit
        else
            echo 'windows环境下无法执行'
            exit
        fi
    ;;
    2)
        if funCheckLinux
        then
            funInstallDocker
        else
            echo 'windows环境下无法执行'
            exit
        fi
    ;;
    3)
        if funCheckLinux
        then
            funInstallDockerCompose
        else
            echo 'windows环境下无法执行'
            exit
        fi
    ;;
    4)
        funAddEnv
    ;;
    5)
        funBuildNginx
    ;;
    6)
        funBuildApache
    ;;
    7)
        funAddServer
    ;;
    *)  
        echo '功能暂未开发' 
        exit
    ;;
esac
echo '****** 脚本执行完成 ******'
####################### 脚本入口 ##########################