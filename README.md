# FitCoach CX Analytics

> **[🇦🇷 Leer en Español](#español) · [🇺🇸 Read in English](#english)**

---

<a name="español"></a>

## 🇦🇷 Español

### Sobre este proyecto

Este proyecto nació de una pregunta de negocio real:

> *¿Puede un negocio de coaching fitness tener revenue creciente y un problema de retención grave al mismo tiempo — sin que nadie lo note?*

La respuesta es sí. Y este análisis lo demuestra.

**FitCoach** es un negocio de coaching fitness digital que vende programas de entrenamiento personalizado a través de Instagram y TikTok. Dos productos: un plan Basic de pago único y un plan Pro de renovación mensual. Revenue estable. Adquisición creciente. Todo bien en superficie.

Debajo: un segmento de clientes Pro que renovó 2–3 veces está empezando a desaparecer silenciosamente. Los clientes nuevos de TikTok tapan el hueco mes a mes. El revenue no baja. Pero el CLV promedio sí — y nadie lo estaba mirando.

Este proyecto es el análisis de ese problema.

---

### El dataset

Dataset sintético con patrones de comportamiento realistas, construido para reflejar dinámicas reales de negocios de suscripción de coaching digital.

| Tabla | Registros | Descripción |
|---|---|---|
| `customers` | 400 | Canal de adquisición, fecha de alta |
| `transactions` | 1.859 | Pagos, renovaciones, tipo de plan |
| `engagement` | 7.428 | Actividad semanal: workouts, videos, mensajes |

**Período:** Enero 2023 — Diciembre 2024 (24 meses)  
**Productos:** Basic ($30 pago único) · Pro ($50 renovación mensual)  
**Canales:** Instagram · TikTok · Referral · Organic

Los patrones intencionales del dataset:

- 📉 **El efecto TikTok:** el canal que más volumen trae tiene el CLV más bajo ($61 vs $285 de Referral)
- ⚠️ **La señal pre-churn:** el engagement cae 3 semanas antes de que el cliente no renueve
- 🔴 **El segmento silencioso:** clientes Pro con 3–6 meses de antigüedad, todavía "activos" en el sistema pero con comportamiento de abandono

---

### Estructura del análisis

El proyecto sigue una metodología profesional de extremo a extremo:

```
1. Auditoría del dataset     →  validar antes de analizar
2. Análisis de Cohortes      →  retención mensual por cohorte de adquisición
3. RFM + Segmentación        →  segmentar clientes por valor y comportamiento
4. CLV por segmento          →  cuantificar el revenue en riesgo en plata
5. Señales pre-churn         →  identificar el momento exacto de la caída
6. Insights + Soluciones     →  recomendaciones orientadas al negocio
```

> **Por qué este orden:** el análisis empieza auditando los datos porque un error en los datos produce conclusiones incorrectas aunque las queries sean perfectas. Solo después de confirmar que el dataset es congruente se avanza al análisis.

---

### Stack tecnológico

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

- **MySQL** — auditoría, RFM con NTILE(5), cohortes, CLV, señales pre-churn
- **Power BI + DAX** — dashboard de 4 páginas con slicers cruzados por canal
- **Python** — generación del dataset sintético con patrones controlados

---

### Módulos de análisis

#### 🔍 Auditoría del dataset
Antes de escribir una sola query de análisis, verifico que los datos sean congruentes: nulos en campos críticos, duplicados, fechas imposibles, precios fuera de rango, referencias huérfanas. El resultado de la auditoría se documenta antes de avanzar.

#### 📅 Análisis de Cohortes
Agrupa clientes por mes de primera compra y rastrea qué porcentaje sigue activo en cada mes posterior. El insight clave: la retención cae abruptamente entre el mes 2 y el mes 3, y las cohortes de TikTok retienen un 40% menos que las de Instagram.

#### 🎯 RFM + Segmentación
Cada cliente recibe tres scores del 1 al 5 usando `NTILE(5)` en SQL: Recency (cuándo compró por última vez), Frequency (cuántas veces compró) y Monetary (cuánto gastó). La combinación de scores genera 6 segmentos accionables: Campeones, Leales, En Riesgo, Grandes Puntuales, Nuevos e Hibernando.

#### 💰 Customer Lifetime Value (CLV)
Calcula el valor total de cada cliente y lo cruza con su segmento RFM y canal de adquisición. La brecha de CLV entre canales es el hallazgo más crítico del proyecto: un cliente de Referral vale 4.6x más que uno de TikTok durante su ciclo de vida.

#### 📉 Señales pre-churn
Analiza el comportamiento de engagement en las 4 semanas previas al churn comparado con clientes activos. Los workouts completados caen de 8–10 por semana a 1–2. Los mensajes se cortan. La señal aparece 3 semanas antes de la no renovación — suficiente tiempo para intervenir.

---

### El insight principal

> *"El revenue creció un 40% en 24 meses, pero el CLV promedio cayó un 28%. Un segmento de 85 clientes Pro con historial de pago está en proceso de abandono silencioso. Representan $X de revenue mensual recurrente. Si se retiene el 30% con intervención proactiva en semana 8, el impacto es $Y adicionales por mes sin adquirir un solo cliente nuevo."*

---

### Estado del proyecto

| Módulo | Estado |
|---|---|
| Dataset sintético | ✅ Completo |
| Documentación del proyecto | ✅ Completa |
| Auditoría del dataset | 🔄 En progreso |
| Análisis de Cohortes | 🔄 En progreso |
| RFM + Segmentación | 🔄 En progreso |
| CLV por segmento | 🔄 En progreso |
| Señales pre-churn | ⏳ Pendiente |
| Dashboard Power BI | ⏳ Pendiente |

---

### Estructura del repositorio

```
fitcoach-cx-analytics/
│
├── data/
│   ├── customers.csv
│   ├── transactions.csv
│   └── engagement.csv
│
├── sql/
│   ├── 01_auditoria.sql
│   ├── 02_cohortes.sql
│   ├── 03_rfm_segmentacion.sql
│   ├── 04_clv.sql
│   └── 05_señales_prechurn.sql
│
├── docs/
│   └── FitCoach_Proyecto_Portfolio.docx
│
├── dashboard/
│   └── FitCoach_Dashboard.pbix        (próximamente)
│
└── README.md
```

---

### Sobre mí

**Federico Almonacid** — Jr Data Analyst | BI & CX Analytics  
Río Grande, Tierra del Fuego, Argentina

Más de 4 años de experiencia en retail (gestión de equipos, NPS, KPIs, análisis de performance). En transición activa hacia roles de BI Analyst, CX Analyst y Revenue Analyst.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/federicoalmonacid)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Federico9420)

---
---

<a name="english"></a>

## 🇺🇸 English

### About this project

This project started with a real business question:

> *Can a fitness coaching business have growing revenue and a serious retention problem at the same time — without anyone noticing?*

The answer is yes. And this analysis proves it.

**FitCoach** is a digital fitness coaching business selling personalized training programs through Instagram and TikTok. Two products: a one-time Basic plan and a monthly Pro subscription. Stable revenue. Growing acquisition. Everything looks fine on the surface.

Underneath: a segment of Pro customers who renewed 2–3 times is silently starting to disappear. New TikTok customers fill the gap month by month. Revenue doesn't drop. But average CLV does — and nobody was watching.

This project is the analysis of that problem.

---

### The dataset

Synthetic dataset with realistic behavioral patterns, built to reflect real dynamics of digital coaching subscription businesses.

| Table | Records | Description |
|---|---|---|
| `customers` | 400 | Acquisition channel, sign-up date |
| `transactions` | 1,859 | Payments, renewals, plan type |
| `engagement` | 7,428 | Weekly activity: workouts, videos, messages |

**Period:** January 2023 — December 2024 (24 months)  
**Products:** Basic ($30 one-time) · Pro ($50 monthly renewal)  
**Channels:** Instagram · TikTok · Referral · Organic

Intentional patterns built into the dataset:

- 📉 **The TikTok effect:** the highest-volume channel has the lowest CLV ($61 vs $285 from Referral)
- ⚠️ **The pre-churn signal:** engagement drops 3 weeks before a customer stops renewing
- 🔴 **The silent segment:** Pro customers with 3–6 months tenure, still "active" in the system but showing abandonment behavior

---

### Analysis structure

The project follows an end-to-end professional methodology:

```
1. Dataset audit         →  validate before analyzing
2. Cohort analysis       →  monthly retention by acquisition cohort
3. RFM + Segmentation   →  segment customers by value and behavior
4. CLV by segment        →  quantify at-risk revenue in dollars
5. Pre-churn signals     →  identify the exact moment of disengagement
6. Insights + Solutions  →  business-oriented recommendations
```

---

### Tech stack

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

- **MySQL** — data audit, RFM with NTILE(5), cohorts, CLV, pre-churn signals
- **Power BI + DAX** — 4-page dashboard with cross-page slicers by channel
- **Python** — synthetic dataset generation with controlled behavioral patterns

---

### Key insight

> *"Revenue grew 40% over 24 months, but average CLV dropped 28%. A segment of 85 Pro customers with payment history is in a silent churn process. They represent $X in monthly recurring revenue. Retaining 30% through a proactive week-8 intervention adds $Y per month with zero new customer acquisition."*

---

### Project status

| Module | Status |
|---|---|
| Synthetic dataset | ✅ Complete |
| Project documentation | ✅ Complete |
| Dataset audit | 🔄 In progress |
| Cohort analysis | 🔄 In progress |
| RFM + Segmentation | 🔄 In progress |
| CLV by segment | 🔄 In progress |
| Pre-churn signals | ⏳ Pending |
| Power BI dashboard | ⏳ Pending |

---

### About me

**Federico Almonacid** — Jr Data Analyst | BI & CX Analytics  
Río Grande, Tierra del Fuego, Argentina

4+ years in retail management (team leadership, NPS, KPI tracking, performance analysis). Actively transitioning into BI Analyst, CX Analyst and Revenue Analyst roles.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/federicoalmonacid)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Federico9420)
