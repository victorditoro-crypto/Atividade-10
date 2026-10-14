USE master;
GO
IF DB_ID('aeronautica_db') IS NOT NULL
BEGIN
    ALTER DATABASE aeronautica_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE aeronautica_db;
END;
GO
CREATE DATABASE aeronautica_db;
GO
USE aeronautica_db;
GO

CREATE TABLE materiais (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(250) NOT NULL,
    descricao VARCHAR(MAX),
    medida VARCHAR(25) NOT NULL,
    estoque_minimo INT DEFAULT 0,
    ativo INT NOT NULL DEFAULT 1
);
GO

CREATE TABLE fornecedores (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(250) NOT NULL,
    contato VARCHAR(250),
    telefone VARCHAR(25),
    ativo INT NOT NULL DEFAULT 1
);
GO

CREATE TABLE entradas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_material INT NOT NULL,
    id_fornecedor INT NOT NULL,
    data_entrada DATE NOT NULL,
    quantidade INT NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    nota_fiscal VARCHAR(50),

    FOREIGN KEY (id_material) REFERENCES materiais(id),
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id)
);
GO

CREATE TABLE saidas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_material INT NOT NULL,
    data_saida DATE NOT NULL,
    quantidade INT NOT NULL,
    destino VARCHAR(50),

    FOREIGN KEY (id_material) REFERENCES materiais(id)
);
GO

SET IDENTITY_INSERT materiais ON;

INSERT INTO materiais
(id, nome, descricao, medida, estoque_minimo, ativo)
VALUES
(1, 'Chapa de alumínio', 'Chapa de alumínio de liga 6061-T6', 'm²', 100, 1),
(2, 'Tubo de titânio', 'Tubo de titânio grau 5', 'm', 50, 1),
(3, 'Parafuso de aço inoxidável', 'Parafuso de aço inoxidável AISI 316', 'unidade', 200, 1),
(4, 'Fio de cobre', 'Fio de cobre esmaltado', 'm', 150, 1),
(5, 'Rebite de alumínio', 'Rebite de alumínio sólido', 'unidade', 300, 1),
(6, 'Chapa de fibra de carbono', 'Chapa de fibra de carbono pré-impregnada', 'm²', 80, 1),
(7, 'Resina epóxi', 'Resina epóxi para laminação', 'kg', 40, 1),
(8, 'Tecido de fibra de vidro', 'Tecido de fibra de vidro para laminação', 'm²', 120, 1),
(9, 'Pintura poliuretânica', 'Pintura poliuretânica para aeronaves', 'l', 30, 1),
(10, 'Adesivo estrutural', 'Adesivo estrutural de alta resistência', 'kg', 25, 1);

SET IDENTITY_INSERT materiais OFF;
GO
SET IDENTITY_INSERT fornecedores ON;
INSERT INTO fornecedores
(id, nome, contato, telefone, ativo)
VALUES
(1, 'Aerometalúrgica do Sudeste', 'João Silva', '(11) 9999-9999', 1),
(2, 'Titânio do Brasil', 'Maria Souza', '(21) 3333-3333', 1),
(3, 'Fixadores Industriais', 'Pedro Santos', '(31) 2222-2222', 1),
(4, 'Condutor Elétrico', 'Ana Oliveira', '(41) 5555-5555', 1),
(5, 'Rebites e Fixadores', 'Carlos Rodrigues', '(19) 8888-8888', 1),
(6, 'Fibra & Carbono Technology', 'Juliana Almeida', '(11) 4444-4444', 1),
(7, 'Epoxi & Compostos', 'Roberto Mendes', '(27) 7777-7777', 1),
(8, 'Fibra de Vidro do Brasil', 'Fernanda Costa', '(48) 6666-6666', 1),
(9, 'Tintas Aeronáuticas', 'Marcelo Santos', '(11) 2222-2222', 1),
(10, 'Adesivos Especiais', 'Patricia Lima', '(47) 9999-9999', 1);

SET IDENTITY_INSERT fornecedores OFF;
GO

CREATE PROCEDURE registrar_entrada
    @p_id_material INT,
    @p_id_fornecedor INT,
    @p_data_entrada DATE,
    @p_quantidade INT,
    @p_preco DECIMAL(10,2),
    @p_nota_fiscal VARCHAR(50)
AS
BEGIN
    INSERT INTO entradas
    (id_material, id_fornecedor, data_entrada,
     quantidade, preco, nota_fiscal)
    VALUES
    (@p_id_material, @p_id_fornecedor, @p_data_entrada,
     @p_quantidade, @p_preco, @p_nota_fiscal);
END;
GO

EXEC registrar_entrada 1, 1, '2023-10-25', 100, 5.50, 'NF001';
EXEC registrar_entrada 2, 2, '2023-10-26', 50, 12.00, 'NF002';
EXEC registrar_entrada 7, 7, '2023-10-27', 40, 18.90, 'NF150';
GO

CREATE PROCEDURE registrar_saida
    @p_id_material INT,
    @p_data_saida DATE,
    @p_quantidade INT,
    @p_destino VARCHAR(50)
AS
BEGIN
    INSERT INTO saidas
    (id_material, data_saida, quantidade, destino)
    VALUES
    (@p_id_material, @p_data_saida, @p_quantidade, @p_destino);
END;
GO

EXEC registrar_saida 3, '2023-11-01', 50, 'OP003';
EXEC registrar_saida 6, '2023-11-05', 20, 'OP010';
GO

CREATE PROCEDURE inativar_material
    @p_id_material INT
AS
BEGIN
    UPDATE materiais
    SET ativo = 0
    WHERE id = @p_id_material;
END;
GO

EXEC inativar_material 4;
EXEC inativar_material 10;
GO

CREATE PROCEDURE inativar_fornecedor
    @p_id_fornecedor INT
AS
BEGIN
    UPDATE fornecedores
    SET ativo = 0
    WHERE id = @p_id_fornecedor;
END;
GO

EXEC inativar_fornecedor 4;
EXEC inativar_fornecedor 8;
GO

CREATE FUNCTION calcular_estoque (@p_id_material INT)
RETURNS INT
AS
BEGIN
    DECLARE @total_entradas INT;
    DECLARE @total_saidas INT;

    SELECT @total_entradas = ISNULL(SUM(quantidade), 0)
    FROM entradas
    WHERE id_material = @p_id_material;

    SELECT @total_saidas = ISNULL(SUM(quantidade), 0)
    FROM saidas
    WHERE id_material = @p_id_material;

    RETURN @total_entradas - @total_saidas;
END;
GO

SELECT dbo.calcular_estoque(1) AS estoque_material_1;
SELECT dbo.calcular_estoque(2) AS estoque_material_2;
SELECT dbo.calcular_estoque(7) AS estoque_material_7;
GO

CREATE VIEW consultar_estoque
AS
SELECT
    id,
    nome,
    medida,
    estoque_minimo,
    dbo.calcular_estoque(id) AS estoque_atual
FROM materiais;
GO

SELECT *
FROM consultar_estoque
ORDER BY nome ASC;
GO

SELECT * FROM entradas;
GO

SELECT * FROM saidas;
GO

SELECT * FROM materiais;
GO

SELECT * FROM fornecedores;
GO

SELECT * FROM entradas;
GO

SELECT * FROM saidas;
GO

SELECT * FROM materiais WHERE ativo = 0;
GO

SELECT * FROM fornecedores WHERE ativo = 0;
GO

SELECT *
FROM consultar_estoque
WHERE estoque_atual < estoque_minimo;
GO