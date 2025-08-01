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

Sleep(300)

local scr  = Sender.Screen
                                       
local controlador = Globals.GetTextList("GlbTextListGroup_Geral.GlbTextList_CLPS")
controlador:Clear() 


local tag_combo     = Tags.Get("Kernel.Tags.Local.TagLocalGroup_CadastroControladores.ComboBox") 
local clp_conectado = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Id_Ultima_conexao")


local CmdSQL = ""

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Abre conexão com o Database 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------                        
local retOpenDB, error = Scripts.Run("Viewers.Scripts.ScriptGroup_BancoDeDados.Script_AbreConexaoPostgres", 'insertcomboboxinicial')
  
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

CmdSQL = tostring("SELECT id, device_name FROM plc WHERE status = 1 ORDER BY id")


---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- controladores
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--print(CmdSQL)
   
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

    local row = cursor:Fetch() -- recupera dicionario {nome_coluna=valor}
    local idx = 0


    while row do
      -- print("Registro")
      -- quando não se souber o nome das colunas

      for coluna in pairs(row) do
        --print("\t" .. coluna .. "->" .. row[coluna])
     
        if(coluna == "device_name")then
          erro =  controlador:AddText(row[coluna], row['id'])
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

scr.ComboBox_CLPs.RefreshNow = 1 


-- atualiza combobox
tag_combo.Value = clp_conectado.Value
tag_combo:WriteValue()






