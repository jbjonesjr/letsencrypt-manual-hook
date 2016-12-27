[Common OpenSSL commands](https://www.sslshopper.com/article-most-common-openssl-commands.html)  
[Let's Encrypt Directory Structure](https://www.linode.com/docs/security/ssl/install-lets-encrypt-to-create-ssl-certificates)  
File layout
> * **cert.pem**: server certificate only.
* **chain.pem**: root and intermediate certificates only.
* **fullchain.pem**: combination of server, root and intermediate certificates (replaces `cert.pem` and `chain.pem`).
privkey.pem: private key (do **not** share this with anyone!).
