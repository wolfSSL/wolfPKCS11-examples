FROM ubuntu:22.04

# Set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    mercurial \
    python3 \
    python-is-python3 \
    python3-pip \
    gyp \
    ninja-build \
    build-essential \
    automake \
    libtool \
    git \
    pkg-config \
    poppler-utils \
    wget \
    enscript \
    ghostscript \
    gdb \
    vim \
    hexedit \
    && rm -rf /var/lib/apt/lists/*

#RUN update-ca-certificates

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

# Create working directory
WORKDIR /opt/wolfssl

# Build wolfSSL
RUN git clone https://github.com/wolfSSL/wolfssl.git && \
    cd wolfssl && \
    ./autogen.sh && \
    ./configure --enable-aescfb --enable-cryptocb --enable-rsapss --enable-keygen --enable-pwdbased --enable-scrypt --enable-cmac --enable-aesctr --enable-aesccm C_EXTRA_FLAGS="-DWOLFSSL_PUBLIC_MP -DWC_RSA_DIRECT -DHAVE_AES_ECB -D_GNU_SOURCE" && \
    make && \
    make install && \
    ldconfig

# Clone and build wolfPKCS11 with NSS support
WORKDIR /opt/wolfpkcs11
RUN git clone https://github.com/wolfSSL/wolfPKCS11.git && \
    cd wolfPKCS11 && \
    ./autogen.sh && \
    ./configure --enable-debug --enable-nss --enable-aesecb --enable-aesctr --enable-aesccm --enable-aescmac CFLAGS="-D_GNU_SOURCE" && \
    make && \
    make install && \
    ldconfig

# Create directory for NSS configuration
RUN mkdir -p /etc/pki/nssdb

# Configure NSS to use wolfPKCS11
RUN echo "library=/usr/local/lib/libwolfpkcs11.so" > /etc/pki/nssdb/pkcs11.txt && \
    echo "name=wolfPKCS11" >> /etc/pki/nssdb/pkcs11.txt && \
    echo "NSS=Flags=internal,critical,fips cipherOrder=100 slotParams={0x00000001=[slotFlags=ECC,RSA,DSA,DH,RC2,RC4,DES,RANDOM,SHA1,MD5,MD2,SSL,TLS,AES,Camellia,SEED,SHA256,SHA512] }" >> /etc/pki/nssdb/pkcs11.txt

# Create directory for PDF operations
RUN mkdir -p /opt/pdf

# Set working directory for PDF operations
WORKDIR /opt/pdf

# Add a script to generate, sign, and verify a PDF
COPY pdf_operations.sh /opt/pdf/
RUN chmod +x /opt/pdf/pdf_operations.sh

# Set NSS debug environment variables
ENV NSS_DEBUG_PKCS11_MODULE="wolfPKCS11"
ENV NSPR_LOG_MODULES="all:5"
ENV NSPR_LOG_FILE=/logs/nss.log
ENV NSS_OUTPUT_FILE=/logs/stats.log
ENV NSS_STRICT_NOFORK=1
ENV NSS_DEBUG=all

RUN mkdir /logs


# Set entrypoint to the PDF operations script
ENTRYPOINT ["/opt/pdf/pdf_operations.sh"]
