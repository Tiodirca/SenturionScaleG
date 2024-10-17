import 'dart:io';

import 'package:flutter/material.dart';
import '../../Modelo/check_box_modelo.dart';
import '../../Uteis/estilo.dart';
import '../../Uteis/paleta_cores.dart';
import '../../Uteis/textos.dart';
import '../../Uteis/constantes.dart';

class TelaSelecaoDiasEspecifico extends StatefulWidget {
  final String tipoCadastroVoluntarios;
  final List<CheckBoxModelo> voluntariosSelecionados;
  final List<CheckBoxModelo> diasSemanaCulto;
  final List<String> intervaloTrabalho;

  const TelaSelecaoDiasEspecifico(
      {super.key,
      required this.tipoCadastroVoluntarios,
      required this.voluntariosSelecionados,
      required this.diasSemanaCulto,
      required this.intervaloTrabalho});

  @override
  State<TelaSelecaoDiasEspecifico> createState() =>
      _TelaSelecaoTelaSelecaoDiasEspecificoState();
}

class _TelaSelecaoTelaSelecaoDiasEspecificoState
    extends State<TelaSelecaoDiasEspecifico> {
  Estilo estilo = Estilo();
  List<CheckBoxModelo> listaNomeVoluntarios = [];
  List<CheckBoxModelo> listaIntervaloTrabalhoConvertido = [];
  List<String> listaNomeVoluntariosSelecionados = [];
  List<String> listaIntervaloTrabalhoSelecionados = [];
  bool opcaoRadioButton = false;
  int valorRadioButton = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var element in widget.voluntariosSelecionados) {
      listaNomeVoluntarios
          .add(CheckBoxModelo(texto: element.texto, checked: false));
    }
    for (var element in widget.intervaloTrabalho) {
      listaIntervaloTrabalhoConvertido.add(CheckBoxModelo(texto: element));
    }
  }

  redirecionarTelaVoltar() {
    Map dados = {};
    dados[Constantes.rotaArgumentoTipoVoluntario] =
        widget.tipoCadastroVoluntarios;
    dados[Constantes.rotaArgumentoListaVoluntarios] =
        widget.voluntariosSelecionados;
    dados[Constantes.rotaArgumentoListaDiasSemana] = widget.diasSemanaCulto;
    Navigator.pushReplacementNamed(
        arguments: dados, context, Constantes.rotaSelecaoInvervaloTrabalho);
  }

  // widget para fazer listagem dos dias e do nomes das
  // pessoas para selecao para trabalho em dias especificos
  Widget carregarListagem(double alturaTela, double larguraTela,
          List<CheckBoxModelo> lista, String tipoListagem) =>
      SizedBox(
          height: alturaTela * 0.4,
          width: larguraTela * 0.8,
          child: Column(
            children: [
              Text(tipoListagem,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20)),
              SizedBox(
                width: larguraTela,
                height: alturaTela * 0.3,
                child: Card(
                  color: Colors.white,
                  shape: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide:
                          BorderSide(width: 1, color: PaletaCores.corCastanho)),
                  child: ListView(
                    children: [
                      ...lista
                          .map((e) => checkBoxPersonalizado(e, tipoListagem))
                    ],
                  ),
                ),
              )
            ],
          ));

  Widget checkBoxPersonalizado(
          CheckBoxModelo checkBoxModel, String tipoListagem) =>
      CheckboxListTile(
        activeColor: PaletaCores.corAzulEscuro,
        checkColor: PaletaCores.corRosaClaro,
        title: Text(
          checkBoxModel.texto,
          style: const TextStyle(fontSize: 20),
        ),
        value: checkBoxModel.checked,
        side: const BorderSide(width: 2, color: PaletaCores.corAzulEscuro),
        onChanged: (value) {
          setState(() {
            checkBoxModel.checked = value!;
            if (checkBoxModel.checked == true &&
                (tipoListagem == Textos.tipoListagemVoluntarios)) {
              listaNomeVoluntariosSelecionados.add(checkBoxModel.texto);
            } else if (checkBoxModel.checked == true &&
                (tipoListagem == Textos.tipoListagemIntervaloTrabalho)) {
              listaIntervaloTrabalhoSelecionados.add(checkBoxModel.texto);
            }
          });
        },
      );

  //metodo para mudar o estado do radio button
  void mudarRadioButton(int value) {
    setState(() {
      valorRadioButton = value;
      switch (valorRadioButton) {
        case 0:
          setState(() {
            opcaoRadioButton = false;
          });
          break;
        case 1:
          setState(() {
            opcaoRadioButton = true;
          });
          break;
      }
    });
  }

  redirecionarTela() {
    Map dados = {};
    dados[Constantes.rotaArgumentoTipoVoluntario] =
        widget.tipoCadastroVoluntarios;
    dados[Constantes.rotaArgumentoListaVoluntarios] =
        widget.voluntariosSelecionados;
    dados[Constantes.rotaArgumentoListaDiasSemana] = widget.diasSemanaCulto;
    dados[Constantes.rotaArgumentoListaIntervaloTrabalho] =
        widget.intervaloTrabalho;
    Navigator.pushReplacementNamed(
        arguments: dados, context, Constantes.rotaGerarEscala);
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
            child: Scaffold(
              appBar: AppBar(
                  title: Text(Textos.tituloSelecaoDiasEspecifico),
                  leading: IconButton(
                    color: Colors.white,
                    onPressed: () {
                      redirecionarTelaVoltar();
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
                          margin: const EdgeInsets.all(10),
                          child: Text(Textos.descricaoSelecaoDiasEspecifico,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                                value: 0,
                                activeColor: PaletaCores.corAzulEscuro,
                                groupValue: valorRadioButton,
                                onChanged: (_) {
                                  mudarRadioButton(0);
                                }),
                            const Text(
                              'Não',
                              style: TextStyle(
                                  fontSize: 17.0, fontWeight: FontWeight.bold),
                            ),
                            Radio(
                                value: 1,
                                activeColor: PaletaCores.corAzulEscuro,
                                groupValue: valorRadioButton,
                                onChanged: (_) {
                                  mudarRadioButton(1);
                                }),
                            const Text(
                              'Sim',
                              style: TextStyle(
                                  fontSize: 17.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Visibility(
                            visible: opcaoRadioButton,
                            child: Column(
                              children: [
                                carregarListagem(
                                    alturaTela,
                                    larguraTela,
                                    listaNomeVoluntarios,
                                    Textos.tipoListagemVoluntarios),
                                carregarListagem(
                                    alturaTela,
                                    larguraTela,
                                    listaIntervaloTrabalhoConvertido,
                                    Textos.tipoListagemIntervaloTrabalho)
                              ],
                            ))
                      ],
                    ),
                  )),
              bottomSheet: Container(
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
                      redirecionarTela();
                    },
                    child: Text(Textos.btnAvancar),
                  ),
                ),
              ),
            )));
  }
}
