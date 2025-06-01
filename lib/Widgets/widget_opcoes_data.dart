import 'dart:io';

import 'package:flutter/material.dart';
import 'package:senturionscaleg/Modelo/check_box_modelo.dart';
import 'package:senturionscaleg/Modelo/radio_button_opcao_data.dart';
import 'package:senturionscaleg/Uteis/metodos_auxiliares.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';
import 'package:senturionscaleg/Uteis/textos.dart';

class WidgetOpcoesData extends StatefulWidget {
  const WidgetOpcoesData({super.key, required this.dataSelecionada});

  final String dataSelecionada;

  @override
  State<WidgetOpcoesData> createState() => _WidgetOpcoesDataState();
}

class _WidgetOpcoesDataState extends State<WidgetOpcoesData> {
  int valorRadioButtonSelecionado = 0;
  String checkBoxSelecionado = "";
  String dataSelecionadaComDepartamento = "";
  bool exibirOpcoesAdicionaisPeriodo = false;

  List<CheckBoxModelo> opcoesAdicionais = [
    CheckBoxModelo(texto: Textos.departamentoEnsaio),
    CheckBoxModelo(texto: Textos.departamentoPeriodoManha),
    CheckBoxModelo(texto: Textos.departamentoPeriodoTarde),
    CheckBoxModelo(texto: Textos.departamentoPeriodoNoite),
    CheckBoxModelo(texto: Textos.departamentoPrimeiroHorario),
    CheckBoxModelo(texto: Textos.departamentoSegundoHorario),
    CheckBoxModelo(texto: Textos.departamentoSede)
  ];

  List<OpcaoDataRadioButton> opcoesDepartamento = [
    OpcaoDataRadioButton(
        valorRadioButton: 0, nomeRadioButton: Textos.departamentoCultoLivre),
    OpcaoDataRadioButton(
        valorRadioButton: 1, nomeRadioButton: Textos.departamentoMissao),
    OpcaoDataRadioButton(
        valorRadioButton: 2, nomeRadioButton: Textos.departamentoCirculoOracao),
    OpcaoDataRadioButton(
        valorRadioButton: 3, nomeRadioButton: Textos.departamentoJovens),
    OpcaoDataRadioButton(
        valorRadioButton: 4, nomeRadioButton: Textos.departamentoAdolecentes),
    OpcaoDataRadioButton(
        valorRadioButton: 5, nomeRadioButton: Textos.departamentoInfantil),
    OpcaoDataRadioButton(
        valorRadioButton: 6, nomeRadioButton: Textos.departamentoVaroes),
    OpcaoDataRadioButton(
        valorRadioButton: 7, nomeRadioButton: Textos.departamentoCampanha),
    OpcaoDataRadioButton(
        valorRadioButton: 8, nomeRadioButton: Textos.departamentoEbom),
    OpcaoDataRadioButton(
        valorRadioButton: 9, nomeRadioButton: Textos.departamentoFamilia),
    OpcaoDataRadioButton(
        valorRadioButton: 10, nomeRadioButton: Textos.departamentoDeboras),
    OpcaoDataRadioButton(
        valorRadioButton: 11, nomeRadioButton: Textos.departamentoConferencia),
    OpcaoDataRadioButton(
        valorRadioButton: 12, nomeRadioButton: Textos.departamentoGrupoLouvor),
    OpcaoDataRadioButton(
        valorRadioButton: 13, nomeRadioButton: Textos.departamentoMusicos),
    OpcaoDataRadioButton(
        valorRadioButton: 14, nomeRadioButton: Textos.departamentoCeia),
    OpcaoDataRadioButton(
        valorRadioButton: 15, nomeRadioButton: Textos.departamentoEnsaio),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //definindo que a variavel vai receber o valor do widget
    dataSelecionadaComDepartamento = widget.dataSelecionada;
    //verificando se a data contem o parametro passado para adicionar um pequeno espaco
    // para caso seja selecionado uma opcao nao ficar grudada
    if (dataSelecionadaComDepartamento.contains("")) {
      dataSelecionadaComDepartamento = dataSelecionadaComDepartamento + " ";
    }
    //chamando metodos para recuperar os valores
    recuperarValorCheckBox(dataSelecionadaComDepartamento);
    valorRadioButtonSelecionado = recuperarValorRadioButton(
        dataSelecionadaComDepartamento, opcoesDepartamento);
  }

  //metodo responsavel por recuperar na lista o nome do departamento selecionado
  //metodo usado tanto para mostrar como vai ficar a data como para passar
  // o nome para a outra tela
  recuperarNomeDepartamento(int valorRadio) {
    String departamentoSelecionado = "";
    opcoesDepartamento.forEach(
      (element) {
        if (valorRadio == element.valorRadioButton) {
          departamentoSelecionado = element.nomeRadioButton;
        }
        //sobreescrevendo para caso seja selecionado
        // a opcao definir que a variavel vai receber vazio
        if (departamentoSelecionado.contains(Textos.departamentoCultoLivre)) {
          departamentoSelecionado = "";
        }
      },
    );
    return departamentoSelecionado;
  }

  //metodo para recuperar o valor do radio
  // button recebendo o nome do departamento
  recuperarValorRadioButton(
      String departamento, List<OpcaoDataRadioButton> opcaoDataDepartamento) {
    int valorRadioButtonSelecionado = 0;
    //percorrendo a lista para verificar se o parametro passado contem
    // o nome que esta no radio button
    opcaoDataDepartamento.forEach(
      (element) {
        // caso tenha a variavel vai receber o valor
        if (departamento.contains(element.nomeRadioButton)) {
          valorRadioButtonSelecionado = element.valorRadioButton;
        }
      },
    );
    return valorRadioButtonSelecionado;
  }

  //metodo para recuperar os valores do checkbox
  recuperarValorCheckBox(String departamento) {
    opcoesAdicionais.forEach(
      (element) {
        if (departamento.contains(element.texto)) {
          setState(() {
            element.checked = true;
          });
        } else {
          element.checked = false;
        }
      },
    );
  }

  //metodo para remover o nome anterior caso seja selecionado uma nova opcao
  removerDepartamentoAnteriorSelecaoRadio(String departamento) {
    opcoesDepartamento.forEach(
      (element) {
        if (departamento.contains(element.nomeRadioButton)) {
          departamento = departamento.split(element.nomeRadioButton)[0];
        }
      },
    );
    return departamento;
  }

  removerDepartamentoAnteriorSelecaoCheckBox(String departamento) {
    opcoesAdicionais.forEach(
      (element) {
        if (departamento.contains(element.texto)) {
          departamento = departamento.split(element.texto)[0];
        }
      },
    );
    return departamento;
  }

  verificarSelecoes() {
    String opcoesAdicionaisSelecionada = "";
    opcoesAdicionais.forEach(
      (element) {
        if (element.checked) {
          opcoesAdicionaisSelecionada = element.texto;
        }
      },
    );
    setState(() {
      //defindo que a data vai receber os valores que os metodos retornar
      dataSelecionadaComDepartamento = removerDepartamentoAnteriorSelecaoRadio(
          dataSelecionadaComDepartamento);
      dataSelecionadaComDepartamento =
          removerDepartamentoAnteriorSelecaoCheckBox(
              dataSelecionadaComDepartamento);
      //concatenando a variavel para receber os valores que o metodo retornar e que a variavel recebel
      dataSelecionadaComDepartamento =
          "${dataSelecionadaComDepartamento}${recuperarNomeDepartamento(valorRadioButtonSelecionado)}" +
              opcoesAdicionaisSelecionada;
    });
    //chamando metodo para passar informacoes para a outra tela
    MetodosAuxiliares.passarDepartamentoSelecionado(
        recuperarNomeDepartamento(valorRadioButtonSelecionado) +
            opcoesAdicionaisSelecionada);
  }

  Widget radioButtonSelecaoDepartamento(int valor, String nomeBtn) => SizedBox(
        width: 250,
        height: 60,
        child: Row(
          children: [
            Radio(
              value: valor,
              groupValue: valorRadioButtonSelecionado,
              onChanged: (value) {
                setState(() {
                  valorRadioButtonSelecionado = valor;
                  verificarSelecoes();
                });
              },
            ),
            Text(nomeBtn)
          ],
        ),
      );

  Widget checkBoxPersonalizado(CheckBoxModelo checkBoxModel) =>
      CheckboxListTile(
        activeColor: PaletaCores.corAzulEscuro,
        checkColor: PaletaCores.corRosaClaro,
        title: Text(
          checkBoxModel.texto,
          style: const TextStyle(fontSize: 17),
        ),
        value: checkBoxModel.checked,
        side: const BorderSide(width: 2, color: PaletaCores.corAzulEscuro),
        onChanged: (value) {
          setState(() {
            print(value);
            checkBoxModel.checked = value!;
            //verificando se o checkbox selecionado
            if (checkBoxModel.checked == true) {
              // caso tenha sido definir que a variavel receber o valor
              checkBoxSelecionado = checkBoxModel.texto;
            } else {
              // caso seja desmarcado vai receber o seguinte valor
              checkBoxSelecionado = "";
            }
            //percorrendo a lista
            opcoesAdicionais.forEach(
              (element) {
                //caso a variavel seja DIFERENTE do elemento passado
                if (checkBoxSelecionado != element.texto) {
                  // definir que o valor do elemento sera
                  // false para poder desmarcar na lista de checkbox
                  element.checked = false;
                }
              },
            );
            //chamando metodo
            verificarSelecoes();
          });
        },
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          Textos.descricaoSelecaoDepartamentos,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        Text(
          dataSelecionadaComDepartamento
              .replaceAll("(", "")
              .replaceAll(")", ""),
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
            width: Platform.isIOS || Platform.isAndroid ? 300 : 500,
            height: Platform.isIOS || Platform.isAndroid ? 200 : 250,
            child: Card(
              color: Colors.white,
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(width: 1, color: PaletaCores.corCastanho)),
              child: ListView.builder(
                itemCount: opcoesDepartamento.length,
                itemBuilder: (context, index) {
                  return radioButtonSelecaoDepartamento(
                      opcoesDepartamento.elementAt(index).valorRadioButton,
                      opcoesDepartamento.elementAt(index).nomeRadioButton);
                },
              ),
            )),
        Text(
          Textos.descricaoDepartamentoPeriodo,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        Container(
            width: Platform.isIOS || Platform.isAndroid ? 300 : 500,
            height: Platform.isIOS || Platform.isAndroid ? 200 : 250,
            child: Card(
              color: Colors.white,
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(width: 1, color: PaletaCores.corCastanho)),
              child: ListView(
                children: [
                  ...opcoesAdicionais.map((e) => checkBoxPersonalizado(
                        e,
                      ))
                ],
              ),
            )),
      ],
    );
  }
}
