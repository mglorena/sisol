#!/usr/bin/perl
use CGI;
use Data::Dumper;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => 'http://localhost:8080/geoserver/datos/wms?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&FORMAT=image%2Fpng&TRANSPARENT=true&QUERY_LAYERS=datos%3Ameses&STYLES&LAYERS=datos%3Ameses&INFO_FORMAT=application%2Fjson&FEATURE_COUNT=50&X=50&Y=50&SRS=EPSG%3A4326&WIDTH=101&HEIGHT=101&BBOX=-64.31396%2C-25.82611%2C-64.31296%2C-25.81611');
my $res = $ua->request($req);

if ($res->is_success) {
      print $res->as_string;
} else {
     print "Failed: ", $res->status_line, "\n";
}