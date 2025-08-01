--[[
    Script: Atualiza tags locais Data_CTLx e emails com valores do banco
    Autor: Eduardo Ferreira Leite
    Data: 13/05/2025
    Revisado: ChatGPT
]]

print("🚀 Início do script de atualização de datas e emails")

-- Converte data ISO → dd/MM/yyyy 00:00:00
local function normalizarData(data_str)
    -- data_str ISO esperada: yyyy-mm-ddTHH:MM:SS ou yyyy-mm-dd HH:MM:SS
    local y, m, d = data_str:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)")
    if y and m and d then
        return string.format("%s/%s/%s 00:00:00", d, m, y)
    end
    return nil
end

-- Abre conexão com PostgreSQL
local function abrirConexao(nomeConexao)
    print("🔌 Tentando abrir conexão com banco...")

    local host = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_BancoDeDados.TagLocal_HostName").Value
    local db   = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_BancoDeDados.TagLocal_DataBaseName").Value
    local port = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_BancoDeDados.TagLocal_PortNumber").Value
    local user = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_BancoDeDados.TagLocal_UserName").Value
    local pass = Tags.Get("Kernel.Tags.Local.TagLocalGroup_KN_BancoDeDados.TagLocal_Password").Value

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
        print("❌ Erro de conexão:", con.Error)
        return nil, con.Error 
    end

    print("✅ Conexão com banco aberta com sucesso.")
    return con
end

-- Atualiza tags CTL com data
local function atualizarTagsDoBanco(con)
    print("📋 Executando SELECT na tabela preventivemaintenance...")

    local query = [[
        SELECT data_timestamp, device_controller_address
        FROM preventivemaintenance;
    ]]

    local cursor, err = con:Execute(query)
    if err then
        print("❌ Erro ao executar consulta:", err)
        return
    end

    local linha = 0
    while true do
        local row = cursor:Fetch()
        if not row then break end
        linha = linha + 1

        local endereco = tonumber(row.device_controller_address)
        local raw_data = row.data_timestamp and tostring(row.data_timestamp) or ""

        print(string.format("\n🔎 Linha %d | CTL%d", linha, endereco or -1))
        print("   🧪 Data do banco (raw):", raw_data)

        if endereco and endereco >= 1 and endereco <= 15 and raw_data ~= "" then
            -- Verifica o formato recebido
            local y, m, d = raw_data:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)")
            local d2, m2, y2 = raw_data:match("^(%d%d)/(%d%d)/(%d%d%d%d)")

            print("   🔍 Verificando padrões de data:")
            print(string.format("     ISO detectado? %s", y and "Sim" or "Não"))
            print(string.format("     BR detectado? %s", d2 and "Sim" or "Não"))

            local data_formatada = nil

            if y and m and d then
                -- formato ISO (yyyy-mm-dd)
                data_formatada = string.format("%s/%s/%s 00:00:00", d, m, y)
            elseif d2 and m2 and y2 then
                -- formato brasileiro (dd/mm/yyyy)
                data_formatada = string.format("%s/%s/%s 00:00:00", d2, m2, y2)
            end

            if data_formatada then
                local tag_path = string.format("Kernel.Tags.Local.TagLocalGroup_Manutencao_preventiva.TagLocal_Data_CTL%d", endereco)
                local tag = Tags.Get(tag_path)
                if tag then
                    print("   📅 Data formatada:", data_formatada)
                    print("   ✏️ Valor atual da tag:", tostring(tag.Value))
                    tag.Value = data_formatada
                    tag:WriteValue()
                    print("   ✅ Tag atualizada:", tostring(tag.Value))
                else
                    print("   ⚠️ Tag não encontrada:", tag_path)
                end
            else
                print("   ❌ Nenhum formato de data reconhecido! Valor bruto:", raw_data)
            end
        else
            print("   ⚠️ Dados incompletos ou inválidos. Endereço:", endereco, "| Data:", raw_data)
        end
    end


    print("\n✅ Final da atualização das datas.")
end

-- Atualiza os emails do usuário com id = '0001'
local function atualizarEmails(con)
    print("\n📬 Iniciando atualização de emails do usuário id = '0001'...")

    local query = [[
        SELECT email_send_1, email_send_2, email_send_3
        FROM "Users"
        WHERE id = '0001'
        LIMIT 1;
    ]]
    
    local cursor, err = con:Execute(query)
    if err or not cursor then 
        print("❌ Erro ao buscar emails:", err or "Cursor inválido")
        return 
    end

    local row = cursor:Fetch()
    if not row then 
        print("⚠️ Nenhum usuário com id = '0001' encontrado.")
        return 
    end

    for i = 1, 3 do
        local colname = "email_send_" .. i
        local email = tostring(row[colname] or ""):match("^%s*(.-)%s*$")
        local tag_path = string.format("Kernel.Tags.Local.TagLocalGroup_Manutencao_preventiva.TagLocal_Email%d", i)
        local tag = Tags.Get(tag_path)
        if tag then
            tag.Value = email
            tag:WriteValue()
            print(string.format("   ✅ Email %d atualizado para: %s", i, email))
        else
            print(string.format("   ⚠️ Tag %s não encontrada", tag_path))
        end
    end
end

-- Execução principal
local nomeConexao = "con_preventivemaintenance"
local con, erro = abrirConexao(nomeConexao)
if not con then
    print("❌ Erro ao abrir conexão:", erro)
    return
end

atualizarTagsDoBanco(con)
atualizarEmails(con)

con:Disconnect()
print("✅ Script concluído com sucesso.")
