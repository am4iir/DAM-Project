CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  password_hash TEXT NOT NULL,
  created_at DATE DEFAULT CURRENT_DATE,
  is_accept BOOLEAN DEFAULT false,
  id_role INTEGER DEFAULT 3
);
CREATE TABLE roles (
  id_role INTEGER PRIMARY KEY,
  role_name VARCHAR(50) NOT NULL
);
/*
username =	ilyes.cherif@student.univ-constantine2.dz
password = ilyesPass77
user are accept 
*/
CREATE TABLE groups (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,          
  level VARCHAR(10) NOT NULL,                     
  max_students INT NOT NULL
    CHECK (max_students > 0),
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE student_groups (
  id SERIAL PRIMARY KEY,
  student_id INT REFERENCES users(id) ON DELETE CASCADE,
  group_id INT REFERENCES groups(id) ON DELETE CASCADE,
  UNIQUE (student_id, group_id)
);
CREATE TABLE teacher_groups (
  id SERIAL PRIMARY KEY,
  teacher_id INT REFERENCES users(id) ON DELETE CASCADE,
  group_id INT REFERENCES groups(id) ON DELETE CASCADE,
  UNIQUE (teacher_id, group_id)
);

CREATE TABLE modules (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  level VARCHAR(10) NOT NULL
);

CREATE TABLE teacher_modules (
  id SERIAL PRIMARY KEY,
  teacher_id INTEGER NOT NULL,
  module_id INTEGER NOT NULL,

  CONSTRAINT fk_teacher
    FOREIGN KEY (teacher_id)
    REFERENCES users(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_module
    FOREIGN KEY (module_id)
    REFERENCES modules(id)
    ON DELETE CASCADE,

  CONSTRAINT uq_teacher_module
    UNIQUE (teacher_id, module_id)
);

CREATE TABLE student_groups (
  id SERIAL PRIMARY KEY,
  student_id INT REFERENCES users(id) ON DELETE CASCADE,
  group_id INT REFERENCES groups(id) ON DELETE CASCADE,
  UNIQUE (student_id, group_id)
);
