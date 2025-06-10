-- Enhanced Performance Queries for Comprehensive Employee Assessment

-- 1. Latest Performance Review Summary for All Active Employees
SELECT 
    e.employee_id,
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    j.job_title,
    d.department_name,
    pr.review_period_start,
    pr.review_period_end,
    pr.review_type,
    pr.overall_rating,
    pr.goals_achievement_rating,
    pr.technical_skills_rating,
    pr.communication_rating,
    pr.leadership_rating,
    pr.status,
    pr.review_date,
    reviewer.first_name || ' ' || reviewer.last_name AS reviewer_name
FROM 
    employees e
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
LEFT JOIN 
    performance_reviews pr ON e.employee_id = pr.employee_id 
    AND pr.review_id = (
        SELECT review_id 
        FROM performance_reviews pr2 
        WHERE pr2.employee_id = e.employee_id 
        ORDER BY pr2.review_date DESC 
        LIMIT 1
    )
LEFT JOIN 
    employees reviewer ON pr.reviewer_id = reviewer.employee_id
WHERE 
    e.is_active = true AND e.employment_status = 'Active'
ORDER BY 
    d.department_name, e.last_name, e.first_name;

-- 2. Average Performance Ratings by Department
SELECT 
    d.department_name,
    d.department_code,
    COUNT(DISTINCT pr.employee_id) AS employees_reviewed,
    ROUND(AVG(pr.overall_rating), 2) AS avg_overall_rating,
    ROUND(AVG(pr.goals_achievement_rating), 2) AS avg_goals_rating,
    ROUND(AVG(pr.technical_skills_rating), 2) AS avg_technical_rating,
    ROUND(AVG(pr.communication_rating), 2) AS avg_communication_rating,
    ROUND(AVG(pr.leadership_rating), 2) AS avg_leadership_rating,
    COUNT(CASE WHEN pr.overall_rating >= 4 THEN 1 END) AS high_performers,
    COUNT(CASE WHEN pr.overall_rating <= 2 THEN 1 END) AS low_performers
FROM 
    performance_reviews pr
JOIN 
    employees e ON pr.employee_id = e.employee_id
JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    pr.status = 'Completed' 
    AND pr.review_date >= CURRENT_DATE - INTERVAL '2 years'
    AND e.is_active = true
GROUP BY 
    d.department_id, d.department_name, d.department_code
ORDER BY 
    avg_overall_rating DESC;

-- 3. Performance Ratings by Job Title
SELECT 
    j.job_title,
    j.job_category,
    j.experience_level,
    COUNT(DISTINCT pr.employee_id) AS employees_reviewed,
    ROUND(AVG(pr.overall_rating), 2) AS avg_overall_rating,
    ROUND(AVG(pr.technical_skills_rating), 2) AS avg_technical_rating,
    COUNT(CASE WHEN pr.overall_rating = 5 THEN 1 END) AS exceptional_performers,
    COUNT(CASE WHEN pr.overall_rating >= 4 THEN 1 END) AS strong_performers,
    COUNT(CASE WHEN pr.overall_rating = 3 THEN 1 END) AS meeting_expectations,
    COUNT(CASE WHEN pr.overall_rating <= 2 THEN 1 END) AS below_expectations
FROM 
    performance_reviews pr
JOIN 
    employees e ON pr.employee_id = e.employee_id
JOIN 
    jobs j ON e.job_id = j.job_id
WHERE 
    pr.status = 'Completed' 
    AND pr.review_date >= CURRENT_DATE - INTERVAL '2 years'
    AND e.is_active = true
GROUP BY 
    j.job_id, j.job_title, j.job_category, j.experience_level
ORDER BY 
    avg_overall_rating DESC;

-- 4. High Performers (Overall Rating 4 or 5)
SELECT 
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    j.job_title,
    d.department_name,
    pr.overall_rating,
    pr.goals_achievement_rating,
    pr.technical_skills_rating,
    pr.communication_rating,
    pr.leadership_rating,
    pr.review_date,
    pr.strengths,
    e.current_salary,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) AS years_of_service
FROM 
    performance_reviews pr
JOIN 
    employees e ON pr.employee_id = e.employee_id
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    pr.overall_rating >= 4
    AND pr.status = 'Completed'
    AND pr.review_date >= CURRENT_DATE - INTERVAL '1 year'
    AND e.is_active = true
ORDER BY 
    pr.overall_rating DESC, pr.review_date DESC;

-- 5. Employees Needing Performance Improvement (Overall Rating Below 3)
SELECT 
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    j.job_title,
    d.department_name,
    pr.overall_rating,
    pr.areas_for_improvement,
    pr.development_plan,
    pr.review_date,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    e.hire_date,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) AS years_of_service
FROM 
    performance_reviews pr
JOIN 
    employees e ON pr.employee_id = e.employee_id
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
LEFT JOIN 
    employees mgr ON e.manager_id = mgr.employee_id
WHERE 
    pr.overall_rating < 3
    AND pr.status = 'Completed'
    AND pr.review_date >= CURRENT_DATE - INTERVAL '1 year'
    AND e.is_active = true
ORDER BY 
    pr.overall_rating ASC, pr.review_date DESC;

-- 6. Performance Review Completion Status
SELECT 
    EXTRACT(YEAR FROM pr.review_period_end) AS review_year,
    pr.review_type,
    COUNT(*) AS total_reviews,
    COUNT(CASE WHEN pr.status = 'Completed' THEN 1 END) AS completed_reviews,
    COUNT(CASE WHEN pr.status = 'In Progress' THEN 1 END) AS in_progress_reviews,
    COUNT(CASE WHEN pr.status = 'Draft' THEN 1 END) AS draft_reviews,
    ROUND(
        COUNT(CASE WHEN pr.status = 'Completed' THEN 1 END) * 100.0 / COUNT(*), 2
    ) AS completion_percentage
FROM 
    performance_reviews pr
GROUP BY 
    EXTRACT(YEAR FROM pr.review_period_end), pr.review_type
ORDER BY 
    review_year DESC, pr.review_type;

-- 7. Performance Trends by Employee (Multiple Reviews)
SELECT 
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    j.job_title,
    d.department_name,
    COUNT(pr.review_id) AS total_reviews,
    ROUND(AVG(pr.overall_rating), 2) AS avg_overall_rating,
    MIN(pr.overall_rating) AS lowest_rating,
    MAX(pr.overall_rating) AS highest_rating,
    (MAX(pr.overall_rating) - MIN(pr.overall_rating)) AS rating_improvement,
    MIN(pr.review_date) AS first_review_date,
    MAX(pr.review_date) AS latest_review_date
FROM 
    performance_reviews pr
JOIN 
    employees e ON pr.employee_id = e.employee_id
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    pr.status = 'Completed'
    AND e.is_active = true
GROUP BY 
    e.employee_id, e.employee_number, e.first_name, e.last_name, 
    j.job_title, d.department_name
HAVING 
    COUNT(pr.review_id) > 1
ORDER BY 
    rating_improvement DESC, avg_overall_rating DESC;

-- 8. Leadership Potential Analysis
SELECT 
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    j.job_title,
    d.department_name,
    pr.leadership_rating,
    pr.communication_rating,
    pr.overall_rating,
    (pr.leadership_rating + pr.communication_rating) / 2.0 AS leadership_potential_score,
    pr.strengths,
    pr.goals_for_next_period,
    e.current_salary,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.hire_date)) AS years_of_service
FROM 
    performance_reviews pr
JOIN 
    employees e ON pr.employee_id = e.employee_id
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    pr.leadership_rating >= 4
    AND pr.communication_rating >= 4
    AND pr.overall_rating >= 4
    AND pr.status = 'Completed'
    AND pr.review_date >= CURRENT_DATE - INTERVAL '1 year'
    AND e.is_active = true
ORDER BY 
    leadership_potential_score DESC, pr.overall_rating DESC;

-- 9. Review Distribution by Rating
SELECT 
    pr.overall_rating,
    COUNT(*) AS review_count,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(*) 
        FROM performance_reviews 
        WHERE status = 'Completed' 
        AND review_date >= CURRENT_DATE - INTERVAL '1 year'
    ), 2) AS percentage
FROM 
    performance_reviews pr
WHERE 
    pr.status = 'Completed'
    AND pr.review_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY 
    pr.overall_rating
ORDER BY 
    pr.overall_rating DESC;

-- 10. Overdue Performance Reviews
SELECT 
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    j.job_title,
    d.department_name,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    e.hire_date,
    COALESCE(MAX(pr.review_date), e.hire_date) AS last_review_date,
    CURRENT_DATE - COALESCE(MAX(pr.review_date), e.hire_date) AS days_since_last_review
FROM 
    employees e
JOIN 
    jobs j ON e.job_id = j.job_id
JOIN 
    departments d ON e.department_id = d.department_id
LEFT JOIN 
    employees mgr ON e.manager_id = mgr.employee_id
LEFT JOIN 
    performance_reviews pr ON e.employee_id = pr.employee_id AND pr.status = 'Completed'
WHERE 
    e.is_active = true 
    AND e.employment_status = 'Active'
GROUP BY 
    e.employee_id, e.employee_number, e.first_name, e.last_name,
    j.job_title, d.department_name, mgr.first_name, mgr.last_name, e.hire_date
HAVING 
    CURRENT_DATE - COALESCE(MAX(pr.review_date), e.hire_date) > 365
ORDER BY 
    days_since_last_review DESC;