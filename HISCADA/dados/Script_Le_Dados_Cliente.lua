--[[- - - - - - - - - - - - - - - - - - - - - - - - - - 

    Ambiente: HIscada_Pro
     Projeto: Simula_Portal
     Empresa: HI Tecnologia
      Versão: 1.0
 Responsável: Eng. de Aplicacao
        Data: 02/10/2020 

 \b Descrição:  \brief
   ... função do script

- - - - - - - - - - - - - - - - - - - - - - - - - - - -]] 


-------------------------------------------------------------------------------------------
-- Função para realizar o parse do arquivo CSV
-------------------------------------------------------------------------------------------
function parseCSVLine (line,sep) 
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do 
		local c = string.sub(line,pos,pos)
		if (c == "") then break end
		if (c == '"') then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(line,'^%b""',pos)
				txt = txt..string.sub(line,startp+1,endp-1)
				pos = endp + 1
				c = string.sub(line,pos,pos) 
				if (c == '"') then txt = txt..'"' end 
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			pos = pos + 1
		else	
			-- no quotes used, just look for the first separator
			local startp,endp = string.find(line,sep,pos)
			if (startp) then 
				table.insert(res,string.sub(line,pos,startp-1))
				pos = endp + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(line,pos))
				break
			end 
		end
	end
	return res
end


------------------------------------------------------------------------------------------------------------------------------
-- Tags
------------------------------------------------------------------------------------------------------------------------------

local id_dispositivo = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Dados.TagLocal_ID_DISP")


------------------------------------------------------------------------------------------------------------------------------
-- Selecione O arquivo 
------------------------------------------------------------------------------------------------------------------------------


local flag_selected, file_path = FileDialog(1, "Selecione arquivo de dados", "", "", "", "", 0);

--print(flag_selected)
--print(file_path)

------------------------------------------------------------------------------------------------------------------------------
-- Caminho completo até o arquivo de integração
------------------------------------------------------------------------------------------------------------------------------
local NomeCaminhoArqCSV =  file_path


-------------------------------------------------------------------------------------------
-- Abre conexão com o banco de dados
-------------------------------------------------------------------------------------------
local NomeDataBase = "Globals.DataBases.DataBase_Postgres"

local retOpenDB = Database.Get(NomeDataBase)
  
-- Verifica se a conexão com o Database foi obtida com sucesso
if(retOpenDB == nil)then
   print("Erro na abertura de conexão:" .. retOpenDB)
   print("Conexão:" .. tostring(retOpenDB))
  return
end

if retOpenDB.Error then
  print("Erro na abertura de conexão:" .. retOpenDB.Error)
  print("Conexão:" .. tostring(con))
  return
end

local SQLDelete = string.format("DELETE FROM Data WHERE id_device = %s", id_dispositivo.Value)
-- Executa o comando no banco 
local cursor,error = retOpenDB:Execute(SQLDelete)

-- Verifica se ocorreu algum erro
if(error ~= nil) then
 print("Falha na execução do comando SQL: " .. tostring(error))
 return
end



-------------------------------------------------------------------------------------------
-- Abre arquivo CSV que contém os dados de integração
-------------------------------------------------------------------------------------------
local fd = io.open(NomeCaminhoArqCSV,"r")
if(fd == nil)then
  print("Falha na Abertura do arquivo de integração")
end

-------------------------------------------------------------------------------------------
-- Obtém qual separador será utilizado para determinar cada registro do arquivo CSV
-- Caso o separador obtido seja diferente de virgula(,) ou ponto-e-virgula(;)
-- Será utilizado o ponto-e-virgula(;) como padrão 
-------------------------------------------------------------------------------------------
local separador = ","
if(separador ~= ";" or separador ~= ",")then
  separador = ","
end

local M={} -- Tabela lua que conterá cada linha obtida do arquivo CSV
local G={} -- Tabela lua que conterá todas as linhas obtidas do arquivo CSV
local linha = string.gsub(fd:read(),'"',"")
while linha ~= nil do
  --print(a)
  M = parseCSVLine (linha, separador) 
  if(linha ~= "")then 
    table.insert(G,M)
  end
  linha = fd:read()

if linha ~= nil then
  linha = string.gsub(linha,'"',"")
end

end
fd:close()

local tipo = 0
  aux_string = 'INSERT INTO data(id, type_data, offset_, id_device, description) VALUES'
   --print(aux_string)
 print(#G)

for i = 2, #G do
   print(i)
  if(G[i][4] == "BOOL")then
    tipo = 1
  elseif(G[i][4] == "INT")then
    tipo = 2
  elseif(G[i][4] == "REAL")then
    tipo = 3 
  elseif(G[i][4] == "DINT")then
    tipo = 4
  elseif(G[i][4] == "UINT")then
    tipo = 5
  elseif(G[i][4] == "UDINT")then
    tipo = 6
  elseif(G[i][4] == "WORD")then
    tipo = 7
  end
 -- Insere 
   local aux_stg = string.format("(%d,%d,'%s',%d,'%s')", tonumber(G[i][2]),tonumber(tipo),G[i][3],id_dispositivo.Value,G[i][8])
    --print(aux_stg)
   if(i == 2) then   
    aux_string = aux_string .. aux_stg    
   else
    aux_string = aux_string .. ", " .. aux_stg  
   end
end
  
local CmdSQL = aux_string
--print(CmdSQL)

-- Executa o comando no banco 
local cursor,error = retOpenDB:Execute(CmdSQL)

-- Verifica se ocorreu algum erro
if(error ~= nil) then
 print("Falha na execução do comando SQL: " .. tostring(error))
 return
end






