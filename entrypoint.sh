#!/bin/bash

sleep 30s
# Run the create_db.py script
python application/create_db.py

exec $@
