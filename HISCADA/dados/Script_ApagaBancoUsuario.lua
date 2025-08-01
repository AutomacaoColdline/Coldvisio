------------------------------------------------------------------------------------------------------------------------------- 
--    Projeto: Demo HIscada Pro
--    Cliente: 
--       Data: 01/ago/2013  
--      Resp.: Eng. de Produto da HI Tecnologia
--   Ambiente: HIscada Pro, versão 1.3.03 ou superior
------------------------------------------------------------------------------------------------------------------------------- 
--  Descrição: 
--    Script para executar comandos SQL no banco de dados configurado em um item DataBase
--
--  Objeto Associado: 
--
------------------------------------------------------------------------------------------------------------------------------- 

local AddUsefulFunctions = require "UsefulFunctions"

local Argumento = Sender.Argument

local msg = ""


local cmd = ConsisteTagOpc("Kernel.Tags.Opc.TagOpcGroup_CMD.Comando")

if(cmd == false)then
  print("Falha ao obter Tags")
  return 
end


-- Chama uma leitura do tag
cmd:ReadDevice()

------------------------------------------------------------------------------------------------------------------------------- 
-- Verifica qual o método de manutenção do banco
-------------------------------------------------------------------------------------------------------------------------------
if(Argumento == "Todos")then
  msg = "Deseja realmente eliminar todos os registros?"
elseif(Argumento == "Periodo")then
  msg = "Deseja realmente eliminar todos os registros no Período selecionado?"
else
  msg = "Deseja realmente eliminar todos os registros anteriores a Data selecionada?"
end


------------------------------------------------------------------------------------------------------------------------------- 
-- Confirma com o usuario se realmente ele deseja Limpar o Banco de Dados
------------------------------------------------------------------------------------------------------------------------------- 
local ret = MessageBox("YN2:" .. msg)


------------------------------------------------------------------------------------------------------------------------------- 
-- Resposta do Operador = Não, sai do script
------------------------------------------------------------------------------------------------------------------------------- 
if(ret ~= 0)then
  return
end



------------------------------------------------------------------------------------------------------------------------------- 
--    NomeDataBase: Crie abaixo as mensagens que serão exibidas pelos MessageBox de interface com o usuário.
------------------------------------------------------------------------------------------------------------------------------- 
local MsgCmdSucesso   = "Comando executado com sucesso!"
local MsgCmdFalha     = "Falha na execução do comando!"
local MsgFalhaConexao = "Falha de conexão com o banco de dados!"



------------------------------------------------------------------------------------------------------------------------------- 
--    CaminhoTagDataHora: Insira nesta variável o caminho completo para o Tag que contém a data/hora para eliminação de 
--    registros da tabela.
------------------------------------------------------------------------------------------------------------------------------- 
local CaminhoTagDataHora = "Kernel.Tags.Local.TagLocalGroup_KN_Configuracao.TagLocal_DataHoraEliminaRegistrosBanco"

-- Tag que contém a data/hora de limite para a eliminação dos registros
local TagLocalDataHora  = Tags.Get(CaminhoTagDataHora)
-- Verifica se o Tag foi obtido com sucesso
if(TagLocalDataHora == nil)then
  return
end
local DataHoraLimite  = TagLocalDataHora.Value

-- Formata a Data/Hora no padrão SQLite
local DataHoraFormato = DataHoraLimite:GetFormatString("yyyy-mm-dd hh:mm:ss")


------------------------------------------------------------------------------------------------------------------------------- 
--    CaminhoTagDataHoraPeriodo: Insira nesta variável o caminho completo para o Tag que contém a data/hora para 
--    eliminação de registros da tabela.
------------------------------------------------------------------------------------------------------------------------------- 
local CaminhoTagDataHoraPeriodoInicio = "Kernel.Tags.Local.TagLocalGroup_KN_Configuracao.TagLocal_InicialPeriodoEliminaRegistroBanco"
local CaminhoTagDataHoraPeriodoFim    = "Kernel.Tags.Local.TagLocalGroup_KN_Configuracao.TagLocal_FinalPeriodoEliminaRegistroBanco"

-- Tag que contém a data/hora de limite para a eliminação dos registros
local TagLocalDataHoraPeriodoInicio  = Tags.Get(CaminhoTagDataHoraPeriodoInicio)
local TagLocalDataHoraPeriodoFim     = Tags.Get(CaminhoTagDataHoraPeriodoFim)

-- Verifica se o Tag foi obtido com sucesso
if(TagLocalDataHoraPeriodoInicio == nil)then
  return
end

local DataHoraLimiteInicial  = TagLocalDataHoraPeriodoInicio.Value
local DataHoraLimiteFinal    = TagLocalDataHoraPeriodoFim .Value

-- Formata a Data/Hora no padrão SQLite
local DataHoraFormatoInicial = DataHoraLimiteInicial:GetFormatString("yyyy-mm-dd hh:mm:ss")
local DataHoraFormatoFinal   = DataHoraLimiteFinal:GetFormatString("yyyy-mm-dd hh:mm:ss")


-------------------------------------------------------------------------------------------------------------------------------
--    NomeDataBase: Insira nesta variável uma string com o caminho completo para o DataBase que se deseja acessar
-------------------------------------------------------------------------------------------------------------------------------
local NomeDataBase = "Globals.DataBases.DataBase_Postgres"


-------------------------------------------------------------------------------------------------------------------------------
-- Abre conexão com o Database  
-------------------------------------------------------------------------                       
local retOpenDB = Database.Get(NomeDataBase)


------------------------------------------------------------------------------------------------------------------------------- 
-- Atribuir a esta variável o nome da tabela desejada
------------------------------------------------------------------------------------------------------------------------------- 
local NomeTabela  = {"dataCollection"}


------------------------------------------------------------------------------------------------------------------------------- 
--    CmdSQL: Insira nesta variável uma string com o comando SQL a ser executado no Banco
-------------------------------------------------------------------------------------------------------------------------------
local CmdSQL = ""


for i = 1, #NomeTabela do

  if(Argumento == "Todos")then
    CmdSQL = string.format("DELETE FROM %s ;", NomeTabela[i])
  elseif(Argumento == "Periodo")then
    CmdSQL = string.format("DELETE FROM %s WHERE data_timestamp BETWEEN '" .. DataHoraFormatoInicial .. "' AND '" .. DataHoraFormatoFinal.. "';",NomeTabela[i]) 
  else
    CmdSQL = string.format("DELETE FROM %s WHERE data_timestamp < '" .. DataHoraFormato.. "';",NomeTabela[i])
  end
  
 print(CmdSQL)
  -------------------------------------------------------------------------------------------------------------------------------
  -- Verifica se a conexão com o Database foi obtida com sucesso
  -------------------------------------------------------------------------------------------------------------------------------
  if(retOpenDB ~= nil)then

    -- Executa o comando no banco
    local cursor,error = retOpenDB:Execute(CmdSQL)

    -- Verifica se ocorreu algum erro
    if(error ~= nil) then
      print("Falha na execução do comando SQL: " .. tostring(error))
      MessageBox("ERW: "..MsgCmdFalha)
      return
    else
	
	if(i == #NomeTabela)then 
        print("Comando executato com sucesso!")
        MessageBox("INW: "..MsgCmdSucesso)
	end 
	
    end  

  else
    print("Falha na abertura de conexão com o banco local!")
   MessageBox("ERW: "..MsgFalhaConexao)
   return
 end
  
  
  
end


-- Envia comando para clp
cmd.Value = 31100
cmd:WriteValue()





