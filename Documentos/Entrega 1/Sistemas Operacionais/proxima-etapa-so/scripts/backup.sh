#!/bin/bash
# Define que este arquivo deve ser executado usando o interpretador Bash.

# Caminho onde estão os dados que serão copiados.
ORIGEM="$HOME/proxima-etapa-so/dados"

# Caminho onde os arquivos de backup serão armazenados.
DESTINO="$HOME/proxima-etapa-so/backups"

# Caminho do arquivo que armazenará o histórico das execuções.
LOG="$HOME/proxima-etapa-so/logs/backup.log"


# Cria uma data e hora para identificar cada backup.
# Exemplo: 2026-09-24_00-15-30
DATA=$(date +"%Y-%m-%d_%H-%M-%S")

# Define o nome do arquivo de backup.
# Exemplo: backup_2026-09-24_00-15-30.tar.gz
ARQUIVO="backup_$DATA.tar.gz"


# Cria a pasta de destino caso ela ainda não exista.
mkdir -p "$DESTINO"

# Cria a pasta onde ficará o arquivo de log caso ela ainda não exista.
mkdir -p "$(dirname "$LOG")"


# Exibe uma linha para separar uma execução da outra no log.
# O comando tee mostra a mensagem no terminal e também salva no arquivo.
echo "==========================================" | tee -a "$LOG"

# Registra a data e hora em que o backup começou.
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Iniciando backup..." | tee -a "$LOG"


# Verifica se o diretório de origem realmente existe.
if [ ! -d "$ORIGEM" ]; then

    # Caso a pasta não exista, registra o erro no log.
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERRO: diretório não encontrado: $ORIGEM" | tee -a "$LOG"

    # Encerra o programa indicando que ocorreu um erro.
    exit 1
fi


# Verifica o tamanho total dos dados que serão copiados.
# du calcula o espaço utilizado e cut pega somente o tamanho.
TAMANHO=$(du -sh "$ORIGEM" | cut -f1)

# Mostra o tamanho dos dados no terminal e no arquivo de log.
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Tamanho dos dados: $TAMANHO" | tee -a "$LOG"


# Cria o backup compactado no formato .tar.gz.
# -c = cria o arquivo
# -z = utiliza gzip para compactar
# -f = define o nome do arquivo
# 2>> = envia possíveis erros para o arquivo de log.
tar -czf "$DESTINO/$ARQUIVO" "$ORIGEM" 2>> "$LOG"


# Verifica se o comando tar foi executado corretamente.
# $? contém o código de saída do último comando.
# 0 significa sucesso.
if [ $? -eq 0 ]; then

    # Obtém o tamanho do arquivo de backup criado.
    TAMANHO_BACKUP=$(du -h "$DESTINO/$ARQUIVO" | cut -f1)

    # Registra que o backup foi criado com sucesso.
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup criado: $ARQUIVO" | tee -a "$LOG"

    # Registra o tamanho do backup.
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Tamanho do backup: $TAMANHO_BACKUP" | tee -a "$LOG"

else

    # Caso o tar apresente algum erro, registra a falha.
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERRO ao criar o backup." | tee -a "$LOG"

    # Encerra o script informando que houve erro.
    exit 1
fi


# Procura todos os backups existentes no diretório.
# find localiza os arquivos backup_*.tar.gz.
# sort organiza os arquivos em ordem.
BACKUPS=$(find "$DESTINO" -name "backup_*.tar.gz" -type f | sort)


# Cria um contador para controlar a quantidade de backups.
CONTADOR=0


# Percorre todos os backups encontrados.
for ARQUIVO_ANTIGO in $BACKUPS; do

    # Aumenta o contador em 1 a cada backup encontrado.
    CONTADOR=$((CONTADOR + 1))


    # Verifica se já existem mais de 5 backups.
    if [ "$CONTADOR" -gt 5 ]; then

        # Remove o backup mais antigo.
        rm -f "$ARQUIVO_ANTIGO"

        # Registra no log qual backup foi removido.
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup antigo removido: $ARQUIVO_ANTIGO" | tee -a "$LOG"
    fi

done


# Registra que todo o processo terminou com sucesso.
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup finalizado com sucesso." | tee -a "$LOG"

# Finaliza visualmente o registro daquela execução.
echo "==========================================" | tee -a "$LOG"

