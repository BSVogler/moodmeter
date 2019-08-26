#!/usr/bin/python3
# -*- coding: utf-8 -*-
import binascii
from datetime import datetime, timedelta
from flask import Flask, request, abort, make_response, Response
import os
import hashlib

app = Flask(__name__)

password_folder = "passwords/"
userdata_folder = "userdata/"

if not os.path.isdir(password_folder):
    os.makedirs(password_folder)
if not os.path.isdir(userdata_folder):
    os.makedirs(userdata_folder)

def measurements_json_to_csv(fp, measurements, limit=None):
    """
    Transform python/json to csv
    :param fp: filepointer
    :param measurements: data
    :param limit: filter dates
    :return:
    """
    for e in measurements:
        if limit is None:
            fp.write(e["day"]+";"+str(e["mood"])+";\n")
        else:
            date = datetime.strptime(e["day"], "%Y-%m-%dT")
            if date >= limit:
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
        # check if exists, then add
        if os.access(userdata_folder + repohash, os.R_OK):
            # check password
            if os.access(password_folder + repohash, os.R_OK):
                with open(password_folder + repohash, "r") as pfp:
                    stored_hash = pfp.readline()[:-1]  # ignore line break
                    stored_salt = pfp.readline()
                transmitted_hash = hashlib.pbkdf2_hmac('sha256', (data["password"].encode('utf-8')), binascii.unhexlify(stored_salt), 10000)
                if binascii.unhexlify(stored_hash) != transmitted_hash:
                    return abort(Response("Invalid passwort"))
            else:
                return abort(Response("Password not found."))

            with open(userdata_folder + repohash, "a") as fp:
                # check if date is allowed.
                last_entry = None
                with open(userdata_folder + repohash, 'r') as f:
                    lines = f.read().splitlines()
                    last_line = lines[-1]
                datestring = last_line[:last_line.find(';')]
                last_entry = datetime.strptime(datestring, "%Y-%m-%dT")

                measurements_json_to_csv(fp, data["measurements"], last_entry)
        else:
            #create new entries
            salt = os.urandom(16)
            transmitted_hash = hashlib.pbkdf2_hmac('sha256', (data["password"].encode('utf-8')), salt, 10000)
            # storing in a text file doubles the file size but this way we can easily use the line break to separate hash and salt when reading
            with open(password_folder + repohash, "w") as fp:
                fp.write(bytes.hex(transmitted_hash)+"\n")
                fp.write(bytes.hex(salt))

            with open(userdata_folder + repohash, "w") as fp:
                measurements_json_to_csv(fp, data["measurements"])

        return "ok"
    else:
        if os.access(userdata_folder + repohash, os.R_OK):
            with open(userdata_folder + repohash, "r") as fp:
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
