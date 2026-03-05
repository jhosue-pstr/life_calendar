# Life Calendar - Documento de Requisitos del Producto (PRD)

## 1. Visión General del Proyecto

**Nombre del Proyecto:** Life Calendar  
**Tipo:** Aplicación Móvil y Escritorio (Flutter) con Backend API REST  
**Funcionalidad Principal:** Un rastreador de productividad personal que ayuda a los usuarios a monitorear actividades diarias, metas personalizadas y malos hábitos a través de una grille de contribución anual similar a GitHub.  
**Usuarios Objetivo:** Personas que buscan rastrear sus hábitos diarios, productividad y crecimiento personal.

---

## 2. Declaracion del Problema

Los usuarios necesitan una herramienta unificada para:

- Rastrear actividades y tareas diarias
- Establecer y monitorear metas de duración personalizada (7-90 días)
- Combatir malos hábitos rastreando días sin recaídas
- Visualizar su productividad a lo largo del tiempo a través de una grille de contribución anual

---

## 3. Visión del Producto

Life Calendar es una aplicación multiplataforma que combina:

- Visualización de contribución estilo GitHub
- Gestión de Tareas/Actividades
- Seguimiento de metas con duración personalizable
- Rastreo de rachas de malos hábitos

Todos los datos se persisten en una base de datos PostgreSQL con autenticación JWT.

---

## 4. Historias de Usuario

| ID   | Historia de Usuario                                                                        | Prioridad |
| ---- | ----------------------------------------------------------------------------------------- | -------- |
| US01 | Como usuario, quiero registrarme e iniciar sesión para que mis datos sean seguros         | Debe     |
| US02 | Como usuario, quiero agregar actividades diarias para rastrear lo que hago               | Debe     |
| US03 | Como usuario, quiero marcar actividades como hechas para ver mi progreso                | Debe     |
| US04 | Como usuario, quiero crear metas personalizadas (7-90 días) para rastrear objetivos a largo plazo | Debe     |
| US05 | Como usuario, quiero marcar los días de meta como completados para ver mi progreso      | Debe     |
| US06 | Como usuario, quiero agregar malos hábitos para rastrear mis rachas                      | Debe     |
| US07 | Como usuario, quiero activar una "recaída" cuando fallo un mal hábito para reiniciar mi racha | Debe     |
| US08 | Como usuario, quiero ver una grille de contribución anual para visualizar mi productividad | Debe     |
| US09 | Como usuario, quiero que mi sesión persista para no tener que iniciar sesión cada vez   | Debe     |

---

## 5. Requisitos Funcionales

### 5.1 Autenticación

- Registro de usuario (email, contraseña, nickname)
- Inicio de sesión con token JWT
- Sesión persistente usando SharedPreferences
- Funcionalidad de cierre de sesión

### 5.2 Actividades

- Crear actividades diarias con título
- Marcar actividades como hecho/no hecho
- Eliminar actividades
- Filtrar actividades por fecha
- Actualizar automáticamente el nivel de contribución al cambiar

### 5.3 Metas

- Crear metas con duración personalizada (1-90 días)
- Establecer título de la meta
- Alternar días de meta como completados
- Ver metas activas
- Eliminar metas
- Puede haber múltiples metas activas simultáneamente

### 5.4 Malos Hábitos

- Crear malos hábitos para rastrear
- Ver racha actual
- Ver la racha más larga lograda
- Activar recaída (reinicia la racha a 0)
- Incrementar racha manualmente
- Eliminar malos hábitos
- Actualizar automáticamente el nivel de contribución al recaer/incrementar

### 5.5 Grille de Contribución

- Vista de calendario anual (Ene-Dic)
- Niveles codificados por colores (0-4):
  - Nivel 0: 0 actividades
  - Nivel 1: 1-2 actividades
  - Nivel 2: 3-4 actividades
  - Nivel 3: 5-6 actividades
  - Nivel 4: 7+ actividades
- Bonus: Cada mal hábito sin recaída añade +1 nivel (máximo 2 de bonus)
- Hoy resaltado con borde

---

## 6. Arquitectura Técnica

### 6.1 Frontend (Flutter)

```
Frontend/
├── lib/
│   ├── main.dart                 # Entry de la app, configuración de providers
│   ├── calendar_page.dart        # Dashboard principal
│   ├── models/                   # Modelos de datos
│   │   ├── user.dart
│   │   ├── activity.dart
│   │   ├── goal.dart
│   │   ├── bad_habit.dart
│   │   └── contribution.dart
│   ├── services/                 # Comunicación con API
│   │   ├── api_client.dart       # Cliente HTTP Dio
│   │   ├── auth_service.dart
│   │   ├── activity_service.dart
│   │   ├── goal_service.dart
│   │   ├── bad_habit_service.dart
│   │   └── contribution_service.dart
│   ├── providers/               # Gestión de estado
│   │   ├── auth_provider.dart
│   │   ├── activity_provider.dart
│   │   ├── goal_provider.dart
│   │   ├── bad_habit_provider.dart
│   │   └── contribution_provider.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── widgets/
│       ├── contribution_grid.dart
│       ├── activities_section.dart
│       ├── goals_section.dart
│       └── bad_habits_section.dart
```

**Stack Tecnológico:**

- Flutter 3.x
- Provider (gestión de estado)
- Dio (cliente HTTP)
- SharedPreferences (almacenamiento local)

### 6.2 Backend (FastAPI)

```
Backend/
├── app/
│   ├── main.py                   # App FastAPI
│   ├── config.py                 # Configuración
│   ├── database.py               # Configuración SQLAlchemy
│   ├── models/                   # Modelos de base de datos
│   │   ├── user.py
│   │   ├── activity.py
│   │   ├── goal.py
│   │   ├── bad_habit.py
│   │   └── contribution.py
│   ├── schemas/                  # Modelos Pydantic
│   ├── routers/                 # Endpoints de API
│   │   ├── auth.py
│   │   ├── activities.py
│   │   ├── goals.py
│   │   ├── bad_habits.py
│   │   └── contributions.py
│   └── utils/
│       ├── auth.py               # Utilidades JWT
│       ├── contributions.py      # Cálculo de contribución
├── requirements.txt
└── .env
```

**Stack Tecnológico:**

- FastAPI (Python 3.12)
- SQLAlchemy (ORM)
- PostgreSQL (Base de datos)
- Pydantic (Validación de datos)
- python-jose (JWT)
- passlib + bcrypt (Hash de contraseñas)

---

## 7. Esquema de Base de Datos

### Tablas

| Tabla          | Columnas                                                                      | Descripción              |
| -------------- | ----------------------------------------------------------------------------- | ---------------------- |
| `users`        | id, email, password_hash, nickname, created_at                                | Cuentas de usuario     |
| `activities`   | id, user_id, title, is_done, date, created_at                               | Tareas diarias          |
| `goals`        | id, user_id, title, target_days, start_date, is_active, created_at           | Metas personalizadas   |
| `goal_days`    | id, goal_id, day_number, is_completed, completed_at                          | Seguimiento de días    |
| `bad_habits`   | id, user_id, name, current_streak, longest_streak, last_relapse_date, created_at | Seguimiento de hábitos |
| `contributions`| id, user_id, date, level                                                     | Datos de contribución anual |

---

## 8. Endpoints de API

### Autenticación

| Método | Endpoint         | Descripción              |
| ------ | ---------------- | ---------------------- |
| POST   | `/auth/register` | Registrar nuevo usuario |
| POST   | `/auth/login`    | Iniciar sesión (retorna JWT) |
| GET    | `/auth/me`       | Obtener usuario actual |

### Actividades

| Método | Endpoint           | Descripción                           |
| ------ | ------------------ | ------------------------------------- |
| GET    | `/activities`      | Listar actividades (filtro: fecha)   |
| POST   | `/activities`      | Crear actividad                       |
| PUT    | `/activities/{id}` | Actualizar actividad                  |
| DELETE | `/activities/{id}` | Eliminar actividad                   |

### Metas

| Método | Endpoint           | Descripción                      |
| ------ | ------------------ | -------------------------------- |
| GET    | `/goals`           | Listar metas (filtro: solo activas) |
| POST   | `/goals`           | Crear meta                       |
| PUT    | `/goals/{id}`      | Actualizar meta                  |
| PATCH  | `/goals/{id}/days` | Alternar día de meta             |
| DELETE | `/goals/{id}`      | Eliminar meta                    |

### Malos Hábitos

| Método | Endpoint                     | Descripción           |
| ------ | ---------------------------- | -------------------- |
| GET    | `/bad-habits`                | Listar malos hábitos |
| POST   | `/bad-habits`                | Crear mal hábito     |
| PUT    | `/bad-habits/{id}`           | Actualizar mal hábito|
| POST   | `/bad-habits/{id}/relapse`   | Activar recaída      |
| POST   | `/bad-habits/{id}/increment` | Incrementar racha    |
| DELETE | `/bad-habits/{id}`           | Eliminar mal hábito  |

### Contribuciones

| Método | Endpoint                     | Descripción                      |
| ------ | ---------------------------- | -------------------------------- |
| GET    | `/contributions`             | Listar contribuciones (filtro: año) |
| GET    | `/contributions/year/{year}` | Obtener contribuciones del año  |

---

## 9. Diseño UI/UX

### Tema

- **Modo:** Modo oscuro y claro (sistema)
- **Color Principal:** Púrpura (Material Design 3 seed)
- **Colores de Acento:**
  - Verde (metas, actividades)
  - Rojo (malos hábitos)

### Diseño

- **Escritorio:** Diseño de dos columnas
  - Izquierda: Grille de contribución anual
  - Derecha: Actividades, Metas, Malos Hábitos
- **Móvil:** Columna simple con scroll

### Pantallas Clave

1. **Pantalla de Login** - Formulario de email + contraseña
2. **Pantalla de Registro** - Formulario de email + contraseña + nickname
3. **Home/Calendar** - Dashboard principal con todas las funcionalidades

---

## 10. Requisitos No Funcionales

- **Rendimiento:** Respuestas de API < 500ms
- **Seguridad:** Tokens JWT con expiración de 30 minutos
- **Compatibilidad:** Android, iOS, Web, Escritorio (Flutter)
- **Persistencia de Datos:** Todos los datos almacenados en PostgreSQL

---

## 11. Mejoras Futuras (Fuera del Alcance)

- [ ] Categorías/etiquetas de actividades
- [ ] Plantillas de metas
- [ ] Estadísticas y análisis
- [ ] Exportar datos (CSV/JSON)
- [ ] NotificacionesRecordatorios
- [ ] Soporte multiidioma
- [ ] Alternar tema oscuro/claro
- [ ] Sincronización en la nube
- [ ] Funciones sociales

---

## 12. Hitos

| Hito | Descripción                         | Estado      |
| ---- | ----------------------------------- | ----------- |
| M1   | Configuración de Backend + Base de datos | ✅ Completo |
| M2   | Autenticación (JWT)                 | ✅ Completo |
| M3   | CRUD de Actividades                 | ✅ Completo |
| M4   | CRUD de Metas                       | ✅ Completo |
| M5   | CRUD de Malos Hábitos + Rachas     | ✅ Completo |
| M6   | Grille de Contribuciones + Cálculo automático | ✅ Completo |
| M7   | Integración de Frontend             | ✅ Completo |
| M8   | Pantallas de Login/Registro         | ✅ Completo |
| M9   | Mejora de UI con Material Design 3 | ✅ Completo |

---

**Versión del Documento:** 1.1  
**Última Actualización:** 4 de Marzo de 2026  
**Autor:** Ezquiz0 (JhosueP)
