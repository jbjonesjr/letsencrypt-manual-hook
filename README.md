# Manual DNS hook for dehydrated

This repository contains a ruby-based hook for the [`dehyrdated`](dehyrdated: https://github.com/lukas2511/dehydrated) project (a [Let's Encrypt](https://letsencrypt.org/), shell script ACME client) that allows a user to obtain a certificate from the `Let's Encrypt`_ API via a DNS challenge. The hook will provide you with the domain and challenge details required for you to add to your DNS records, and poll until this change has propogated before allowing Let's Encrypt to confirm that changes. This is helpful for DNS providers and solutions that do not provide an API. This is an interactive hook to support those DNS providers that require manual interaction.

Looking for a DNS provider with an API? Try AWS Route 53, Rackspace, or CloudFlare.

Relevant Links:
* letsencrypt.sh: https://github.com/lukas2511/dehydrated
* Let's Encrypt: https://letsencrypt.org/

## Required
* git client for tool download
* ruby installed and available on the PATH

## Installation
Download the files for installation

``` sh
  $ git clone https://github.com/lukas2511/letsencrypt.sh.git
  $ git clone https://github.com/jbjonesjr/letsencrypt-manual-hook.git letsencrypt.sh/hooks/manual
```

## Usage
``` bash
letsencrypt-jbjonesjr.sh$ ./letsencrypt.sh -c -t dns-01 -d jbjonesjr.com -d blog.jbjonesjr.com -k ./hooks/manual/manual_hook.rb
# INFO: Using main config file /Users/jbjonesjr/lets-encrypt/letsencrypt-jbjonesjr.sh/config.sh
Processing jbjonesjr.com with alternative names: blog.jbjonesjr.com
 + Signing domains...
 + Generating private key...
 + Generating signing request...
 + Requesting challenge for jbjonesjr.com...
 + Requesting challenge for blog.jbjonesjr.com...
Create TXT record for the domain: _acme-challenge.jbjonesjr.com. TXT record:
NT5EcszzzD2imO2IAWh81KqPHcx7nCSR8jHOEwKDjHQ
Press any key when DNS has been updated...

Found NT5EcszzzD2imO2IAWh81KqPHcx7nCSR8jHOEwKDjHQ. match.
 + Responding to challenge for jbjonesjr.com...
Challenge complete. Please delete this TXT record(or in bulk later). Press any key when DNS has been updated...

 + Challenge is valid!
 Create TXT record for the domain: _acme-challenge.blog.jbjonesjr.com. TXT record:
EHv_9kV6cfEdAsNBnlttr5ribvCpNqQRf6-R0kJLrh8
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

## This is too hard
Hate the idea of having to update DNS records manually? Want to have a script that takes of this for you without cutting and pasting, and pressing the enter key? Try these other providers and their related hooks:
* [Route 53](https://gist.github.com/asimihsan/d8d8f0f10bdc85fc6f8a)
* [Rackspace](https://github.com/major/letsencrypt-rackspace-hook/)
* [Cloudflare](https://github.com/kappataumu/letsencrypt-cloudflare-hook)
