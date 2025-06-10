-- Initial schema migration for HR database
-- Creates all base tables in the correct dependency order

-- Create locations table (no dependencies)
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    street_address VARCHAR(255),
    postal_code VARCHAR(20),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    country VARCHAR(100) NOT NULL DEFAULT 'USA',
    region VARCHAR(50),
    phone_number VARCHAR(20),
    is_headquarters BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create jobs table (no dependencies)
CREATE TABLE jobs (
    job_id SERIAL PRIMARY KEY,
    job_title VARCHAR(255) NOT NULL UNIQUE,
    job_description TEXT,
    min_salary DECIMAL(10, 2) NOT NULL,
    max_salary DECIMAL(10, 2) NOT NULL,
    job_category VARCHAR(100),
    experience_level VARCHAR(50) CHECK (experience_level IN ('Entry', 'Junior', 'Mid', 'Senior', 'Executive')),
    employment_type VARCHAR(50) DEFAULT 'Full-time' CHECK (employment_type IN ('Full-time', 'Part-time', 'Contract', 'Temporary')),
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_salary_range CHECK (max_salary >= min_salary)
);

-- Create departments table (depends on locations)
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_code VARCHAR(10) UNIQUE,
    parent_department_id INTEGER,
    manager_id INTEGER,
    location_id INTEGER NOT NULL,
    budget DECIMAL(15, 2),
    cost_center VARCHAR(20),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_departments_parent FOREIGN KEY (parent_department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_departments_location FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Create employees table (depends on jobs, departments, locations)
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

-- Create salary_history table (depends on employees)
CREATE TABLE salary_history (
    salary_history_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    old_salary DECIMAL(10, 2),
    new_salary DECIMAL(10, 2) NOT NULL,
    salary_change_amount DECIMAL(10, 2),
    salary_change_percentage DECIMAL(5, 2),
    change_reason VARCHAR(100),
    effective_date DATE NOT NULL,
    end_date DATE,
    approved_by INTEGER,
    notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_salary_history_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_salary_history_approver FOREIGN KEY (approved_by) REFERENCES employees(employee_id),
    CONSTRAINT chk_salary_positive CHECK (new_salary > 0),
    CONSTRAINT chk_end_after_effective CHECK (end_date IS NULL OR end_date >= effective_date)
);

-- Create performance_reviews table (depends on employees)
CREATE TABLE performance_reviews (
    review_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    reviewer_id INTEGER NOT NULL,
    review_period_start DATE NOT NULL,
    review_period_end DATE NOT NULL,
    review_type VARCHAR(50) DEFAULT 'Annual' CHECK (review_type IN ('Annual', 'Mid-year', 'Quarterly', 'Probationary', 'Special')),
    overall_rating INTEGER CHECK (overall_rating BETWEEN 1 AND 5),
    goals_achievement_rating INTEGER CHECK (goals_achievement_rating BETWEEN 1 AND 5),
    technical_skills_rating INTEGER CHECK (technical_skills_rating BETWEEN 1 AND 5),
    communication_rating INTEGER CHECK (communication_rating BETWEEN 1 AND 5),
    leadership_rating INTEGER CHECK (leadership_rating BETWEEN 1 AND 5),
    strengths TEXT,
    areas_for_improvement TEXT,
    goals_for_next_period TEXT,
    development_plan TEXT,
    reviewer_comments TEXT,
    employee_comments TEXT,
    status VARCHAR(20) DEFAULT 'Draft' CHECK (status IN ('Draft', 'In Progress', 'Completed', 'Approved')),
    review_date DATE,
    approval_date DATE,
    approved_by INTEGER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_performance_reviews_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_performance_reviews_reviewer FOREIGN KEY (reviewer_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_performance_reviews_approver FOREIGN KEY (approved_by) REFERENCES employees(employee_id),
    CONSTRAINT chk_review_period CHECK (review_period_end >= review_period_start)
);

-- Add the circular foreign key constraint for department manager
ALTER TABLE departments ADD CONSTRAINT fk_departments_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);