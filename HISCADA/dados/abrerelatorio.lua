--[[
    Ambiente: Desenvolvimento
    Projeto: Coldvisio
    Empresa: Coldline
    Versão: 1.4.0
    Responsável: Eduardo Ferreira Leite
    Data: 25/11/2024

    Descrição:
    Script unificado para decidir entre quatro scripts (Histórico de Controladores, Gráfico de Temperatura, Relatório de Portas ou Alarmes/Acionamentos)
]]

-- Função para obter tags com validação opcional
local function ObterTag(nome, obrigatoria)
    local tag = Tags.Get(nome)
    if obrigatoria and tag == nil then
        MessageBox("Erro: Tag '" .. nome .. "' não encontrada.")
        error("Tag obrigatória ausente: " .. nome)
    end
    return tag
end

-- Obtém a tela
local scr = Sender and Sender.Screen
if scr == nil then
    MessageBox("Erro: 'scr' está nil. Verifique se Sender.Screen está disponível.")
    return
end

-- Obtém a tag para decidir qual script executar
local tag_tipo_relatorio = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_Tipo_Relatorio", true)
local tipo_relatorio = tag_tipo_relatorio.Value

-- Validação do tipo de relatório
if tipo_relatorio < 1 or tipo_relatorio > 4 then
    MessageBox("Erro: Tipo de relatório inválido. Deve ser 1 (Histórico de Controladores), 2 (Gráfico de Temperatura), 3 (Relatório de Portas) ou 4 (Alarmes/Acionamentos).")
    return
end

-- Tags compartilhadas
local tag_inicio = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_Inicial", true)
local tag_final = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_Final", true)
local tag_clp_conectado = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_Conexao.TagLocal_Id_Ultima_conexao", true)
local tag_num_controladores = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_NumeroControladoresCheckBox", true)

-- Validação das datas
if tag_inicio.Value == "" or tag_final.Value == "" then
    MessageBox("Erro: Datas de início e fim são necessárias.")
    return
end

-- Obtém os controladores selecionados
local controladores_selecionados = {}
for i = 1, 15 do
    local checkbox_tag = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_CheckBox_Controlador" .. i, false)
    local nome_controlador_tag = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_Instancias.Nome_controlador_" .. i, false)
    if checkbox_tag and checkbox_tag.Value == true and nome_controlador_tag then
        table.insert(controladores_selecionados, nome_controlador_tag.Value)
    end
end

local num_controladores = #controladores_selecionados
if tipo_relatorio < 3 and num_controladores < 1 then
    MessageBox("Erro: Selecione pelo menos 1 controlador.")
    return
elseif num_controladores > 5 then
    MessageBox("Erro: Selecione no máximo 5 controladores.")
    return
end

-- Atualiza a tag com o número de controladores selecionados
tag_num_controladores.Value = num_controladores
tag_num_controladores:WriteValue()

-- Ajusta para exatamente 5 controladores
while #controladores_selecionados < 5 do
    table.insert(controladores_selecionados, controladores_selecionados[1] or "Controlador_Padrão")
end
-- Função para o script 1 (Histórico de Controladores)
local function ExecutarHistoricoControladores()
    local string_historico_tags = {
        ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_HistoricoControlador1", true),
        ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_HistoricoControlador2", true),
        ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_HistoricoControlador3", true),
        ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_HistoricoControlador4", true),
        ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_HistoricoControlador5", true)
    }
    
    local tag_tipo_grafico_tabular = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_TipoGraficoTabular", true)
    local tag_tempo_amostragem = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_SelecaoTempoAmostragem", true)
    
    -- Obtém o valor do tempo de amostragem
    local tempo_amostragem = tag_tempo_amostragem.Value

    -- Define o fator de amostragem com base no intervalo fornecido
    local fator_amostragem = 1
    if tempo_amostragem == 10 then
        fator_amostragem = 2  -- Pega de 2 em 2 registros
    elseif tempo_amostragem == 30 then
        fator_amostragem = 6  -- Pega de 6 em 6 registros
    elseif tempo_amostragem == 60 then
        fator_amostragem = 12  -- Pega de 12 em 12 registros
    end

    for i = 1, 5 do
        local controlador_nome = controladores_selecionados[i]

        -- Monta o comando SQL ajustando a amostragem apenas se necessário
        local cmd = ""
        if tempo_amostragem == 5 then
            -- Consulta normal sem filtro adicional
            cmd = string.format(
                [[
                    SELECT data_timestamp, id_device, name_device, model_device, 
                    MAX(data_real) FILTER (WHERE data_id = %d + id_device) AS dado_1, 
                    MAX(data_real) FILTER (WHERE data_id = %d + id_device) AS dado_2, 
                    MAX(data_int) FILTER (WHERE data_id = %d + id_device) AS dado_3 
                    FROM dataCollection
                    WHERE data_timestamp BETWEEN '%s' AND '%s' 
                    AND name_device = '%s' 
                    AND status_plc = %d 
                    GROUP BY data_timestamp, name_device, model_device, id_device 
                    ORDER BY data_timestamp;
                ]],
                200, 300, 400, 
                tag_inicio.Value, tag_final.Value, controlador_nome, 
                tag_clp_conectado.Value
            )
            print(cmd)
        else
            -- Consulta ajustada com filtro de amostragem
            cmd = string.format(
                [[
                    SELECT * FROM (
                        SELECT *, 
                        ROW_NUMBER() OVER (PARTITION BY name_device ORDER BY data_timestamp) AS row_num
                        FROM (
                            SELECT data_timestamp, id_device, name_device, model_device, 
                            MAX(data_real) FILTER (WHERE data_id = %d + id_device) AS dado_1, 
                            MAX(data_real) FILTER (WHERE data_id = %d + id_device) AS dado_2, 
                            MAX(data_int) FILTER (WHERE data_id = %d + id_device) AS dado_3 
                            FROM dataCollection 
                            WHERE data_timestamp BETWEEN '%s' AND '%s' 
                            AND name_device = '%s' 
                            AND status_plc = %d 
                            GROUP BY data_timestamp, name_device, model_device, id_device
                        ) AS A
                    ) AS B 
                    WHERE (row_num %% %d = 1) -- Filtra os valores com base no intervalo de amostragem
                    ORDER BY data_timestamp;
                ]],
                200, 300, 400, 
                tag_inicio.Value, tag_final.Value, controlador_nome, 
                tag_clp_conectado.Value, fator_amostragem
            )
            print(cmd)
        end

        -- Atualiza a tag com o comando SQL gerado
        string_historico_tags[i].Value = cmd
        string_historico_tags[i]:WriteValue()
    end

    -- Define o caminho do relatório com base no tipo de exibição (gráfico ou tabular)
    local CaminhoRelatorio = ""
    if tag_tipo_grafico_tabular.Value == 1 then
        CaminhoRelatorio = "Globals.Reports.ReportsGroup_relatorios.Report_HistoricoControladores"
    elseif tag_tipo_grafico_tabular.Value == 2 then
        CaminhoRelatorio = "Globals.Reports.ReportsGroup_relatorios.Report_HistoricoControladoresGrafico"
    end

    print("aqui1")
    print(CaminhoRelatorio)

    -- Obtém e exibe o relatório
    local rep = Reports.GetReport(CaminhoRelatorio)
    print(rep)
    if not rep or not rep:ShowReport() then
        print(CaminhoRelatorio)
        print(rep)
        MessageBox("Erro: Falha ao exibir o relatório.")
    end
end

-- Função para o script 2 (Gráfico de Temperatura)
local function ExecutarGraficoTemperatura()
    local string_eventos_tags = {
        ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_HistoricoControlador1", true),
        ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_HistoricoControlador2", true),
        ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_HistoricoControlador3", true),
        ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_HistoricoControlador4", true),
        ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_HistoricoControlador5", true)
    }
    local tag_tipo_grafico_tabular = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_TipoGraficoTabular", true)

    for i = 1, 5 do
        local controlador_nome = controladores_selecionados[i]
        local cmd = string.format(
            "SELECT * FROM (SELECT data_timestamp, id_device, name_device, model_device, " ..
            "MAX(data_real) FILTER (WHERE data_id = id_device) AS dado_1, " ..
            "MAX(data_real) FILTER (WHERE data_id = %d + id_device) AS dado_2 " ..
            "FROM dataCollection WHERE data_timestamp BETWEEN '%s' AND '%s' AND name_device = '%s' " ..
            "AND status_plc = %d GROUP BY data_timestamp, name_device, model_device, id_device " ..
            "ORDER BY data_timestamp, name_device) AS A WHERE dado_1 IS NOT NULL AND dado_2 IS NOT NULL;",
            100, tag_inicio.Value, tag_final.Value, controlador_nome, tag_clp_conectado.Value
        )
        print(cmd)
        string_eventos_tags[i].Value = cmd
        string_eventos_tags[i]:WriteValue()
    end

    local CaminhoRelatorio = ""
    if tag_tipo_grafico_tabular.Value == 1 then
        CaminhoRelatorio = "Globals.Reports.ReportsGroup_relatorios.Report_HistoricoTempDiaria"
    elseif tag_tipo_grafico_tabular.Value == 2 then
        CaminhoRelatorio = "Globals.Reports.ReportsGroup_relatorios.Report_HistoricoTempDiariaGrafico"
    end
    print("aqui2")
    print(CaminhoRelatorio)

    local rep = Reports.GetReport(CaminhoRelatorio)
    print(rep)
    if not rep or not rep:ShowReport() then
         print(CaminhoRelatorio)
        print(rep)
        MessageBox("Erro: Falha ao exibir o relatório.")
    end
end

-- Função para o script 3 (Relatório de Portas)
local function ExecutarRelatorioPortas()
    local string_porta = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_string_portas", true)
    local valor_combo = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_Selecao_porta", true)

    if valor_combo.Value == 0 then
        MessageBox("WAW: Selecione uma Porta!")
        return
    end

    local cmd = ""
    if valor_combo.Value == -1 then
        cmd = string.format(
            "SELECT * FROM dataCollection WHERE data_timestamp BETWEEN '%s' AND '%s' AND data_id > 500 AND status_plc = %d ORDER BY id_device",
            tag_inicio.Value, tag_final.Value, tag_clp_conectado.Value
        )
    else
        cmd = string.format(
            "SELECT * FROM dataCollection WHERE data_timestamp BETWEEN '%s' AND '%s' AND data_id = %d AND status_plc = %d ORDER BY data_timestamp",
            tag_inicio.Value, tag_final.Value, 500 + valor_combo.Value, tag_clp_conectado.Value
        )
    end
    print(cmd)

    string_porta.Value = cmd
    string_porta:WriteValue()
    Sleep(500)

    local i = 0
    while (i <= 2) do
        local err = string_porta:ReadCache()
        if string_porta.Value == cmd then
            i = 10
        end
        i = i + 1
        Sleep(100)
    end

    if i == 3 then
        MessageBox("WAW: Erro ao abrir o relatório, tente novamente!")
        return
    end

    local CaminhoRelatorio = "Globals.Reports.ReportsGroup_relatorios.Report_Eventos_Porta"
    local rep = Reports.GetReport(CaminhoRelatorio)

    if rep == nil or not rep:ShowReport() then
        MessageBox("ERW: Falha na execução do comando!")
        return
    end
end

-- Função para o script 4 (Alarmes e Acionamentos)
local function ExecutarAlarmesAcionamentos()
    local string_alarme = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_String_Alarmes", true)
    local tag_alarm_acion = ObterTag("Kernel.Tags.Local.TagLocalGroup_KN_relatorio.TagLocal_Alarmes_Acionamentos", true)

    if tag_alarm_acion.Value ~= 1 and tag_alarm_acion.Value ~= 2 then
        MessageBox("Erro: O valor de 'TagLocal_Alarmes_Acionamentos' deve ser 1 (Alarmes) ou 2 (Acionamentos PHP).")
        return
    end

    local cmd = ""
    if tag_alarm_acion.Value == 1 then
        cmd = string.format("SELECT * FROM systemactionhistory WHERE timestamp BETWEEN '%s' AND '%s' ORDER BY timestamp", tag_inicio.Value, tag_final.Value)
    elseif tag_alarm_acion.Value == 2 then
        cmd = string.format("SELECT * FROM systemactionhistory WHERE tag_name = 'TagOpcGroup_Alarmes.TagOpc_Alarmes_STS_PHP' AND timestamp BETWEEN '%s' AND '%s' ORDER BY timestamp", tag_inicio.Value, tag_final.Value)
    end

print(cmd)

    string_alarme.Value = cmd
    string_alarme:WriteValue()
    Sleep(500)

    local i = 0
    while (i <= 2) do
        local err = string_alarme:ReadCache()
        if string_alarme.Value == cmd then
            i = 10
        end
        i = i + 1
        Sleep(100)
    end

    if i == 3 then
        MessageBox("WAW: Erro ao abrir o relatório, tente novamente!")
        return
    end

    local CaminhoRelatorio = "Globals.Reports.ReportsGroup_alarme.Report_Alarmes"
    local rep = Reports.GetReport(CaminhoRelatorio)

    if not rep or not rep:ShowReport() then
        MessageBox("ERW: Falha na execução do comando!")
        return
    end
end

-- Decide qual script executar
if tipo_relatorio == 1 then
    ExecutarHistoricoControladores()
elseif tipo_relatorio == 2 then
    ExecutarGraficoTemperatura()
elseif tipo_relatorio == 3 then
    ExecutarRelatorioPortas()
elseif tipo_relatorio == 4 then
    ExecutarAlarmesAcionamentos()
end
