var lat, long, altura, currentPosition, pointercenter;
lat = -24.79;
long = -65.42;
altura = 1301;
currentPosition = {
    lat: lat,
    lng: long
};
pointercenter = {
    lat: -24.063393373551428,
    lng: -63.797607421875
};

function SetMap() {
    try {
        wmsLayer = GetLayer();
        map.overlayMapTypes.clear(); //removeAt(0);
        map.overlayMapTypes.push(wmsLayer);
        goForData([lat,long,nameurl], [callback_goForData]);
    } catch (e) {
        //map.overlayMapTypes.push(wmsLayer);
    }
}

function changeMap(div, divname) {
    try {
        if (div !== null) {
            $(".meses").parent().find('div').removeAttr(" style ");
            $("#" + div.id).css("background-color", "#791522");
            nameurl = nname + div.id;
        } else {
            $(".meses").parent().find('div').removeAttr(" style ");
            $("#" + divname).css("background-color", "#791522");
            nameurl = nname + divname;
        }
        SetMap();
    } catch (e) {}
}

function GetMap(n) {
    try {
        nameurl = n;
        var url = hostMapas + nameurl;
        console.log(url);
        url += "&service=WMS";
        url += "&version=1.1.0";
        url += "&request=GetMap";
        url += "&BGCOLOR=0xFFFFFF";
        url += "&TRANSPARENT=TRUE";
        url += "&styles=";
        url += "&width=256";
        url += "&height=256";
        url += "&tiled=true";
        url += "&srs=EPSG:4326";
        url += "&format=image/png";
        UpdateData();
        return url;
    } catch (e) {}
}
var wmsLayer;

function GetLayer() {
    try {
        wmsLayer = new google.maps.ImageMapType({
            getTileUrl: function(coord, zoom) {
                var url = GetMap(nameurl);
                var s = Math.pow(2, zoom);
                var twidth = 768;
                var theight = 540;
                //define boundingbox
                var gBl = map.getProjection().fromPointToLatLng(new google.maps.Point(coord.x * twidth / s, (coord.y + 1) * theight / s)); //zuidwest coördinaat
                var gTr = map.getProjection().fromPointToLatLng(new google.maps.Point((coord.x + 1) * twidth / s, coord.y * theight / s)); //noordoost coördinaat
                var bbox = gBl.lng() + "," + gBl.lat() + "," + gTr.lng() + "," + gTr.lat();
                //basics WMS URL
                url += "&bbox=" + bbox;
                
                return url;
            },
            tileSize: new google.maps.Size(768, 540),
            opacity: 0.85,
            isPng: true
        });
        return wmsLayer;
    } catch (e) {}
}
var map, marker;

function disablingOptions() {
    try {
        map.setOptions({
            zoomControl: false,
            scaleControl: false,
            mapTypeControl: false,
        });
    } catch (e) {}
}

function enablingOptions() {
    try {
        map.setOptions({
            zoomControl: true,
            scaleControl: true,
            mapTypeControl: true,
        });
    } catch (e) {}
}

function ResizeMap() {
    try {
        var center = map.getCenter();
        google.maps.event.trigger(map, "resize");
        getWindowsSize();
        if (_iBrowserWidth < 480) {
            map.setZoom(6);
            disablingOptions();
            var pointerNew = {
                lat: -24.72126154823711,
                lng: -65.028076171875
            };
            map.setCenter(pointerNew);
        } else {
            map.setZoom(7);
            enablingOptions();
            map.setCenter(pointercenter);
        }
    } catch (e) {}
}

function LoadMap() {
    try {
        var myLatLng = currentPosition;
        map = new google.maps.Map(document.getElementById('map'), {
            zoom: 7,
           scaleControl: true,
            /*center: {lat: -24.3260336, lng: -66.2248039}*/
            mapTypeControl: true,
            mapTypeControlOptions: {
                style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
                position: google.maps.ControlPosition.LEFT_CENTER
            },
            zoomControl: true,
            zoomControlOptions: {
                style: google.maps.ZoomControlStyle.SMALL,
                position: google.maps.ControlPosition.LEFT_CENTER,
                border: '2px solid yellow'
            },
            scaleControl: true,
            streetViewControl: false,
            streetViewControlOptions: {
                position: google.maps.ControlPosition.BOTTOM_CENTER,
                border: '2px solid #0bf672'
            },
            fullscreenControl: false,
            center: pointercenter
        });
        google.maps.event.addDomListener(window, "resize", function() {
            ResizeMap();
        });
        ResizeMap();
        var elevator = new google.maps.ElevationService;
        marker = new google.maps.Marker({
            position: myLatLng,
            map: map,
            draggable: true,
            title: 'Salta'
        });
        wmsLayer = GetLayer();
       
        marker.setVisible(false);
        map.overlayMapTypes.push(wmsLayer);
        map.setMapTypeId('hybrid');
        map.addListener('click', function(e) {
            lat = e.latLng.lat(), long = e.latLng.lng();
            marker.setVisible(true);
            marker.setPosition(e.latLng);
            currentPosition = {
                lat: e.latLng.lat(),
                lng: e.latLng.lng()
            };
            altura = getLocationElevation(e.latLng, elevator);
            updateLabels(lat, long, altura);
            goForData([lat,long,nameurl], [callback_goForData]);
        });

        function getLocationElevation(location, elevator) {
            // Initiate the location request
            elevator.getElevationForLocations({
                'locations': [location]
            }, function(results, status) {
                if (status === 'OK') {
                    if (results[0]) {
                        try {
                            altura = results[0].elevation.toFixed(0);
                            $("#varalt").html(results[0].elevation.toFixed(0));
                            $("#varaltTemp").html(results[0].elevation.toFixed(0));
                        } catch (e) {}
                    } else {
                        return 0;
                    }
                } else {
                    return 'error';
                }
            });
        }
    } catch (e) {}
}

function setNewLatLong() {
    try {
        lat = $("#txtLat").val();
        long = $("#txtLong").val();
        lat = parseFloat(lat).toFixed(2);
        long = parseFloat(long).toFixed(2);
        myLatlng = new google.maps.LatLng(lat, long);
        marker.setPosition(myLatlng);
        marker.setVisible(true);
        updateLabels(lat, long, altura);
        goForData([lat,long,nameurl], [callbackData]);
    } catch (e) {}
}