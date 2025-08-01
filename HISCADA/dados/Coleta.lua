--[[- - - - - - - - - - - - - - - - - - - - - - - - - - 

    Ambiente: HIscada_Pro
     Projeto: Simula_Portal
     Empresa: HI Tecnologia
      Versão: 1.0
 Responsável: Eng. de Aplicacao
        Data: 11/09/2020 

 \b Descrição:  \brief
   ... função do script

- - - - - - - - - - - - - - - - - - - - - - - - - - - -]] 

--print("Inicio Script Coleta")
local AddUsefulFunctions = require "UsefulFunctions"
local AddUsefulConversao = require "Conversao"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Obtem o timer 
-------------------------------------------------------------------------------------------------------------------------------------------------------------
local timer = Timers.Get("Kernel.Timers.Timer_InsertBanco")

----------------------------------------------------------------------------------------------------------------------------------------
--data hora atual
----------------------------------------------------------------------------------------------------------------------------------------
local DataHoraAtual = DateTime()

----------------------------------------------------------------------------------------------------------------------------------------
--Tag para teste
----------------------------------------------------------------------------------------------------------------------------------------
local tag_abre_tela = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Simulacao.TagLocal_Abre_tela")

----------------------------------------------------------------------------------------------------------------------------------------
--Obtem o Tag de erro no script 
----------------------------------------------------------------------------------------------------------------------------------------
local tag_local_erro = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Dados.TagLocal_Erro_Script_Coleta")

----------------------------------------------------------------------------------------------------------------------------------------
-- Obtem TOPC_NumeroDeRegistrosNoBufferDeColeta
----------------------------------------------------------------------------------------------------------------------------------------
local TOPC_NumeroDeRegistrosNoBufferDeColeta = ConsisteTagOpc("Kernel.Tags.Opc.TagOpcGroup_Buffer.TagOpc_NumeroDeRegistrosNoBufferDeColeta")

----------------------------------------------------------------------------------------------------------------------------------------
-- Sai do Script caso esteja sem comunicação com o CLP.
----------------------------------------------------------------------------------------------------------------------------------------
if (TOPC_NumeroDeRegistrosNoBufferDeColeta == false) then
     print("Sem comunicação com CLP")
	 tag_local_erro.Value = true 
       tag_local_erro:WriteValue()
     return
end 

----------------------------------------------------------------------------------------------------------------------------------------
--Obtem o tag de flag de coleta de dados 
----------------------------------------------------------------------------------------------------------------------------------------
local tag_local_flag_coletando = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Dados.TagLocal_FlagColetando")


--========================================================================================================================================
-- Verifica se tem dado no buffer de coleta 
--========================================================================================================================================
if(TOPC_NumeroDeRegistrosNoBufferDeColeta.Value > 0)then
 
  ----------------------------------------------------------------------------------------------------------------------------------------
  -- Abre a conexão ou obtem conexão
  ----------------------------------------------------------------------------------------------------------------------------------------  
  local conPostgre, error = Scripts.Run("Kernel.Scripts.ScriptGroup_BancoDeDados.Script_AbreConexaoPostgres", "con_porta")
    
  if(error ~= nil)then
    print("Ao abrir conexão com o banco: " .. error)
    	 tag_local_erro.Value = true 
       tag_local_erro:WriteValue()
    return
  end
  
  if(conPostgre == nil)then
    	 tag_local_erro.Value = true 
       tag_local_erro:WriteValue()
    return
  end

   
  ----------------------------------------------------------------------------------------------------------------------------------------
  -- Seta flag para indicar coletando 
  ----------------------------------------------------------------------------------------------------------------------------------------
  tag_local_flag_coletando.Value = true
  tag_local_flag_coletando:WriteValue()
  
  tempo_timer = 1000 -- tempo para executar o timer 1 segundos 

  ----------------------------------------------------------------------------------------------------------------------------------------
  -- Le buffer de dados do clp com os dados a ser coletados 
  ---------------------------------------------------------------------------------------------------------------------------------------- 
  local TOPC_RegistrosNoBufferDeColeta = ConsisteTagOpc("Kernel.Tags.Opc.TagOpcGroup_Buffer.TagOpc_RegistrosNoBufferDeColeta")

  -- Tags Locais do Kernel
  local TLK_Timestamp                  = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_Timestamp")                                    
  local Caminho_TLK_ID_DISP            = "Kernel.Tags.Local.TagLocalGroup_Dados.TagLocal_ID_DISP"
  local TLK_ID_DISP                    = Tags.Get(Caminho_TLK_ID_DISP)
  
  ----------------------------------------------------------------------------------------------------------------------------------------
  -- Verifica se o Tag foi obtido com sucesso
  ----------------------------------------------------------------------------------------------------------------------------------------
  if(TLK_ID_DISP == nil)then
    tag_local_erro.Value = true 
    tag_local_erro:WriteValue()
    return
  end
  
  local TLK_ID_DISP_VALUE  = TLK_ID_DISP.Value
  
  -- Variaveis Locais
  local Limite = TOPC_NumeroDeRegistrosNoBufferDeColeta.Value - 1
  if (Limite > 23) then
      Limite = 23
  end
  
  local Registro = 0
 
  ----------------------------------------------------------------------------------------------------------------------------------------
  -- Obtem TimeZone do CLP
  ----------------------------------------------------------------------------------------------------------------------------------------
  local TimeZone = ConsisteTagOpc("Kernel.Tags.Opc.TagOpcGroup_InfosControlador.TagOpc_TimeZone")
  local total
  local multiplicador 
  
  -- Verifica se o TimeZone é positivo
  if TimeZone.Value >= 0 then
  -- Caso seja atribui valor do timezone pra a avariável total para realizar cálculo de timezone
      total         = TimeZone.Value
  -- O multiplicador quando positivo força somar o timezone ao horário UTC (usado na formula do timestamp do dado)
      multiplicador = 1
  else
  -- Caso o timezone seja negativo atribui valor do timezone vezes -1 pra a avariável total para realizar cálculo de timezone
      total         = TimeZone.Value * (-1)
  -- O multiplicador quando negativo força subtrair o timezone ao horário UTC (usado na formula do timestamp do dado)
      multiplicador = -1
  end
  -- O Valor do timezone é dado em munuto, os cálculos abaixo são para encontrar o timezone em horar e coloca-lo no formato (string)
  -- HH:MM:SS
  local horas = math.floor((total) / 60)
  local minutos = math.floor(total % 60)
  local time = string.format(horas .. ":" .. minutos .. ":" .. "00") 
  
  --[[--
  formato do registro
  1-TIMESTAMP_0-UINT
  2-TIMESTAMP_1-UINT
  3-TIMESTAMP_2-UINT
  4-TIMESTAMP_3-UINT
  5-DATA_VALUE_0-UINT
  6-DATA_VALUE_1-UINT
  7-DATA_VALUE_2-UINT
  8-DATA_VALUE_3-UINT
  9-DATA_TYPE-UINT
  10-SPARE-UINT
  --]]--
  
  ----------------------------------------------------------------------------------------------------------------------------------------
  -- Coletar Registro de 1 a Numero de Registros - 1
  ----------------------------------------------------------------------------------------------------------------------------------------
  while (Registro <= Limite) do 
  
        -- Coleta DT do Registro (numero de microsegundos desde 01/01/2000 (64 bits)
        local TIMESTAMP_0   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+1]
        local TIMESTAMP_1   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+2]
        local TIMESTAMP_2   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+3]
        local TIMESTAMP_3   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+4]
        local dh = TIMESTAMP_0 + (TIMESTAMP_1 * 65536) + (TIMESTAMP_2 * 4294967296) + (TIMESTAMP_3 * 281474976710656)
        --TLK_Timestamp.Value[Registro+1] = DateTime(DateTime('01/01/2000 00:00:01'):GetValue() + ((1/24/60/60/1000000)*(dh) + (DateTime('03:00:00'):GetValue()))):GetFormatString('dd/mm/yyyy hh:mm:ss')    
        TLK_Timestamp.Value[Registro+1] = DateTime(DateTime('01/01/2000 00:00:01'):GetValue() + ((1/24/60/60/1000000)*(dh) + multiplicador * (DateTime(time):GetValue()))):GetFormatString('dd/mm/yyyy hh:mm:ss')  
        -- Escreve Timestamp do Registro coletado
        TLK_Timestamp:WriteValue()
  	  
        -- Identifica os DADO do Registro Coletado
        local DATA_VALUE_0   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+5]
        local DATA_VALUE_1   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+6]
        local DATA_VALUE_2   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+7]
        local DATA_VALUE_3   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+8]
  	  
        -- Identifica o ID do Dado do Registro Coletado
        local DATA_TYPE = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+9]
        local IDDaVariavelNoPortal = 0
        local Tipo
        local ValorColetado 
        local offset
        local NroRegistrosNoBanco = aux_numero_registros
  
        TLK_DADO_Timestamp = DateTime(DateTime():GetFormatString(TLK_Timestamp.Value[Registro+1])) 
        TLK_DADO_ID = DATA_TYPE
        offset = string.format('%s',DATA_TYPE)
        TLK_DADO_OFFSET = offset
  
        -- print(TLK_DADO_Timestamp.Value)
        -- print(TLK_DADO_ID.Value) 
        -- print(TLK_DADO_OFFSET.Value) 
  			   
	 ---------------------------------------------------------------------------------------------------------------------------------------- 
  	 -- Tipo de valores de eventos Publicados pelo PLC para o Portal: 
  	 --      1 a 400: Valores Ponto Flutuantes
        --      401 a 500: Valores Inteiros 
        --      501 a 508: Valores Bolenos 	
        -----------------------------------------------------------------------------------------------------------------------------------------				 
        if(DATA_TYPE > 500)then
           Tipo = 1 -- Valores boleanos
  	    elseif(DATA_TYPE > 400)then	  
           Tipo = 2 -- Valores Interios			  
  	    else 				  
           Tipo = 3 -- Valores Ponto flutuante					  
  	    end  
  				  
        TLK_DADO_TIPO  = Tipo
        TLK_DADO_BOOL  = false
        TLK_DADO_INT   = 0 
        TLK_DADO_REAL  = 0.0
        TLK_DADO_DINT  = 0
        TLK_DADO_UINT  = 0
        TLK_DADO_UDINT = 0
  		
        ----------------------------------------------------------------------------------------------------------------------------------------		
        if (Tipo == 2) then -- INT 
            ValorColetado = DATA_VALUE_0
            TLK_DADO_INT  = ValorColetado
        ----------------------------------------------------------------------------------------------------------------------------------------			
        elseif (Tipo == 5) then -- UINT
                ValorColetado = DATA_VALUE_0
                TLK_DADO_UINT = ValorColetado 
		----------------------------------------------------------------------------------------------------------------------------------------		
        elseif (Tipo == 4) then -- DINT
                ValorColetado = DATA_VALUE_0 + DATA_VALUE_1 * 65536
                TLK_DADO_DINT = ValorColetado 
		----------------------------------------------------------------------------------------------------------------------------------------		
        elseif (Tipo == 6) then -- UDINT
                ValorColetado  = DATA_VALUE_0 + DATA_VALUE_1 * 65536
                TLK_DADO_UDINT = ValorColetado 
		----------------------------------------------------------------------------------------------------------------------------------------		
        elseif (Tipo == 3) then -- REAL		
  		        TLK_DADO_REAL = Converte32IntToFloat(DATA_VALUE_0,DATA_VALUE_1) -- salva o valor recebido do controlador.
        ----------------------------------------------------------------------------------------------------------------------------------------     
        elseif (Tipo == 1) then -- BOOL
                ValorColetado = DATA_VALUE_0
  
                if (ValorColetado ~= 0) then
                   TLK_DADO_BOOL = true
                else 
                   TLK_DADO_BOOL = false		
                end -- if (ValorColetado ~= 0) then
  
        end -- if (Tipo == 1) then -- INT
	 ----------------------------------------------------------------------------------------------------------------------------------------
  		
	 --dhf = DateTime()
        -- print("Hora antes de salvar no banco de dados")
        -- print(dhf)

	 ----------------------------------------------------------------------------------------------------------------------------------------
	 -- Insert no banco de dados 
        ----------------------------------------------------------------------------------------------------------------------------------------		
	 -- Verifica qual instancia do dado 
        local aux_dado_id_disp = math.fmod(TLK_DADO_ID,100)
				 
	 -- print(aux_dado_id_disp)
        local i = aux_dado_id_disp		 
		
		local caminho = 'Kernel.Tags.Local.TagLocalGroup_KN_Instancias.Controlador_' .. i 
        local hab_controlado_ok = Tags.Get(caminho)
 

    if(hab_controlado_ok.Value == true)then -- verifica se a instalacia esta habilitada

        --OBTEM OS TAGS
        local caminho_nome_tag_opc    = "Instances.InstanceGroup_Controladores.Controlador_" .. i .. ".Tags.Opc.Nome_Controlador.Nome_Controlador"
        local caminho_modelo_tag_opc  = "Instances.InstanceGroup_Controladores.Controlador_" .. i .. ".Tags.Opc.Modelo_Controlador.Modelo"
        local caminho_end_tag_opc     = "Instances.InstanceGroup_Controladores.Controlador_" .. i .. ".Tags.Opc.Endereco_Controlador.Endereco"
        
        local nome_controlador_opc    = ConsisteTagOpc(caminho_nome_tag_opc)
        local modelo_controlador_opc  = ConsisteTagOpc(caminho_modelo_tag_opc)
        local end_controlador_opc     = ConsisteTagOpc(caminho_end_tag_opc)
        
        local clp_conectado = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Id_Ultima_conexao")
        
        local sql_cmd = ""		
				 
        -------------------------------------------------------------------------------------------------------------------------------------------------------------
        -- Insert de evento de porta
        -- Se dado_id for maior que 500 insere dados de porta
        -- Se dado_id for menor que 500 insere dados de temperatura 
        -------------------------------------------------------------------------------------------------------------------------------------------------------------
        if(TLK_DADO_ID < 500)then 
         
          -- VERIFICA SE O TIPO DE DADO É DE MINIMA E MAXIMA (DADO ENTRE 1 E 120)
          if(TLK_DADO_ID >= 1 and TLK_DADO_ID <= 120)then 
          
            -- SELECT PARA VERIFICAR SE O DADO JA EXISTE NO BANCO DE DADOS
            sql_select = string.format("SELECT * FROM dataCollection WHERE data_id = %d ORDER BY data_timestamp DESC LIMIT 1",TLK_DADO_ID) 
            -- print(sql_select)
            
        	-- EXECUTA O SELECT  
            local cursor1, error1 = conPostgre:Execute(sql_select) 
            -- verifica se tem erro 
            if (error1 ~= nil) then
              MessageBox("ERW:Falha ao consultar minima e maxima existente!") 
        	 tag_local_erro.Value = true 
               tag_local_erro:WriteValue()	  
              return
            end
        
            -- PEGA A LINHA DO BANCO
            local row1  = cursor1:Fetch() 
        
            -- SE NÃO ACHOU REGISTRO
            if row1 == nil then 
          
              aux_dado_tmstamp = '01/01/2010 00:00:00' 
        
            -- SE REGISTRO EXISTE PEGA AS INFORMAÇÕES DO BANCO DE DADOS 
            else
        	
              aux_id               = tonumber(row1['id'])
        	  aux_insert_timestamp = row1['insert_timestamp']
        	  aux_dado_tmstamp     = row1['data_timestamp']
        	  aux_dado_id          = tonumber(row1['data_id']) 
        	  aux_dado_tipo        = tonumber(row1['data_type']) 
        	  aux_dado_offset      = tonumber(row1['data_offset']) 
        	  aux_dado_bool        = row1['data_bool']
        	  aux_dado_int         = tonumber(row1['data_int']) 
        	  aux_dado_real        = TLK_DADO_REAL
        	  aux_dint             = tonumber(row1['dint']) 
        	  aux_uint             = tonumber(row1['uint']) 
        	  aux_udint            = tonumber(row1['udint'])  
        	  aux_id_disp          = tonumber(row1['id_device'])  
        	  aux_nome_controlador = row1['name_device']
        	  aux_modelo           = tonumber(row1['model_device']) 
        	  aux_endereco         = tonumber(row1['address_device'])  
        	  aux_clp_conectado    = tonumber(row1['status_plc']) 
        
            end
            cursor1:Close() -- FECHA LINHA DO BANCO
          
            -- SEPARA DATA HORA 
            aux_dado = string.format('%s',TLK_DADO_Timestamp)      
            dado_tmstamp_banco =  DateTime(DateTime(aux_dado_tmstamp):GetFormatString('dd/mm/yyyy'))
            dado_tmstamp_atual =  DateTime(DateTime(aux_dado):GetFormatString('dd/mm/yyyy')) 
        	  
            data_banco   = dado_tmstamp_banco:GetValue()
            data_sdcard  = dado_tmstamp_atual:GetValue()
        
            -- print(data_banco)
            -- print(data_banco)
        
            -- VERIFICA SE A DATA JA EXISTE NO VBANCO DE DADOS 
        	-- SE FOR IGUAL A DATA DO BANCO REALIZA UM UPDATE
        	-- SE FOR DIFERENTE REALIZA UM INSERT
            if(data_sdcard > data_banco)then
        	    tipo = 1
            elseif(data_sdcard == data_banco)then	
                tipo = 2
            elseif(data_sdcard < data_banco)then	 
                tipo = 3
                return  	  
        	end 
        	
            -- monta o insert ou o update 			
            if(tipo == 1)then 
        	    sql_cmd = string.format("INSERT INTO dataCollection(insert_timestamp, data_timestamp, data_id, data_type, data_offset, data_bool, data_int, data_real, dint, uint, udint, id_device, name_device, model_device, address_device, status_plc) VALUES('%s','%s',%d,%d,'%s',%s,%d,%.2f,%d,%d,%d,%d,'%s',%d,%d,%d)",DataHoraAtual,TLK_DADO_Timestamp,TLK_DADO_ID,TLK_DADO_TIPO,TLK_DADO_OFFSET,TLK_DADO_BOOL,TLK_DADO_INT,TLK_DADO_REAL,TLK_DADO_DINT,TLK_DADO_UINT,TLK_DADO_UDINT,aux_dado_id_disp,nome_controlador_opc.Value,modelo_controlador_opc.Value,end_controlador_opc.Value,clp_conectado.Value)
            elseif(tipo == 2)then 
        	   sql_cmd = string.format("UPDATE dataCollection SET insert_timestamp='%s', data_timestamp='%s', data_id=%d, data_type=%d, data_offset='%s', data_bool=%s, data_int=%d, data_real=%.2f,dint=%d,uint=%d,udint=%d, id_device=%d, name_device='%s', model_device=%d, address_device=%d, status_plc=%d WHERE id = %d",DataHoraAtual,TLK_DADO_Timestamp,aux_dado_id,aux_dado_tipo,aux_dado_offset,aux_dado_bool,aux_dado_int,TLK_DADO_REAL,aux_dint,aux_uint,aux_udint,aux_id_disp,aux_nome_controlador,aux_modelo,aux_endereco,aux_clp_conectado,aux_id)
               -- print(sql_cmd) 
            end 
        	
          else 

            sql_cmd = string.format("INSERT INTO dataCollection(insert_timestamp, data_timestamp, data_id, data_type, data_offset, data_bool, data_int, data_real, dint, uint, udint, id_device, name_device, model_device, address_device, status_plc) VALUES('%s','%s',%d,%d,'%s',%s,%d,%.2f,%d,%d,%d,%d,'%s',%d,%d,%d)",DataHoraAtual,TLK_DADO_Timestamp,TLK_DADO_ID,TLK_DADO_TIPO,TLK_DADO_OFFSET,TLK_DADO_BOOL,TLK_DADO_INT,TLK_DADO_REAL,TLK_DADO_DINT,TLK_DADO_UINT,TLK_DADO_UDINT,aux_dado_id_disp,nome_controlador_opc.Value,modelo_controlador_opc.Value,end_controlador_opc.Value,clp_conectado.Value)
           

          end -- FIM VERIFICA SE O TIPO DE DADO É DE MINIMA E MAXIMA (DADO ENTRE 1 E 120) 
         

        elseif(TLK_DADO_ID >= 600 and TLK_DADO_ID <= 720)then
         
       	sql_cmd = string.format("INSERT INTO dataCollection(insert_timestamp, data_timestamp, data_id, data_type, data_offset, data_bool, data_int, data_real, dint, uint, udint, id_device, name_device, model_device, address_device, status_plc) VALUES('%s','%s',%d,%d,'%s',%s,%d,%.2f,%d,%d,%d,%d,'%s',%d,%d,%d)",DataHoraAtual,TLK_DADO_Timestamp,TLK_DADO_ID,TLK_DADO_TIPO,TLK_DADO_OFFSET,TLK_DADO_BOOL,TLK_DADO_INT,TLK_DADO_REAL,TLK_DADO_DINT,TLK_DADO_UINT,TLK_DADO_UDINT,aux_dado_id_disp,nome_controlador_opc.Value,modelo_controlador_opc.Value,end_controlador_opc.Value,clp_conectado.Value)

        else
        
           sql_cmd = string.format("INSERT INTO dataCollection(insert_timestamp, data_timestamp, data_id, data_type, data_offset, data_bool, data_int, data_real, dint, uint, udint, id_device, status_plc) VALUES('%s','%s',%d,%d,'%s',%s,%d,%.2f,%d,%d,%d,%d,%d)",DataHoraAtual,TLK_DADO_Timestamp,TLK_DADO_ID,TLK_DADO_TIPO,TLK_DADO_OFFSET,TLK_DADO_BOOL,TLK_DADO_INT,TLK_DADO_REAL,TLK_DADO_DINT,TLK_DADO_UINT,TLK_DADO_UDINT,aux_dado_id_disp,clp_conectado.Value)
          
        end 
 
        
          -- Executa o comando no banco 
          local cursor,error = conPostgre:Execute(sql_cmd)
        
          -- Verifica se ocorreu algum erro
          if(error ~= nil) then
            print("Falha na execução do comando SQL: " .. tostring(error))
             	 tag_local_erro.Value = true 
              tag_local_erro:WriteValue()
            return
          end

				
          ----------------------------------------------------------------------------------------------------------------------------------------  
          -- Fim do inser no banco
          ----------------------------------------------------------------------------------------------------------------------------------------		

	-- dhf = DateTime()
       -- print("Hora apos salvar no banco de dados")
       -- print(dhf)	
		
      Registro = Registro + 1
	  
	  
	end  -- fim do if de verifica instancia habilitada
			   
  end -- while (Registro <= Limite) do 
  
      TOPC_NumeroDeRegistrosNoBufferDeColeta.Value = Registro * -1
      TOPC_NumeroDeRegistrosNoBufferDeColeta:WriteValue()
  
	  
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    --Fecha conexão com o Banco postgres
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    local ret = conPostgre:Disconnect()
  
  
else 

   -------------------------------------------------------------------------------------------------------------------------------------------------------------	
   -- retira flag para indicar coletando
   -------------------------------------------------------------------------------------------------------------------------------------------------------------
   tag_local_flag_coletando.Value = false
   tag_local_flag_coletando:WriteValue()
  
   tempo_timer = 2000 -- tempo para executar o timer 2 segundos 

end 

----------------------------------------------------------------------------------------------------------------------------------------
-- Habilita timer
----------------------------------------------------------------------------------------------------------------------------------------
ret = timer:Enable(tempo_timer)
--print(timer.Enabled)

