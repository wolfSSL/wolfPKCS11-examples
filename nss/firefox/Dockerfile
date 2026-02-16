FROM ubuntu:24.04

ARG FIREFOX_TAG=78c455227887c316bdde0be2738e31fcecb4547d

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive
# Set wolf install path
ENV LD_LIBRARY_PATH=/usr/local/lib

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    mercurial \
    gyp \
    ninja-build \
    pkg-config \
    zlib1g-dev \
    wget \
    python3 \
    python-is-python3 \
    python3-pip \
    autoconf \
    automake \
    libtool \
    make \
    gdb \
    vim \
    ca-certificates \
    zlib1g-dev \
    gettext \
    llvm \
    alsa \
    libgtk-3-0 \
    libasound2-dev \
    libx11-xcb1 \
    libegl1 \
    libpci3 \
    dbus-x11 \
    sudo

RUN usermod -aG sudo ubuntu
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers

USER ubuntu
RUN sudo ls /home
WORKDIR /home/ubuntu

RUN wget https://raw.githubusercontent.com/mozilla-firefox/firefox/refs/heads/main/python/mozboot/bin/bootstrap.py
RUN python3 bootstrap.py --no-interactive --application-choice browser

WORKDIR /home/ubuntu/src
RUN git clone https://github.com/wolfssl/wolfssl.git
WORKDIR /home/ubuntu/src/wolfssl
RUN autoreconf -if
RUN ./configure --enable-all --enable-aescfb --enable-cryptocb --enable-rsapss --enable-keygen \
    --enable-pwdbased --enable-scrypt 'CFLAGS=-DWOLFSSL_PUBLIC_MP -DWC_RSA_DIRECT'
RUN make && sudo make install
WORKDIR /home/ubuntu/src

RUN git clone https://github.com/wolfSSL/wolfPKCS11.git #1
WORKDIR /home/ubuntu/src/wolfPKCS11
RUN autoreconf -if
RUN ./configure --enable-rsa --enable-rsaoaep --enable-rsapss --enable-keygen --enable-ecc \
    --enable-dh --enable-aes --enable-aeskeywrap --enable-aescbc --enable-aesgcm --enable-aesctr \
    --enable-aesccm --enable-aesecb --enable-aescmac --enable-hmac --enable-md5 --enable-sha \
    --enable-sha1 --enable-sha224 --enable-sha256 --enable-sha384 --enable-sha512 --enable-nss
RUN make && sudo make install
WORKDIR /home/ubuntu/src

RUN git clone https://github.com/wolfSSL/osp.git

WORKDIR /home/ubuntu/firefox
RUN git checkout $FIREFOX_TAG
WORKDIR /home/ubuntu/firefox/security/nss
RUN patch -p1 < /home/ubuntu/src/osp/nss/nss-fixes-2025-04-11-978205bd37c33d862a5798d8158df7091412d3a7.patch
RUN patch -p1 < /home/ubuntu/src/osp/nss/nss-tests-2025-04-11-978205bd37c33d862a5798d8158df7091412d3a7.patch
WORKDIR /home/ubuntu/firefox
RUN ./mach build
RUN OBJ_DIR=$(ls -d obj-*/dist/bin/firefox | head -1 | cut -d/ -f1) && \
    mkdir -p /home/ubuntu/firefox/$OBJ_DIR/tmp/profile-default && \
    cd /home/ubuntu/firefox/$OBJ_DIR/tmp/profile-default && \
    echo "library=libwolfpkcs11.so" > pkcs11.txt && \
    echo "name=wolfPKCS11" >> pkcs11.txt && \
    echo "parameters=configdir='sql:/home/ubuntu/firefox/$OBJ_DIR/tmp/profile-default' certPrefix='' keyPrefix='' secmod='secmod.db' flags=optimizeSpace updatedir='' updateCertPrefix='' updateKeyPrefix='' updateid='' updateTokenDescription=''" >> pkcs11.txt && \
    echo "NSS=Flags=internal,critical cipherOrder=100 slotParams={0x00000001=[slotFlags=ECC,RSA,DSA,DH,RC2,RC4,DES,RANDOM,SHA1,MD5,MD2,SSL,TLS,AES,Camellia,SEED,SHA256,SHA512] }" >> pkcs11.txt
WORKDIR /home/ubuntu/firefox
