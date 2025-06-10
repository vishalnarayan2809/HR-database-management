-- Enhanced hire employee procedure with comprehensive employee onboarding
CREATE OR REPLACE FUNCTION hire_employee(
    p_employee_number VARCHAR(20),
    p_first_name VARCHAR(50),
    p_last_name VARCHAR(50),
    p_email VARCHAR(100),
    p_phone_number VARCHAR(20),
    p_hire_date DATE,
    p_job_id INTEGER,
    p_department_id INTEGER,
    p_manager_id INTEGER,
    p_location_id INTEGER,
    p_starting_salary DECIMAL(10,2),
    p_employment_type VARCHAR(20) DEFAULT 'Full-time',
    p_date_of_birth DATE DEFAULT NULL,
    p_gender VARCHAR(10) DEFAULT NULL,
    p_emergency_contact_name VARCHAR(100) DEFAULT NULL,
    p_emergency_contact_phone VARCHAR(20) DEFAULT NULL
) RETURNS INTEGER AS $$
DECLARE
    new_employee_id INTEGER;
    job_min_salary DECIMAL(10,2);
    job_max_salary DECIMAL(10,2);
BEGIN
    -- Validate that the salary is within the job range
    SELECT min_salary, max_salary INTO job_min_salary, job_max_salary
    FROM jobs WHERE job_id = p_job_id;
    
    IF p_starting_salary < job_min_salary OR p_starting_salary > job_max_salary THEN
        RAISE EXCEPTION 'Starting salary % is not within job range (% - %)', 
            p_starting_salary, job_min_salary, job_max_salary;
    END IF;
    
    -- Insert new employee
    INSERT INTO employees (
        employee_number, first_name, last_name, email, phone_number,
        hire_date, job_id, department_id, manager_id, location_id,
        current_salary, employment_status, employment_type,
        date_of_birth, gender, emergency_contact_name, emergency_contact_phone,
        is_active, created_date, modified_date
    ) VALUES (
        p_employee_number, p_first_name, p_last_name, p_email, p_phone_number,
        p_hire_date, p_job_id, p_department_id, p_manager_id, p_location_id,
        p_starting_salary, 'Active', p_employment_type,
        p_date_of_birth, p_gender, p_emergency_contact_name, p_emergency_contact_phone,
        true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    ) RETURNING employee_id INTO new_employee_id;
    
    -- Create initial salary history record
    INSERT INTO salary_history (
        employee_id, old_salary, new_salary, salary_change_amount, 
        salary_change_percentage, change_reason, effective_date, 
        approved_by, notes, created_date
    ) VALUES (
        new_employee_id, NULL, p_starting_salary, NULL, 
        NULL, 'Initial Hire', p_hire_date,
        p_manager_id, 'Starting salary for new hire', CURRENT_TIMESTAMP
    );
    
    RETURN new_employee_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error hiring employee: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;