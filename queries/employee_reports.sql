-- Enhanced employee reports with comprehensive analytics

-- 1. Employee Overview Statistics
SELECT 
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN hire_date >= CURRENT_DATE - INTERVAL '1 year' THEN 1 END) AS new_hires_last_year,
    COUNT(CASE WHEN employment_status = 'Active' THEN 1 END) AS active_employees,
    COUNT(CASE WHEN employment_status = 'Terminated' THEN 1 END) AS total_terminations,
    COUNT(CASE WHEN termination_date IS NOT NULL AND termination_date >= CURRENT_DATE - INTERVAL '1 year' THEN 1 END) AS recent_terminations,
    COUNT(CASE WHEN employment_type = 'Full-time' THEN 1 END) AS fulltime_employees,
    COUNT(CASE WHEN employment_type = 'Part-time' THEN 1 END) AS parttime_employees,
    COUNT(CASE WHEN employment_type = 'Contract' THEN 1 END) AS contract_employees,
    COUNT(CASE WHEN employment_type = 'Temporary' THEN 1 END) AS temporary_employees,
    ROUND(AVG(current_salary), 2) AS average_salary,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date))), 2) AS average_tenure_years
FROM 
    employees;

-- 2. Department-wise Employee Distribution
SELECT 
    d.department_name,
    d.department_code,
    COUNT(e.employee_id) AS employee_count,
    COUNT(CASE WHEN e.employment_status = 'Active' THEN 1 END) AS active_count,
    ROUND(AVG(e.current_salary), 2) AS average_salary,
    ROUND(MIN(e.current_salary), 2) AS min_salary,
    ROUND(MAX(e.current_salary), 2) AS max_salary,
    ROUND(SUM(e.current_salary), 2) AS total_salary_cost
FROM 
    departments d
LEFT JOIN 
    employees e ON d.department_id = e.department_id AND e.is_active = true
WHERE 
    d.is_active = true
GROUP BY 
    d.department_id, d.department_name, d.department_code
ORDER BY 
    employee_count DESC;

-- 3. Job Title Analysis
SELECT 
    j.job_title,
    j.job_category,
    j.experience_level,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.current_salary), 2) AS average_salary,
    j.min_salary AS job_min_salary,
    j.max_salary AS job_max_salary,
    ROUND(AVG(e.current_salary) - j.min_salary, 2) AS avg_above_min,
    ROUND(j.max_salary - AVG(e.current_salary), 2) AS avg_below_max
FROM 
    jobs j
LEFT JOIN 
    employees e ON j.job_id = e.job_id AND e.is_active = true
WHERE 
    j.is_active = true
GROUP BY 
    j.job_id, j.job_title, j.job_category, j.experience_level, j.min_salary, j.max_salary
ORDER BY 
    employee_count DESC;

-- 4. Hiring Trends by Year
SELECT 
    EXTRACT(YEAR FROM hire_date) AS hire_year,
    COUNT(*) AS total_hires,
    COUNT(CASE WHEN employment_status = 'Active' THEN 1 END) AS still_active,
    COUNT(CASE WHEN employment_status = 'Terminated' THEN 1 END) AS terminated,
    ROUND(AVG(current_salary), 2) AS average_starting_salary
FROM 
    employees
GROUP BY 
    EXTRACT(YEAR FROM hire_date)
ORDER BY 
    hire_year DESC;

-- 5. Location-wise Employee Distribution
SELECT 
    l.location_name,
    l.city,
    l.country,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.current_salary), 2) AS average_salary
FROM 
    locations l
LEFT JOIN 
    employees e ON l.location_id = e.location_id AND e.is_active = true
WHERE 
    l.is_active = true
GROUP BY 
    l.location_id, l.location_name, l.city, l.country
ORDER BY 
    employee_count DESC;

-- 6. Gender Distribution Analysis
SELECT 
    COALESCE(gender, 'Not Specified') AS gender,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees WHERE is_active = true), 2) AS percentage,
    ROUND(AVG(current_salary), 2) AS average_salary
FROM 
    employees
WHERE 
    is_active = true
GROUP BY 
    gender
ORDER BY 
    employee_count DESC;

-- 7. Age Distribution Analysis
SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) < 25 THEN 'Under 25'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 25 AND 34 THEN '25-34'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 35 AND 44 THEN '35-44'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 45 AND 54 THEN '45-54'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) >= 55 THEN '55+'
        ELSE 'Unknown'
    END AS age_group,
    COUNT(*) AS employee_count,
    ROUND(AVG(current_salary), 2) AS average_salary,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date))), 2) AS average_tenure
FROM 
    employees
WHERE 
    is_active = true
GROUP BY 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) < 25 THEN 'Under 25'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 25 AND 34 THEN '25-34'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 35 AND 44 THEN '35-44'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 45 AND 54 THEN '45-54'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) >= 55 THEN '55+'
        ELSE 'Unknown'
    END
ORDER BY 
    MIN(COALESCE(EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)), 999));

-- 8. Employees with Longest Tenure
SELECT 
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.hire_date,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) AS years_of_service,
    j.job_title,
    d.department_name,
    e.current_salary
FROM 
    employees e
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    e.is_active = true
ORDER BY 
    e.hire_date ASC
LIMIT 10;