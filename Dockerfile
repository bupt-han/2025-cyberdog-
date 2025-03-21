# 指定基础镜像
FROM arm64v8/ubuntu:bionic

# 指定 cmake 版本
ENV CMAKE_VER="3.21.2"

# 指定 github 网址
ENV GITHUB_URL="github.com"
ENV GITHUB_RAW="raw.githubusercontent.com"

# 指定工作路径
WORKDIR /home/builder

# 更新 apt 源，并安装 wget 和 ca-certificates
RUN apt-get update \
  && apt-get install -q -y --no-install-recommends wget \
  ca-certificates \
  # 删除软件包资源索引文件
  && rm -rf /var/lib/apt/lists/*

# 设置国内的 apt 源
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic main restricted universe multiverse\n" > /etc/apt/sources.list && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-updates main restricted universe multiverse\n" >> /etc/apt/sources.list && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-backports main restricted universe multiverse\n" >> /etc/apt/sources.list && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list

# 设置时区
RUN echo 'Etc/UTC' > /etc/timezone && \
  ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime

# 复制本地的 tar 包文件到容器中
COPY ./base-deb.tar.gz /home/builder/
COPY ./config-deb.tar.gz /home/builder/
COPY ./docker-depend.tar.gz /home/builder/
COPY ./carpo-ros2-debs.tgz /home/builder/
RUN ls /home/builder/


# 解压并安装相关依赖
RUN tar -xzvf /home/builder/config-deb.tar.gz && \
  dpkg -i /home/builder/config-deb/tzdata/*.deb && \
  rm -rf /home/builder/config-deb.tar.gz

# 解压 base-deb.tar.gz 并安装
RUN tar -xzvf /home/builder/base-deb.tar.gz \
  && cp /home/builder/base-deb/*.deb /var/cache/apt/archives/ \
  && apt install -y --no-install-recommends --allow-downgrades /var/cache/apt/archives/*.deb \
  && rm -rf /home/builder/base-deb.tar.gz

# 更新 pip
RUN pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 配置 ROS2
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu/ bionic main" > /etc/apt/sources.list.d/ros2-latest.list \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# 解压 ROS2 的 deb 包并安装
RUN mkdir /home/builder/carpo-ros2-debs && \
  tar -xf /home/builder/carpo-ros2-debs.tgz -C /home/builder/carpo-ros2-debs && \
  dpkg -i /home/builder/carpo-ros2-debs/*.deb && \
  rm -rf /home/builder/carpo-ros2-debs.tgz

# 配置其他依赖库和文件
RUN mkdir -p /opt/nvidia/l4t-packages/ && \
  touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall && \
  rm /var/lib/dpkg/info/* -rf

# 在安装docker相关依赖前添加：
RUN apt-get update && apt-get install -y equivs \
    && mkdir -p /tmp/equivs \
    && echo 'Package: libssl1.1\nVersion: 1.1.1-1ubuntu2.1~18.04.21\nArchitecture: arm64\nDepends: libssl1.1 (>= 1.1.1)\nDescription: Virtual package to satisfy libssl1.1 dependency' > /tmp/equivs/libssl1.1 \
    && cd /tmp/equivs \
    && equivs-build libssl1.1 \
    && dpkg -i libssl1.1_1.1.1-1ubuntu2.1~18.04.21_arm64.deb
    
# 安装 docker 相关的依赖
RUN tar -xzvf /home/builder/docker-depend.tar.gz \
    && dpkg -i --force-depends /home/builder/docker-depend/dpkg-deb/*.deb \
    && apt-get install -f -y \
    && cp /home/builder/docker-depend/apt-deb/*.deb /var/cache/apt/archives/ \
    && apt-get install -y --allow-downgrades --no-install-recommends /var/cache/apt/archives/*.deb \
    && python3 -m pip install --no-index --find-link /home/builder/docker-depend/whls/ -r /home/builder/docker-depend/whls/requirement.txt --ignore-installed \
    && cp /home/builder/docker-depend/config-file/libwebrtc.a /usr/local/lib \
    && cp /home/builder/docker-depend/config-file/libgalaxy-fds-sdk-cpp.a /usr/local/lib/ \
    && cp -r /home/builder/docker-depend/config-file/webrtc_headers/ /usr/local/include/ \
    && cp -r /home/builder/docker-depend/config-file/include/* /usr/local/include/ \
    && cp -r /home/builder/docker-depend/config-file/grpc-archive/* /usr/local/lib/ \
    && cp /home/builder/docker-depend/config-file/ldconf/* /etc/ld.so.conf.d \
    && ldconfig \
    && rm -rf /home/builder/docker-depend.tar.gz /home/builder/docker-depend/

# 设置 Python 链接
RUN rm -f /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python

# 设置 ROS 环境变量
RUN echo "ros2_galactic_on(){" >> /root/.bashrc && \
  echo "export ROS_VERSION=2" >> /root/.bashrc && \
  echo "export ROS_PYTHON_VERSION=3" >> /root/.bashrc && \
  echo "export ROS_DISTRO=galactic" >> /root/.bashrc && \
  echo "source /opt/ros2/galactic/setup.bash" >> /root/.bashrc && \
  echo "}" >> /root/.bashrc
