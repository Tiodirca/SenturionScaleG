import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senturionscaleg/Modelo/escala_sonoplastas.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';
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
  String complementoDataDepartamento = Textos.departamentoCultoLivre;
  int valorRadioButton = 0;
  String horarioTroca = "";

  late DateTime dataSelecionada = DateTime.now();
  final _formKeyFormulario = GlobalKey<FormState>();
  TextEditingController ctMesaSom = TextEditingController(text: "");
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
                  alertaSelecaoOpcaoData(context);
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
    recuperarHorarioTroca();
    preencherCampos(widget.escalaModelo);
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
    ctIrmaoReserva.text = element.irmaoReserva;
    valorRadioButton = MetodosAuxiliares.recuperarValorRadioButtonComplementoData(element.dataCulto);
    complementoDataDepartamento = MetodosAuxiliares.mudarRadioButton(valorRadioButton);
    dataSelecionada =
        DateFormat("dd/MM/yyyy EEEE", "pt_BR").parse(element.dataCulto);
    formatarData(dataSelecionada);
    MetodosAuxiliares.mudarRadioButton(valorRadioButton);
    setState(() {
      exibirWidgetCarregamento = false;
    });
  }

  Widget radioButtonComplementoData(int valor, String nomeBtn) => SizedBox(
        width: 250,
        height: 60,
        child: Row(
          children: [
            Radio(
              value: valor,
              groupValue: valorRadioButton,
              onChanged: (value) {
                setState(() {
                  valorRadioButton = valor;
                  complementoDataDepartamento = MetodosAuxiliares.mudarRadioButton(valor);
                });
                Navigator.of(context).pop();
              },
            ),
            Text(nomeBtn)
          ],
        ),
      );

  Future<void> alertaSelecaoOpcaoData(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            Textos.alertaOpcoesData,
            style: const TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                radioButtonComplementoData(0, Textos.departamentoCultoLivre),
                radioButtonComplementoData(1, Textos.departamentoMissao),
                radioButtonComplementoData(2, Textos.departamentoCirculoOracao),
                radioButtonComplementoData(3, Textos.departamentoJovens),
                radioButtonComplementoData(4, Textos.departamentoAdolecentes),
                radioButtonComplementoData(5, Textos.departamentoInfantil),
                radioButtonComplementoData(6, Textos.departamentoVaroes),
                radioButtonComplementoData(7, Textos.departamentoCampanha),
                radioButtonComplementoData(8, Textos.departamentoEbom),
                radioButtonComplementoData(9, Textos.departamentoSede),
                radioButtonComplementoData(10, Textos.departamentoFamilia),
                radioButtonComplementoData(11, Textos.departamentoDeboras),
                radioButtonComplementoData(12, Textos.departamentoConferencia),
                radioButtonComplementoData(13, Textos.departamentoManha),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
  }

  // metodo para formatar a data e exibir
  // ela nos moldes exigidos
  formatarData(DateTime data) {
    String dataFormatada = DateFormat("dd/MM/yyyy EEEE", "pt_BR").format(data);
    if (complementoDataDepartamento.isNotEmpty &&
        complementoDataDepartamento != Textos.departamentoCultoLivre) {
      return "$dataFormatada ( $complementoDataDepartamento )";
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

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;
    double alturaBarraStatus = MediaQuery.of(context).padding.top;
    double alturaAppBar = AppBar().preferredSize.height;

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
                        child: Column(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
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
                              child: Text(Textos.descricaoTelaAtualizarItem,
                                  style: const TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                botoesAcoes(Textos.btnData,
                                    Constantes.iconeDataCulto, 60, 60),
                                botoesAcoes(Textos.btnOpcoesData,
                                    Constantes.iconeOpcoesData, 120, 40)
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
                            SizedBox(
                              width: larguraTela,
                              child: Text(horarioTroca,
                                  textAlign: TextAlign.center),
                            ),
                            Form(
                              key: _formKeyFormulario,
                              child: Wrap(
                                children: [
                                  camposFormulario(larguraTela, ctNotebook,
                                      Textos.labelSomNotebook),
                                  camposFormulario(larguraTela, ctMesaSom,
                                      Textos.labelSomMesa),
                                  camposFormulario(larguraTela, ctIrmaoReserva,
                                      Textos.labelIrmaoReserva),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))),
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
                              botoesAcoes(Textos.btnAtualizar,
                                  Constantes.iconeAtualizar, 90, 60),
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
