library(readxl)
library(dplyr)
library(gtools)
library(dplyr)
library(plyr)
library(openxlsx)

arquivos = list.files(pattern='.xlsx')
arquivos_aptos = c()

for(i in 1:length(arquivos)) {
  if(i>1){
  data = substr(arquivos[i],start = 37,stop = 44)
  data = as.Date(data,format = "%d%m%Y")
  if(data > as.Date("2015-08-01")){
    arquivos_aptos = c(arquivos_aptos,arquivos[i])
  }else{
    print(paste0(arquivos[i], " Não serve"))
  }
  }
}



for (j in 1:length(arquivos_aptos)) {
    print(j)
    print(arquivos_aptos[j])
    # lendo o arquivo
    aux = read.xlsx(arquivos_aptos[j],colNames = FALSE,detectDates = TRUE)
    # detectando a linha que se encontra o nome "real" das dolunas
    INDEX = which(aux == "PROGRAM.")
    # lendo o arquivo pulando as linhas que não importam
    aux = read.xlsx(arquivos_aptos[j],colNames = FALSE,detectDates = TRUE, startRow = INDEX)
    # pegando a primeira linha com os nomes de colunas e transformando em vetor
    nomes_desejados = unname(unlist(aux[1,]))
    # acertando o nome das colunas com o vetor retirado do data frame
    aux = aux %>% setNames(nomes_desejados)
    # eliminando a primeira linha com os nomes das colunas
    aux = aux[-1,]
    # pegando o ano e mes do nome do arquivo
    ano = substr(arquivos_aptos[j],start = 41, stop = 44)
    mes = substr(arquivos_aptos[j],start = 39, stop = 40)
    # transformando em data
    data = paste0(mes,"/",ano)
    aux$`DT EVENTO` = as.Date(aux$`DT EVENTO`,origin = "1900-01-01", tz = "America/Sao_Paulo")
    aux$`DT INÍC. OF.` = as.Date(aux$`DT INÍC. OF.`,origin = "1900-01-01", tz = "America/Sao_Paulo")
    # criando uma coluna nova com mes/ano
    col_mes = rep(data,length(aux$PROGRAM.))
    aux = cbind(col_mes,aux)
    # renomeando a coluna criada
    aux = aux %>% dplyr::rename(MÊS = col_mes)
    # convertendo para data
    aux$`DT AT.` = as.Date(as.numeric(aux$`DT AT.`),origin = "1900-01-01", tz = "America/Sao_Paulo")
    # escrevendo o arquivo limpo na pasta de arquivos limpos
    write.xlsx(aux,paste0("arquivos limpos\\",arquivos_aptos[j]))
    
}

# Lendo e empilhando os dataframes em sequencia
for (k in 1:length(arquivos_aptos)){
  print(k)
  print(arquivos_aptos[k])
  if(k==1){
    # lendo data frame "inicial" para começar a empilhar
    DF = read.xlsx(paste0("arquivos limpos\\",arquivos_aptos[k]),detectDates = TRUE)
  }else{
    # lendo e empilhando a partir do primeiro lido acima
  DF <- rbind(DF, read.xlsx(paste0("arquivos limpos\\",arquivos_aptos[k]),detectDates = TRUE))
  }
} 
# escrevendo o novo arquivo com todos os dataframes
write.xlsx(DF, "arquivos limpos\\Tabela_canais_programadoras_acumulado.xlsx", row.names=FALSE, quote=FALSE)



#quando chegar arquivo novo e quiser empilhar do mesmo modo, usar o código abaixo substituindo o 
# "nome do aquivo aqui" pelo nome do arquivo desejado, incluindo sua extenção

nome_arquivo = "nome do arquivo aqui"

data_f = read.xlsx(nome_arquivo,colNames = FALSE,detectDates = TRUE)
INDEX = which(aux == "")
data_f = read.xlsx(nome_arquivo,colNames = FALSE,detectDates = TRUE, startRow = INDEX)
nomes_desejados = unname(unlist(data[1,]))
data_f = data_f %>% setNames(nomes_desejados)
data_f = data_f[-1,]
ano = substr(nome_arquivo,start = 41, stop = 44)
mes = substr(nome_arquivo,start = 39, stop = 40)
data = paste0(mes,"/",ano)
data_f$`DT EVENTO` = as.Date(data_f$`DT EVENTO`,origin = "1900-01-01", tz = "America/Sao_Paulo")
data_f$`DT INÍC. OF.` = as.Date(data_f$`DT INÍC. OF.`,origin = "1900-01-01", tz = "America/Sao_Paulo")
col_mes = rep(data,length(data_f$PROGRAM.))
data_f = cbind(col_mes,data_f)
data_f = data_f %>% dplyr::rename(MÊS = col_mes)
data_f$`DT AT.` = as.Date(as.numeric(data_f$`DT AT.`),origin = "1900-01-01", tz = "America/Sao_Paulo")
write.xlsx(data_f,paste0("arquivos limpos\\",nome_arquivo))


# lendo o arquivo já empilhado
DF = read.xlsx(paste0("arquivos limpos\\Tabela_acumulado.xlsx"),detectDates = TRUE)

#empilhando o arquivo novo na pilha antiga
DF <- rbind(DF, read.xlsx(paste0("arquivos limpos\\",nome_arquivo),detectDates = TRUE))

# escrevendo o novo arquivo com todos os dataframes
write.xlsx(DF, "arquivos limpos\\Tabela_acumulado.xlsx", row.names=FALSE, quote=FALSE)
