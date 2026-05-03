-- ==========================================================================================
-- ESQUEMA COMPLETO PARA SUPABASE - PORTAFOLIO ACADÉMICO (POSTGRESQL)
-- Estudiante: Chavez Orihuela Ruel Manuel - Universidad Peruana Los Andes (UPLA)
-- ==========================================================================================

-- ------------------------------------------------------------------------------------------
-- 1. TABLA: configuracion (Preferencias globales del sitio)
-- ------------------------------------------------------------------------------------------
CREATE TABLE configuracion (
    id SERIAL PRIMARY KEY,
    clave VARCHAR(50) UNIQUE NOT NULL,
    valor TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------------------------------------
-- 2. TABLA: perfil (Información Personal y Profesional)
-- ------------------------------------------------------------------------------------------
CREATE TABLE perfil (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    nombre_completo VARCHAR(200),
    carrera VARCHAR(150),
    universidad VARCHAR(150),
    bio TEXT,
    correo VARCHAR(100),
    telefono VARCHAR(50),
    ubicacion VARCHAR(200),
    foto_url TEXT,
    cv_url TEXT,
    linkedin TEXT,
    github TEXT,
    instagram TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------------------------------------
-- 3. TABLA: habilidades (Skills para la sección Sobre Mí)
-- ------------------------------------------------------------------------------------------
CREATE TABLE habilidades (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nivel INTEGER CHECK (nivel BETWEEN 0 AND 100),
    categoria VARCHAR(50) DEFAULT 'General',
    orden INTEGER DEFAULT 0
);

-- ------------------------------------------------------------------------------------------
-- 4. TABLA: cursos (Asignaturas Universitarias)
-- ------------------------------------------------------------------------------------------
CREATE TABLE cursos (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    icono VARCHAR(10),
    orden INTEGER DEFAULT 0,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------------------------------------
-- 5. TABLA: semanas (Unidades semanales de cada curso)
-- ------------------------------------------------------------------------------------------
CREATE TABLE semanas (
    id SERIAL PRIMARY KEY,
    curso_id INTEGER REFERENCES cursos(id) ON DELETE CASCADE,
    numero INTEGER NOT NULL CHECK (numero BETWEEN 1 AND 16),
    -- El sistema calculará la unidad automáticamente (1 al 4) basado en la semana
    unidad INTEGER GENERATED ALWAYS AS (CEIL(numero / 4.0)) STORED, 
    titulo VARCHAR(150),
    objetivo TEXT,
    UNIQUE(curso_id, numero)
);

-- ------------------------------------------------------------------------------------------
-- 6. TABLA: archivos (Material didáctico y evidencias)
-- ------------------------------------------------------------------------------------------
CREATE TABLE archivos (
    id SERIAL PRIMARY KEY,
    semana_id INTEGER REFERENCES semanas(id) ON DELETE CASCADE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    ruta TEXT NOT NULL, -- URL pública de Supabase Storage o enlace externo
    tipo VARCHAR(50), -- pdf, img, zip, etc
    peso_mb DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------------------------------------
-- 7. TABLA: mensajes_contacto (Bandeja de entrada del formulario)
-- ------------------------------------------------------------------------------------------
CREATE TABLE mensajes_contacto (
    id SERIAL PRIMARY KEY,
    remitente_nombre VARCHAR(150) NOT NULL,
    remitente_correo VARCHAR(150) NOT NULL,
    asunto VARCHAR(200),
    mensaje TEXT NOT NULL,
    leido BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================================================
-- TRIGGERS Y FUNCIONES AUTOMÁTICAS (PL/pgSQL)
-- ==========================================================================================

-- Función para automatizar el portafolio: Al crear un curso, se autogeneran sus 16 semanas.
CREATE OR REPLACE FUNCTION generar_semanas_curso()
RETURNS TRIGGER AS $$
BEGIN
    FOR i IN 1..16 LOOP
        INSERT INTO semanas (curso_id, numero, titulo)
        VALUES (NEW.id, i, 'Desarrollo de la Semana ' || i);
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que ejecuta la función al insertar en cursos
CREATE TRIGGER trg_crear_semanas
AFTER INSERT ON cursos
FOR EACH ROW
EXECUTE FUNCTION generar_semanas_curso();


-- ==========================================================================================
-- INSERCIÓN DE DATOS DE PRUEBA / SEMILLAS INICIALES
-- ==========================================================================================

-- A) CONFIGURACIÓN INICIAL
INSERT INTO configuracion (clave, valor) VALUES 
('theme_color', '#3b82f6'),
('site_title', 'Portafolio Profesional UPLA');

-- B) PERFIL DE RUEL MANUEL
INSERT INTO perfil (nombre, apellido, nombre_completo, carrera, universidad, bio, correo, telefono, ubicacion)
VALUES (
    'Ruel Manuel', 
    'Chavez Orihuela', 
    'Chavez Orihuela Ruel Manuel',
    'Ingeniero de Sistemas y Computación',
    'Universidad Peruana Los Andes (UPLA)',
    'Estudiante apasionado por la ingeniería de sistemas, enfocado en diseñar interfaces de usuario fluidas (UI/UX) y arquitecturas limpias para aplicaciones web de alto rendimiento. Preparado para retos tecnológicos complejos.',
    'rchavez@upla.edu.pe', 
    '+51 987 654 321',
    'Huancayo, Perú'
);

-- C) HABILIDADES TÉCNICAS (Reemplaza los datos basura 'aaa', 'bbb')
INSERT INTO habilidades (nombre, nivel, categoria, orden) VALUES
('Arquitectura de Software', 90, 'Especialidad', 1),
('Desarrollo Web (Frontend)', 85, 'Tecnología', 2),
('Bases de Datos (PostgreSQL)', 80, 'Tecnología', 3),
('Machine Learning (Algoritmos)', 70, 'Investigación', 4),
('Gobierno de TI (COBIT/ITIL)', 75, 'Gestión', 5);

-- D) CURSOS EXACTOS (Su inserción disparará automáticamente las 16 semanas por curso)
INSERT INTO cursos (codigo, nombre, descripcion, icono, orden) VALUES
('333188', 'MACHINE LEARNING (ELECTIVO)', 'Curso electivo sobre algoritmos de aprendizaje automático e inteligencia artificial para análisis predictivo.', '🤖', 1),
('332181', 'ARQUITECTURA DE SOFTWARE', 'Diseño y estructuración a gran escala de sistemas de software, patrones de diseño y escalabilidad.', '🏗️', 2),
('332187', 'LEGISLACIÓN INFORMÁTICA', 'Estudio del marco legal aplicable a las tecnologías de la información, auditoría y ética profesional.', '⚖️', 3),
('33218A', 'INGLÉS IV', 'Nivel intermedio-avanzado de idioma inglés técnico orientado a la lectura de documentación.', '🇺🇸', 4),
('33228B', 'TALLER DE INVESTIGACIÓN I', 'Metodologías para la formulación, redacción y defensa de proyectos de investigación tecnológica.', '🔬', 5),
('333185', 'COMERCIO ELECTRONICO', 'Sistemas de e-commerce, pasarelas de pagos online, y estrategias de negocios digitales empresariales.', '🛒', 6),
('333186', 'GOBIERNO DE TI', 'Gestión, alineación y control de las tecnologías de información según estándares COBIT e ITIL.', '🏛️', 7),
('333189', 'SEGURIDAD DE LA INFRAESTRUCTURA DE TI I', 'Protección de redes, hardening de servidores, criptografía y políticas de ciberseguridad corporativa.', '🛡️', 8);

-- ==========================================================================================
-- POLÍTICAS DE SEGURIDAD (RLS) PARA SUPABASE
-- ==========================================================================================
-- Habilitar RLS en las tablas
ALTER TABLE configuracion ENABLE ROW LEVEL SECURITY;
ALTER TABLE perfil ENABLE ROW LEVEL SECURITY;
ALTER TABLE habilidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE cursos ENABLE ROW LEVEL SECURITY;
ALTER TABLE semanas ENABLE ROW LEVEL SECURITY;
ALTER TABLE archivos ENABLE ROW LEVEL SECURITY;
ALTER TABLE mensajes_contacto ENABLE ROW LEVEL SECURITY;

-- Políticas de Lectura Pública (El portafolio puede ser visto por cualquiera)
CREATE POLICY "Lectura pública de perfil" ON perfil FOR SELECT USING (true);
CREATE POLICY "Lectura pública de habilidades" ON habilidades FOR SELECT USING (true);
CREATE POLICY "Lectura pública de cursos" ON cursos FOR SELECT USING (true);
CREATE POLICY "Lectura pública de semanas" ON semanas FOR SELECT USING (true);
CREATE POLICY "Lectura pública de archivos" ON archivos FOR SELECT USING (true);

-- Política para que cualquiera pueda enviar un formulario de contacto
CREATE POLICY "Inserción pública de mensajes" ON mensajes_contacto FOR INSERT WITH CHECK (true);

-- Importante: El CRUD de Admin (Insert, Update, Delete) en cursos/archivos
-- debe asegurarse en la interfaz de Supabase habilitando reglas para 'authenticated' users.
