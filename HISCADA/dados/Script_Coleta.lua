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

-- Desabilita Timer
local Timer_Coleta = Timers.GetTimer("Viewers.Timers.Timer_Coleta")
Timer_Coleta:Cancel()
--print("Desabilita Timer_Coleta")

-- Obtem TLK_TotalDeRegistros e TLK_Atualiza
local TLK_TotalDeRegistros = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_TotalDeRegistros")
local TLK_Atualiza         = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_Atualiza")
--print("TLK_TotalDeRegistros")
--print(TLK_TotalDeRegistros.Value)

-- Obtem TOPC_NumeroDeRegistrosNoBufferDeColeta
local TOPC_NumeroDeRegistrosNoBufferDeColeta = Tags.Get("Kernel.Tags.Opc.TagOpcGroup_Buffer.TagOpc_NumeroDeRegistrosNoBufferDeColeta")
--print("TOPC_NumeroDeRegistrosNoBufferDeColeta")
--print(TOPC_NumeroDeRegistrosNoBufferDeColeta.Value)

-- Obtem TLK_HabilitaColeta
local TLK_HabilitaColeta = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_HabilitaColeta")
-- Obtem TLK_ColetaAutomatica
local TLK_ColetaAutomatica = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_ColetaAutomatica")
-- Obtem TLK_ColetaManualCompleta
local TLK_ColetaManualCompleta = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_ColetaManualCompleta")
-- Obtem TLK_ColetaManualParcial
local TLK_ColetaManualParcial = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_ColetaManualParcial")



if ((TLK_HabilitaColeta.Value == true) and (TOPC_NumeroDeRegistrosNoBufferDeColeta.Value == 0) and (TLK_ColetaAutomatica.Value == false)) then

      TLK_HabilitaColeta.Value = false
      TLK_HabilitaColeta:WriteValue()
      if (TLK_ColetaManualCompleta.Value == true) then
          TLK_ColetaManualCompleta.Value = false
          TLK_ColetaManualCompleta:WriteValue()
      end

end


-- Define se Atualiza ou não Atualiza
if ((TOPC_NumeroDeRegistrosNoBufferDeColeta.Value > 0) and 
    ((TOPC_NumeroDeRegistrosNoBufferDeColeta.Value ~= TLK_TotalDeRegistros.Value) or
     (TLK_HabilitaColeta.Value == true))
   ) then
   TLK_Atualiza.Value = true
else
   TLK_Atualiza.Value = false
end
TLK_Atualiza:WriteValue()

if (TLK_Atualiza.Value == false) then
    --print("Atualiza == false")
    -- Habilita o Timer de Coleta  
    local CicloDeAquisicao = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_CicloDeAquisicao")
    CicloDeAquisicao:WriteValue()
    Timer_Coleta:Enable(CicloDeAquisicao.Value)
    return
else
    --print("Atualiza == true")
end

-- Tags OPC 
local TOPC_RegistrosNoBufferDeColeta = Tags.Get("Kernel.Tags.Opc.TagOpcGroup_Buffer.TagOpc_RegistrosNoBufferDeColeta")

-- Tags Locais do Kernel
local TLK_Timestamp                  = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_Timestamp")                                    
local TLK_NumeroDeRegistrosColetados = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_NumeroDeRegistrosColetados")
local Caminho_TLK_ID_DISP            = "Kernel.Tags.Local.TagLocalGroup_FiltroDispositivo.TagLocal_ID_DISP"
local TLK_ID_DISP                    = Tags.Get(Caminho_TLK_ID_DISP)
-- Verifica se o Tag foi obtido com sucesso
if(TLK_ID_DISP == nil)then
  return
end
local TLK_ID_DISP_VALUE  = TLK_ID_DISP.Value

-- Tags Locais do Kernel relacionados ao Banco de Dados
local TLK_DADO_Timestamp = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_DADO_Timestamp")
local TLK_DADO_ID        = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_DADO_ID")
local TLK_DADO_TIPO      = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_DADO_TIPO")
local TLK_DADO_OFFSET    = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_DADO_OFFSET")
local TLK_DADO_BOOL      = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_DADO_BOOL")
local TLK_DADO_INT       = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_DADO_INT")
local TLK_DADO_REAL      = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_DADO_REAL")
local TLK_DADO_DINT      = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_DADO_DINT")
local TLK_DADO_UINT      = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_DADO_UINT")
local TLK_DADO_UDINT     = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_DADO_UDINT")
local TLK_InsereColeta   = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_InsereColeta")

-- Variaveis Locais
local Limite = TOPC_NumeroDeRegistrosNoBufferDeColeta.Value - 1
if (Limite > 23) then
    Limite = 23
end
local Registro = 0

--    NomeTabela: Insira nesta variável o Nome da Tabela existente no banco da aplicação em que se deseja executar o comando SQL.
local NomeTabela = "data"  
--    CmdSQL: Insira nesta variável uma string com o comando SQL a ser executado no Banco
local CmdSQL = string.format("SELECT * FROM %s WHERE id_device = %d AND ID != 0",NomeTabela, TLK_ID_DISP_VALUE)
print(CmdSQL)
--    NomeDataBase: Insira nesta variável uma string com o caminho completo para o DataBase que se deseja acessar
local NomeDataBase = "Globals.DataBases.DataBase_001"
-- Abre conexão com o Database        
local retOpenDB = Database.Get(NomeDataBase)
-- Tabelas Auxiliares
local tabela_ID     = {}
local tabela_Tipo   = {}
local tabela_Offset = {}
-- Variaveis auxiliares
local idx = 1 
local aux_numero_registros = 0

local cursor, error  = retOpenDB:Execute(CmdSQL)

row = cursor:Fetch() -- recupera dicionario {nome_coluna=valor}

aux_numero_registros = cursor.NumRows

while row do
 tabela_ID[idx]      = tonumber(row["ID"]) 
 tabela_Tipo[idx]    = tonumber(row["type_data"])
 tabela_Offset[idx]  = row["Offset"]
 idx = idx + 1 
 -- recupera o próximo registro
 row = cursor:Fetch()
end
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

-- Coletar Registro de 1 a Numero de Registros - 1
while (Registro <= Limite) do 
      -- Coleta DT do Registro (numero de microsegundos desde 01/01/2000 (64 bits)
      local TIMESTAMP_0   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+1]
      local TIMESTAMP_1   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+2]
      local TIMESTAMP_2   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+3]
      local TIMESTAMP_3   = TOPC_RegistrosNoBufferDeColeta.Value[Registro*10+4]
      local dh = TIMESTAMP_0 + (TIMESTAMP_1 * 65536) + (TIMESTAMP_2 * 4294967296) + (TIMESTAMP_3 * 281474976710656)
      TLK_Timestamp.Value[Registro+1] = DateTime(DateTime('01/01/2000 00:00:01'):GetValue() + ((1/24/60/60/1000000)*(dh) - (DateTime('03:00:00'):GetValue()))):GetFormatString('dd/mm/yyyy hh:mm:ss')    
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
      local Achou
      local ValorColetado 
      local offset
      local NroRegistrosNoBanco = aux_numero_registros

      if (TLK_HabilitaColeta.Value == true) then
            Achou = false
            for Indice = 1, NroRegistrosNoBanco do
                 if (DATA_TYPE == tabela_ID[Indice]) then
                     IDDaVariavelNoPortal = Indice
                     Achou = true
                     break
                 end -- end if                   
            end -- end for Indice = 1, NroRegistrosNoBanco do
--print ("ACHOU = ")

            if (Achou == true) then 
--print (" = TRUE")
                TLK_DADO_Timestamp.Value = DateTime(DateTime():GetFormatString(TLK_Timestamp.Value[Registro+1])) 
                TLK_DADO_ID.Value = (tabela_ID[IDDaVariavelNoPortal])
                offset = tabela_Offset[IDDaVariavelNoPortal]
                TLK_DADO_OFFSET.Value = offset
                --print(TLK_DADO_Timestamp.Value)
                --print(TLK_DADO_ID.Value) 
                --print(TLK_DADO_OFFSET.Value) 
                Tipo = tabela_Tipo[IDDaVariavelNoPortal]
                TLK_DADO_TIPO.Value = Tipo
                print(TLK_DADO_TIPO.Value) 
                TLK_DADO_BOOL.Value = false
                TLK_DADO_INT.Value  = 0 
                TLK_DADO_REAL.Value = 0.0
                TLK_DADO_DINT.Value = 0
                TLK_DADO_UINT.Value = 0
                TLK_DADO_UDINT.Value = 0
                if (Tipo == 2) then -- INT 
                    ValorColetado = DATA_VALUE_0
                    TLK_DADO_INT.Value = ValorColetado 
                elseif (Tipo == 5) then -- UINT
                        ValorColetado = DATA_VALUE_0
                        TLK_DADO_UINT.Value = ValorColetado 
                elseif (Tipo == 4) then -- DINT
                        ValorColetado = DATA_VALUE_0 + DATA_VALUE_1 * 65536
                        TLK_DADO_DINT.Value = ValorColetado 
                elseif (Tipo == 6) then -- UDINT
                        ValorColetado = DATA_VALUE_0 + DATA_VALUE_1 * 65536
                        TLK_DADO_UDINT.Value = ValorColetado 
                elseif (Tipo == 3) then -- REAL
                        TLK_DADO_REAL.Value = Tags.Get(string.format("Kernel.Tags.Opc.TagOpcGroup_Buffer.TagOpc_DADO_REAL_%d", Registro+1)).Value
                        --print(TLK_DADO_REAL.Value)
                elseif (Tipo == 1) then -- BOOL
                        ValorColetado = DATA_VALUE_0
                        if (ValorColetado ~= 0) then
                           TLK_DADO_BOOL.Value = true
                        else 
                           TLK_DADO_BOOL.Value = false
                        end -- if (ValorColetado ~= 0) then
                end -- if (Tipo == 1) then -- INT
            else -- Não ACHOU IDDaVariavelNoPortal

--print (" = FALSE")
                 TLK_DADO_Timestamp.Value = DateTime(DateTime():GetFormatString(TLK_Timestamp.Value[Registro+1])) 
                 TLK_DADO_ID.Value = IDDadoDoRegistroColetado
                 print(TLK_DADO_Timestamp.Value)
                 print(TLK_DADO_ID.Value) 
                 Tipo = 0
                 TLK_DADO_TIPO.Value = Tipo
                 print(TLK_DADO_TIPO.Value) 
                 ValorColetado = LSW
                 offset = 0
                 TLK_DADO_OFFSET.Value = offset
                 TLK_DADO_BOOL.Value = false
                 TLK_DADO_INT.Value = ValorColetado 
                 TLK_DADO_REAL.Value = 0.0
                 TLK_DADO_DINT.Value = 0
                 TLK_DADO_UINT.Value = 0
                 TLK_DADO_UDINT.Value = 0
            end -- endif ACHOU ID do Registro Coletado

         -- Escreve Registro Coletado
         TLK_DADO_Timestamp:WriteValue()
         TLK_DADO_ID:WriteValue()
         TLK_DADO_TIPO:WriteValue()
         TLK_DADO_OFFSET:WriteValue()
         TLK_DADO_BOOL:WriteValue()
         TLK_DADO_INT:WriteValue()
         TLK_DADO_REAL:WriteValue()
         TLK_DADO_DINT:WriteValue()
         TLK_DADO_UINT:WriteValue()
         TLK_DADO_UDINT:WriteValue()
         -- Escreve flag InsereColeta
         if (TLK_InsereColeta.Value == true)then
             TLK_InsereColeta.Value = false
         else
             TLK_InsereColeta.Value = true
         end
         TLK_InsereColeta:WriteValue()
         -- Incrementa numero de registros coletados
         TLK_NumeroDeRegistrosColetados.Value = TLK_NumeroDeRegistrosColetados.Value + 1
         TLK_NumeroDeRegistrosColetados:WriteValue()
      end -- if (TLK_HabilitaColeta.Value == true)
      Registro = Registro + 1
end -- while (Registro <= Limite) do 
TLK_Timestamp:WriteValue()
if (TLK_HabilitaColeta.Value == true) then
      local NumeroDeRegistrosNoBufferDeColeta = TOPC_NumeroDeRegistrosNoBufferDeColeta.Value
      if (NumeroDeRegistrosNoBufferDeColeta > 24) then
          NumeroDeRegistrosNoBufferDeColeta = 24
      end
      NumeroDeRegistrosNoBufferDeColeta = NumeroDeRegistrosNoBufferDeColeta * -1
      TOPC_NumeroDeRegistrosNoBufferDeColeta.Value = NumeroDeRegistrosNoBufferDeColeta
      TOPC_NumeroDeRegistrosNoBufferDeColeta:WriteValue()
      --
      TLK_TotalDeRegistros.Value = NumeroDeRegistrosNoBufferDeColeta
      TLK_TotalDeRegistros:WriteValue()
      --
      if (TLK_ColetaManualParcial.Value == true) then

          TLK_HabilitaColeta.Value = false
          TLK_HabilitaColeta:WriteValue()
          TLK_ColetaManualParcial.Value = false
          TLK_ColetaManualParcial:WriteValue()

      end
--    print("Habilita Coleta == true")
    
else

      TLK_TotalDeRegistros.Value = TOPC_NumeroDeRegistrosNoBufferDeColeta.Value
      TLK_TotalDeRegistros:WriteValue()
      --      print("Habilita Coleta == false")
    
end

-- Habilita o Timer de Coleta  
local CicloDeAquisicao = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Coleta.TagLocal_CicloDeAquisicao")
CicloDeAquisicao:WriteValue()
Timer_Coleta:Enable(CicloDeAquisicao.Value)
print("Final Script Coleta. Habilita Timer_Coleta")











