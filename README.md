# Manual DNS hook for dehydrated

### Latest Changes
v1: initial release. Support dehydrated client and domain registration via acme
v2: acme 2.0 support, including hook_chain configuration option and wildcard certificates

### Overview

This repository contains a ruby-based hook for the [`dehydrated`](dehydrated: https://github.com/lukas2511/dehydrated) project (a [Let's Encrypt](https://letsencrypt.org/), shell script ACME client) that allows a user to obtain a certificate from the _Let's Encrypt_ API via a DNS challenge. The hook will provide you with the domain and challenge details required for you to add to your DNS records, and poll until this change has propogated before allowing Let's Encrypt to confirm that changes. This is helpful for DNS providers and solutions that do not provide an API. This is an interactive hook to support those DNS providers that require manual interaction.

Looking for a DNS provider with an API? Try AWS Route 53, Rackspace, or CloudFlare.

Relevant Links:
* dehydrated: https://github.com/lukas2511/dehydrated
* Let's Encrypt: https://letsencrypt.org/

## Required
* git client for tool download
* ruby installed and available on the PATH

## Installation
Download the files for installation

``` bash
  $ git clone https://github.com/lukas2511/dehydrated.git
  $ git clone https://github.com/jbjonesjr/letsencrypt-manual-hook.git dehydrated/hooks/manual
```

## Usage
### Certificate for single domain 
``` bash
# **Note:** The `dehyrdrated` client uses the following flags in this example
# --cron (-c): Sign/renew non-existant/changed/expiring certificates. 
# --challenge (-t) [http-01|dns-01]: Which challenge should be used? Currently http-01 and dns-01 are supported 
# --domain (-d) [domain.tld]: Use specified domain name(s) instead of domains.txt entry (one certificate!) 
# --hook (-k) [path/to/hook.sh]: Use specified script for hooks

git-projects$ ./dehydrated/dehydrated -c -t dns-01 -d jbjonesjr.com -k ./dehydrated/hooks/manual/manual_hook.rb
# INFO: Using main config file /Users/jbjonesjr/lets-encrypt/letsencrypt-jbjonesjr.sh/config.sh
Processing jbjonesjr.com with alternative names: blog.jbjonesjr.com
 + Signing domains...
 + Generating private key...
 + Generating signing request...
 + Requesting challenge for jbjonesjr.com...
Create TXT record for the domain: '_acme-challenge.jbjonesjr.com'. TXT record:
'NT5EcszzzD2imO2IAWh81KqPHcx7nCSR8jHOEwKDjHQ'
Press any key when DNS has been updated...

Found NT5EcszzzD2imO2IAWh81KqPHcx7nCSR8jHOEwKDjHQ. match.
 + Responding to challenge for jbjonesjr.com...
Challenge complete. Please delete this TXT record(or in bulk later). Press any key when DNS has been updated...

 + Challenge is valid!
 + Requesting certificate...
 + Checking certificate...
 + Done!
 + Creating fullchain.pem...
deploy_cert
jbjonesjr.com
/Users/jbjonesjr/lets-encrypt/letsencrypt-jbjonesjr.sh/certs/jbjonesjr.com/cert.pem
 + Done!
```

### Certificate with additional alias(es)
``` bash
# **Note:** The `dehyrdrated` client uses the following flags in this example
# --cron (-c): Sign/renew non-existant/changed/expiring certificates. 
# --challenge (-t) [http-01|dns-01]: Which challenge should be used? Currently http-01 and dns-01 are supported 
# --domain (-d) [domain.tld]: Use specified domain name(s) instead of domains.txt entry (one certificate!) 
# --hook (-k) [path/to/hook.sh]: Use specified script for hooks

git-projects$ ./dehydrated/dehydrated -c -t dns-01 -d jbjonesjr.com -d blog.jbjonesjr.com -k ./dehydrated/hooks/manual/manual_hook.rb
# INFO: Using main config file /Users/jbjonesjr/lets-encrypt/letsencrypt-jbjonesjr.sh/config.sh
Processing jbjonesjr.com with alternative names: blog.jbjonesjr.com
 + Signing domains...
 + Generating private key...
 + Generating signing request...
 + Requesting challenge for jbjonesjr.com...
 + Requesting challenge for blog.jbjonesjr.com...
Create TXT record for the domain: '_acme-challenge.jbjonesjr.com'. TXT record:
'NT5EcszzzD2imO2IAWh81KqPHcx7nCSR8jHOEwKDjHQ'
Press any key when DNS has been updated...

Found NT5EcszzzD2imO2IAWh81KqPHcx7nCSR8jHOEwKDjHQ. match.
 + Responding to challenge for jbjonesjr.com...
Challenge complete. Please delete this TXT record(or in bulk later). Press any key when DNS has been updated...

 + Challenge is valid!
 Create TXT record for the domain: '_acme-challenge.blog.jbjonesjr.com'. TXT record:
'EHv_9kV6cfEdAsNBnlttr5ribvCpNqQRf6-R0kJLrh8'
Press any key when DNS has been updated...

Found EHv_9kV6cfEdAsNBnlttr5ribvCpNqQRf6-R0kJLrh8. match.
 + Responding to challenge for blog.jbjonesjr.com...
Challenge complete. Please delete this TXT record(or in bulk later). Press any key when DNS has been updated...

 + Challenge is valid!
 + Requesting certificate...
 + Checking certificate...
 + Done!
 + Creating fullchain.pem...
deploy_cert
jbjonesjr.com
/Users/jbjonesjr/lets-encrypt/letsencrypt-jbjonesjr.sh/certs/jbjonesjr.com/cert.pem
 + Done!
```

### Inspecting resulting certificates
After dehydrated has verified your domain ownership via TXT Record challenges, it provides you with a copy of the certificate signing request (csr), the private key used to identify your site, the resulting certificate and CA-chains. An example of the resulting certificate is below:
``` bash
git-projects$ openssl x509 -in ./dehydrated/certs/jbjonesjr.com/cert.pem -noout -text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            03:60:e6:37:6c:f6:db:00:b8:c5:e8:2e:50:80:aa:8c:f7:d0
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, O=Let's Encrypt, CN=Let's Encrypt Authority X3
        Validity
            Not Before: Oct 25 01:39:00 2016 GMT
            Not After : Jan 25 01:39:00 2017 GMT
        Subject: CN=jbjonesjr.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
            RSA Public Key: (4096 bit)
                Modulus (4096 bit):
                    00:c3:bb:7e:5a:e7:db:a0:02:40:c0:ba:54:37:aa:
                    6d:2a:dc:21:8f:86:99:1e:bd:c4:41:49:bb:e7:37:
                    0c:d4:44:c0:e5:c0:fc:5c:3c:64:14:be:89:80:9b:
                    d1:17:aa:45:da:88:d4:40:3c:9e:69:47:3f:17:c3:
                    1b:5b:94:89:48:3a:bf:ca:61:8f:c0:5c:7c:3a:0b:
                    90:f2:c4:68:2a:19:b5:f6:73:f4:cc:37:c8:dd:46:
                    e0:da:ab:39:87:39:26:20:be:33:77:2d:ee:ee:4d:
                    17:e4:4d:8b:ac:30:8b:d1:e1:9c:7a:36:58:55:35:
                    e8:7f:5e:c7:6a:29:45:fa:67:c0:61:2f:44:da:51:
                    0d:d1:d4:68:42:73:0d:c4:83:65:e4:cf:83:aa:1d:
                    0b:a0:96:4b:d3:39:03:3f:ef:8b:51:94:4c:e7:83:
                    92:25:d6:b9:6f:a5:1d:97:0f:75:9e:0f:f5:a1:c5:
                    ce:26:8d:2c:57:65:97:4e:38:1e:40:91:2b:8e:a5:
                    b5:88:12:fe:37:59:c1:1f:8e:a5:f9:c7:cd:f2:59:
                    a1:1d:33:4a:0c:54:bb:c0:c0:8c:62:f0:2d:6b:00:
                    02:44:ce:72:20:79:6e:fa:a3:18:69:e0:07:a2:17:
                    56:35:6a:e4:64:9b:27:2d:c2:54:2e:8b:1e:ee:60:
                    08:36:34:d9:cc:b8:ee:2a:8f:dd:79:66:c4:fd:6c:
                    f2:6c:c3:74:ab:d7:55:d5:15:60:ad:f5:c5:85:b0:
                    59:d8:00:bb:eb:cb:97:b0:74:fe:8b:3b:e4:50:0f:
                    99:78:61:fb:ff:c2:02:e3:9a:35:49:f6:0e:2b:48:
                    a6:7a:48:e6:78:9e:1e:77:e1:16:1d:d1:6c:f3:91:
                    c8:c9:25:b6:88:5f:74:d3:dc:f0:99:65:2f:10:f2:
                    6c:20:85:e0:c5:a6:3c:a7:96:a2:b6:af:de:b2:17:
                    ec:68:07:f0:06:36:43:ae:98:a0:cb:e1:ae:5f:fe:
                    93:18:bc:44:b1:3b:e2:1b:ec:99:3d:1c:04:06:df:
                    59:f6:f5:bf:3d:79:e5:f6:9c:63:bb:ad:79:b2:b2:
                    1b:9c:35:40:fb:d9:ad:98:92:85:68:89:1e:a3:1e:
                    d9:3f:5b:d3:bb:e4:9b:e5:ae:4a:0b:55:5c:62:d5:
                    16:ef:2f:54:65:46:9e:ba:3b:d3:f7:a6:de:7b:e1:
                    3b:3b:db:a0:5e:15:f9:d0:ed:62:52:75:83:6b:34:
                    9c:69:3d:06:13:42:20:f7:f5:cb:bc:e5:da:c9:7e:
                    c2:d1:2a:ad:47:98:3a:ef:cc:58:67:bd:b1:50:2d:
                    27:21:f8:70:74:7a:1c:3d:bc:d1:f8:bc:5b:e4:54:
                    a6:cc:7b
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                A4:3F:6D:69:0D:DA:D7:01:CF:7D:FA:D0:9F:4E:CB:83:3A:CF:59:3A
            X509v3 Authority Key Identifier:
                keyid:A8:4A:6A:63:04:7D:DD:BA:E6:D1:39:B7:A6:45:65:EF:F3:A8:EC:A1

            Authority Information Access:
                OCSP - URI:http://ocsp.int-x3.letsencrypt.org/
                CA Issuers - URI:http://cert.int-x3.letsencrypt.org/

            X509v3 Subject Alternative Name:
                DNS:blog.jbjonesjr.com, DNS:jbjonesjr.com
            X509v3 Certificate Policies:
                Policy: 2.23.140.1.2.1
                Policy: 1.3.6.1.4.1.44947.1.1.1
                  CPS: http://cps.letsencrypt.org
                  User Notice:
                    Explicit Text: This Certificate may only be relied upon by Relying Parties and only in accordance with the Certificate Policy found at https://letsencrypt.org/repository/

    Signature Algorithm: sha256WithRSAEncryption
        82:c6:41:7c:f9:4d:0f:25:a0:2d:24:b7:e6:56:a3:76:22:00:
        b9:ad:1c:1d:a9:3f:13:ba:7b:f3:53:73:7b:55:b3:ce:26:50:
        b5:df:c2:a9:d4:52:a3:fe:eb:b6:84:37:9d:f6:c3:b7:03:6f:
        8d:9b:f6:67:b2:23:b0:27:87:36:e9:0a:cd:74:33:01:0c:61:
        dd:11:24:c0:64:b1:d7:d1:bd:8b:fe:99:7b:42:de:86:d9:d3:
        17:32:0e:be:3f:a4:fc:f7:8a:34:de:a6:13:a9:20:5e:c0:81:
        96:25:87:66:28:31:ef:e5:8d:6b:c7:39:4e:c5:c7:5f:31:49:
        ee:30:b7:21:a3:b2:83:2a:0c:5e:db:12:67:94:7e:cd:0c:3e:
        78:34:53:d2:ca:03:4f:bc:3b:1c:be:f6:c9:8c:11:dc:48:01:
        4e:c1:07:30:75:f9:60:90:ef:c1:d2:db:df:cc:57:ca:36:b5:
        cc:2a:73:a2:a3:70:f5:17:29:34:02:cd:4f:6a:f4:63:fe:6b:
        5d:18:e1:46:75:61:42:ce:cf:9b:01:ab:88:1a:d2:74:91:19:
        19:7f:dd:51:69:32:57:8e:07:34:4b:9a:84:97:81:df:4e:4e:
        46:2a:8b:44:02:b7:5e:94:c0:66:28:3f:f2:f3:7a:a3:e4:ad:
        1f:56:da:b5
```

## This is too hard
Hate the idea of having to update DNS records manually? Want to have a script that takes of this for you without cutting and pasting, and pressing the enter key? Try these other providers and their related hooks:
* [Route 53](https://gist.github.com/asimihsan/d8d8f0f10bdc85fc6f8a)
* [Rackspace](https://github.com/major/letsencrypt-rackspace-hook/)
* [Cloudflare](https://github.com/kappataumu/letsencrypt-cloudflare-hook)
* [DNS Simple](https://github.com/danp/letsencrypt-dnsimple)
