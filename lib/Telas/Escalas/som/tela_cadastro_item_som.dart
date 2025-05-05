import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senturionscaleg/Uteis/constantes.dart';
import 'package:senturionscaleg/Uteis/estilo.dart';
import 'package:senturionscaleg/Uteis/metodos_auxiliares.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';
import 'package:senturionscaleg/Uteis/textos.dart';
import 'package:senturionscaleg/Widgets/barra_navegacao_widget.dart';
import 'package:senturionscaleg/Widgets/tela_carregamento.dart';
import 'package:senturionscaleg/Widgets/widget_opcoes_data.dart';

@immutable
class TelaCadastroItemSom extends StatefulWidget {
  TelaCadastroItemSom(
      {Key? key, required this.nomeTabela, required this.idTabelaSelecionada})
      : super(key: key);

  final String nomeTabela;
  final String idTabelaSelecionada;

  @override
  State<TelaCadastroItemSom> createState() => _TelaCadastroItemSomState();
}

class _TelaCadastroItemSomState extends State<TelaCadastroItemSom> {
  Estilo estilo = Estilo();
  bool exibirWidgetCarregamento = false;
  bool exibirTelaCarregamento = false;
  bool exibirOpcoesData = false;
  String opcaoDataComplemento = Textos.departamentoCultoLivre;
  DateTime dataSelecionada = DateTime.now();
  final _formKeyFormulario = GlobalKey<FormState>();
  TextEditingController ctMesaSom = TextEditingController(text: "");
  TextEditingController ctNotebook = TextEditingController(text: "");
  TextEditingController ctIrmaoReserva = TextEditingController(text: "");

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    MetodosAuxiliares.passarDepartamentoSelecionado("");
  }

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
              heroTag: nomeBotao,
              elevation: 0,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                  side: BorderSide(color: PaletaCores.corCastanho),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              onPressed: () async {
                //verificando o tipo do botao
                // para fazer acoes diferentes
                if (nomeBotao == Textos.btnSalvar) {
                  if (_formKeyFormulario.currentState!.validate()) {
                    adicionarItensBancoDados();
                  }
                } else if (nomeBotao == Textos.btnVerEscalaAtual) {
                  var dados = {};
                  dados[Constantes.rotaArgumentoNomeEscala] = widget.nomeTabela;
                  dados[Constantes.rotaArgumentoIDEscalaSelecionada] =
                      widget.idTabelaSelecionada;
                  Navigator.pushReplacementNamed(
                      context, Constantes.rotaEscalaDetalhadaSom,
                      arguments: dados);
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

  adicionarItensBancoDados() async {
    setState(() {
      exibirTelaCarregamento = true;
    });

    try {
      var db = FirebaseFirestore.instance;
      db
          .collection(Constantes.fireBaseColecaoEscala)
          .doc(widget.idTabelaSelecionada)
          .collection(Constantes.fireBaseDadosCadastrados)
          .doc()
          .set({
        Constantes.mesaSom: ctMesaSom.text,
        Constantes.notebook: ctNotebook.text,
        Constantes.dataCulto: formatarData(dataSelecionada),
        Constantes.irmaoReserva: ctIrmaoReserva.text,
      });
      MetodosAuxiliares.exibirMensagens(Textos.sucessoMsgAdicionarItemEscala,
          Textos.tipoNotificacaoSucesso, context);
      setState(() {
        limparValoresCampos();
        exibirTelaCarregamento = false;
      });
    } catch (e) {
      MetodosAuxiliares.exibirMensagens(Textos.erroMsgAdicionarItemEscala,
          Textos.tipoNotificacaoErro, context);
      setState(() {
        exibirTelaCarregamento = false;
      });
    }
  }

  // metodo para limpar valores dos
  // campos apos cadastrar item
  // na base de dados
  limparValoresCampos() {
    ctMesaSom.text = "";
    ctNotebook.text = "";
    ctIrmaoReserva.text = "";
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
                      title: Text(Textos.tituloTelaCadastro),
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
                                              Textos.descricaoTelaCadastro,
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
                                            botoesAcoes(
                                                Textos.btnOpcoesData,
                                                Constantes.iconeOpcoesData,
                                                120,
                                                40),
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
                                child: botoesAcoes(Textos.btnSalvar,
                                    Constantes.iconeSalvar, 90, 60),
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
