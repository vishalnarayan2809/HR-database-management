-- Comprehensive employee details view with enhanced information
CREATE VIEW employee_details AS
SELECT 
    e.employee_id,
    e.employee_number,
    e.first_name,
    e.last_name,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.email,
    e.phone_number,
    e.hire_date,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) AS years_of_service,
    j.job_title,
    j.job_category,
    j.experience_level,
    d.department_name,
    d.department_code,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    l.location_name,
    l.city,
    l.state_province,
    l.country,
    e.current_salary,
    e.employment_status,
    e.employment_type,
    e.date_of_birth,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_of_birth)) AS age,
    e.gender,
    e.emergency_contact_name,
    e.emergency_contact_phone,
    e.is_active,
    e.created_date,
    e.modified_date
FROM 
    employees e
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
JOIN 
    locations l ON e.location_id = l.location_id
LEFT JOIN 
    employees mgr ON e.manager_id = mgr.employee_id
WHERE 
    e.is_active = true
ORDER BY 
    d.department_name, e.last_name, e.first_name;