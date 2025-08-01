--[[
    Script com lógica de UPSERT (INSERT ou UPDATE)
    Atualiza a tabela preventivemaintenance com device_controller_name
    Autor: Eduardo Ferreira Leite / Corrigido por ChatGPT
]]

-- Função para abrir conexão com PostgreSQL
local function abrirConexao(nomeConexao)
    print("Iniciando abertura de conexão...")
    local host = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_BancoDeDados.TagLocal_HostName").Value
    local db   = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_BancoDeDados.TagLocal_DataBaseName").Value
    local port = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_BancoDeDados.TagLocal_PortNumber").Value
    local user = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_BancoDeDados.TagLocal_UserName").Value
    local pass = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_BancoDeDados.TagLocal_Password").Value

    print(string.format("Host: %s | DB: %s | Port: %s | User: %s", host, db, port, user))

    local dsn = {
        driver = 'PostgreSQL',
        host = host,
        database = db,
        port = port,
        username = user,
        password = pass
    }

    local con = Database.Get(nomeConexao)
    if not con then
        con = Database.Connect(nomeConexao, dsn)
    end

    if con.Error then
        print("Erro ao conectar:", con.Error)
        return nil, con.Error
    end

    print("Conexão aberta com sucesso.")
    return con
end

-- Escapa apóstrofos
local function escaparSQL(texto)
    return tostring(texto):gsub("'", "''")
end

-- Converte data dd/mm/yyyy HH:MM:SS → yyyy-mm-dd HH:MM:SS
local function converterParaISO(data_br)
    local d, m, y, h, mi, s = data_br:match("^(%d%d)/(%d%d)/(%d%d%d%d) (%d%d):(%d%d):(%d%d)$")
    if d and m and y and h and mi and s then
        return string.format("%s-%s-%s %s:%s:%s", y, m, d, h, mi, s)
    else
        return nil
    end
end

-- Captura valor da TagLocal_Data
local tag_origem = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Manutencao_preventiva.TagLocal_Data")
if not tag_origem then
    print("!! Erro: tag de origem 'TagLocal_Data' não encontrada.")
    return
end

local valor = tostring(tag_origem.Value or ""):gsub("^%s*(.-)%s*$", "%1")
print("Valor original da TagLocal_Data:", valor)

if valor == "" or valor == "30/12/1899 00:00:00" then
    print("!! Valor inválido da tag de origem:", valor)
    return
end

local valor_iso = converterParaISO(valor)
print("Valor convertido para ISO:", valor_iso)
if not valor_iso then
    print("!! Erro ao converter data para formato ISO:", valor)
    return
end

-- Abre conexão
local nomeConexao = "con_preventivemaintenance"
local con, erro = abrirConexao(nomeConexao)
if not con then
    print("!! Falha ao abrir conexão:", erro)
    return
end

-- Loop CTL1 a CTL15
for i = 1, 15 do
    local tag_dest_path = string.format("Kernel.Tags.Local.TagLocalGroup_Manutencao_preventiva.TagLocal_Data_CTL%d", i)
    local tag_checkbox_path = string.format("Kernel.Tags.Local.TagLocalGroup_Manutencao_preventiva.TagLocal_Checkbox_CTL%d", i)

    local tag_dest = Tags.Get(tag_dest_path)
    local tag_checkbox = Tags.Get(tag_checkbox_path)

    if tag_dest and tag_checkbox and tag_checkbox.Value == true then
        print(string.format(">> Checkbox CTL%d está marcado. Processando...", i))

        local valor_antigo = tostring(tag_dest.Value or ""):gsub("^%s*(.-)%s*$", "%1")

        if valor_antigo ~= valor then
            tag_dest.Value = valor
            tag_dest:WriteValue()

            -- Verifica se existe
            local queryExist = string.format(
                "SELECT 1 FROM preventivemaintenance WHERE device_controller_address = %d LIMIT 1;", i)
            local resultExist = con:Execute(queryExist)

            local device_name = string.format("CTL%d", i)
            local sql_cmd = ""

            if resultExist and resultExist:Fetch() then
                -- UPDATE
                sql_cmd = string.format([[
                    UPDATE preventivemaintenance
                    SET data_timestamp = '%s', notice = false, alert = false
                    WHERE device_controller_address = %d;
                ]], valor_iso, i)
                print(">> UPDATE:", sql_cmd)
            else
                -- INSERT (com nome do controlador)
                sql_cmd = string.format([[
                    INSERT INTO preventivemaintenance 
                    (device_controller_name, device_controller_address, data_timestamp, notice, alert)
                    VALUES ('%s', %d, '%s', false, false);
                ]], escaparSQL(device_name), i, valor_iso)
                print(">> INSERT:", sql_cmd)
            end

            local result = con:Execute(sql_cmd)

            if result then
                -- Log histórico
                local data_log = os.date("%Y-%m-%d")
                local acao = string.format("Data da máquina CTL%d atualizada", i)
                local descricao = string.format("A data da máquina CTL%d foi alterada de '%s' para '%s'.", i, valor_antigo, valor)

                local logSQL = string.format([[
                   INSERT INTO public.systemactionhistory (event_name, event_type, timestamp, message)
                    VALUES ('%s','%s', '%s', '%s');
                ]],
                    escaparSQL(acao),
                    "1",
                    data_log,
                    escaparSQL(descricao)
                )
                print(">> LOG:", logSQL)
                con:Execute(logSQL)
            else
                print("!! Falha ao executar INSERT ou UPDATE para CTL", i)
            end
        else
            print(string.format("CTL%d: valor já está igual, não será atualizado.", i))
        end
    else
        print(string.format("CTL%d: Checkbox não marcado ou tag não existe.", i))
    end
end

-- Fecha conexão
con:Disconnect()
print(">> Conexão com o banco encerrada.")
