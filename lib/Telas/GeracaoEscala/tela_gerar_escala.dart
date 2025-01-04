import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senturionscaleg/Modelo/escala_modelo.dart';
import 'package:senturionscaleg/Uteis/metodos_auxiliares.dart';
import 'package:senturionscaleg/Widgets/tela_carregamento.dart';
import '../../Modelo/check_box_modelo.dart';
import '../../Uteis/estilo.dart';
import '../../Uteis/textos.dart';
import '../../Uteis/constantes.dart';

class TelaGerarEscala extends StatefulWidget {
  final String tipoCadastroVoluntarios;
  final List<CheckBoxModelo> voluntariosSelecionados;
  final List<CheckBoxModelo> diasSemanaCulto;
  final List<String> intervaloTrabalho;

  const TelaGerarEscala(
      {super.key,
      required this.tipoCadastroVoluntarios,
      required this.voluntariosSelecionados,
      required this.diasSemanaCulto,
      required this.intervaloTrabalho});

  @override
  State<TelaGerarEscala> createState() => _TelaGerarEscalaState();
}

class _TelaGerarEscalaState extends State<TelaGerarEscala> {
  String ordenarCadastroVoluntarios = "";
  bool exibirWidgetCarregamento = false;
  final validacaoFormulario = GlobalKey<FormState>();
  Estilo estilo = Estilo();
  String idDocumento = "";
  TextEditingController nomeEscala = TextEditingController(text: "");
  Random random = Random();
  List<int> listaNumeroAuxiliarRepeticao = [];

  List<String> nomeVoluntarios = [];
  List<EscalaModelo> escalaSorteada = [];
  List<String> locaisSorteioVoluntarios = [
    Constantes.porta01,
    Constantes.banheiroFeminino,
    Constantes.primeiraHoraPulpito,
    Constantes.segundaHoraPulpito,
    Constantes.primeiraHoraEntrada,
    Constantes.segundaHoraEntrada,
    Constantes.mesaApoio,
    Constantes.recolherOferta,
    Constantes.irmaoReserva
  ];
  String horarioSemana = "";
  String horarioFinalSemana = "";

  List<String> gravataCor = [
    Constantes.gravataPreta,
    Constantes.gravataAmarela,
    Constantes.gravataAzul,
    Constantes.gravataDourada,
    Constantes.gravataMarsala,
    Constantes.gravataVerde,
    Constantes.gravataVermelha
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // removendo da lista de locais de trabalho os pontos
    // que nao irao receber voluntarios baseado no tipo de voluntario
    if (widget.tipoCadastroVoluntarios !=
        Constantes.fireBaseDocumentoCooperadores) {
      // caso o tipo de voluntario seja diferente do parametro
      // passado entrar no if e remover os seguintes elementos
      locaisSorteioVoluntarios.removeWhere((element) =>
          element.contains(
            Constantes.primeiraHoraPulpito,
          ) ||
          element.contains(
            Constantes.segundaHoraPulpito,
          ) ||
          element.contains(
            Constantes.recolherOferta,
          ) ||
          element.contains(
            Constantes.porta01,
          ));
    } else {
      locaisSorteioVoluntarios.removeWhere((element) =>
          element.contains(
            Constantes.mesaApoio,
          ) ||
          element.contains(
            Constantes.banheiroFeminino,
          ));
    }
    //adicionando o nome dos voluntarios a uma lista de String
    for (var element in widget.voluntariosSelecionados) {
      // add somente o nome na lista
      nomeVoluntarios.add(element.texto);
    }
    // chamando metodo para recuperar o horario de troca de turno
    chamarRecuperarHorarioTroca();
  }

  // metodo para chamar recuperacao do horario de troca de turno
  chamarRecuperarHorarioTroca() async {
    horarioSemana = await MetodosAuxiliares.recuperarValoresSharePreferences(
        Constantes.diaSegunda);
    horarioFinalSemana =
        await MetodosAuxiliares.recuperarValoresSharePreferences(
            Constantes.diaDomingo);
  }

  // metodo para realizar o sorteio dos nomes nos locais de trabalho
  fazerSorteio() {
    setState(() {
      exibirWidgetCarregamento = true;
    });
    // limpando listas
    escalaSorteada.clear();
    listaNumeroAuxiliarRepeticao.clear();
    var linha = {};
    int numeroRandomico = 0;
    // chamando metodo para sortear posicoes na lista de numero
    // sem repeticao para ser utilizado no FOR abaixo
    sortearNomesSemRepeticao(numeroRandomico);
    for (var elemento in widget.intervaloTrabalho) {
      // fazendo a iteracao baseado na quantidade de dias selecionados no intervalo de trabalho
      for (int index = 0; index < locaisSorteioVoluntarios.length; index++) {
        // fazendo iteracao baseado na quantidade de locais de trabalho disponiveis
        // a cada interacao a LINHA vai receber um ELEMENTO/LOCAL de trabalho baseado
        // no index que esta e vai atribuir um NOME DE VOLUNTARIO a esse LOCAL da
        // LINHA baseado no valor que a LISTA de NUMEROS AUXILIAR recebeu para que
        // não haja repeticao de nomes na mesma LINHA
        linha[locaisSorteioVoluntarios.elementAt(index)] = nomeVoluntarios
            .elementAt(listaNumeroAuxiliarRepeticao.elementAt(index));
      }
      String horarioTroca = "";
      //verificando se a data Contem algum dos parametros a abaixo para
      // definir qual sera o horario de troca de turno
      if (elemento.contains(Constantes.diaDomingo.toLowerCase()) ||
          elemento.contains(Constantes.diaSabado.toLowerCase())) {
        horarioTroca = horarioFinalSemana;
      } else {
        horarioTroca = horarioSemana;
      }

      //adiocionando os itens sorteados em uma
      // LISTA do MODELO DE ESCALA para poder trabalhar
      // com cada item separadamente depois
      escalaSorteada.add(EscalaModelo(
          dataCulto: elemento,
          // verificando qual o tipo de voluntario para
          // preencher o capo com a informacao
          // correspondente ao tipo de voluntario
          porta01: widget.tipoCadastroVoluntarios ==
                  Constantes.fireBaseDocumentoCooperadores
              ? linha[Constantes.porta01]
              : "",
          banheiroFeminino: widget.tipoCadastroVoluntarios ==
                  Constantes.fireBaseDocumentoCooperadores
              ? ""
              : linha[Constantes.banheiroFeminino],
          primeiraHoraEntrada: linha[Constantes.primeiraHoraEntrada],
          segundaHoraEntrada: linha[Constantes.segundaHoraEntrada],
          primeiraHoraPulpito: widget.tipoCadastroVoluntarios ==
                  Constantes.fireBaseDocumentoCooperadores
              ? linha[Constantes.primeiraHoraPulpito]
              : "",
          segundaHoraPulpito: widget.tipoCadastroVoluntarios ==
                  Constantes.fireBaseDocumentoCooperadores
              ? linha[Constantes.segundaHoraPulpito]
              : "",
          recolherOferta: widget.tipoCadastroVoluntarios ==
                  Constantes.fireBaseDocumentoCooperadores
              ? linha[Constantes.recolherOferta]
              : "",
          mesaApoio: widget.tipoCadastroVoluntarios ==
                  Constantes.fireBaseDocumentoCooperadores
              ? ""
              : linha[Constantes.mesaApoio],
          uniforme: widget.tipoCadastroVoluntarios ==
                  Constantes.fireBaseDocumentoCooperadores
              ? sortearGravata()
              : "",
          horarioTroca: horarioTroca,
          servirSantaCeia: "",
          irmaoReserva: linha[Constantes.irmaoReserva]));
      //chamando metodo para sortear
      // novas combinacoes de nome
      sortearNomesSemRepeticao(numeroRandomico);
    }
    chamarCadastroItens(escalaSorteada);
  }

  sortearGravata() {
    int numeroRandom = random.nextInt(gravataCor.length);
    return gravataCor.elementAt(numeroRandom);
  }

  // metodo para chamar o sorteio de nomes sem repeticao
  sortearNomesSemRepeticao(int numeroRandomico) {
    listaNumeroAuxiliarRepeticao.clear(); //limpando lista
    for (var element in locaisSorteioVoluntarios) {
      // para cada interacao sortear um numero entre 0 e o
      // tamanho da lista de locais de trabalho
      numeroRandomico = random.nextInt(nomeVoluntarios.length);
      sortearNumeroSemRepeticao(numeroRandomico); //chamando metodo
    }
  }

  // metodo para sortear numero sem repeticao
  sortearNumeroSemRepeticao(int numeroRandomico) {
    //caso a lista nao contenha o numero randomico entrar no if
    if (!listaNumeroAuxiliarRepeticao.contains(numeroRandomico)) {
      //adicionando numero NAO repetido a lista para posteriormente
      // ser utilizada ao posicionar o nome dos voluntarios
      // nos locais de trabalho
      listaNumeroAuxiliarRepeticao.add(numeroRandomico);
      return numeroRandomico;
    } else {
      // sorteando outro numero pois o numero
      // sorteado anteriormente ja esta na lista
      numeroRandomico = random.nextInt(nomeVoluntarios.length);
      sortearNumeroSemRepeticao(numeroRandomico);
    }
  }

  // metodo para chamar o cadastro de itens no banco de dados
  chamarCadastroItens(List<EscalaModelo> escalaModelo) async {
    int contador = 0;
    var db = FirebaseFirestore.instance;
    db
        // definindo a COLECAO no Firebase
        .collection(Constantes.fireBaseColecaoEscala)
        // definindo o nome do DOCUMENTO
        .add({
      Constantes.fireBaseDocumentoEscala:
          MetodosAuxiliares.removerEspacoNomeTabelas(nomeEscala.text)
    });
    String idDocumentoFirebase = await buscarIDDocumentoFirebase();
    for (var element in escalaModelo) {
      cadastrarItens(element, idDocumentoFirebase);
      contador++;
      if (contador == escalaModelo.length) {
        Map dados = {};
        dados[Constantes.rotaArgumentoNomeEscala] =
            MetodosAuxiliares.removerEspacoNomeTabelas(nomeEscala.text);
        dados[Constantes.rotaArgumentoIDEscalaSelecionada] =
            idDocumentoFirebase;
        Navigator.pushReplacementNamed(
            arguments: dados, context, Constantes.rotaEscalaDetalhada);
      }
    }
  }

  buscarIDDocumentoFirebase() async {
    String idDocumentoFirebase = "";
    var db = FirebaseFirestore.instance;
    await db
        // definindo a COLECAO no Firebase
        .collection(Constantes.fireBaseColecaoEscala)
        // selecionar todos os itens que contem o parametro passado
        .where(Constantes.fireBaseDocumentoEscala)
        .get()
        .then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        // verificando se o valor do campo e o mesmo do parametro
        if (docSnapshot.data().values.contains(
            MetodosAuxiliares.removerEspacoNomeTabelas(nomeEscala.text))) {
          // caso seja definir que a variavel vai receber o valor
          idDocumentoFirebase = docSnapshot.id;
        }
      }
    });
    return idDocumentoFirebase;
  }

  // metodo para cadastrar item no banco de dados
  cadastrarItens(EscalaModelo escala, String idDocumentoFirebase) async {
    try {
      var db = FirebaseFirestore.instance;
      db
          .collection(Constantes.fireBaseColecaoEscala)
          .doc(idDocumentoFirebase)
          .collection(Constantes.fireBaseDadosCadastrados)
          .doc()
          .set({
        // adicionando cada item da escala para poder ser gravado online
        Constantes.porta01 : escala.porta01.toString(),
        Constantes.banheiroFeminino : escala.banheiroFeminino.toString(),
        Constantes.primeiraHoraPulpito: escala.primeiraHoraPulpito.toString(),
        Constantes.segundaHoraPulpito: escala.segundaHoraPulpito.toString(),
        Constantes.primeiraHoraEntrada: escala.primeiraHoraEntrada.toString(),
        Constantes.segundaHoraEntrada: escala.segundaHoraEntrada.toString(),
        Constantes.recolherOferta: escala.recolherOferta.toString(),
        Constantes.uniforme: escala.uniforme,
        Constantes.mesaApoio: escala.mesaApoio.toString(),
        Constantes.servirSantaCeia: escala.servirSantaCeia.toString(),
        Constantes.dataCulto: escala.dataCulto,
        Constantes.horarioTroca: escala.horarioTroca,
        Constantes.irmaoReserva: escala.irmaoReserva.toString(),
      });
    } catch (e) {
      MetodosAuxiliares.exibirMensagens(Textos.descricaoNotificacaoSucessoErro,
          Textos.tipoNotificacaoErro, context);
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  chamarTelaCarregamento() {
    setState(() {
      exibirWidgetCarregamento = true;
    });
  }

  redirecionarTelaVoltar() {
    Map dados = {};
    dados[Constantes.rotaArgumentoTipoVoluntario] =
        widget.tipoCadastroVoluntarios;
    dados[Constantes.rotaArgumentoListaVoluntarios] =
        widget.voluntariosSelecionados;
    dados[Constantes.rotaArgumentoListaDiasSemana] = widget.diasSemanaCulto;
    dados[Constantes.rotaArgumentoListaIntervaloTrabalho] =
        widget.intervaloTrabalho;
    Navigator.pushReplacementNamed(
        arguments: dados, context, Constantes.rotaSelecaoInvervaloTrabalho);
  }

  @override
  Widget build(BuildContext context) {
    double larguraTela = MediaQuery.of(context).size.width;
    double alturaTela = MediaQuery.of(context).size.height;
    return Theme(
        data: estilo.estiloGeral,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (exibirWidgetCarregamento) {
                return const TelaCarregamento();
              } else {
                return Scaffold(
                  appBar: AppBar(
                      title: Text(Textos.btnGerarEscala),
                      leading: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          redirecionarTelaVoltar();
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                        ),
                      )),
                  body: Container(
                      color: Colors.white,
                      width: larguraTela,
                      height: alturaTela,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                                height: alturaTela * 0.3,
                                padding: const EdgeInsets.only(bottom: 20.0),
                                width: larguraTela,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        width: larguraTela,
                                        child: Text(
                                            Textos.descricaoTipoVoluntario +
                                                widget.tipoCadastroVoluntarios,
                                            textAlign: TextAlign.end),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Text(
                                          Textos.descricaoGerarEscala,
                                          textAlign: TextAlign.justify,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Form(
                                              key: validacaoFormulario,
                                              child: SizedBox(
                                                width: Platform.isWindows
                                                    ? 300
                                                    : 200,
                                                child: TextFormField(
                                                  controller: nomeEscala,
                                                  onFieldSubmitted: (value) {
                                                    if (validacaoFormulario
                                                        .currentState!
                                                        .validate()) {
                                                      fazerSorteio();
                                                    }
                                                  },
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return Textos
                                                          .erroCampoVazio;
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              )),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            width: 100,
                                            height: 50,
                                            child: FloatingActionButton(
                                              heroTag: Textos.btnCadastro,
                                              onPressed: () {
                                                if (validacaoFormulario
                                                    .currentState!
                                                    .validate()) {
                                                  fazerSorteio();
                                                }
                                              },
                                              child:
                                                  Text(Textos.btnGerarEscala),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      )),
                );
              }
            },
          ),
        ));
  }
}
