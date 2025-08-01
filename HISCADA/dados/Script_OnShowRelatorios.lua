--[[- - - - - - - - - - - - - - - - - - - - - - - - - - 

    Ambiente: HIscada_Pro
     Projeto: Projeto_Colegio
     Empresa: HI Tecnologia
      Versão: 1.1.0.0
 Responsável: Daniel kantor
        Data: 18/10/2022 

 \b Descrição:  \brief
   ... função do script

- - - - - - - - - - - - - - - - - - - - - - - - - - - -]] 


--Scripts.Run("Viewers.Scripts.ScriptGroup_BancoDeDados.Insere_Ambiente")


Sleep(300)


local tag_inicio = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_Inicial")
local tag_final  = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_Final")

--print(data_atual)

tag_inicio.Value  = DateTime(DateTime():GetFormatString('dd/mm/yyyy 00:00:00'))
tag_final.Value   = DateTime(DateTime():GetFormatString('dd/mm/yyyy 23:59:59'))

tag_inicio:WriteValue()
tag_final:WriteValue()

local clp_conectado = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Id_Ultima_conexao")

local scr  = Sender.Screen
                                       
local controlador = Globals.GetTextList("GlbTextListGroup_Geral.GlbTextList_Controladores")
controlador:Clear() 

local tag_combo = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_SelecaoControlador") 
tag_combo.Value = 0
tag_combo:WriteValue()

local CmdSQL = ""

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Abre conexão com o Database 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------                        
local retOpenDB, error = Scripts.Run("Viewers.Scripts.ScriptGroup_BancoDeDados.Script_AbreConexaoPostgres", 'insertcombobox')
  
   if(error ~= nil)then
     print("Falha na abertura de conexão com o banco local!")
     -- MessageBox("ERW: Falha na conexão com o banco de dados!")
      
     return
   end 

  if(retOpenDB == nil)then
    print("Falha na abertura de conexão com o banco local!")
   --  MessageBox("ERW: Falha na conexão com o banco de dados!")
   return
  end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Monta select 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CmdSQL = string.format("SELECT DISTINCT name_device FROM dataCollection WHERE name_device != '' AND status_plc = %d ORDER BY name_device",clp_conectado.Value)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- controladores
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--print(CmdSQL_nome_area)
   
-- Executa o comando no banco 
local cursor,error = retOpenDB:Execute(CmdSQL)

 -- Verifica se ocorreu algum erro
   if(error ~= nil) then
      print("Falha na execução do comando SQL: " .. tostring(error))
      return
   end

 -- Se for um comando de consulta 
  local TipoComando = string.find(CmdSQL,"SELECT")
  if(TipoComando ~= nil)then
    --print('Numero de registros recuperados ' .. cursor.NumRows)
    --print("Error" ..  tostring(error))

    controlador:AddText("Selecione um Ambiente... ", 0)

    local row = cursor:Fetch() -- recupera dicionario {nome_coluna=valor}
    local idx = 0
    while row do
      -- print("Registro")
      -- quando não se souber o nome das colunas

      for coluna in pairs(row) do
        --print("\t" .. coluna .. "->" .. row[coluna])
     
        if(coluna == "name_device")then
          erro =  controlador:AddText(row[coluna], idx + 1)
          --print(erro)
        end            
      idx = idx + 1      
      end
      -- recupera o próximo registro
      row = cursor:Fetch()
    end
    cursor:Close()
  end

  --controlador:AddText("Todos Ambientes", -1)

-- scr.ComboBox_Controladores.RefreshNow = 1 



-- tags tipo relatorio
local tag_tipo    = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_TipoGraficoTabular") 
local tag_tabular = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_Tabular") 
local tag_grafico = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_Grafico") 


tag_tabular.Value = true
tag_grafico.Value = false
tag_tipo.Value = 0

tag_tipo:WriteValue()
tag_tabular:WriteValue()
tag_grafico:WriteValue()


-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Fecha conexão com o Banco 
-------------------------------------------------------------------------------------------------------------------------------------------------------------
local ret = retOpenDB:Disconnect()




