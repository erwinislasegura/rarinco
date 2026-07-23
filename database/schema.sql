SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE IF NOT EXISTS users (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(120) NOT NULL, email VARCHAR(190) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL, role VARCHAR(30) NOT NULL DEFAULT 'admin', active TINYINT(1) NOT NULL DEFAULT 1,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS room_types (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, slug VARCHAR(100) NOT NULL UNIQUE, name VARCHAR(140) NOT NULL,
 short_description VARCHAR(255) NOT NULL, description TEXT NOT NULL, capacity TINYINT UNSIGNED NOT NULL,
 beds VARCHAR(120) NOT NULL, size_m2 SMALLINT UNSIGNED NULL, base_price INT UNSIGNED NOT NULL,
 currency CHAR(3) NOT NULL DEFAULT 'CLP', image VARCHAR(190) NOT NULL, active TINYINT(1) NOT NULL DEFAULT 1,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rooms (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, room_type_id INT UNSIGNED NOT NULL, number VARCHAR(30) NOT NULL UNIQUE,
 floor VARCHAR(30) NULL, status ENUM('available','maintenance','inactive') NOT NULL DEFAULT 'available', notes TEXT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(room_type_id) REFERENCES room_types(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS guests (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, first_name VARCHAR(100) NOT NULL, last_name VARCHAR(100) NOT NULL,
 document VARCHAR(50) NULL, email VARCHAR(190) NOT NULL, phone VARCHAR(50) NOT NULL, city VARCHAR(100) NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, INDEX(email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS reservations (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, code VARCHAR(30) NOT NULL UNIQUE, guest_id BIGINT UNSIGNED NOT NULL,
 check_in DATE NOT NULL, check_out DATE NOT NULL, adults TINYINT UNSIGNED NOT NULL, children TINYINT UNSIGNED DEFAULT 0,
 rooms_count TINYINT UNSIGNED DEFAULT 1, nights SMALLINT UNSIGNED NOT NULL, total INT UNSIGNED NOT NULL,
 currency CHAR(3) NOT NULL DEFAULT 'CLP', status ENUM('pending_review','confirmed','cancelled','checked_in','checked_out') NOT NULL DEFAULT 'pending_review',
 payment_method VARCHAR(40) NOT NULL DEFAULT 'transfer', special_requests TEXT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY(guest_id) REFERENCES guests(id), INDEX(check_in,check_out), INDEX(status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS reservation_rooms (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, reservation_id BIGINT UNSIGNED NOT NULL, room_id INT UNSIGNED NOT NULL,
 nightly_price INT UNSIGNED NOT NULL, FOREIGN KEY(reservation_id) REFERENCES reservations(id) ON DELETE CASCADE,
 FOREIGN KEY(room_id) REFERENCES rooms(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS room_nights (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, reservation_id BIGINT UNSIGNED NOT NULL, room_id INT UNSIGNED NOT NULL,
 stay_date DATE NOT NULL, UNIQUE KEY room_date(room_id,stay_date),
 FOREIGN KEY(reservation_id) REFERENCES reservations(id) ON DELETE CASCADE, FOREIGN KEY(room_id) REFERENCES rooms(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS contact_messages (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(120) NOT NULL, email VARCHAR(190) NOT NULL,
 phone VARCHAR(50) NULL, subject VARCHAR(160) NOT NULL, message TEXT NOT NULL, status VARCHAR(30) DEFAULT 'new',
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS corporate_requests (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, company VARCHAR(160) NOT NULL, rut VARCHAR(30) NULL,
 contact_name VARCHAR(120) NOT NULL, email VARCHAR(190) NOT NULL, phone VARCHAR(50) NOT NULL,
 guests SMALLINT UNSIGNED NOT NULL, start_date DATE NOT NULL, end_date DATE NOT NULL, requirements TEXT NULL,
 status VARCHAR(30) DEFAULT 'new', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS settings (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, setting_key VARCHAR(100) NOT NULL UNIQUE, value TEXT NOT NULL,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO room_types(slug,name,short_description,description,capacity,beds,size_m2,base_price,image) VALUES
('single','Habitación Individual','Una alternativa cómoda para viajes de trabajo y estadías individuales.','Espacio funcional con baño privado, desayuno, Wi-Fi y climatización.',1,'1 cama matrimonial',18,55000,'room-matrimonial.webp'),
('matrimonial','Habitación Matrimonial','Comodidad y tranquilidad para parejas o viajeros que buscan más espacio.','Habitación luminosa con cama matrimonial, baño privado y servicios incluidos.',2,'1 cama matrimonial',22,68000,'room-matrimonial.webp'),
('triple','Habitación Triple','Una distribución práctica para familias pequeñas o compañeros de viaje.','Tres plazas, baño privado, climatización y desayuno incluido.',3,'3 camas',28,85000,'room-triple.webp'),
('familiar','Habitación Familiar','Más espacio y flexibilidad para vacaciones familiares en el Biobío.','Habitación amplia para compartir con comodidad durante viajes y vacaciones.',4,'3 camas',34,105000,'room-family.webp')
ON DUPLICATE KEY UPDATE name=VALUES(name),base_price=VALUES(base_price),image=VALUES(image);

INSERT IGNORE INTO rooms(room_type_id,number,floor) SELECT id,'101','1' FROM room_types WHERE slug='single';
INSERT IGNORE INTO rooms(room_type_id,number,floor) SELECT id,'102','1' FROM room_types WHERE slug='single';
INSERT IGNORE INTO rooms(room_type_id,number,floor) SELECT id,'201','2' FROM room_types WHERE slug='matrimonial';
INSERT IGNORE INTO rooms(room_type_id,number,floor) SELECT id,'202','2' FROM room_types WHERE slug='matrimonial';
INSERT IGNORE INTO rooms(room_type_id,number,floor) SELECT id,'301','3' FROM room_types WHERE slug='triple';
INSERT IGNORE INTO rooms(room_type_id,number,floor) SELECT id,'302','3' FROM room_types WHERE slug='familiar';

SET FOREIGN_KEY_CHECKS=1;
