-- Sample data for locations table
INSERT INTO locations (location_name, street_address, postal_code, city, state_province, country, region, phone_number, is_headquarters, is_active) VALUES
('New York Headquarters', '123 Broadway', '10001', 'New York', 'NY', 'USA', 'North America', '212-555-0001', true, true),
('Los Angeles Office', '456 Sunset Blvd', '90210', 'Los Angeles', 'CA', 'USA', 'North America', '310-555-0002', false, true),
('Chicago Branch', '789 Michigan Ave', '60601', 'Chicago', 'IL', 'USA', 'North America', '312-555-0003', false, true),
('Austin Tech Hub', '101 South Lamar', '78704', 'Austin', 'TX', 'USA', 'North America', '512-555-0004', false, true),
('Seattle Development Center', '202 Pine St', '98101', 'Seattle', 'WA', 'USA', 'North America', '206-555-0005', false, true),
('Miami Sales Office', '303 Ocean Drive', '33139', 'Miami', 'FL', 'USA', 'North America', '305-555-0006', false, true),
('London Office', '404 Oxford Street', 'W1A 0AA', 'London', 'England', 'United Kingdom', 'Europe', '44-20-7946-0007', false, true),
('Tokyo Branch', '505 Shibuya Crossing', '150-0002', 'Tokyo', 'Tokyo', 'Japan', 'Asia Pacific', '81-3-1234-5678', false, true);