# ベース開発環境ステージ
FROM ubuntu:latest AS base-dev
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y git cmake swig g++ \
    libusb-1.0-0-dev libxml2-dev bison flex libavahi-client-dev \
    libavahi-common-dev libaio1t64 libzstd-dev libaio-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# libiioビルドステージ
FROM base-dev AS libiio-builder
WORKDIR /usr/src
ARG LIBIIO_VERSION
RUN git clone https://github.com/analogdevicesinc/libiio.git && \
    cd libiio && \
    git checkout ${LIBIIO_VERSION:-$(git describe --tags `git rev-list --tags --max-count=1`)} && \
    LIBIIO_VERSION_VAL=$(git describe --tags) && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local . && \
    make && \
    make install && \
    ldconfig && \
    cd /usr/src && \
    rm -rf libiio && \
    echo "LIBIIO_VERSION=${LIBIIO_VERSION_VAL}" > /tmp/versions.txt

# libm2kビルドステージ（Python用）
FROM libiio-builder AS libm2k-python-builder
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y python3-dev python3-setuptools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG LIBM2K_VERSION
RUN git clone https://github.com/analogdevicesinc/libm2k.git && \
    cd libm2k && \
    git checkout ${LIBM2K_VERSION:-$(git describe --tags `git rev-list --tags --max-count=1`)} && \
    LIBM2K_VERSION_VAL=$(git describe --tags) && \
    mkdir build && \
    cd build && \
    cmake -DENABLE_PYTHON=ON -DPYTHON_EXECUTABLE=$(which python3) \
          -DIIO_INCLUDE_DIRS=/usr/local/include/iio -DIIO_LIBRARIES=/usr/local/lib/libiio.so ../ && \
    make && \
    make install && \
    ldconfig && \
    cd /usr/src && \
    rm -rf libm2k && \
    echo "LIBM2K_VERSION=${LIBM2K_VERSION_VAL}" >> /tmp/versions.txt

# バージョン情報収集ステージ
FROM libm2k-python-builder AS version-collector
RUN mkdir -p /opt/version_info && \
    echo "BUILD_DATE=$(date -u +'%Y-%m-%d %H:%M:%S UTC')" > /opt/version_info/build_versions.txt && \
    echo "UBUNTU_VERSION=$(cat /etc/os-release | grep VERSION_ID | cut -d= -f2 | tr -d '"')" >> /opt/version_info/build_versions.txt && \
    echo "PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)" >> /opt/version_info/build_versions.txt && \
    echo "CMAKE_VERSION=$(cmake --version | head -n1 | awk '{print $3}')" >> /opt/version_info/build_versions.txt && \
    echo "GCC_VERSION=$(gcc --version | head -n1 | awk '{print $4}')" >> /opt/version_info/build_versions.txt && \
    echo "SWIG_VERSION=$(swig -version | grep 'SWIG Version' | awk '{print $3}')" >> /opt/version_info/build_versions.txt && \
    echo "LIBUSB_VERSION=$(dpkg -s libusb-1.0-0 | grep Version | awk '{print $2}')" >> /opt/version_info/build_versions.txt && \
    echo "LIBXML2_VERSION=$(dpkg -s libxml2 | grep Version | awk '{print $2}')" >> /opt/version_info/build_versions.txt && \
    echo "LIBAVAHI_CLIENT_VERSION=$(dpkg -s libavahi-client3 | grep Version | awk '{print $2}')" >> /opt/version_info/build_versions.txt && \
    cat /tmp/versions.txt >> /opt/version_info/build_versions.txt

# Python環境ステージ
FROM ubuntu:latest as stage-1

# システムのアップデートと必要なパッケージのインストール
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y python3 python3-pip python3-venv \
    libusb-1.0-0 libavahi-client3 libxml2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists*

# ビルドステージからファイルをコピー
COPY --from=version-collector /usr/local /usr/local
COPY --from=version-collector /etc/ld.so.conf.d /etc/ld.so.conf.d
COPY --from=version-collector /opt/version_info /opt/version_info

# 共有ライブラリのキャッシュを更新
RUN ldconfig

# m2kユーザー環境ステージ
FROM stage-1 as stage-2

# m2kユーザーの設定と必要なディレクトリの作成
RUN apt-get update && \
    apt-get install -y sudo && \
    groupadd -r m2k && \
    useradd -r -g m2k -m m2k && \
    # 上書き（/etc/sudoers.d/m2k）
    echo "m2k ALL=(ALL) NOPASSWD: /usr/bin/chown -R m2k\:m2k /home/m2k" > /etc/sudoers.d/m2k && \
    # 追加
    echo "m2k ALL=(ALL) NOPASSWD: /usr/bin/chown -R m2k\:m2k /home/m2k/**" >> /etc/sudoers.d/m2k && \
    # 追加
    echo "m2k ALL=(ALL) NOPASSWD: /usr/bin/cat /etc/sudoers.d/m2k" >> /etc/sudoers.d/m2k && \
    chmod 440 /etc/sudoers.d/m2k && \
    mkdir -p /home/m2k && \
    chown -R m2k:m2k /home/m2k /opt/version_info && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
