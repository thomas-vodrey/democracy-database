from flask import Blueprint, request, jsonify, make_response
import json
from src import db

candidate = Blueprint('candidate', __name__)

# Get a list of petitions for candidates for an office
@candidate.route('/petitions/<posID>', methods=['GET'])
def get_petitions(posID):
    cursor = db.get_db().cursor()
    cursor.execute("SELECT lastName AS Last, firstName AS First, numSignatures AS Signatures, CASE WHEN numSignatures > signatureReq THEN TRUE ELSE FALSE END AS Qualified, residence AS Residency, posName AS Office, constituency AS Constituency, term AS Term, salary AS Salary, ofLevel AS Level FROM petition JOIN race r on petition.forRace = r.raceID JOIN electedPosition eP on r.positionFor = eP.electedPosID JOIN candidate c on petition.forCandidate = c.candidateID WHERE electedPosID = '{0}'".format(posID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get a list of offices and their IDs, for select widgets
@candidate.route('/offices', methods=['GET'])
def get_offices():
    cursor = db.get_db().cursor()
    cursor.execute("SELECT CONCAT(posName, ', ', constituency) AS label, electedPosID AS value FROM electedPosition")
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get information on a specific office
@candidate.route('/offices/<officeID>', methods=['GET'])
def get_office(officeID):
    cursor = db.get_db().cursor()
    cursor.execute("SELECT posName, constituency, term, salary, signatureReq, ofLevel FROM electedPosition WHERE electedPosID = {0}".format(officeID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get a list of parties and their IDs, for select widgets
@candidate.route('/parties', methods=['GET'])
def get_parties():
    cursor = db.get_db().cursor()
    cursor.execute("SELECT partyName AS label, partyID AS value FROM politicalParty")
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get a list of cities, for select widgets
@candidate.route('/cities', methods=['GET'])
def get_cities():
    cursor = db.get_db().cursor()
    cursor.execute("SELECT DISTINCT city AS label, city AS value FROM voter")
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get a list of precincts, for select widgets
@candidate.route('/precincts', methods=['GET'])
def get_precincts():
    cursor = db.get_db().cursor()
    cursor.execute("SELECT CONCAT(precinctID, ', ', precinctCity, ' Ward ', precinctWard) AS label, precinctID AS value FROM precinct")
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get a list of voters based on city, party, or precinct
@candidate.route('/findVoter', methods=['GET'])
def find_voter():
    cursor = db.get_db().cursor()
    city = request.form['City']
    party = request.form['Party']
    precinct = request.form['Precinct']
    cursor.execute(f"SELECT firstName, middleName, lastName, dob, street, city, state, zip, partyName, CONCAT(precinctID, ', ', precinctCity, ' Ward ', precinctWard) AS precinct FROM voter JOIN politicalParty pP on voter.partyAfil = pP.partyID JOIN precinct p on voter.homePrecinct = p.precinctID WHERE city = '{city}' OR partyAfil = {party} OR homePrecinct = {precinct}")
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response