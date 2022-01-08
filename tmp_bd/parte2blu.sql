CREATE SCHEMA proj;
set search_path to proj; 
set datestyle = mdy;



CREATE TABLE utente
(
    email varchar(100)  NOT NULL,
    nome varchar(50) ,
    cognome varchar(50) ,
    nickname varchar(20) ,
    datanascita date,
    CONSTRAINT utente_pkey PRIMARY KEY (email)
);


CREATE TABLE icona
(
    id_icona integer NOT NULL,
    immagine varchar(50),
    nome varchar(50),
    CONSTRAINT icona_pkey PRIMARY KEY (id_icona)
);

CREATE TABLE plancia
(
    id_plancia integer NOT NULL,
    tema varchar(30),
    CONSTRAINT plancia_pkey PRIMARY KEY (id_plancia)
);

CREATE TABLE gioco
(
    id_gioco integer NOT NULL,
    maxsquadre integer NOT NULL,
    idplancia integer NOT NULL,
    tempomax integer NOT NULL,
    sfondo varchar(30),
    CONSTRAINT gioco_pkey PRIMARY KEY (id_gioco),
    CONSTRAINT gioco_idplancia_fkey FOREIGN KEY (idplancia)
        REFERENCES plancia (id_plancia)
);

CREATE TABLE dado
(
    id_dado integer NOT NULL,
    id_gioco integer NOT NULL,
    CONSTRAINT dado_pkey PRIMARY KEY (id_dado),
    CONSTRAINT dado_idgioco_fkey FOREIGN KEY (id_gioco)
        REFERENCES gioco (id_gioco)        
);


CREATE TABLE sfida
(
    id_sfida integer NOT NULL,
    data_ora_inizio timestamp without time zone NOT NULL,
    data_ora_fine timestamp without time zone NOT NULL,
    id_gioco integer NOT NULL,
    CONSTRAINT sfida_pkey PRIMARY KEY (id_sfida),
    CONSTRAINT sfida_id_gioco_fkey FOREIGN KEY (id_gioco)
        REFERENCES gioco (id_gioco),
    CONSTRAINT sfida_check CHECK (data_ora_inizio < data_ora_fine)
);

CREATE TABLE moderatore
(
    email_utente varchar(100) NOT NULL,
    id_sfida integer NOT NULL,
    tipo varchar(12) NOT NULL,
    CONSTRAINT moderatore_pkey PRIMARY KEY (email_utente),
    CONSTRAINT moderatore_id_sfida_key UNIQUE (id_sfida),
    CONSTRAINT moderatore_email_utente_fkey FOREIGN KEY (email_utente)
        REFERENCES utente (email),
    CONSTRAINT moderatore_id_sfida_sfida_fkey FOREIGN KEY (id_sfida)
        REFERENCES sfida (id_sfida),    
    CONSTRAINT moderatore_tipo_check CHECK (tipo::text = 'caposquadra'::text OR tipo::text = 'coach'::text)
);

CREATE TABLE coach
(
    email varchar(100) NOT NULL,
    CONSTRAINT coach_pkey PRIMARY KEY (email),
    CONSTRAINT coach_email_fkey FOREIGN KEY (email)
        REFERENCES moderatore (email_utente)
);

CREATE TABLE caposquadra
(
    email varchar(100) NOT NULL,
    CONSTRAINT caposquadra_pkey PRIMARY KEY (email),
    CONSTRAINT caposquadra_email_fkey1 FOREIGN KEY (email)
        REFERENCES moderatore (email_utente)
);

CREATE TABLE gioco_contiene_icone
(
    id_icona integer NOT NULL,
    id_gioco integer NOT NULL,
    CONSTRAINT gioco_contiene_icone_pkey PRIMARY KEY (id_icona, id_gioco),
    CONSTRAINT gioco_contiene_icone_id_gioco_fkey FOREIGN KEY (id_gioco)
        REFERENCES gioco (id_gioco),
    CONSTRAINT gioco_contiene_icone_id_icona_fkey FOREIGN KEY (id_icona)
        REFERENCES icona (id_icona)
);

CREATE TABLE casella
(
    num_casella integer NOT NULL,
    id_gioco integer NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    video varchar(150),
    dadi_per_lancio integer,
    num_casella_successiva integer,
    tipo varchar(4) NOT NULL,
    CONSTRAINT casella_pkey PRIMARY KEY (num_casella, id_gioco),
    CONSTRAINT casella_id_gioco_fkey FOREIGN KEY (id_gioco)
        REFERENCES gioco (id_gioco),
    CONSTRAINT casella_check CHECK ((x <> -1 OR y <> -1) AND (x <> -2 OR y <> -2) AND (x <> -3 OR y <> -3)),
    CONSTRAINT casella_tipo_check CHECK (tipo = 'quiz' OR tipo = 'task')
);

CREATE TABLE quiz
(
    num_casella integer NOT NULL,
    id_gioco integer NOT NULL,
    testo varchar(150),
    immagine varchar(200),
    tempo_max integer NOT NULL,
    CONSTRAINT quiz_pkey PRIMARY KEY (num_casella, id_gioco),
    CONSTRAINT quiz_num_casella_fkey FOREIGN KEY (num_casella, id_gioco)
        REFERENCES casella (num_casella, id_gioco)
);

CREATE TABLE task
(
    num_casella integer NOT NULL,
    id_gioco integer NOT NULL,
    testo varchar(200) ,
    punteggio integer,
    tempo_max integer NOT NULL,
    punteggio_assegnato integer NOT NULL,
    CONSTRAINT task_pkey PRIMARY KEY (num_casella, id_gioco),
    CONSTRAINT task_num_casella_fkey FOREIGN KEY (num_casella, id_gioco)
        REFERENCES casella (num_casella, id_gioco),
    CONSTRAINT task_tempo_max_check CHECK (tempo_max >= 0)
);

CREATE TABLE risposta_quiz
(
    num_casella integer NOT NULL,
    id_gioco integer NOT NULL,
    numero_risposta integer NOT NULL,
    testo varchar(150),
    immagine varchar(200),
    punteggio integer,
    CONSTRAINT risposta_quiz_pkey PRIMARY KEY (num_casella, id_gioco, numero_risposta),
    CONSTRAINT risposta_quiz_num_casella_fkey FOREIGN KEY (id_gioco, num_casella)
        REFERENCES casella (id_gioco, num_casella)
);

CREATE TABLE risposta_task
(
    id_risp_task integer NOT NULL,
    file varchar(200),
    email_utente varchar(100),
    num_casella integer NOT NULL,
    id_gioco integer NOT NULL,
    email_moderatore varchar(100),
    CONSTRAINT risposta_task_pkey PRIMARY KEY (id_risp_task),
    CONSTRAINT risposta_task_email_moderatore_fkey FOREIGN KEY (email_moderatore)
        REFERENCES moderatore (email_utente),
    CONSTRAINT risposta_task_email_utente_fkey FOREIGN KEY (email_utente)
        REFERENCES utente (email),
    CONSTRAINT risposta_task_num_casella_fkey FOREIGN KEY (num_casella, id_gioco)
        REFERENCES casella (num_casella, id_gioco)       
);

CREATE TABLE squadra
(
    nome varchar(20),
    id_icona integer NOT NULL,
    id_sfida integer NOT NULL,
    CONSTRAINT squadra_pkey PRIMARY KEY (nome, id_icona, id_sfida),
    CONSTRAINT squadra_id_icona_fkey FOREIGN KEY (id_icona)
        REFERENCES icona (id_icona),
    CONSTRAINT squadra_id_sfida_fkey FOREIGN KEY (id_sfida)
        REFERENCES sfida (id_sfida)      
);

CREATE TABLE turno
(
    num_turno integer NOT NULL,
    id_icona integer NOT NULL,
    nome_squadra varchar(30),
    id_sfida integer NOT NULL,
    num_casella integer NOT NULL,
    id_gioco integer NOT NULL,
    punteggio integer NOT NULL,
    num_risp_quiz integer,
    risp_task integer,
    casella_quiz integer,
    gioco_quiz integer,
    CONSTRAINT turno_pkey PRIMARY KEY (num_turno),
    CONSTRAINT turno_gioco_quiz_fkey FOREIGN KEY (casella_quiz, gioco_quiz, num_risp_quiz)
        REFERENCES risposta_quiz (num_casella, id_gioco, numero_risposta),
    CONSTRAINT turno_id_icona_fkey FOREIGN KEY (id_icona, nome_squadra, id_sfida)
        REFERENCES squadra (id_icona, nome, id_sfida),
    CONSTRAINT turno_num_casella_fkey FOREIGN KEY (num_casella, id_gioco)
        REFERENCES casella (num_casella, id_gioco),
    CONSTRAINT turno_risp_task_fkey FOREIGN KEY (risp_task)
        REFERENCES risposta_task (id_risp_task)
);


CREATE TABLE lancio
(
    num_turno integer NOT NULL,
    id_dado integer NOT NULL,
    valore integer NOT NULL,
    CONSTRAINT lancio_pkey PRIMARY KEY (num_turno, id_dado),
    CONSTRAINT lancio_id_dado_fkey FOREIGN KEY (id_dado)
        REFERENCES dado (id_dado),
    CONSTRAINT lancio_num_turno_fkey FOREIGN KEY (num_turno)
        REFERENCES turno (num_turno),
    CONSTRAINT lancio_valore_check CHECK (valore <= 6 AND valore >= 1)
);


CREATE TABLE èmembro
(
    email varchar(150) NOT NULL,
    id_icona_sq integer NOT NULL,
    nome_sq varchar(150) NOT NULL,
    id_sfida_sq integer NOT NULL,
    CONSTRAINT gioca_pkey PRIMARY KEY (email, id_icona_sq, nome_sq, id_sfida_sq),
    CONSTRAINT gioca_email_fkey FOREIGN KEY (email)
        REFERENCES utente (email) MATCH SIMPLE,
    CONSTRAINT gioca_id_icona_sq_fkey FOREIGN KEY (id_icona_sq, nome_sq, id_sfida_sq)
        REFERENCES squadra (id_icona, nome, id_sfida) MATCH SIMPLE
);


CREATE TABLE podio
(
    num_turno integer NOT NULL,
    x1 integer NOT NULL DEFAULT -1,
    x2 integer NOT NULL DEFAULT -2,
    x3 integer NOT NULL DEFAULT -3,
    y1 integer NOT NULL DEFAULT -1,
    y2 integer NOT NULL DEFAULT -2,
    y3 integer NOT NULL DEFAULT -3,
    icona1 integer,
    icona2 integer,
    icona3 integer,
    CONSTRAINT podio_pkey PRIMARY KEY (num_turno),
    CONSTRAINT podio_icona1_fkey FOREIGN KEY (icona1)
        REFERENCES icona (id_icona),
    CONSTRAINT podio_icona2_fkey FOREIGN KEY (icona2)
        REFERENCES icona (id_icona),
    CONSTRAINT podio_icona3_fkey FOREIGN KEY (icona3)
        REFERENCES icona (id_icona),
    CONSTRAINT podio_num_turno_fkey FOREIGN KEY (num_turno)
        REFERENCES turno (num_turno),
    CONSTRAINT podio_check CHECK (x1 = -1 AND y1 = -1 AND x2 = -2 AND y2 = -2 AND x3 = -3 AND y3 = -3)
);