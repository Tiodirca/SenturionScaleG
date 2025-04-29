import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senturionscaleg/Modelo/escala_sonoplastas.dart';
import 'package:senturionscaleg/Uteis/PDF/gerar_pdf_escala_som.dart';
import 'package:senturionscaleg/Uteis/constantes.dart';
import 'package:senturionscaleg/Uteis/estilo.dart';
import 'package:senturionscaleg/Uteis/metodos_auxiliares.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';
import 'package:senturionscaleg/Uteis/textos.dart';
import 'package:senturionscaleg/Widgets/barra_navegacao_widget.dart';
import 'package:senturionscaleg/Widgets/tela_carregamento.dart';

class TelaEscalaDetalhadaSom extends StatefulWidget {
  const TelaEscalaDetalhadaSom(
      {super.key, required this.nomeTabela, required this.idTabelaSelecionada});

  final String nomeTabela;
  final String idTabelaSelecionada;

  @override
  State<TelaEscalaDetalhadaSom> createState() => _TelaEscalaDetalhadaSomState();
}

class _TelaEscalaDetalhadaSomState extends State<TelaEscalaDetalhadaSom> {
  Estilo estilo = Estilo();
  late List<EscalaSonoplatasModelo> escala;
  late List<EscalaSonoplatasModelo> escalaAuxiliarOriginal;
  bool exibirWidgetCarregamento = true;
  bool exibirOcultarBtnAcao = true;
  TextEditingController ctPesquisa = TextEditingController(text: "");
  bool exibirOcultarIrmaoReserva = true;

  @override
  void initState() {
    super.initState();
    escala = [];
    realizarBuscaDadosFireBase(widget.idTabelaSelecionada);
  }

  realizarBuscaDadosFireBase(String idDocumento) async {
    var db = FirebaseFirestore.instance;
    //instanciano variavel
    db
        .collection(Constantes.fireBaseColecaoEscala)
        .doc(idDocumento)
        .collection(Constantes.fireBaseDadosCadastrados)
        .get()
        .then(
      (querySnapshot) async {
        // for para percorrer todos os dados que a variavel recebeu
        if (querySnapshot.docs.isNotEmpty) {
          for (var documentoFirebase in querySnapshot.docs) {
            // chamando metodo para converter json
            // recebido do firebase para objeto
            converterJsonParaObjeto(idDocumento, documentoFirebase.id);
          }
        } else {
          setState(() {
            exibirOcultarBtnAcao = false;
            exibirWidgetCarregamento = false;
          });
        }
        print("fdsfsdf");
      },
    );
  }

  converterJsonParaObjeto(String idDocumento, String id) async {
    // instanciando variavel
    var db = FirebaseFirestore.instance;
    //fazendo busca no banco de dados
    final ref = db
        .collection(Constantes.fireBaseColecaoEscala)
        .doc(idDocumento)
        .collection(Constantes.fireBaseDadosCadastrados)
        .doc(id)
        // chamando conversao
        .withConverter(
          fromFirestore: EscalaSonoplatasModelo.fromFirestore,
          toFirestore: (EscalaSonoplatasModelo escalaModelo, _) =>
              escalaModelo.toFirestore(),
        );

    final docSnap = await ref.get();
    final dados = docSnap.data(); // convertendo
    if (dados != null) {
      dados.id = docSnap.id;
      //adicionando os dados convertidos na lista
      escala.add(dados);
      setState(() {
        ordenarLista();
        escalaAuxiliarOriginal = escala;
        exibirWidgetCarregamento = false;
      });
    }
  }

  ordenarLista() {
    // ordenando a lista pela data colocando
    // a data mais antiga no topo da listagem
    escala.sort((a, b) => DateFormat("dd/MM/yyyy EEEE", "pt_BR")
        .parse(a.dataCulto)
        .compareTo(DateFormat("dd/MM/yyyy EEEE", "pt_BR").parse(b.dataCulto)));
  }

  // Metodo para chamar deletar tabela
  chamarDeletar(EscalaSonoplatasModelo escalaModelo) async {
    var db = FirebaseFirestore.instance;
    await db
        .collection(Constantes.fireBaseColecaoEscala)
        .doc(widget.idTabelaSelecionada)
        .collection(Constantes.fireBaseDadosCadastrados)
        .doc(escalaModelo.id)
        .delete()
        .then(
      (doc) {
        setState(() {
          escala.clear();
          realizarBuscaDadosFireBase(widget.idTabelaSelecionada);
        });
        MetodosAuxiliares.exibirMensagens(
            Textos.sucessoExcluirItem, Textos.tipoNotificacaoSucesso, context);
      },
      onError: (e) => MetodosAuxiliares.exibirMensagens(
          Textos.erroMsgExcluirItemEscala, Textos.tipoNotificacaoErro, context),
    );
  }

  Widget botoesAcoes(
          String nomeBotao, IconData icone, double largura, double altura) =>
      Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          height: altura,
          width: largura,
          child: FloatingActionButton(
              elevation: 0,
              heroTag: nomeBotao,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                  side: BorderSide(color: PaletaCores.corCastanho),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              onPressed: () async {
                if (nomeBotao == Textos.btnBaixar) {
                  GerarPdfEscalaSom gerarPDF = GerarPdfEscalaSom(
                    escala: escala,
                    exibirIrmaoReserva: exibirOcultarIrmaoReserva,
                    nomeEscala: widget.nomeTabela,
                  );
                  gerarPDF.pegarDados();
                } else if (nomeBotao == Textos.btnAdicionar) {
                  var dados = {};
                  dados[Constantes.rotaArgumentoNomeEscala] = widget.nomeTabela;
                  dados[Constantes.rotaArgumentoIDEscalaSelecionada] =
                      widget.idTabelaSelecionada;
                  Navigator.pushReplacementNamed(
                      context, Constantes.rotaCadastroItemEscalaSom,
                      arguments: dados);
                } else if (nomeBotao == Textos.btnRecarregar) {
                  setState(() {
                    exibirWidgetCarregamento = true;
                    realizarBuscaDadosFireBase(widget.idTabelaSelecionada);
                  });
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icone, color: PaletaCores.corAzulMagenta, size: 30),
                  Text(
                    nomeBotao,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: PaletaCores.corAzulMagenta),
                  )
                ],
              )));

  Future<void> alertaExclusao(
      EscalaSonoplatasModelo escala, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            Textos.tituloAlertaExclusao,
            style: const TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Textos.descricaoAlerta,
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  children: [
                    Text(
                      escala.dataCulto,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Não',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Sim',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                setState(() {
                  exibirWidgetCarregamento = true;
                });
                chamarDeletar(escala);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
    print(label);
    if (label == Textos.labelIrmaoReserva) {
      setState(() {
        exibirOcultarIrmaoReserva = !exibirOcultarIrmaoReserva;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;

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
                      title: Text(Textos.tituloTelaEscalaDetalhada),
                      leading: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, Constantes.rotaListarEscalas);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                        ),
                      )),
                  body: LayoutBuilder(
                    builder: (context, constraints) {
                      if (escala.isEmpty) {
                        return Container(
                          color: Colors.white,
                          width: larguraTela,
                          height: alturaTela,
                          child: Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 20),
                                width: larguraTela * 0.5,
                                height: 200,
                                child: Text(
                                    Textos.descricaoErroConsultasBancoDados,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    botoesAcoes(Textos.btnRecarregar,
                                        Constantes.iconeRecarregar, 100, 60),
                                    botoesAcoes(Textos.btnAdicionar,
                                        Constantes.iconeAdicionar, 100, 60)
                                  ]),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                            color: Colors.white,
                            width: larguraTela,
                            height: alturaTela,
                            child: SingleChildScrollView(
                              child: Column(
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
                                        Textos.descricaoTelaListagemItens,
                                        style: const TextStyle(fontSize: 18),
                                        textAlign: TextAlign.center),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 0.0),
                                      height: Platform.isWindows
                                          ? alturaTela * 0.5
                                          : alturaTela * 0.5,
                                      width: Platform.isWindows
                                          ? larguraTela * 0.5
                                          : larguraTela,
                                      child: Card(
                                        color: Colors.white,
                                        shape: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                width: 1,
                                                color:
                                                    PaletaCores.corCastanho)),
                                        child: Center(
                                          child: ListView(
                                            children: [
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: DataTable(
                                                  columnSpacing: 10,
                                                  columns: [
                                                    DataColumn(
                                                        label: Text(
                                                            Textos.labelData,
                                                            textAlign: TextAlign
                                                                .center)),
                                                    DataColumn(
                                                        label: Text(
                                                            Textos
                                                                .labelSomNotebook,
                                                            textAlign: TextAlign
                                                                .center)),
                                                    DataColumn(
                                                        label: Text(
                                                            Textos.labelSomMesa,
                                                            textAlign: TextAlign
                                                                .center)),
                                                    DataColumn(
                                                        label: Visibility(
                                                            visible:
                                                                exibirOcultarIrmaoReserva,
                                                            child: Text(
                                                                Textos
                                                                    .labelIrmaoReserva,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center))),
                                                    DataColumn(
                                                      label: Text(
                                                          Textos.labelEditar,
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                          Textos.labelExcluir,
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                  ],
                                                  rows: escala
                                                      .map(
                                                        (item) =>
                                                            DataRow(cells: [
                                                          DataCell(SizedBox(
                                                              width: 90,
                                                              //SET width
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Text(
                                                                    item
                                                                        .dataCulto,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ))),
                                                          DataCell(
                                                            SizedBox(
                                                                width: 90,
                                                                //SET width
                                                                child: Text(
                                                                    item
                                                                        .notebook,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center)),
                                                          ),
                                                          DataCell(
                                                            SizedBox(
                                                                width: 90,
                                                                //SET width
                                                                child: Text(
                                                                    item
                                                                        .mesaSom,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center)),
                                                          ),
                                                          DataCell(Visibility(
                                                            visible:
                                                                exibirOcultarIrmaoReserva,
                                                            child: SizedBox(
                                                                width: 90,
                                                                //SET width
                                                                child: Text(
                                                                    item
                                                                        .irmaoReserva,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center)),
                                                          )),
                                                          DataCell(Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            child:
                                                                FloatingActionButton(
                                                              heroTag: item.id
                                                                  .toString(),
                                                              elevation: 0,
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
                                                              onPressed: () {
                                                                var dados = {};
                                                                dados[Constantes
                                                                        .rotaArgumentoNomeEscala] =
                                                                    widget
                                                                        .nomeTabela;
                                                                dados[Constantes
                                                                        .rotaArgumentoIDEscalaSelecionada] =
                                                                    widget
                                                                        .idTabelaSelecionada;
                                                                dados[Constantes
                                                                        .escalaModelo] =
                                                                    item;
                                                                Navigator.pushReplacementNamed(
                                                                    context,
                                                                    Constantes
                                                                        .rotaAtualizarItemEscalaSom,
                                                                    arguments:
                                                                        dados);
                                                              },
                                                              child: const Icon(
                                                                  Icons
                                                                      .edit_outlined,
                                                                  size: 20,
                                                                  color: PaletaCores
                                                                      .corAzulMagenta),
                                                            ),
                                                          )),
                                                          DataCell(Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            child:
                                                                FloatingActionButton(
                                                              heroTag:
                                                                  "Excluir${item.id.toString()}",
                                                              elevation: 0,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              shape: const RoundedRectangleBorder(
                                                                  side: BorderSide(
                                                                      color: PaletaCores
                                                                          .corRosaAvermelhado),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10))),
                                                              onPressed: () {
                                                                alertaExclusao(
                                                                    item,
                                                                    context);
                                                              },
                                                              child: const Icon(
                                                                  Icons
                                                                      .close_outlined,
                                                                  size: 20,
                                                                  color: PaletaCores
                                                                      .corAzulMagenta),
                                                            ),
                                                          )),
                                                        ]),
                                                      )
                                                      .toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ));
                      }
                    },
                  ),
                  bottomNavigationBar: Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      width: larguraTela,
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: exibirOcultarBtnAcao,
                            child: Container(
                              margin: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  botoesAcoes(Textos.btnBaixar,
                                      Constantes.iconeBaixar, 100, 60),
                                  botoesSwitch(Textos.labelIrmaoReserva,
                                      exibirOcultarIrmaoReserva),
                                  botoesAcoes(Textos.btnAdicionar,
                                      Constantes.iconeAdicionar, 80, 60),
                                ],
                              ),
                            ),
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
