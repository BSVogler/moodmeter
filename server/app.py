#!/usr/bin/python
# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
from flask import Flask, request, abort, make_response, Response
import os
import hashlib

app = Flask(__name__)


def measurements_json_to_csv(fp, measurements, limit=None):
    for e in measurements:
        if limit is None:
            fp.write(e["day"]+";"+str(e["mood"])+";\n")
        else:
            date = datetime.strptime(e["day"], "%Y-%m-%dT")
            if date > limit:
                fp.write(e["day"] + ";" + str(e["mood"]) + ";\n")
            else:
                print("Invalid date")

@app.route('/<string:repohash>', methods=['POST', 'GET'])
def add_data(repohash):
    """

    :param repohash:
    :return:
    """
    if request.method == 'POST':
        if not request.json:
            return abort(400)
        data = request.json["data"]
        # check if exists
        if os.access("userdata/"+repohash, os.R_OK):
            # check password
            if os.access("passwords/" + repohash, os.R_OK):
                with open("passwords/" + repohash, "r") as pfp:
                    stored_hash = pfp.readline()
                transmitted_hash = hashlib.sha224(data["password"].encode('utf-8')).hexdigest()
                if stored_hash != transmitted_hash:
                    return abort(Response("Invalid passwort"))
            else:
                return abort(Response("Password not found."))

            with open("userdata/"+repohash, "a") as fp:
                # check if date is allowed.
                last_entry = None
                with open("userdata/"+repohash, 'r') as f:
                    lines = f.read().splitlines()
                    last_line = lines[-1]
                datestring = last_line[:last_line.find(';')]
                last_entry = datetime.strptime(datestring, "%Y-%m-%dT")

                measurements_json_to_csv(fp, data["measurements"], last_entry)
        else:
            transmitted_hash = hashlib.sha224(data["password"].encode('utf-8')).hexdigest()
            with open("passwords/" + repohash, "w") as fp:
                fp.write(transmitted_hash)

            with open("userdata/"+repohash, "w") as fp:
                measurements_json_to_csv(fp, data["measurements"])

        return "ok"
    else:
        if os.access("userdata/"+repohash, os.R_OK):
            with open("userdata/"+repohash, "r") as fp:
                # todo check password properly
                #if data["password"] != "empty":
                    csvdata = fp.read()
                    resp = make_response(csvdata, 200)
                    resp.headers["Content-Type"] = "text/csv"
                    return resp
                #else:
                #    return "wrong password"
        return abort(404)


if __name__ == '__main__':
    app.run()
