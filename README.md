# Hotel Rarinco — PHP + MySQL

Sitio hotelero responsive desarrollado en PHP 8+, MySQL 5.7/8 y CSS, preparado para Apache/cPanel.

## Instalación

1. Crea una base de datos MySQL y un usuario con todos los permisos sobre ella.
2. El paquete incluye `config/config.php` con la conexión MySQL proporcionada.
3. Sube **todo el contenido del ZIP directamente a `public_html`**.
4. Abre `https://rarinco.gocreative.cl/install.php` y presiona **Instalar base de datos**. Como alternativa, importa `database/schema.sql` desde phpMyAdmin.
5. Abre `/admin/login`. El administrador inicial se crea durante la instalación.
6. Cambia la contraseña inicial después de comprobar el acceso.

## Estructura para cPanel

La raíz ya incluye `index.php`, por lo que el sitio se muestra directamente al entrar al dominio:

```text
public_html/
├── index.php
├── .htaccess
├── app/
├── config/
├── database/
├── public/
└── storage/
```

No debes subir solamente la carpeta `public`; sube todo el contenido del ZIP a `public_html`.

## Requisitos

- PHP 8.1 o superior con PDO MySQL.
- MySQL 5.7 o MySQL 8.
- Apache con `mod_rewrite` y soporte `.htaccess`.
- HTTPS recomendado.

## Módulos incluidos

- Inicio responsive con buscador de disponibilidad.
- Habitaciones, detalle, servicios, galería y contacto.
- Disponibilidad real por habitación y noche.
- Reserva con código único, huésped, fechas, total y medio de pago.
- Prevención de reservas dobles mediante índice único de habitación/fecha.
- Consulta pública de reserva.
- Solicitudes para empresas.
- Panel administrativo para revisar y cambiar estados.
- SEO técnico: metadatos, canonical, Open Graph y datos estructurados Hotel.
- Seguridad: PDO/prepared statements, CSRF, sesión segura y contraseñas con `password_hash`.

## Desarrollo local

Configura `app_url` como `http://localhost:8000` y ejecuta desde la raíz:

```bash
php -S localhost:8000 -t public
```
