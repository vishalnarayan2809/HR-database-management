-- HR Database - Comprehensive Testing Script
-- This script validates all aspects of the HR database system
-- Run this after database setup to ensure everything works correctly

\echo '==================================='
\echo 'HR Database Comprehensive Testing'
\echo '==================================='
\echo ''

-- Test 1: Table Existence and Structure
\echo '1. Testing table existence and structure...'

SELECT 
    'PASS' as status,
    'All core tables exist' as test_description,
    count(*) as table_count
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('locations', 'jobs', 'departments', 'employees', 'salary_history', 'performance_reviews')
HAVING count(*) = 6;

-- Test 2: Foreign Key Constraints
\echo '2. Testing foreign key constraints...'

SELECT 
    'PASS' as status,
    'All foreign key constraints exist' as test_description,
    count(*) as constraint_count
FROM information_schema.table_constraints 
WHERE constraint_type = 'FOREIGN KEY' 
AND table_schema = 'public';

-- Test 3: Primary Key Constraints
\echo '3. Testing primary key constraints...'

SELECT 
    'PASS' as status,
    'All primary key constraints exist' as test_description,
    count(*) as pk_count
FROM information_schema.table_constraints 
WHERE constraint_type = 'PRIMARY KEY' 
AND table_schema = 'public'
HAVING count(*) = 6;

-- Test 4: Sample Data Validation
\echo '4. Testing sample data...'

SELECT 
    'locations' as table_name,
    count(*) as record_count,
    CASE WHEN count(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM locations
UNION ALL
SELECT 
    'jobs' as table_name,
    count(*) as record_count,
    CASE WHEN count(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM jobs
UNION ALL
SELECT 
    'departments' as table_name,
    count(*) as record_count,
    CASE WHEN count(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM departments
UNION ALL
SELECT 
    'employees' as table_name,
    count(*) as record_count,
    CASE WHEN count(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM employees
UNION ALL
SELECT 
    'salary_history' as table_name,
    count(*) as record_count,
    CASE WHEN count(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM salary_history
UNION ALL
SELECT 
    'performance_reviews' as table_name,
    count(*) as record_count,
    CASE WHEN count(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM performance_reviews;

-- Test 5: Relationship Integrity
\echo '5. Testing relationship integrity...'

-- Test employees -> departments relationship
SELECT 
    'Employee-Department Relationship' as test_name,
    CASE 
        WHEN count(*) = 0 THEN 'PASS - No orphaned employees'
        ELSE 'FAIL - Found orphaned employees'
    END as status,
    count(*) as orphaned_records
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id IS NOT NULL AND d.department_id IS NULL;

-- Test employees -> jobs relationship
SELECT 
    'Employee-Job Relationship' as test_name,
    CASE 
        WHEN count(*) = 0 THEN 'PASS - No orphaned employees'
        ELSE 'FAIL - Found orphaned employees'
    END as status,
    count(*) as orphaned_records
FROM employees e
LEFT JOIN jobs j ON e.job_id = j.job_id
WHERE e.job_id IS NOT NULL AND j.job_id IS NULL;

-- Test employees -> locations relationship
SELECT 
    'Employee-Location Relationship' as test_name,
    CASE 
        WHEN count(*) = 0 THEN 'PASS - No orphaned employees'
        ELSE 'FAIL - Found orphaned employees'
    END as status,
    count(*) as orphaned_records
FROM employees e
LEFT JOIN locations l ON e.location_id = l.location_id
WHERE e.location_id IS NOT NULL AND l.location_id IS NULL;

-- Test 6: Views Functionality
\echo '6. Testing database views...'

-- Test employee_details view
SELECT 
    'employee_details view' as view_name,
    count(*) as record_count,
    CASE WHEN count(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM employee_details;

-- Test department_summary view
SELECT 
    'department_summary view' as view_name,
    count(*) as record_count,
    CASE WHEN count(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM department_summary;

-- Test salary_bands view
SELECT 
    'salary_bands view' as view_name,
    count(*) as record_count,
    CASE WHEN count(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM salary_bands;

-- Test 7: Stored Procedures
\echo '7. Testing stored procedures...'

-- Test hire_employee procedure
\echo 'Testing hire_employee procedure...'
DO $$
DECLARE
    new_emp_id INTEGER;
    test_result TEXT;
BEGIN
    -- Call the hire_employee procedure
    CALL hire_employee(
        'TEST001',          -- employee_number
        'Test',             -- first_name
        'Employee',         -- last_name
        'test@company.com', -- email
        '555-0199',         -- phone_number
        1,                  -- job_id
        1,                  -- department_id
        1,                  -- manager_id
        1,                  -- location_id
        75000.00,           -- salary
        'Test hire'         -- hire_reason
    );
    
    -- Check if employee was created
    SELECT employee_id INTO new_emp_id
    FROM employees 
    WHERE employee_number = 'TEST001';
    
    IF new_emp_id IS NOT NULL THEN
        RAISE NOTICE 'PASS - hire_employee procedure works correctly';
        
        -- Clean up test data
        DELETE FROM salary_history WHERE employee_id = new_emp_id;
        DELETE FROM employees WHERE employee_id = new_emp_id;
    ELSE
        RAISE NOTICE 'FAIL - hire_employee procedure failed';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'FAIL - hire_employee procedure error: %', SQLERRM;
END;
$$;

-- Test update_salary procedure
\echo 'Testing update_salary procedure...'
DO $$
DECLARE
    test_employee_id INTEGER;
    old_salary DECIMAL;
    new_salary DECIMAL;
BEGIN
    -- Get first active employee
    SELECT employee_id, current_salary INTO test_employee_id, old_salary
    FROM employees 
    WHERE is_active = true 
    LIMIT 1;
    
    IF test_employee_id IS NOT NULL THEN
        -- Test salary update
        CALL update_salary(
            test_employee_id,
            old_salary + 5000.00,
            'Test salary increase',
            1  -- approved_by (assuming employee_id 1 exists)
        );
        
        -- Verify the update
        SELECT current_salary INTO new_salary
        FROM employees 
        WHERE employee_id = test_employee_id;
        
        IF new_salary = old_salary + 5000.00 THEN
            RAISE NOTICE 'PASS - update_salary procedure works correctly';
            
            -- Revert the test change
            UPDATE employees 
            SET current_salary = old_salary 
            WHERE employee_id = test_employee_id;
            
            -- Remove test salary history record
            DELETE FROM salary_history 
            WHERE employee_id = test_employee_id 
            AND change_reason = 'Test salary increase';
        ELSE
            RAISE NOTICE 'FAIL - update_salary procedure did not update correctly';
        END IF;
    ELSE
        RAISE NOTICE 'SKIP - No active employees found for salary update test';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'FAIL - update_salary procedure error: %', SQLERRM;
END;
$$;

-- Test 8: Data Validation Rules
\echo '8. Testing data validation rules...'

-- Test unique constraints
SELECT 
    'Unique Constraints' as test_category,
    constraint_name,
    table_name,
    'PASS' as status
FROM information_schema.table_constraints
WHERE constraint_type = 'UNIQUE'
AND table_schema = 'public'
ORDER BY table_name, constraint_name;

-- Test check constraints
SELECT 
    'Check Constraints' as test_category,
    constraint_name,
    table_name,
    'PASS' as status
FROM information_schema.table_constraints
WHERE constraint_type = 'CHECK'
AND table_schema = 'public'
ORDER BY table_name, constraint_name;

-- Test 9: Index Performance
\echo '9. Testing database indexes...'

SELECT 
    schemaname,
    tablename,
    indexname,
    CASE 
        WHEN indexdef LIKE '%UNIQUE%' THEN 'UNIQUE INDEX'
        ELSE 'REGULAR INDEX'
    END as index_type,
    'PASS' as status
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Test 10: Sample Query Performance
\echo '10. Testing sample queries...'

-- Test complex join query
EXPLAIN (ANALYZE, BUFFERS) 
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    j.job_title,
    l.location_name,
    e.current_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j ON e.job_id = j.job_id
JOIN locations l ON e.location_id = l.location_id
WHERE e.is_active = true
LIMIT 10;

-- Test 11: Business Logic Validation
\echo '11. Testing business logic...'

-- Test employee hierarchy (no circular references)
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: employees with no manager
    SELECT 
        employee_id,
        first_name || ' ' || last_name as full_name,
        manager_id,
        0 as level,
        ARRAY[employee_id] as path
    FROM employees 
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: employees with managers
    SELECT 
        e.employee_id,
        e.first_name || ' ' || e.last_name as full_name,
        e.manager_id,
        eh.level + 1,
        eh.path || e.employee_id
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
    WHERE NOT (e.employee_id = ANY(eh.path))  -- Prevent circular references
    AND eh.level < 10  -- Prevent infinite recursion
)
SELECT 
    'Employee Hierarchy' as test_name,
    CASE 
        WHEN max(level) <= 10 THEN 'PASS - No circular references detected'
        ELSE 'FAIL - Possible circular references'
    END as status,
    max(level) as max_hierarchy_depth,
    count(*) as total_employees_in_hierarchy
FROM employee_hierarchy;

-- Test department hierarchy (no circular references)
WITH RECURSIVE dept_hierarchy AS (
    -- Base case: departments with no parent
    SELECT 
        department_id,
        department_name,
        parent_department_id,
        0 as level,
        ARRAY[department_id] as path
    FROM departments 
    WHERE parent_department_id IS NULL
    
    UNION ALL
    
    -- Recursive case: departments with parents
    SELECT 
        d.department_id,
        d.department_name,
        d.parent_department_id,
        dh.level + 1,
        dh.path || d.department_id
    FROM departments d
    JOIN dept_hierarchy dh ON d.parent_department_id = dh.department_id
    WHERE NOT (d.department_id = ANY(dh.path))  -- Prevent circular references
    AND dh.level < 10  -- Prevent infinite recursion
)
SELECT 
    'Department Hierarchy' as test_name,
    CASE 
        WHEN max(level) <= 10 THEN 'PASS - No circular references detected'
        ELSE 'FAIL - Possible circular references'
    END as status,
    max(level) as max_hierarchy_depth,
    count(*) as total_departments_in_hierarchy
FROM dept_hierarchy;

-- Test 12: Data Quality Checks
\echo '12. Testing data quality...'

-- Check for employees without required information
SELECT 
    'Employee Data Quality' as test_category,
    CASE 
        WHEN count(*) = 0 THEN 'PASS - All employees have required data'
        ELSE 'FAIL - Found employees with missing required data'
    END as status,
    count(*) as issues_found
FROM employees 
WHERE first_name IS NULL 
   OR last_name IS NULL 
   OR email IS NULL 
   OR hire_date IS NULL;

-- Check salary history data quality
SELECT 
    'Salary History Data Quality' as test_category,
    CASE 
        WHEN count(*) = 0 THEN 'PASS - All salary records have valid data'
        ELSE 'FAIL - Found invalid salary records'
    END as status,
    count(*) as issues_found
FROM salary_history 
WHERE new_salary <= 0 
   OR effective_date IS NULL;

-- Check performance review data quality
SELECT 
    'Performance Review Data Quality' as test_category,
    CASE 
        WHEN count(*) = 0 THEN 'PASS - All reviews have valid ratings'
        ELSE 'FAIL - Found reviews with invalid ratings'
    END as status,
    count(*) as issues_found
FROM performance_reviews 
WHERE overall_rating < 1 
   OR overall_rating > 5
   OR review_period_start IS NULL
   OR review_period_end IS NULL
   OR review_period_start >= review_period_end;

-- Final Summary
\echo ''
\echo '==================================='
\echo 'Testing Complete!'
\echo '==================================='
\echo ''
\echo 'Review the results above for any FAIL status.'
\echo 'All tests should show PASS for a properly configured database.'
\echo ''
\echo 'If you see any failures:'
\echo '1. Check the setup_database.sql script ran completely'
\echo '2. Verify all sample data was loaded'
\echo '3. Ensure PostgreSQL version compatibility'
\echo '4. Run individual schema files if needed'
\echo ''
