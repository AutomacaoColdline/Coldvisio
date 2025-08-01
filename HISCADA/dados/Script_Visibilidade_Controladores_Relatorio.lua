--[[ 
    Ambiente: Desenvolvimento
    Projeto: Coldvisio
    Empresa: Coldline Brasil
    Versão: 1.6.0
    Responsável: Eduardo Ferreira Leite
    Data: 22/11/2024

    Descrição:
    Script para ajustar a visibilidade de elementos na tela com base em dados retornados do banco de dados.
    O script compara apenas as datas (ignora o horário) e ajusta os elementos visuais adequados.
]]

-- Obtém a tela, garantindo que `scr` não seja nil
local scr = Sender and Sender.Screen
if not scr then
    print("Erro: 'scr' está nil. Verifique se Sender.Screen está disponível.")
    return
end

-- Função para definir a visibilidade de um elemento específico
---@param element string Nome do elemento na tela
---@param isVisible boolean Define se o elemento deve ser visível
local function setVisibility(element, isVisible)
    if scr[element] then
        scr[element].Visible = isVisible
        print(string.format("Elemento '%s' atualizado para visibilidade: %s", element, tostring(isVisible)))
    else
        print(string.format("Aviso: Elemento '%s' não encontrado na tela.", element))
    end
end

-- Função para ajustar visibilidade com base na data retornada do banco
local function atualizarEVerificarControlador(conPostgre, controlador_index)
    local nome_controlador = string.format("maquina%d", controlador_index)
    local endereco = controlador_index

    -- Comando SQL para buscar o dado do banco
    local CmdSQL = string.format([[ 
        SELECT data_timestamp
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
        -- print(string.format("Nenhum dado encontrado para o controlador %d.", controlador_index))
        return
    end

    -- Processa os resultados da consulta
    local row = cursor:Fetch() -- Recupera a primeira linha como um dicionário {nome_coluna=valor}

    if row then
        -- Obtém o valor do timestamp
        local timestamp = row["data_timestamp"]

        -- Atualiza a tag com o valor retornado
        local tag_destino = Tags.Get(string.format("Kernel.Tags.Local.TagLocalGroup_Manutencao_preventiva.TagLocal_Data_CTL%d", controlador_index))
        if tag_destino then
            tag_destino.Value = tostring(timestamp)
            tag_destino:WriteValue()
        end

        -- Extrai componentes de data para comparação, ignorando o horário
        local day, month, year = timestamp:match("^(%d%d)/(%d%d)/(%d%d%d%d)")
        if not day or not month or not year then
            print(string.format("Erro: Timestamp '%s' para o controlador %d não está no formato esperado (dd/MM/yyyy).", timestamp, controlador_index))
            return
        end

        -- Converte a data do banco para timestamp
        local tag_date = os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = 0, min = 0, sec = 0 })
        if not tag_date then
            print(string.format("Erro ao criar timestamp para o controlador %d.", controlador_index))
            return
        end

        -- Obtém a data atual como timestamp, ignorando o horário
        local current_date = os.time({ year = tonumber(os.date("%Y")), month = tonumber(os.date("%m")), day = tonumber(os.date("%d")), hour = 0, min = 0, sec = 0 })

        -- Nomes das propriedades para os controladores
        local imageA = string.format("ImageA_CTL%d", controlador_index)
        local imageB = string.format("ImageB_CTL%d", controlador_index)

        -- Ajusta a visibilidade com base na comparação de datas
        if current_date > tag_date then
            -- Data atual é maior que a data do banco (data no passado)
            setVisibility(imageA, true)
            setVisibility(imageB, false)
            print(string.format("Controlador %d: ImageA visível, ImageB oculto (data no passado).", controlador_index))
        else
            -- Data atual é menor ou igual à data do banco (data no futuro)
            setVisibility(imageA, false)
            setVisibility(imageB, true)
            print(string.format("Controlador %d: ImageA oculto, ImageB visível (data no futuro).", controlador_index))
        end
    else
        -- print(string.format("Nenhum dado encontrado para o controlador %d.", controlador_index))
    end
end

-- Abre a conexão com o banco de dados
local conPostgre, error = Scripts.Run("Viewers.Scripts.ScriptGroup_BancoDeDados.Script_AbreConexaoPostgres", "con_preventivemaintenance")

-- Verifica se houve erro ao abrir a conexão
if not conPostgre then
    print("Erro ao abrir a conexão com o banco de dados.")
    return
end

-- Atualiza e verifica os controladores 1, 2 e 3
for i = 1, 3 do
    atualizarEVerificarControlador(conPostgre, i)
end

-- Fecha a conexão com o banco
local disconnect_result = conPostgre:Disconnect()
if disconnect_result then
    -- print("Conexão com o banco encerrada com sucesso.")
else
    print("Erro ao encerrar a conexão com o banco.")
end
