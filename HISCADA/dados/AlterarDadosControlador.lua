--[[ 
    Script: Registra ou atualiza no banco os dados do controlador (Nome, Endereço, Modelo, Número de Série)
]]

-- === Função para abrir conexão com PostgreSQL ===
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

-- === 1. Obtem informações do controlador ===
local instance = Sender.Screen:GetInstance('RefModel_Cfg_controlador')

if not instance then
    print("? Erro: Instância do controlador não encontrada")
    return
end

local numero_controlador = string.match(instance.Name, "Controlador_(%d+)")

if not numero_controlador then
    print("? Erro: Número do controlador não encontrado")
    return
end

local caminho_nome = "Instances.InstanceGroup_Controladores.Controlador_"..numero_controlador..".Tags.Opc.Nome_Controlador.Nome_Controlador"
local caminho_modelo = "Instances.InstanceGroup_Controladores.Controlador_"..numero_controlador..".Tags.Opc.Modelo_Controlador.Modelo"
local caminho_numero_serie = "Instances.InstanceGroup_Maquinas.Controlador_"..numero_controlador..".Tags.Local.Maquina.NumeroDeSerie"

local tag_nome = Tags.Get(caminho_nome)
local tag_modelo = Tags.Get(caminho_modelo)
local tag_numero_serie = Tags.Get(caminho_numero_serie)

local nome = tag_nome and tag_nome.Value or "Nulo"
local modelo = tag_modelo and tag_modelo.Value or "Nulo"
local numero_serie = tag_numero_serie and tag_numero_serie.Value or "Nulo"
local endereco = numero_controlador

print("========== INFORMAÇÕES DO CONTROLADOR ==========")
print("Nome: ", nome)
print("Endereço: ", endereco)
print("Modelo: ", modelo)
print("Número de Série: ", numero_serie)
print("=================================================")

-- === 2. Abrir conexão ===
local nomeConexao = "con_preventivemaintenance"
local con, erro = abrirConexao(nomeConexao)

if not con then
    print("? Erro ao abrir conexão:", erro)
    return
end

-- === 3. Verificar se já existe registro com o mesmo endereço ===
local selectQuery = string.format([[
    SELECT * FROM public.devicecontroller WHERE "address" = '%s';
]], endereco)

local cursor = con:Execute(selectQuery)

if cursor then
    local row = cursor:Fetch()  -- busca a primeira linha
    if row then
        -- ?? Já existe: Faz UPDATE
        local updateQuery = string.format([[
            UPDATE public.devicecontroller
            SET "name" = '%s',
                "serial_number" = '%s',
                "model" = '%s'
            WHERE "address" = '%s';
        ]], nome, numero_serie, modelo, endereco)

        print("SQL enviada ao banco (UPDATE):")
        print(updateQuery)

        local resultado = con:Execute(updateQuery)
        if resultado then
            print("? Dados atualizados na tabela public.maquinas com sucesso.")
        else
            print("? Erro ao atualizar dados no banco.")
        end
    else
        -- ? Não existe: Faz INSERT
        local insertQuery = string.format([[
            INSERT INTO public.devicecontroller("name", "serial_number", "model", "address")
            VALUES ('%s', '%s', '%s', '%s');
        ]], nome, numero_serie, modelo, endereco)

        print("SQL enviada ao banco (INSERT):")
        print(insertQuery)

        local resultado = con:Execute(insertQuery)
        if resultado then
            print("? Dados inseridos na tabela public.maquinas com sucesso.")
        else
            print("? Erro ao inserir dados no banco.")
        end
    end
    cursor:Close()
else
    print("? Erro na execução da query SELECT.")
end

-- === 4. Fechar conexão ===
con:Disconnect()
print("?? Conexão com o banco finalizada.")

local scr = Sender and Sender.Screen
if not scr then return end

scr.Caixa_Confirmacao.Visible = false
scr.Texto_confirmacao.Visible = false
scr.Confirmar_exclusao.Visible = false
scr.Negar_exclusao.Visible = false

local ret = Screens.Open("Screen_Habilita_Instancias","Viewers.Screens.ScreenGroup_Configuracao.Screen_Habilita_Instancias")

if Screens.Exist("Screen_Configuracao_Controlador") then
  --print("Tela Existe")
  Screens.Close("Screen_Configuracao_Controlador")
end
