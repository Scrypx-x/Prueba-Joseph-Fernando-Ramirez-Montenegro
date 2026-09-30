-- =========================================================================
-- SISTEMA DE GESTIÓN DE POSTULACIONES LABORALES
-- =========================================================================

-- 1. ELIMINACIÓN DE TABLAS EXISTENTES (Orden inverso por dependencias de FK)
DROP TABLE IF EXISTS postulaciones;
DROP TABLE IF EXISTS vacantes;
DROP TABLE IF EXISTS candidatos;

-- =========================================================================
-- 2. CREACIÓN DE TABLAS Y RESTRICCIONES
-- =========================================================================

-- Tabla de Candidatos
CREATE TABLE candidatos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    correo_electronico VARCHAR(150) NOT NULL UNIQUE,
    anios_experiencia INT NOT NULL CHECK (anios_experiencia >= 0)
);

-- Tabla de Vacantes
CREATE TABLE vacantes (
    id SERIAL PRIMARY KEY,
    titulo_cargo VARCHAR(150) NOT NULL,
    anios_minimos_experiencia INT NOT NULL CHECK (anios_minimos_experiencia >= 0),
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('Disponibles', 'Cerrado'))
);

-- Tabla de Postulaciones (Relación N:M entre Candidatos y Vacantes)
CREATE TABLE postulaciones (
    id SERIAL PRIMARY KEY,
    candidato_id INT NOT NULL,
    vacante_id INT NOT NULL,
    carta_presentacion TEXT,
    fuente VARCHAR(20) NOT NULL CHECK (fuente IN ('REFERRAL', 'INTERNAL', 'JOB_BOARD', 'OTHER')),
    puntaje NUMERIC(5,2) NOT NULL CHECK (puntaje >= 0 AND puntaje <= 100),
    prioridad VARCHAR(20) NOT NULL CHECK (prioridad IN ('BAJO', 'MEDIO', 'ALTO', 'HACKER (TOP)')),
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('RECIBIDO', 'En REVISION', 'ANCLADO', 'CONTRATADO')),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion_estado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Restricciones de Claves Foráneas
    CONSTRAINT fk_postulacion_candidato FOREIGN KEY (candidato_id) 
        REFERENCES candidatos(id) ON DELETE CASCADE,
    CONSTRAINT fk_postulacion_vacante FOREIGN KEY (vacante_id) 
        REFERENCES vacantes(id) ON DELETE CASCADE,
        
    -- Restricción de Negocio Única: Un candidato solo puede postularse una vez a la misma vacante
    CONSTRAINT uk_candidato_vacante UNIQUE (candidato_id, vacante_id)
);

-- =========================================================================
-- 3. CREACIÓN DE ÍNDICES PARA OPTIMIZACIÓN DE CONSULTAS
-- =========================================================================

-- Índice para búsquedas frecuentes y filtros por estado de vacantes
CREATE INDEX idx_vacantes_estado ON vacantes(estado);

-- Índices en claves foráneas de postulaciones para acelerar JOINs
CREATE INDEX idx_postulaciones_candidato ON postulaciones(candidato_id);
CREATE INDEX idx_postulaciones_vacante ON postulaciones(vacante_id);

-- Índices para filtros analíticos y tableros de reclutamiento (filtrado por estado y prioridad)
CREATE INDEX idx_postulaciones_estado ON postulaciones(estado);
CREATE INDEX idx_postulaciones_prioridad ON postulaciones(prioridad);

-- =========================================================================
-- 4. INSERCIÓN DE DATOS DE PRUEBA (SEED DATA)
-- =========================================================================

-- Inserción de al menos 3 candidatos
INSERT INTO candidatos (nombre, correo_electronico, anios_experiencia) VALUES
('Ana María Gómez', 'ana.gomez@example.com', 5),
('Carlos Ruiz Pérez', 'carlos.ruiz@example.com', 2),
('Sofía Valentina Torres', 'sofia.torres@example.com', 8);

-- Inserción de al menos 2 vacantes (obligatoriamente una 'Disponibles' y otra 'Cerrado')
INSERT INTO vacantes (titulo_cargo, anios_minimos_experiencia, estado) VALUES
('Desarrollador Backend Senior Node.js', 4, 'Disponibles'),
('Especialista en Marketing Digital Junior', 1, 'Cerrado');

-- Inserción de postulaciones de prueba enlazando candidatos y vacantes
INSERT INTO postulaciones (candidato_id, vacante_id, carta_presentacion, fuente, puntaje, prioridad, estado, fecha_creacion, fecha_actualizacion_estado) VALUES
(
    1, 1, 
    'Tengo amplia experiencia en arquitectura de microservicios y Node.js, alineada perfectamente con los requerimientos de la vacante.', 
    'REFERRAL', 
    95.50, 
    'HACKER (TOP)', 
    'En REVISION', 
    CURRENT_TIMESTAMP - INTERVAL '3 days', 
    CURRENT_TIMESTAMP - INTERVAL '1 day'
),
(
    2, 1, 
    'Me entusiasma mucho la oportunidad de crecer profesionalmente en su equipo de tecnología.', 
    'JOB_BOARD', 
    72.00, 
    'MEDIO', 
    'RECIBIDO', 
    CURRENT_TIMESTAMP - INTERVAL '2 days', 
    CURRENT_TIMESTAMP - INTERVAL '2 days'
),
(
    3, 2, 
    'Aporto una visión estratégica sólida basada en campañas pasadas de gran impacto.', 
    'INTERNAL', 
    88.30, 
    'ALTO', 
    'CONTRATADO', 
    CURRENT_TIMESTAMP - INTERVAL '10 days', 
    CURRENT_TIMESTAMP - INTERVAL '5 days'
);