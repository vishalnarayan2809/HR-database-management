-- Enhanced salary history table with comprehensive salary tracking
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

-- Create indexes for better performance
CREATE INDEX idx_salary_history_employee ON salary_history(employee_id);
CREATE INDEX idx_salary_history_effective_date ON salary_history(effective_date);
CREATE INDEX idx_salary_history_approver ON salary_history(approved_by);

-- Create unique constraint for active salary records
CREATE UNIQUE INDEX idx_salary_history_active ON salary_history(employee_id) 
WHERE end_date IS NULL;