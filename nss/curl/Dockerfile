FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for NSS, curl, wolfSSL, and wolfPKCS11
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
    libnss3-tools \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /src

# Clone NSS and NSPR repositories in the correct structure
RUN mkdir -p /src && \
    cd /src && \
    hg clone https://hg.mozilla.org/projects/nspr && \
    hg clone https://hg.mozilla.org/projects/nss


# Clone OSP for NSS patches
WORKDIR /src
RUN git clone https://github.com/wolfSSL/osp.git

# Build NSS with debug mode enabled (debug is the default)
WORKDIR /src/nss
ENV USE_64=1
ENV NSS_ENABLE_WERROR=0
ENV BUILD_OPT=0

# Checkout our branch
RUN patch -p1 < /src/osp/nss/nss-ecc-curves.patch
RUN patch -p1 < /src/osp/nss/nss-slot.patch

# Build NSS with debug mode enabled (debug is the default)
RUN ./build.sh -v

# Clone and build wolfSSL
WORKDIR /src
RUN git clone https://github.com/wolfSSL/wolfssl.git --depth=1 && \
    cd wolfssl && \
    ./autogen.sh && \
    ./configure \
      --enable-all \
      --enable-debug \
      --enable-aescfb \
      --enable-cryptocb \
      --enable-rsapss \
      --enable-keygen \
      --enable-pwdbased \
      --enable-scrypt \
      CFLAGS="-DWOLFSSL_PUBLIC_MP -DWC_RSA_DIRECT -D_GNU_SOURCE" && \
    make && \
    make install && \
    ldconfig

# Clone and build wolfPKCS11
WORKDIR /src
RUN git clone https://github.com/wolfSSL/wolfPKCS11.git && \
    cd wolfPKCS11 && \
    ./autogen.sh && \
    CFLAGS="-D_GNU_SOURCE" ./configure --enable-debug --enable-nss --enable-aesecb --enable-aesctr --enable-aesccm --enable-aescmac && \
    make && \
    make install && \
    ldconfig && \
    ls -la /usr/local/lib/libwolfpkcs11.so

# Create NSS database directory structure
RUN mkdir -p /etc/pki/nssdb

# Configure NSS to use wolfPKCS11
RUN echo "library=/usr/local/lib/libwolfpkcs11.so" > /etc/pki/nssdb/pkcs11.txt && \
    echo "name=wolfPKCS11" >> /etc/pki/nssdb/pkcs11.txt && \
    echo "NSS=Flags=internal,critical cipherOrder=100 slotParams={0x00000001=[slotFlags=ECC,RSA,DSA,DH,RC2,RC4,DES,RANDOM,SHA1,MD5,MD2,SSL,TLS,AES,Camellia,SEED,SHA256,SHA512] }" >> /etc/pki/nssdb/pkcs11.txt && \
    echo "" >> /etc/pki/nssdb/pkcs11.txt

# Download and extract curl 8.0.0
WORKDIR /src
RUN wget --progress=dot:giga https://curl.se/download/curl-8.0.0.tar.gz && \
    tar -xzf curl-8.0.0.tar.gz && \
    rm curl-8.0.0.tar.gz

# Copy NSS and NSPR headers and libraries from dist directory
RUN mkdir -p /usr/local/include/nss && \
    mkdir -p /usr/local/include/nspr && \
    # Copy NSS headers from dist directory
    cp -r /src/dist/public/nss/* /usr/local/include/nss/ && \
    # Copy NSPR headers from dist directory
    cp -r /src/dist/Debug/include/nspr/* /usr/local/include/nspr/ && \
    # Copy NSS and NSPR libraries
    mkdir -p /usr/local/lib && \
    find /src/dist/Debug -name "*.so" -exec cp {} /usr/local/lib/ \; && \
    find /src/nspr/Debug -name "*.so" -exec cp {} /usr/local/lib/ \; && \
    ldconfig

# Build curl with NSS support
WORKDIR /src/curl-8.0.0

# Set up environment for curl build
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV CPPFLAGS="-I/usr/local/include/nss -I/usr/local/include/nspr -I/usr/local/include"
ENV LDFLAGS="-L/usr/local/lib"
# Fix NSS include paths
RUN mkdir -p /usr/include/nss && \
    cp -r /usr/local/include/nss/* /usr/include/nss/ && \
    mkdir -p /usr/include/nspr && \
    cp -r /usr/local/include/nspr/* /usr/include/nspr/

# Configure and build curl with NSS support
RUN ./configure --with-nss=/usr/local --with-nss-deprecated && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

# Verify curl was built with NSS
RUN curl -V | grep NSS

# Set NSS debug environment variables
ENV NSS_DEBUG_PKCS11_MODULE="wolfPKCS11"
ENV NSPR_LOG_MODULES="all:5"
ENV NSPR_LOG_FILE=/logs/nss.log
ENV NSS_OUTPUT_FILE=/logs/stats.log
ENV NSS_STRICT_NOFORK=1
ENV NSS_DEBUG=all

# Create logs directory
RUN mkdir -p /logs

# Default command to run curl with NSS debugging and capture errors
CMD ["sh", "-c", "echo 'Testing curl with wolfPKCS11:' && \
                  echo 'NSS using wolfPKCS11 from pkcs11.txt:' && \
                  cat /etc/pki/nssdb/pkcs11.txt && \
                  echo 'Setting up NSS debugging:' && \
                  echo 'NSS_DEBUG_PKCS11_MODULE=\"NSS Internal PKCS #11 Module\"' && \
                  echo 'NSPR_LOG_MODULES=\"nss_mod_log:4,pkcs11module:4,pk11mod:4,secmod:4\"' && \
                  echo 'NSPR_LOG_FILE=/logs/nss.log' && \
                  echo 'NSS_DEBUG=all' && \
                  echo 'NSS_STRICT_NOFORK=1' && \
                  echo 'Running curl against https://example.com/ (may crash, which is expected):' && \
                  touch /logs/nss.log && chmod 666 /logs/nss.log && \
                  curl -v https://example.com/ || echo 'Curl exited with error code $?' && \
                  ls -la /logs && \
                  cat /logs/nss.log"]

