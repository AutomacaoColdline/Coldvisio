--[[- - - - - - - - - - - - - - - - - - - - - - - - - - 

    Ambiente: HIscada_Pro
     Projeto: Projeto Sup Controle Refrigeração
     Empresa: HI Tecnologia
      Versão: 1.0.00
 Responsável: HI Tecnologia
        Data: 17/09/2024 

 \b Descrição:  \brief
   ... função do script

- - - - - - - - - - - - - - - - - - - - - - - - - - - -]] 

local AddUsefulFunctions = require "UsefulFunctions"

--Obtém o Tag 
local tag_opc_numero_controladores = ConsisteTagOpc("Kernel.Tags.Opc.TagOpcGroup_Habilita_Controladores.NumeroControladores")

--pega o valor do tag 
local numero_controcalor = tag_opc_numero_controladores.Value


-- Verifica qual controlador esta habilitado.
for i = 1, numero_controcalor do 

  local caminho_isnt_habilitada_tag_local = "Kernel.Tags.Local.TagLocalGroup_KN_Instancias.Controlador_" .. i
  local caminho_isnt_habilitada_tag_opc   = "Kernel.Tags.Opc.TagOpcGroup_Habilita_Controladores.Controlador_" .. i

  local isnt_habilitada_tag_local = Tags.Get(caminho_isnt_habilitada_tag_local)
  local isnt_habilitada_tag_opc   = ConsisteTagOpc(caminho_isnt_habilitada_tag_opc)

  if(isnt_habilitada_tag_opc == false)then 
    print("Falha ao obter o tag opc script = " .. ScriptName)
    return
   end


  isnt_habilitada_tag_opc:ReadDevice()

  if(isnt_habilitada_tag_local.Value == false)then  
     isnt_habilitada_tag_opc.Value   =  0
  elseif(isnt_habilitada_tag_local.Value == true)then  
    isnt_habilitada_tag_opc.Value   =  1
  end


  isnt_habilitada_tag_opc:WriteValue()


end 

