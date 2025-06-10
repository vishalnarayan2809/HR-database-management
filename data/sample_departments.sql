-- Sample data for departments table
INSERT INTO departments (department_name, department_code, parent_department_id, manager_id, location_id, budget, cost_center, description, is_active) VALUES
('Executive', 'EXEC', NULL, NULL, 1, 2000000.00, 'CC001', 'Executive leadership and strategic planning', true),
('Human Resources', 'HR', 1, NULL, 1, 800000.00, 'CC002', 'Employee relations, recruitment, and HR policies', true),
('Finance', 'FIN', 1, NULL, 1, 600000.00, 'CC003', 'Financial planning, accounting, and budgeting', true),
('Information Technology', 'IT', 1, NULL, 1, 1500000.00, 'CC004', 'Technology infrastructure and software development', true),
('Sales', 'SALES', 1, NULL, 2, 1200000.00, 'CC005', 'Sales operations and client acquisition', true),
('Marketing', 'MKT', 1, NULL, 2, 900000.00, 'CC006', 'Marketing campaigns and brand management', true),
('Customer Support', 'SUPP', 1, NULL, 3, 400000.00, 'CC007', 'Customer service and technical support', true),
('Research and Development', 'RND', 1, NULL, 5, 1800000.00, 'CC008', 'Product research and innovation', true),
('Legal', 'LEG', 1, NULL, 1, 500000.00, 'CC009', 'Legal compliance and contract management', true),
('Operations', 'OPS', 1, NULL, 4, 700000.00, 'CC010', 'Business operations and process management', true),
('Quality Assurance', 'QA', 4, NULL, 5, 300000.00, 'CC011', 'Software testing and quality control', true),
('DevOps', 'DEVOPS', 4, NULL, 5, 400000.00, 'CC012', 'Infrastructure automation and deployment', true),
('Product Management', 'PM', 1, NULL, 1, 600000.00, 'CC013', 'Product strategy and lifecycle management', true),
('Data Analytics', 'DATA', 4, NULL, 1, 500000.00, 'CC014', 'Data analysis and business intelligence', true);