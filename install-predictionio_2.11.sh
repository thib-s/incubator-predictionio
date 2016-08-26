#!/bin/bash

mkdir usr
mkdir usr/vendors
mkdir usr/vendors/predictionio

bash -c "$(curl -s https://raw.githubusercontent.com/apache/incubator-predictionio/master/bin/install.sh)"

