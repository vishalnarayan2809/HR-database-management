-- Enhanced departments table with hierarchy support and location reference
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
    -- Note: manager_id FK will be added after employees table is created
);

-- Create indexes for better performance
CREATE INDEX idx_departments_parent ON departments(parent_department_id);
CREATE INDEX idx_departments_manager ON departments(manager_id);
CREATE INDEX idx_departments_location ON departments(location_id);
CREATE INDEX idx_departments_active ON departments(is_active);