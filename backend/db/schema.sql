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