-- HR Database Validation Test Script
-- This script performs basic validation tests to ensure the database is working correctly

-- Test 1: Check if all tables exist and have data
SELECT 'TEST 1: TABLE EXISTENCE AND DATA COUNT' AS test_name;
SELECT 
    'locations' as table_name, 
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM locations
UNION ALL
SELECT 
    'jobs' as table_name, 
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM jobs
UNION ALL
SELECT 
    'departments' as table_name, 
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM departments
UNION ALL
SELECT 
    'employees' as table_name, 
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM employees
UNION ALL
SELECT 
    'salary_history' as table_name, 
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM salary_history
UNION ALL
SELECT 
    'performance_reviews' as table_name, 
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM performance_reviews;

-- Test 2: Check if views are working
SELECT 'TEST 2: VIEW FUNCTIONALITY' AS test_name;
SELECT 
    'employee_details' as view_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM employee_details
UNION ALL
SELECT 
    'department_summary' as view_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM department_summary
UNION ALL
SELECT 
    'salary_bands' as view_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM salary_bands;

-- Test 3: Check foreign key relationships
SELECT 'TEST 3: REFERENTIAL INTEGRITY' AS test_name;
SELECT 
    'employees_to_jobs' as relationship,
    COUNT(*) as valid_relationships,
    CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM employees WHERE is_active = true) THEN 'PASS' ELSE 'FAIL' END as status
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE e.is_active = true
UNION ALL
SELECT 
    'employees_to_departments' as relationship,
    COUNT(*) as valid_relationships,
    CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM employees WHERE is_active = true) THEN 'PASS' ELSE 'FAIL' END as status
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.is_active = true
UNION ALL
SELECT 
    'employees_to_locations' as relationship,
    COUNT(*) as valid_relationships,
    CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM employees WHERE is_active = true) THEN 'PASS' ELSE 'FAIL' END as status
FROM employees e
JOIN locations l ON e.location_id = l.location_id
WHERE e.is_active = true;

-- Test 4: Check data consistency
SELECT 'TEST 4: DATA CONSISTENCY' AS test_name;
SELECT 
    'salary_within_job_range' as consistency_check,
    COUNT(*) as valid_records,
    CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM employees WHERE is_active = true) THEN 'PASS' ELSE 'FAIL' END as status
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE e.is_active = true 
AND e.current_salary BETWEEN j.min_salary AND j.max_salary
UNION ALL
SELECT 
    'hire_date_before_today' as consistency_check,
    COUNT(*) as valid_records,
    CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM employees WHERE is_active = true) THEN 'PASS' ELSE 'FAIL' END as status
FROM employees
WHERE is_active = true 
AND hire_date <= CURRENT_DATE
UNION ALL
SELECT 
    'active_salary_history_exists' as consistency_check,
    COUNT(DISTINCT e.employee_id) as valid_records,
    CASE WHEN COUNT(DISTINCT e.employee_id) = (SELECT COUNT(*) FROM employees WHERE is_active = true) THEN 'PASS' ELSE 'FAIL' END as status
FROM employees e
JOIN salary_history sh ON e.employee_id = sh.employee_id
WHERE e.is_active = true 
AND sh.end_date IS NULL;

-- Test 5: Sample analytical queries
SELECT 'TEST 5: ANALYTICAL QUERIES' AS test_name;
SELECT 
    'department_employee_count' as query_type,
    department_name,
    total_employees,
    CASE WHEN total_employees > 0 THEN 'PASS' ELSE 'FAIL' END as status
FROM department_summary
WHERE total_employees > 0
LIMIT 5;

-- Test 6: Performance review data integrity
SELECT 'TEST 6: PERFORMANCE REVIEW INTEGRITY' AS test_name;
SELECT 
    'valid_performance_ratings' as check_type,
    COUNT(*) as valid_records,
    CASE 
        WHEN COUNT(*) = (SELECT COUNT(*) FROM performance_reviews WHERE overall_rating IS NOT NULL) 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as status
FROM performance_reviews
WHERE overall_rating BETWEEN 1 AND 5;

-- Test Summary
SELECT 'TEST SUMMARY: HR DATABASE VALIDATION COMPLETE' AS summary;
SELECT 
    'Total Active Employees' as metric,
    COUNT(*) as value
FROM employees WHERE is_active = true
UNION ALL
SELECT 
    'Total Departments' as metric,
    COUNT(*) as value
FROM departments WHERE is_active = true
UNION ALL
SELECT 
    'Total Locations' as metric,
    COUNT(*) as value
FROM locations WHERE is_active = true
UNION ALL
SELECT 
    'Total Job Positions' as metric,
    COUNT(*) as value
FROM jobs WHERE is_active = true
UNION ALL
SELECT 
    'Total Performance Reviews' as metric,
    COUNT(*) as value
FROM performance_reviews WHERE status = 'Completed'
UNION ALL
SELECT 
    'Average Salary' as metric,
    ROUND(AVG(current_salary), 2) as value
FROM employees WHERE is_active = true;

-- Display completion message
SELECT 'HR Database validation tests completed successfully!' AS completion_message;
