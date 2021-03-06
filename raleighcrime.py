from flask import Flask, render_template, abort, request, jsonify, g
import sqlite3
import rpy2.robjects as robjects
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

@app.route('/<search_query>,')
def export_new(search_query):
	searches = search_query.split(',');
	if (len(searches) % 3 == 0):
		points = []
		names = []
		it = iter(searches)
		for p in it:
			names.append(p);
			points.append([next(it),next(it)])
		indexes = []
		summaries = []
		for point in points:
			indexes.append(r_find_index(point[0], point[1]))
			summaries.append(r_get_summary(point[0], point[1]))
		return render_template('export.html', points = points, indexes = indexes, summaries = summaries, names = names)
	else:
		return abort(500)

def find_filter(mytype):
	types = { "Violent Crimes":["ASSAULT", "WEAPONS", "KIDNAPPING", "HUMAN TRAFFICKING", "HOMICIDE"],
		"Driving": ["DRIVING", "VEHICLE"],
		"Drugs/Alcohol": ["DRUGS","ALCOHOL"],
		"Theft/Burglary": ["BURGLARY", "ROBBERY", "FRAUD", "LARCENY", "FORGERY", "STOLEN PROPERTY", "EMBEZZLEMENT"],
		"Property Damage": ["DAMAGE PROPERTY"],
		"Sexual Offense": ["SEX OFFENSE", "PROSTITUTION", "PORNOGRAPHY"],
		"Miscellaneous": ["MISC", "HUMANE", "CHILD", "FAMILY", "JUVENILE", "DISORDERLY", "EXTORTION", "GAMBLING", "ALL", "NOISE"] }

	for key, value in types.iteritems():
		if mytype in value:
			return key
	return "Miscellaneous"

@app.route('/crimes/<lat>,<lng>,<startDate>,<endDate>')
def find_crimes(lat, lng, startDate, endDate):
	max_lat = float(lat) + MODULATION_LAT
	min_lat = float(lat) - MODULATION_LAT
	max_long = float(lng) + MODULATION_LNG
	min_long = float(lng) - MODULATION_LNG

	c = get_db().cursor()
	features = []
	categoryCount = { "Violent Crimes": 0, "Driving": 0, "Drugs/Alcohol": 0, "Theft/Burglary":0, "Property Damage": 0, "Sexual Offense": 0, "Miscellaneous": 0 }
	totalCount = 0 
	for row in c.execute('SELECT * FROM PoliceIncidents where ( (latitude > ? AND latitude < ?) AND (longitude > ? AND longitude < ?) AND (dates > ? and dates < ?))', [min_lat, max_lat, min_long, max_long, startDate, endDate]):
		geometry = { "type": "Point", "coordinates": [row[8], row[7]] }
		minutes = "%02d" % (row[16],)
		description = row[2]+"<br>"+row[12]+"-"+str(row[11])+"-"+str(row[14]) + " " + str(row[15]%12)+":"+ minutes + " " + row[17]
		feature = {"type": "Feature", "geometry": geometry, "properties": {"desc": description, "icon" : crime_map[row[20]], "filter": find_filter(row[20]), "type1": row[26], "hour": row[15] }}
		categoryCount[find_filter(row[20])] += 1
		totalCount += 1
		features.append(feature)
		#print row[20]
		#crimes.append({'geo': {'lat': , 'lng': row[8]}})
	geojson = {"type": "FeatureCollection", "features": features}

	if totalCount > 0:
		for key in categoryCount.iterkeys():
			categoryCount[key] = float(categoryCount[key])/float(totalCount) * 100

	return jsonify(geojson = geojson, categoryCount = categoryCount)

def r_find_index(lat,lng):
	#do python stuff
	r=robjects.r
	r.source("./CrimeIndexSummaryTier.R")
	full_result = str(r.CrimeIndex("{\"latitude\": \""+lat+"\", \"longitude\": \""+lng+"\"}"))
	json_data = full_result.split(" ")[1]
	crime_data = json.loads(json_data)
	crime_data = json.loads(crime_data)
	output = {}
	return crime_data

def r_get_summary(lat,lng):
	r=robjects.r
	r.source("./CrimeIndexWrittenSummary.R")
	full_result = str(r.CrimeWrittenSummary("{\"latitude\": \""+lat+"\", \"longitude\": \""+lng+"\"}"))
	json_data = full_result[4:]
	summary = json.loads(json_data)
	summary = json.loads(summary)
	#output = {}
	return summary

@app.route('/crimeIndex/<lat>,<lng>')
def find_index(lat, lng):
	try:
		return jsonify(r_find_index(lat,lng))
	except ValueError:
		return jsonify({}), 403




if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug='True')
