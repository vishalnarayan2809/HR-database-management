-- This script resets the HR database to its initial state 
-- by dropping existing tables and recreating the entire database structure

-- Drop views first
DROP VIEW IF EXISTS salary_bands CASCADE;
DROP VIEW IF EXISTS department_summary CASCADE;
DROP VIEW IF EXISTS employee_details CASCADE;

-- Drop functions and procedures
DROP FUNCTION IF EXISTS update_modified_date() CASCADE;
DROP FUNCTION IF EXISTS hire_employee(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, DATE, INTEGER, INTEGER, INTEGER, INTEGER, DECIMAL, VARCHAR, DATE, VARCHAR, VARCHAR, VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS update_salary(INTEGER, DECIMAL, VARCHAR, DATE, INTEGER, TEXT) CASCADE;
DROP FUNCTION IF EXISTS department_transfer(INTEGER, INTEGER, INTEGER, INTEGER, DATE, TEXT, INTEGER) CASCADE;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS performance_reviews CASCADE;
DROP TABLE IF EXISTS salary_history CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS jobs CASCADE;
DROP TABLE IF EXISTS locations CASCADE;

-- Recreate the database structure
\i ../migrations/001_initial_schema.sql
\i ../migrations/002_add_indexes.sql
\i ../migrations/003_add_constraints.sql

-- Insert sample data in correct order
\i ../data/sample_locations.sql
\i ../data/sample_jobs.sql
\i ../data/sample_departments.sql
\i ../data/sample_employees.sql
\i ../data/sample_salary_history.sql
\i ../data/sample_performance_reviews.sql

-- Create views
\i ../views/employee_details.sql
\i ../views/department_summary.sql
\i ../views/salary_bands.sql

-- Create stored procedures
\i ../procedures/hire_employee.sql
\i ../procedures/update_salary.sql
\i ../procedures/department_transfer.sql

-- Display completion message
SELECT 'HR Database has been successfully reset!' AS status;