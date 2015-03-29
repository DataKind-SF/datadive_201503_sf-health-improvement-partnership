var map = L.map('map').setView([37.78, -122.401], 12);
var mapbox_pk = "pk.eyJ1IjoiYmlsbGMiLCJhIjoiYllENmI2VSJ9.7wxYGAIJoOtQ2WE3zoCJEA";

L.tileLayer('http://{s}.tiles.mapbox.com/v3/billc.lj7dn4cg/{z}/{x}/{y}.png', {
  attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
  maxZoom: 18
}).addTo(map);

// Makes a circle on the map from the input
function circleMaker(latLong, radius, color, opacity) {
  return L.circle(latLong, radius, {
    color: color,
    fillColor: color,
    fillOpacity: opacity,
    stroke: false
  });
};

// Takes Creates the Callback that turns a list into a set of points on a map
// Also adds them to the map
function dataAnalyzer(size, color, opacity) {
  return function(data) {
    var xs = [],
      ys = [];
    $.each(data.X, function(key, value) {
      xs.push(value);
    });

    $.each(data.Y, function(key, value) {
      ys.push(value);
    });

    var latLongs = _.zip(ys, xs);

    $.each(latLongs, function(val) {
      circleMaker([latLongs[val][0], latLongs[val][1]], size, color, opacity).addTo(map);
    });

  }
};

$.getJSON('data/alcohol_stores.json', {}, dataAnalyzer(100, 'black', 0.2));
$.getJSON('data/ASSAULTS.json', {}, dataAnalyzer(10, 'red', 0.1));
$.getJSON('data/liquor_stores_cluster_centers.json', {}, dataAnalyzer(200, 'black', 0.6));
$.getJSON('data/ASSAULT_cluster_centers.json', {}, dataAnalyzer(200, 'red',0.6));
$.getJSON('data/SEX OFFENSES, FORCIBLE_cluster_centers.json', {}, dataAnalyzer(200, 'green',0.6));
