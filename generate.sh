#!/bin/bash

mkdir modules/key_pair/keys
echo -e 'y\n' | ssh-keygen -t rsa -f modules/key_pair/keys/id_rsa -P ""
