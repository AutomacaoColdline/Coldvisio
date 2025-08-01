-------------------------------------------------------------------------------------------------------------------------------
--    HI Tecnologia Ind. Com. Ltda - www.hitecnologia.com.br
-------------------------------------------------------------------------------------------------------------------------------
--    Projeto: App Model HIscada Pro
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
local CaminhoTagDataHora = "Kernel.Tags.Local.TagLocalGroup_KN_Relatorio.TagLocal_DataEliminacaoAlarmes"

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
--    NomeTabela: Insira nesta variável o Nome da Tabela existente no banco da aplicação em que se deseja executar o comando SQL.
-------------------------------------------------------------------------------------------------------------------------------

local NomeTabela = "systemactionhistory"       -- Contém os registros do histórico de alarmes e eventos 
-- local NomeTabela = "taglocal"      -- Contém os registros dos valores dos Tags Locais da aplicação
-- local NomeTabela = "active_alarms" -- Contém os registros de alarmes ativos



-------------------------------------------------------------------------------------------------------------------------------
--    CmdSQL: Insira nesta variável uma string com o comando SQL a ser executado no Banco
-------------------------------------------------------------------------------------------------------------------------------
 
-- Este exemplo deleta da tabela "NomeTabela" os registros inseridos antes da Data/Hora passada como parâmetro
local CmdSQL = string.format("DELETE FROM %s WHERE timestamp < '" .. DataHoraFormato.. "';",NomeTabela)
-- local CmdSQL = string.format("SELECT *FROM %s;",NomeTabela)



-------------------------------------------------------------------------------------------------------------------------------
--    NomeDataBase: Insira nesta variável uma string com o caminho completo para o DataBase que se deseja acessar
-------------------------------------------------------------------------------------------------------------------------------
local NomeDataBase = "Globals.DataBases.DataBase_HistoricoAlarmes"



-------------------------------------------------------------------------------------------------------------------------------
-- Abre conexão com o Database        
-------------------------------------------------------------------------------------------------------------------------------                 
local retOpenDB = Database.Get(NomeDataBase)


-------------------------------------------------------------------------------------------------------------------------------
-- Verifica se a conexão com o Database foi obtida com sucesso e executa o comando SQL
-------------------------------------------------------------------------------------------------------------------------------
if(retOpenDB ~= nil)then

  -- Executa o comando no banco
  cursor,error = retOpenDB:Execute(CmdSQL)

  -- Verifica se ocorreu algum erro
  if(error ~= nil) then
    print("Falha na execução do comando SQL: " .. tostring(error))
    MessageBox("ERW: ".. MsgCmdFalha)
  else
    print("Comando executato com sucesso!")
    MessageBox("INW: ".. MsgCmdSucesso)
  end

  -- Se for um comando de consulta 
  local TipoComando = string.find(CmdSQL,"SELECT")
  if(TipoComando ~= nil)then
    print('Numero de registros recuperados ' .. cursor.NumRows)
    print("Error" ..  tostring(error))
    row = cursor:Fetch() -- recupera dicionario {nome_coluna=valor}
    while row do
      print("Registro")
      -- quando não se souber o nome das colunas
      for coluna in pairs(row) do
        print("\t" .. coluna .. "->" .. row[coluna])
      end
      -- recupera o próximo registro
      row = cursor:Fetch()
    end
    cursor:Close()
  end
else
  print("Falha na abertura de conexão com o banco local!")
  MessageBox("ERW: "..MsgFalhaConexao)
end







