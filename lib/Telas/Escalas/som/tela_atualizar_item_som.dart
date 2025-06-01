import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:senturionscaleg/Modelo/escala_sonoplastas.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';
import 'package:senturionscaleg/Widgets/widget_opcoes_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Uteis/constantes.dart';
import '../../../Uteis/estilo.dart';
import '../../../Uteis/metodos_auxiliares.dart';
import '../../../Uteis/textos.dart';
import '../../../Widgets/barra_navegacao_widget.dart';
import '../../../Widgets/tela_carregamento.dart';

class TelaAtualizarItemSom extends StatefulWidget {
  TelaAtualizarItemSom(
      {Key? key,
      required this.nomeTabela,
      required this.idTabelaSelecionada,
      required this.escalaModelo})
      : super(key: key);

  final String nomeTabela;
  final String idTabelaSelecionada;
  final EscalaSonoplatasModelo escalaModelo;

  @override
  State<TelaAtualizarItemSom> createState() => _TelaAtualizarItemSomState();
}

class _TelaAtualizarItemSomState extends State<TelaAtualizarItemSom> {
  Estilo estilo = Estilo();
  bool exibirWidgetCarregamento = true;
  bool exibirOpcoesData = false;
  String horarioTroca = "";
  TimeOfDay? horarioTimePicker = const TimeOfDay(hour: 19, minute: 00);
  String opcaoDataComplemento = Textos.departamentoCultoLivre;
  late DateTime dataSelecionada = DateTime.now();
  final _formKeyFormulario = GlobalKey<FormState>();
  TextEditingController ctMesaSom = TextEditingController(text: "");
  TextEditingController ctVideos = TextEditingController(text: "");
  TextEditingController ctNotebook = TextEditingController(text: "");
  TextEditingController ctIrmaoReserva = TextEditingController(text: "");

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

  @override
  void initState() {
    super.initState();
    exibirWidgetCarregamento = false;
    preencherCampos(widget.escalaModelo);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    MetodosAuxiliares.passarDepartamentoSelecionado("");
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

  redirecionarTela() {
    var dados = {};
    dados[Constantes.rotaArgumentoNomeEscala] = widget.nomeTabela;
    dados[Constantes.rotaArgumentoIDEscalaSelecionada] =
        widget.idTabelaSelecionada;
    Navigator.pushReplacementNamed(context, Constantes.rotaEscalaDetalhadaSom,
        arguments: dados);
  }

  preencherCampos(EscalaSonoplatasModelo element) {
    ctNotebook.text = element.notebook;
    ctMesaSom.text = element.mesaSom;
    ctVideos.text = element.videos;
    ctIrmaoReserva.text = element.irmaoReserva;
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

    if (element.dataCulto.contains(Textos.departamentoEbom) ||
        element.dataCulto.contains(Textos.departamentoSede)) {
    } else {
      formatarHorario(element.horarioTroca);
      sobreescreverHorarioTroca();
    }
    sobreescreverHorarioTroca();
    setState(() {
      exibirWidgetCarregamento = false;
    });
  }

  chamarAtualizarItensBancoDados() async {
    setState(() {
      exibirWidgetCarregamento = true;
    });

    try {
      var db = FirebaseFirestore.instance;
      db
          .collection(Constantes.fireBaseColecaoEscala)
          .doc(widget.idTabelaSelecionada)
          .collection(Constantes.fireBaseDadosCadastrados)
          .doc(widget.escalaModelo.id)
          .set({
        Constantes.notebook: ctNotebook.text,
        Constantes.mesaSom: ctMesaSom.text,
        Constantes.horarioTroca:
        opcaoDataComplemento.contains(Textos.departamentoEbom)  ||
            opcaoDataComplemento.contains(Textos.departamentoSede)
            ? "--"
            : horarioTroca,
        Constantes.videos: ctVideos.text,
        Constantes.dataCulto: formatarData(dataSelecionada),
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

  // metodo para formatar a data e exibir
  // ela nos moldes exigidos
  formatarData(DateTime data) {
    String dataFormatada = DateFormat("dd/MM/yyyy EEEE", "pt_BR").format(data);
    if (opcaoDataComplemento.isNotEmpty &&
        opcaoDataComplemento != Textos.departamentoCultoLivre) {
      return "$dataFormatada ( $opcaoDataComplemento )";
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
                              Constantes.rotaEscalaDetalhadaSom);
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
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 20.0, horizontal: 0),
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
                                              camposFormulario(
                                                  larguraTela,
                                                  ctNotebook,
                                                  Textos.labelSomNotebook),
                                              camposFormulario(
                                                  larguraTela,
                                                  ctMesaSom,
                                                  Textos.labelSomMesa),
                                              camposFormulario(larguraTela,
                                                  ctVideos, Textos.labelVideos),
                                              camposFormulario(
                                                  larguraTela,
                                                  ctIrmaoReserva,
                                                  Textos.labelIrmaoReserva),
                                            ],
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
