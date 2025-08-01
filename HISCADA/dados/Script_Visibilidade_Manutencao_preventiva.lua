-- Função para atualizar uma tag com base nos dados do banco
local function atualizarTag(conPostgre, controlador_index)
    local nome_controlador = string.format("maquina%d", controlador_index)
    local endereco = controlador_index

    -- Comando SQL para buscar o dado no banco em formato ISO8601
    local CmdSQL = string.format([[ 
        SELECT TO_CHAR(data_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS data_timestamp
        FROM preventivemaintenance
        WHERE device_controller_address = %d AND device_controller_name = '%s'
        LIMIT 1;
    ]], endereco, nome_controlador)

    -- Executa o comando SQL
    local cursor, exec_error = conPostgre:Execute(CmdSQL)

    -- Verifica se houve erro durante a execução do comando
    if exec_error then
        print(string.format("Erro ao buscar dados para o controlador %d: %s", controlador_index, exec_error))
        return
    end

    -- Verifica se o cursor é válido
    if not cursor then
        print(string.format("Nenhum dado encontrado para o controlador %d.", controlador_index))
        return
    end

    -- Processa os resultados da consulta
    local row = cursor:Fetch()

    if row then
        -- Obtém o valor do timestamp
        local timestamp = row["data_timestamp"]

        -- Atualiza a tag com o valor retornado
        local tag_destino = Tags.Get(string.format("Kernel.Tags.Local.TagLocalGroup_Manutencao_preventiva.TagLocal_Data_CTL%d", controlador_index))
        if tag_destino then
            tag_destino.Value = tostring(timestamp)
            tag_destino:WriteValue()
            
        else
            
        end
    else
        print(string.format("Nenhum dado encontrado para o controlador %d.", controlador_index))
    end
end

-- Abrir a conexão com o banco
local conPostgre, error = Scripts.Run("Viewers.Scripts.ScriptGroup_BancoDeDados.Script_AbreConexaoPostgres", "con_preventivemaintenance")

if not conPostgre then
    print("Erro ao abrir a conexão com o banco de dados.")
    return
end

-- Atualizar as tags para os controladores 1 a 15
for i = 1, 15 do
    atualizarTag(conPostgre, i)
end

-- Fechar a conexão com o banco
local disconnect_result = conPostgre:Disconnect()
