#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# NOTE: This is a robust, interactive setup script for a development environment.
# It prompts for user input and includes password confirmation for security.
# While suitable for development, for production, consider a secrets management system.

# Define the database name
DB_NAME="fastapiauthdb"

echo "Beginning PostgreSQL interactive setup..."
echo "This script will create a new user and database for your project."

# Prompt for the new database username
read -p "Enter the desired PostgreSQL username: " DB_USER

# Prompt and confirm the password for the new user
while true; do
    read -sp "Enter the password for '$DB_USER': " DB_PASS
    echo
    read -sp "Confirm the password: " DB_PASS_CONFIRM
    echo
    if [[ "$DB_PASS" == "$DB_PASS_CONFIRM" ]]; then
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

# Prompt and confirm the password for the default 'postgres' user
while true; do
    read -sp "Enter a new password for the default 'postgres' user: " PG_ROOT_PASS
    echo
    read -sp "Confirm the password: " PG_ROOT_PASS_CONFIRM
    echo
    if [[ "$PG_ROOT_PASS" == "$PG_ROOT_PASS_CONFIRM" ]]; then
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

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
echo "Setting a new password for the 'postgres' user..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$PG_ROOT_PASS';"

# Create a new user and a new database for your project
echo "Creating a new database user '$DB_USER', database '$DB_NAME', and local user role 'ubuntu'..."

# Create the database user if it does not already exist
sudo -u postgres psql -c "DO \$do\$ BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$DB_USER') THEN CREATE USER $DB_USER WITH PASSWORD '$DB_PASS'; END IF; END \$do\$;"

# Create the database if it does not already exist and grant privileges
sudo -u postgres psql -c "DO \$do\$ BEGIN IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME') THEN CREATE DATABASE $DB_NAME; END IF; END \$do\$;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# Create a PostgreSQL role for the current system user ('ubuntu') if it doesn't exist
# This allows you to run 'psql' without specifying a user.
sudo -u postgres psql -c "DO \$do\$ BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'ubuntu') THEN CREATE ROLE ubuntu WITH LOGIN; END IF; END \$do\$;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO ubuntu;"

echo "PostgreSQL setup complete!"
echo "Database '$DB_NAME' is ready for use with user '$DB_USER'."
echo "You can now connect as the 'ubuntu' user directly by typing 'psql' on your command line."
echo "Please update your application's .env file with the following:"
echo "POSTGRES_USER=$DB_USER"
echo "POSTGRES_PASSWORD=$DB_PASS"
echo "POSTGRES_DB=$DB_NAME"
echo "POSTGRES_HOST=localhost"
echo "POSTGRES_PORT=5432"
