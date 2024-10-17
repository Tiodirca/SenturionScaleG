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
  static const rotaCadastroItemEscala = "telaCadastroItem";
  static const rotaAtualizarItemEscala = "telaAtualizarItemEscala";

  static const rotaArgumentoTipoVoluntario = "tipoVoluntario";
  static const rotaArgumentoListaVoluntarios = "listaVoluntarios";
  static const rotaArgumentoListaDiasSemana = "listaDiasSemana";
  static const rotaArgumentoListaIntervaloTrabalho = "listaIntervaloTrabalho";
  static const rotaArgumentoListaVoluntariosEspecificos =
      "listaVoluntariosEspeficicos";
  static const rotaArgumentoListaDiasEspecificos = "listaDiasEspeficicos";
  static const rotaArgumentoNomeEscala = "nomeEscala";
  static const rotaArgumentoIDEscalaSelecionada  = "IDEscalaSelecionada";

  // variaveis responsaveis pela gravacao e consulta no firebase
  // referente aos nomes de voluntarios masculino e feminino
  static const fireBaseColecaoVoluntarios = "nome_voluntarios";
  static const fireBaseDocumentoCooperadoras = "cooperadoras";
  static const fireBaseDocumentoCooperadores = "cooperadores";
  static const fireBaseNomeVoluntario = "NomeVoluntario";
  static const fireBaseDadosVoluntarios = "dadosVoluntarios";

  static const fireBaseColecaoEscala = "escalas";
  static const fireBaseDocumentoEscala = "nome_escalas";
  static const fireBaseDadosCadastrados = "dados_tabela";

  static const escalaModelo = "escala_modelo";

  // dados da escala de trabalho
  static const idItem = "id";
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


  // ICONES
  static const iconeAdicionar = "adicionar";
  static const iconeTelaInicial = "telaInicial";
  static const iconeAtualizar = "atualizar";
  static const iconeAdicionarEscala = "adicionarEscala";
  static const iconeLista = "lista";
  static const iconeConfiguracao = "configuracao";
  static const iconeOpcoesData = "opcoesData";

  static const iconeExclusao = "exclusao";
  static const iconeRecarregar = "recarregar";
  static const iconeBaixar = "baixar";
  static const iconeEditar = "editar";


  static const iconeSalvar = "salvar";
  static const iconeDataCulto = "dataCulto";


// Horario padrao de trocas de cooperadores
  static const horarioInicialSemana = "19:00";
  static const horarioTrocaSemana = "20:15";
  static const horarioInicialFSemana = "18:00";
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
