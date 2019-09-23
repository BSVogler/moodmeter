#!/usr/bin/python2
# -*- coding: utf-8 -*-
import binascii
from datetime import datetime
from flask import Flask, request, abort, make_response, Response
import os
import hashlib
import shutil
import csv
import logging
import time
#from flask.logging import default_handler


application = Flask(__name__)

userdata_folder = "userdata/"
logging.basicConfig(filename="moodRest.log",
                    filemode='a',
                    format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                    datefmt='%H:%M:%S',
                    level=logging.DEBUG)
#application.logger.removeHandler(default_handler) # DSGVO no ip address saved

logging.info("Running moodREST")

logger = logging.getLogger('moodREST')

if not os.path.isdir(userdata_folder):
    os.makedirs(userdata_folder)

def merge(fp_old_read, old, new):
    # read old data
    reader = csv.reader(fp_old_read, delimiter=';')
    measurements = []
    # ignore pasword and salt
    skip = 2
    for row in reader:
        if skip > 2:
            skip -= 1
        else:
            measure = dict()
            measure["day"] = row[0]
            measure["mood"] = row[1]
            measurements.append(measure)
    add_measurements_to_csv(new, measurements)
    # then delete old
    os.remove(userdata_folder + old+".csv")


def add_measurements_to_csv(repohash, measurements, limit=None):
    """
    Integrates new measurements by transform the python/json to csv.
    :param fp: filepointer
    :param measurements: data with fields "day" and "mood"
    :param limit: filter dates before that date
    :return:
    """

    name_src = userdata_folder + repohash+".csv"
    name_tmp = userdata_folder + repohash + ".csv~"
    shutil.move(name_src, name_tmp)

    destination = open(name_src, "w")
    source = open(name_tmp, "r")
    # check if a line must be updated
    skip = 2 # skip header
    for line in source:
        update = False
        if skip > 0:
            skip -= 1
        else:
            date_in_line = datetime.strptime(line[:line.find(";")], "%Y-%m-%dT")
            for index, e in enumerate(measurements):
                # update
                date_to_write = datetime.strptime(e["day"], "%Y-%m-%dT")  # string to date
                if date_to_write == date_in_line:
                    destination.write(e["day"] + ";" + str(e["mood"]) + "\n")
                    update = True
                    measurements.pop(index)
                    break
        if not update:
            destination.write(line)

    # append the rest
    for e in measurements:
        destination.write(e["day"] + ";" + str(e["mood"]) + "\n")

    source.close()
    destination.close()
    os.remove(name_tmp)


@application.route("/")
def root():
    return "moodserver runs"


def has_access(repohash, password, rights="r"):
    if os.access(userdata_folder + repohash+".csv", os.R_OK):
        pfp = open(userdata_folder + repohash+".csv", rights)
        stored_hash = pfp.readline()[:-2]  # ignore line break and delimiter
        stored_salt = pfp.readline()[:-2]
        transmitted_hash = hashlib.pbkdf2_hmac('sha256',
                                               password,
                                               binascii.unhexlify(stored_salt),
                                               10000)
        if binascii.unhexlify(stored_hash) == transmitted_hash:
            return pfp
    return None


def writeFile(hash, password, measurements):
    # save password
    salt = os.urandom(16)
    pw_hashed = hashlib.pbkdf2_hmac('sha256', password, salt, 10000)
    # storing in a text file doubles the file size but this way we can easily use the line break to separate
    # hash and salt when reading
    with open(userdata_folder + hash+".csv", "w") as fp:
        fp.write(binascii.hexlify(pw_hashed) + ";\n")
        fp.write(binascii.hexlify(salt) + ";\n")
        for e in measurements:
            fp.write(e["day"] + ";" + str(e["mood"]) + "\n")


def readFile(hash, password):
    fp = has_access(hash, password)
    if fp is not None:
        fp.readline() #skip password
        fp.readline() #skip salt
        csvdata = fp.read()
        return csvdata
        # else:
        #    return "wrong password"


@application.route('/<string:repohash>', methods=['POST', 'GET', 'DELETE'])
def add_data(repohash):
    """

    :param repohash:
    :return:
    """
    start = time.time()
    repohash = repohash.lower()
    filename = userdata_folder + repohash+".csv"
    action = "default"
    if request.method == 'POST':
        if not request.json:
            logger.info("{:10.4f}".format((time.time() - start) * 1000) + "ms " + action + " fail")
            return abort(400)
        request_data = request.json["data"]
        # check if file exists, then add new measurement
        if os.access(filename, os.R_OK):
            # check password
            fp_new = has_access(repohash, request_data["password"].encode('utf-8'))
            if fp_new is not None:
                fp_new.close()
                # merge request?
                if "old_hash" in request_data and len(request_data["old_hash"]) > 0\
                        and "old_password" in request_data:
                    action = "merge"
                    fp_old_read = has_access(request_data["old_hash"].lower(), request_data["old_password"].encode('utf-8'), "r")
                    if fp_old_read is not None:
                        merge(fp_old_read, request_data["old_hash"].lower(), repohash)
                add_measurements_to_csv(repohash, request_data["measurements"])
            else:  # no access
                logger.info("{:10.4f}".format((time.time() - start) * 1000) + "ms " + action + " fail")
                return abort(Response("Invalid passwort for "+repohash+"."))
        else:  # save to new hash
            # append new data
            measurements = None
            if "measurements" in request_data:
                measurements = request_data["measurements"]

            # is move request?
            if "old_hash" in request_data and len(request_data["old_hash"]) > 0:
                old_hash = request_data["old_hash"].lower()
                action = "move"
                old_pw = request_data["old_password"].encode('utf-8')
                access_old = has_access(old_hash, old_pw)
                if access_old:
                    access_old.close()
                    # move old data to new hash
                    os.rename(userdata_folder + old_hash+".csv", userdata_folder + repohash+".csv")
                else:
                    # authentication failed
                    logger.info("{:10.4f}".format((time.time() - start) * 1000) + "ms "+ action +" fail")
                    return abort(403)

            writeFile(repohash, (request_data["password"].encode('utf-8')), measurements)
        # disable log because this may make the request slower.
        #ip = request.remote_addr #only returning proxi address
        logger.info("{:10.4f}".format((time.time()-start)*1000) +"ms "+action)
        return "ok"
    elif request.method == 'GET':
        # todo check password properly
        # if "password" in request_data:
        password = ""
        if not os.access(filename, os.R_OK):
            return abort(404)
        with open(filename) as fp:
            fp.readline()  # skip password
            fp.readline()  # skip salt
            csvdata = fp.read()
            resp = make_response(csvdata, 200)
            resp.headers["Content-Type"] = "text/csv"
            logger.info("{:10.4f}".format((time.time() - start) * 1000) + "ms get")
            return resp
        return abort(500)
    elif request.method == 'DELETE':
        if not request.json:
            return abort(400)
        request_data = request.json["data"]
        fp = has_access(repohash, request_data["password"].encode('utf-8'))
        if fp is not None:
            if os.access(filename, os.R_OK):
                os.remove(filename)
            logger.info("{:10.4f}".format((time.time() - start) * 1000) + "ms delete")
            return "ok"
        else:
            logger.info("{:10.4f}".format((time.time() - start) * 1000) + "ms delete fail")
            return abort(Response("Invalid passwort for "+repohash+"."))


if __name__ == '__main__':
    application.run()

