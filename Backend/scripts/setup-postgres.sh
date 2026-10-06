#!/bin/bash
set -e
# Update Ubuntu's package list.
sudo apt update

# Install PostgreSQL.
sudo apt install -y postgresql

# Start the PostgreSQL service.
sudo systemctl start postgresql

# Open PostgreSQL's command-line interface as the PostgreSQL administrator.
sudo -u postgres psql < scripts/setup-postgres.sql
