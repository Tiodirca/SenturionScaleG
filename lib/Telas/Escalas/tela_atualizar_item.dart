import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:senturionscaleg/Modelo/escala_modelo.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';
import 'package:senturionscaleg/Widgets/widget_opcoes_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Uteis/constantes.dart';
import '../../Uteis/estilo.dart';
import '../../Uteis/metodos_auxiliares.dart';
import '../../Uteis/textos.dart';
import '../../Widgets/barra_navegacao_widget.dart';
import '../../Widgets/tela_carregamento.dart';

class TelaAtualizar extends StatefulWidget {
  TelaAtualizar(
      {Key? key,
      required this.nomeTabela,
      required this.idTabelaSelecionada,
      required this.escalaModelo})
      : super(key: key);

  final String nomeTabela;
  final String idTabelaSelecionada;
  final EscalaModelo escalaModelo;

  @override
  State<TelaAtualizar> createState() => _TelaAtualizarState();
}

class _TelaAtualizarState extends State<TelaAtualizar> {
  Estilo estilo = Estilo();
  bool exibirCampoServirSantaCeia = false;
  bool exibirSoCamposCooperadora = false;
  bool exibirOcultarCamposNaoUsados = false;
  bool exibirWidgetCarregamento = true;
  bool exibirOpcoesData = false;

  TimeOfDay? horarioTimePicker = const TimeOfDay(hour: 19, minute: 00);
  String opcaoDataComplemento = Textos.departamentoCultoLivre;
  String horarioTroca = "";

  late DateTime dataSelecionada = DateTime.now();
  final _formKeyFormulario = GlobalKey<FormState>();
  TextEditingController ctPrimeiroHoraPulpito = TextEditingController(text: "");
  TextEditingController ctSegundoHoraPulpito = TextEditingController(text: "");
  TextEditingController ctPrimeiroHoraEntrada = TextEditingController(text: "");
  TextEditingController ctSegundoHoraEntrada = TextEditingController(text: "");
  TextEditingController ctRecolherOferta = TextEditingController(text: "");
  TextEditingController ctUniforme = TextEditingController(text: "");
  TextEditingController ctMesaApoio = TextEditingController(text: "");
  TextEditingController ctServirSantaCeia = TextEditingController(text: "");
  TextEditingController ctIrmaoReserva = TextEditingController(text: "");
  TextEditingController ctPorta01 = TextEditingController(text: "");
  TextEditingController ctBanheiroFeminino = TextEditingController(text: "");

  Widget camposFormulario(
          double larguraTela, TextEditingController controller, String label) =>
      Container(
        padding:
            const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
        width: MetodosAuxiliares.ajustarTamanhoTextField(larguraTela),
        child: TextFormField(
          keyboardType: TextInputType.text,
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
          ),
        ),
      );

  Widget botoesAcoes(
          String nomeBotao, IconData icone, double largura, double altura) =>
      Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          height: altura,
          width: largura,
          child: FloatingActionButton(
              elevation: 0,
              heroTag: "${nomeBotao}att",
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                  side: BorderSide(color: PaletaCores.corCastanho),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              onPressed: () async {
                //verificando o tipo do botao
                // para fazer acoes diferentes
                if (nomeBotao == Textos.btnAtualizar) {
                  if (_formKeyFormulario.currentState!.validate()) {
                    chamarAtualizarItensBancoDados();
                  }
                } else if (nomeBotao == Textos.btnOpcoesData) {
                  setState(() {
                    exibirOpcoesData = true;
                  });
                } else if (nomeBotao == Textos.btnSalvarOpcoesData) {
                  setState(() {
                    exibirOpcoesData = false;
                    opcaoDataComplemento =
                        MetodosAuxiliares.recuperarDepartamentoSelecionado();
                  });
                } else if (nomeBotao == Textos.btnVerEscalaAtual) {
                  redirecionarTela();
                } else {
                  exibirDataPicker();
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (nomeBotao == Textos.btnOpcoesData) {
                        return Container();
                      } else {
                        return Icon(icone,
                            color: PaletaCores.corAzulMagenta, size: 30);
                      }
                    },
                  ),
                  Text(
                    nomeBotao,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: PaletaCores.corAzulMagenta),
                  )
                ],
              )));

  Widget botoesSwitch(String label, bool valorBotao) => SizedBox(
        width: 180,
        child: Row(
          children: [
            Text(label),
            Switch(
                inactiveThumbColor: PaletaCores.corAzulMagenta,
                value: valorBotao,
                activeColor: PaletaCores.corAzulMagenta,
                onChanged: (bool valor) {
                  setState(() {
                    mudarSwitch(label, valor);
                  });
                })
          ],
        ),
      );

  // metodo para mudar status dos switch
  mudarSwitch(String label, bool valor) {
    if (label == Textos.labelSwitchCooperadora) {
      setState(() {
        exibirSoCamposCooperadora = !valor;
        exibirSoCamposCooperadora = valor;
      });
    } else if (label == Textos.labelSwitchExibirCampos) {
      setState(() {
        exibirOcultarCamposNaoUsados = !exibirOcultarCamposNaoUsados;
      });
    } else if (label == Textos.labelSwitchServirSantaCeia) {
      setState(() {
        exibirCampoServirSantaCeia = !valor;
        exibirCampoServirSantaCeia = valor;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    exibirWidgetCarregamento = false;
    opcaoDataComplemento = Textos.departamentoCultoLivre;
    preencherCampos(widget.escalaModelo);
  }

  @override
  void dispose() {
    super.dispose();
    MetodosAuxiliares.passarDepartamentoSelecionado("");
  }

  redirecionarTela() {
    var dados = {};
    dados[Constantes.rotaArgumentoNomeEscala] = widget.nomeTabela;
    dados[Constantes.rotaArgumentoIDEscalaSelecionada] =
        widget.idTabelaSelecionada;
    Navigator.pushReplacementNamed(context, Constantes.rotaEscalaDetalhada,
        arguments: dados);
  }

  preencherCampos(EscalaModelo element) {
    ctPrimeiroHoraPulpito.text = element.primeiraHoraPulpito;
    ctSegundoHoraPulpito.text = element.segundaHoraPulpito;
    ctPrimeiroHoraEntrada.text = element.primeiraHoraEntrada;
    ctSegundoHoraEntrada.text = element.segundaHoraEntrada;
    ctRecolherOferta.text = element.recolherOferta;
    ctUniforme.text = element.uniforme;
    ctMesaApoio.text = element.mesaApoio;
    ctServirSantaCeia.text = element.servirSantaCeia;
    ctIrmaoReserva.text = element.irmaoReserva;
    ctPorta01.text = element.porta01;
    ctBanheiroFeminino.text = element.banheiroFeminino;
    //verificando se a data salva no banco de dados contem o parametro
    // caso tenha quer dizer que foi gravado opcoes adicionais na data
    if (element.dataCulto.contains("(")) {
      //defindo que a variavel vai receber o seguinte item pegando o INDEX 1,
      //pois o INDEX 0 contem a data no padrao aaaa/mm/dd
      opcaoDataComplemento =
          element.dataCulto.toString().split("(")[1].replaceAll(")", "");
    }
    dataSelecionada =
        DateFormat("dd/MM/yyyy EEEE", "pt_BR").parse(element.dataCulto);
    //verificando se os campos nao estao vazios
    // para exibi-los
    if (element.dataCulto.contains(Textos.departamentoEbom) ||
        element.dataCulto.contains(Textos.departamentoSede)) {
    } else {
      formatarHorario(element.horarioTroca);
      sobreescreverHorarioTroca();
    }
    if (element.servirSantaCeia.isNotEmpty) {
      setState(() {
        exibirCampoServirSantaCeia = true;
      });
    }
    if (element.primeiraHoraPulpito.isEmpty &&
        element.segundaHoraPulpito.isEmpty) {
      setState(() {
        exibirSoCamposCooperadora = true;
      });
    }
    setState(() {
      exibirWidgetCarregamento = false;
    });
  }

  chamarAtualizarItensBancoDados() async {
    setState(() {
      exibirWidgetCarregamento = true;
    });

    String primeiroHoraPulpito = "";
    String segundoHoraPulpito = "";
    String mesaApoio = "";
    String servirSantaCeia = "";
    String porta01 = "";
    String banheiroFeminino = "";

    if (exibirSoCamposCooperadora) {
      primeiroHoraPulpito = "";
      segundoHoraPulpito = "";
      mesaApoio = ctMesaApoio.text;
      banheiroFeminino = ctBanheiroFeminino.text;
      porta01 = "";
    } else {
      primeiroHoraPulpito = ctPrimeiroHoraPulpito.text;
      segundoHoraPulpito = ctSegundoHoraPulpito.text;
      mesaApoio = "";
      porta01 = ctPorta01.text;
      banheiroFeminino = "";
    }
    if (exibirCampoServirSantaCeia) {
      servirSantaCeia = ctServirSantaCeia.text;
    } else {
      servirSantaCeia = "";
    }

    try {
      var db = FirebaseFirestore.instance;
      db
          .collection(Constantes.fireBaseColecaoEscala)
          .doc(widget.idTabelaSelecionada)
          .collection(Constantes.fireBaseDadosCadastrados)
          .doc(widget.escalaModelo.id)
          .set({
        Constantes.porta01: porta01,
        Constantes.banheiroFeminino: banheiroFeminino,
        Constantes.primeiraHoraPulpito: primeiroHoraPulpito,
        Constantes.segundaHoraPulpito: segundoHoraPulpito,
        Constantes.primeiraHoraEntrada: ctPrimeiroHoraEntrada.text,
        Constantes.segundaHoraEntrada: ctSegundoHoraEntrada.text,
        Constantes.recolherOferta: ctRecolherOferta.text,
        Constantes.uniforme: ctUniforme.text,
        Constantes.mesaApoio: mesaApoio,
        Constantes.servirSantaCeia: servirSantaCeia,
        Constantes.dataCulto: formatarData(dataSelecionada),
        Constantes.horarioTroca:
        opcaoDataComplemento.contains(Textos.departamentoEbom)  ||
            opcaoDataComplemento.contains(Textos.departamentoSede)
            ? "--"
                : horarioTroca,
        Constantes.irmaoReserva: ctIrmaoReserva.text,
      });
      MetodosAuxiliares.exibirMensagens(Textos.sucessoMsgAtualizarItemEscala,
          Textos.tipoNotificacaoSucesso, context);
      setState(() {
        redirecionarTela();
      });
    } catch (e) {
      MetodosAuxiliares.exibirMensagens(
          Textos.erroMsgAtualizarEscala, Textos.tipoNotificacaoErro, context);
      setState(() {
        exibirWidgetCarregamento = false;
      });
    }
  }

  // metodo para recuperar os horarios definidos
  // e gravados no share preferences
  recuperarHorarioTroca() async {
    String data = formatarData(dataSelecionada).toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // verificando se a data corresponde a um dia do fim de semana
    if (data.contains(Constantes.sabado) || data.contains(Constantes.domingo)) {
      setState(() {
        horarioTroca = Textos.msgComecoHorarioEscala +
            "${prefs.getString(Constantes.shareHorarioInicialFSemana) ?? ''}";
      });
    } else {
      setState(() {
        horarioTroca = Textos.msgComecoHorarioEscala +
            "${prefs.getString(Constantes.shareHorarioInicialSemana) ?? ''}";
      });
    }
    formatarHorario(horarioTroca);
  }

  // metodo para formatar a data e exibir
  // ela nos moldes exigidos
  formatarData(DateTime data) {
    String dataFormatada = DateFormat("dd/MM/yyyy EEEE", "pt_BR").format(data);
    if (exibirCampoServirSantaCeia) {
      return dataFormatada = "$dataFormatada ( Santa Ceia )";
    } else if (opcaoDataComplemento.isNotEmpty &&
        opcaoDataComplemento != Textos.departamentoCultoLivre) {
      return "$dataFormatada ($opcaoDataComplemento)";
    } else {
      return dataFormatada;
    }
  }

  // metodo para exibir data picker para
  // o usuario selecionar uma data
  exibirDataPicker() {
    showDatePicker(
      helpText: Textos.descricaoDataPicker,
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2001),
      lastDate: DateTime(2222),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.light(
              primary: PaletaCores.corVerdeCiano,
              onPrimary: Colors.white,
              surface: PaletaCores.corAzulMagenta,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    ).then((date) {
      setState(() {
        //definindo que a  variavel vai receber o
        // valor selecionado no data picker
        if (date != null) {
          dataSelecionada = date;
        }
      });
      formatarData(dataSelecionada);
      recuperarHorarioTroca();
    });
  }

  exibirTimePicker() async {
    TimeOfDay? novoHorario = await showTimePicker(
      context: context,
      initialTime: horarioTimePicker!,
      helpText: Textos.descricaoTimePickerHorarioInicial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.white,
              onPrimary: PaletaCores.corCastanho,
              surface: PaletaCores.corAzulEscuro,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (novoHorario != null) {
      setState(() {
        horarioTimePicker = novoHorario;
        sobreescreverHorarioTroca();
      });
    }
  }

  sobreescreverHorarioTroca() {
    formatarHorario(horarioTimePicker.toString());
    horarioTroca = "";
    horarioTroca =
        "${Textos.msgComecoHorarioEscala}${horarioTimePicker.toString().replaceAll("TimeOfDay(", "").replaceAll(")", "")}";
  }

  formatarHorario(String horarioTrocaRecuperado) {
    String horarioSemCaracteres =
        horarioTrocaRecuperado.replaceAll(new RegExp(r'[^0-9]'), '');

    String hora = "";
    String minuto = "";
    if (horarioSemCaracteres.length == 4) {
      hora = horarioSemCaracteres.substring(0, 2);
      minuto = horarioSemCaracteres.substring(2);
    } else {
      hora = horarioSemCaracteres.substring(0, 1);
      minuto = horarioSemCaracteres.substring(1);
    }
    String horarioFinal = hora + ":" + minuto;
    DateTime conversaoHorarioPData =
        new DateFormat("HH:mm").parse(horarioFinal);

    setState(() {
      TimeOfDay conversaoDataPTimeOfDay =
          TimeOfDay.fromDateTime(conversaoHorarioPData);
      horarioTimePicker = conversaoDataPTimeOfDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;
    double alturaBarraStatus = MediaQuery.of(context).padding.top;
    double alturaAppBar = AppBar().preferredSize.height;
    Timer(Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    });
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
                      title: Text(Textos.tituloTelaAtualizarItem),
                      leading: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          var dados = {};
                          dados[Constantes.rotaArgumentoNomeEscala] =
                              widget.nomeTabela;
                          dados[Constantes.rotaArgumentoIDEscalaSelecionada] =
                              widget.idTabelaSelecionada;
                          Navigator.pushReplacementNamed(
                              arguments: dados,
                              context,
                              Constantes.rotaEscalaDetalhada);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                        ),
                      )),
                  body: Container(
                      color: Colors.white,
                      width: larguraTela,
                      height: alturaTela - alturaAppBar - alturaBarraStatus,
                      child: SingleChildScrollView(
                          child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 0),
                              width: larguraTela,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  if (exibirOpcoesData) {
                                    return Column(
                                      children: [
                                        WidgetOpcoesData(
                                          dataSelecionada:
                                              formatarData(dataSelecionada),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          width: larguraTela,
                                          child: Text(
                                              Textos.descricaoTabelaSelecionada +
                                                  widget.nomeTabela,
                                              textAlign: TextAlign.end),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 0),
                                          width: larguraTela,
                                          child: Text(
                                              Textos.descricaoTelaAtualizarItem,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                              textAlign: TextAlign.center),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            botoesAcoes(
                                                Textos.btnData,
                                                Constantes.iconeDataCulto,
                                                60,
                                                60),
                                            SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: FloatingActionButton(
                                                    elevation: 0,
                                                    heroTag: "mudar horario",
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: const RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color: PaletaCores
                                                                .corCastanho),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    onPressed: () async {
                                                      exibirTimePicker();
                                                    },
                                                    child: const Icon(
                                                      Icons
                                                          .access_time_filled_outlined,
                                                      color: PaletaCores
                                                          .corAzulEscuro,
                                                    ))),
                                            botoesAcoes(
                                                Textos.btnOpcoesData,
                                                Constantes.iconeOpcoesData,
                                                120,
                                                40)
                                          ],
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 20.0),
                                          width: larguraTela,
                                          child: Text(
                                              Textos.descricaoDataSelecionada +
                                                  formatarData(dataSelecionada),
                                              textAlign: TextAlign.center),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10.0),
                                          width: larguraTela,
                                          child: Text(horarioTroca,
                                              textAlign: TextAlign.center),
                                        ),
                                        Form(
                                          key: _formKeyFormulario,
                                          child: Wrap(
                                            children: [
                                              Visibility(
                                                  visible:
                                                      !exibirSoCamposCooperadora,
                                                  child: Wrap(
                                                    children: [
                                                      Visibility(
                                                        visible:
                                                            exibirOcultarCamposNaoUsados,
                                                        child: camposFormulario(
                                                            larguraTela,
                                                            ctPorta01,
                                                            Textos
                                                                .labelPorta01),
                                                      ),
                                                      camposFormulario(
                                                          larguraTela,
                                                          ctPrimeiroHoraPulpito,
                                                          Textos
                                                              .labelPrimeiroHoraPulpito),
                                                      Visibility(
                                                        visible:
                                                            exibirOcultarCamposNaoUsados,
                                                        child: camposFormulario(
                                                            larguraTela,
                                                            ctSegundoHoraPulpito,
                                                            Textos
                                                                .labelSegundoHoraPulpito),
                                                      )
                                                    ],
                                                  )),
                                              Visibility(
                                                  visible:
                                                      exibirSoCamposCooperadora,
                                                  child: Visibility(
                                                    visible:
                                                        exibirOcultarCamposNaoUsados,
                                                    child: camposFormulario(
                                                        larguraTela,
                                                        ctBanheiroFeminino,
                                                        Textos
                                                            .labelBanheiroFeminino),
                                                  )),
                                              camposFormulario(
                                                  larguraTela,
                                                  ctPrimeiroHoraEntrada,
                                                  Textos
                                                      .labelPrimeiroHoraEntrada),
                                              Visibility(
                                                visible:
                                                    exibirOcultarCamposNaoUsados,
                                                child: camposFormulario(
                                                    larguraTela,
                                                    ctSegundoHoraEntrada,
                                                    Textos
                                                        .labelSegundoHoraEntrada),
                                              ),
                                              Visibility(
                                                visible:
                                                    !exibirSoCamposCooperadora,
                                                child: camposFormulario(
                                                    larguraTela,
                                                    ctRecolherOferta,
                                                    Textos.labelRecolherOferta),
                                              ),
                                              camposFormulario(
                                                  larguraTela,
                                                  ctUniforme,
                                                  Textos.labelUniforme),
                                              Visibility(
                                                visible:
                                                    exibirSoCamposCooperadora,
                                                child: camposFormulario(
                                                    larguraTela,
                                                    ctMesaApoio,
                                                    Textos.labelMesaApoio),
                                              ),
                                              Visibility(
                                                visible:
                                                    exibirCampoServirSantaCeia,
                                                child: camposFormulario(
                                                    larguraTela,
                                                    ctServirSantaCeia,
                                                    Textos
                                                        .labelServirSantaCeia),
                                              ),
                                              camposFormulario(
                                                  larguraTela,
                                                  ctIrmaoReserva,
                                                  Textos.labelIrmaoReserva),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: Platform.isAndroid ||
                                                  Platform.isIOS
                                              ? larguraTela
                                              : larguraTela * 0.9,
                                          height: 100,
                                          child: Card(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                    width: 1,
                                                    color: PaletaCores
                                                        .corAzulMagenta),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            elevation: 1,
                                            child: Wrap(
                                              runAlignment:
                                                  WrapAlignment.center,
                                              alignment: WrapAlignment.center,
                                              children: [
                                                botoesSwitch(
                                                    Textos
                                                        .labelSwitchCooperadora,
                                                    exibirSoCamposCooperadora),
                                                botoesSwitch(
                                                    Textos
                                                        .labelSwitchServirSantaCeia,
                                                    exibirCampoServirSantaCeia),
                                                botoesSwitch(
                                                    Textos
                                                        .labelSwitchExibirCampos,
                                                    exibirOcultarCamposNaoUsados)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              )))),
                  bottomNavigationBar: Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      width: larguraTela,
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Visibility(
                                visible: !exibirOpcoesData,
                                child: botoesAcoes(Textos.btnAtualizar,
                                    Constantes.iconeAtualizar, 90, 60),
                              ),
                              Visibility(
                                visible: exibirOpcoesData,
                                child: botoesAcoes(Textos.btnSalvarOpcoesData,
                                    Constantes.iconeSalvarOpcoes, 150, 60),
                              ),
                              botoesAcoes(Textos.btnVerEscalaAtual,
                                  Constantes.iconeLista, 90, 60),
                            ],
                          ),
                          BarraNavegacao()
                        ],
                      )),
                );
              }
            },
          ),
        ));
  }
}
