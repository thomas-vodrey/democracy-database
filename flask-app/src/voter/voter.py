from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db

voter = Blueprint('voter', __name__)

# Get all voters from the DB
@voter.route('/voters', methods=['GET'])
def get_voters():
    cursor = db.get_db().cursor()
    cursor.execute('select * from voter')
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Gets the VoterID of a voter from their SSN
@voter.route('/findvoter/ssn/<socSec>', methods=['GET'])
def get_voter_ssn(socSec):
    cursor = db.get_db().cursor()
    cursor.execute("select voterID from voter where ssn = '{0}'".format(socSec))
    return str(cursor.fetchone()[0])

# Get a voter with a license
@voter.route('/findvoter/lic/<drivLic>', methods=['GET'])
def get_voter_lic(drivLic):
    cursor = db.get_db().cursor()
    cursor.execute("select voterID from voter where license = '{0}'".format(drivLic))
    return str(cursor.fetchone()[0])

# Get a voter with a VoterID
@voter.route('/findvoter/id/<vID>', methods=['GET'])
def get_voter_id(vID):
    cursor = db.get_db().cursor()
    cursor.execute("SELECT * FROM voter JOIN politicalParty pP on pP.partyID = voter.partyAfil JOIN precinct p on voter.homePrecinct = p.precinctID JOIN pollingPlace pP2 on p.location = pP2.pollingPlaceID JOIN election e on p.curElection = e.electionID WHERE voterID = '{0}'".format(vID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Gets the races of a specific election
@voter.route('/findraces/<eID>', methods=['GET'])
def get_races(eID):
    cursor = db.get_db().cursor()
    cursor.execute("SELECT posName AS Position, constituency AS Constituency, term AS Term, raceID AS ZID FROM race JOIN electedPosition eP on race.positionFor = eP.electedPosID WHERE inElection = {0}".format(eID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Gets the candidates of a race
@voter.route('/findcandidates/<rID>', methods=['GET'])
def get_candidates(rID):
    cursor = db.get_db().cursor()
    cursor.execute("SELECT firstName AS First, lastName AS Last, partyName AS Party FROM candidate JOIN politicalParty pP on candidate.partyMemb = pP.partyID JOIN race r on candidate.raceIn = r.raceID WHERE raceID = {0}".format(rID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Adds a voter to the voter rolls
@voter.route('/register', methods=['POST'])
def register_voter():
    current_app.logger.info(request.form)
    cursor = db.get_db().cursor()
    ssn = request.form['SSN']
    licNum = request.form['LicNum']
    fName = request.form['FirstName']
    mName = request.form['MiddleName']
    lName = request.form['LastName']
    dob = request.form['DOB']
    street = request.form['Street']
    city = request.form['City']
    zip = request.form['ZIP']
    party = request.form['Party']
    query = f"INSERT INTO voter (ssn, license, firstName, middleName, lastName, dob, street, city, state, zip, partyAfil, homePrecinct, absRequest) VALUES ('{ssn}', '{licNum}', '{fName}', '{mName}', '{lName}', '{dob}', '{street}', '{city}', 'WC', {zip}, {party}, 1, null)"
    cursor.execute(query)
    db.get_db().commit()
    return "Voter Registration Success"

# Changes a voter's registration address or party
@voter.route('/changeReg', methods=['POST'])
def change_reg():
    current_app.logger.info(request.form)
    cursor = db.get_db().cursor()
    street = request.form['Street']
    city = request.form['City']
    zip = request.form['ZIP']
    party = request.form['Party']
    id = request.form['VoterID']
    query = f"UPDATE voter SET street = '{street}', city = '{city}', zip = {zip}, partyAfil = {party} WHERE voterID = {id}"
    cursor.execute(query)
    db.get_db().commit()
    return "Voter Registration Change Success"