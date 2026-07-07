CREATE SCHEMA CX_ANALYTICS;
USE CX_ANALYTICS;

-- tablas raw
CREATE TABLE CUSTOMERS(
CUSTOMER_ID VARCHAR(10) NOT NULL PRIMARY KEY,
ACQUISITION_DATE DATE,
ACQUISITION_CHANNEL VARCHAR(50)
);

CREATE TABLE TRANSACTIONS(
TRANSACTION_ID VARCHAR(10) NOT NULL PRIMARY KEY,
CUSTOMER_ID VARCHAR(10) NOT NULL,
DATE DATE,
PRODUCT_TYPE VARCHAR(10),
PRICE DECIMAL(12,2),
IS_RENEWAL BOOLEAN,
CONSTRAINT FK_CUSTOMER_ID
FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID)
);

CREATE TABLE ENGAGEMENT(
CUSTOMER_ID VARCHAR(10) NOT NULL,
DATE DATE,
WORKOUTS_COMPLETED INT,
VIDEOS_SENT INT,
MESSAGES_SENT INT,
CONSTRAINT FK_CUSTOMER_ID_2
FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID)
);

-- Obtener la fecha de primera compra de cada cliente y asignar su cohorte mensual
CREATE VIEW vw_cohorts AS
SELECT
CUSTOMER_ID,
MIN(DATE) AS PRIMERA_COMPRA,
DATE_FORMAT(MIN(DATE), '%Y-%m-01') AS COHORT_MES
FROM TRANSACTIONS
GROUP BY CUSTOMER_ID;

-- Medir la actividad de cada cliente en el tiempo desde su primera compra (edad en meses)
CREATE VIEW vw_customer_activity AS
WITH PRIMERA_COMPRA AS (
SELECT
CUSTOMER_ID,
MIN(DATE) AS PRIMERA_COMPRA,
DATE_FORMAT(MIN(DATE), '%Y-%m-01') AS COHORT_MES
FROM TRANSACTIONS
GROUP BY CUSTOMER_ID)
SELECT
T.CUSTOMER_ID AS CLIENTE,
PC.COHORT_MES,
T.DATE AS FECHA_PAGO,
TIMESTAMPDIFF(MONTH, PC.PRIMERA_COMPRA, T.DATE) AS MES_DE_ADQUISICION
FROM TRANSACTIONS T
JOIN PRIMERA_COMPRA PC ON T.CUSTOMER_ID = PC.CUSTOMER_ID;

-- Construir la tabla de retención por cohorte (clientes activos por mes desde adquisición)
CREATE VIEW vw_retention AS
WITH PRIMERA_COMPRA AS(
SELECT
CUSTOMER_ID,
MIN(DATE) AS PRIMERA_COMPRA,
DATE_FORMAT(MIN(DATE), '%Y-%m-01') AS COHORT_MES
FROM TRANSACTIONS
GROUP BY CUSTOMER_ID
),
ACTIVIDAD AS(
SELECT
T.CUSTOMER_ID, 
PC.COHORT_MES,
TIMESTAMPDIFF(MONTH, PC.PRIMERA_COMPRA, T.DATE) AS MES_NUM 
FROM TRANSACTIONS T
JOIN PRIMERA_COMPRA PC ON T.CUSTOMER_ID = PC.CUSTOMER_ID
),
COHORT_SIZE AS(
SELECT COHORT_MES, COUNT(DISTINCT CUSTOMER_ID) AS TOTAL_CLIENTES
FROM PRIMERA_COMPRA 
GROUP BY COHORT_MES
)
SELECT 
A.COHORT_MES,
CS.TOTAL_CLIENTES,
A.MES_NUM,
COUNT(DISTINCT A.CUSTOMER_ID) AS CLIENTES_ACTIVOS
FROM ACTIVIDAD A
JOIN COHORT_SIZE CS ON A.COHORT_MES = CS.COHORT_MES
GROUP BY A.COHORT_MES, CS.TOTAL_CLIENTES, A.MES_NUM;

-- Calcular métricas base RFM por cliente: recencia, frecuencia y valor monetario
CREATE VIEW vw_rfm_base AS
SELECT
CUSTOMER_ID,
DATEDIFF('2024-12-31', MAX(DATE)) AS RECENCY_DIAS,
COUNT(DISTINCT DATE) AS FREQUENCY_PAGOS,
SUM(PRICE) AS MONETARY_TOTAL
FROM TRANSACTIONS
GROUP BY CUSTOMER_ID;

-- Asignar scores RFM (1 a 5) para segmentación de clientes
CREATE OR REPLACE VIEW vw_rfm_scores AS
WITH rfm_base AS (
SELECT 
customer_id,
DATEDIFF('2024-12-31', MAX(date)) AS recency_dias,
COUNT(DISTINCT date) AS frequency_pagos,
SUM(price) AS monetary_total
FROM transactions
GROUP BY customer_id
)
SELECT 
customer_id,
recency_dias,
frequency_pagos,
monetary_total,
NTILE(5) OVER (ORDER BY recency_dias desc) AS r_score,
NTILE(5) OVER (ORDER BY frequency_pagos asc) AS f_score,
NTILE(5) OVER (ORDER BY monetary_total asc) AS m_score
FROM rfm_base;

-- Clasificar clientes en segmentos de negocio en base a su score RFM
CREATE OR REPLACE VIEW vw_rfm_segmented AS
WITH rfm_base AS (
 SELECT customer_id,
 DATEDIFF('2024-12-31', MAX(date)) AS recency_dias,
 COUNT(DISTINCT date) AS frequency_pagos,
 SUM(price) AS monetary_total
 FROM transactions GROUP BY customer_id
),
rfm_scored AS (
 SELECT *,
 NTILE(5) OVER (ORDER BY recency_dias DESC) AS r_score,
 NTILE(5) OVER (ORDER BY frequency_pagos ASC) AS f_score,
 NTILE(5) OVER (ORDER BY monetary_total ASC) AS m_score
 FROM rfm_base
)
SELECT
 customer_id, recency_dias, frequency_pagos, monetary_total,
 r_score, f_score, m_score,
 CONCAT(r_score, f_score, m_score) AS rfm_score,
 CASE
 WHEN r_score >= 4 AND f_score >= 4 THEN 'Campeon'
 WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 4 THEN 'Leal'
 WHEN r_score <= 2 AND f_score >= 3 THEN 'En Riesgo'
 WHEN r_score >= 4 AND f_score <= 2 AND m_score >= 4 THEN 'Grande Puntual'
 WHEN r_score >= 4 AND f_score <= 2 THEN 'Nuevo'
 WHEN r_score <= 2 AND f_score <= 2 THEN 'Hibernando'
 ELSE 'Intermedio'
 END AS segmento
FROM rfm_scored;

-- Analizar métricas de valor por segmento RFM y canal de adquisición
CREATE OR REPLACE VIEW vw_clv AS
WITH RFM_BASE AS(
SELECT CUSTOMER_ID,
DATEDIFF('2024-12-31', MAX(DATE)) AS RECENCY_DIAS,
COUNT(DISTINCT DATE) AS FREQUENCY_PAGOS,
SUM(PRICE) AS MONETARY_TOTAL,
AVG(PRICE) AS TICKET_PROMEDIO
FROM TRANSACTIONS
GROUP BY CUSTOMER_ID),
RFM_SCORE AS(
SELECT *,
NTILE(5) OVER (ORDER BY recency_dias DESC) AS r_score,
NTILE(5) OVER (ORDER BY frequency_pagos ASC) AS f_score,
NTILE(5) OVER (ORDER BY monetary_total ASC) AS m_score
 FROM RFM_BASE
),
RFM_SEGMENTED AS(
SELECT *,
 CASE
 WHEN r_score >= 4 AND f_score >= 4 THEN 'Campeon'
 WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 4 THEN 'Leal'
 WHEN r_score <= 2 AND f_score >= 3 THEN 'En Riesgo'
 WHEN r_score >= 4 AND f_score <= 2 AND m_score >= 4 THEN 'Grande Puntual'
 WHEN r_score >= 4 AND f_score <= 2 THEN 'Nuevo'
 WHEN r_score <= 2 AND f_score <= 2 THEN 'Hibernando'
 ELSE 'Intermedio'
 END AS segmento
FROM RFM_SCORE
)
SELECT
RS.SEGMENTO, C.ACQUISITION_CHANNEL,
COUNT(*) AS TOTAL_CLIENTES,
ROUND(AVG(RS.monetary_total), 0) AS clv_promedio,
ROUND(AVG(RS.ticket_promedio), 0) AS ticket_promedio,
ROUND(AVG(RS.frequency_pagos), 1) AS frecuencia_promedio,
ROUND(SUM(RS.monetary_total), 0) AS revenue_total_segmento
FROM RFM_SEGMENTED RS
JOIN CUSTOMERS C ON RS.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY RS.SEGMENTO, C.ACQUISITION_CHANNEL;

-- Estimar el revenue asociado a clientes en riesgo
CREATE OR REPLACE VIEW vw_revenue_risk AS
WITH rfm_base AS (
 SELECT customer_id,
 DATEDIFF('2024-12-31', MAX(date)) AS recency_dias,
 COUNT(DISTINCT date) AS frequency_pagos,
 SUM(price) AS monetary_total,
 AVG(price) AS ticket_promedio
 FROM transactions GROUP BY customer_id
),
rfm_scored AS (
 SELECT *,
 NTILE(5) OVER (ORDER BY recency_dias DESC) AS r_score,
 NTILE(5) OVER (ORDER BY frequency_pagos ASC) AS f_score,
 NTILE(5) OVER (ORDER BY monetary_total ASC) AS m_score
 FROM rfm_base
),
en_riesgo AS (
 SELECT * FROM rfm_scored
 WHERE r_score <= 2 AND f_score >= 3
)
SELECT
 COUNT(*) AS clientes_en_riesgo,
 ROUND(AVG(ticket_promedio), 0) AS ticket_promedio_mensual,
 ROUND(SUM(ticket_promedio), 0) AS revenue_mensual_en_riesgo,
 ROUND(SUM(ticket_promedio) * 12, 0) AS revenue_anual_en_riesgo
FROM en_riesgo;

-- Identificar clientes churned según días de inactividad desde su última compra
CREATE VIEW vw_churn AS
SELECT
 customer_id,
 MAX(date) AS ultima_transaccion,
 DATEDIFF('2024-12-31', MAX(date)) AS dias_sin_actividad,
 CASE
 WHEN DATEDIFF('2024-12-31', MAX(date)) > 45
 THEN 'Churned'
 ELSE 'Activo'
 END AS estado_churn
FROM transactions
GROUP BY customer_id;

-- Comparar el engagement previo al churn vs clientes activos
CREATE VIEW vw_engagement AS
WITH estado_clientes AS (
 SELECT customer_id,
 MAX(date) AS ultima_txn,
 CASE WHEN DATEDIFF('2024-12-31', MAX(date)) > 45
 THEN 'Churned' ELSE 'Activo'
 END AS estado
 FROM transactions GROUP BY customer_id
),
eng_previo AS (
 SELECT
 e.customer_id,
 ec.estado,
 e.workouts_completed,
 e.videos_sent,
 e.messages_sent,
 DATEDIFF(ec.ultima_txn, e.date) AS dias_antes_churn
 FROM engagement e
 JOIN estado_clientes ec ON e.customer_id = ec.customer_id
 WHERE DATEDIFF(ec.ultima_txn, e.date) BETWEEN 0 AND 28
)
SELECT
 estado,
 COUNT(DISTINCT customer_id) AS clientes,
 ROUND(AVG(workouts_completed), 1) AS avg_workouts,
 ROUND(AVG(videos_sent), 1) AS avg_videos,
 ROUND(AVG(messages_sent), 1) AS avg_mensajes
FROM eng_previo
GROUP BY estado;
