# 🐳 Infra Dev - Docker Database Stack

> Stack completa de bancos de dados para desenvolvimento local usando Docker - PostgreSQL, MySQL e MongoDB prontos para uso com DataGrip/DBeaver.

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Batch (.bat)](https://img.shields.io/badge/Batch%20(.bat)-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://docs.microsoft.com/windows/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![Redis](https://img.shields.io/badge/Redis-D92B2B?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io/)

---

## 🎯 Por que usar?

✅ **Zero instalação** - Sem precisar instalar PostgreSQL, MySQL, MongoDB ou Redis no sistema  
✅ **Setup instantâneo** - 1 comando e tudo está rodando  
✅ **Portável** - Funciona em qualquer PC com Docker  
✅ **Leve** - Limites de RAM otimizados para desenvolvimento  
✅ **Backup fácil** - Scripts automatizados inclusos  
✅ **Multi-projeto** - Bancos separados por perfil (Docker Profiles)
✅ **Ambiente Pronto** - Ambiente-ready

---

## 📋 Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop) instalado e executando
- Windows 10/11 (scripts `.bat` são para Windows)
- Um cliente SQL (DataGrip, DBeaver, etc.)

---

## 🚀 Quick Start

### 1. Clone o repositório
```bash
git clone https://github.com/matheus05dev/Infra-dev.git
cd Infra
```

### 2. Inicie os bancos
**Opção A - Via script (recomendado):**
```batch
Startardbs.bat
```

**Opção B - Via Docker Compose:**
```bash
# Todos os bancos
docker compose --profile pg --profile my --profile mo --profile redis up -d

# Apenas PostgreSQL
docker compose --profile pg up -d

# Apenas MySQL
docker compose --profile my up -d

# Apenas MongoDB
docker compose --profile mo up -d

# Apenas Redis
docker compose --profile redis up -d
```

### 3. Conecte no DataGrip/DBeaver
Veja a seção [Conexões](#-conectar-nos-bancos) abaixo.

---

## 📦 Bancos Disponíveis

| Banco | Porta | Usuário | Senha | Profile |
|-------|-------|---------|-------|---------|
| **PostgreSQL** | 5432 | `postgres` | `admin` | `pg` |
| **MySQL** | 3306 | `root` | `admin` | `my` |
| **MongoDB** | 27017 | *(sem auth)* | - | `mo` |
| **Redis** | 6379 | - | - | `redis` |

---

## 🛠️ Scripts Disponíveis

| Script | Descrição |
|--------|-----------|
| **`Startardbs.bat`** | Inicia os containers com menu interativo |
| **`Stopdbs.bat`** | Para todos os containers |
| **`Logsdbs.bat`** | Visualiza logs em tempo real |
| **`Backupdbs.bat`** | Cria backup automático dos dados |
| **`Restoredbs.bat`** | Restaura backup anterior |

### Como usar os scripts

**Iniciar:**
```batch
Startardbs.bat
# Escolha: 1 (todos) ou específico
```

**Ver logs:**
```batch
Logsdbs.bat
# Ctrl+C para sair
```

**Backup:**
```batch
Backupdbs.bat
# Backup salvo em: Backups/Backup_DD-MM-YYYY/
```

**Restaurar (substitui dados atuais):**
```batch
Restoredbs.bat
# Escolha o backup a restaurar; este comando substituirá os dados atuais
```

**Remover imagens e volumes (CUIDADO — apaga dados):**

- Recomenda-se usar o script `Stopdbs.bat`, que faz uma limpeza interativa e segura (para evitar remoção acidental): ele para a stack, remove volumes e realiza limpeza de imagens e volumes órfãos.

```batch
Stopdbs.bat
# O script pede confirmação antes de prosseguir.
```

- Alternativa manual (avançado):

```bash
# Parar e remover containers e volumes mapeados pelo compose
docker compose down -v

# Parar, remover containers, imagens definidas no compose e volumes
docker compose down --rmi all -v

# Remover imagens não utilizadas (opcional)
docker image prune -a

# Remover volumes não utilizados (opcional)
docker volume prune
```

---

## 💻 Conectar nos Bancos

### 🐘 PostgreSQL

**DataGrip/DBeaver:**
```
Host:     localhost
Port:     5432
Database: postgres
User:     postgres
Password: admin
```

**Linha de comando:**
```bash
docker exec -it postgres_dev psql -U postgres
```

---

### 🐬 MySQL

**DataGrip/DBeaver:**
```
Host:     localhost
Port:     3306
Database: mysql
User:     root
Password: admin
```

**Linha de comando:**
```bash
docker exec -it mysql_dev mysql -u root -padmin
```

---

### 🍃 MongoDB

**DataGrip/DBeaver:**
```
Host:     localhost
Port:     27017
Database: admin
User:     (deixe vazio)
Password: (deixe vazio)
```

**Linha de comando:**
```bash
docker exec -it mongo_dev mongosh
```

---

## ⚙️ Configurações

### Alterar senhas

**Edite `docker-compose.yml`:**
```yaml
environment:
  POSTGRES_PASSWORD: SUA_SENHA_AQUI  # Linha 10
  MYSQL_ROOT_PASSWORD: SUA_SENHA_AQUI  # Linha 25
```

**Depois reinicie:**
```bash
docker compose down
docker compose --profile pg up -d
```

---

### Alterar pasta padrão dos scripts

**Edite os arquivos `.bat` e adicione no início:**
```batch
@echo off
set BASE_DIR=C:\caminho\para\sua\pasta\Infra
cd /d %BASE_DIR%

:: Resto do script...
```

---

### Limites de recursos

Os containers têm limites de RAM configurados:

| Container | RAM Reservada | RAM Máxima |
|-----------|---------------|------------|
| PostgreSQL | 64MB | 128MB |
| MySQL | 128MB | 256MB |
| MongoDB | 128MB | 300MB |

**Total:** ~684MB máximo

Para ajustar, edite `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      memory: 512M  # Aumenta limite
```

---

## 🔧 Comandos Úteis

### Ver containers rodando
```bash
docker ps
```

### Ver uso de recursos
```bash
docker stats
```

### Parar tudo
```bash
docker compose down
```

### Remover TUDO (cuidado! ⚠️)
```bash
docker compose down -v  # Remove containers E dados
```

### Entrar no container
```bash
docker exec -it postgres_dev bash
```

---

## 🐛 Troubleshooting

### Porta já está em uso
```
Error: bind: address already in use
```

**Solução:**
```bash
# Ver processo usando a porta
netstat -ano | findstr :5432

# Matar processo
taskkill /PID <PID> /F
```

---

### Docker não inicia
```
Cannot connect to the Docker daemon
```

**Solução:**
1. Abra Docker Desktop manualmente
2. Aguarde "Engine running"
3. Execute o script novamente

---

### Container não sobe (EXIT 1)
```bash
# Ver logs do container com problema
docker compose logs postgres_dev
```

**Causas comuns:**
- Falta de RAM
- Porta já em uso
- Erro no `docker-compose.yml`

---

## 📁 Estrutura do Projeto

```
Infra/
├── docker-compose.yml       # Definição dos containers
├── Startardbs.bat          # Script para iniciar
├── Stopdbs.bat             # Script para parar
├── Logsdbs.bat             # Script de logs
├── Backupdbs.bat           # Script de backup
├── Restoredbs.bat          # Script de restore
├── Backups/                # Backups gerados (não versionado)
│   └── Backup_DD-MM-YYYY/
└── README.md               # Este arquivo
```

---

## ⚠️ Avisos Importantes

### 🔒 Segurança

> **⚠️ ATENÇÃO:** Senhas padrão `admin` são apenas para desenvolvimento local!
> 
> **NÃO USE EM PRODUÇÃO** ou ambientes compartilhados.
> 
> Para ambientes sérios, use senhas fortes e variáveis de ambiente (`.env`).

### 📦 Backups

> Os arquivos de backup **NÃO** estão no Git (`.gitignore`).
> 
> Faça backup manual dos arquivos importantes para local seguro.

### 🌐 Repositório Público

> Este repositório é para uso pessoal seu
> 
> **as senhas são padrões**

---

## 💡Motivo do projeto

Evitar instalações manuais repetitivas de bancos de dados, configuração de drivers e desperdício de espaço no sistema.

O Infra-dev ajuda a subir, gerenciar e remover bancos via Docker de forma rápida e descartável, mantendo o ambiente limpo e produtivo.

---

**Desenvolvido com ☕ por [Matheus Nunes da Silva](https://github.com/matheus05dev)**

⭐ Se este projeto te ajudou, considere dar uma estrela no GitHub!
