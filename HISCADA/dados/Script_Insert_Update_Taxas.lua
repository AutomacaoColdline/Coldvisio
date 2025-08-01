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

local AddUsefulFunctions = require "UsefulFunctions" --chama função do consiste Tags

----------------------------------------------------------------------------------------------------------------------------------------  
--Obtem Data e Hora Atual
----------------------------------------------------------------------------------------------------------------------------------------  
local DataAtual     = os.date('%d/%m/%Y') -- Data Atual
local DataHoraAtual = DateTime() -- Data e Hora Atual

----------------------------------------------------------------------------------------------------------------------------------------  
--Inicia variaveis
----------------------------------------------------------------------------------------------------------------------------------------  
local tipo_comando_banco = 1

----------------------------------------------------------------------------------------------------------------------------------------  
--Obtem os Tags
----------------------------------------------------------------------------------------------------------------------------------------  
--Obtem quantidade de instancia.
local qtd_instancias = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Geral.Quantidade_Instancias")

----------------------------------------------------------------------------------------------------------------------------------------
-- Abre a conexão ou obtem conexão
----------------------------------------------------------------------------------------------------------------------------------------  
-- trecho omitido mantido como está (require, datas, variáveis...)

print("Iniciando Script_Insert_Update_Taxas")

-- Valida conexão com banco
local conPostgre, error = Scripts.Run("Kernel.Scripts.ScriptGroup_BancoDeDados.Script_AbreConexaoPostgres", "con_taxas")
if(error ~= nil) then
  print("ERRO: Falha ao abrir conexão com o banco: " .. error)
  return
end
if(conPostgre == nil) then
  print("ERRO: Conexão com banco retornou nil")
  return
end

print("Conexão com banco estabelecida com sucesso")

-- Laço pelas instâncias
for i = 1, qtd_instancias.Value do
  caminho_isnt_habilitada_tag_local = "Kernel.Tags.Local.TagLocalGroup_KN_Instancias.Controlador_" .. i
  isnt_habilitada_tag_local = Tags.Get(caminho_isnt_habilitada_tag_local)

  if(isnt_habilitada_tag_local.Value == true) then
    print("Instância habilitada: " .. i)

    -- Consistência de tags
    tag_opc_ambiente        = ConsisteTagOpc("Instances.InstanceGroup_Controladores.Controlador_" .. i .. ".Tags.Opc.Nome_Controlador.Nome_Controlador")
    tag_opc_status          = ConsisteTagOpc("Instances.InstanceGroup_Controladores.Controlador_" .. i .. ".Tags.Opc.Status_Controlador.Status_Controlador")
    tag_opc_comunicacao_ok  = ConsisteTagOpc("Instances.InstanceGroup_Controladores.Controlador_" .. i .. ".Tags.Opc.Comunicacao_Ok.Comunicacao_Ok")
    tag_opc_comunicacao_nok = ConsisteTagOpc("Instances.InstanceGroup_Controladores.Controlador_" .. i .. ".Tags.Opc.Comunicacao_NOk.Comunicacao_NOk")

    if(not tag_opc_ambiente or not tag_opc_status or not tag_opc_comunicacao_ok or not tag_opc_comunicacao_nok) then
      print("ERRO: Tag inconsistente na instância " .. i)
      return
    end

    -- Variáveis
    controlador     = i
    ambiente        = tag_opc_ambiente.Value
    status          = tag_opc_status.Value
    comunicacao_ok  = tag_opc_comunicacao_ok.Value
    comunicacao_nok = tag_opc_comunicacao_nok.Value

    -- SELECT
    local sql_select_registro = string.format("SELECT * FROM rates WHERE date = '%s' AND device_controller_adress = %d", DataAtual, controlador)
    print("Executando SELECT para verificação: " .. sql_select_registro)

    local cursor, error = conPostgre:Execute(sql_select_registro)
    if(error ~= nil) then
      print("ERRO: Falha ao executar SELECT: " .. tostring(error))
      return
    end

    local row = cursor:Fetch()
    if row == nil then
      tipo_comando_banco = 1
      print("Registro não encontrado, será feito INSERT")
    else
      tipo_comando_banco = 2
      print("Registro já existe, será feito UPDATE")
    end
    cursor:Close()

    -- INSERT ou UPDATE
    if(tipo_comando_banco == 1) then
      local CmdSQL_Insert = string.format("INSERT INTO rates(device_controller_adress, date, device_controller_name ,status, comunicacao_ok, comunicacao_nok, timestamp) VALUES(%d,'%s','%s',%d,%d,%d,'%s')",
        controlador, DataAtual, ambiente, status, comunicacao_ok, comunicacao_nok, DataHoraAtual)
      print("Executando INSERT: " .. CmdSQL_Insert)

      local cursor_insert, error_insert = conPostgre:Execute(CmdSQL_Insert)
      if(error_insert ~= nil) then
        print("ERRO: Falha no INSERT: " .. tostring(error_insert))
        return
      end

    elseif(tipo_comando_banco == 2) then
      local CmdSQL_Update = string.format("UPDATE rates SET device_controller_name='%s', status=%d, comunicacao_ok=%d, comunicacao_nok=%d, timestamp='%s' WHERE date='%s' AND device_controller_adress=%d",
        ambiente, status, comunicacao_ok, comunicacao_nok, DataHoraAtual, DataAtual, controlador)
      print("Executando UPDATE: " .. CmdSQL_Update)

      local cursor_update, error_update = conPostgre:Execute(CmdSQL_Update)
      if(error_update ~= nil) then
        print("ERRO: Falha no UPDATE: " .. tostring(error_update))
        return
      end
    end

  else
    print("Instância " .. i .. " não habilitada, ignorando.")
  end
end

print("Script finalizado com sucesso")
conPostgre:Disconnect()
