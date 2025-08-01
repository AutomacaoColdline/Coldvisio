--[[- - - - - - - - - - - - - - - - - - - - - - - - - - 

    Ambiente: HIscada_Pro
     Projeto: Projeto Sup Controle Refrigeração
     Empresa: HI Tecnologia
      Versão: 1.0.00
 Responsável: HI Tecnologia
        Data: 25/07/2024 

 \b Descrição:  \brief
   ... função do script

- - - - - - - - - - - - - - - - - - - - - - - - - - - -]] 

local AddUsefulFunctions  = require "UsefulFunctions"

local path   = "Instances."..CellInstance.Group.. "." .. CellInstance.Name

inst = CellInstance.Name

local tipo, modo = string.match(inst,'(.*)_(.*)')
--print(tonumber(modo))


-------------------------------------------------------------------------------------------------------------------------------
-- Obtém Tag
-------------------------------------------------------------------------------------------------------------------------------
local data_hora_inicial = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_DataHoraInicioTaxas") 
local data_hora_final   = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_DataHoraFimTaxas") 

local string_slq = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_String_Taxas")

-------------------------------------------------------------------------------------------------------------------------------
-- variaveis
-------------------------------------------------------------------------------------------------------------------------------
local numero_controlador    = tonumber(modo)
local aux_data_hora_iinical = data_hora_inicial.Value
local aux_data_hora_final   = data_hora_final.Value

-------------------------------------------------------------------------------------------------------------------------------
-- Select para o banco de dados
-------------------------------------------------------------------------------------------------------------------------------
--Select para a query
local cmd_query = string.format("SELECT * FROM rates WHERE timestamp BETWEEN '%s' AND '%s' AND device_controller_adress = %d ORDER BY date asc",aux_data_hora_iinical,aux_data_hora_final,numero_controlador)

print(cmd_query) 

string_slq.Value = cmd_query
string_slq:WriteValue()


-------------------------------------------------------------------------------------------------------------------------------
-- Verifica qual é o relatório a ser aberto. Tabular ou Gráfico.
-------------------------------------------------------------------------------------------------------------------------------
local CaminhoRelatorio = ""
                   
CaminhoRelatorio = "Globals.Reports.ReportsGroup_taxas.Report_taxas"                   
                       
--print(CaminhoRelatorio)

-------------------------------------------------------------------------------------------------------------------------------
-- Verifica o argumento recebido
-------------------------------------------------------------------------------------------------------------------------------
if(CaminhoRelatorio == nil)then
  MessageBox("ERW: Falha na execução do comando!")
  return
end


Sleep(800)
-------------------------------------------------------------------------------------------------------------------------------
-- Comando de Preview do Relatório
-------------------------------------------------------------------------------------------------------------------------------
local rep = Reports.GetReport(CaminhoRelatorio)


-------------------------------------------------------------------------------------------------------------------------------
-- Verifica se o relatório foi obtido
-------------------------------------------------------------------------------------------------------------------------------
if(rep == nil)then
  MessageBox("ERW: Falha na execução do comando!")
  return
end

rep:ShowReport()
