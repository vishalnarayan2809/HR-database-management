-- Comprehensive department summary view with enhanced metrics
CREATE VIEW department_summary AS
SELECT 
    d.department_id,
    d.department_name,
    d.department_code,
    d.budget,
    d.cost_center,
    parent_dept.department_name AS parent_department,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    l.location_name,
    l.city,
    l.country,
    COUNT(e.employee_id) AS total_employees,
    COUNT(CASE WHEN e.employment_status = 'Active' THEN 1 END) AS active_employees,
    COUNT(CASE WHEN e.employment_type = 'Full-time' THEN 1 END) AS fulltime_employees,
    COUNT(CASE WHEN e.employment_type = 'Part-time' THEN 1 END) AS parttime_employees,
    COUNT(CASE WHEN e.employment_type = 'Contract' THEN 1 END) AS contract_employees,
    COUNT(CASE WHEN e.employment_type = 'Temporary' THEN 1 END) AS temporary_employees,
    COALESCE(AVG(e.current_salary), 0) AS average_salary,
    COALESCE(MIN(e.current_salary), 0) AS min_salary,
    COALESCE(MAX(e.current_salary), 0) AS max_salary,
    COALESCE(SUM(e.current_salary), 0) AS total_salary_cost,
    CASE 
        WHEN d.budget > 0 THEN ROUND((COALESCE(SUM(e.current_salary), 0) / d.budget * 100), 2)
        ELSE 0 
    END AS salary_budget_utilization_percent,
    d.is_active AS department_active
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
    d.department_id, d.department_name, d.department_code, d.budget, d.cost_center,
    parent_dept.department_name, mgr.first_name, mgr.last_name, 
    l.location_name, l.city, l.country, d.is_active
ORDER BY 
    d.department_name;