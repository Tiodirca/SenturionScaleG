import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:senturionscaleg/Modelo/escala_modelo.dart';
import 'package:senturionscaleg/Uteis/PDF/gerar_pdf_escala.dart';
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
  bool exibirTelaPesquisa = false;
  bool exibirOcultarCampoMesaApoio = false;
  bool exibirOcultarCampoUniforme = false;
  bool exibirOcultarServirSantaCeia = false;
  bool exibirOcultarTelaQuantiRepeticaoNomes = false;
  late List<EscalaModelo> escala;
  bool exibirWidgetCarregamento = true;
  bool exibirOcultarBtnAcao = true;
  int contadorItensEscala = 0;
  int quantRepeticaoNome = 0;
  List<String> nomesFiltrados = [];
  Set<String> nomes = Set();
  String nomeReacar = "";
  Map<String, int> quantidadeRepeticaoNome = {};

  @override
  void initState() {
    super.initState();
    escala = [];
    realizarBuscaDadosFireBase(widget.idTabelaSelecionada);
  }

  realizarBuscaDadosFireBase(String idDocumento) async {
    setState(() {
      nomes.clear();
      quantidadeRepeticaoNome.clear();
      nomesFiltrados.clear();
      nomeReacar = "";
      exibirOcultarTelaQuantiRepeticaoNomes = false;
      contadorItensEscala = 0;
      quantRepeticaoNome = 0;
    });
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
            converterJsonParaObjeto(
                idDocumento, documentoFirebase.id, querySnapshot.size);
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

  converterJsonParaObjeto(
      String idDocumento, String id, int tamanhoEscala) async {
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
      //adicionando os dados convertidos na lista
      escala.add(dados);
      contadorItensEscala++;
      setState(() {
        ordenarLista();
        chamarVerificarColunaVazia();
        exibirWidgetCarregamento = false;
      });
      if (contadorItensEscala == tamanhoEscala) {
        setState(() {
          pegarNomesEscala();
        });
      }
    }
  }

  pegarNomesEscala() {
    List<String> nomesFiltradosAuxiliar = [];
    if (exibirOcultarCampoMesaApoio) {
      for (EscalaModelo voluntarios in escala) {
        if (!nomes.contains(voluntarios.primeiraHoraEntrada) ||
            !nomes.contains(voluntarios.irmaoReserva) ||
            !nomes.contains(voluntarios.mesaApoio)) {
          nomes.add(voluntarios.primeiraHoraEntrada.toLowerCase());
          nomes.add(voluntarios.irmaoReserva.toLowerCase());
          nomes.add(voluntarios.mesaApoio.toLowerCase());
          nomesFiltradosAuxiliar.add(voluntarios.mesaApoio.toLowerCase());
          nomesFiltradosAuxiliar
              .add(voluntarios.primeiraHoraEntrada.toLowerCase());
          nomesFiltradosAuxiliar.add(voluntarios.irmaoReserva.toLowerCase());
        }
      }
    } else {
      for (EscalaModelo voluntarios in escala) {
        if (!nomes.contains(voluntarios.recolherOferta) ||
            !nomes.contains(voluntarios.primeiraHoraPulpito) ||
            !nomes.contains(voluntarios.primeiraHoraEntrada) ||
            !nomes.contains(voluntarios.irmaoReserva)) {
          nomesFiltradosAuxiliar.add(voluntarios.recolherOferta.toLowerCase());
          nomesFiltradosAuxiliar.add(voluntarios.primeiraHoraPulpito.toLowerCase());
          nomesFiltradosAuxiliar.add(voluntarios.primeiraHoraEntrada.toLowerCase());
          nomesFiltradosAuxiliar.add(voluntarios.irmaoReserva.toLowerCase());
        }
      }
    }
    nomesFiltradosAuxiliar.forEach(
      (element) {
        if (element.isNotEmpty) {
          if (element.contains(" e ") || element.contains("/")) {
            element = element.replaceAll(" e ", "/");
            nomesFiltrados.addAll(element.split("/"));
          } else {
            nomesFiltrados.add(element);
          }
        }
      },
    );
    chamarPercorrerEscalaCompleta();
    print(quantidadeRepeticaoNome.toString());
  }

  chamarPercorrerEscalaCompleta() {
    for (int i = 0; i < nomesFiltrados.length; i++) {
      percorrerEscalaCompleta(i);
      quantRepeticaoNome = 0;
    }
  }

  //metodo para percorrer a escala completa
  percorrerEscalaCompleta(int index) {
    escala.forEach(
      (element) {
        verificarQuantRepeticaoNome(
            element.primeiraHoraEntrada.toLowerCase(), index);
        //validando se a escala e de cooperadoras
        //caso o campo mesa apoio estiver ativo fazer os seguintes passos
        if (exibirOcultarCampoMesaApoio) {
          verificarQuantRepeticaoNome(element.mesaApoio.toLowerCase(), index);
        } else {
          verificarQuantRepeticaoNome(
              element.recolherOferta.toLowerCase(), index);
          verificarQuantRepeticaoNome(
              element.primeiraHoraPulpito.toLowerCase(), index);
        }
        verificarQuantRepeticaoNome(element.irmaoReserva.toLowerCase(), index);
      },
    );
  }

  //metodo para verificar q quantidade de repeticoes que a escala tem
  verificarQuantRepeticaoNome(String nome, int index) {
    //verificando se a string JA contem na LISTA nome filtrados
    if (nome.contains(nomesFiltrados.elementAt(index))) {
      //caso JA tenha aumentar a quantidade
      quantRepeticaoNome++;
      //passando MAP para colocar o nome e a quantidade
      quantidadeRepeticaoNome[nomesFiltrados.elementAt(index)] =
          quantRepeticaoNome;
    }
  }

  ordenarLista() {
    // ordenando a lista pela data colocando
    // a data mais antiga no topo da listagem
    escala.sort(
      (a, b) {
        //convertendo data para o formato correto
        int data = DateFormat("dd/MM/yyyy EEEE", "pt_BR")
            .parse(a.dataCulto)
            .compareTo(
                DateFormat("dd/MM/yyyy EEEE", "pt_BR").parse(b.dataCulto));

        // caso a variavel seja diferente de 0 quer dizer que as datas nao sao iguais
        // logo sera colocado em ordem baseado na ordem acima
        if (data != 0) {
          return data;
        }
        // caso a condicao acima retorne 0 quer dizer que as datas sao iguais
        // logo sera colocado em ordem baseado na ordem a baixo
        return a.horarioTroca.compareTo(b.horarioTroca);
      },
    );
  }

  formatarHorario(String horarioTrocaRecuperado) {
    String horaSeparada = horarioTrocaRecuperado.split(" : ")[1];
    DateTime conversaoHorarioPData = new DateFormat("hh").parse(horaSeparada);
    print(conversaoHorarioPData.hour.toString());
    return conversaoHorarioPData;
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
    for (var element in escala) {
      if (element.banheiroFeminino.isNotEmpty) {
        //exibirPortaBanheiroFeminino = true;
        break;
      } else {
        //exibirPortaBanheiroFeminino = false;
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
                  GerarPDFEscala gerarPDF = GerarPDFEscala(
                      escala: escala,
                      nomeEscala: widget.nomeTabela,
                      exibirMesaApoio: exibirOcultarCampoMesaApoio,
                      exibirRecolherOferta: exibirOcultarCampoRecolherOferta,
                      exibirIrmaoReserva: exibirOcultarCampoIrmaoReserva,
                      exibirServirSantaCeia: exibirOcultarServirSantaCeia,
                      exibirUniformes: exibirOcultarCampoUniforme);
                  gerarPDF.pegarDados();
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

  Widget botoesSwitch(String label, bool valorBotao) => Container(
        margin: EdgeInsets.symmetric(horizontal: 1.0),
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
    if (label == Textos.labelSwitchUniforme) {
      setState(() {
        exibirOcultarCampoUniforme = !exibirOcultarCampoUniforme;
      });
    }
  }

  validarNomeFoco(String nome) {
    if (nome.toLowerCase().contains(nomeReacar) && nomeReacar.isNotEmpty) {
      return BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border(
              bottom: BorderSide(width: 1, color: Colors.green),
              left: BorderSide(width: 1, color: Colors.green),
              right: BorderSide(width: 1, color: Colors.green),
              top: BorderSide(width: 1, color: Colors.green)));
    } else {
      return null;
    }
  }

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
                      actions: [
                        Container(
                          width: 40,
                          height: 40,
                          child: FloatingActionButton(
                            heroTag: "Pesquisa",
                            onPressed: () {
                              setState(() {
                                exibirOcultarTelaQuantiRepeticaoNomes = true;
                              });
                            },
                            child: Icon(
                              Icons.search,
                              size: 30,
                            ),
                          ),
                        )
                      ],
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
                                child: Stack(
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Column(
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
                                            ? alturaTela * 0.55
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
                                                          Textos.labelHorario,
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
                                                        label: Text(
                                                            Textos
                                                                .labelPrimeiroHoraEntrada,
                                                            textAlign: TextAlign
                                                                .center)),
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
                                                        label: Visibility(
                                                      visible:
                                                          exibirOcultarCampoUniforme,
                                                      child: Text(
                                                          Textos.labelUniforme,
                                                          textAlign:
                                                              TextAlign.center),
                                                    )),
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
                                                            child: Container(
                                                                decoration:
                                                                    validarNomeFoco(item
                                                                        .primeiraHoraPulpito),
                                                                width: 90,
                                                                //SET width
                                                                child: Text(
                                                                    item
                                                                        .primeiraHoraPulpito,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center)),
                                                          )),
                                                          DataCell(Container(
                                                              decoration:
                                                                  validarNomeFoco(item
                                                                      .primeiraHoraEntrada),
                                                              width: 90,
                                                              //SET width
                                                              child: Text(
                                                                  item
                                                                      .primeiraHoraEntrada,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center))),
                                                          DataCell(Visibility(
                                                            visible:
                                                                exibirOcultarCampoMesaApoio,
                                                            child: Container(
                                                                decoration:
                                                                    validarNomeFoco(item
                                                                        .mesaApoio),
                                                                width: 90,
                                                                //SET width
                                                                child: Text(
                                                                    item
                                                                        .mesaApoio,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center)),
                                                          )),
                                                          DataCell(Visibility(
                                                            visible:
                                                                exibirOcultarCampoUniforme,
                                                            child: SizedBox(
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
                                                                )),
                                                          )),
                                                          DataCell(Visibility(
                                                            visible:
                                                                exibirOcultarCampoRecolherOferta,
                                                            child: Container(
                                                                decoration:
                                                                    validarNomeFoco(item
                                                                        .recolherOferta),
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
                                                            child: Container(
                                                                decoration:
                                                                    validarNomeFoco(item
                                                                        .servirSantaCeia),
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
                                                            child: Container(
                                                                decoration:
                                                                    validarNomeFoco(item
                                                                        .irmaoReserva),
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
                                          )),
                                        )),
                                  ],
                                ),
                                Visibility(
                                    visible:
                                        exibirOcultarTelaQuantiRepeticaoNomes,
                                    child: Positioned(
                                        right: 0,
                                        child: Center(
                                          child: Container(
                                              padding: EdgeInsets.all(10),
                                              width: Platform.isAndroid ||
                                                      Platform.isIOS
                                                  ? larguraTela * 0.9
                                                  : larguraTela * 0.3,
                                              child: Card(
                                                  color: Colors.white,
                                                  shape: const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20)),
                                                      borderSide: BorderSide(
                                                          width: 1,
                                                          color: PaletaCores
                                                              .corCastanho)),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Text(
                                                          Textos
                                                              .telaFiltragemDescricao,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            height: 200,
                                                            width: larguraTela,
                                                            child: Center(
                                                              child: GridView
                                                                  .builder(
                                                                itemCount:
                                                                    quantidadeRepeticaoNome
                                                                        .length,
                                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                    crossAxisCount:
                                                                        Platform.isAndroid ||
                                                                                Platform.isIOS
                                                                            ? 3
                                                                            : 4),
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return Container(
                                                                      height:
                                                                          100,
                                                                      margin: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              5,
                                                                          horizontal:
                                                                              5),
                                                                      child:
                                                                          FloatingActionButton(
                                                                        heroTag: quantidadeRepeticaoNome
                                                                            .keys
                                                                            .elementAt(index)
                                                                            .toString(),
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            exibirOcultarTelaQuantiRepeticaoNomes =
                                                                                false;
                                                                            nomeReacar =
                                                                                "";
                                                                            nomeReacar =
                                                                                quantidadeRepeticaoNome.keys.elementAt(index);
                                                                            print(nomeReacar);
                                                                          });
                                                                        },
                                                                        child:
                                                                            Wrap(
                                                                          alignment:
                                                                              WrapAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              textAlign: TextAlign.center,
                                                                              " ${quantidadeRepeticaoNome.keys.elementAt(index)}",
                                                                              style: TextStyle(color: Colors.black),
                                                                            ),
                                                                            Text(textAlign: TextAlign.center,
                                                                              ": ${quantidadeRepeticaoNome.values.elementAt(index).toString()}",
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ));
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    bottom: 10),
                                                            width: 100,
                                                            height: 40,
                                                            child:
                                                                FloatingActionButton(
                                                              heroTag: Textos
                                                                  .btnCancelarAcao,
                                                              onPressed: () {
                                                                setState(() {
                                                                  exibirOcultarTelaQuantiRepeticaoNomes =
                                                                      false;
                                                                  nomeReacar =
                                                                      "";
                                                                });
                                                              },
                                                              child: Text(
                                                                Textos
                                                                    .btnCancelarAcao,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: PaletaCores
                                                                        .corRosaAvermelhado),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ))),
                                        )))
                              ],
                            )));
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
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  botoesAcoes(Textos.btnBaixar,
                                      Constantes.iconeBaixar, 100, 60),
                                  botoesSwitch(Textos.labelSwitchUniforme,
                                      exibirOcultarCampoUniforme),
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
