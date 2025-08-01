--[[
    Script: Atualiza os campos Email1, Email2 e Email3 no banco de dados
            com base no valor atual das tags TagLocal_Email1, 2 e 3.
            Também registra essa ação no histórico de ações.
    Autor: Eduardo Ferreira Leite
    Data: 14/05/2025
]]

-- Função para abrir conexão com PostgreSQL
local function abrirConexao(nomeConexao)
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
        return nil, con.Error
    end

    return con
end

-- Abrir conexão
local nomeConexao = "con_preventivemaintenance"
local con, erro = abrirConexao(nomeConexao)
if not con then
    print("? Erro ao abrir conexão:", erro)
    return
end

-- Atualiza valores no banco com base nas tags Email1, 2 e 3
for i = 1, 3 do
    local tag_path = string.format("Kernel.Tags.Local.TagLocalGroup_Manutencao_preventiva.TagLocal_Email%d", i)
    local tag = Tags.Get(tag_path)

    if not tag then
        print(string.format("?? Tag não encontrada: %s", tag_path))
    else
        local valor = tostring(tag.Value or ""):gsub("^%s*(.-)%s*$", "%1")

        if valor == "" then
            print(string.format("?? Valor vazio para email_send_%d. Não atualizado no banco.", i))
        else
            local query = string.format([[UPDATE public."Users" SET "email_send_%d" = '%s' WHERE true;]], i, valor)
            print("?? SQL enviada ao banco:")
            print(query)

            local resultado = con:Execute(query)
            if resultado then
                print(string.format("? Banco atualizado: email_send_%d = %s", i, valor))
            else
                print(string.format("? Erro ao atualizar email_send_%d no banco.", i))
            end
        end
    end
end

-- Registra ação no histórico
local data_agora = os.date("%Y-%m-%d")
local acao = "Atualizar Email"
local typeac = "1"
local descricao = string.format(
    "Usuário atualizou os campos Email1, Email2 e Email3 com base nas respectivas tags locais em %s.",
    data_agora
)

local insert_query = string.format([[
    INSERT INTO public.systemactionhistory (event_name, event_type, timestamp, message)
    VALUES ('%s','%s', '%s', '%s');
]], acao, typeac, data_agora, descricao)

local resultado_insert = con:Execute(insert_query)
if resultado_insert then
    print("? Ação registrada no histórico com sucesso.")
else
    print("? Erro ao registrar ação no histórico.")
end

-- Fecha conexão
con:Disconnect()
print("?? Atualização de emails no banco concluída.")

-- Lê CountEmail para controle de visibilidade
local tag = Tags.Get("Kernel.Tags.Local.TagLocalGroup_Manutencao_preventiva.TagLocal_CountEmail")
local CountEmail = tag and tonumber(tag.Value) or 1

-- Ajusta componentes visuais da tela
local scr = Sender and Sender.Screen
if not scr then return end

scr.Text_EmailsList.Visible = true
scr.Button_Voltar.Visible = true
scr.Button_MaisEmail.Visible = true
scr.Button_MenosEmail.Visible = true

scr.Button_EditarEmail1.Visible = true
scr.Email_1.Visible = true

if CountEmail > 1 then
    scr.Button_EditarEmail2.Visible = true
    scr.Email_2.Visible = true
end

if CountEmail > 2 then
    scr.Button_EditarEmail3.Visible = true
    scr.Email_3.Visible = true
end

scr.Texto_editar.Visible = false

scr.EditEmail_1.Visible = false
scr.EditEmail1_confirmar.Visible = false
scr.EditEmail1_negar.Visible = false

scr.EditEmail_2.Visible = false
scr.EditEmail2_confirmar.Visible = false
scr.EditEmail2_negar.Visible = false

scr.EditEmail_3.Visible = false
scr.EditEmail3_confirmar.Visible = false
scr.EditEmail3_negar.Visible = false
