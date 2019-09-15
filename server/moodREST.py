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


def hasAccess(repohash, password):
    if os.access(password_folder + repohash, os.R_OK):
        with open(password_folder + repohash, "r") as pfp:
            stored_hash = pfp.readline()[:-1]  # ignore line break
            stored_salt = pfp.readline()
        transmitted_hash = hashlib.pbkdf2_hmac('sha256',
                                               password,
                                               binascii.unhexlify(stored_salt),
                                               10000)
        if binascii.unhexlify(stored_hash) != transmitted_hash:
            return abort(Response("Invalid passwort"))
    else:
        return abort(Response("Password not found."))
    return True


@application.route('/<string:repohash>', methods=['POST', 'GET', 'DELETE'])
def add_data(repohash):
    """

    :param repohash:
    :return:
    """
    if request.method == 'POST':
        if not request.json:
            return abort(400)
        request_data = request.json["data"]
        # check if file exists, then add new measurement
        if os.access(userdata_folder + repohash, os.R_OK):
            # check password
            access = hasAccess(repohash, request_data["password"].encode('utf-8'))
            if access:
                write_measurements_to_csv(repohash, request_data["measurements"])
            else:  # no access
                return access
        else:  # save new entries
            # is move request?
            if "old_hash" in request_data and len(request_data["old_hash"]) > 0:
                # move old data to new hash
                access = hasAccess(request_data["old_hash"], request_data["password"].encode('utf-8'))
                if access:
                    os.rename(userdata_folder + request_data["old_hash"], userdata_folder + repohash)
                    # append new data
                    with open(userdata_folder + repohash, "wa") as fp:
                        for e in request_data["measurements"]:
                            fp.write(e["day"] + ";" + str(e["mood"]) + ";\n")
                    # success, so remove old password
                    os.remove(password_folder + request_data["old_hash"])
                else:
                    # authentication failed
                    return abort(403)
            else:
                # initial write of data
                with open(userdata_folder + repohash, "w") as fp:
                    for e in request_data["measurements"]:
                        fp.write(e["day"] + ";" + str(e["mood"]) + ";\n")

            # save password
            salt = os.urandom(16)
            pw_hashed = hashlib.pbkdf2_hmac('sha256', (request_data["password"].encode('utf-8')), salt, 10000)
            # storing in a text file doubles the file size but this way we can easily use the line break to separate
            # hash and salt when reading
            with open(password_folder + repohash, "w") as fp:
                fp.write(binascii.hexlify(pw_hashed) + "\n")
                fp.write(binascii.hexlify(salt))

        return "ok"
    elif request.method == 'GET':
        if os.access(userdata_folder + repohash, os.R_OK):
            with open(userdata_folder + repohash, "r") as fp:
                # todo check password properly
                # if request_data["password"] != "empty":
                csvdata = fp.read()
                resp = make_response(csvdata, 200)
                resp.headers["Content-Type"] = "text/csv"
                return resp
            # else:
            #    return "wrong password"
        return abort(404)
    elif request.method == 'DELETE':
        if not request.json:
            return abort(400)
        request_data = request.json["data"]
        access = hasAccess(repohash, request_data["password"].encode('utf-8'))
        if access:
            if os.access(userdata_folder + repohash, os.R_OK):
                os.remove(userdata_folder + repohash)
            if os.access(password_folder + repohash, os.R_OK):
                os.remove(password_folder + repohash)
            return "ok"
        else:
            return access


if __name__ == '__main__':
    application.run()
