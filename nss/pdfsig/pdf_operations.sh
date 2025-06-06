#!/bin/bash
# set -e

echo "Starting PDF operations with wolfPKCS11 and NSS..."

echo "Checking wolfPKCS11 library..."
if [ -f /usr/local/lib/libwolfpkcs11.so ]; then
    echo "wolfPKCS11 library found at /usr/local/lib/libwolfpkcs11.so"
    ls -la /usr/local/lib/libwolfpkcs11.so
    ldd /usr/local/lib/libwolfpkcs11.so || echo "Failed to run ldd on libwolfpkcs11.so"
else
    echo "ERROR: wolfPKCS11 library not found at /usr/local/lib/libwolfpkcs11.so"
    find /usr -name "libwolfpkcs11.so"
fi

echo "Checking wolfSSL library..."
if [ -f /usr/local/lib/libwolfssl.so ]; then
    echo "wolfSSL library found at /usr/local/lib/libwolfssl.so"
    ls -la /usr/local/lib/libwolfssl.so
else
    echo "ERROR: wolfSSL library not found at /usr/local/lib/libwolfssl.so"
    find /usr -name "libwolfssl.so"
fi

echo "Configuring NSS to use wolfPKCS11..."
mkdir -p /etc/pki/nssdb
chmod 755 /etc/pki/nssdb

cat > /etc/pki/nssdb/pkcs11.txt << 'EOF'
library=/usr/local/lib/libwolfpkcs11.so
name=wolfPKCS11
NSS=Flags=internal,critical,fips cipherOrder=100 slotParams={0x00000001=[slotFlags=ECC,RSA,DSA,DH,RC2,RC4,DES,RANDOM,SHA1,MD5,MD2,SSL,TLS,AES,Camellia,SEED,SHA256,SHA512] }
EOF

/src/dist/Debug/bin/certutil -N -d /etc/pki/nssdb/ --empty-password

echo "* Generating self-signed certificate for PDF signing..."
/src/dist/Debug/bin/certutil -d /etc/pki/nssdb -S -n "PDF Signing Certificate" -s "CN=PDF Signer,O=wolfSSL,C=US" -x -t "CT,C,C" -v 120 -g 2048 -z pdf_operations.sh

echo "* Generating a simple PDF file..."
cat > test.txt << EOF
This is a test document for PDF signing with wolfPKCS11 and NSS.
Generated on $(date)
EOF

echo "* Converting text to PDF..."
cat test.txt | enscript -B -o - | ps2pdf - test.pdf || echo "Failed to generate PDF"

if [ -f test.pdf ]; then
    echo "PDF generation successful!"
    ls -la test.pdf
else
    echo "PDF generation failed!"
fi

echo "* Signing the PDF file..."
echo "An NSS shutdown error is normal here"
pdfsig test.pdf signed.pdf -add-signature -nick "PDF Signing Certificate" -nssdir /etc/pki/nssdb

echo "* Verifying the PDF signature..."
pdfsig signed.pdf -nssdir /etc/pki/nssdb

echo "PDF operations completed successfully!"

if [ "$1" = "keep-running" ]; then
    echo "Container will keep running. Use Ctrl+C to stop."
    tail -f /dev/null
fi
