-- Enhanced employees table with comprehensive employee information
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    employee_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    hire_date DATE NOT NULL,
    job_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    manager_id INTEGER,
    location_id INTEGER NOT NULL,
    current_salary DECIMAL(10, 2) NOT NULL,
    employment_status VARCHAR(20) DEFAULT 'Active' CHECK (employment_status IN ('Active', 'Inactive', 'Terminated', 'On Leave')),
    employment_type VARCHAR(20) DEFAULT 'Full-time' CHECK (employment_type IN ('Full-time', 'Part-time', 'Contract', 'Temporary')),
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other', 'Prefer not to say')),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    termination_date DATE,
    termination_reason TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_employees_job FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    CONSTRAINT fk_employees_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_employees_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_employees_location FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT chk_hire_before_termination CHECK (termination_date IS NULL OR termination_date >= hire_date)
);

-- Create indexes for better performance
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_manager ON employees(manager_id);
CREATE INDEX idx_employees_job ON employees(job_id);
CREATE INDEX idx_employees_location ON employees(location_id);
CREATE INDEX idx_employees_hire_date ON employees(hire_date);
CREATE INDEX idx_employees_status ON employees(employment_status);
CREATE INDEX idx_employees_active ON employees(is_active);
CREATE INDEX idx_employees_name ON employees(first_name, last_name);