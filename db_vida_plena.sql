create database if not exists vidaplena_db
default character set utf8mb4
collate utf8mb4_unicode_ci;

use vidaplena_db;

create table consultorios (
    id_consultorio smallint unsigned not null auto_increment,
    numero_sala smallint unsigned not null,
    andar smallint unsigned not null,
    
    # Chave primária
    constraint pk_consultorios primary key (id_consultorio),
    # Restrição unique de sala e o andar
    constraint uq_consultorio_sala unique (andar, numero_sala)
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table convenios (
    codigo_convenio smallint unsigned not null auto_increment,
    nome varchar(45) not null,
    cnpj char(14) not null,
    telefone char(11) not null,
    pc_cobertura decimal(5,2) not null,
    
    # Chave primária
    constraint pk_convenios primary key (codigo_convenio),
    
    # Restrição unique do cnpj
    constraint uq_convenio_cnpj unique (cnpj),
    
    # Restrição: aqui coloquei pra ter exatamente 14 caracteres no CNPJ
    constraint chk_convenio_cnpj check (cnpj regexp '^[0-9]{14}$'),
    
	# Restrição: valor da cobertura do convenio é maior que 0 e menor que 100 (que pobreza)
    constraint chk_convenio_cobertura check (pc_cobertura >= 0 and pc_cobertura <= 100)
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table especialidades (
    id_especialidade smallint unsigned not null auto_increment,
    nome_especialidade varchar(45) not null,
    constraint pk_especialidades primary key (id_especialidade),
    constraint uq_especialidade_nome unique (nome_especialidade)
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table exames (
    codigo_exame smallint unsigned not null auto_increment,
    nome varchar(45) not null,
    descricao tinytext not null,
    valor_base decimal(8,2) not null,
    prazo smallint unsigned not null,
    categoria varchar(45) not null,
    
    # Primary Key
    constraint pk_exames primary key (codigo_exame),
    
    # Restrição: garantir que não exista dois nomes no mesmo exame
    constraint uq_exame_nome unique (nome),
    
    # Restrição: valor do exame tem que ser maior que zero (é particular, não SUS)
    constraint chk_exame_valor check (valor_base >= 0),
    
    # Restrição: Prazo do exame tem que ser maior que 0
    constraint chk_exame_prazo check (prazo > 0)
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;


create table pacientes (
    id_paciente int unsigned not null auto_increment,
    nome varchar(100) not null,
    cpf char(11) not null,
    data_nascimento date not null,
    sexo varchar(25) not null,
    telefone char(11) not null,
    email varchar(100) not null,
    logradouro varchar(100) not null,
    numero varchar(10) not null,
    complemento varchar(45) null,
    bairro varchar(60) not null,
    cidade varchar(60) not null,
    uf char(2) not null,
    cep char(8) not null,
    
    # Chave primária
    constraint pk_pacientes primary key (id_paciente),
    
    # Restrição: CPF único
    constraint uq_paciente_cpf unique (cpf),
    
    # Restrição: email único
    constraint uq_paciente_email unique (email),
    
    # Restrição: CPF exatamente com 11 dígitos
    constraint chk_paciente_cpf check (cpf regexp '^[0-9]{11}$'),
    
    # Restrição: só pode essas quatro opções
    constraint chk_paciente_sexo check (sexo in ('Masculino', 'Feminino', 'Outros', 'Prefiro Não Responder'))
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table paciente_telefones (
    id_paciente int unsigned not null,
    telefone char(11) not null,
    
    # Chave primária
    constraint pk_paciente_telefones primary key (id_paciente, telefone),
    
    # Chave Estrangeira
    constraint fk_pt_paciente foreign key (id_paciente) references pacientes(id_paciente)
        on update cascade on delete cascade
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table contatos_emergencia (
    id_contato int unsigned not null auto_increment,
    id_paciente int unsigned not null,
    nome varchar(100) not null,
    telefone char(11) not null,
    parentesco varchar(30) not null,
    
    # Chave primária
    constraint pk_contatos_emergencia primary key (id_contato),
    
    #Chave Estrangeira
    constraint fk_ce_paciente foreign key (id_paciente) references pacientes(id_paciente)
        on update cascade on delete cascade
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table convenio_pacientes (
    codigo_convenio smallint unsigned not null,
    id_paciente int unsigned not null,
    carteirinha varchar(20) not null,
    validade date not null,
    tipo_vinculo varchar(15) not null,
    
    # Chave primária
    constraint pk_convenio_pacientes primary key (codigo_convenio, id_paciente),
    
    # Restrição: Cada convênio ligado a uma carteirinha
    constraint uq_cp_carteirinha unique (codigo_convenio, carteirinha),
    
    # Chave Estrangeira
    constraint fk_cp_convenio foreign key (codigo_convenio) references convenios(codigo_convenio)
        on update cascade on delete cascade,
        
	# Chave Estrangeira
    constraint fk_cp_paciente foreign key (id_paciente) references pacientes(id_paciente)
        on update cascade on delete cascade,
        
	# Restrição: tipo de vínculo do convênio
    constraint chk_cp_vinculo check (tipo_vinculo in ('Titular', 'Dependente', 'Agregado'))
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table funcionarios (
    matricula smallint unsigned not null,
    nome varchar(100) not null,
    cpf char(11) not null,
    cargo varchar(45) not null,
    data_admissao date not null,
    salario decimal(10,2) not null,
    telefone char(11) not null,
    supervisor_matricula smallint unsigned null,
    
    # Chave primária
    constraint pk_func primary key (matricula),
    
    # Restrição: cada funcionário com CPF único
    constraint uq_func_cpf unique (cpf),
    
    # Restrição: ok, acho que aqui já deu pra entender que são exatamente 11 digitos aff
    constraint chk_func_cpf check (cpf regexp '^[0-9]{11}$'),
    
    # Restrição: salario maior que zero (a não ser que você queira trabalhar de graça)
    constraint chk_func_salario check (salario >= 0),
    
    # Chave Estrangeira
    constraint fk_func_supervisor foreign key (supervisor_matricula) references funcionarios(matricula)
        on update cascade
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table medicos (
    id_medico smallint unsigned not null auto_increment,
    id_consultorio smallint unsigned not null,
    nome varchar(100) not null,
    crm char(6) not null,
    crm_uf char(2) not null,
    data_admissao date not null,
    telefone char(11) not null,
    email varchar(100) not null,
    salario decimal(10,2) not null,
    
    # Chave primária
    constraint pk_medicos primary key (id_medico),
    
    # Restrição: CRM unico por estado
    constraint uq_medico_crm unique (crm, crm_uf),
    
    # Restrição: cada médico tem um unico email
    constraint uq_medico_email unique (email),
    
    # Restrição: não é medico do SUS
    constraint chk_medico_salario check (salario >= 0),
    
    # Chave Estrangeira
    constraint fk_med_consultorio foreign key (id_consultorio) references consultorios(id_consultorio)
        on update cascade on delete cascade
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table medico_especialidades (
    id_medico smallint unsigned not null,
    id_especialidade smallint unsigned not null,
    
    # Chave primária
    constraint pk_medico_especialidades primary key (id_medico, id_especialidade),
    
    # Chaves estrangeiras
    constraint fk_me_medico foreign key (id_medico) references medicos(id_medico)
        on update cascade on delete cascade,
    constraint fk_me_especialidade foreign key (id_especialidade) references especialidades(id_especialidade)
        on update cascade on delete cascade
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table consultas (
    id_consulta int unsigned not null auto_increment,
    id_paciente int unsigned not null,
    id_medico smallint unsigned not null,
    data_hora datetime not null,
    
    # Chave primária
    constraint pk_consultas primary key (id_consulta),
    
    # Restrição: médico não pode atender dois pacientes no mesmo horario
    constraint uq_medico_horario unique (id_medico, data_hora),
    
    # Restrição: mesma coisa acima, só que para pacientes
    constraint uq_paciente_horario unique (id_paciente, data_hora),
    
    # Chaves Estrangeiras
    constraint fk_con_paciente foreign key (id_paciente) references pacientes(id_paciente)
        on update cascade on delete cascade,
    constraint fk_con_medico foreign key (id_medico) references medicos(id_medico)
        on update cascade on delete cascade,
        
	# Indíce das datas/horários das consultas
    index idx_consultas_data (data_hora)
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table prescricoes (
    id_prescricao int unsigned not null auto_increment,
    id_consulta int unsigned not null,
    descricao tinytext not null,
    
    # Chave Primária
    constraint pk_prescricoes primary key (id_prescricao),
    
    # Chave Estrangeira
    constraint fk_presc_consulta foreign key (id_consulta) references consultas(id_consulta)
        on update cascade on delete cascade
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table solicitacoes_exame (
    id_solicitacao int unsigned not null auto_increment,
    id_consulta int unsigned not null,
    data_solicitacao datetime not null default current_timestamp,
    
    # Chave primária
    constraint pk_solicitacoes_exame primary key (id_solicitacao),
    
    # Chave Estrangeira
    constraint fk_solic_consulta foreign key (id_consulta) references consultas(id_consulta)
        on update cascade on delete cascade
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;


create table itens_exame (
    id_solicitacao int unsigned not null,
    codigo_exame smallint unsigned not null,
    data_realizacao datetime null,
    resultado tinytext null,
    status varchar(15) not null default 'Pendente',
    
    # Chave primária
    constraint pk_itens_exame primary key (id_solicitacao, codigo_exame),
    
    # Chaves Estrangeiras
    constraint fk_item_solicitacao foreign key (id_solicitacao) references solicitacoes_exame(id_solicitacao)
        on update cascade on delete cascade,
    constraint fk_item_exame foreign key (codigo_exame) references exames(codigo_exame)
        on update cascade on delete cascade,
        
	# Restrição: os status só podem ser esses
    constraint chk_item_status check (status in ('Pendente', 'Realizado', 'Cancelado')),
    
    # Restrição: resultado dos exames e a data ficam nulos quando não forem realizados
    constraint chk_item_realizado check (status <> 'Realizado' or (data_realizacao is not null and resultado is not null))
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table pagamentos (
    id_pagamento int unsigned not null auto_increment,
    id_consulta int unsigned null,
    id_solicitacao int unsigned null,
    codigo_convenio smallint unsigned null,
    forma_pagamento varchar(20) not null,
    valor decimal(8,2) not null,
    data_pagamento datetime not null default current_timestamp,
    status varchar(15) not null default 'Pendente',
    
    # Chave primária
    constraint pk_pagamentos primary key (id_pagamento),
    
    # Restrição: restringe a um pagamento a cada consulta
    constraint uq_pag_consulta unique (id_consulta),
    
    # Restrição: restringe a um pagamento a cada solicitação
    constraint uq_pag_solicitacao unique (id_solicitacao),
    
    # Chaves Estrangeiras
    constraint fk_pag_consulta foreign key (id_consulta) references consultas(id_consulta),
    constraint fk_pag_solicitacao foreign key (id_solicitacao) references solicitacoes_exame(id_solicitacao),
    constraint fk_pag_convenio foreign key (codigo_convenio) references convenios(codigo_convenio),
    constraint chk_pag_origem check (
        (id_consulta is not null and id_solicitacao is null)
        or (id_consulta is null and id_solicitacao is not null)
    ),
    
    # Restrição: se a forma de pagamento for por convênio, então código_convenio é obrigatório
    constraint chk_pag_convenio check (forma_pagamento <> 'Convenio' or codigo_convenio is not null),
    
    # Restrição: só aceita essas formas de pagamento
    constraint chk_pag_forma check (forma_pagamento in ('Convenio', 'Dinheiro', 'Debito', 'Credito', 'PIX')),
    
    # Restrição: só é possível esses status
    constraint chk_pag_status check (status in ('Aprovado', 'Recusado', 'Pendente')),
    
    # Restrição: pagamento tem que ser maior que 0 (óbvio)
    constraint chk_pag_valor check (valor >= 0),
    
    # Indíce das datas dos pagamentos
    index idx_pagamentos_data (data_pagamento)
) engine=innodb default charset=utf8mb4 collate=utf8mb4_unicode_ci;


insert into consultorios (numero_sala, andar) values
(101, 1),
(102, 1),
(201, 2),
(202, 2);

insert into convenios (nome, cnpj, telefone, pc_cobertura) values
('Vitalis Saúde',                 '32458174000199', '2132458900', 80.00),
('MedPrev Assistência Médica',    '18906327000192', '2125017700', 70.00),
('Carioca Saúde',                 '45710293000139', '2133019020', 50.00);

insert into especialidades (nome_especialidade) values
('Clínica Médica'),
('Cardiologia'),
('Dermatologia'),
('Ortopedia'),
('Pediatria');

insert into exames (nome, descricao, valor_base, prazo, categoria) values
('Hemograma Completo',  'Contagem de células sanguíneas com leucograma e plaquetas', 35.00, 1, 'Laboratorial'),
('Raio-X de Tórax',     'Radiografia de tórax em PA e perfil',                       90.00, 2, 'Imagem'),
('Eletrocardiograma',   'Registro da atividade elétrica do coração em repouso',      70.00, 1, 'Cardiológico'),
('Glicemia de Jejum',   'Dosagem de glicose no sangue após jejum de 8 horas',        18.00, 1, 'Laboratorial');

insert into pacientes (nome, cpf, data_nascimento, sexo, telefone, email, logradouro, numero, complemento, bairro, cidade, uf, cep) values
('Camila Ribeiro Duarte',     '14783250979', '1989-03-14', 'Feminino',  '21987214530', 'camila.duarte89@gmail.com',     'Rua Conde de Bonfim',  '1020', 'Apto 304', 'Tijuca',           'Rio de Janeiro',     'RJ', '20520054'),
('Wesley Nascimento Barbosa', '38562914746', '1993-08-27', 'Masculino', '21996382741', 'wesley.barbosa@hotmail.com',    'Rua Capitão Pinto',    '212',  null,      'Vila São Luís',    'Duque de Caxias',    'RJ', '25070310'),
('Cláudio Mendes Pacheco',    '09257483150', '1971-11-02', 'Masculino', '21981405937', 'claudio.pacheco71@gmail.com',   'Rua Francisco Sá',     '58',   'Casa',    'Jardim Meriti',    'São João de Meriti', 'RJ', '25555120'),
('Thaís Cristina Moreira',    '56190327877', '1998-12-02', 'Feminino',  '21973658812', 'thais.moreira98@outlook.com',   'Rua Atílio Vivacqua',  '740',  'Bloco B', 'Centro',           'Nova Iguaçu',        'RJ', '26221040'),
('Rodrigo Alves Teixeira',    '72941860576', '2001-07-30', 'Masculino', '21999147026', 'rodrigo.teixeira@gmail.com',    'Rua Moreira César',    '305',  'Apto 802','Icaraí',           'Niterói',            'RJ', '24230200');

insert into paciente_telefones (id_paciente, telefone) values
(1, '21974820635'),
(3, '21982659403'),
(4, '21991376508');

insert into contatos_emergencia (id_paciente, nome, telefone, parentesco) values
(1, 'Renato Duarte',      '21985731402', 'Cônjuge'),
(2, 'Edileuza Barbosa',   '21976094318', 'Mãe'),
(3, 'Sandra Pacheco',     '21988420967', 'Esposa'),
(4, 'Marlene Moreira',    '21993561074', 'Mãe');

insert into convenio_pacientes (codigo_convenio, id_paciente, carteirinha, validade, tipo_vinculo) values
(1, 1, '00340127896502', '2027-08-31', 'Titular'),
(2, 2, '09123847500160', '2027-03-31', 'Titular'),
(1, 3, '00340127811240', '2027-08-31', 'Titular'),
(3, 1, '71580264930015', '2026-12-31', 'Titular');

insert into funcionarios (matricula, nome, cpf, cargo, data_admissao, salario, telefone, supervisor_matricula) values
(1001, 'Fernanda Lopes Siqueira', '21497530652', 'Gerente Administrativa',  '2018-06-15', 7850.00, '21981936740', null),
(1004, 'Aline Cardoso Prates',    '63820149740', 'Técnica de Enfermagem',  '2020-02-03', 3420.00, '21975208413', 1001),
(1009, 'Diego Santana Freitas',   '85043619260', 'Recepcionista',          '2022-01-10', 2180.00, '21998462071', 1001),
(1015, 'Luana Gomes Batista',     '47319082560', 'Recepcionista',          '2024-05-20', 2180.00, '21983015592', 1009);

insert into medicos (id_consultorio, nome, crm, crm_uf, data_admissao, telefone, email, salario) values
(1, 'Rafael Monteiro Cardoso',  '528341', 'RJ', '2019-02-11', '21982047516', 'rafael.cardoso@vidaplena.com.br',    14800.00),
(2, 'Beatriz Almeida Louzada',  '603719', 'RJ', '2019-08-26', '21997315824', 'beatriz.louzada@vidaplena.com.br',   13200.00),
(3, 'Gustavo Henrique Brandão', '744052', 'RJ', '2021-06-01', '21986520139', 'gustavo.brandao@vidaplena.com.br',   12900.00),
(3, 'Larissa Pimentel Coutinho','812266', 'RJ', '2022-09-19', '21994783260', 'larissa.coutinho@vidaplena.com.br',  13600.00);

insert into medico_especialidades (id_medico, id_especialidade) values
(1, 2),
(2, 1),
(2, 5),
(3, 3),
(4, 4);

insert into consultas (id_paciente, id_medico, data_hora) values
(1, 1, '2026-10-05 08:30:00'),
(2, 2, '2026-10-05 10:15:00'),
(3, 3, '2026-10-06 11:00:00'),
(4, 4, '2026-10-06 14:40:00'),
(5, 1, '2026-10-07 09:20:00'),
(1, 2, '2026-10-08 15:30:00');

insert into prescricoes (id_consulta, descricao) values
(1, 'Losartana potássica 50 mg, 1 comprimido pela manhã, uso contínuo. Retorno em 30 dias com os resultados dos exames.'),
(2, 'Dipirona 500 mg, 1 comprimido a cada 6 horas se febre ou dor, por até 3 dias. Repouso e hidratação.'),
(3, 'Cetoconazol 2% creme, aplicar na lesão 1 vez ao dia por 14 dias. Evitar exposição solar direta na região.'),
(4, 'Naproxeno 500 mg a cada 12 horas por 5 dias, após as refeições. Fisioterapia 2 vezes por semana por 6 semanas.');

insert into solicitacoes_exame (id_consulta, data_solicitacao) values
(1, '2026-10-05 09:05:00'),
(2, '2026-10-05 10:50:00'),
(5, '2026-10-07 09:50:00');

insert into itens_exame (id_solicitacao, codigo_exame, data_realizacao, resultado, status) values
(1, 1, '2026-10-07 07:40:00', 'Hb 13,8 g/dL; leucócitos 7.200/mm³; plaquetas 248.000/mm³', 'Realizado'),
(1, 3, null, null, 'Pendente'),
(2, 4, '2026-10-06 07:25:00', 'Glicemia de jejum: 94 mg/dL', 'Realizado'),
(3, 2, null, null, 'Cancelado');

insert into pagamentos (id_consulta, id_solicitacao, codigo_convenio, forma_pagamento, valor, data_pagamento, status) values
(1,    null, 1,    'Convenio', 64.00,  '2026-10-05 09:10:00', 'Aprovado'),
(2,    null, 2,    'Convenio', 78.00,  '2026-10-05 11:00:00', 'Aprovado'),
(3,    null, 1,    'Convenio', 60.00,  '2026-10-06 11:40:00', 'Aprovado'),
(4,    null, null, 'Credito',  350.00, '2026-10-06 15:20:00', 'Aprovado'),
(5,    null, null, 'PIX',      320.00, '2026-10-07 09:55:00', 'Aprovado'),
(6,    null, 3,    'Convenio', 130.00, '2026-10-08 16:05:00', 'Pendente'),
(null, 1,    1,    'Convenio', 21.00,  '2026-10-05 09:12:00', 'Aprovado'),
(null, 2,    2,    'Convenio', 5.40,   '2026-10-05 11:05:00', 'Aprovado');
