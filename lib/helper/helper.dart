
var baseurl="http://yourdomain.com/api/";
// var baseurl="http://192.168.1.9/transport-backend/api/";
var upload_url="${baseurl}upload_data";
var login_url="${baseurl}login";
var user_by_id_url="${baseurl}get_user_by_id";
var insert_reading="${baseurl}insert_reading";

// Google Key
var google_key="AIzaSyDHZ4rfHDSWAqSl19aw9cBg71derwKV3B4";
String google_url(lat,long,key)=>"https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${long}&key=${key}";
