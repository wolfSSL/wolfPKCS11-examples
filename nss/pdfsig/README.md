# wolfPKCS11 with NSS for PDF Signing

## Introuction

This Dockerfile creates an environment that:

1. Takes the `nss` branch of wolfPKCS11
2. Compiles it with `--enable-nss`
3. Configures NSS to use wolfPKCS11
4. Generates a PDF file
5. Signs the PDF file with `pdfsig`
6. Verifies the signature with `pdfsig`

`pdfsig` uses `libpoppler` which in-turn uses NSS for signing PDF files.

## Building and Running

With Docker running on your system, simply run `./run_wolfpkcs11_test.sh`. This
will build the Docker image and then execute it.

## Output

The container will:
1. Configure NSS to use wolfPKCS11
2. Generate a self-signed certificate for PDF signing
3. Create a simple PDF file
4. Sign the PDF with pdfsig
5. Verify the signature with pdfsig
6. Display detailed signature information

The signed PDF will be available at `/opt/pdf/signed.pdf` inside the container.
