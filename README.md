<div align="center">
    <p>
        <img src="https://raw.githubusercontent.com/rogerionasc/gesoft/main/img/logo_wcode.svg" width="420" alt="Logo WCode" />
    </p>
    <p>
        <img src="https://img.shields.io/badge/Docker-24.0+-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />
        <img src="https://img.shields.io/badge/PostgreSQL-15-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
        <img src="https://img.shields.io/badge/PHP-8.1-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP" />
        <img src="https://img.shields.io/badge/Node.js-18.x-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" alt="Node.js" />
        <img src="https://img.shields.io/badge/Laravel-9.x-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" alt="Laravel" />
        <img src="https://img.shields.io/badge/Ubuntu-22.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Ubuntu" />
    </p>
</div>

<div align="center">
    <p>
        <a href="#sobre">Sobre</a> •
        <a href="#arquitetura-do-ambiente">Arquitetura</a> •
        <a href="#pré-requisitos">Pré-requisitos</a> •
        <a href="#ambientação-e-instalação">Ambientação</a> •
        <a href="#configuração-de-dns--hosts">Configuração de DNS</a> •
        <a href="#comandos-úteis">Comandos Úteis</a> •
        <a href="#licença">Licença</a>
    </p>
</div>

---

# Sobre

O **WCode Clinic ERP** é uma solução completa de gestão clínica (Enterprise Resource Planning) projetada para otimizar operações médicas, prontuários, agendamentos, faturamento e integrações com convênios.

Este repositório contém a infraestrutura e o ambiente de desenvolvimento conteinerizado com **Docker**, **PostgreSQL**, **Node.js 18** e **PHP/Laravel**, preparado para rodar tanto em ambientes **Ubuntu (Linux)** quanto em **Windows**.

---

# Arquitetura do Ambiente

O ambiente é orquestrado via `docker-compose.yml` composto pelos seguintes serviços integrados na rede interna `network-webclinic`:

| Serviço | Contêiner | Imagem / Base | Porta Exposta | Descrição |
| :--- | :--- | :--- | :--- | :--- |
| **db** | `postgres` | `postgres:15` | `5432:5432` | Banco de dados relacional com persistência em `./db_data` |
| **app** | `appWeb` | Build local (`./Dockerfile`) | `8000:8000` / `8080:80` | Aplicação PHP 8.1, Apache, Composer, Node.js 18 e Laravel |

---

# Pré-requisitos

Antes de iniciar, certifique-se de ter instalado em sua máquina (Ubuntu ou Windows):

- [Docker Engine](https://docs.docker.com/engine/install/) (v20.10 ou superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0 ou superior)
- [Git](https://git-scm.com/)

---

# Ambientação e Instalação

Siga o passo a passo abaixo para subir o ambiente do zero:

### 1. Clonar o Repositório
```bash
git clone <url-do-repositorio>
cd AmbienteDocker
```

### 2. Configurar Variáveis de Ambiente do Docker
O arquivo `.env` na raiz define as credenciais do banco para o Docker Compose:
```ini
DATABASE_DATABASE=gesoft
DATABASE_USER=user
DATABASE_PASSWORD=user
```

### 3. Configurar o `.env` da Aplicação Laravel
Dentro do diretório `appWeb`, copie o arquivo de exemplo para criar o seu `.env`:
```bash
cp appWeb/.env.example appWeb/.env
```

Verifique se a seção de banco de dados do `appWeb/.env` aponta para o contêiner do PostgreSQL:
```ini
DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=gesoft
DB_USERNAME=user
DB_PASSWORD=user
```

### 4. Configurar a Resolução de DNS Local (Hosts)
Para acessar a aplicação utilizando domínios amigáveis como `http://appweb.local` ou `http://webclinic.local`:

#### No Ubuntu / Linux:
Execute o script utilitário incluído no projeto:
```bash
chmod +x setup-hosts.sh
./setup-hosts.sh
```
*(O script adicionará `127.0.0.1 appweb.local webclinic.local` no `/etc/hosts` com `sudo`)*

#### No Windows:
Execute com duplo clique o arquivo **`setup-hosts.bat`** (ele solicitará permissão de Administrador e atualizará o arquivo `C:\Windows\System32\drivers\etc\hosts`).

---

# Inicialização dos Contêineres

### Subir o ambiente em segundo plano:
```bash
docker compose up -d --build
```

### Verificar o status dos contêineres:
```bash
docker compose ps
```

### Inicializar a Aplicação Laravel (Primeira Execução):
Acesse o terminal do contêiner `appWeb` para gerar a chave da aplicação e rodar as migrações:

```bash
# Entrar no contêiner da aplicação
docker compose exec app bash

# Dentro do contêiner:
php artisan key:generate
php artisan migrate --seed

# Instalar dependências de frontend e compilar assets com Node.js 18:
npm install
npm run build   # ou 'npm run dev' em modo desenvolvimento
exit
```

---

# URLs de Acesso

Com os contêineres em execução, os serviços estão disponíveis em:

| Serviço | URL | Descrição |
| :--- | :--- | :--- |
| **Laravel Server** | [http://appweb.local:8000](http://appweb.local:8000) ou `http://localhost:8000` | Servido via `php artisan serve` |
| **Apache Web Server** | [http://appweb.local:8080](http://appweb.local:8080) ou `http://localhost:8080` | Servido via servidor web Apache |
| **PostgreSQL** | `localhost:5432` (externo) / `db:5432` (interno) | Acesso via DBeaver, pgAdmin ou terminal |

---

# Comandos Úteis

### Ver logs em tempo real:
```bash
# Logs de todos os serviços
docker compose logs -f

# Logs apenas da aplicação
docker compose logs -f app

# Logs do banco de dados
docker compose logs -f db
```

### Reiniciar serviços:
```bash
docker compose restart
```

### Parar o ambiente:
```bash
docker compose stop
```

### Destruir contêineres e manter dados salvos:
```bash
docker compose down
```

### Executar comandos Artisan diretamente:
```bash
docker compose exec app php artisan route:list
docker compose exec app php artisan migrate:status
```

---

# Estrutura do Projeto

```text
AmbienteDocker/
├── appWeb/                 # Código-fonte da aplicação Laravel
│   ├── app/
│   ├── config/
│   ├── routes/
│   └── .env.example
├── db_data/                # Volume de dados persistentes do PostgreSQL
├── .env                    # Variáveis de ambiente raiz (Docker Compose)
├── docker-compose.yml      # Configuração dos serviços e contêineres
├── Dockerfile              # Imagem Docker customizada da aplicação
├── hosts                   # Mapeamentos de host para referência
├── setup-hosts.sh          # Script de configuração de hosts para Ubuntu/Linux
├── setup-hosts.bat         # Script de configuração de hosts para Windows
└── README.md               # Documentação do projeto
```

---

# Licença

Consulte o arquivo [LICENSE](file:///c:/laragon/www/AmbienteDocker/LICENSE) para obter detalhes sobre direitos autorais e termos de licença de uso do software.
