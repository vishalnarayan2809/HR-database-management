-- Enhanced Department Analytics for Comprehensive Organizational Insights

-- 1. Department Overview with Financial Metrics
SELECT 
    d.department_id,
    d.department_name,
    d.department_code,
    d.cost_center,
    parent_dept.department_name AS parent_department,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    l.location_name,
    l.city,
    l.country,
    COUNT(e.employee_id) AS total_employees,
    COUNT(CASE WHEN e.employment_status = 'Active' THEN 1 END) AS active_employees,
    ROUND(AVG(e.current_salary), 2) AS average_salary,
    ROUND(SUM(e.current_salary), 2) AS total_salary_cost,
    ROUND(MAX(e.current_salary), 2) AS highest_salary,
    ROUND(MIN(e.current_salary), 2) AS lowest_salary,
    d.budget,
    CASE 
        WHEN d.budget > 0 THEN ROUND((SUM(e.current_salary) / d.budget * 100), 2)
        ELSE 0 
    END AS salary_budget_utilization_percent,
    CASE 
        WHEN d.budget > 0 THEN ROUND(d.budget - SUM(e.current_salary), 2)
        ELSE 0 
    END AS remaining_budget
FROM 
    departments d
LEFT JOIN 
    departments parent_dept ON d.parent_department_id = parent_dept.department_id
LEFT JOIN 
    employees mgr ON d.manager_id = mgr.employee_id
LEFT JOIN 
    locations l ON d.location_id = l.location_id
LEFT JOIN 
    employees e ON d.department_id = e.department_id AND e.is_active = true
WHERE 
    d.is_active = true
GROUP BY 
    d.department_id, d.department_name, d.department_code, d.cost_center,
    parent_dept.department_name, mgr.first_name, mgr.last_name,
    l.location_name, l.city, l.country, d.budget
ORDER BY 
    total_employees DESC;

-- 2. Department Hierarchy Analysis
WITH RECURSIVE dept_hierarchy AS (
    -- Base case: top-level departments
    SELECT 
        department_id,
        department_name,
        department_code,
        parent_department_id,
        0 as level,
        CAST(department_name AS TEXT) as hierarchy_path
    FROM 
        departments 
    WHERE 
        parent_department_id IS NULL AND is_active = true
    
    UNION ALL
    
    -- Recursive case: child departments
    SELECT 
        d.department_id,
        d.department_name,
        d.department_code,
        d.parent_department_id,
        dh.level + 1,
        CAST(dh.hierarchy_path || ' > ' || d.department_name AS TEXT)
    FROM 
        departments d
    JOIN 
        dept_hierarchy dh ON d.parent_department_id = dh.department_id
    WHERE 
        d.is_active = true
)
SELECT 
    REPEAT('  ', level) || department_name AS department_hierarchy,
    department_code,
    level,
    hierarchy_path,
    (SELECT COUNT(*) FROM employees WHERE department_id = dh.department_id AND is_active = true) AS employee_count,
    (SELECT ROUND(AVG(current_salary), 2) FROM employees WHERE department_id = dh.department_id AND is_active = true) AS avg_salary
FROM 
    dept_hierarchy dh
ORDER BY 
    hierarchy_path;

-- 3. Department Performance Metrics
SELECT 
    d.department_name,
    d.department_code,
    COUNT(DISTINCT e.employee_id) AS total_employees,
    COUNT(DISTINCT pr.employee_id) AS employees_reviewed,
    ROUND(
        COUNT(DISTINCT pr.employee_id) * 100.0 / NULLIF(COUNT(DISTINCT e.employee_id), 0), 2
    ) AS review_coverage_percent,
    ROUND(AVG(pr.overall_rating), 2) AS avg_performance_rating,
    COUNT(CASE WHEN pr.overall_rating >= 4 THEN 1 END) AS high_performers,
    COUNT(CASE WHEN pr.overall_rating <= 2 THEN 1 END) AS low_performers,
    ROUND(AVG(e.current_salary), 2) AS avg_salary,
    COUNT(CASE WHEN e.hire_date >= CURRENT_DATE - INTERVAL '1 year' THEN 1 END) AS new_hires_last_year,
    COUNT(CASE WHEN e.termination_date IS NOT NULL AND e.termination_date >= CURRENT_DATE - INTERVAL '1 year' THEN 1 END) AS terminations_last_year
FROM 
    departments d
LEFT JOIN 
    employees e ON d.department_id = e.department_id AND e.is_active = true
LEFT JOIN 
    performance_reviews pr ON e.employee_id = pr.employee_id 
    AND pr.status = 'Completed' 
    AND pr.review_date >= CURRENT_DATE - INTERVAL '1 year'
WHERE 
    d.is_active = true
GROUP BY 
    d.department_id, d.department_name, d.department_code
ORDER BY 
    avg_performance_rating DESC NULLS LAST;

-- 4. Department Workforce Distribution by Employment Type
SELECT 
    d.department_name,
    COUNT(CASE WHEN e.employment_type = 'Full-time' THEN 1 END) AS fulltime_count,
    COUNT(CASE WHEN e.employment_type = 'Part-time' THEN 1 END) AS parttime_count,
    COUNT(CASE WHEN e.employment_type = 'Contract' THEN 1 END) AS contract_count,
    COUNT(CASE WHEN e.employment_type = 'Temporary' THEN 1 END) AS temporary_count,
    ROUND(
        COUNT(CASE WHEN e.employment_type = 'Full-time' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(e.employee_id), 0), 2
    ) AS fulltime_percentage,
    COUNT(e.employee_id) AS total_employees
FROM 
    departments d
LEFT JOIN 
    employees e ON d.department_id = e.department_id AND e.is_active = true
WHERE 
    d.is_active = true
GROUP BY 
    d.department_id, d.department_name
ORDER BY 
    total_employees DESC;

-- 5. Department Age and Tenure Analysis
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS total_employees,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_of_birth))), 1) AS avg_age,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date))), 1) AS avg_tenure_years,
    COUNT(CASE WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_of_birth)) < 30 THEN 1 END) AS under_30,
    COUNT(CASE WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_of_birth)) BETWEEN 30 AND 40 THEN 1 END) AS age_30_40,
    COUNT(CASE WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_of_birth)) BETWEEN 41 AND 50 THEN 1 END) AS age_41_50,
    COUNT(CASE WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_of_birth)) > 50 THEN 1 END) AS over_50,
    COUNT(CASE WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) < 2 THEN 1 END) AS tenure_under_2,
    COUNT(CASE WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) BETWEEN 2 AND 5 THEN 1 END) AS tenure_2_5,
    COUNT(CASE WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) > 5 THEN 1 END) AS tenure_over_5
FROM 
    departments d
LEFT JOIN 
    employees e ON d.department_id = e.department_id 
    AND e.is_active = true 
    AND e.date_of_birth IS NOT NULL
WHERE 
    d.is_active = true
GROUP BY 
    d.department_id, d.department_name
ORDER BY 
    total_employees DESC;

-- 6. Department Gender Distribution
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS total_employees,
    COUNT(CASE WHEN e.gender = 'Male' THEN 1 END) AS male_count,
    COUNT(CASE WHEN e.gender = 'Female' THEN 1 END) AS female_count,
    COUNT(CASE WHEN e.gender NOT IN ('Male', 'Female') OR e.gender IS NULL THEN 1 END) AS other_or_unknown,
    ROUND(
        COUNT(CASE WHEN e.gender = 'Female' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(CASE WHEN e.gender IN ('Male', 'Female') THEN 1 END), 0), 2
    ) AS female_percentage,
    ROUND(AVG(CASE WHEN e.gender = 'Male' THEN e.current_salary END), 2) AS male_avg_salary,
    ROUND(AVG(CASE WHEN e.gender = 'Female' THEN e.current_salary END), 2) AS female_avg_salary
FROM 
    departments d
LEFT JOIN 
    employees e ON d.department_id = e.department_id AND e.is_active = true
WHERE 
    d.is_active = true
GROUP BY 
    d.department_id, d.department_name
ORDER BY 
    total_employees DESC;

-- 7. Department Turnover Analysis
WITH dept_turnover AS (
    SELECT 
        d.department_id,
        d.department_name,
        COUNT(CASE WHEN e.hire_date >= CURRENT_DATE - INTERVAL '1 year' THEN 1 END) AS hires_last_year,
        COUNT(CASE WHEN e.termination_date IS NOT NULL AND e.termination_date >= CURRENT_DATE - INTERVAL '1 year' THEN 1 END) AS terminations_last_year,
        COUNT(CASE WHEN e.is_active = true THEN 1 END) AS current_employees,
        -- Average headcount over the year (simplified calculation)
        (COUNT(CASE WHEN e.is_active = true THEN 1 END) + 
         COUNT(CASE WHEN e.termination_date IS NOT NULL AND e.termination_date >= CURRENT_DATE - INTERVAL '1 year' THEN 1 END)) / 2.0 AS avg_headcount
    FROM 
        departments d
    LEFT JOIN 
        employees e ON d.department_id = e.department_id
    WHERE 
        d.is_active = true
    GROUP BY 
        d.department_id, d.department_name
)
SELECT 
    department_name,
    current_employees,
    hires_last_year,
    terminations_last_year,
    ROUND(
        CASE 
            WHEN avg_headcount > 0 THEN (terminations_last_year / avg_headcount * 100)
            ELSE 0 
        END, 2
    ) AS turnover_rate_percent,
    CASE 
        WHEN terminations_last_year > 0 THEN ROUND(hires_last_year::DECIMAL / terminations_last_year, 2)
        ELSE CASE WHEN hires_last_year > 0 THEN 999.99 ELSE 0 END
    END AS hire_to_termination_ratio
FROM 
    dept_turnover
ORDER BY 
    turnover_rate_percent DESC;

-- 8. Department Cost Efficiency Analysis
SELECT 
    d.department_name,
    d.budget,
    COUNT(e.employee_id) AS employee_count,
    ROUND(SUM(e.current_salary), 2) AS total_salary_cost,
    ROUND(AVG(e.current_salary), 2) AS avg_salary_per_employee,
    CASE 
        WHEN COUNT(e.employee_id) > 0 THEN ROUND(d.budget / COUNT(e.employee_id), 2)
        ELSE 0 
    END AS budget_per_employee,
    CASE 
        WHEN d.budget > 0 THEN ROUND((SUM(e.current_salary) / d.budget * 100), 2)
        ELSE 0 
    END AS salary_budget_utilization,
    CASE 
        WHEN d.budget > 0 THEN ROUND(d.budget - SUM(e.current_salary), 2)
        ELSE 0 
    END AS remaining_budget
FROM 
    departments d
LEFT JOIN 
    employees e ON d.department_id = e.department_id AND e.is_active = true
WHERE 
    d.is_active = true AND d.budget > 0
GROUP BY 
    d.department_id, d.department_name, d.budget
ORDER BY 
    salary_budget_utilization DESC;

-- 9. Cross-Department Comparison
SELECT 
    'All Departments' AS comparison_type,
    COUNT(DISTINCT d.department_id) AS department_count,
    COUNT(e.employee_id) AS total_employees,
    ROUND(AVG(e.current_salary), 2) AS avg_salary,
    ROUND(SUM(e.current_salary), 2) AS total_salary_cost,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date))), 2) AS avg_tenure_years
FROM 
    departments d
LEFT JOIN 
    employees e ON d.department_id = e.department_id AND e.is_active = true
WHERE 
    d.is_active = true

UNION ALL

SELECT 
    'Largest Department' AS comparison_type,
    1 AS department_count,
    COUNT(e.employee_id) AS total_employees,
    ROUND(AVG(e.current_salary), 2) AS avg_salary,
    ROUND(SUM(e.current_salary), 2) AS total_salary_cost,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date))), 2) AS avg_tenure_years
FROM 
    departments d
LEFT JOIN 
    employees e ON d.department_id = e.department_id AND e.is_active = true
WHERE 
    d.is_active = true
    AND d.department_id = (
        SELECT department_id 
        FROM departments d2 
        LEFT JOIN employees e2 ON d2.department_id = e2.department_id AND e2.is_active = true
        WHERE d2.is_active = true
        GROUP BY d2.department_id 
        ORDER BY COUNT(e2.employee_id) DESC 
        LIMIT 1
    )

UNION ALL

SELECT 
    'Highest Paid Department' AS comparison_type,
    1 AS department_count,
    COUNT(e.employee_id) AS total_employees,
    ROUND(AVG(e.current_salary), 2) AS avg_salary,
    ROUND(SUM(e.current_salary), 2) AS total_salary_cost,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date))), 2) AS avg_tenure_years
FROM 
    departments d
LEFT JOIN 
    employees e ON d.department_id = e.department_id AND e.is_active = true
WHERE 
    d.is_active = true
    AND d.department_id = (
        SELECT department_id 
        FROM departments d2 
        LEFT JOIN employees e2 ON d2.department_id = e2.department_id AND e2.is_active = true
        WHERE d2.is_active = true
        GROUP BY d2.department_id 
        HAVING COUNT(e2.employee_id) > 0
        ORDER BY AVG(e2.current_salary) DESC 
        LIMIT 1
    );