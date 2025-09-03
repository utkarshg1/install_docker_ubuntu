#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Prompt the user for the new database username and password
read -p "Enter the desired PostgreSQL username: " DB_USER
read -p "Enter the desired password for the new user: " -s DB_PASS
echo # Move to a new line after the password prompt

# Prompt the user for the default 'postgres' user password
read -p "Enter a password for the default 'postgres' user: " -s PG_ROOT_PASS
echo # Move to a new line after the password prompt

# Update the package list
echo "Updating package list..."
sudo apt-get update

# Install PostgreSQL and its contrib package
echo "Installing PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

# Start the PostgreSQL service
echo "Starting PostgreSQL service..."
sudo systemctl start postgresql.service

# Check the status of the service
echo "Checking PostgreSQL service status..."
sudo systemctl status postgresql.service --no-pager

# Change the default postgres user password
echo "Switching to postgres user to set up a new user and database..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$PG_ROOT_PASS';"

# Create a new user and a new database for your project
echo "Creating a new database user '$DB_USER' and database 'fastapiauthdb'..."

# Create the database user
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"

# Create the database and grant privileges
sudo -u postgres psql -c "CREATE DATABASE fastapiauthdb;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fastapiauthdb TO $DB_USER;"

echo "PostgreSQL setup complete!"
echo "You can now connect to your new database 'fastapiauthdb' with user '$DB_USER' and the password you entered."
echo "The default 'postgres' user's password has been updated as well."
echo "Remember to update your .env file with these new credentials."
