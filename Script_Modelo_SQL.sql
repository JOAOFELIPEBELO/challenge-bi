----- MODELO DESENVOLVIDO COM SINTAXE PL/SQL

--Tabela VENDAS/COMPRAS
CREATE TABLE VENDAS 
(
  Id_Venda              NUMBER,
  Id_Pedido             NUMBER,
  Id_Item               NUMBER,
  Id_Parceiro           NUMBER,
  Id_Site               NUMBER,
  Id_Status             NUMBER,
  Id_Cliente            NUMBER,
  Id_Forma_Pagamento    NUMBER,
  Quantidade            NUMBER,
  Data_Inclusao         DATE,
  Data_Aprovacao        DATE,
  Data_Faturamento      DATE,
  Data_Expedicao        DATE,
  Data_Entrega          DATE,
  Data_Entrega_Prevista DATE,
  PRIMARY KEY(Id_Venda,Id_Pedido,Id_Item)
);

--Tabela de Dimensão de Endereços
CREATE TABLE Endereco 
(
  CEP                   NUMBER PRIMARY KEY,
  Endereco              VARCHAR2(500),
  Cidade                VARCHAR2(200),
  Estado                VARCHAR2(200)
);

--Tabela de Cadastro de Clientes
CREATE TABLE Cliente 
(
  Id_Cliente             NUMBER PRIMARY KEY,
  CEP                    NUMBER,
  Nome_Cliente           VARCHAR2(200),
  CPF_CNPJ               NUMBER(15),
  Numero                 NUMBER,
  Complemento            VARCHAR2(200),
  Telefone_Res_DDD       NUMBER(3),
  Telefone_Res           NUMBER,
  Telefone_Celular_DDD   NUMBER(3),
  Telefone_Celular       NUMBER,
  Email                  VARCHAR2(200),
  FOREIGN KEY(CEP) REFERENCES Endereco (CEP)
);

--Tabela de Dimensão Site
CREATE TABLE Site 
(
  Id_Site               NUMBER PRIMARY KEY,
  Site                  VARCHAR2(200)
);

--Tabela de Dimensão de Ramo de Atividades
CREATE TABLE Ramo_Atividade 
(
  Id_Ramo_Atividade     NUMBER PRIMARY KEY,
  Ramo_Atividade        VARCHAR2(200)
);

--Tabela de Cadastro de Parceiros/Sellers
CREATE TABLE Parceiro 
(
  Id_Parceiro            NUMBER PRIMARY KEY,
  Id_Ramo_Atidade        NUMBER,
  Id_Site                NUMBER,
  CEP                    NUMBER,
  CNPJ_Matriz            NUMBER(15),
  Razao_Social           VARCHAR2(500),
  Nome_Fantasia          VARCHAR2(200),
  Inscricao_Municipal    NUMBER,
  Inscricao_Estadual     NUMBER,
  Nome_Contato           VARCHAR2(200),
  CPF_Contato            NUMBER(15),
  Telefone_Comercial_DDD NUMBER(3),
  Telefone_Comercial     NUMBER,
  Email                  VARCHAR2(200),
  Percentual_MKT         NUMBER(18,3),
  FOREIGN KEY(Id_Ramo_Atidade) REFERENCES Ramo_Atividade (Id_Ramo_Atividade),
  FOREIGN KEY(Id_Site)         REFERENCES Site (Id_Site),
  FOREIGN KEY(CEP)             REFERENCES Endereco (CEP)
);

--Tabela Cadastro de Parceiro/Item
CREATE TABLE Parceiro_Item 
(
  Id_Parceiro           NUMBER,
  Id_Item               NUMBER,
  Valor_Item            NUMBER(18,2),
  Quantidade_Estoque    NUMBER,
  PRIMARY KEY(Id_Parceiro,Id_Item)
);

--Tabela de Dimensão de Forma de Pagamentos
CREATE TABLE Forma_Pagamento 
(
  Id_Forma_Pagamento    NUMBER PRIMARY KEY,
  Forma_Pagamento       VARCHAR2(200)
);

--Tabela de Dimensão Status dos Pedidos
CREATE TABLE Status_Pedido 
(
  Id_Status             NUMBER PRIMARY KEY,
  Status                VARCHAR2(200)
);

--Tabela de Dimensão de Itens
CREATE TABLE Item 
(
  Id_Item               NUMBER PRIMARY KEY,
  Item                  VARCHAR2(200),
  Descricao_Item        VARCHAR2(500)
);

ALTER TABLE VENDAS        ADD FOREIGN KEY(Id_Parceiro,Id_Item) REFERENCES Parceiro_Item (Id_Parceiro,Id_Item);
ALTER TABLE VENDAS        ADD FOREIGN KEY(Id_Site)             REFERENCES Site (Id_Site);
ALTER TABLE VENDAS        ADD FOREIGN KEY(Id_Status)           REFERENCES Status_Pedido (Id_Status);
ALTER TABLE VENDAS        ADD FOREIGN KEY(Id_Cliente)          REFERENCES Cliente (Id_Cliente);
ALTER TABLE VENDAS        ADD FOREIGN KEY(Id_Forma_Pagamento)  REFERENCES Forma_Pagamento (Id_Forma_Pagamento);
ALTER TABLE Parceiro_Item ADD FOREIGN KEY(Id_Parceiro)         REFERENCES Parceiro (Id_Parceiro);
ALTER TABLE Parceiro_Item ADD FOREIGN KEY(Id_Item)             REFERENCES Item (Id_Item);

--------------------------------------------------------------------------------------------------------------------
/********************************************** QUESTÕES DE NEGÓCIO ***********************************************/
--------------------------------------------------------------------------------------------------------------------
--qual seller que tem mais itens disponíveis para venda em nossos sites?
SELECT T2.NOME_FANTASIA,
       T1.QTDE_ITENS
FROM(
      SELECT ID_PARCEIRO,
             COUNT (DISTINCT ID_ITEM) AS QTDE_ITENS
      FROM PARCEIRO_ITEM
      WHERE QUANTIDADE_ESTOQUE > 0
      GROUP BY
             ID_PARCEIRO
      ORDER BY 2 DESC
      )                        T1
LEFT JOIN PARCEIRO             T2
ON   T1.ID_PARCEIRO = T2.ID_PARCEIRO
WHERE  ROWNUM = 1;

--qual o seller que mais vende? E qual cliente que mais compra?
SELECT 'SELLER'   IDENTIFICADOR,
       T2.NOME_FANTASIA,
       T1.QTDE_VENDAS QTDE_VENDAS_COMPRAS
FROM(
      SELECT ID_PARCEIRO,
             COUNT (DISTINCT ID_VENDA) AS QTDE_VENDAS
      FROM VENDAS
      WHERE ID_STATUS  = 1 -- 1 REPRESENTA "APROVADO" NA TABELA DIMENSÃO Status_Pedido
      GROUP BY
            ID_PARCEIRO
      ORDER BY 2 DESC
      )                        T1
LEFT JOIN PARCEIRO             T2
ON   T1.ID_PARCEIRO = T2.ID_PARCEIRO
WHERE  ROWNUM = 1
UNION ALL
SELECT 'CLIENTE' IDENTIFICADOR,
       T2.NOME_CLIENTE,
       T1.QTDE_VENDAS
FROM(
      SELECT ID_CLIENTE,
             COUNT (DISTINCT ID_VENDA) AS QTDE_VENDAS
      FROM VENDAS
      WHERE ID_STATUS  = 1 -- 1 REPRESENTA "APROVADO" NA TABELA DIMENSÃO Status_Pedido
      GROUP BY
            ID_CLIENTE
      ORDER BY 2 DESC
      )                        T1
LEFT JOIN CLIENTE              T2
ON   T1.ID_CLIENTE = T2.ID_CLIENTE
WHERE  ROWNUM = 1;

--qual é o total ($) de venda aprovada no último mês?
SELECT 
       SUM (T1.QUANTIDADE*T2.VALOR_ITEM) AS VALOR_VENDAS
FROM         VENDAS           T1
INNER JOIN   PARCEIRO_ITEM    T2
ON    T1.ID_PARCEIRO                      = T2.ID_PARCEIRO
AND   T1.ID_ITEM                          = T2.ID_ITEM
WHERE T1.ID_STATUS                        = 1 -- 1 REPRESENTA "APROVADO" NA TABELA DIMENSÃO Status_Pedido 
AND   TO_CHAR(T1.DATA_APROVACAO,'RRRRMM') = TO_CHAR(ADD_MONTHS(SYSDATE,-1),'RRRRMM');

--qual seller que tem o maior ticket médio? e o menor?
SELECT 'MAIOR TICKET MEDIO' AS TICKET,
       T2.NOME_FANTASIA,
       T1.TICKET_MEDIO
FROM     (
          SELECT T1.ID_PARCEIRO,
                 SUM   (T1.QUANTIDADE*T2.VALOR_ITEM) /COUNT (DISTINCT T1.ID_VENDA) AS TICKET_MEDIO
          FROM VENDAS                   T1
          INNER JOIN   PARCEIRO_ITEM    T2
          ON    T1.ID_PARCEIRO                      = T2.ID_PARCEIRO
          AND   T1.ID_ITEM                          = T2.ID_ITEM
          WHERE T1.ID_STATUS                        = 1 -- 1 REPRESENTA "APROVADO" NA TABELA DIMENSÃO Status_Pedido
          GROUP BY
                 T1.ID_PARCEIRO
          ORDER BY 2 DESC
          )                        T1
LEFT JOIN PARCEIRO                 T2
ON   T1.ID_PARCEIRO = T2.ID_PARCEIRO
WHERE ROWNUM = 1
UNION ALL
SELECT 'MENOR TICKET MEDIO' AS TICKET, 
       T2.NOME_FANTASIA,
       T1.TICKET_MEDIO
FROM     (
          SELECT T1.ID_PARCEIRO,
                 SUM   (T1.QUANTIDADE*T2.VALOR_ITEM) /COUNT (DISTINCT T1.ID_VENDA) AS TICKET_MEDIO
          FROM  VENDAS                   T1
          INNER JOIN   PARCEIRO_ITEM     T2
          ON    T1.ID_PARCEIRO                      = T2.ID_PARCEIRO
          AND   T1.ID_ITEM                          = T2.ID_ITEM
          WHERE T1.ID_STATUS                        = 1 -- 1 REPRESENTA "APROVADO" NA TABELA DIMENSÃO Status_Pedido
          GROUP BY
                 T1.ID_PARCEIRO
          ORDER BY 2
          )                        T1
LEFT JOIN PARCEIRO                 T2
ON   T1.ID_PARCEIRO = T2.ID_PARCEIRO
WHERE ROWNUM = 1;

--qual o seller que mais atrasa para entregar no RJ nos últimos 30d?
SELECT T2.NOME_FANTASIA,
       T1.PER_PEDIDOS PERCENTUAL_ATRASOS
FROM (
      SELECT T1.ID_PARCEIRO,
                  COUNT (DISTINCT (CASE WHEN T1.DATA_ENTREGA > T1.DATA_ENTREGA_PREVISTA THEN T1.ID_PEDIDO END))  / COUNT (DISTINCT T1.ID_PEDIDO) AS PER_PEDIDOS
      FROM         VENDAS           T1
      INNER JOIN   PARCEIRO_ITEM    T2
      ON    T1.ID_PARCEIRO                      = T2.ID_PARCEIRO
      AND   T1.ID_ITEM                          = T2.ID_ITEM
      INNER JOIN   PARCEIRO         T3
      ON    T2.ID_PARCEIRO                      = T3.ID_PARCEIRO
      INNER JOIN   ENDERECO         T4
      ON    T3.CEP                              = T4.CEP
      AND   T4.ESTADO                           = 'RJ'
      WHERE T1.DATA_ENTREGA                     > SYSDATE - 31
      GROUP BY T1.ID_PARCEIRO
      ORDER BY 2 DESC
      )                            T1
LEFT JOIN PARCEIRO                 T2
ON   T1.ID_PARCEIRO = T2.ID_PARCEIRO
WHERE ROWNUM = 1
;

--qual o seller que gera mais dinheiro para a B2W?
SELECT T2.NOME_FANTASIA,
       T1.LUCRO
FROM (SELECT T1.ID_PARCEIRO,
             SUM(T1.QUANTIDADE*T2.VALOR_ITEM*PERCENTUAL_MKT) AS LUCRO
      FROM         VENDAS           T1
      INNER JOIN   PARCEIRO_ITEM    T2
      ON    T1.ID_PARCEIRO                      = T2.ID_PARCEIRO
      AND   T1.ID_ITEM                          = T2.ID_ITEM
      INNER JOIN   PARCEIRO         T3
      ON    T2.ID_PARCEIRO                      = T3.ID_PARCEIRO
      WHERE T1.ID_STATUS                        = 1 -- 1 REPRESENTA "APROVADO" NA TABELA DIMENSÃO Status_Pedido
      GROUP BY T1.ID_PARCEIRO
      ORDER BY 2 DESC
      )                            T1
LEFT JOIN PARCEIRO                 T2
ON   T1.ID_PARCEIRO = T2.ID_PARCEIRO
WHERE ROWNUM = 1;

--Tarefa extra
--Se suas tabelas tiverem bilhões de registros, o que você faria para a consulta de pedidos e itens de um parceiro não ficar lenta?
/*
RESPOSTA:

Criação de Índice nos campos mais utilizados como filtro ou join, por exemplo, campos de datas e ID's.
Particionamento da tabela VENDAS por Data de Inclusão.

*/
