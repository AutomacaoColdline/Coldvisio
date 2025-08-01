--[[- - - - - - - - - - - - - - - - - - - - - - - - - - 

    Ambiente: HIscada_Pro
     Projeto: hioiltools2
     Empresa: 
      Versão: 
 Responsável: 
        Data: 06/10/2014 

 \b Descrição:  \brief
   ... função do script

- - - - - - - - - - - - - - - - - - - - - - - - - - - -]]

-- Verifica se foi enviado o comando.
local tag_local_cfg_mpl = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Geral.TagLocal_ConfiguraMPL")

if(tag_local_cfg_mpl.Value == false)then
  return
end
print("================== CONFIGURANDO O MPLSERVER ================")


-----------------------------------------------------------------------------------------
-- Obtem Tags
-----------------------------------------------------------------------------------------
local id_clp_conectado   = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Id_Ultima_conexao")
local nome_clp_conectado = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Nome_Ultimo_Controlador")

local id_controlador      = Tags.Get("Kernel.Tags.Local.TagLocalGroup_CadastroControladores.ComboBox")

local ip        = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_IP")
local gateway   = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Gateway")
local mascara   = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Mascara")

local nome_controlador = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Geral.TagLocal_NOME_CONTROLADOR")

-----------------------------------------------------------------------------------------
-- Dados do ultimo clp conectado
-----------------------------------------------------------------------------------------

-- Guara id do clp conectado.
id_clp_conectado.Value = id_controlador.Value
id_clp_conectado:WriteValue()

--Guarda Nome do Ultimo CLP Conectado
local texto_combo = nome_controlador.Value

nome_clp_conectado.Value = texto_combo
nome_clp_conectado:WriteValue()

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Abre conexão com o Database 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------                        
local retOpenDB, error = Scripts.Run("Kernel.Scripts.ScriptGroup_BancoDeDados.Script_AbreConexaoPostgres", 'conexao')
  
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


-- select no banco
local sql_select = string.format("SELECT ip, gateway, subnet_mask FROM plc WHERE id = %d",id_controlador.Value)
--print(sql_select)

local cursor, error = retOpenDB:Execute(sql_select)

  if (error ~= nil) then
    MessageBox("ERW:Falha ao inicia uma nova medição!")   
    return
  end

local row  = cursor:Fetch()


if row == nil then 
   
else

    ip.Value       = row['ip']
    gateway.Value  = row['gateway']
    mascara.Value  = row['subnet_mask']	
	
   cursor:Close()
end

ip:WriteValue()
gateway:WriteValue()
mascara:WriteValue()

--print(ip.Value)
--print(gateway.Value)
--print(mascara.Value)

-- fim da consulta no banco de dados

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Fecha conexão com o Banco 
-------------------------------------------------------------------------------------------------------------------------------------------------------------
local ret = retOpenDB:Disconnect()


-----------------------------------------------------------------------------------------
-- Função para configurar os Drives de Comunicação
-----------------------------------------------------------------------------------------
function ConfigMCS(cfg, propriedade, newValue)

   i, f = string.find(cfg, propriedade .. "=")

   inicio = f + 2

   i, f = string.find(cfg, "\"", inicio)

   valor = string.sub(cfg, inicio, f - 1)

   if (valor ~= newValue) then

      cfg1 = propriedade .. '="' .. valor .. '"'
      cfg2 = propriedade .. '="' .. newValue .. '"'
      cfg  = string.gsub(cfg, cfg1, cfg2, 1)

      return cfg, 1

   else

      return cfg, 0

   end

end
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Função para configurar todos os parâmetros de Timeouts dos Drives de Comunicação
-----------------------------------------------------------------------------------------
function ConfigTimeout(cfg, propriedade, newValue)

   x = 0

   i, f = string.find(cfg, propriedade .. "=")

   while (i ~= nil) do

      inicio = f + 2

      i, f = string.find(cfg, "\"", inicio)

      valor = string.sub(cfg, inicio, f - 1)

      if (valor ~= newValue) then

         cfg1 = propriedade .. '="' .. valor .. '"'
         cfg2 = propriedade .. '="' .. newValue .. '"'
         cfg  = string.gsub(cfg, cfg1, cfg2, 1)

         x = 1

      end

      i, f = string.find(cfg, propriedade .. "=", f)

   end

   return cfg, x

end
-----------------------------------------------------------------------------------------

local nome_MPL =  Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_nome_MPL")

----------------------------------------------------------------------
--Altera projeto mcs com os dados definidos para comunicação, se necessário
--Dispara script para conexão serial ou ethernet
----------------------------------------------------------------------
--Obtem a pasta de projetos do mcs
path_mcs = ProjectsFolder .. ProjectName .. "\\"
 --print(path_mcs)

hnd = io.open(path_mcs .. "PathMCS.txt", "r")

local aux_path = ""


if (hnd) then -- entra nesse if quando esta rodando o programa por dentro do IDE

local achou_path = false -- flag para verificar se achou o caminho correto do MPLServer.

  -- Loop para verificar e encontrar o caminho correto do MPLServer
  while achou_path == false do

    path_mcs = hnd:read("*l") 

     if path_mcs == nil then
     -- Não encontrou nenhum path valido para o MLPServer
       achou_path = true
       MessageBox("Servidor MPLServer Não encontrado")
     else
      -- Testa se o Path especificado para o MPLServer existe.
     
        aux_path = path_mcs .. "\\".. nome_MPL.Value -- apenda o arquivo do mplserver.
        --print(aux_path)
 
         ret = io.open(aux_path, "r") -- abre o arquivo 
         if ret ~= nil then -- verifica se tem conteudo no arquivo se tiver seta flag qeu achou o caminho.

            achou_path = true

             ret:close()

         end      
     end
  end
else -- entra no else se estiver em produção(rodando pelo instalador)

   local caminho_path = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_MCS.Caminho")

  -- path_mcs = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_MCS.TagLocal_ProjectsFolder").Value
     
   path_mcs = caminho_path.Value

   --print(path_mcs)

   aux_path = path_mcs .. "MCS\\Projects".."\\"..nome_MPL.Value

end

 path_mcs = aux_path

--print(path_mcs)

path_mcs = string.gsub(path_mcs, "\\", "\\" .. "\\")

--print(path_mcs)

-- Abre o projeto MCS do hioiltools3
hnd = io.open(path_mcs, "r")

if (hnd) then

   msg = hnd:read("*all")
   hnd:close()

   --print('batata')

   tipo_conexao   = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_TipoConexao").Value
   reiniciar_mcs = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Reiniciar_MCS")

   local porta     = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_PortaEth").Value
   local id        = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Id").Value
   local protocolo = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Protocolo").Value
   local timeout   = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Timeout").Value
   


   if (tipo_conexao == 1) then --Ethernet

      -----------------------------------------
      --Configura o IP
      -----------------------------------------
      msg, ret = ConfigMCS(msg, "device_ip", ip.Value)

      if (ret == 1) then

         reiniciar_mcs.Value = ret

      end

      -----------------------------------------
      --Configura o Gateway
      -----------------------------------------
      msg, ret = ConfigMCS(msg, "gateway_ip", gateway.Value)

      if (ret == 1) then

         reiniciar_mcs.Value = ret

      end
	
 
      -----------------------------------------
      --Configura o Mascara
      -----------------------------------------
      msg, ret = ConfigMCS(msg, "subnet_mask", mascara.Value)

      if (ret == 1) then

         reiniciar_mcs.Value = ret

      end
	  
      -----------------------------------------
      --Configura a porta
      -----------------------------------------
      msg, ret = ConfigMCS(msg, "port_number", tostring(porta))

      if (ret == 1) then

         reiniciar_mcs.Value = ret

      end

      -----------------------------------------
      --remap_id
      -----------------------------------------
      msg, ret = ConfigTimeout(msg, "remap_id", tostring(id))

      if (ret == 1) then

         reiniciar_mcs.Value = ret

      end

      -----------------------------------------
      --Configura o protocolo
      -----------------------------------------
      msg, ret = ConfigMCS(msg, "driver_sub_type", tostring(protocolo))

      if (ret == 1) then

         reiniciar_mcs.Value = ret

      end

      -----------------------------------------------
      --Configura o nome do driver para Driver_1000
      -----------------------------------------------
      i, f = string.find(msg, 'TEthernetDriver name="Driver_2000"')

      if (i ~= nil) then

         msg = string.gsub(msg, 'TEthernetDriver name="Driver_2000"', 'TEthernetDriver name="Driver_1000"')
         msg = string.gsub(msg, 'TSerialDriver name="Driver_1000"', 'TSerialDriver name="Driver_2000"')

      end

      if (protocolo == 11) then -- UDP

         -----------------------------------------
         --frames_retry
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "frames_retry", "1")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --frame_timeout
         -----------------------------------------
         msg, ret = ConfigTimeout(msg, "frame_timeout", tostring(timeout))

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --link_retry_init_time
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "link_retry_init_time", "10")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --link_retry_step_time
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "link_retry_step_time", "0")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --link_retry_max_time
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "link_retry_max_time", "0")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --connect_timeout
         -----------------------------------------
         msg, ret = ConfigTimeout(msg, "connect_timeout", tostring(timeout))

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --transmmit_timeout
         -----------------------------------------
         msg, ret = ConfigTimeout(msg, "transmmit_timeout", tostring(timeout))

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --fast_connection_interval
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "fast_connection_interval", "10")

         if (ret == 1) then


            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --msgs_to_switch_connection
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "msgs_to_switch_connection", "10")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --connection_interval
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "connection_interval", "10")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

      else --TCP

         -----------------------------------------
         --frames_retry
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "frames_retry", "0")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --frame_timeout
         -----------------------------------------
         msg, ret = ConfigTimeout(msg, "frame_timeout", tostring(timeout))

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --link_retry_init_time
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "link_retry_init_time", "3")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --link_retry_step_time
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "link_retry_step_time", "5")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --link_retry_max_time
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "link_retry_max_time", "180")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --connect_timeout
         -----------------------------------------
         msg, ret = ConfigTimeout(msg, "connect_timeout", tostring(timeout))

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --transmmit_timeout
         -----------------------------------------
         msg, ret = ConfigTimeout(msg, "transmmit_timeout", tostring(timeout))

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --fast_connection_interval
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "fast_connection_interval", "10")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --msgs_to_switch_connection
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "msgs_to_switch_connection", "12")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

         -----------------------------------------
         --connection_interval
         -----------------------------------------
         msg, ret = ConfigMCS(msg, "connection_interval", "10")

         if (ret == 1) then

            reiniciar_mcs.Value = ret

         end

      end

   elseif (tipo_conexao == 2) then --Serial

      local PortaCom = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_PortaCom").Value
      local BaudRate = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_BaudRate").Value

      -----------------------------------------
      --remap_id
      -----------------------------------------
      msg, ret = ConfigTimeout(msg, "remap_id", tostring(id))

      if (ret == 1) then

         reiniciar_mcs.Value = ret

      end

      -----------------------------------------
      --frame_timeout
      -----------------------------------------
      msg, ret = ConfigTimeout(msg, "frame_timeout", tostring(timeout))

      if (ret == 1) then

         reiniciar_mcs.Value = ret

      end

      -----------------------------------------
      --connect_timeout
      -----------------------------------------
      msg, ret = ConfigTimeout(msg, "connect_timeout", tostring(timeout))

      if (ret == 1) then

         reiniciar_mcs.Value = ret

      end

      -----------------------------------------
      --transmmit_timeout
      -----------------------------------------
      msg, ret = ConfigTimeout(msg, "transmmit_timeout", tostring(timeout))

      if (ret == 1) then

         reiniciar_mcs.Value = ret

      end

      -----------------------------------------
      --Configura o numero da porta COM
      -----------------------------------------
      inicio_serial = string.find(msg, "TSerialDriver")

      i, f = string.find(msg, "port_number=", inicio_serial)

      inicio = f + 2

      i, f = string.find(msg, "\"", inicio)

      port = string.sub(msg, inicio, f - 1)

      if (port ~= tostring(PortaCom)) then

         reiniciar_mcs.Value = 1

         port1 = 'port_number="' .. port .. '"'
         port2 = 'port_number="' .. tostring(PortaCom) .. '"'

         msg = string.gsub(msg, port1, port2)

      end

      -----------------------------------------
      --Configura o baud rate
      -----------------------------------------
      i, f = string.find(msg, "baud_rate=", inicio_serial)

      inicio = f + 2

      i, f = string.find(msg, "\"", inicio)

      baud_rate = string.sub(msg, inicio, f - 1)

      if (baud_rate ~= tostring(BaudRate)) then

         reiniciar_mcs.Value = 1

         baud_rate1 = 'baud_rate="' .. baud_rate .. '"'
         baud_rate2 = 'baud_rate="' .. tostring(BaudRate) .. '"'

         msg = string.gsub(msg, baud_rate1, baud_rate2)

      end

      -----------------------------------------
      --Configura o nome do driver para Driver_1000 
      -----------------------------------------
      i, f = string.find(msg, 'TSerialDriver name="Driver_2000"')

      if (i ~= nil) then

         msg = string.gsub(msg, 'TSerialDriver name="Driver_2000"', 'TSerialDriver name="Driver_1000"')
         msg = string.gsub(msg, 'TEthernetDriver name="Driver_1000"', 'TEthernetDriver name="Driver_2000"')

      end

   end

   reiniciar_mcs.Value = 1
   reiniciar_mcs:WriteValue()

   if (reiniciar_mcs.Value == 1) then

      -----------------------------------------
      --Salva configuração no arquivo
      -----------------------------------------
      hnd = io.open(path_mcs, "w+")

      ret = hnd:write(tostring(msg))
      hnd:close()

   end

end

-- reseta comando de configuração
if(tag_local_cfg_mpl.Value == true)then 
 tag_local_cfg_mpl.Value = false
 tag_local_cfg_mpl:WriteValue()
end

Sleep(5000)
print("================== ENVIOU O COMANDO DE RECONECTAR ================")
-----------------------------------------------------------------------------------------------------------------------------------
--Envia comando para disparar script do kernel que realiza nova conexão com os parametros de comunicação definidos pelo usuário
-----------------------------------------------------------------------------------------------------------------------------------
tag = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_ComandoConectar")
tag.Value = 1

tag:WriteValue()
