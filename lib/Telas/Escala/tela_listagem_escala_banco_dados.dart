import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:senturionscaleg/Modelo/tabelas_modelo.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';
import '../../Uteis/constantes.dart';
import '../../Uteis/estilo.dart';
import '../../Uteis/textos.dart';
import '../../Widgets/tela_carregamento.dart';

class TelaListagemTabelasBancoDados extends StatefulWidget {
  const TelaListagemTabelasBancoDados({super.key});

  @override
  State<TelaListagemTabelasBancoDados> createState() =>
      _TelaListagemTabelasBancoDadosState();
}

class _TelaListagemTabelasBancoDadosState
    extends State<TelaListagemTabelasBancoDados> {
  String nomeItemDrop = "";
  String idTabelaSelecionada = "";
  String nomeTabelaSelecionada = "";
  bool exibirConfirmacaoTabelaSelecionada = false;
  Estilo estilo = Estilo();
  bool exibirWidgetCarregamento = true;
  List<TabelaModelo> tabelasBancoDados = [];

  @override
  void initState() {
    super.initState();
    chamarConsultarTabelas();
  }

  chamarConsultarTabelas() async {
    tabelasBancoDados = await consultarTabelas();
    if (tabelasBancoDados.isEmpty) {
      setState(() {
        nomeItemDrop = "";
        exibirWidgetCarregamento = false;
      });
    } else {
      setState(() {
        nomeItemDrop = tabelasBancoDados.first.nomeTabela;
        exibirWidgetCarregamento = false;
      });
    }
  }

  static Future consultarTabelas() async {
    List<TabelaModelo> tabelasBancoDados = [];
    var db = FirebaseFirestore.instance;
    await db.collection(Constantes.fireBaseColecaoEscala).get().then((event) {
      for (var doc in event.docs) {
        var nomeTabela = doc
            .data()
            .values
            .toString()
            .replaceAll("(", "")
            .replaceAll(")", "");
        tabelasBancoDados
            .add(TabelaModelo(nomeTabela: nomeTabela, idTabela: doc.id));
      }
    });
    return tabelasBancoDados;
  }

  Future<void> alertaExclusao(BuildContext context) async {
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
                      nomeTabelaSelecionada,
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
                chamarDeletar();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Metodo para chamar deletar tabela
  chamarDeletar() async {
    setState(() {
      exibirWidgetCarregamento = true;
    });
    String retornoIdDocumentoFireBase =
        await realizarConsultaDocumentoFirebase();
    var db = FirebaseFirestore.instance;
    await db
        .collection(Constantes.fireBaseColecaoEscala)
        .doc(retornoIdDocumentoFireBase)
        .delete()
        .then(
      (doc) {
        setState(() {
          tabelasBancoDados = [];
          nomeItemDrop = "";
          nomeTabelaSelecionada = "";
          exibirConfirmacaoTabelaSelecionada = false;
        });
        //exibirMsg(Textos.sucessoMsgExcluirEscala);
        chamarConsultarTabelas();
      },
      onError: (e) => exibirMsg(Textos.erroMsgExcluirEscala),
    );
  }

  realizarConsultaDocumentoFirebase() async {
    String idDocumentoFirebase = "";

    var db = FirebaseFirestore.instance;
    //consultando id do documento no firebase para posteriormente excluir
    await db
        .collection(Constantes.fireBaseColecaoEscala)
        .where(Constantes.fireBaseDocumentoEscala)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          if (docSnapshot.data().values.contains(nomeTabelaSelecionada)) {
            idDocumentoFirebase = docSnapshot.id;
          }
        }
      },
    );
    return idDocumentoFirebase;
  }

  exibirMsg(String msg) {
    final snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget botoesAcoes(String nomeBotao, Color corBotao) => SizedBox(
      height: 40,
      width: 60,
      child: FloatingActionButton(
        heroTag: nomeBotao,
        elevation: 0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: corBotao),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        onPressed: () async {
          if (nomeBotao == Constantes.iconeAdicionar) {
            Navigator.pushReplacementNamed(context, Constantes.rotaTelaInicial);
          } else if (nomeBotao == Constantes.iconeRecarregar) {
            setState(() {
              exibirWidgetCarregamento = true;
            });
            chamarConsultarTabelas();
          } else {
            alertaExclusao(context);
          }
        },
        child: LayoutBuilder(
          builder: (p0, p1) {
            if (nomeBotao == Constantes.iconeAdicionar) {
              return const Icon(
                Icons.add_circle_outline_outlined,
                color: PaletaCores.corAzulMagenta,
              );
            } else if (nomeBotao == Constantes.iconeRecarregar) {
              return const Icon(Icons.refresh,
                  color: PaletaCores.corAzulMagenta);
            } else {
              return const Center(
                  child: Icon(
                Icons.close_outlined,
                color: PaletaCores.corAzulMagenta,
                size: 30,
              ));
            }
          },
        ),
      ));

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
              } else if (tabelasBancoDados.isEmpty) {
                return Container(
                  margin: const EdgeInsets.all(30),
                  width: larguraTela,
                  height: alturaTela,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        width: larguraTela * 0.5,
                        child: Text(Textos.descricaoErroConsultasBancoDados,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            botoesAcoes(Constantes.iconeAdicionar,
                                PaletaCores.corVermelha),
                            botoesAcoes(Constantes.iconeRecarregar,
                                PaletaCores.corAmarela)
                          ]),
                    ],
                  ),
                );
              } else {
                return Scaffold(
                  appBar: AppBar(
                      title: Text(Textos.btnListarEscalas),
                      leading: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, Constantes.rotaTelaInicial);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                        ),
                      )),
                  body: Container(
                      color: Colors.white,
                      width: larguraTela,
                      height: alturaTela,
                      child: Column(
                        children: [
                          SizedBox(
                            width: larguraTela,
                            child: Text(
                              textAlign: TextAlign.center,
                              Textos.descricaoDropDownTabelas,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          DropdownButton(
                            value: nomeItemDrop,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 40,
                              color: Colors.black,
                            ),
                            items: tabelasBancoDados
                                .map((item) => DropdownMenuItem<String>(
                                      value: item.nomeTabela,
                                      child: Text(
                                        item.nomeTabela.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                nomeItemDrop = value!;
                                nomeTabelaSelecionada = nomeItemDrop;
                                for (var element in tabelasBancoDados) {
                                  if (element.nomeTabela
                                      .contains(nomeTabelaSelecionada)) {
                                    idTabelaSelecionada = element.idTabela;
                                  }
                                }
                                exibirConfirmacaoTabelaSelecionada = true;
                              });
                            },
                          ),
                          Visibility(
                              visible: exibirConfirmacaoTabelaSelecionada,
                              child: Container(
                                  margin: const EdgeInsets.all(10),
                                  width: larguraTela,
                                  child: Column(
                                    children: [
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          Text(
                                            textAlign: TextAlign.center,
                                            Textos.descricaoTabelaSelecionada,
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          Text(
                                            textAlign: TextAlign.center,
                                            nomeTabelaSelecionada,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: botoesAcoes(
                                                Constantes.iconeExclusao,
                                                PaletaCores.corVermelha),
                                          )
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(20),
                                        width: 200,
                                        height: 60,
                                        child: ElevatedButton(
                                          child: Text(
                                            Textos.btnUsarTabela,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    PaletaCores.corAzulMagenta,
                                                fontSize: 18),
                                          ),
                                          onPressed: () {
                                            var dados = {};
                                            dados[Constantes.rotaArgumentoNomeEscala] =
                                                nomeTabelaSelecionada;
                                            dados[Constantes
                                                    .rotaArgumentoIDEscalaSelecionada] =
                                                idTabelaSelecionada;
                                            Navigator
                                                .pushReplacementNamed(
                                                    context,
                                                    Constantes
                                                        .rotaEscalaDetalhada,
                                                    arguments:
                                                        dados);
                                          },
                                        ),
                                      )
                                    ],
                                  )))
                        ],
                      )),
                );
              }
            },
          ),
        ));
  }
}
