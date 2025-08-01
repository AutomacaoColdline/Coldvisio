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


local Argumento = Sender.Argument

local msg = ""

------------------------------------------------------------------------------------------------------------------------------- 
-- Verifica qual o método de manutenção do banco
-------------------------------------------------------------------------------------------------------------------------------
if(Argumento == "Todos")then
  msg = "Deseja realmente eliminar as taxas de comunicação?"
else
  msg = "Deseja realmente eliminar todas as taxas de comunicação anteriores a Data selecionada?"
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
local CaminhoTagDataHora = "Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_DataHoraEliminaTaxas"

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
-- Atribui nome da tabela do Histórico de Alarmes
------------------------------------------------------------------------------------------------------------------------------- 
local NomeTabela = "rates"       -- Contém os registros do histórico de alarmes e eventos 


------------------------------------------------------------------------------------------------------------------------------- 
--    CmdSQL: Insira nesta variável uma string com o comando SQL a ser executado no Banco
-------------------------------------------------------------------------------------------------------------------------------
local CmdSQL = ""

if(Argumento == "Todos")then
  CmdSQL = string.format("DELETE FROM %s ;", NomeTabela)
else
  CmdSQL = string.format("DELETE FROM %s WHERE timestamp < '" .. DataHoraFormato.. "';",NomeTabela)
end




-------------------------------------------------------------------------------------------------------------------------------
--    NomeDataBase: Insira nesta variável uma string com o caminho completo para o DataBase que se deseja acessar
-------------------------------------------------------------------------------------------------------------------------------
local NomeDataBase = "Globals.DataBases.DataBase_Postgres"



-------------------------------------------------------------------------------------------------------------------------------
-- Abre conexão com o Database  
-------------------------------------------------------------------------------------------------------------------------------                       
local retOpenDB = Database.Get(NomeDataBase)



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
  else
    print("Comando executato com sucesso!")
    MessageBox("INW: "..MsgCmdSucesso)
  end

else
  print("Falha na abertura de conexão com o banco local!")
  MessageBox("ERW: "..MsgFalhaConexao)
end

