#!/bin/bash

# git clone https://github.com/amyasnov/stepic-db-intro.git

service mysql restart

mysql -u root -p < create_user.sql
mysql -u root -p < create_database.sql
