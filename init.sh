#!/bin/bash

service mysql restart

mysql -u root -p < create_user.sql
mysql -u root -p < create_database.sql
