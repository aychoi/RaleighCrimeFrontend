from flask import Flask, render_template, abort, request, jsonify, g
import sqlite3
#import rpy2.robjects as robjects
import math
import json
from crimemap import crime_map

DATABASE = 'PoliceIncidents.sqlite'
R_LOCATION = "../backend/"
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

@app.route('/export')
def export_page():
    return render_template('export.html')

@app.route('/crimes/<lat>,<lng>,<startDate>,<endDate>')
def find_crimes(lat, lng, startDate, endDate):
	max_lat = float(lat) + MODULATION_LAT
	min_lat = float(lat) - MODULATION_LAT
	max_long = float(lng) + MODULATION_LNG
	min_long = float(lng) - MODULATION_LNG

	c = get_db().cursor()
	features = []
	for row in c.execute('SELECT * FROM PoliceIncidents where ( (latitude > ? AND latitude < ?) AND (longitude > ? AND longitude < ?) AND (dates > ? and dates < ?))', [min_lat, max_lat, min_long, max_long, startDate, endDate]):
		geometry = { "type": "Point", "coordinates": [row[8], row[7]] }
		minutes = "%02d" % (row[16],)
		description = row[2]+"<br>"+row[12]+"-"+str(row[11])+"-"+str(row[14]) + " " + str(row[15]%12)+":"+ minutes + " " + row[17]
		feature = {"type": "Feature", "geometry": geometry, "properties": {"desc": description, "icon" : crime_map[row[20]] }}
		features.append(feature)
		#print row[20]
		#crimes.append({'geo': {'lat': , 'lng': row[8]}})
	geojson = {"type": "FeatureCollection", "features": features}

	
	return jsonify(geojson = geojson)


@app.route('/crimeIndex/<lat>,<lng>')
def find_index(lat, lng):
	#do python stuff 
	#r=robjects.r
	#r.source("./CrimeIndexSummary.R")
	#full_result = str(r.CrimeIndex("{\"latitude\": \""+lat+"\", \"longitude\": \""+lng+"\"}"))
	#json_data = full_result.split(" ")[1]
	#crime_data = json.loads(json_data)
	#crime_data = json.loads(crime_data)
	#output = {}
	#output["index"] = crime_data["crimeRating"][0]
	#history = {}
	#for i in range(2009, 2015):
		#history[i] = crime_data["crimeRatingYear"][i-2009]
	#output["history"] = crime_data["crimeRatingYear"]
	#return jsonify(crime_data)
	data = {"crimeRating": [98.48, 98.48, 98.48, 98.48, 98.48, 98.48], "crimeRatingYear": [99.46, 99.3, 99.36, 99.32, 98.48, 99.38], "crimeRatingYear_driving": [98.64, 98.74, 98.7, 98.84, 98.28, 99.38], "crimeRatingYear_drugs": [99.32, 97.08, 97.34, 97.52, 96.06, 96.58], "crimeRatingYear_misc": [98.9, 99.1, 99.22, 98.84, 98.6, 99.3], "crimeRatingYear_property": [99.36, 99.3, 99.38, 99.4, 91.92, 99.86], "crimeRatingYear_sexual": [98.5, 96.42, 98.64, 99.3, 93.4, 99.98], "crimeRatingYear_theft": [99.28, 99.3, 99, 99.38, 97.06, 98.96], "crimeRatingYear_violent": [99.28, 99.44, 99.08, 99.28, 96.28, 99.44]}
	return jsonify(data)
	



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug='True')