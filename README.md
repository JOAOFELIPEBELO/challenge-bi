# Challenge

### Somos um marketplace
 
Marketplace é uma plataforma de intermediação de vendas entre duas partes: vendedores parceiros e clientes.
 
Os parceiros podem vender os seus itens nos nossos 3 sites - Americanas.com, Submarino, Shoptime.
Nós capturamos o pedido e aprovamos o pagamento; o parceiro fica responsável por entregar os itens vendidos.
Para cada venda recebemos um percentual do valor total – este percentual pode variar por parceiro.
 
Os parceiros cadastram os itens que querem vender, informando o preço e a quantidade disponível em estoque de cada item.
Um parceiro pode vender quantos itens desejar.
 
Cada parceiro vende um item, mas pode ser o mesmo item que outro parceiro está vendendo – ou seja, um mesmo produto pode ser vendido por vários sellers - mas tanto o preço como a disponibilidade de estoque podem ser diferentes para cada parceiro.
 
(Por exemplo: o produto “HD Externo Portátil Seagate Expansion 1TB USB 3.0” é vendido por vários parceiros)

 ![HD Externo](https://i.imgur.com/6ClCaYL.png)
 
Depois de cadastrar o produto, confirmar a disponibilidade do estoque e precificar, o item do parceiro  aparece na vitrine dos nossos sites.
 
### E então
O cliente navega por cada um dos nossos sites e decide comprar um ou N produtos.
A compra de um cliente pode conter itens de um ou mais parceiros – e cada compra pode gerar vários pedidos, pois um pedido é sempre de um único parceiro.
 
Os pedidos são processados na nossa plataforma (e esta plataforma acompanha o ciclo de vida de um pedido, desde a compra do cliente até a entrega)
 
Cada pedido contém várias informações:
* site que intermediou a venda (Americanas.com, Submarino, Shoptime)
* parceiro
* datas de cadastro, de aprovação, etc
* dados do cliente (incluindo endereço de entrega)
* dados da forma de pagamento
* produto(s) comprado(s)
 
No ciclo de vida, acompanhamos várias etapas até o produto chegar na casa do cliente (e comunicamos o cliente em cada uma delas):
* inclusão (data da compra)
* aprovação de pagamento
* faturamento
* expedição

### QUIZ
A partir das informações acima
1. modelar as tabelas, com colunas e relacionamentos, usando o padrão da modelagem entidade relacionamento:
1. definir as chaves primárias de cada tabela
1. montar as consultas nas tabelas para obter as seguintes respostas:
    1. qual seller que tem mais itens disponíveis para venda em nossos sites?
    1. qual o seller que mais vende? E qual cliente que mais compra?
    1. qual é o total ($) de venda aprovada no último mês?
    1. qual seller que tem o maior ticket médio? e o menor?
    1. qual o seller que mais atrasa para entregar no RJ nos últimos 30d?
    1. qual o seller que gera mais dinheiro para a B2W?
 
#### Tarefa extra
Se suas tabelas tiverem **bilhões de registros**, o que você faria para a consulta de pedidos e itens de um parceiro não ficar lenta?
