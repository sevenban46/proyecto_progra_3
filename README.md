# calculadora_financiera

Una aplicación móvil para realizar cálculos financieros con persistencia de datos local, implementando el patrón MVC y operaciones CRUD.

## Getting Started
Características principales
🏦 Cálculos financieros:

Interés simple y compuesto

Valor futuro de inversiones

Cálculo de anualidades para préstamos

💾 Persistencia de datos con SQLite

🔄 Operaciones CRUD completas

🏗️ Arquitectura MVC bien definida

📱 Interfaz intuitiva y fácil de usar

Tecnologías utilizadas
Flutter - Framework para desarrollo multiplataforma

SQLite - Base de datos local

sqflite - Plugin para integración con SQLite

MVC - Patrón de diseño Modelo-Vista-Controlador

Estructura del proyecto
lib/
├── controllers/          # Lógica de la aplicación
│   └── financial_controller.dart
├── models/               # Modelos de datos
│   └── financial_operation.dart
├── repositories/         # Conexión con la base de datos
│   └── database_helper.dart
├── views/                # Interfaces de usuario
│   ├── operation_list.dart
│   └── operation_detail.dart
└── main.dart             # Punto de entrada

Instalación
Clona el repositorio:

git clone https://github.com/tu-usuario/calculadora-financiera.git
Navega al directorio del proyecto:


cd calculadora-financiera
Instala las dependencias:

flutter pub get
Ejecuta la aplicación:


flutter run

Uso de la aplicación
Pantalla principal
Lista todas las operaciones financieras almacenadas

Permite:

Ver detalles de cada operación

Editar operaciones existentes

Eliminar operaciones

Agregar nuevas operaciones

Pantalla de detalle
Formulario para crear/editar operaciones financieras

Campos:

Tipo de operación (Inversión/Préstamo)

Descripción

Monto principal

Tasa de interés (%)

Período (años)

Tipo de cálculo (Simple/Compuesto)

Fecha

Visualización de resultados
Muestra los resultados de los cálculos:

Interés simple

Interés compuesto

Valor futuro

Pago de anualidad (para préstamos)

Dependencias
Las dependencias utilizadas en este proyecto son:

sqflite: ^2.3.0 - Para operaciones con SQLite

path_provider: ^2.1.1 - Para manejo de rutas de archivos

intl: ^0.18.1 - Para internacionalización y formato de fechas

fluttertoast: ^8.2.2 - Para mostrar notificaciones toast


# proyecto_progra_3
