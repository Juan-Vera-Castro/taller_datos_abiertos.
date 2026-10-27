# Taller Datos Abiertos — API Colombia

Aplicación Flutter que consume datos abiertos de **[API Colombia](https://api-colombia.com/)** y los presenta con un patrón **maestro‑detalle**: un dashboard con las categorías, un listado por categoría y una pantalla de detalle por registro.

- **API base:** `https://api-colombia.com/api/v1`
- **Documentación de la API:** <https://api-colombia.com/>
- **Paquetes clave:** [`http`](https://pub.dev/packages/http), [`go_router`](https://pub.dev/packages/go_router), [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv)

---

## Tabla de contenido

1. [Sobre API Colombia](#sobre-api-colombia)
2. [Endpoints consumidos](#endpoints-consumidos)
3. [Ejemplo de respuesta JSON](#ejemplo-de-respuesta-json)
4. [Arquitectura](#arquitectura)
5. [Estructura de carpetas](#estructura-de-carpetas)
6. [Rutas con go_router](#rutas-con-go_router)
7. [Estados de la interfaz](#estados-de-la-interfaz)
8. [Capturas de pantalla](#capturas-de-pantalla)
9. [Cómo ejecutar el proyecto](#cómo-ejecutar-el-proyecto)
10. [Pruebas](#pruebas)
11. [Decisiones técnicas y limitaciones conocidas](#decisiones-técnicas-y-limitaciones-conocidas)
12. [Flujo de trabajo en Git](#flujo-de-trabajo-en-git)

---

## Sobre API Colombia

API Colombia es una API REST pública y gratuita, sin autenticación, que expone información general de Colombia: departamentos, ciudades, regiones, presidentes, atractivos turísticos, gastronomía, áreas naturales, aeropuertos, entre otros. Todas las respuestas son JSON en UTF‑8.

## Endpoints consumidos

| # | Endpoint | Qué contiene | Listado (`GET`) | Detalle (`GET`) |
|---|----------|--------------|-----------------|-----------------|
| 1 | **Department** | Los departamentos de Colombia: descripción, población, superficie, número de municipios, indicativo telefónico y ciudad capital. | `/Department` | `/Department/{id}` |
| 2 | **President** | Presidentes de Colombia: foto, nombre, periodo de gobierno, partido político y biografía. | `/President` | `/President/{id}` |
| 3 | **TouristicAttraction** | Atractivos turísticos: descripción, imágenes, coordenadas y ciudad. | `/TouristicAttraction` | `/TouristicAttraction/{id}` |
| 4 | **TypicalDish** | Platos típicos: descripción, ingredientes, imagen y departamento de origen. | `/TypicalDish` | `/TypicalDish/{id}` |

## Ejemplo de respuesta JSON

`GET https://api-colombia.com/api/v1/President/3`

```json
{
  "id": 3,
  "image": "https://upload.wikimedia.org/wikipedia/commons/d/db/Rafael_Nunez.JPG",
  "name": "Rafael",
  "lastName": "Nuñez Moledo",
  "startPeriodDate": "1887-06-04",
  "endPeriodDate": "1888-08-07",
  "politicalParty": "Partido nacional",
  "description": "Rafael Wenceslao Núñez Moledo (Cartagena, 28 de septiembre de 1825-Ib., 18 de septiembre de 1894) fue un abogado, periodista, escritor, político y militar colombiano, antiguo miembro del Partido Liberal Colombiano y luego líder del Partido Nacional. (…)",
  "cityId": 210,
  "city": {
    "id": 210,
    "name": "Cartagena",
    "description": "Cartagena de Indias, oficialmente Distrito Turístico y Cultural de Cartagena de Indias (…)",
    "surface": 609,
    "population": 1028736,
    "postalCode": "130000",
    "departmentId": 6,
    "department": null,
    "touristAttractions": null,
    "presidents": [null],
    "indigenousReservations": null,
    "airports": null,
    "radios": null,
    "urbanCenters": null,
    "higherEducationInstitutions": null,
    "televisionChannels": null
  }
}
```

> Las descripciones se recortaron con `(…)` para este ejemplo. `GET /President` devuelve un arreglo de objetos con la misma forma, pero con `"city": null`. Cuando el periodo sigue vigente, `endPeriodDate` llega en `null` y la app muestra **"Actualidad"**.

El modelo [`President`](lib/models/president.dart) convierte ese JSON así:

```dart
final president = President.fromJson(json);
president.fullName; // "Rafael Nuñez Moledo"
president.toJson(); // vuelve a Map<String, dynamic>
```

---

## Arquitectura

La aplicación está organizada por **capas**. Cada capa solo conoce a la que está debajo:

```
┌──────────────────────────────────────────────────────────────┐
│ views/    Pantallas (Dashboard, Listado, Detalle)            │
│ widgets/  Componentes reutilizables (cards, loader, error)   │
├──────────────────────────────────────────────────────────────┤
│ routes/   go_router: rutas nombradas y parámetro :id         │
├──────────────────────────────────────────────────────────────┤
│ services/ Un servicio por endpoint → ApiClient (paquete http)│
├──────────────────────────────────────────────────────────────┤
│ models/   Clases con fromJson / toJson                       │
├──────────────────────────────────────────────────────────────┤
│ config/   Variables del .env (flutter_dotenv) y secciones    │
│ themes/   Colores y ThemeData claro / oscuro                 │
└──────────────────────────────────────────────────────────────┘
```

**Flujo de una petición** (por ejemplo, al abrir el detalle de un presidente):

1. El usuario toca un elemento del listado → `context.goNamed('president-detail', pathParameters: {'id': '3'})`.
2. `go_router` resuelve `/presidents/3`, convierte `id` a `int` y construye `PresidentDetailView(id: 3)`.
3. La vista usa `AsyncStateBuilder`, que llama a `PresidentService.getById(3)`.
4. `ApiClient` arma la URL con `API_BASE_URL` del `.env`, hace `GET /President/3` con el paquete `http`, decodifica el cuerpo en UTF‑8 y traduce cualquier fallo a `ApiException`.
5. `President.fromJson` convierte el JSON en un objeto.
6. `AsyncStateBuilder` pinta el estado correspondiente: cargando, error con "Reintentar" o los datos.

## Estructura de carpetas

```
.
├── .env                         # API_BASE_URL y API_TIMEOUT_SECONDS
├── .env.example                 # Plantilla del .env
├── pubspec.yaml                 # Dependencias y registro del .env como asset
├── lib/
│   ├── main.dart                # Carga el .env, aplica el tema y monta el router
│   ├── config/
│   │   ├── env_config.dart      # Lectura tipada del .env (con valores por defecto)
│   │   └── app_sections.dart    # Las 4 secciones del dashboard (título, icono, ruta)
│   ├── models/
│   │   ├── city.dart            # Ciudad (anidada en Department y TouristicAttraction)
│   │   ├── department.dart
│   │   ├── president.dart
│   │   ├── touristic_attraction.dart
│   │   ├── typical_dish.dart
│   │   └── models.dart          # Exporta todos los modelos
│   ├── routes/
│   │   ├── app_routes.dart      # Nombres de ruta, paths y helpers
│   │   └── app_router.dart      # Configuración global de GoRouter
│   ├── services/
│   │   ├── api_client.dart      # GET genérico: timeout, UTF‑8 y manejo de errores
│   │   ├── api_exception.dart   # Error con mensaje listo para el usuario
│   │   ├── department_service.dart
│   │   ├── president_service.dart
│   │   ├── touristic_attraction_service.dart
│   │   ├── typical_dish_service.dart
│   │   └── services.dart        # Exporta todos los servicios
│   ├── themes/
│   │   ├── app_colors.dart      # Paleta (amarillo, azul y rojo de la bandera)
│   │   └── app_theme.dart       # ThemeData Material 3 claro y oscuro
│   ├── views/
│   │   ├── dashboard_view.dart  # Home con las 4 cards
│   │   ├── resource_list_view.dart  # Listado genérico (ListView.builder + búsqueda)
│   │   ├── not_found_view.dart  # Rutas o ids inválidos
│   │   ├── departments/         # department_list_view.dart, department_detail_view.dart
│   │   ├── presidents/          # president_list_view.dart, president_detail_view.dart
│   │   ├── attractions/         # attraction_list_view.dart, attraction_detail_view.dart
│   │   └── dishes/              # dish_list_view.dart, dish_detail_view.dart
│   └── widgets/
│       ├── async_state_builder.dart # Estados cargando / error / éxito
│       ├── loader.dart          # CircularProgressIndicator y skeleton de listado
│       ├── error_view.dart      # Mensaje de error + "Reintentar" y vista vacía
│       ├── section_card.dart    # Card del dashboard
│       ├── resource_tile.dart   # Elemento de listado
│       ├── app_network_image.dart   # Imagen remota con URLs de respaldo
│       ├── detail_widgets.dart  # InfoTile, InfoGrid, títulos de sección
│       └── formatters.dart      # Números (6.887.306) y fechas (4 jun 1887)
└── test/
    ├── models_test.dart
    ├── services_test.dart
    ├── router_test.dart
    └── views_test.dart
```

> El `.env` se ubica en la **raíz** del proyecto, porque `flutter_dotenv` lo carga como asset declarado en `pubspec.yaml`. Su lectura se centraliza en `lib/config/env_config.dart`.

---

## Rutas con go_router

La configuración está en [`lib/routes/app_router.dart`](lib/routes/app_router.dart) y los nombres en [`lib/routes/app_routes.dart`](lib/routes/app_routes.dart). Los listados son rutas hijas de `/` y cada detalle es ruta hija de su listado. Así, el botón **atrás** del detalle vuelve al listado, y el del listado vuelve al dashboard.

| Nombre (`name`) | Path | Parámetros | Pantalla | Endpoint consumido |
|-----------------|------|------------|----------|--------------------|
| `home` | `/` | — | `DashboardView` | — |
| `departments` | `/departments` | — | `DepartmentListView` | `GET /Department` |
| `department-detail` | `/departments/:id` | `id` (path, entero) | `DepartmentDetailView` | `GET /Department/{id}` |
| `presidents` | `/presidents` | — | `PresidentListView` | `GET /President` |
| `president-detail` | `/presidents/:id` | `id` (path, entero) | `PresidentDetailView` | `GET /President/{id}` |
| `attractions` | `/attractions` | — | `AttractionListView` | `GET /TouristicAttraction` |
| `attraction-detail` | `/attractions/:id` | `id` (path, entero) | `AttractionDetailView` | `GET /TouristicAttraction/{id}` |
| `dishes` | `/dishes` | — | `DishListView` | `GET /TypicalDish` |
| `dish-detail` | `/dishes/:id` | `id` (path, entero) | `DishDetailView` | `GET /TypicalDish/{id}` |
| *(errorBuilder)* | cualquier otra | — | `NotFoundView` | — |

**Paso de parámetros.** El listado navega por nombre y envía el `id` como parámetro de ruta:

```dart
context.goNamed(
  AppRoutes.presidentDetail,                 // 'president-detail'
  pathParameters: {AppRoutes.idParam: '3'},  // → /presidents/3
);
```

El router lo lee y lo valida antes de construir la pantalla:

```dart
GoRoute(
  path: ':id',
  name: detailName,
  builder: (context, state) {
    final id = int.tryParse(state.pathParameters['id'] ?? '');
    if (id == null) return const NotFoundView(message: 'El identificador del registro no es válido.');
    return detail(id);   // p. ej. PresidentDetailView(id: id)
  },
),
```

Solo se envía el `id` por la ruta (no el objeto completo con `extra`), y la vista de detalle consulta `GET /{Endpoint}/{id}`. Así, una URL como `/presidents/3` funciona aunque se abra directamente, por ejemplo al recargar en web o desde un enlace profundo. Además, el detalle muestra los datos completos que devuelve la API para ese registro.

## Estados de la interfaz

Todas las pantallas que consultan la API usan [`AsyncStateBuilder`](lib/widgets/async_state_builder.dart), que maneja de forma explícita tres estados:

| Estado | Listado | Detalle |
|--------|---------|---------|
| **Cargando** | `ListSkeleton`: filas grises animadas con la forma de la lista | `Loader`: `CircularProgressIndicator` + "Cargando…" |
| **Éxito** | `ListView.builder` con buscador (ignora tildes), contador y *pull‑to‑refresh* | Información completa del registro |
| **Error** | `ErrorView`: mensaje claro + botón **Reintentar** | `ErrorView`: mensaje claro + botón **Reintentar** |

Mensajes de error que puede ver el usuario (definidos en [`ApiClient`](lib/services/api_client.dart)):

- *"No fue posible conectar con API Colombia. Revisa tu conexión a internet."* — sin red.
- *"El servidor tardó demasiado en responder. Intenta de nuevo."* — se superó `API_TIMEOUT_SECONDS`.
- *"El registro solicitado no existe."* — HTTP 404.
- *"API Colombia respondió con un error (500)."* — otros códigos HTTP.
- *"La respuesta no tiene el formato esperado."* / *"No se pudo interpretar la respuesta."* — JSON inválido.

---

## Capturas de pantalla

> **Pendiente:** reemplazar cada imagen guardando la captura con el nombre indicado en [`docs/screenshots/`](docs/screenshots/).

| Dashboard | Listado | Detalle |
|:---:|:---:|:---:|
| ![Dashboard con las 4 categorías](docs/screenshots/01_dashboard.png) | ![Listado de presidentes](docs/screenshots/02_listado.png) | ![Detalle de un presidente](docs/screenshots/03_detalle.png) |
| `01_dashboard.png` | `02_listado.png` | `03_detalle.png` |

| Estado: cargando | Estado: error | Búsqueda en listado |
|:---:|:---:|:---:|
| ![Skeleton mientras carga el listado](docs/screenshots/04_cargando.png) | ![Mensaje de error con botón Reintentar](docs/screenshots/05_error.png) | ![Listado filtrado por búsqueda](docs/screenshots/06_busqueda.png) |
| `04_cargando.png` | `05_error.png` | `06_busqueda.png` |

| Detalle departamento | Detalle atractivo turístico | Detalle plato típico |
|:---:|:---:|:---:|
| ![Detalle de un departamento](docs/screenshots/07_detalle_departamento.png) | ![Detalle de un atractivo turístico](docs/screenshots/08_detalle_atractivo.png) | ![Detalle de un plato típico](docs/screenshots/09_detalle_plato.png) |
| `07_detalle_departamento.png` | `08_detalle_atractivo.png` | `09_detalle_plato.png` |

*Para capturar el estado de error:* desactiva el Wi‑Fi o los datos y abre cualquier listado; luego vuelve a activarlos y pulsa **Reintentar**.

---

## Cómo ejecutar el proyecto

**Requisitos:** Flutter estable con Dart `^3.13.3` (el proyecto se desarrolló con Flutter 3.47.4) y un emulador Android, un dispositivo físico, Chrome o Windows de escritorio.

```bash
# 1. Clonar (el repositorio se llama "taller_datos_abiertos." con punto final)
git clone https://github.com/Juan-Vera-Castro/taller_datos_abiertos..git
cd taller_datos_abiertos.
git checkout feature/taller_api_colombia

# 2. Instalar dependencias
flutter pub get

# 3. (Opcional) revisar variables de entorno
cat .env

# 4. Ejecutar
flutter run                 # elige el dispositivo
flutter run -d windows      # escritorio Windows
flutter run -d chrome       # web
```

**Variables de entorno** (`.env`):

| Variable | Valor por defecto | Uso |
|----------|-------------------|-----|
| `API_BASE_URL` | `https://api-colombia.com/api/v1` | URL base de todas las peticiones |
| `API_TIMEOUT_SECONDS` | `15` | Tiempo máximo de espera por petición |

El `.env` está versionado a propósito porque solo contiene la URL pública de la API, sin credenciales. Si en el futuro se agregan secretos, se debe añadir `.env` a `.gitignore` y conservar solo `.env.example`.

## Pruebas

```bash
flutter analyze   # análisis estático (sin problemas)
flutter test      # 31 pruebas
```

| Archivo | Qué verifica |
|---------|--------------|
| `test/models_test.dart` | `fromJson`/`toJson` de los 4 modelos, campos nulos y objetos anidados |
| `test/services_test.dart` | URLs de cada endpoint, decodificación UTF‑8 y errores 404, 500, red, timeout y formato (con `MockClient`) |
| `test/router_test.dart` | Las 9 rutas, el paso del parámetro `id`, ids no numéricos y rutas desconocidas |
| `test/views_test.dart` | Estados cargando / error / éxito, botón Reintentar, búsqueda, detalle por id, navegación desde el dashboard, URLs de imágenes y formatos |

---

## Decisiones técnicas y limitaciones conocidas

- **Modelos tolerantes a nulos.** La API envía en `null` campos como `endPeriodDate`, `surface`, `population` o `postalCode`. Los modelos los declaran opcionales y la interfaz muestra "Sin dato". Las relaciones que la API siempre devuelve en `null` (`region`, `airports`, `maps`, etc.) no se modelan.
- **UTF‑8 explícito.** `ApiClient` decodifica `response.bodyBytes` con `utf8`, sin depender de la cabecera `charset`, para que tildes y eñes se muestren bien.
- **Imágenes de Wikimedia.** Wikimedia solo sirve miniaturas en anchos estándar, y varias URLs de la API piden anchos no permitidos (p. ej. `800px`), lo que produce un error 400. [`AppNetworkImage`](lib/widgets/app_network_image.dart) reescribe la miniatura a un ancho válido (330 px en listados, 960 px en detalle), prueba la imagen original como respaldo y envía un `User-Agent` identificable, como pide la política de Wikimedia. Si ninguna URL funciona, muestra un icono.
- **Datos incompletos en la API.** Algunos atractivos turísticos tienen imágenes que ya no existen (HTTP 404), y dos registros traen un texto en lugar de una URL. En esos casos se muestra el icono de respaldo.
- **Detalle por id.** El detalle siempre consulta `/{Endpoint}/{id}` (ver [Rutas](#rutas-con-go_router)). Esto implica una petición adicional, pero hace que las rutas sean independientes y enlazables.

## Flujo de trabajo en Git

- Ramas: `main` → `dev` → `feature/taller_api_colombia` (todo el desarrollo está en la rama *feature*).
- Commits atómicos con [Conventional Commits](https://www.conventionalcommits.org/es/v1.0.0/): `feat:`, `fix:`, `test:`, `docs:`, `chore:`.

---

**Autor:** [Juan-Vera-Castro](https://github.com/Juan-Vera-Castro) · Datos: [API Colombia](https://api-colombia.com/)
