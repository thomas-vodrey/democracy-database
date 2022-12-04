from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db

official = Blueprint('official', __name__)

# Get a list of petitions
@official.route('/petitions', methods=['GET'])
def get_precincts():
    cursor = db.get_db().cursor()
    cursor.execute("SELECT petitionID, numSignatures, firstName, middleName, lastName, posName, constituency FROM petition JOIN candidate c on petition.forCandidate = c.candidateID JOIN race r on petition.forRace = r.raceID JOIN electedPosition eP on r.positionFor = eP.electedPosID")
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Add signatures to a petition
@official.route('/petitions/addSignatures', methods=['POST'])
def add_signatures():
    current_app.logger.info(request.form)
    cursor = db.get_db().cursor()
    signatures = request.form['Signatures']
    id = request.form['Petition']
    query = f"UPDATE petition SET numSignatures = numSignatures + {signatures} WHERE petitionID = {id}"
    cursor.execute(query)
    db.get_db().commit()
    return "Signature add success"

# Gets a list of absentee requests that need to be processed
@official.route('/absenteeRequests', methods=['GET'])
def get_abs_requests():
    cursor = db.get_db().cursor()
    cursor.execute("SELECT request, CONCAT(firstName, ' ', middleName, ' ', lastName) AS name, CONCAT(precinctID, ', ', precinctCity, ' Ward ', precinctWard) AS precinct, CONCAT(requestStreet, ', ', requestCity, ' ', requestState, ' ', requestZip) AS mailingAddress FROM absenteeApproval JOIN absenteeRequest aR on absenteeApproval.request = aR.requestID JOIN voter v on aR.requestID = v.absRequest JOIN precinct p on v.homePrecinct = p.precinctID WHERE sent = false")
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

@official.route('/absenteeRequests/markComplete', methods=['POST'])
def abs_request_mark_complete():
    current_app.logger.info(request.form)
    cursor = db.get_db().cursor()
    abs_request = request.form['Request']
    query = f"UPDATE absenteeApproval SET sent = true WHERE request = {abs_request}"
    cursor.execute(query)
    db.get_db().commit()
    return "Mark complete sucess"