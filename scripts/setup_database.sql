-- This script sets up the HR database by creating the necessary tables and inserting initial data.
-- Tables are created in dependency order to avoid foreign key constraint errors

-- Create database (if needed)
-- CREATE DATABASE hr_database;
-- \c hr_database;

-- Create tables in correct dependency order
\i ../schemas/locations.sql
\i ../schemas/jobs.sql
\i ../schemas/departments.sql
\i ../schemas/employees.sql
\i ../schemas/salary_history.sql
\i ../schemas/performance_reviews.sql

-- Add foreign key constraints that have circular dependencies
ALTER TABLE departments ADD CONSTRAINT fk_departments_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

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