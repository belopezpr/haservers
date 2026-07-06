# Conceptos Generales de Alta Disponibilidad

---

## 📌 ¿Qué es Alta Disponibilidad?
La **Alta Disponibilidad (HA)** es la capacidad de un sistema para permanecer operativo y accesible durante la mayor parte del tiempo, incluso frente a fallos de hardware, software o red.  
Su objetivo principal es **minimizar el tiempo de inactividad** y garantizar la continuidad de los servicios críticos.

---

## ❌ ¿Qué no es Alta Disponibilidad?
- No significa que el sistema nunca falle.  
- No es lo mismo que un sistema **rápido** o **eficiente**.  
- No garantiza seguridad por sí mismo.  
- No implica necesariamente redundancia total.

---

## 📊 SLA, MTBF y MTRF
- **SLA (Service Level Agreement):** Acuerdo contractual que define el nivel de servicio esperado (ej. 99.9% de disponibilidad).  
- **MTBF (Mean Time Between Failures):** Tiempo promedio entre fallos de un sistema.  
- **MTTR (Mean Time To Repair):** Tiempo promedio para reparar un fallo y restaurar el servicio.

---

## 🔄 Diferencias Clave
- **Alta Disponibilidad (HA):** Redundancia y recuperación rápida.  
- **Tolerancia a Fallos (FT):** El sistema sigue funcionando sin interrupción aunque falle un componente.  
- **Balanceo de Carga (LB):** Distribución de tráfico entre múltiples servidores para mejorar rendimiento y disponibilidad.

---

## 💰 Costos de Alta Disponibilidad
Implementar HA implica:
- **CAPEX (Capital Expenditure):** Inversión inicial en hardware, software y licencias.  
- **OPEX (Operational Expenditure):** Costos operativos de mantenimiento, soporte y energía.  
- **ROI (Return on Investment):** Beneficio económico obtenido al reducir pérdidas por caídas de servicio.

---

## 📉 Matriz de Riesgos
La matriz de riesgos ayuda a evaluar la probabilidad e impacto de fallos:

| Riesgo                  | Probabilidad | Impacto | Mitigación |
|--------------------------|--------------|---------|------------|
| Fallo de hardware        | Alta         | Alto    | Redundancia, reemplazo rápido |
| Corte eléctrico          | Media        | Alto    | UPS, generadores |
| Error humano             | Alta         | Medio   | Capacitación, procedimientos |
| Ataque de seguridad      | Media        | Alto    | Firewalls, monitoreo |
| Fallo de red             | Baja         | Alto    | Rutas redundantes |

---

## 🌳 Árbol de Decisión
El árbol de decisión permite elegir la estrategia adecuada según el escenario:

¿El servicio es crítico?
├── Sí → ¿El presupuesto es alto?
│       ├── Sí → Implementar HA + FT + LB
│       └── No → HA básico con redundancia mínima
└── No → ¿Se requiere disponibilidad 24/7?
├── Sí → HA con balanceo de carga
└── No → Sistema estándar con backups


---

## 📌 Conclusión del módulo
Este módulo establece las bases conceptuales para comprender qué significa realmente **Alta Disponibilidad**, cómo se diferencia de otras estrategias, y qué factores económicos y técnicos deben evaluarse antes de implementar soluciones.

---
