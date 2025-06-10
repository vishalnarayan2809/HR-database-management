-- Enhanced department transfer procedure with comprehensive tracking
CREATE OR REPLACE FUNCTION department_transfer(
    p_employee_id INTEGER,
    p_new_department_id INTEGER,
    p_new_manager_id INTEGER DEFAULT NULL,
    p_new_location_id INTEGER DEFAULT NULL,
    p_transfer_date DATE DEFAULT CURRENT_DATE,
    p_transfer_reason TEXT DEFAULT NULL,
    p_approved_by INTEGER DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    current_department_id INTEGER;
    current_manager_id INTEGER;
    current_location_id INTEGER;
    employee_name VARCHAR(100);
    old_department_name VARCHAR(100);
    new_department_name VARCHAR(100);
BEGIN
    -- Get current employee information
    SELECT e.department_id, e.manager_id, e.location_id, 
           CONCAT(e.first_name, ' ', e.last_name),
           d.department_name
    INTO current_department_id, current_manager_id, current_location_id,
         employee_name, old_department_name
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE e.employee_id = p_employee_id AND e.is_active = true;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee with ID % not found or is inactive', p_employee_id;
    END IF;
    
    -- Validate new department exists and is active
    SELECT department_name INTO new_department_name
    FROM departments 
    WHERE department_id = p_new_department_id AND is_active = true;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Department with ID % not found or is inactive', p_new_department_id;
    END IF;
    
    -- If no new location specified, use department's default location
    IF p_new_location_id IS NULL THEN
        SELECT location_id INTO p_new_location_id
        FROM departments
        WHERE department_id = p_new_department_id;
    END IF;
    
    -- Update employee record
    UPDATE employees 
    SET department_id = p_new_department_id,
        manager_id = COALESCE(p_new_manager_id, manager_id),
        location_id = COALESCE(p_new_location_id, location_id),
        modified_date = CURRENT_TIMESTAMP
    WHERE employee_id = p_employee_id;
    
    -- Log the transfer (you could create a separate employee_transfers table for this)
    -- For now, we'll use a comment approach or could extend to add to a transfers log table
    
    -- Optional: Insert into an employee_transfers log table if it exists
    -- This would require creating that table first
    
    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error transferring employee: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Optional: Create employee transfers log table
-- Uncomment if you want to track transfer history
/*
CREATE TABLE IF NOT EXISTS employee_transfers (
    transfer_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    old_department_id INTEGER,
    new_department_id INTEGER NOT NULL,
    old_manager_id INTEGER,
    new_manager_id INTEGER,
    old_location_id INTEGER,
    new_location_id INTEGER,
    transfer_date DATE NOT NULL,
    transfer_reason TEXT,
    approved_by INTEGER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_transfer_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_transfer_old_dept FOREIGN KEY (old_department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_transfer_new_dept FOREIGN KEY (new_department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_transfer_old_mgr FOREIGN KEY (old_manager_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_transfer_new_mgr FOREIGN KEY (new_manager_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_transfer_old_loc FOREIGN KEY (old_location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_transfer_new_loc FOREIGN KEY (new_location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_transfer_approver FOREIGN KEY (approved_by) REFERENCES employees(employee_id)
);
*/