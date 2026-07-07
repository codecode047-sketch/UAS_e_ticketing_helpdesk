CREATE DATABASE IF NOT EXISTS e_ticketing_helpdesk;

USE e_ticketing_helpdesk;

CREATE TABLE users (

id INT AUTO_INCREMENT PRIMARY KEY,

name VARCHAR(100),

email VARCHAR(100) UNIQUE,

password VARCHAR(255),

role ENUM('admin','helpdesk','user'),

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE tickets (

id INT AUTO_INCREMENT PRIMARY KEY,

user_id INT,

title VARCHAR(255),

description TEXT,

priority ENUM('Low','Medium','High'),

status ENUM('Open','On Progress','Resolved','Closed'),

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY(user_id) REFERENCES users(id)

);

CREATE TABLE comments(

id INT AUTO_INCREMENT PRIMARY KEY,

ticket_id INT,

user_id INT,

comment TEXT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY(ticket_id) REFERENCES tickets(id),

FOREIGN KEY(user_id) REFERENCES users(id)

);

CREATE TABLE notifications(

id INT AUTO_INCREMENT PRIMARY KEY,

user_id INT,

title VARCHAR(255),

message TEXT,

is_read BOOLEAN DEFAULT FALSE,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY(user_id) REFERENCES users(id)

);

INSERT INTO users(name,email,password,role) VALUES

('Admin','msury@gmail.com','suryagantengdewe','admin'),

('Helpdesk','helpdesk@gmail.com','suryagantengdewe','helpdesk'),

('User','user@gmail.com','suryagantengdewe','user');

INSERT INTO tickets(user_id,title,description,priority,status) VALUES

(3,'Printer Rusak','Printer tidak bisa digunakan','High','Open'),

(3,'Wifi Lambat','Internet sangat lambat','Medium','Resolved'),

...

(3,'Komputer Mati','CPU tidak menyala','High','On Progress');

INSERT INTO comments(ticket_id,user_id,comment) VALUES

(1,2,'Sedang diperiksa'),

(1,3,'Terima kasih'),

(2,2,'Sudah diperbaiki'),

(3,2,'Menunggu sparepart');

INSERT INTO notifications(user_id,title,message) VALUES

(3,'Ticket Dibuat','Ticket berhasil dibuat'),

(3,'Ticket Diproses','Helpdesk sedang menangani ticket'),

(3,'Ticket Selesai','Ticket berhasil diselesaikan');