-- Performance reviews table for tracking employee performance
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

-- Create indexes for better performance
CREATE INDEX idx_performance_reviews_employee ON performance_reviews(employee_id);
CREATE INDEX idx_performance_reviews_reviewer ON performance_reviews(reviewer_id);
CREATE INDEX idx_performance_reviews_period ON performance_reviews(review_period_start, review_period_end);
CREATE INDEX idx_performance_reviews_status ON performance_reviews(status);
CREATE INDEX idx_performance_reviews_type ON performance_reviews(review_type);
