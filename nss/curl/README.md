# Curl wolfPKCS11 Test

## Introduction

This is a Dockerfile test which builds Curl 8.0.0 (because it is was one of the last versions with NSS support) with NSS and builds wolfPKCS11. It configures NSS to use wolfPKCS11 instead of NSS's internal PKCS11 provider for cryptography calls.

Some patches to NSS are applied to fix compatibility issues with third party PKCS11 providers and their source code.

Whilst this is not intended for production use, this does make for a good simple demonstration of using wolfPKCS11 for web access.

## Docker Usage

You will need Docker installed and running to the script.

To execute, the command is `run_wolfpkcs11_test.sh`. This will run NSS twice for a given URL, the first time it will log all PKCS11 mechanism calls to wolfPKCS11 and the second time it will log the mechanism calls to the internal NSS PKCS11 provider. It will then filter this to a unique list of calls made, the full logs will be made available in the `logs` subdirectory.

You use `run_wolfpkcs11_test.sh` by providing a URL, such as:

```sh
./run_wolfpkcs11_test.sh https://example.com
```
