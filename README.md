Sobre o projeto

Este projeto consiste na construção de um pipeline de Engenharia de Dados para extração, transformação e modelagem de dados de partidas de futebol utilizando a API-Sports, seguido pelo desenvolvimento de modelos de Machine Learning para previsão de resultados de partidas.

Engenharia de Dados

O pipeline realiza a ingestão dos dados da API-Sports, seu tratamento e armazenamento em uma arquitetura em camadas (Raw, Bronze, Silver e Gold), permitindo a criação de bases consistentes para análises e modelagem preditiva.

As principais etapas são:

Extração de dados da API-Sports utilizando requests;
Transformação e limpeza dos dados com pandas;
Persistência das tabelas utilizando SQLAlchemy;
Modelagem dos dados em diferentes camadas (Bronze, Silver e Gold);
Construção de Feature Stores por meio de consultas SQL.
Machine Learning

A partir das Feature Stores, são construídos modelos para previsão do resultado das partidas (Vitória, Empate ou Derrota).

O processo de modelagem inclui:

Construção de pipelines com scikit-learn;
Tratamento de valores ausentes;
Validação temporal utilizando conjuntos Train, Test e Out-of-Time (OOT);
Otimização de hiperparâmetros com GridSearchCV;
Comparação entre diferentes algoritmos.
Algoritmos utilizados
Random Forest
LightGBM
Monitoramento de experimentos

Os experimentos são registrados utilizando MLflow, permitindo acompanhar métricas, parâmetros e comparar diferentes versões dos modelos.

As principais métricas avaliadas são:

Accuracy
ROC AUC (One-vs-Rest)
Endpoints utilizados

Foram utilizados os seguintes endpoints da API-Sports:

fixtures: informações das partidas e seus eventos;
injuries: informações sobre lesões dos jogadores;
standings: classificação das ligas (utilizado apenas para consulta, não faz parte das features do modelo).
Requisitos

Para executar o projeto é necessário:

possuir uma chave (API Key) válida da API-Sports;
informar obrigatoriamente os parâmetros league e season;
considerar que o plano gratuito da API disponibiliza apenas parte das temporadas (normalmente de 2022 a 2024);
observar que nem todas as ligas estão disponíveis na versão gratuita da API. 
Neste projeto foram utilizadas as ligas com IDs: 2, 39, 78, 140.
Estrutura do projeto

O projeto segue uma arquitetura de dados organizada em camadas.

data/
raw/

Armazena os arquivos Parquet gerados a partir dos dados retornados pela API-Sports (originalmente em formato JSON).

bronze/

Contém os dados logo após a ingestão, preservando sua estrutura com o mínimo de transformações.

silver/

Armazena os dados tratados, padronizados e preparados para análises.

gold/

Contém as tabelas analíticas utilizadas para construção das Feature Stores e treinamento dos modelos de Machine Learning.

analytics/

Reúne toda a etapa analítica do projeto.

Inclui:

consultas SQL responsáveis pela criação das Feature Stores;
script para execução das queries e criação das tabelas;
pipeline de treinamento, validação e avaliação dos modelos de Machine Learning.
engineering/

Responsável pelo pipeline de Engenharia de Dados (ETL).

Contém os processos de:

extração dos dados da API-Sports;
transformação e tratamento das informações;
carregamento dos dados nas camadas Bronze, Silver e Gold.

O arquivo main centraliza toda a execução do pipeline de ETL.