

--Objectif business : Identifier zones critiques : pays, produit, profil

--Prioriser actions sur marge et risque

-- Combinaisons pays + produit + risk_profile à risque

SELECT
    c.country,
    p.product_type,
    c.risk_profile,
    ROUND(SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved')
        / SUM(p.annual_premium),2) AS loss_ratio,
    SUM(p.annual_premium)
        - SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved') AS margin
FROM clients c
JOIN policies p ON c.client_id = p.client_id
LEFT JOIN claims_staging cl ON p.policy_id = cl.policy_id
GROUP BY c.country, p.product_type, c.risk_profile
HAVING
    SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved') / SUM(p.annual_premium) > 0.8
    AND SUM(p.annual_premium) - SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved') < 0
ORDER BY loss_ratio DESC;


/*
Interprétation globale

---Poches de risque prioritaire :

Auto + High Risk + France → perte très élevée → revoir souscription et pricing

SME + High Risk → segment rentable à surveiller, mais volatil

---Segments “à contrôler” :

Corporate + High Risk → peu de clients, mais perte par sinistre élevée

Retail + Medium/Low → volume élevé, mais perte cumulée importante

---Segments rentables (implicite) :

SME Medium Risk, Retail High Risk → marge positive ou moins mauvaise

Focus sur développement stratégique et cross-sell


🔹 Recommandations business concrètes

---Underwriting & Pricing

1- Revoir les tarifs sur High Risk (Auto, SME, Corporate)

2- Introduire franchises plus élevées ou couverture limitée sur segments à risque

---Portefeuille & Acquisition

1- Limiter acquisition de clients High Risk dans les marchés où la perte est forte

2- Favoriser acquisition sur segments rentables (SME Medium, Retail High)

---Fidélisation & produits

1- Segmenter les produits et canaux pour maximiser la marge par client

2- Améliorer rétention sur cohortes récentes (2023–2025)

*/
