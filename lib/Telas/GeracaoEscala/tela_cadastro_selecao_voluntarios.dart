import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senturionscaleg/Uteis/metodos_auxiliares.dart';
import 'package:senturionscaleg/Widgets/tela_carregamento.dart';
import '../../Modelo/check_box_modelo.dart';
import '../../Uteis/estilo.dart';
import '../../Uteis/paleta_cores.dart';
import '../../Uteis/textos.dart';
import '../../Uteis/constantes.dart';

class TelaCadastroSelecaoVoluntarios extends StatefulWidget {
  final String tipoCadastroVoluntarios;

  const TelaCadastroSelecaoVoluntarios(
      {super.key, required this.tipoCadastroVoluntarios});

  @override
  State<TelaCadastroSelecaoVoluntarios> createState() =>
      _TelaCadastroSelecaoVoluntariosState();
}

class _TelaCadastroSelecaoVoluntariosState
    extends State<TelaCadastroSelecaoVoluntarios> {
  String ordenarCadastroVoluntarios = "";
  List<CheckBoxModelo> listaVoluntariosCadastrados = [];
  List<CheckBoxModelo> listaVoluntariosSelecionados = [];
  bool exibirWidgetCarregamento = true;
  final validacaoFormulario = GlobalKey<FormState>();
  Estilo estilo = Estilo();
  TextEditingController nomeVoluntario = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    if (widget.tipoCadastroVoluntarios ==
        Constantes.fireBaseDocumentoCooperadores) {
      ordenarCadastroVoluntarios = Constantes.fireBaseDocumentoCooperadores;
    } else {
      ordenarCadastroVoluntarios = Constantes.fireBaseDocumentoCooperadoras;
    }
    // chamando metodo para
    // buscar dados no banco de dados
    realizarBuscaDadosFireBase();
  }

  Widget checkBoxPersonalizado(CheckBoxModelo checkBoxModel) =>
      CheckboxListTile(
        activeColor: PaletaCores.corAzulEscuro,
        checkColor: PaletaCores.corRosaClaro,
        secondary: SizedBox(
          width: 30,
          height: 30,
          child: FloatingActionButton(
            heroTag: "btnExcluir${checkBoxModel.id}",
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.red, width: 1)),
            child: const Icon(Icons.close, size: 20),
            onPressed: () {
              // chamando alerta para confirmar exclusao do item
              alertaExclusao(context, checkBoxModel);
            },
          ),
        ),
        title: Text(
          checkBoxModel.texto,
          style: const TextStyle(fontSize: 20),
        ),
        value: checkBoxModel.checked,
        side: const BorderSide(width: 2, color: PaletaCores.corAzulEscuro),
        onChanged: (value) {
          setState(() {
            // verificando se o balor
            checkBoxModel.checked = value!;
            verificarItensSelecionados();
          });
        },
      );

  // metodo para verificar se o item foi selecionado
  // para adicionar na lista de itens selecionados
  verificarItensSelecionados() {
    //verificando cada elemento da lista de nomes cadastrados
    for (var element in listaVoluntariosCadastrados) {
      //verificando se o usuario selecionou um item
      if (element.checked == true) {
        // verificando se o item Nao foi adicionado anteriormente na lista
        if (!(listaVoluntariosSelecionados.contains(element))) {
          //add item
          listaVoluntariosSelecionados.add(element);
        }
      } else if (element.checked == false) {
        // removendo item caso seja desmarcado
        listaVoluntariosSelecionados.remove(element);
      }
    }
  }

  // metodo para cadastrar item
  cadastrarNomeVoluntario(String nome) async {
    try {
      // instanciando Firebase
      var db = FirebaseFirestore.instance;
      db
          .collection(
              Constantes.fireBaseColecaoVoluntarios) // passando a colecao
          .doc(ordenarCadastroVoluntarios) //passando o documento
          .collection(Constantes
              .fireBaseDadosVoluntarios) // passando colecao dentro do documento referenciado anteriomente
          .doc()
          .set({Constantes.fireBaseNomeVoluntario: nomeVoluntario.text});
      chamarTelaCarregamento();
      realizarBuscaDadosFireBase();
      MetodosAuxiliares.exibirMensagens(Textos.descricaoNotificacaoSucessoErro,
          Textos.tipoNotificacaoSucesso, context);
    } catch (e) {
      MetodosAuxiliares.exibirMensagens(Textos.descricaoNotificacaoSucessoErro,
          Textos.tipoNotificacaoErro, context);
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  chamarTelaCarregamento() {
    listaVoluntariosCadastrados.clear();
    nomeVoluntario.clear();
    listaVoluntariosSelecionados.clear();
    setState(() {
      exibirWidgetCarregamento = true;
    });
  }

  realizarBuscaDadosFireBase() async {
    var db = FirebaseFirestore.instance;
    //instanciano variavel
    db
        .collection(Constantes.fireBaseColecaoVoluntarios)
        .doc(ordenarCadastroVoluntarios)
        .collection(Constantes.fireBaseDadosVoluntarios)
        .get()
        .then(
      (querySnapshot) async {
        // for para percorrer todos os dados que a variavel recebeu
        if (querySnapshot.docs.isNotEmpty) {
          for (var documentoFirebase in querySnapshot.docs) {
            // chamando metodo para converter json
            // recebido do firebase para objeto
            converterJsonParaObjeto(
                ordenarCadastroVoluntarios, documentoFirebase.id);
          }
        } else {
          setState(() {
            exibirWidgetCarregamento = false;
          });
        }
      },
    );
  }

  converterJsonParaObjeto(String idDocumento, String id) async {
    var db = FirebaseFirestore.instance;
    final ref = db
        .collection(Constantes.fireBaseColecaoVoluntarios)
        .doc(ordenarCadastroVoluntarios)
        .collection(Constantes.fireBaseDadosVoluntarios)
        .doc(id)
        .withConverter(
          // chamando modelos para fazer conversao
          fromFirestore: CheckBoxModelo.fromFirestore,
          toFirestore: (CheckBoxModelo checkbox, _) => checkbox.toFirestore(),
        );

    final docSnap = await ref.get();
    final dados = docSnap.data(); // convertendo
    if (dados != null) {
      // pegando o id para posteriormente excluir o item caso seja necessario
      dados.id = docSnap.id;
      //adicionando os dados convertidos na lista
      listaVoluntariosCadastrados.add(dados);
      setState(() {
        exibirWidgetCarregamento = false;
      });
    }
  }

  // Metodo para chamar deletar tabela
  chamarDeletar(CheckBoxModelo checkbox) async {
    var db = FirebaseFirestore.instance;
    await db
        .collection(Constantes.fireBaseColecaoVoluntarios)
        .doc(ordenarCadastroVoluntarios)
        .collection(Constantes.fireBaseDadosVoluntarios)
        .doc(checkbox.id)
        .delete()
        .then(
      (doc) {
        setState(() {
          chamarTelaCarregamento();
          realizarBuscaDadosFireBase();
          listaVoluntariosSelecionados.clear();
          MetodosAuxiliares.exibirMensagens(
              Textos.descricaoNotificacaoSucessoErro,
              Textos.tipoNotificacaoSucesso,
              context);
        });
      },
      onError: (e) => MetodosAuxiliares.exibirMensagens(
          Textos.descricaoNotificacaoSucessoErro,
          Textos.tipoNotificacaoErro,
          context),
    );
  }

  Future<void> alertaExclusao(
      BuildContext context, CheckBoxModelo checkbox) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            Textos.alertaTituloExclusao,
            style: const TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Textos.alertaDescricaoExclusao,
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  children: [
                    Text(
                      checkbox.texto,
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
                chamarDeletar(checkbox);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  redirecionarTela() {
    Map dados = {};
    dados[Constantes.rotaArgumentoTipoVoluntario] =
        widget.tipoCadastroVoluntarios;
    dados[Constantes.rotaArgumentoListaVoluntarios] =
        listaVoluntariosSelecionados;
    Navigator.pushReplacementNamed(
        arguments: dados, context, Constantes.rotaSelecaoDiasSemana);
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
                      title: Text(Textos.tituloTelaCadastroSelecaoVoluntarios),
                      leading: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.popAndPushNamed(
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
                                          Textos.descricaoCadastroVoluntario,
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
                                                  controller: nomeVoluntario,
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
                                                  setState(() {
                                                    cadastrarNomeVoluntario(
                                                        nomeVoluntario.text);
                                                  });
                                                }
                                              },
                                              child: Text(Textos.btnCadastro),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )),
                            // area de listagem de nomes geral
                            SizedBox(
                              height: alturaTela * 0.55,
                              width: larguraTela,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  if (listaVoluntariosCadastrados.isNotEmpty) {
                                    // area de exibicao de descricao e listagem de nomes
                                    return SizedBox(
                                        width: larguraTela,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0),
                                                width: larguraTela,
                                                child: Text(
                                                  textAlign: TextAlign.center,
                                                  Textos
                                                      .descricaoSelecaoVoluntarios,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              // Area de Exibicao da lista com os nomes dos voluntarios
                                              Card(
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
                                                child: SizedBox(
                                                  height: alturaTela * 0.45,
                                                  width: larguraTela * 0.8,
                                                  child: ListView(
                                                    children: [
                                                      ...listaVoluntariosCadastrados
                                                          .map((e) =>
                                                              checkBoxPersonalizado(
                                                                e,
                                                              ))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ));
                                  } else {
                                    // area caso nao tenha
                                    // nenhum voluntario cadastrado
                                    return Container(
                                        margin: const EdgeInsets.all(10.0),
                                        transformAlignment: Alignment.center,
                                        alignment: Alignment.center,
                                        child: Text(
                                          Textos.descricaoSemVonluntarios,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 18),
                                        ));
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      )),
                  bottomNavigationBar: Container(
                    alignment: Alignment.center,
                    color: Colors.white,
                    width: larguraTela,
                    height: 50,
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: FloatingActionButton(
                        heroTag: "avancar",
                        onPressed: () {
                          if (listaVoluntariosSelecionados.isEmpty ||
                              (listaVoluntariosSelecionados.length < 5)) {
                            MetodosAuxiliares.exibirMensagens(
                                Textos.descricaoNoficacaoSelecaoVoluntarios,
                                Textos.tipoNotificacaoErro,
                                context);
                          } else {
                            redirecionarTela();
                          }
                        },
                        child: Text(Textos.btnAvancar),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ));
  }
}
