var map = L.map('map').setView([37.78, -122.401], 12);
var mapbox_pk = "pk.eyJ1IjoiYmlsbGMiLCJhIjoiYllENmI2VSJ9.7wxYGAIJoOtQ2WE3zoCJEA";

L.tileLayer('http://{s}.tiles.mapbox.com/v3/billc.lj7dn4cg/{z}/{x}/{y}.png', {
  attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
  maxZoom: 18
}).addTo(map);

function circleMaker(latLong, radius, color, opacity) {

return L.circle(latLong, radius, {
  color: color,
  fillColor: color,
  fillOpacity: opacity,
  stroke: false
})
};

circleMaker([37.78, -122.401], 20, 'red', 0.5).addTo(map);
