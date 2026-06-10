-- Script SQL - Agencia de Viagens
-- Modelo Logico e Fisico 

DROP TABLE IF EXISTS comissao CASCADE;
DROP TABLE IF EXISTS pagamento_fornecedor CASCADE;
DROP TABLE IF EXISTS recebimento_cliente CASCADE;
DROP TABLE IF EXISTS venda CASCADE;
DROP TABLE IF EXISTS pacote_servico CASCADE;
DROP TABLE IF EXISTS pacote CASCADE;
DROP TABLE IF EXISTS servico CASCADE;
DROP TABLE IF EXISTS fornecedor CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS vendedor CASCADE;

CREATE TABLE vendedor (
    matricula INTEGER PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE cliente (
    id_cliente INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(120) UNIQUE
);

CREATE TABLE fornecedor (
    cnpj VARCHAR(14) PRIMARY KEY,
    nome_empresa VARCHAR(120) NOT NULL,
    contato VARCHAR(120) NOT NULL
);

CREATE TABLE servico (
    id_servico INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cnpj_fornecedor VARCHAR(14) NOT NULL,
    descricao VARCHAR(200) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    valor_custo DECIMAL(10,2) NOT NULL CHECK (valor_custo >= 0),
    CONSTRAINT fk_servico_fornecedor
        FOREIGN KEY (cnpj_fornecedor)
        REFERENCES fornecedor(cnpj)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE pacote (
    id_pacote INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome_pacote VARCHAR(100) NOT NULL,
    descricao VARCHAR(250) NOT NULL,
    valor_base DECIMAL(10,2) NOT NULL CHECK (valor_base >= 0)
);

CREATE TABLE pacote_servico (
    id_pacote INTEGER NOT NULL,
    id_servico INTEGER NOT NULL,
    quantidade INTEGER NOT NULL DEFAULT 1 CHECK (quantidade > 0),
    observacao VARCHAR(200),
    PRIMARY KEY (id_pacote, id_servico),
    CONSTRAINT fk_pacote_servico_pacote
        FOREIGN KEY (id_pacote)
        REFERENCES pacote(id_pacote)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pacote_servico_servico
        FOREIGN KEY (id_servico)
        REFERENCES servico(id_servico)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE venda (
    id_venda INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_vendedor INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,
    id_pacote INTEGER NOT NULL,
    data_venda DATE NOT NULL DEFAULT CURRENT_DATE,
    valor_total DECIMAL(10,2) NOT NULL CHECK (valor_total >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMADA'
        CHECK (status IN ('CONFIRMADA','CANCELADA','PENDENTE')),
    CONSTRAINT fk_venda_vendedor
        FOREIGN KEY (matricula_vendedor)
        REFERENCES vendedor(matricula)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_venda_pacote
        FOREIGN KEY (id_pacote)
        REFERENCES pacote(id_pacote)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE recebimento_cliente (
    id_recebimento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_venda INTEGER NOT NULL UNIQUE,
    forma_pagamento VARCHAR(40) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL CHECK (valor_total >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'PAGO'
        CHECK (status IN ('PAGO','PENDENTE','ESTORNADO')),
    CONSTRAINT fk_recebimento_venda
        FOREIGN KEY (id_venda)
        REFERENCES venda(id_venda)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE pagamento_fornecedor (
    id_pagamento_fornecedor INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_venda INTEGER NOT NULL,
    cnpj_fornecedor VARCHAR(14) NOT NULL,
    valor_custo DECIMAL(10,2) NOT NULL CHECK (valor_custo >= 0),
    data_limite_repasse DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE'
        CHECK (status IN ('PENDENTE','REPASSADO','CANCELADO')),
    CONSTRAINT fk_pagamento_venda
        FOREIGN KEY (id_venda)
        REFERENCES venda(id_venda)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pagamento_fornecedor
        FOREIGN KEY (cnpj_fornecedor)
        REFERENCES fornecedor(cnpj)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE comissao (
    id_comissao INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_venda INTEGER NOT NULL UNIQUE,
    valor_comissao DECIMAL(10,2) NOT NULL CHECK (valor_comissao >= 0),
    percentual DECIMAL(5,2) NOT NULL CHECK (percentual >= 0 AND percentual <= 100),
    status VARCHAR(20) NOT NULL DEFAULT 'A_PAGAR'
        CHECK (status IN ('A_PAGAR','PAGA','CANCELADA')),
    CONSTRAINT fk_comissao_venda
        FOREIGN KEY (id_venda)
        REFERENCES venda(id_venda)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

INSERT INTO vendedor (matricula, nome) VALUES
(1001, 'Ana Souza'),
(1002, 'Carlos Lima');

INSERT INTO cliente (nome, cpf, telefone, email) VALUES
('Mariana Costa', '12345678901', '73999990000', 'mariana@email.com'),
('Joao Pereira', '98765432100', '73988887777', 'joao@email.com');

INSERT INTO fornecedor (cnpj, nome_empresa, contato) VALUES
('12345678000190', 'Hotel Sol Bahia', 'reservas@hotelsol.com'),
('98765432000110', 'AeroTour Brasil', 'operacional@aerotour.com'),
('11222333000144', 'Passeios Nordeste', 'contato@passeiosne.com');

INSERT INTO servico (cnpj_fornecedor, descricao, categoria, valor_custo) VALUES
('12345678000190', 'Hospedagem 5 diarias em Salvador', 'Hospedagem', 1200.00),
('98765432000110', 'Passagem aerea ida e volta', 'Transporte', 900.00),
('11222333000144', 'City tour historico', 'Passeio', 250.00);

INSERT INTO pacote (nome_pacote, descricao, valor_base) VALUES
('Salvador Completo', 'Pacote com hospedagem, passagem e city tour.', 3200.00);

INSERT INTO pacote_servico (id_pacote, id_servico, quantidade, observacao) VALUES
(1, 1, 1, 'Hospedagem inclusa'),
(1, 2, 1, 'Transporte aereo incluso'),
(1, 3, 1, 'Passeio guiado incluso');

INSERT INTO venda (matricula_vendedor, id_cliente, id_pacote, data_venda, valor_total, status) VALUES
(1001, 1, 1, '2026-06-10', 3200.00, 'CONFIRMADA');

INSERT INTO recebimento_cliente (id_venda, forma_pagamento, valor_total, status) VALUES
(1, 'Cartao de Credito', 3200.00, 'PAGO');

INSERT INTO pagamento_fornecedor (id_venda, cnpj_fornecedor, valor_custo, data_limite_repasse, status) VALUES
(1, '12345678000190', 1200.00, '2026-06-17', 'PENDENTE'),
(1, '98765432000110', 900.00, '2026-06-17', 'PENDENTE'),
(1, '11222333000144', 250.00, '2026-06-17', 'PENDENTE');

INSERT INTO comissao (id_venda, valor_comissao, percentual, status) VALUES
(1, 320.00, 10.00, 'A_PAGAR');

-- Consulta de rastreabilidade financeira
SELECT
    v.data_venda AS data_da_venda,
    vd.nome AS nome_do_vendedor,
    c.nome AS nome_do_cliente,
    rc.valor_total AS valor_total_pago_pelo_cliente,
    SUM(pf.valor_custo) AS valor_de_custo_do_fornecedor,
    co.valor_comissao AS valor_da_comissao_do_consultor
FROM venda v
JOIN vendedor vd ON vd.matricula = v.matricula_vendedor
JOIN cliente c ON c.id_cliente = v.id_cliente
JOIN recebimento_cliente rc ON rc.id_venda = v.id_venda
JOIN pagamento_fornecedor pf ON pf.id_venda = v.id_venda
JOIN comissao co ON co.id_venda = v.id_venda
GROUP BY v.data_venda, vd.nome, c.nome, rc.valor_total, co.valor_comissao;