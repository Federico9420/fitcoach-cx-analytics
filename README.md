<!-- ═══════════════════════════════ ESPAÑOL ═══════════════════════════════ -->

# FitCoach — CX Analytics
### Cuando facturar más cada mes esconde un problema de fondo

> Un negocio de suscripción puede mostrar ingresos en alza y estar enfermo por dentro.
> Este proyecto toma un caso real de coaching fitness digital y responde una pregunta incómoda:
> **¿el negocio crece, o solo corre cada vez más rápido para quedarse en el mismo lugar?**

**Stack:** MySQL 8 · Power BI  |  **Período:** ene 2023 – dic 2024  |  **Base:** 400 clientes · 2.759 transacciones · 17.312 registros de engagement
**Enfoque:** de la pregunta de negocio → SQL → visualización → **recomendación**. No es un tablero: es una decisión.

---

## 1. El planteo inicial

**FitCoach** vende programas de entrenamiento en dos modalidades: **Basic** ($30, pago único) y **Pro** ($50/mes, renovación). El revenue mensual crece de forma sostenida y la dueña asume, razonablemente, que el negocio está sano.

La hipótesis de trabajo es que esa lectura de superficie es engañosa: **el revenue estable puede estar tapando una dependencia estructural de las altas nuevas.** Si cada mes entran suficientes clientes nuevos como para reemplazar a los que se van, el ingreso total no baja — pero el negocio se vuelve cada vez más dependiente de seguir comprando clientes.

### Las preguntas que el análisis debía responder

| # | Pregunta de negocio | Área |
|---|---------------------|------|
| 1 | ¿Qué porcentaje de clientes no renueva después del mes 3? | Churn |
| 2 | ¿Las cohortes recientes retienen mejor o peor que las anteriores? | Cohortes |
| 3 | ¿Qué segmento de clientes está en riesgo? | RFM |
| 4 | ¿Cuánto revenue recurrente está en juego? | CLV |
| 5 | ¿Hay señales de comportamiento que predicen el churn? | Pre-churn |
| 6 | ¿Qué canal de adquisición trae los clientes de mayor valor? | CLV por canal |
| 7 | Si retenemos el 30% de los clientes en riesgo, ¿cuánto ingreso adicional generamos? | Recomendación |

---

## 2. Lo que se hizo

**Auditoría de datos primero.** Antes de una sola query de análisis se corrió un control de calidad sobre las tres tablas: nulos en campos críticos, duplicados, coherencia de fechas, precios fuera de rango y referencias huérfanas. Resultado: dataset limpio (0 nulos críticos, 0 duplicados, 0 huérfanos, 0 transacciones previas a la adquisición). Único hallazgo: **diciembre 2024 truncado en la fuente** — documentado y aislado para que no contamine la lectura.

**Capa analítica en SQL (views).** Se construyó una capa de vistas reutilizables:
- **Cohortes y retención** — actividad de cada cliente por mes desde su primera compra.
- **RFM** — segmentación por Recency, Frequency y Monetary con `NTILE(5)`.
- **CLV** — valor acumulado por segmento y por canal.
- **Revenue en riesgo** — cuantificación del ingreso asociado al segmento En Riesgo.
- **Churn y pre-churn** — estado de cada cliente y comparación de engagement previo a la baja.

**Control de calidad del propio análisis.** Durante la revisión se detectó y corrigió un error de dirección en el `NTILE` del RFM (los scores estaban invertidos, etiquetando como "Campeones" a los peores clientes). El fix quedó documentado en el SQL.

**Visualización en Power BI.** Dashboard de cuatro páginas (visión general, cohortes, RFM, señales de churn) para consumo de la gerencia.

---

## 3. Resultados obtenidos

**El crecimiento es real… y frágil.**
- Revenue 2023: **$40.610** → 2024 (ene–nov): **$93.900** (**+131%**).
- Pero **69% de la base ya no está activa** al cierre del período, y **el 37–40% de los clientes paga una sola vez** y nunca vuelve.

**La retención cae temprano.**
- Retención agregada: **62%** (mes 1) → **52%** (mes 3) → **37%** (mes 6).
- **El 48% de los clientes no sigue activo pasado el mes 3.**

**La calidad no se deterioró en el tiempo — pero el valor por cliente sí baja.**
- Cohortes comparadas a la misma edad: **54% (2023) vs 52% (2024)** a mes 3. Retienen casi igual.
- El CLV promedio acumulado cae en las cohortes nuevas, pero por **composición** (los clientes nuevos tuvieron menos meses para acumular pagos), no por peor retención. *Distinguir esto es la diferencia entre un diagnóstico correcto y uno equivocado.*

**El canal explica casi todo.**

| Canal | CLV promedio | Retención mes 3 |
|-------|-------------:|----------------:|
| Referral | **$417** | 59% |
| Instagram | **$378** | 60% |
| Organic | $292 | 46% |
| TikTok | **$213** | **29%** |

Un cliente de Referral vale casi el doble que uno de TikTok y retiene el doble.

**No hay señal conductual de pre-churn.**
- Engagement en las 4 semanas previas a la baja: **7,4** (churned) vs **7,7** (activo). Sin diferencia relevante — verificado por nivel y por caída respecto a la línea base propia. El predictor real del churn es **el canal**, no el comportamiento.

**Segmentación (RFM):**

| Segmento | Clientes | % base | CLV | Frecuencia | Recency |
|----------|---------:|-------:|----:|-----------:|--------:|
| Campeón | 131 | 33% | $713 | 14 | 40 d |
| Leal | 29 | 7% | $736 | 15 | 56 d |
| Intermedio | 80 | 20% | $122 | 3 | 102 d |
| En Riesgo | 39 | 10% | $162 | 3 | 402 d |
| Hibernando | 121 | 30% | $35 | 1 | 474 d |

---

## 4. Respuesta a la gerencia comercial

> *Presentación ejecutiva del diagnóstico.*

**El negocio no está creciendo: está reponiendo.** El revenue sube, pero se sostiene sobre un flujo constante de altas nuevas que reemplaza a una base que se vacía (69% de churn, 4 de cada 10 clientes que pagan una sola vez). Mientras el canal de adquisición siga alimentando el embudo, los números de arriba se ven sanos. El día que ese flujo se enfríe, el problema aparece de golpe.

**El cuello de botella no es la retención en el tiempo: es la calidad de lo que compramos.** Las cohortes retienen parejo mes a mes; no hay un deterioro progresivo. Lo que hay es un canal —TikTok— que aporta volumen a la mitad de valor y la mitad de retención que Referral e Instagram. Estamos financiando crecimiento con el cliente más caro de mantener.

**La palanca no es "evitar que se vayan", es "dejar de traer a los que se van".** No existe una señal de comportamiento que nos permita anticipar el churn e intervenir a tiempo (lo verificamos y no está). Por lo tanto, la eficiencia se gana **antes** de la adquisición, eligiendo mejor el canal, no **después**, persiguiendo clientes que ya decidieron irse.

### Mis observaciones

1. **El indicador de superficie (revenue) y el indicador de salud (dependencia de altas) apuntan en direcciones opuestas.** Reportar solo el primero da una falsa sensación de control.
2. **"CLV promedio en caída" es cierto pero mal interpretable.** Buena parte de la caída es efecto de composición, no de deterioro. Comunicarlo sin ese matiz llevaría a perseguir un problema que no existe (la retención) y a ignorar el que sí existe (el mix de canal).
3. **El segmento "En Riesgo" es, en realidad, win-back.** Con recency promedio de 402 días, no son clientes a punto de irse: ya se fueron. La acción correcta es reactivación, no retención preventiva.

### Mis recomendaciones al negocio

1. **Reasignar la inversión de adquisición hacia Referral e Instagram.** Son los canales de mayor CLV y retención. A TikTok, o se le rediseña el onboarding para levantar su retención, o se lo trata como canal de awareness barato — no como fuente de suscriptores Pro.
2. **Formalizar un programa de referidos.** Referral ya es el mejor canal de forma orgánica; sistematizarlo (incentivo por referido que complete 3 meses) escala el mejor activo del negocio en vez del más barato.
3. **Campaña de win-back sobre el segmento En Riesgo.** Son 39 clientes = **$1.950/mes** de revenue recurrente. Recuperar el 30% son **$585/mes** ($7.020/año) sin adquirir un solo cliente nuevo.

---

## 5. Estructura del repositorio

```
fitcoach-cx-analytics/
├── README.md
├── sql/          cx_analytics.sql   — esquema + views (cohortes, RFM, CLV, churn, pre-churn)
├── data/         tablas raw + outputs de las views
├── reports/      FitCoach_CaseStudy_CX.pdf   — informe completo
├── charts/       gráficos del análisis
└── dashboard/    capturas Power BI + notas de medidas DAX
```

**Cómo reproducirlo:** cargar las tres tablas raw en MySQL 8 → correr `sql/cx_analytics.sql` → validar RFM con `SELECT r_score, ROUND(AVG(recency_dias)) FROM vw_rfm_scores GROUP BY r_score;` (r_score = 5 debe tener menos días) → conectar Power BI a las views.

**Notas de método:** dataset sintético con patrones realistas · fecha de referencia 2024-12-31 (diciembre truncado, excluido solo de la tendencia mensual) · RFM con `NTILE(5)`, 5 = mejor · CLV = revenue acumulado por cliente · todos los números provienen de las views SQL o de cálculo directo sobre las tres tablas.

<br>

<!-- ═══════════════════════════════ ENGLISH ═══════════════════════════════ -->

# FitCoach — CX Analytics
### When growing revenue hides a structural problem

> A subscription business can show rising revenue and still be sick underneath.
> This project takes a real digital fitness-coaching case and answers an uncomfortable question:
> **is the business growing, or just running faster to stay in the same place?**

**Stack:** MySQL 8 · Power BI  |  **Period:** Jan 2023 – Dec 2024  |  **Data:** 400 customers · 2,759 transactions · 17,312 engagement records
**Approach:** from business question → SQL → visualization → **recommendation**. Not a dashboard: a decision.

---

## 1. The initial framing

**FitCoach** sells training programs in two tiers: **Basic** ($30, one-off) and **Pro** ($50/month, recurring). Monthly revenue grows steadily and the owner reasonably assumes the business is healthy.

The working hypothesis is that this surface reading is misleading: **stable revenue may be masking a structural dependence on new sign-ups.** If enough new customers come in each month to replace those who leave, total revenue doesn't drop — but the business becomes increasingly dependent on continuing to buy customers.

### The questions the analysis had to answer

| # | Business question | Area |
|---|-------------------|------|
| 1 | What % of customers don't renew after month 3? | Churn |
| 2 | Do recent cohorts retain better or worse than older ones? | Cohorts |
| 3 | Which customer segment is at risk? | RFM |
| 4 | How much recurring revenue is at stake? | CLV |
| 5 | Are there behavioral signals that predict churn? | Pre-churn |
| 6 | Which acquisition channel brings the highest-value customers? | CLV by channel |
| 7 | If we retain 30% of at-risk customers, how much extra revenue? | Recommendation |

---

## 2. What was done

**Data audit first.** Before any analytical query, a quality check ran across all three tables: nulls in critical fields, duplicates, date coherence, out-of-range prices, and orphan references. Result: clean dataset (0 critical nulls, 0 duplicates, 0 orphans, 0 pre-acquisition transactions). One finding: **December 2024 is truncated in the source** — documented and isolated so it doesn't contaminate the reading.

**SQL analytical layer (views).** A reusable view layer was built:
- **Cohorts & retention** — each customer's activity by month since first purchase.
- **RFM** — Recency / Frequency / Monetary segmentation with `NTILE(5)`.
- **CLV** — accumulated value by segment and channel.
- **Revenue at risk** — quantified revenue tied to the At-Risk segment.
- **Churn & pre-churn** — customer state and pre-churn engagement comparison.

**QA on the analysis itself.** During review, a direction bug in the RFM `NTILE` was found and fixed (scores were inverted, labeling the worst customers as "Champions"). The fix is documented in the SQL.

**Power BI visualization.** A four-page dashboard (overview, cohorts, RFM, churn signals) for management consumption.

---

## 3. Results

**Growth is real… and fragile.**
- Revenue 2023: **$40,610** → 2024 (Jan–Nov): **$93,900** (**+131%**).
- But **69% of the base is no longer active** by period end, and **37–40% of customers pay only once** and never return.

**Retention drops early.**
- Blended retention: **62%** (month 1) → **52%** (month 3) → **37%** (month 6).
- **48% of customers are no longer active past month 3.**

**Quality didn't deteriorate over time — but value per customer does fall.**
- Cohorts at equal age: **54% (2023) vs 52% (2024)** at month 3. Nearly identical.
- Average accumulated CLV falls for newer cohorts, but by **composition** (newer customers had fewer months to accumulate payments), not worse retention. *Telling these apart is the difference between a correct diagnosis and a wrong one.*

**Channel explains almost everything.**

| Channel | Avg CLV | Month-3 retention |
|---------|--------:|------------------:|
| Referral | **$417** | 59% |
| Instagram | **$378** | 60% |
| Organic | $292 | 46% |
| TikTok | **$213** | **29%** |

A Referral customer is worth nearly twice a TikTok customer and retains twice as well.

**No behavioral pre-churn signal.**
- Engagement in the 4 weeks before churn: **7.4** (churned) vs **7.7** (active). No relevant difference — verified both by level and by drop against each customer's own baseline. The real churn predictor is **channel**, not behavior.

**Segmentation (RFM):**

| Segment | Customers | % base | CLV | Frequency | Recency |
|---------|----------:|-------:|----:|----------:|--------:|
| Champion | 131 | 33% | $713 | 14 | 40 d |
| Loyal | 29 | 7% | $736 | 15 | 56 d |
| Intermediate | 80 | 20% | $122 | 3 | 102 d |
| At Risk | 39 | 10% | $162 | 3 | 402 d |
| Hibernating | 121 | 30% | $35 | 1 | 474 d |

---

## 4. Response to commercial management

> *Executive presentation of the diagnosis.*

**The business isn't growing: it's replacing.** Revenue rises, but it stands on a constant inflow of new sign-ups replacing a base that is emptying out (69% churn, 4 in 10 customers paying once). As long as the acquisition channel keeps feeding the funnel, the top-line looks healthy. The day that inflow cools, the problem surfaces all at once.

**The bottleneck isn't retention over time: it's the quality of what we buy.** Cohorts retain evenly month over month; there's no progressive deterioration. What there is: one channel — TikTok — delivering volume at half the value and half the retention of Referral and Instagram. We're financing growth with the most expensive customer to keep.

**The lever isn't "stop them from leaving," it's "stop bringing in the ones who leave".** There is no behavioral signal that lets us anticipate churn and intervene in time (we checked; it isn't there). Efficiency is therefore won **before** acquisition, by choosing the channel better — not **after**, by chasing customers who already decided to leave.

### My observations

1. **The surface metric (revenue) and the health metric (dependence on new sign-ups) point in opposite directions.** Reporting only the first gives a false sense of control.
2. **"Falling average CLV" is true but easy to misread.** Much of the drop is a composition effect, not deterioration. Communicating it without that nuance would lead to chasing a non-problem (retention) and ignoring the real one (channel mix).
3. **The "At Risk" segment is really win-back.** With average recency of 402 days, these aren't customers about to leave: they already left. The right action is reactivation, not preventive retention.

### My recommendations to the business

1. **Reallocate acquisition spend toward Referral and Instagram.** Highest CLV and retention. TikTok either gets a redesigned onboarding to lift retention, or is treated as a cheap awareness channel — not a source of Pro subscribers.
2. **Formalize a referral program.** Referral is already the best channel organically; systematizing it (incentive per referral that completes 3 months) scales the best asset instead of the cheapest.
3. **Win-back campaign on the At-Risk segment.** 39 customers = **$1,950/month** of recurring revenue. Recovering 30% is **$585/month** ($7,020/year) with zero new acquisition.

---

## 5. Repository structure

```
fitcoach-cx-analytics/
├── README.md
├── sql/          cx_analytics.sql   — schema + views (cohorts, RFM, CLV, churn, pre-churn)
├── data/         raw tables + view outputs
├── reports/      FitCoach_CaseStudy_CX.pdf   — full report
├── charts/       analysis charts
└── dashboard/    Power BI screenshots + DAX measure notes
```

**How to reproduce:** load the three raw tables into MySQL 8 → run `sql/cx_analytics.sql` → validate RFM with `SELECT r_score, ROUND(AVG(recency_dias)) FROM vw_rfm_scores GROUP BY r_score;` (r_score = 5 must have fewer days) → connect Power BI to the views.

**Method notes:** synthetic dataset with realistic patterns · reference date 2024-12-31 (December truncated, excluded only from the monthly trend) · RFM with `NTILE(5)`, 5 = best · CLV = accumulated revenue per customer · all figures come from the SQL views or direct computation over the three tables.

---

*Federico Almonacid · 2026*
