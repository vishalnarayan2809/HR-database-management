-- Enhanced salary update procedure with comprehensive tracking and validation
CREATE OR REPLACE FUNCTION update_salary(
    p_employee_id INTEGER,
    p_new_salary DECIMAL(10,2),
    p_change_reason VARCHAR(100),
    p_approved_by INTEGER,
    p_effective_date DATE DEFAULT CURRENT_DATE,
    p_notes TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    current_salary DECIMAL(10,2);
    job_min_salary DECIMAL(10,2);
    job_max_salary DECIMAL(10,2);
    salary_change_amount DECIMAL(10,2);
    salary_change_percentage DECIMAL(5,2);
    employee_job_id INTEGER;
BEGIN
    -- Get current salary and job information
    SELECT e.current_salary, e.job_id, j.min_salary, j.max_salary
    INTO current_salary, employee_job_id, job_min_salary, job_max_salary
    FROM employees e
    JOIN jobs j ON e.job_id = j.job_id
    WHERE e.employee_id = p_employee_id AND e.is_active = true;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee with ID % not found or is inactive', p_employee_id;
    END IF;
    
    -- Validate new salary is within job range
    IF p_new_salary < job_min_salary OR p_new_salary > job_max_salary THEN
        RAISE EXCEPTION 'New salary % is not within job range (% - %)', 
            p_new_salary, job_min_salary, job_max_salary;
    END IF;
    
    -- Calculate salary change
    salary_change_amount := p_new_salary - current_salary;
    IF current_salary > 0 THEN
        salary_change_percentage := ROUND(((salary_change_amount / current_salary) * 100), 2);
    ELSE
        salary_change_percentage := 0;
    END IF;
    
    -- End the current salary record
    UPDATE salary_history 
    SET end_date = p_effective_date - INTERVAL '1 day'
    WHERE employee_id = p_employee_id AND end_date IS NULL;
    
    -- Create new salary history record
    INSERT INTO salary_history (
        employee_id, old_salary, new_salary, salary_change_amount,
        salary_change_percentage, change_reason, effective_date,
        approved_by, notes, created_date
    ) VALUES (
        p_employee_id, current_salary, p_new_salary, salary_change_amount,
        salary_change_percentage, p_change_reason, p_effective_date,
        p_approved_by, p_notes, CURRENT_TIMESTAMP
    );
    
    -- Update current salary in employees table
    UPDATE employees 
    SET current_salary = p_new_salary,
        modified_date = CURRENT_TIMESTAMP
    WHERE employee_id = p_employee_id;
    
    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error updating salary: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;