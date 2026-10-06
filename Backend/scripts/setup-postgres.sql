# Create the PostgreSQL user that our NestJS application will use.
# Replace YOUR_PASSWORD with the password you want to use.
CREATE USER ligand_user WITH PASSWORD 'PASSWORD';

# Create the database used by the application.
CREATE DATABASE ligand_app;

# Give ligand_user all privileges on the ligand_app database.
GRANT ALL PRIVILEGES ON DATABASE ligand_app TO ligand_user;

# Allow ligand_user to create databases.
# Prisma can need this permission for certain migration/shadow-database operations.
ALTER ROLE ligand_user CREATEDB;

# Switch the current PostgreSQL session to the ligand_app database.
\c ligand_app;

# Allow ligand_user to use the public schema.
GRANT USAGE ON SCHEMA public TO ligand_user;

# Allow ligand_user to create objects (tables, etc.) inside the public schema.
GRANT CREATE ON SCHEMA public TO ligand_user;