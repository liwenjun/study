CREATE USER dev;
CREATE DATABASE devdb owner dev;
-- GRANT ALL PRIVILEGES ON DATABASE devdb TO dev;
ALTER ROLE dev WITH PASSWORD 'password';
