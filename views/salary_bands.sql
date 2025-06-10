-- Enhanced salary bands view with comprehensive salary analysis
CREATE VIEW salary_bands AS
SELECT 
    e.employee_id,
    e.employee_number,
    e.first_name,
    e.last_name,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.current_salary,
    j.job_title,
    j.job_category,
    j.experience_level,
    j.min_salary AS job_min_salary,
    j.max_salary AS job_max_salary,
    d.department_name,
    l.location_name,
    l.city,
    l.country,
    CASE 
        WHEN e.current_salary < 40000 THEN 'Entry Level'
        WHEN e.current_salary >= 40000 AND e.current_salary < 60000 THEN 'Junior'
        WHEN e.current_salary >= 60000 AND e.current_salary < 80000 THEN 'Mid Level'
        WHEN e.current_salary >= 80000 AND e.current_salary < 100000 THEN 'Senior'
        WHEN e.current_salary >= 100000 AND e.current_salary < 130000 THEN 'Senior+'
        WHEN e.current_salary >= 130000 THEN 'Executive'
    END AS salary_band,
    CASE 
        WHEN e.current_salary < j.min_salary THEN 'Below Range'
        WHEN e.current_salary > j.max_salary THEN 'Above Range'
        ELSE 'Within Range'
    END AS salary_vs_job_range,
    ROUND(((e.current_salary - j.min_salary) / (j.max_salary - j.min_salary) * 100), 2) AS salary_percentile_in_job_range,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) AS years_of_service,
    ROUND((e.current_salary / EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date))), 2) AS salary_per_year_of_service
FROM 
    employees e
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
JOIN 
    locations l ON e.location_id = l.location_id
WHERE 
    e.is_active = true
    AND e.employment_status = 'Active'
ORDER BY 
    e.current_salary DESC, d.department_name, e.last_name;