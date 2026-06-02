# CineTrack 🎬

**App de seguimiento de películas y series con Persistencia Dual (SQL / NoSQL)**  
*FIS - EPN | Examen Práctico: Persistencia Dual en Móviles | Semestre 2026*

---

## Estructura del Proyecto (Real)

```
Examen01/
├── lib/
│   ├── main.dart                          # Entry point + Navegación
│   │
│   ├── core/
│   │   ├── logger/
│   │   │   └── app_logger.dart            # Logs estructurados
│   │   └── theme/
│   │       └── app_theme.dart             # Tema oscuro moderno
│   │
│   ├── domain/                            # Capa de dominio
│   │   ├── entities/
│   │   │   └── content_item.dart          # Entidad de contenido
│   │   └── repositories/
│   │       └── content_repository.dart    # Interfaz del repositorio
│   │
│   ├── data/                              # Capa de datos
│   │   ├── models/
│   │   │   └── content_model.dart         # Mapeo SQL/NoSQL
│   │   ├── datasources/
│   │   │   └── local/
│   │   │       ├── sql_datasource.dart    # SQLite (sqflite)
│   │   │       └── nosql_datasource.dart  # Hive
│   │   └── repositories/
│   │       └── content_repository_impl.dart # Lógica de persistencia dual
│   │
│   └── presentation/                      # Capa de UI
│       ├── providers/
│       │   └── content_provider.dart      # Estado global (Optimista)
│       ├── widgets/
│       │   ├── content_card.dart          # Tarjetas con soporte de assets/network
│       │   └── engine_switch_widget.dart  # Conmutador de motor
│       └── pages/
│           ├── home_page.dart             # UI Moderno: Hero, Continuar viendo y Filtros
│           ├── library_page.dart          # Listado completo
│           ├── favorites_page.dart        # Mis favoritos
│           ├── detail_page.dart           # Banner y detalles
│           └── add_edit_page.dart         # Formulario asíncrono
│
├── assets/
│   └── images/
│       └── default-movie.png              # Imagen de respaldo (placeholder)
│
├── test/
│   └── repository_test.dart               # Pruebas de persistencia
└── README.md
```

---

## Arquitectura y Mejoras Recientes

### UI Estilo Streaming
Se ha rediseñado la `HomePage` para ofrecer una experiencia de usuario superior:
- **Featured Hero**: Destaca automáticamente el último ítem añadido.
- **Continuar Viendo**: Fila dinámica que aparece solo cuando hay contenido en progreso.
- **Filtros Inteligentes (Chips)**: Permite explorar la biblioteca por categorías (Películas, Series, Favoritos) sin redundancia de datos.
- **Optimistic Updates**: La UI se actualiza instantáneamente antes de confirmar la persistencia en disco.

### Manejo de Imágenes
- Implementación de `CachedNetworkImage` para gestión eficiente de memoria y red.
- Sistema de fallback: Si falla el link de internet, se utiliza automáticamente el asset local `default-movie.png`.

### Persistencia Dual Real-Time
- **SQLite**: Para una estructura relacional robusta.
- **Hive**: Para una respuesta NoSQL ultrarrápida.
- El cambio de motor es instantáneo mediante el switch en el AppBar, manteniendo almacenes de datos totalmente independientes.

---

## Dependencias Principales

| Paquete | Uso |
|---|---|
| `sqflite` | Persistencia Relacional |
| `hive_flutter` | Persistencia NoSQL |
| `provider` | Gestión de estado |
| `cached_network_image` | Caché y optimización de posters |
| `flutter_rating_bar` | Calificación interactiva |

---

## Ejecución de Pruebas

```bash
flutter test test/repository_test.dart
```
