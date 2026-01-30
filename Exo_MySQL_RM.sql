-- ========================================
-- Création de la base de données Samsung_DB
-- ========================================
DROP DATABASE IF EXISTS Samsung_DB;
CREATE DATABASE Samsung_DB;
USE Samsung_DB;

-- ========================================
-- Table : Clients_Samsung
-- ========================================
CREATE TABLE Clients_Samsung (
    ID_Client VARCHAR(10) PRIMARY KEY,
    Age INT NOT NULL,
    Sexe ENUM('Homme', 'Femme', 'Autre') NOT NULL,
    Pays VARCHAR(100) NOT NULL,
    Revenu_Annuel DECIMAL(15,2) NOT NULL,
    Date_Inscription DATE NOT NULL,
    Nombre_Achats INT DEFAULT 0,
    Préférence_Produit VARCHAR(100),
    Canal_Préféré VARCHAR(50),
    Score_Fidélité DOUBLE CHECK (Score_Fidélité >= 0 AND Score_Fidélité <= 10)
);

-- ========================================
-- Table : Produits_Samsung
-- ========================================
CREATE TABLE Produits_Samsung (
    ID_Produit VARCHAR(10) PRIMARY KEY,
    Nom_Produit VARCHAR(150) NOT NULL,
    Catégorie VARCHAR(100) NOT NULL,
    Sous_Catégorie VARCHAR(100),
    Prix DECIMAL(15,2) NOT NULL,
    Date_Lancement DATE NOT NULL,
    Date_Fin_Production DATE NULL DEFAULT NULL,
    Nombre_Revendeurs INT DEFAULT 0,
    Nombre_Pays_Distribution INT DEFAULT 0,
    Nombre_Publicités INT DEFAULT 0,
    Gamme ENUM('Économique', 'Premium', 'Moyenne') NOT NULL,
    Certification VARCHAR(150)
);

-- ========================================
-- Table : Ventes_Samsung
-- ========================================
CREATE TABLE Ventes_Samsung (
    ID_Vente VARCHAR(15) PRIMARY KEY,
    ID_Produit VARCHAR(10),
    Quantité_Vendue INT NOT NULL,
    Date_Vente DATE NOT NULL,
    ID_Client VARCHAR(10),
    Montant_Total DECIMAL(15,2) NOT NULL,
    Délai_Livraison_Jours INT,
    Score_Satisfaction DOUBLE CHECK (Score_Satisfaction >= 0 AND Score_Satisfaction <= 10),
    Méthode_Expédition ENUM('Standard', 'Express', 'Premium') NOT NULL,
    Canal_Achat VARCHAR(100) NOT NULL,
    Pays_Vente VARCHAR(100) NOT NULL

   /*  -- Relations avec suppression = SET NULL
    CONSTRAINT fk_client FOREIGN KEY (ID_Client) 
        REFERENCES Clients_Samsung(ID_Client) ,

    CONSTRAINT fk_produit FOREIGN KEY (ID_Produit) 
        REFERENCES Produits_Samsung(ID_Produit) */
        
);

-- ========================================
-- Vérification des tables 
-- ========================================
SHOW TABLES;

-- Exercice 1 : Sélection de clients basée sur des critères multiples
-- Objectif : Afficher les informations des clients qui répondent à tous les critères suivants :
-- Age supérieur ou égal à 30 ans.
-- Revenu annuel compris entre 40 000 et 70 000 euros.
-- Inscrits après le 1er janvier 2018.
-- Ayant un score de fidélité supérieur à 5.

SELECT 
	*
FROM 
	clients_samsung
WHERE
	Age >= 30
    AND Revenu_Annuel BETWEEN 40000 AND 70000
    AND Date_Inscription > DATE_FORMAT("2018-01-01" , "%Y-%m-%d")
    AND Score_Fidélité > 5;
    

-- Exercice 2 : Analyse des ventes avec multiples conditions
-- Sélectionner les détails des ventes qui satisfont à toutes les conditions suivantes :
-- Montant total de la vente supérieur à 1000 euros.
-- Score de satisfaction client inférieur à 3.
-- Ventes réalisées en ligne.
-- Délai de livraison supérieur à 20 jours.

SELECT    
	*
FROM
	ventes_samsung
WHERE
	Montant_Total > 1000
    AND Score_Satisfaction <3
    AND Canal_Achat = 'En ligne'
    AND Délai_Livraison_Jours > 20;
    
-- Exercice 3 : Diversité des pays de vente
-- Problématique : Pour évaluer l'expansion géographique de l'entreprise, identifiez
-- tous les pays distincts où les produits ont été vendus.

SELECT
	DISTINCT(Pays_Vente)
FROM
	ventes_samsung;

-- Exercice 4 : Analyse des canaux de vente et satisfaction des clients
-- : Évaluez l'efficacité des canaux de vente en fonction de la
-- satisfaction des clients. Pour chaque canal de vente, affichez le canal, le score
-- moyen de satisfaction des clients et le nombre total de ventes réalisées par ce canal.
SELECT
	Canal_Achat,
    ROUND(AVG(Score_Satisfaction),2) 	AS Moyenne_Satisfaction_client_Canal,
    COUNT(Canal_Achat)					AS Nbre_Total_Vente_Canal,
    SUM(Quantité_Vendue)				AS Qte_Totale_Vendue_Canal
FROM
	ventes_samsung
GROUP BY
	Canal_Achat;

-- Exercice 5 : Produits et leur popularité
-- Problématique : Affichez chaque produit, son prix, et le nombre total de fois qu'il a été vendu.
SELECT
	PR.ID_Produit,
    PR.Nom_Produit,
    PR.Prix,
    SUM(VE.Quantité_Vendue)				AS Quantite_Vendue_Produit
FROM
	produits_samsung 					AS PR
    LEFT JOIN ventes_samsung			AS VE
    ON PR.ID_Produit = VE.ID_Produit
GROUP BY
	1,2,3;
    
 -- Exercice 6 : Profilage des clients
 -- Problématique : Déterminez l'âge moyen et le revenu annuel maximum des clients
-- pour chaque pays. Affichez le pays, l'âge moyen et le revenu annuel maximum.
SELECT
	Pays,
    ROUND(AVG(Age))					AS Age_Moyen,
    MAX(Revenu_Annuel)				AS Revenu_Annuel_Max
FROM
	clients_samsung
GROUP BY
	Pays;
    
    
-- Exercice 7 : Analyse des méthodes d'expédition
-- Problématique : Identifiez le délai de livraison minimum et le score de satisfaction
-- moyen pour chaque méthode d'expédition. Affichez la méthode d'expédition, le
-- délai de livraison minimum et le score moyen de satisfaction.
SELECT
	Méthode_Expédition,
    MIN(Délai_Livraison_Jours)			AS Delai_livraison_Min,
    ROUND(AVG(Score_Satisfaction),2)	AS Score_moyen_Satisfaction
FROM
	ventes_samsung
GROUP BY
	Méthode_Expédition;


-- Exercice 8 : Analyse de la fidélité des clients
-- Problématique : Déterminez le nombre de clients avec un score de fidélité "Faible"
-- (<5), "Moyen" (5-7), "Élevé" (>7).

SELECT
	CASE
		WHEN Score_Fidélité < 5 THEN "Faible"
        WHEN Score_Fidélité BETWEEN 5 AND 7 THEN "Moyen"
        ELSE "Élevé"
	END 									AS Categorie_Score_Fidelite,
	COUNT(Score_Fidélité)	 				AS Nbre_clients_categorie
FROM
	clients_samsung
GROUP BY
	Categorie_Score_Fidelite;
    
    
-- Exercice 9 : Analyse des produits populaires
-- Problématique : Trouvez les produits dont le montant total des ventes dépasse 15000.
--  Listez l'ID du produit et le montant total des ventes.

SELECT 
    ID_Produit,
    ROUND(SUM(Montant_Total)) 				AS Montant_total_vente
FROM
	ventes_samsung 						
GROUP BY
	1
HAVING 
	Montant_total_vente > 15000;
    
    
-- Exercice 10 : Identification des pays à forte activité commerciale
-- Problématique : Trouvez les pays où plus de 400 ventes ont été réalisées. Affichez
-- le nom du pays et le nombre total de ventes.
SELECT
	Pays_Vente,
    COUNT(Pays_Vente) 				AS Nbre_Vente_Total
FROM
	ventes_samsung 						
GROUP BY
	1
HAVING 
	Nbre_Vente_Total > 400;
    
    
-- Exercice 11 : Analyse des ventes par mois
-- Problématique : Calculez le montant total des ventes pour chaque mois de l'année
-- 2021. Utilisez DATE_FORMAT() pour extraire le mois de la date de vente.   

SELECT
	DATE_FORMAT(Date_Vente, '%Y') 				AS Annee_vente,
    DATE_FORMAT(Date_Vente, '%m')				AS Mois_vente,
    ROUND(SUM(Montant_Total))					AS Total_Vente_mensuel
FROM
	ventes_samsung
WHERE
	DATE_FORMAT(Date_Vente, '%Y') = 2021
GROUP BY 1,2
ORDER BY  Mois_vente;


-- Exercice 12 : Classification des ventes par jour de la semaine
-- Classez les ventes en "Weekend" (Samedi et Dimanche) et
-- "Semaine" (Lundi à Vendredi). Calculez le nombre total de ventes pour chaque classification.
SELECT
	CASE
		WHEN DATE_FORMAT(Date_Vente,'%w') IN (0,6) THEN "Weekend"
        ELSE "Semaine"
	END 								AS Jour_Semaine,
    COUNT(ID_Vente)						AS Nbre_total_Vente
FROM
	ventes_samsung
GROUP BY
	Jour_Semaine;
    
    
-- Exercice 13 : Catégorisation des ventes par période de l'année
-- Problématique : Catégorisez les ventes en "Début d'Année" (Janvier à Avril), "Milieu
-- d'Année" (Mai à Août), et "Fin d'Année" (Septembre à Décembre) basé sur la date
-- de vente. Calculez le montant total des ventes pour chaque catégorie
SELECT
	CASE
		WHEN DATE_FORMAT(Date_Vente,'%c') IN (1,2,3,4)  THEN "Début d'Année"
        WHEN DATE_FORMAT(Date_Vente,'%c') IN (5,6,7,8)  THEN "Milieu d'Année"
        WHEN DATE_FORMAT(Date_Vente,'%c') > 8           THEN "Fin d'Année"
	END 										AS Periode_annee,
    ROUND(SUM(Montant_Total))					AS Montant_total
FROM
	ventes_samsung 
GROUP BY
	1;
    
-- Exercice 14 : Clients fidèles dans des pays spécifiques
-- Problématique : Identifiez les clients de France et d'Allemagne ayant un score de
-- fidélité moyen supérieur à 7.
SELECT
	CASE
		WHEN Score_Fidélité > 7 THEN 'OUI'
        ELSE 'NON'
    END                                      AS Fidele,
    ID_Client,
    Pays
FROM
	clients_samsung
WHERE
	Pays IN ('France', 'Allemagne')
    AND Score_Fidélité > 7
ORDER BY 
	3;
    
-- Exercice 15 : Catégorisation des clients selon leur Revenu et Leur Âge
-- Problématique : Pour une segmentation marketing, vous devez catégoriser les clients
-- en fonction de leur revenu et de leur âge. Créez une nouvelle variable "Segment_Client"
-- avec les conditions suivantes :
-- "Jeune à Revenu Élevé" : Pour les clients de moins de 35 ans avec un revenu supérieur à 50 000.
-- "Jeune à Revenu Moyen" : Pour les clients de moins de 35 ans avec un revenu entre 30 000 et 50 000.
-- "Jeune à Revenu Faible" : Pour les clients de moins de 35 ans avec un revenu inférieur à 30 000.
-- "Senior à Revenu Élevé" : Pour les clients de 35 ans et plus avec un revenu supérieur à 50 000.
-- "Senior à Revenu Moyen" : Pour les clients de 35 ans et plus avec un revenu entre 30 000 et 50 000.
-- "Senior à Revenu Faible" : Pour les clients de 35 ans et plus avec un revenu inférieur à 30 000.

SELECT
	CASE
		WHEN (Age < 35) AND (Revenu_Annuel > 50000) THEN "Jeune à Revenu Élevé" 
		WHEN (Age < 35) AND (Revenu_Annuel BETWEEN 30000 AND  50000) THEN "Jeune à Revenu Moyen"
		WHEN (Age < 35) AND (Revenu_Annuel < 30000) THEN "Jeune à Revenu Faible"
		WHEN (Age <= 35) AND (Revenu_Annuel > 50000) THEN "Senior à Revenu Élevé" 
		WHEN (Age >= 35) AND (Revenu_Annuel BETWEEN 30000 AND  50000) THEN "Senior à Revenu Moyen"
		WHEN (Age >= 35) AND (Revenu_Annuel < 30000) THEN "Senior à Revenu Faible"
        ELSE 'Non_classifie'
	END   						AS Segment_Client,
    ROUND(AVG(Age))				AS Age_moyen_Segment,
	COUNT(ID_Client)			AS Nbre_clients_segments,
	ROUND(AVG(Revenu_Annuel))	AS Revenu_moyen_Segment
    
FROM
	clients_samsung
GROUP BY
	1
ORDER BY Segment_Client;

-- Exercice 16 : Tendances des ventes par mois
-- Problématique : Déterminez le volume total des ventes pour chaque mois en
-- affichant tous les mois de l'année avec la quantité totale de produits vendus
-- durant ces mois.
SELECT
    DATE_FORMAT(Date_Vente, '%m')				AS Mois_vente,
    COUNT(ID_Vente)								AS Volume_vente_mensuel,
    ROUND(SUM(Quantité_Vendue))					AS Qte_Total_Vente_mensuel
FROM
	ventes_samsung
GROUP BY 1
ORDER BY  Mois_vente;

-- Exercice 17 : Analyse croisée des produits par gamme et pays de vente
-- Problématique : Pour chaque combinaison Gamme et Pays_Vente, calculez :
-- le nombre de ventes, le montant total des ventes.
SELECT
	PR.Gamme,
    VE.Pays_Vente,
    COUNT(VE.ID_Vente)				AS nombre_vente_gamme,
    ROUND(SUM(VE.Montant_Total))	AS Montant_total_gamme
FROM
	produits_samsung				AS PR
    LEFT JOIN ventes_samsung		AS VE
    ON PR.ID_Produit= VE.ID_Produit
GROUP BY
	PR.Gamme,
    VE.Pays_Vente
HAVING
	Montant_total_gamme > 0
ORDER BY 
	PR.Gamme,
    VE.Pays_Vente;
    

-- Exercice 18 : Analyse croisée multi-dimensionnelle des performances produits
-- Problématique : Pour chaque gamme de produit et chaque canal d’achat, affichez :
-- le nombre total de ventes,
-- la quantité totale vendue,
-- le montant total des ventes,
-- la satisfaction moyenne,
-- Triez par gamme, puis canal.

SELECT
	PR.Gamme,
    VE.Canal_Achat,
    COUNT(VE.ID_Vente)									AS Nbre_total_vente,
    SUM(VE.Quantité_Vendue)								AS Qte_totale_vendue,
    FORMAT(SUM(VE.Montant_Total),0,'fr-FR')				AS Montant_total,
    ROUND(AVG(VE.Score_Satisfaction),2)		AS Satisfaction_moyenne
FROM
	produits_samsung				AS PR
    LEFT JOIN ventes_samsung		AS VE
    ON PR.ID_Produit= VE.ID_Produit
GROUP BY
	PR.Gamme,
    VE.Canal_Achat
HAVING 
	Nbre_total_vente > 0
ORDER BY 
	PR.Gamme,
     VE.Canal_Achat;


