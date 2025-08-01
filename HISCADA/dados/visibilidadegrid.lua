--[[- - - - - - - - - - - - - - - - - - - - - - - - - - 

    Ambiente: HIscada_Pro
     Projeto: Projeto_Colegio
     Empresa: HI Tecnologia
      Versão: 1.1.0.0
 Responsável: Daniel kantor
        Data: 29/09/2022 

 \b Descrição:  \brief
   ... função do script

- - - - - - - - - - - - - - - - - - - - - - - - - - - -]]


local AddUsefulFunctions = require "UsefulFunctions"

local scr = Sender.Screen

Sleep(1000)

local qtd_instancias = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Geral.Quantidade_Instancias")
--print(scr.Grid_Controladores.Height)

local controladores_habilitados = {}

local idx = 1 
-------------------------------------------------------------------------------------------------------------------------------
-- VERIFICA QUATAS INSTANCIAS ESTÃO HABILITADAS
-------------------------------------------------------------------------------------------------------------------------------
for i = 1, qtd_instancias.Value do 
  caminho = 'Kernel.Tags.Local.TagLocalGroup_KN_Instancias.Controlador_' .. i 
  hab_controlado = Tags.Get(caminho)
 -- print(hab_controlado.Value)

  if(hab_controlado.Value == true)then
    controladores_habilitados[idx] = hab_controlado.Value
    idx = idx + 1
  end
end

--print(#controladores_habilitados)
tamanho = 25


-------------------------------------------------------------------------------------------------------------------------------
-- AJUSTA O TAMANHO DO GRID
-------------------------------------------------------------------------------------------------------------------------------
if(#controladores_habilitados == 0) then 

  seta_tamanho = 50
  scr.Grid_Controladores.Height = seta_tamanho 

else

 for i = 1, #controladores_habilitados  do 
   seta_tamanho = tamanho + 25 * i
   scr.Grid_Controladores.Height = seta_tamanho 
 end
  
end


