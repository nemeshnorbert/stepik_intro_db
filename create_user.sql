USE mysql;
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';  		# create user admin and set his password
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';  			# give admin full access to all databases
