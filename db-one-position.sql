-- phpMyAdmin SQL Dump
-- version 4.2.11
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Czas generowania: 25 Lut 2015, 14:24
-- Wersja serwera: 5.6.21
-- Wersja PHP: 5.6.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Baza danych: `db`
--
CREATE DATABASE IF NOT EXISTS `db` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `db`;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `balance`
--

CREATE TABLE IF NOT EXISTS `balance` (
  `account` varchar(250) DEFAULT '0',
  `balance` decimal(10,2) DEFAULT '0.00',
  `equity` decimal(10,2) DEFAULT '0.00',
  `alias` varchar(250) DEFAULT '0',
  `linkmql` varchar(250) DEFAULT '0',
  `time` bigint(21) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `balanceall`
--

CREATE TABLE IF NOT EXISTS `balanceall` (
  `account` varchar(250) DEFAULT '0',
  `balance` decimal(10,2) DEFAULT '0.00',
  `equity` decimal(10,2) DEFAULT '0.00',
  `time` bigint(21) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `orders`
--

CREATE TABLE IF NOT EXISTS `orders` (
  `id` varchar(250) DEFAULT NULL,
  `symbol` varchar(250) DEFAULT '0',
  `volume` float DEFAULT '0',
  `type` varchar(250) DEFAULT '0',
  `opent` bigint(21) NOT NULL DEFAULT '0',
  `openp` float DEFAULT '0',
  `sl` float DEFAULT '0',
  `tp` float DEFAULT '0',
  `closet` bigint(21) NOT NULL DEFAULT '0',
  `closep` float DEFAULT '0',
  `profit` float DEFAULT '0',
  `time` bigint(21) NOT NULL DEFAULT '0',
  `account` varchar(250) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `users`
--

CREATE TABLE IF NOT EXISTS `users` (
`id` bigint(21) NOT NULL,
  `alias` varchar(250) NOT NULL,
  `pass` varchar(250) NOT NULL,
  `email` varchar(250) NOT NULL,
  `country` varchar(2) DEFAULT NULL,
  `account` varchar(250) DEFAULT '',
  `linkmql` varchar(250) DEFAULT '',
  `mobile` text,
  `allowfrom` text,
  `about` text,
  `ip` text,
  `time` bigint(21) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indexes for table `balance`
--
ALTER TABLE `balance`
 ADD UNIQUE KEY `account` (`account`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
 ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
 ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `alias` (`alias`), ADD UNIQUE KEY `email` (`email`), ADD UNIQUE KEY `linkmql` (`linkmql`), ADD UNIQUE KEY `account` (`account`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT dla tabeli `users`
--
ALTER TABLE `users`
MODIFY `id` bigint(21) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
