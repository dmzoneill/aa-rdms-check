# aa-rdms-check

<p align="center">
  <img src=".github/logo.png" alt="aa-rdms-check logo" width="128" />
</p>

![Alt text](alert.png?raw=true "Alert")

Perl requirements

```text
dnf install perl-*curl*
```

Setup crontab

```text
crontab -e
*/5 * * * * (/usr/bin/bash -l -c "/home/daoneill/src/aa-rdms-check/rdms.pl") > /tmp/db_check 2>&1
```

Setup grafana cookie

```text
echo 'PROM_COOKIE="0cfd7692xxxxxxxxxxxxxxxx6a=9f69b72f60108a37b621ac0c7e1d9911; _oauth2_proxy=eyJFbWFpbCI6ImRtxxxxxxxNlciI6ImRtem9uZWlsbCJ9|1652341057|h_Js85vjK--INTIxxxxxxxmf47FU="' >  ~/.bashrc.d/prom.sh
chmod u+x ~/.bashrc.d/prom.sh
```
