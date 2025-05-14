import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senturionscaleg/Modelo/check_box_modelo.dart';
import 'package:senturionscaleg/Uteis/constantes.dart';
import 'package:senturionscaleg/Uteis/estilo.dart';
import 'package:senturionscaleg/Uteis/metodos_auxiliares.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';
import 'package:senturionscaleg/Uteis/textos.dart';


class TelaSelecaoDiasSemana extends StatefulWidget {
  final String tipoCadastroVoluntarios;
  final List<CheckBoxModelo> voluntariosSelecionados;

  const TelaSelecaoDiasSemana(
      {super.key,
      required this.tipoCadastroVoluntarios,
      required this.voluntariosSelecionados});

  @override
  State<TelaSelecaoDiasSemana> createState() => _TelaSelecaoDiasSemanaState();
}

class _TelaSelecaoDiasSemanaState extends State<TelaSelecaoDiasSemana> {
  Estilo estilo = Estilo();
  List<CheckBoxModelo> listaDiasSelecionado = [];

  List<CheckBoxModelo> listaDiasSemana = [
    CheckBoxModelo(texto: Constantes.diaSegunda),
    CheckBoxModelo(texto: Constantes.diaTerca),
    CheckBoxModelo(texto: Constantes.diaQuarta),
    CheckBoxModelo(texto: Constantes.diaQuinta),
    CheckBoxModelo(texto: Constantes.diaSexta),
    CheckBoxModelo(texto: Constantes.diaSabado),
    CheckBoxModelo(texto: Constantes.diaDomingo),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget checkBoxPersonalizado(CheckBoxModelo checkBoxModel) =>
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
            verificarItensSelecionados();
          });
        },
      );

  // metodo para verificar se o item foi selecionado
  // para adicionar na lista de itens selecionados
  verificarItensSelecionados() {
    //verificando cada elemento da lista de nomes cadastrados
    for (var element in listaDiasSemana) {
      //verificando se o usuario selecionou um item
      if (element.checked == true) {
        // verificando se o item Nao foi adicionado anteriormente na lista
        if (!(listaDiasSelecionado.contains(element))) {
          //add item
          listaDiasSelecionado.add(element);
        }
      } else if (element.checked == false) {
        // removendo item caso seja desmarcado
        listaDiasSelecionado.remove(element);
      }
    }
  }

  redirecionarTela() {
    Map dados = {};
    dados[Constantes.rotaArgumentoTipoVoluntario] =
        widget.tipoCadastroVoluntarios;
    dados[Constantes.rotaArgumentoListaVoluntarios] =
        widget.voluntariosSelecionados;
    dados[Constantes.rotaArgumentoListaDiasSemana] = listaDiasSelecionado;
    Navigator.pushReplacementNamed(
        arguments: dados, context, Constantes.rotaSelecaoInvervaloTrabalho);
  }

  @override
  Widget build(BuildContext context) {
    double larguraTela = MediaQuery.of(context).size.width;
    double alturaTela = MediaQuery.of(context).size.height;
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
            child: Scaffold(
              appBar: AppBar(
                  title: Text(Textos.tituloTelaSelecaoDiasSemana),
                  leading: IconButton(
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          arguments: widget.tipoCadastroVoluntarios,
                          context,
                          Constantes.rotaTelaCadastroVoluntarios);
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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0),
                          width: larguraTela,
                          child: Text(
                              Textos.descricaoTipoVoluntario +
                                  widget.tipoCadastroVoluntarios,
                              textAlign: TextAlign.end),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          child: Text(
                            Textos.descricaoSelecaoDiasSemana,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.white,
                          shape: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(
                                  width: 1, color: PaletaCores.corCastanho)),
                          child: SizedBox(
                            height: alturaTela * 0.6,
                            width: larguraTela * 0.7,
                            child: ListView(
                              children: [
                                ...listaDiasSemana
                                    .map((e) => checkBoxPersonalizado(
                                          e,
                                        ))
                              ],
                            ),
                          ),
                        )
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
                      if (listaDiasSelecionado.isNotEmpty) {
                        redirecionarTela();
                      } else {
                        MetodosAuxiliares.exibirMensagens(
                            Textos.descricaoNotificacaoSelecaoDiasSemana,
                            Textos.tipoNotificacaoErro,
                            context);
                      }
                    },
                    child: Text(Textos.btnAvancar),
                  ),
                ),
              ),
            )));
  }
}
