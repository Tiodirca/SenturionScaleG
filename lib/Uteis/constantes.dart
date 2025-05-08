import 'package:flutter/material.dart';

class Constantes {
  // rotas
  static const rotaTelaInicial = "rotaTelaInicial";
  static const rotaTelaCadastroVoluntarios = "telaCadastroSelecaoVoluntarios";
  static const rotaTelaConfiguracoes = "telaConfiguracoes";
  static const rotaTelaSplash = "telaSplash";
  static const rotaSelecaoDiasSemana = "telaSelecaoDiasSemana";
  static const rotaSelecaoInvervaloTrabalho = "telaIntervaloTrabalho";
  static const rotaSelecaoDiasEspecifico = "telaDiasEspecifico";
  static const rotaGerarEscala = "telaGerarEscala";

  static const rotaListarEscalas = "telaListarEscalas";
  static const rotaEscalaDetalhada = "telaEscalaDetalhada";
  static const rotaEscalaDetalhadaSom = "telaEscalaDetalhadaSom";
  static const rotaCadastroItemEscala = "telaCadastroItem";
  static const rotaAtualizarItemEscala = "telaAtualizarItemEscala";
  static const rotaAtualizarItemEscalaSom = "telaAtualizarItemEscalaSom";
  static const rotaCadastroItemEscalaSom = "telaCadastroItemSom";
  static const rotaArgumentoTipoVoluntario = "tipoVoluntario";
  static const rotaArgumentoListaVoluntarios = "listaVoluntarios";
  static const rotaArgumentoListaDiasSemana = "listaDiasSemana";
  static const rotaArgumentoListaIntervaloTrabalho = "listaIntervaloTrabalho";
  static const rotaArgumentoNomeEscala = "nomeEscala";
  static const rotaArgumentoIDEscalaSelecionada = "IDEscalaSelecionada";
  static const argumentoDiferenciarEscalaSom = "som_";

  // variaveis responsaveis pela gravacao e consulta no firebase
  // referente aos nomes de voluntarios masculino e feminino
  static const fireBaseColecaoVoluntarios = "nome_voluntarios";
  static const fireBaseDocumentoCooperadoras = "cooperadoras";
  static const fireBaseDocumentoCooperadores = "cooperadores";
  static const fireBaseDocumentoSonoplastas = "sonoplastas";
  static const fireBaseNomeVoluntario = "NomeVoluntario";
  static const fireBaseDadosVoluntarios = "dadosVoluntarios";

  static const fireBaseColecaoEscala = "escalas";
  static const fireBaseDocumentoEscala = "nome_escalas";
  static const fireBaseDadosCadastrados = "dados_tabela";

  static const escalaModelo = "escala_modelo";

  static const opcaoDataSelecaoDepartamento = "selecaoDepartamento";

  // dados da escala de trabalho
  static const idItem = "id";
  static const porta01 = "porta01";
  static const banheiroFeminino = "banheiroFeminino";
  static const primeiraHoraPulpito = "primeiraHoraPulpito";
  static const segundaHoraPulpito = "segundaHoraPulpito";
  static const primeiraHoraEntrada = "primeiraHoraEntrada";
  static const segundaHoraEntrada = "segundaHoraEntrada";
  static const recolherOferta = "recolherOferta";
  static const uniforme = "uniforme";
  static const mesaApoio = "mesaApoio";
  static const servirSantaCeia = "servirSantaCeia";
  static const dataCulto = "dataCulto";
  static const horarioTroca = "horarioTroca";
  static const irmaoReserva = "irmaoReserva";

  static const videos = "videos";
  static const mesaSom = "mesaSom";
  static const notebook = "notebook";

  static const gravataPreta = "Gravata Preta";
  static const gravataAzul = "Gravata Azul";
  static const gravataVermelha = "Gravata Vermelha";
  static const gravataDourada = "Gravata Dourada";
  static const gravataVerde = "Gravata Verde";
  static const gravataAmarela = "Gravata Amarela";
  static const gravataMarsala = "Gravata Marsala";

  // ICONES
  static const iconeTelaInicial = Icons.home_filled;
  static const iconeAdicionar = Icons.add;
  static const iconeAtualizar = Icons.update;
  static const iconeLista = Icons.list_alt_outlined;
  static const iconeOpcoesData = Icons.settings;

  static const iconeExclusao = Icons.close;
  static const iconeRecarregar = Icons.refresh;
  static const iconeBaixar = Icons.download_rounded;

  static const iconeSalvar = Icons.save;
  static const iconeSalvarOpcoes = Icons.save_as;
  static const iconeDataCulto = Icons.date_range_outlined;

// Horario padrao de trocas de cooperadores
  static const horarioInicialSemana = "19:20";
  static const horarioTrocaSemana = "20:15";
  static const horarioInicialFSemana = "17:50";
  static const horarioTrocaFsemana = "19:00";
  static const horarioMudado = "sim";

  // datas da semana
  static String diaSegunda = "Segunda-feira";
  static String diaTerca = "Terça-feira";
  static String diaQuarta = "Quarta-feira";
  static String diaQuinta = "Quinta-feira";
  static String diaSexta = "Sexta-feira";
  static String diaSabado = "Sábado";
  static String diaDomingo = "Domingo";

  static const String domingo = "domingo";
  static const String sabado = "sábado";

  // constantes para gravacao  e mudanca do horario de troca
  static const shareHorarioInicialSemana = "horarioInicialSemana";
  static const shareHorarioTrocaSemana = "horarioFinalSemana";
  static const shareHorarioInicialFSemana = "horarioInicialFSemana";
  static const shareHorarioTrocaFsemana = "horarioFinalFSemana";
  static const trocarHorarioSemana = "semana";
  static const trocarHorarioFimSemana = "fimSemana";
}
