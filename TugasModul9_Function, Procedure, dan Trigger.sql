-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 05, 2026 at 01:28 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `toko_buku`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `tambah_transaksi` (`p_id_pel` INT, `p_id_buku` INT, `p_jumlah` INT)   begin
declare  n_harga decimal(10,2);
declare n_total_harga decimal(10,2);
declare n_stok INT;
select harga, stok
into n_harga, n_stok
from buku 
where id_buku=p_id_buku;
if n_stok < p_jumlah then
select 'stok buku tidak mencukupi untuk melanjutkan' as pesan;
else 
set n_total_harga = n_harga * p_jumlah;
update buku
set stok = stok - p_jumlah
where id_buku = p_id_buku;
insert into transaksi (id_pel, id_buku, jumlah, total_harga, tanggal_transaksi) values
(p_id_pel, p_id_buku, p_jumlah, n_total_harga, curdate());
update pelanggan
set total_belanja = total_belanja +n_total_harga
where id_pel = p_id_pel;
select 'Transaksi berhasil' as pesan;
end if;
end$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `hitung_diskon2` (`total_harga` DECIMAL) RETURNS DECIMAL(10,2) DETERMINISTIC begin
if total_harga < 1000000 then
return total_harga;
elseif total_harga <5000000 then 
return total_harga - (total_harga * 0.05);
else
return total_harga - (total_harga * 0.10);
end if;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `buku`
--

CREATE TABLE `buku` (
  `id_buku` int(11) NOT NULL,
  `judul` varchar(100) DEFAULT NULL,
  `penulis` varchar(100) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL,
  `stok` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `buku`
--

INSERT INTO `buku` (`id_buku`, `judul`, `penulis`, `harga`, `stok`) VALUES
(1, 'Laut Bercerita', 'Leila S. Chudori', 115000.00, 14),
(2, 'Bumi Manusia', 'Pramoedya Ananta Toer', 132000.00, 17),
(3, 'Atomic Habits', 'James Clear', 128000.00, 7),
(4, 'Start With Why', 'Simon Sinek', 140000.00, 5),
(5, 'Cantik Itu Luka', 'Eka Kurniawan', 126000.00, 11),
(6, 'Sebuah Seni untuk Bersikap Bodo Amat', 'Almira Bastari', 99000.00, 2),
(7, 'Filosofi Teras', 'Henry Manampiring', 98000.00, 7);

-- --------------------------------------------------------

--
-- Table structure for table `pelanggan`
--

CREATE TABLE `pelanggan` (
  `id_pel` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `total_belanja` decimal(10,2) DEFAULT 0.00,
  `status_member` enum('REGULER','GOLD','PLATINUM') DEFAULT 'REGULER'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pelanggan`
--

INSERT INTO `pelanggan` (`id_pel`, `nama`, `total_belanja`, `status_member`) VALUES
(1, 'Andri', 1200000.00, 'GOLD'),
(2, 'Amri', 0.00, 'GOLD'),
(3, 'Hartanto', 396000.00, 'PLATINUM'),
(4, 'Imam', 0.00, 'REGULER'),
(5, 'Sapri', 5500000.00, 'PLATINUM');

--
-- Triggers `pelanggan`
--
DELIMITER $$
CREATE TRIGGER `updateMember` BEFORE UPDATE ON `pelanggan` FOR EACH ROW BEGIN

    IF NEW.total_belanja >= 5000000 THEN

        SET NEW.status_member = 'PLATINUM';

    ELSEIF NEW.total_belanja >= 1000000 THEN

        SET NEW.status_member = 'GOLD';

    ELSE

        SET NEW.status_member = 'REGULER';

    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `id_transaksi` int(11) NOT NULL,
  `id_pel` int(11) DEFAULT NULL,
  `id_buku` int(11) DEFAULT NULL,
  `jumlah` int(11) DEFAULT NULL,
  `total_harga` decimal(10,2) DEFAULT NULL,
  `tanggal_transaksi` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`id_transaksi`, `id_pel`, `id_buku`, `jumlah`, `total_harga`, `tanggal_transaksi`) VALUES
(1, 1, 2, 10, 1150000.00, '2026-06-09'),
(2, 2, 6, 11, 1089000.00, '2026-06-14'),
(3, 3, 3, 20, 2560000.00, '2026-06-22'),
(4, 4, 4, 30, 4200000.00, '2026-06-19'),
(5, 5, 5, 50, 6300000.00, '2026-06-16'),
(8, 3, 6, 4, 396000.00, '2026-06-05');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `buku`
--
ALTER TABLE `buku`
  ADD PRIMARY KEY (`id_buku`);

--
-- Indexes for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`id_pel`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`id_transaksi`),
  ADD KEY `id_pel` (`id_pel`),
  ADD KEY `id_buku` (`id_buku`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `buku`
--
ALTER TABLE `buku`
  MODIFY `id_buku` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `pelanggan`
--
ALTER TABLE `pelanggan`
  MODIFY `id_pel` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `id_transaksi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`id_pel`) REFERENCES `pelanggan` (`id_pel`),
  ADD CONSTRAINT `transaksi_ibfk_2` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id_buku`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
