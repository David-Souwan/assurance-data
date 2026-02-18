

-- Création de la table clients

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    country VARCHAR(50),
    acquisition_channel VARCHAR(50),
    acquisition_date DATE,
    customer_segment VARCHAR(50),
    risk_profile VARCHAR(20)
);

-- Création de la table police


CREATE TABLE policies (
    policy_id INT PRIMARY KEY,
    client_id INT,
    product_type VARCHAR(100),
    start_date_ DATE,
    annual_premium NUMERIC(12,2),
    policy_status VARCHAR(20),
FOREIGN KEY (client_id) REFERENCES clients(client_id)
        
);

-- Création de la table claims


CREATE TABLE claims (
    claim_id INT PRIMARY KEY,
    policy_id INT,
    claim_date DATE,
    claim_amount NUMERIC(12,2),
    claim_status VARCHAR(20),
FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);

-- Création de la table payments


CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    policy_id INT,
    payment_date DATE,
    payment_amount NUMERIC(12,2),
    payment_type VARCHAR(50),
FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);


