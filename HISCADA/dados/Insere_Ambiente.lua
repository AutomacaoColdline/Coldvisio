--[[- - - - - - - - - - - - - - - - - - - - - - - - - - 

    Ambiente: HIscada_Pro
     Projeto: Projeto_Colegio
     Empresa: HI Tecnologia
      Versão: 1.1.0.0
 Responsável: Daniel kantor
        Data: 05/10/2022 

 \b Descrição:  \brief
   ... função do script

- - - - - - - - - - - - - - - - - - - - - - - - - - - -]] 

local AddUsefulFunctions = require "UsefulFunctions"

----------------------------------------------------------------------------------------------------------------------------------------
-- Abre a conexão ou obtem conexão
----------------------------------------------------------------------------------------------------------------------------------------  
local conPostgre, error = Scripts.Run("Viewers.Scripts.ScriptGroup_BancoDeDados.Script_AbreConexaoPostgres", "con_analisador")
  
if(error ~= nil)then
  print("Ao abrir conexão com o banco: " .. error)
  return
end

if(conPostgre == nil)then
  print("Ao abrir conexão com o banco")
  return
end

----------------------------------------------------------------------------------------------------------------------------------------  
--Obtem os Tags.
----------------------------------------------------------------------------------------------------------------------------------------  

--Obtem quantidade de instancia.
local qtd_instancias = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Geral.Quantidade_Instancias")


----------------------------------------------------------------------------------------------------------------------------------------  
-- Verifica instancias habilitadas e realiza o insert
----------------------------------------------------------------------------------------------------------------------------------------  
for i = 1, qtd_instancias.Value do 

     caminho_isnt_habilitada_tag_local = "Kernel.Tags.Local.TagLocalGroup_KN_Instancias.Controlador_" .. i
     isnt_habilitada_tag_local = Tags.Get(caminho_isnt_habilitada_tag_local)
 
     if(isnt_habilitada_tag_local.Value == true)then

       caminho_nome_tag_opc            = "Instances.InstanceGroup_Controladores.Controlador_" .. i .. ".Tags.Opc.Nome_Controlador.Nome_Controlador"
       caminho_modelo_tag_opc          = "Instances.InstanceGroup_Controladores.Controlador_" .. i .. ".Tags.Opc.Modelo_Controlador.Modelo"
       caminho_end_tag_opc             = "Instances.InstanceGroup_Controladores.Controlador_" .. i .. ".Tags.Opc.Endereco_Controlador.Endereco"

       nome_controlador_opc            = ConsisteTagOpc(caminho_nome_tag_opc)
       modelo_controlador_opc          = ConsisteTagOpc(caminho_modelo_tag_opc)
       end_controlador_opc             = ConsisteTagOpc(caminho_end_tag_opc)


       -- Verifica se tag esta ok
       if(nome_controlador_opc           == false or           
          modelo_controlador_opc         == false or       
          end_controlador_opc            == false )then

         print("Falha ao obter Tags no insert historico")
         return 
       end

       local CmdSQL_select = string.format("SELECT nome_controlador FROM ambiente WHERE nome_controlador = '%s'",nome_controlador_opc.Value)
       print(CmdSQL_select)
   
       -- Executa o comando no banco 
       local cursor1,error1 = conPostgre:Execute(CmdSQL_select)

        row = cursor1:Fetch() -- recupera dicionario {nome_coluna=valor}

        if row ~= nil then 
          print("Ja existe esse ambiente")

       else
         ------------------------------------------------------------------------------------------------------------------------------------------------------------
         -- Insere No banco 
         -------------------------------------------------------------------------------------------------------------------------------------------------------------					   
	  local CmdSQL = string.format("INSERT INTO public.ambiente(nome_controlador,modelo,endereco)\
                             VALUES('%s',%d,%d)",nome_controlador_opc.Value,modelo_controlador_opc.Value,end_controlador_opc.Value) 
         --print(CmdSQL)
   
         -- Executa o comando no banco 
         local cursor,error = conPostgre:Execute(CmdSQL)

         -- Verifica se ocorreu algum erro
         if(error ~= nil) then
          print("Falha na execução do comando SQL: " .. tostring(error))
          return
         end


        cursor1:Close()
      end    

     else


     end

end



-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Fecha conexão com o Banco MySQL
-------------------------------------------------------------------------------------------------------------------------------------------------------------
local ret = conPostgre:Disconnect()




  







