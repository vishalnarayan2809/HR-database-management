-- HR Database Setup Script
-- This script sets up the HR database by creating the necessary tables and inserting initial data.
-- Tables are created in dependency order to avoid foreign key constraint errors
-- Run this from the project root directory using: psql -U postgres -d hr_database -f scripts/setup_database.sql

-- Create database (if needed)
-- CREATE DATABASE hr_database;
-- \c hr_database;

-- Create tables in correct dependency order
\i schemas/locations.sql
\i schemas/jobs.sql
\i schemas/departments.sql
\i schemas/employees.sql
\i schemas/salary_history.sql
\i schemas/performance_reviews.sql

-- Add foreign key constraints that have circular dependencies
ALTER TABLE departments ADD CONSTRAINT fk_departments_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- Insert sample data in correct order
\i data/sample_locations.sql
\i data/sample_jobs.sql
\i data/sample_departments.sql
\i data/sample_employees.sql
\i data/sample_salary_history.sql
\i data/sample_performance_reviews.sql

-- Create views for reporting
\i views/employee_details.sql
\i views/department_summary.sql
\i views/salary_bands.sql

-- Create stored procedures
\i procedures/hire_employee.sql
\i procedures/update_salary.sql
\i procedures/department_transfer.sql

-- Final verification
SELECT 'Setup completed successfully!' as status;
SELECT 'Tables created: ' || count(*) as tables_info FROM information_schema.tables WHERE table_schema = 'public';
SELECT 'Sample data loaded:' as info;
SELECT 'Employees: ' || count(*) as employee_count FROM employees;
SELECT 'Departments: ' || count(*) as department_count FROM departments;
SELECT 'Locations: ' || count(*) as location_count FROM locations;
SELECT 'Jobs: ' || count(*) as job_count FROM jobs;
SELECT 'Salary History: ' || count(*) as salary_history_count FROM salary_history;
SELECT 'Performance Reviews: ' || count(*) as performance_review_count FROM performance_reviews;
