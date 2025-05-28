package Conf;

our $hostUrl ="http://localhost";
our $hostGeoDatos = "http://localhost:8080/geoserver/sisol/wms?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&FORMAT=image%2Fpng&TRANSPARENT=true&QUERY_LAYERS=sisol%3Adatos&STYLES&LAYERS=datos%3Adatos&INFO_FORMAT=application%2Fjson&FEATURE_COUNT=50&X=50&Y=50&SRS=EPSG%3A4326&WIDTH=101&HEIGHT=101";
our $hostGeoMapa ="http://localhost:8080/geoserver/sisol/wms?&layers=sisol:";

our $reportesURL="/var/www/html/sisol/";


1;
