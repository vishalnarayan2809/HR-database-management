-- Enhanced salary analysis with comprehensive compensation insights

-- 1. Current Salary Analysis by Job Title
SELECT 
    j.job_title,
    j.job_category,
    j.experience_level,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.current_salary), 2) AS average_salary,
    ROUND(MIN(e.current_salary), 2) AS minimum_salary,
    ROUND(MAX(e.current_salary), 2) AS maximum_salary,
    ROUND(STDDEV(e.current_salary), 2) AS salary_std_deviation,
    j.min_salary AS job_min_range,
    j.max_salary AS job_max_range,
    ROUND(AVG(e.current_salary) - j.min_salary, 2) AS avg_above_min_range,
    ROUND(j.max_salary - AVG(e.current_salary), 2) AS avg_below_max_range
FROM 
    employees e
JOIN 
    jobs j ON e.job_id = j.job_id
WHERE 
    e.is_active = true AND e.employment_status = 'Active'
GROUP BY 
    j.job_id, j.job_title, j.job_category, j.experience_level, j.min_salary, j.max_salary
ORDER BY 
    average_salary DESC;

-- 2. Salary Analysis by Department
SELECT 
    d.department_name,
    d.department_code,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.current_salary), 2) AS average_salary,
    ROUND(MIN(e.current_salary), 2) AS minimum_salary,
    ROUND(MAX(e.current_salary), 2) AS maximum_salary,
    ROUND(SUM(e.current_salary), 2) AS total_salary_cost,
    d.budget,
    CASE 
        WHEN d.budget > 0 THEN ROUND((SUM(e.current_salary) / d.budget * 100), 2)
        ELSE 0 
    END AS salary_budget_utilization_percent
FROM 
    employees e
JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    e.is_active = true AND e.employment_status = 'Active'
GROUP BY 
    d.department_id, d.department_name, d.department_code, d.budget
ORDER BY 
    total_salary_cost DESC;

-- 3. Salary Analysis by Location
SELECT 
    l.location_name,
    l.city,
    l.country,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.current_salary), 2) AS average_salary,
    ROUND(MIN(e.current_salary), 2) AS minimum_salary,
    ROUND(MAX(e.current_salary), 2) AS maximum_salary,
    ROUND(SUM(e.current_salary), 2) AS total_salary_cost
FROM 
    employees e
JOIN 
    locations l ON e.location_id = l.location_id
WHERE 
    e.is_active = true AND e.employment_status = 'Active'
GROUP BY 
    l.location_id, l.location_name, l.city, l.country
ORDER BY 
    average_salary DESC;

-- 4. Salary Growth Analysis (Historical)
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    j.job_title,
    d.department_name,
    COUNT(sh.salary_history_id) AS total_salary_changes,
    MIN(sh.new_salary) AS lowest_salary,
    MAX(sh.new_salary) AS highest_salary,
    ROUND(MAX(sh.new_salary) - MIN(sh.new_salary), 2) AS total_salary_growth,
    ROUND(AVG(sh.salary_change_percentage), 2) AS avg_increase_percentage,
    MIN(sh.effective_date) AS first_salary_date,
    MAX(sh.effective_date) AS latest_salary_date
FROM 
    employees e
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
JOIN 
    salary_history sh ON e.employee_id = sh.employee_id
WHERE 
    e.is_active = true
GROUP BY 
    e.employee_id, e.first_name, e.last_name, j.job_title, d.department_name
HAVING 
    COUNT(sh.salary_history_id) > 1
ORDER BY 
    total_salary_growth DESC;

-- 5. Salary Bands Distribution
SELECT 
    salary_band,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees WHERE is_active = true), 2) AS percentage,
    ROUND(AVG(current_salary), 2) AS average_salary_in_band,
    ROUND(MIN(current_salary), 2) AS min_salary_in_band,
    ROUND(MAX(current_salary), 2) AS max_salary_in_band
FROM 
    salary_bands
GROUP BY 
    salary_band
ORDER BY 
    MIN(current_salary);

-- 6. Gender Pay Gap Analysis
SELECT 
    j.job_title,
    j.job_category,
    COUNT(CASE WHEN e.gender = 'Male' THEN 1 END) AS male_count,
    COUNT(CASE WHEN e.gender = 'Female' THEN 1 END) AS female_count,
    ROUND(AVG(CASE WHEN e.gender = 'Male' THEN e.current_salary END), 2) AS male_avg_salary,
    ROUND(AVG(CASE WHEN e.gender = 'Female' THEN e.current_salary END), 2) AS female_avg_salary,
    ROUND(
        AVG(CASE WHEN e.gender = 'Male' THEN e.current_salary END) - 
        AVG(CASE WHEN e.gender = 'Female' THEN e.current_salary END), 2
    ) AS pay_gap_amount,
    ROUND(
        (1 - (AVG(CASE WHEN e.gender = 'Female' THEN e.current_salary END) / 
              AVG(CASE WHEN e.gender = 'Male' THEN e.current_salary END))) * 100, 2
    ) AS pay_gap_percentage
FROM 
    employees e
JOIN 
    jobs j ON e.job_id = j.job_id
WHERE 
    e.is_active = true 
    AND e.employment_status = 'Active' 
    AND e.gender IN ('Male', 'Female')
GROUP BY 
    j.job_id, j.job_title, j.job_category
HAVING 
    COUNT(CASE WHEN e.gender = 'Male' THEN 1 END) > 0 
    AND COUNT(CASE WHEN e.gender = 'Female' THEN 1 END) > 0
ORDER BY 
    ABS(pay_gap_percentage) DESC;

-- 7. Salary vs Tenure Analysis
SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) < 1 THEN '< 1 year'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) BETWEEN 1 AND 2 THEN '1-2 years'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) BETWEEN 3 AND 5 THEN '3-5 years'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) BETWEEN 6 AND 10 THEN '6-10 years'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) > 10 THEN '10+ years'
    END AS tenure_group,
    COUNT(*) AS employee_count,
    ROUND(AVG(e.current_salary), 2) AS average_salary,
    ROUND(MIN(e.current_salary), 2) AS min_salary,
    ROUND(MAX(e.current_salary), 2) AS max_salary
FROM 
    employees e
WHERE 
    e.is_active = true AND e.employment_status = 'Active'
GROUP BY 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) < 1 THEN '< 1 year'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) BETWEEN 1 AND 2 THEN '1-2 years'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) BETWEEN 3 AND 5 THEN '3-5 years'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) BETWEEN 6 AND 10 THEN '6-10 years'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) > 10 THEN '10+ years'
    END
ORDER BY 
    MIN(EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)));

-- 8. Top Salary Earners
SELECT 
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    j.job_title,
    d.department_name,
    l.location_name,
    e.current_salary,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) AS years_of_service
FROM 
    employees e
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
JOIN 
    locations l ON e.location_id = l.location_id
WHERE 
    e.is_active = true AND e.employment_status = 'Active'
ORDER BY 
    e.current_salary DESC
LIMIT 20;