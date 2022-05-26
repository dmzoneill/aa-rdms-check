#!/usr/bin/env perl
use strict;
use warnings;
use WWW::Curl::Easy;
use JSON;

my $cookie = $ENV{'PROM_COOKIE'};
print($cookie . "\n");

my @headers = (
    "authority: prometheus.app-sre-prod-01.devshift.net",
    "accept: */*",
    "accept-language: en-GB,en-US;q=0.9,en;q=0.8",
    "cookie: $cookie",
    "referer: https://prometheus.app-sre-prod-01.devshift.net/graph?g0.expr=max(rdsosmetrics_fileSys_used{exported_instance=\"tower-analytics-prod\", mount_point=\"/rdsdbdata\"})&g0.tab=1&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1h",
    "sec-ch-ua: ' Not A;Brand';v='99', 'Chromium';v='100', 'Google Chrome';v='100'",
    "sec-ch-ua-mobile: ?0",
    "sec-ch-ua-platform: 'Linux'",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-origin",
    "user-agent: Mozilla/5.0 (X11; Fedora; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"
);

my $curl = WWW::Curl::Easy->new;
 
$curl->setopt(CURLOPT_URL, "https://prometheus.app-sre-prod-01.devshift.net/api/v1/query?query=max%28rdsosmetrics_fileSys_used%7Bexported_instance%3D%22tower-analytics-prod%22%2C+mount_point%3D%22%2Frdsdbdata%22%7D%29&time=1653565242.994");
$curl->setopt(CURLOPT_HTTPHEADER,\@headers);
$curl->setopt(CURLOPT_HEADER(),1);
$curl->setopt(CURLOPT_MAXREDIRS(),3);
$curl->setopt(CURLOPT_VERBOSE, 0);
$curl->setopt(CURLOPT_HEADER, 0);
$curl->setopt(CURLOPT_NOPROGRESS, 0);
$curl->setopt(CURLOPT_FOLLOWLOCATION, 1);
$curl->setopt(CURLOPT_FAILONERROR, 1);
$curl->setopt(CURLOPT_SSL_VERIFYPEER, 0);
$curl->setopt(CURLOPT_SSL_VERIFYHOST, 0);
$curl->setopt(CURLOPT_NOSIGNAL, 1);
$curl->setopt(CURLOPT_ENCODING, 'gzip');
$curl->setopt(CURLOPT_CONNECTTIMEOUT,8);

my $response_body;
$curl->setopt(CURLOPT_WRITEDATA,\$response_body);
my $retcode = $curl->perform;

if ($retcode != 0) {
    print("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
    print("$response_body\n");
    system("notify-send \"AA database size alert\" \"Unable to check grafana\"");
    exit 1;
}

# print("Received response: $response_body\n");
my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
my $json = JSON->new->utf8->decode($response_body);
my $current_kb = $json->{data}->{result}[0]->{value}[1];
my $alert_kb = 15569256448;

print($current_kb);

if ($current_kb > $alert_kb) {
    my $readable_size = sprintf("%.2f", $current_kb / 1024 / 1024 / 1024);
    system("notify-send \"AA database size alert\" \"The database is at $readable_size TB\"");
}
