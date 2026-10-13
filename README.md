<div align="center">
    <p>
        <img src="https://raw.githubusercontent.com/rogerionasc/gesoft/main/img/logo_wcode.svg" width="420" alt="Logo WCode" />
    </p>
    <p>
        <img src="https://img.shields.io/badge/Docker-24.0+-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />
        <img src="https://img.shields.io/badge/PostgreSQL-15-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
        <img src="https://img.shields.io/badge/PHP-8.1--apache-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP 8.1 Apache" />
        <img src="https://img.shields.io/badge/Node.js-18.x-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" alt="Node.js" />
        <img src="https://img.shields.io/badge/Laravel-9.x%20%2F%2010.x-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" alt="Laravel" />
        <img src="https://img.shields.io/badge/Debian-Slim-A81D33?style=for-the-badge&logo=debian&logoColor=white" alt="Debian" />
    </p>
</div>

<div align="center">
    <p>
        <a href="#sobre">Sobre</a> •
        <a href="#arquitetura-do-ambiente">Arquitetura</a> •
        <a href="#pré-requisitos">Pré-requisitos</a> •
        <a href="#ambientação-e-instalação">Instalação</a> •
        <a href="#urls-de-acesso">URLs de Acesso</a> •
        <a href="#solução-de-problemas-frequentes">Troubleshooting</a> •
        <a href="#comandos-úteis">Comandos Úteis</a> •
        <a href="#licença">Licença</a>
    </p>
</div>

---

# Sobre

Este repositório contém a infraestrutura e o ambiente de desenvolvimento conteinerizado com **Docker**, **PostgreSQL 15**, **Node.js 18** e **PHP 8.1 / Apache**, preparado para executar o ecossistema **WebClinic ERP** (arquitetura Multi-Tenant com Laravel) tanto em ambientes **Ubuntu (Linux)** quanto em **Windows**.

> **Nota:** Este repositório gerencia a **infraestrutura de contêineres**. O código-fonte da aplicação Laravel reside no repositório [WebClinic](https://github.com/rogerionasc/WebClinic) e é clonado/montado no diretório `appWeb/`.

---

# Arquitetura do Ambiente

O ambiente é orquestrado via `docker-compose.yml` composto pelos seguintes serviços integrados na rede interna `network-webclinic`:

| Serviço | Contêiner | Imagem / Base | Portas Expostas | Descrição |
| :--- | :--- | :--- | :--- | :--- |
| **db** | `postgres` | `postgres:15` | `5432:5432` | Banco de dados PostgreSQL com persistência em `./db_data` |
| **app** | `appWeb` | Build local (`./Dockerfile`) | `80:80` e `8080:80` | Servidor web Apache, PHP 8.1, Composer, Node.js 18 e aplicação Laravel |

---

# Pré-requisitos

Antes de iniciar, certifique-se de ter instalado em sua máquina:

- [Docker Engine](https://docs.docker.com/engine/install/) (v20.10 ou superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0 ou superior)
- [Git](https://git-scm.com/)

---

# Ambientação e Instalação

Siga o passo a passo abaixo para subir o ambiente do zero:

### 1. Clonar o Repositório de Infraestrutura
```bash
git clone https://github.com/rogerionasc/AmbienteDocker.git
cd AmbienteDocker
```

### 2. Configurar Variáveis de Ambiente do Docker
Copie o arquivo de exemplo para criar o `.env` raiz do Docker Compose:
```bash
cp .env-example .env
```

Edite o `.env` raiz com os dados desejados:
```ini
DATABASE_DATABASE=webclinic
DATABASE_ROOT_PASSWORD=root
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres

# Token de acesso pessoal do GitHub para clonar o repositório WebClinic no primeiro boot:
GITHUB_TOKEN=seu_token_aqui
```

### 3. Configurar a Resolução de DNS Local (Hosts)
A aplicação utiliza arquitetura multi-tenant com domínios locais (`webclinic.local`, `matriz.webclinic.local`).

#### No Windows:
Execute com o botão direito -> **Executar como Administrador** o arquivo:
```cmd
setup-hosts.bat
```

#### No Ubuntu / Linux:
Execute o script utilitário com permissão de execução:
```bash
chmod +x setup-hosts.sh
./setup-hosts.sh
```

*(O script registrará `127.0.0.1 appweb.local webclinic.local matriz.webclinic.local` no seu arquivo `hosts`).*

---

# Inicialização dos Contêineres

### 1. Subir o ambiente em segundo plano:
```bash
docker compose up -d --build
```

No primeiro boot, o contêiner `appWeb` executará automaticamente o script de entrypoint que:
1. Clona o repositório WebClinic para a pasta `appWeb/` (se ainda não existir).
2. Cria o arquivo `.env` da aplicação a partir de `.env.example`.
3. Executa `composer install`.
4. Executa `npm install` e `npm run build`.
5. Gera a chave da aplicação (`php artisan key:generate`).
6. Cria o link simbólico de storage (`php artisan storage:link`).
7. Ajusta permissões de escrita em `storage/` e `bootstrap/cache`.
8. Inicia o servidor web Apache.

### 2. Verificar o status dos contêineres:
```bash
docker compose ps
```

---

# Configuração do Banco de Dados e Multi-Tenancy

### 1. Configurar o `.env` da Aplicação (`appWeb/.env`)
Certifique-se de que a conexão do banco aponta para o host do contêiner (`db`):
```ini
DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=webclinic
DB_USERNAME=postgres
DB_PASSWORD=postgres
```

Se alterar o `.env`, limpe o cache de configuração no contêiner:
```bash
docker compose exec app php artisan config:clear
```

### 2. Executar as Migrações do Banco Central:
```bash
docker compose exec app php artisan migrate
```

### 3. Criar o Superusuário e o Primeiro Tenant (Matriz):
Execute o comando interativo do WebClinic para criar a empresa/clínica matriz e o usuário administrador:
```bash
docker compose exec app php artisan create:su
```
*(O comando criará o tenant ID 1000, o domínio `matriz.webclinic.local` e migrará o banco de dados do tenant `clinica_webclinic`).*

---

# URLs de Acesso

Com os contêineres em execução, os serviços estão disponíveis em:

| Serviço | URL | Descrição |
| :--- | :--- | :--- |
| **Central / Landing** | [http://webclinic.local](http://webclinic.local) | Domínio principal da plataforma |
| **Tenant Matriz (Login)** | [http://matriz.webclinic.local](http://matriz.webclinic.local) | Acesso direto à clínica/tenant Matriz |
| **Porta Alternativa Apache** | [http://matriz.webclinic.local:8080](http://matriz.webclinic.local:8080) | Mapeamento alternativo para porta 8080 |
| **PostgreSQL** | `localhost:5432` (externo) / `db:5432` (interno) | Acesso via DBeaver, pgAdmin, HeidiSQL |

---

# Solução de Problemas Frequentes

### 1. Conflito de porta 5432 com PostgreSQL do Laragon (Windows)
* **Sintoma:** Erro `Connection refused` ou falha de autenticação ao conectar no PostgreSQL pela máquina hospedeira.
* **Causa:** O Laragon possui um serviço `postgres.exe` próprio rodando em `127.0.0.1:5432`, interceptando a porta do Docker.
* **Solução:** No painel do Laragon, clique com o botão direito -> **PostgreSQL -> Stop** (ou feche o Laragon enquanto usa o Docker).

### 2. Erro `SQLSTATE[08006] Connection refused` no Tenant
* **Causa:** O `DB_HOST` no arquivo `appWeb/.env` está definido como `localhost`. Dentro do contêiner, `localhost` não possui servidor PostgreSQL instalado.
* **Solução:** Altere para `DB_HOST=db` no `appWeb/.env` e execute `docker compose exec app php artisan config:clear`.

### 3. Link Simbólico do Storage
Se as imagens e uploads não carregarem, recrie o link simbólico:
```bash
docker compose exec app php artisan storage:link
```

---

# Comandos Úteis

### Ver logs em tempo real:
```bash
# Logs de todos os contêineres
docker compose logs -f

# Logs apenas da aplicação
docker compose logs -f app

# Logs do banco de dados
docker compose logs -f db
```

### Acessar o terminal do contêiner da aplicação:
```bash
docker compose exec app bash
```

### Reiniciar serviços:
```bash
docker compose restart
```

### Parar e remover contêineres (mantendo dados do banco preservados em `./db_data`):
```bash
docker compose down
```

### Rodar comandos Artisan diretamente:
```bash
docker compose exec app php artisan route:list
docker compose exec app php artisan migrate:status
```

---

# Estrutura do Repositório

```text
AmbienteDocker/
├── .dockerignore           # Exclusões de arquivos na geração da imagem Docker
├── .env-example            # Exemplo de variáveis de ambiente do Docker Compose
├── .gitignore              # Ignora .env, appWeb/ e db_data/ para manter repo limpo
├── 000-default.conf        # Configuração do VirtualHost do Apache
├── Dockerfile              # Imagem Docker customizada (PHP 8.1 Apache + Node 18 + OPcache)
├── docker-compose.yml      # Orquestração dos serviços (postgres e appWeb)
├── hosts                   # Mapeamentos de host para referência
├── setup-hosts.bat         # Script automatizado de configuração de hosts para Windows
├── setup-hosts.sh          # Script automatizado de configuração de hosts para Linux
├── LICENSE                 # Termos de licença
└── README.md               # Documentação completa do projeto
```

---

# Licença

Consulte o arquivo [LICENSE](LICENSE) para obter detalhes sobre os direitos autorais e termos de licença de uso do software.
