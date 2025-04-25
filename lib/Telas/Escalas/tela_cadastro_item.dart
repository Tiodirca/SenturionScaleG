import 'dart:io';
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
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class TelaCadastroItem extends StatefulWidget {
  TelaCadastroItem(
      {Key? key, required this.nomeTabela, required this.idTabelaSelecionada})
      : super(key: key);

  final String nomeTabela;
  final String idTabelaSelecionada;

  @override
  State<TelaCadastroItem> createState() => _TelaCadastroItemState();
}

class _TelaCadastroItemState extends State<TelaCadastroItem> {
  Estilo estilo = Estilo();
  bool exibirOcultarCamposNaoUsados = false;
  bool exibirTelaCarregamento = false;
  bool exibirCampoServirSantaCeia = false;
  bool exibirSoCamposCooperadora = false;
  bool exbirCampoIrmaoReserva = false;
  String horarioTroca = "";
  bool exibirWidgetCarregamento = false;
  String complementoDataDepartamento = Textos.departamentoCultoLivre;
  int valorRadioButton = 0;
  DateTime dataSelecionada = DateTime.now();
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
                      context, Constantes.rotaEscalaDetalhada,
                      arguments: dados);
                } else if (nomeBotao == Textos.btnOpcoesData) {
                  alertaSelecaoOpcaoData(context);
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
    recuperarHorarioTroca();
  }

  adicionarItensBancoDados() async {
    setState(() {
      exibirTelaCarregamento = true;
    });

    String primeiroHoraPulpito = "";
    String segundoHoraPulpito = "";
    String mesaApoio = "";
    String servirSantaCeia = "";
    String irmaoReserva = "";
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

    if (exbirCampoIrmaoReserva) {
      irmaoReserva = ctIrmaoReserva.text;
    } else {
      irmaoReserva = "";
    }
    try {
      var db = FirebaseFirestore.instance;
      db
          .collection(Constantes.fireBaseColecaoEscala)
          .doc(widget.idTabelaSelecionada)
          .collection(Constantes.fireBaseDadosCadastrados)
          .doc()
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
            complementoDataDepartamento == Textos.departamentoEbom
                ? Textos.departamentoEbom
                : horarioTroca,
        Constantes.irmaoReserva: irmaoReserva,
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

  // metodo para limpar valores dos
  // campos apos cadastrar item
  // na base de dados
  limparValoresCampos() {
    ctPrimeiroHoraPulpito.text = "";
    ctSegundoHoraPulpito.text = "";
    ctPrimeiroHoraEntrada.text = "";
    ctSegundoHoraEntrada.text = "";
    ctRecolherOferta.text = "";
    ctUniforme.text = "";
    ctMesaApoio.text = "";
    ctServirSantaCeia.text = "";
    ctIrmaoReserva.text = "";
  }

  // metodo para formatar a data e exibir
  // ela nos moldes exigidos
  formatarData(DateTime data) {
    String dataFormatada = DateFormat("dd/MM/yyyy EEEE", "pt_BR").format(data);
    if (exibirCampoServirSantaCeia) {
      return dataFormatada = "$dataFormatada ( Santa Ceia )";
    } else if (complementoDataDepartamento.isNotEmpty &&
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
            dialogBackgroundColor: Colors.white,
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

  Widget radioButtonComplementoData(int valor, String nomeBtn) => SizedBox(
        width: 250,
        height: 60,
        child: Row(
          children: [
            Radio(
              value: valor,
              groupValue: valorRadioButton,
              onChanged: (value) {
                mudarRadioButton(valor);
                Navigator.of(context).pop();
              },
            ),
            Text(nomeBtn)
          ],
        ),
      );

  mudarRadioButton(int value) {
    //metodo para mudar o estado do radio button
    setState(() {
      valorRadioButton = value;
      switch (valorRadioButton) {
        case 0:
          setState(() {
            complementoDataDepartamento = Textos.departamentoCultoLivre;
          });
          break;
        case 1:
          setState(() {
            complementoDataDepartamento = Textos.departamentoMissao;
          });
          break;
        case 2:
          setState(() {
            complementoDataDepartamento = Textos.departamentoCirculoOracao;
          });
          break;
        case 3:
          setState(() {
            complementoDataDepartamento = Textos.departamentoJovens;
          });
          break;
        case 4:
          setState(() {
            complementoDataDepartamento = Textos.departamentoAdolecentes;
          });
          break;
        case 5:
          setState(() {
            complementoDataDepartamento = Textos.departamentoInfantil;
          });
          break;
        case 6:
          setState(() {
            complementoDataDepartamento = Textos.departamentoVaroes;
          });
          break;
        case 7:
          setState(() {
            complementoDataDepartamento = Textos.departamentoCampanha;
          });
          break;
        case 8:
          setState(() {
            complementoDataDepartamento = Textos.departamentoEbom;
          });
          break;
        case 9:
          setState(() {
            complementoDataDepartamento = Textos.departamentoSede;
          });
          break;
        case 10:
          setState(() {
            complementoDataDepartamento = Textos.departamentoFamilia;
          });
          break;
      }
    });
  }

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
                Text(
                  Textos.descricaoalertaOpcoesData,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
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
                              child: Text(Textos.descricaoTelaCadastro,
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
                                  Visibility(
                                      visible: !exibirSoCamposCooperadora,
                                      child: Wrap(
                                        children: [
                                          Visibility(
                                            visible:
                                                exibirOcultarCamposNaoUsados,
                                            child: camposFormulario(larguraTela,
                                                ctPorta01, Textos.labelPorta01),
                                          ),
                                          camposFormulario(
                                              larguraTela,
                                              ctPrimeiroHoraPulpito,
                                              Textos.labelPrimeiroHoraPulpito),
                                          Visibility(
                                            visible:
                                                exibirOcultarCamposNaoUsados,
                                            child: camposFormulario(
                                                larguraTela,
                                                ctSegundoHoraPulpito,
                                                Textos.labelSegundoHoraPulpito),
                                          )
                                        ],
                                      )),
                                  Visibility(
                                      visible: exibirSoCamposCooperadora,
                                      child: Visibility(
                                        visible: exibirOcultarCamposNaoUsados,
                                        child: camposFormulario(
                                            larguraTela,
                                            ctBanheiroFeminino,
                                            Textos.labelBanheiroFeminino),
                                      )),
                                  camposFormulario(
                                      larguraTela,
                                      ctPrimeiroHoraEntrada,
                                      Textos.labelPrimeiroHoraEntrada),
                                  Visibility(
                                    visible: exibirOcultarCamposNaoUsados,
                                    child: camposFormulario(
                                        larguraTela,
                                        ctSegundoHoraEntrada,
                                        Textos.labelSegundoHoraEntrada),
                                  ),
                                  Visibility(
                                    visible: !exibirSoCamposCooperadora,
                                    child: camposFormulario(
                                        larguraTela,
                                        ctRecolherOferta,
                                        Textos.labelRecolherOferta),
                                  ),
                                  camposFormulario(larguraTela, ctUniforme,
                                      Textos.labelUniforme),
                                  Visibility(
                                    visible: exibirSoCamposCooperadora,
                                    child: camposFormulario(larguraTela,
                                        ctMesaApoio, Textos.labelMesaApoio),
                                  ),
                                  Visibility(
                                    visible: exibirCampoServirSantaCeia,
                                    child: camposFormulario(
                                        larguraTela,
                                        ctServirSantaCeia,
                                        Textos.labelServirSantaCeia),
                                  ),
                                  camposFormulario(larguraTela, ctIrmaoReserva,
                                      Textos.labelIrmaoReserva),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: Platform.isAndroid || Platform.isIOS
                                  ? larguraTela
                                  : larguraTela * 0.9,
                              height: 100,
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 1,
                                        color: PaletaCores.corAzulMagenta),
                                    borderRadius: BorderRadius.circular(20)),
                                elevation: 1,
                                child: Wrap(
                                  runAlignment: WrapAlignment.center,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    botoesSwitch(Textos.labelSwitchCooperadora,
                                        exibirSoCamposCooperadora),
                                    botoesSwitch(
                                        Textos.labelSwitchServirSantaCeia,
                                        exibirCampoServirSantaCeia),
                                    botoesSwitch(Textos.labelSwitchExibirCampos,
                                        exibirOcultarCamposNaoUsados)
                                  ],
                                ),
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
                              botoesAcoes(Textos.btnSalvar,
                                  Constantes.iconeSalvar, 90, 60),
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
