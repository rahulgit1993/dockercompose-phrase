#CREATE USER admin IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON *.* TO admin;

CREATE USER 'developer'@'%' IDENTIFIED BY 'dev123';
GRANT SELECT ON *.* TO 'developer'@'%';

USE flask;

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (`name`, `email`) VALUES
('Rahul Raj', 'rahulraj@example.com'),
('Test User', 'testuser@example.com');
