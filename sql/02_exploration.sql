

-- Exploration : volume de lignes par table
-- Objectif : comprendre la taille du portefeuille et des événements associés

SELECT 'clients'  AS table_name, COUNT(*) AS nb_rows FROM clients
UNION ALL
SELECT 'policies' AS table_name, COUNT(*) AS nb_rows FROM policies
UNION ALL
SELECT 'claims_staging' AS table_name, COUNT(*) AS nb_rows FROM claims_staging
UNION ALL
SELECT 'payments_staging' AS table_name, COUNT(*) AS nb_rows FROM payments_staging;


-- Nombre de contrats par client


SELECT c.client_id, c.country, COUNT(p.policy_id) AS nbr_contrat
FROM policies p
JOIN clients c ON c.client_id = p.client_id
GROUP BY c.client_id, c.country
ORDER BY nbr_contrat DESC;


-- Exploration : ratios clés du modèle relationnel


SELECT
    ROUND((SELECT COUNT(*) FROM policies)::DECIMAL / COUNT(*), 2) AS avg_policies_per_client
FROM clients;
--- Portefeuille partiellement multi-équipé

SELECT
    ROUND(COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM policies), 2) AS avg_claims_per_policy
FROM claims_staging;
--- Sinistralité modérée mais significative

SELECT
    ROUND(COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM policies), 2) AS avg_payments_per_policy
FROM payments_staging;
--- Paiements multiples (prime + sinistre / remboursement)


-- Exploration : période couverte par les contrats

SELECT
    MIN(start_date_) AS min_policy_date,
    MAX(start_date_) AS max_policy_date
FROM policies;

SELECT
    MIN(claim_date) AS min_claims_date,
    MAX(claim_date) AS max_claims_date
FROM claims_staging;

SELECT
    MIN(payment_date) AS min_payments_date,
    MAX(payment_date) AS max_payments_date
FROM payments_staging;

SELECT
    MIN(acquisition_date) AS min_clients_date,
    MAX(acquisition_date) AS max_clients_date
FROM clients;


-- Exploration : valeurs manquantes dans policies

SELECT
    COUNT(*) FILTER (WHERE annual_premium IS NULL) AS missing_premium,
    COUNT(*) FILTER (WHERE product_type IS NULL) AS missing_product,
    COUNT(*) FILTER (WHERE policy_status IS NULL) AS missing_status
FROM policies;

-- Exploration : valeurs manquantes dans claims

SELECT
    COUNT(*) FILTER (WHERE claim_amount IS NULL) AS missing_amount,
    COUNT(*) FILTER (WHERE claim_status IS NULL) AS missing_status
FROM claims_staging;

-- Exploration : valeurs manquantes dans payments

SELECT
    COUNT(*) FILTER (WHERE payment_amount IS NULL) AS missing_payment_amount,
    COUNT(*) FILTER (WHERE payment_type IS NULL) AS missing_payment_status
FROM payments_staging;


-- Exploration : valeurs manquantes dans clients

SELECT
    COUNT(*) FILTER (WHERE country IS NULL) AS missing_country,
    COUNT(*) FILTER (WHERE acquisition_channel IS NULL) AS missing_acquisition,
    COUNT(*) FILTER (WHERE risk_profile IS NULL) AS missing_risk
FROM clients;


/* 
-Aucune prime manquante
-Aucun montant de sinistre manquant
-Aucun paiement sans type
-Aucun client sans pays / canal / profil de risque */
