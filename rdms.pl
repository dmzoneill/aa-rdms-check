#!/usr/bin/env perl
use strict;
use warnings;
use WWW::Curl::Easy;
use JSON;

my $cookie = $ENV{'GRAFANA_COOKIE'};

my @headers = (
    "Server: wrapper-y",
    "User-Agent: ipfc-wrap",
    "authority: grafana.app-sre.devshift.net",
    "accept: application/json, text/plain, */*",
    "accept-language: en-GB,en-US;q=0.9,en;q=0.8",
    "content-type: application/x-www-form-urlencoded",
    "cookie: $cookie",
    "origin: https://grafana.app-sre.devshift.net",
    "referer: https://grafana.app-sre.devshift.net/d/81Du_aIHdf/automation-analytics?orgId=1&from=now-24h&to=now&var-Datasource=crcp01ue1-prometheus&var-DatasourceRDS=app-sre-prod-01-prometheus&var-namespace=tower-analytics-prod&var-granularity=daily&var-granularity=monthly&var-granularity=yearly&var-realtime_rollup_series=ta_rollup_processor_rollup_event_explorer_rollup_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_host_event_explorer_rollup_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_host_explorer_rollup_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_job_explorer_rollup_failed_steps_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_job_explorer_rollup_jobs_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_job_explorer_rollup_workflow_hierarchy_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_job_explorer_rollup_workflows_time_bucket&var-granularity_rollups=job_explorer&var-granularity_rollups=event_explorer&var-granularity_rollups=host_explorer&var-processor_tables=analytics_bundle&var-processor_tables=events_table&var-processor_tables=unified_jobs&viewPanel=46&editPanel=46&inspect=23763571993&inspectTab=query",
    "sec-ch-ua: ' Not A;Brand';v='99', 'Chromium';v='100', 'Google Chrome';v='100'",
    "sec-ch-ua-mobile: ?0",
    "sec-ch-ua-platform: 'Linux'",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-origin",
    "user-agent: Mozilla/5.0 (X11; Fedora; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36",
    "x-dashboard-id: 20930",
    "x-grafana-org-id: 1",
    "x-grafana-org-id: 23763571993",
);

my $grafana_query = "query=max%28rdsosmetrics_fileSys_used%7Bexported_instance%3D%22tower-analytics-prod%22%2C+mount_point%3D%22%2Frdsdbdata%22%7D%29&start=1652256120&end=1652342520&step=120";
 
my $curl = WWW::Curl::Easy->new;
 
$curl->setopt(CURLOPT_URL, "https://grafana.app-sre.devshift.net/api/datasources/proxy/10/api/v1/query_range");
$curl->setopt(CURLOPT_HTTPHEADER,\@headers);
$curl->setopt(CURLOPT_HEADER(),1);
$curl->setopt(CURLOPT_MAXREDIRS(),3);
$curl->setopt(CURLOPT_VERBOSE, 0);
$curl->setopt(CURLOPT_HEADER, 0);
$curl->setopt(CURLOPT_NOPROGRESS, 1);
$curl->setopt(CURLOPT_FOLLOWLOCATION, 0);
$curl->setopt(CURLOPT_FAILONERROR, 1);
$curl->setopt(CURLOPT_SSL_VERIFYPEER, 0);
$curl->setopt(CURLOPT_SSL_VERIFYHOST, 0);
$curl->setopt(CURLOPT_NOSIGNAL, 1);
$curl->setopt(CURLOPT_ENCODING, 'gzip');
$curl->setopt(CURLOPT_POSTFIELDS, "$grafana_query" );
$curl->setopt(CURLOPT_POSTFIELDSIZE, length($grafana_query) );
$curl->setopt(CURLOPT_POST, 1);
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
my $values = $json->{data}->{result}['0']->{values};
my $last_index = $$values[$#$values];
my $current_kb = int($$last_index[$#$last_index]);
my $alert_kb = 15569256448;

if ($current_kb > $alert_kb) {
    my $readable_size = sprintf("%.2f", $current_kb / 1024 / 1024 / 1024);
    system("notify-send \"AA database size alert\" \"The database is at $readable_size TB\"");
}
