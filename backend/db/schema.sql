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
CREATE TABLE teacher_groups (
  id SERIAL PRIMARY KEY,
  teacher_id INT REFERENCES users(id) ON DELETE CASCADE,
  group_id INT REFERENCES groups(id) ON DELETE CASCADE,
  UNIQUE (teacher_id, group_id)
);

