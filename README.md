# aa-rdms-check

![Alt text](alert.png?raw=true "Alert")

Perl requirements
```
dnf install perl-*curl*
```

Setup crontab
```
crontab -e
*/5 * * * * (/usr/bin/bash -l -c "/home/daoneill/src/aa-rdms-check/rdms.pl") > /tmp/db_check 2>&1
```

Setup grafana cookie
```
echo 'GRAFANA_COOKIE="0cfd7692xxxxxxxxxxxxxxxx6a=9f69b72f60108a37b621ac0c7e1d9911; _oauth2_proxy=eyJFbWFpbCI6ImRtxxxxxxxNlciI6ImRtem9uZWlsbCJ9|1652341057|h_Js85vjK--INTIxxxxxxxmf47FU="' >  ~/.bashrc.d/grafana.sh
chmod u+x ~/.bashrc.d/grafana.sh
```
