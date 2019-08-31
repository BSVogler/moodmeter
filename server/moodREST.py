#!/usr/bin/python2
# -*- coding: utf-8 -*-
import binascii
from datetime import datetime
from flask import Flask, request, abort, make_response, Response
import os
import hashlib
import shutil

application = Flask(__name__)

password_folder = "passwords/"
userdata_folder = "userdata/"

if not os.path.isdir(password_folder):
    os.makedirs(password_folder)
if not os.path.isdir(userdata_folder):
    os.makedirs(userdata_folder)


def write_measurements_to_csv(repohash, measurements, limit=None):
    """
    Transform python/json to csv
    :param fp: filepointer
    :param measurements: data with fields "day" and "mood"
    :param limit: filter dates before that date
    :return:
    """
    shutil.move(userdata_folder + repohash, userdata_folder + repohash + "~")

    destination = open(userdata_folder + repohash, "w")
    source = open(userdata_folder + repohash + "~", "r")
    for line in source:
        update = False
        date_in_line = datetime.strptime(line[:line.find(";")], "%Y-%m-%dT")
        for index, e in enumerate(measurements):
            # update
            date_to_write = datetime.strptime(e["day"], "%Y-%m-%dT")  # string to date
            if date_to_write == date_in_line:
                destination.write(e["day"] + ";" + str(e["mood"]) + ";\n")
                update = True
                measurements.pop(index)
                break
        if not update:
            destination.write(line)

    # append the rest
    for e in measurements:
        destination.write(e["day"] + ";" + str(e["mood"]) + ";\n")

    source.close()
    destination.close()
    os.remove(userdata_folder + repohash + "~")



@application.route("/")
def root():
    return "moodserver runs"


@application.route('/<string:repohash>', methods=['POST', 'GET'])
def add_data(repohash):
    """

    :param repohash:
    :return:
    """
    if request.method == 'POST':
        if not request.json:
            return abort(400)
        data = request.json["data"]
        # check if file exists, then add
        if os.access(userdata_folder + repohash, os.R_OK):
            # check password
            if os.access(password_folder + repohash, os.R_OK):
                with open(password_folder + repohash, "r") as pfp:
                    stored_hash = pfp.readline()[:-1]  # ignore line break
                    stored_salt = pfp.readline()
                transmitted_hash = hashlib.pbkdf2_hmac('sha256', (data["password"].encode('utf-8')),
                                                       binascii.unhexlify(stored_salt), 10000)
                if binascii.unhexlify(stored_hash) != transmitted_hash:
                    return abort(Response("Invalid passwort"))
            else:
                return abort(Response("Password not found."))

            write_measurements_to_csv(repohash, data["measurements"])
        else:
            # create new entries
            salt = os.urandom(16)
            hash = hashlib.pbkdf2_hmac('sha256', (data["password"].encode('utf-8')), salt, 10000)
            # storing in a text file doubles the file size but this way we can easily use the line break to separate
            # hash and salt when reading
            with open(password_folder + repohash, "w") as fp:
                fp.write(binascii.hexlify(hash) + "\n")
                fp.write(binascii.hexlify(salt))

            # initial write
            with open(userdata_folder + repohash, "w") as fp:
                for e in data["measurements"]:
                    fp.write(e["day"] + ";" + str(e["mood"]) + ";\n")

        return "ok"
    else:
        if os.access(userdata_folder + repohash, os.R_OK):
            with open(userdata_folder + repohash, "r") as fp:
                # todo check password properly
                # if data["password"] != "empty":
                csvdata = fp.read()
                resp = make_response(csvdata, 200)
                resp.headers["Content-Type"] = "text/csv"
                return resp
            # else:
            #    return "wrong password"
        return abort(404)


if __name__ == '__main__':
    application.run()
