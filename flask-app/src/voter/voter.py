from flask import Blueprint, request, jsonify, make_response
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
