from flask import Flask, render_template, abort, request, jsonify, g
import sqlite3

DATABASE = 'PoliceIncidents.sqlite'
METERS_PER_DEGREE = 111000
DEGREES_PER_METER = 0.000009009
HALF_SIDE = 250
MODULATION_LAT = .0045;
MODULATION_LNG = .004;

app = Flask(__name__)

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = connect_db()
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

def connect_db():
    return sqlite3.connect(DATABASE)

@app.route('/')
def home_page():
    return render_template('index.html')

@app.route('/crimes/<lat>,<lng>')
def find_crimes(lat, lng):
	max_lat = float(lat) + MODULATION_LAT
	min_lat = float(lat) - MODULATION_LAT
	max_long = float(lng) + MODULATION_LNG
	min_long = float(lng) - MODULATION_LNG

	c = get_db().cursor()
	features = []
	for row in c.execute('SELECT * FROM Police where ( (latitude > ? AND latitude < ?) AND (longitude > ? AND longitude < ?) AND (year>=2014))', [min_lat, max_lat, min_long, max_long]):
		geometry = { "type": "Point", "coordinates": [row[8], row[7]] }
		feature = {"type": "Feature", "geometry": geometry, "properties": {"nothing" : "nothing"}}
		features.append(feature)
		#crimes.append({'geo': {'lat': , 'lng': row[8]}})
	geojson = {"type": "FeatureCollection", "features": features}
	#print counter
	#print lat + " " + long
	return jsonify(geojson = geojson)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug='True')