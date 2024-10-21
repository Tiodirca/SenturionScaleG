import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senturionscaleg/Modelo/escala_modelo.dart';
import 'package:senturionscaleg/Uteis/PDF/GerarPDF.dart';
import 'package:senturionscaleg/Uteis/constantes.dart';
import 'package:senturionscaleg/Uteis/estilo.dart';
import 'package:senturionscaleg/Uteis/metodos_auxiliares.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';
import 'package:senturionscaleg/Uteis/textos.dart';
import 'package:senturionscaleg/Widgets/barra_navegacao_widget.dart';
import 'package:senturionscaleg/Widgets/tela_carregamento.dart';

class TelaEscalaDetalhada extends StatefulWidget {
  const TelaEscalaDetalhada(
      {super.key, required this.nomeTabela, required this.idTabelaSelecionada});

  final String nomeTabela;
  final String idTabelaSelecionada;

  @override
  State<TelaEscalaDetalhada> createState() => _TelaEscalaDetalhadaState();
}

class _TelaEscalaDetalhadaState extends State<TelaEscalaDetalhada> {
  Estilo estilo = Estilo();
  bool exibirOcultarCampoRecolherOferta = false;
  bool exibirOcultarCampoIrmaoReserva = false;
  bool exibirOcultarCampoMesaApoio = false;
  bool exibirOcultarServirSantaCeia = false;
  late List<EscalaModelo> escala;
  bool exibirWidgetCarregamento = true;
  bool exibirOcultarBtnAcao = true;

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
          fromFirestore: EscalaModelo.fromFirestore,
          toFirestore: (EscalaModelo escalaModelo, _) =>
              escalaModelo.toFirestore(),
        );

    final docSnap = await ref.get();
    final dados = docSnap.data(); // convertendo
    if (dados != null) {
      dados.id = docSnap.id;
      //print(dados.id);
      //adicionando os dados convertidos na lista
      escala.add(dados);
      setState(() {
        ordenarLista();
        exibirWidgetCarregamento = false;
        chamarVerificarColunaVazia();
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

  // metodo para chamar metodo para verificar
  // se a coluna esta vazia
  chamarVerificarColunaVazia() {
    for (var element in escala) {
      if (element.mesaApoio.isNotEmpty) {
        exibirOcultarCampoMesaApoio = true;
        break;
      } else {
        exibirOcultarCampoMesaApoio = false;
      }
    }
    for (var element in escala) {
      if (element.irmaoReserva.isNotEmpty) {
        exibirOcultarCampoIrmaoReserva = true;
        break;
      } else {
        exibirOcultarCampoIrmaoReserva = false;
      }
    }
    for (var element in escala) {
      if (element.recolherOferta.isNotEmpty) {
        exibirOcultarCampoRecolherOferta = true;
        break;
      } else {
        exibirOcultarCampoRecolherOferta = false;
      }
    }
    for (var element in escala) {
      if (element.servirSantaCeia.isNotEmpty) {
        exibirOcultarServirSantaCeia = true;
        break;
      } else {
        exibirOcultarServirSantaCeia = false;
      }
    }
  }

  // Metodo para chamar deletar tabela
  chamarDeletar(EscalaModelo escalaModelo) async {
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

  // metodo para chamar a geracao do arquivo em pdf
  // e permitir o usuario baixar o arquivo
  chamarGerarArquivoPDF() {
    GerarPDF gerarPDF = GerarPDF(
        escala: escala,
        nomeEscala: widget.nomeTabela,
        exibirMesaApoio: exibirOcultarCampoMesaApoio,
        exibirRecolherOferta: exibirOcultarCampoRecolherOferta,
        exibirIrmaoReserva: exibirOcultarCampoIrmaoReserva,
        exibirServirSantaCeia: exibirOcultarServirSantaCeia);
    gerarPDF.pegarDados();
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
                  chamarGerarArquivoPDF();
                } else if (nomeBotao == Textos.btnAdicionar) {
                  var dados = {};
                  dados[Constantes.rotaArgumentoNomeEscala] = widget.nomeTabela;
                  dados[Constantes.rotaArgumentoIDEscalaSelecionada] =
                      widget.idTabelaSelecionada;
                  Navigator.pushReplacementNamed(
                      context, Constantes.rotaCadastroItemEscala,
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

  Future<void> alertaExclusao(EscalaModelo escala, BuildContext context) async {
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
                                          ? alturaTela * 0.6
                                          : alturaTela * 0.5,
                                      width: larguraTela,
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
                                                              .labelHorarioTroca,
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    DataColumn(
                                                        label: Visibility(
                                                      visible:
                                                          !exibirOcultarCampoMesaApoio,
                                                      child: Text(
                                                          Textos
                                                              .labelPrimeiroHoraPulpito,
                                                          textAlign:
                                                              TextAlign.center),
                                                    )),
                                                    DataColumn(
                                                        label: Visibility(
                                                      visible:
                                                          !exibirOcultarCampoMesaApoio,
                                                      child: Text(
                                                          Textos
                                                              .labelSegundoHoraPulpito,
                                                          textAlign:
                                                              TextAlign.center),
                                                    )),
                                                    DataColumn(
                                                        label: Text(
                                                            Textos
                                                                .labelPrimeiroHoraEntrada,
                                                            textAlign: TextAlign
                                                                .center)),
                                                    DataColumn(
                                                      label: Text(
                                                          Textos
                                                              .labelSegundoHoraEntrada,
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    DataColumn(
                                                        label: Visibility(
                                                      visible:
                                                          exibirOcultarCampoMesaApoio,
                                                      child: Text(
                                                          Textos.labelMesaApoio,
                                                          textAlign:
                                                              TextAlign.center),
                                                    )),
                                                    DataColumn(
                                                      label: Text(
                                                          Textos.labelUniforme,
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    DataColumn(
                                                        label: Visibility(
                                                      visible:
                                                          exibirOcultarCampoRecolherOferta,
                                                      child: Text(
                                                          Textos
                                                              .labelRecolherOferta,
                                                          textAlign:
                                                              TextAlign.center),
                                                    )),
                                                    DataColumn(
                                                        label: Visibility(
                                                      visible:
                                                          exibirOcultarServirSantaCeia,
                                                      child: Text(
                                                          Textos
                                                              .labelServirSantaCeia,
                                                          textAlign:
                                                              TextAlign.center),
                                                    )),
                                                    DataColumn(
                                                        label: Visibility(
                                                      visible:
                                                          exibirOcultarCampoIrmaoReserva,
                                                      child: Text(
                                                          Textos
                                                              .labelIrmaoReserva,
                                                          textAlign:
                                                              TextAlign.center),
                                                    )),
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
                                                          DataCell(Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              width: 150,
                                                              //SET width
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Text(
                                                                    item
                                                                        .horarioTroca,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ))),
                                                          DataCell(Visibility(
                                                            visible:
                                                                !exibirOcultarCampoMesaApoio,
                                                            child: SizedBox(
                                                                width: 90,
                                                                //SET width
                                                                child: Text(
                                                                    item
                                                                        .primeiraHoraPulpito,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center)),
                                                          )),
                                                          DataCell(Visibility(
                                                            visible:
                                                                !exibirOcultarCampoMesaApoio,
                                                            child: SizedBox(
                                                                width: 90,
                                                                //SET width
                                                                child: Text(
                                                                    item
                                                                        .segundaHoraPulpito,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center)),
                                                          )),
                                                          DataCell(SizedBox(
                                                              width: 90,
                                                              //SET width
                                                              child: Text(
                                                                  item
                                                                      .primeiraHoraEntrada,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center))),
                                                          DataCell(SizedBox(
                                                              width: 90,
                                                              //SET width
                                                              child: Text(
                                                                  item
                                                                      .segundaHoraEntrada,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center))),
                                                          DataCell(Visibility(
                                                            visible:
                                                                exibirOcultarCampoMesaApoio,
                                                            child: SizedBox(
                                                                width: 90,
                                                                //SET width
                                                                child: Text(
                                                                    item
                                                                        .mesaApoio,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center)),
                                                          )),
                                                          DataCell(SizedBox(
                                                              width: 150,
                                                              //SET width
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Text(
                                                                    item
                                                                        .uniforme,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ))),
                                                          DataCell(Visibility(
                                                            visible:
                                                                exibirOcultarCampoRecolherOferta,
                                                            child: SizedBox(
                                                                width: 90,
                                                                //SET width
                                                                child: Text(
                                                                    item
                                                                        .recolherOferta,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center)),
                                                          )),
                                                          DataCell(Visibility(
                                                            visible:
                                                                exibirOcultarServirSantaCeia,
                                                            child: SizedBox(
                                                                width: 90,
                                                                //SET width
                                                                child: Text(
                                                                    item
                                                                        .servirSantaCeia,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center)),
                                                          )),
                                                          DataCell(Visibility(
                                                            visible:
                                                                exibirOcultarCampoIrmaoReserva,
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
                                                                        .rotaAtualizarItemEscala,
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
                                  botoesAcoes(Textos.btnAdicionar,
                                      Constantes.iconeAdicionar, 100, 60),
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
