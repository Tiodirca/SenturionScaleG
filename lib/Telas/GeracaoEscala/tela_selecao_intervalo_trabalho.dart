import 'dart:io';
import 'package:flutter/material.dart';
import 'package:senturionscaleg/Modelo/check_box_modelo.dart';
import 'package:senturionscaleg/Uteis/constantes.dart';
import 'package:senturionscaleg/Uteis/estilo.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';
import 'package:senturionscaleg/Uteis/textos.dart';
import 'package:intl/intl.dart';

class TelaSelecaoIntervaloTrabalho extends StatefulWidget {
  final String tipoCadastroVoluntarios;
  final List<CheckBoxModelo> voluntariosSelecionados;
  final List<CheckBoxModelo> diasSemanaCulto;

  const TelaSelecaoIntervaloTrabalho(
      {super.key,
      required this.tipoCadastroVoluntarios,
      required this.voluntariosSelecionados,
      required this.diasSemanaCulto});


  @override
  State<TelaSelecaoIntervaloTrabalho> createState() =>
      _TelaSelecaoIntervaloTrabalhoState();
}

class _TelaSelecaoIntervaloTrabalhoState
    extends State<TelaSelecaoIntervaloTrabalho> {
  Estilo estilo = Estilo();
  List<CheckBoxModelo> listaDiasSelecionado = [];
  DateTime dataInicial = DateTime.now();
  DateTime dataFinal = DateTime.now();
  List<String> listaDatasFinal = [];
  List<DateTime> listaDatasAuxiliar = [];
  bool exibirListagemIntervalo = false;

  Widget selecaoPeriodoTrabalho(String label, DateTime data) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      width: 150,
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: PaletaCores.corAzulEscuro),
          ),
          TextFormField(
            readOnly: true,
            onTap: () async {
              DateTime? novaData = await showDatePicker(
                  builder: (context, child) {
                    return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: PaletaCores.corAzulEscuro,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          dialogBackgroundColor: Colors.white,
                        ),
                        child: child!);
                  },
                  context: context,
                  initialDate: data,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));

              if (novaData == null) return;
              setState(() {
                if (label.contains(Textos.labelPeriodoInicio)) {
                  dataInicial = novaData;
                } else {
                  dataFinal = novaData;
                }
                listaDatasAuxiliar = [];
                listaDatasFinal = [];
                pegarDatasIntervalo();
              });
            },
            decoration: InputDecoration(
              hintStyle:  const TextStyle(color: PaletaCores.corAzulEscuro,),
              hintText: '${data.day}/${data.month}/${data.year}',
            ),
          ),
        ],
      ));

  // metodo para pegar o intervalo de datas entre
  // o primeiro periodo e o periodo final
  pegarDatasIntervalo() {
    // setando valor para a variavel
    DateTime datasDiferenca = dataInicial;
    //pegando a diferenca entre as datas em dias
    dynamic diferencaDias = datasDiferenca
        .difference(dataFinal.add(const Duration(days: 1)))
        .inDays;
    //verificando se a variavel recebeu um valor negativo
    if (diferencaDias.toString().contains("-")) {
      // passando para positivo
      diferencaDias = -(diferencaDias);
    }
    //pegando todas as datas
    for (int interacao = 0; interacao <= diferencaDias; interacao++) {
      listaDatasAuxiliar.add(datasDiferenca);
      // definindo que a variavel vai receber ela mesma
      // com a adicao de parametro de duracao
      datasDiferenca = datasDiferenca.add(const Duration(days: 1));
    }
    listarDatas();
  }

  // metodo para listar as datas formatando elas para
  // o formato que contenha da data em numeros e o dia da semana
  listarDatas() {
    // pegando todos os itens da lista
    for (var element in listaDatasAuxiliar) {
      String data = DateFormat("dd/MM/yyyy EEEE", "pt_BR").format(element);
      // verificando se a data contem o dia
      // da semana selecionado anteriormente caso conter adicionar na lista
      for (var element in widget.diasSemanaCulto) {
        if (data.toString().contains(element.texto.toLowerCase())) {
          listaDatasFinal.add(data);
        }
      }
    }
    setState(() {
      exibirListagemIntervalo = true;
    });
  }

  redirecionarTelaVoltar() {
    Map dados = {};
    dados[Constantes.rotaArgumentoTipoVoluntario] =
        widget.tipoCadastroVoluntarios;
    dados[Constantes.rotaArgumentoListaVoluntarios] =
        widget.voluntariosSelecionados;
    Navigator.pushReplacementNamed(
        arguments: dados, context, Constantes.rotaSelecaoDiasSemana);
  }

  redirecionarTela() {
    Map dados = {};
    dados[Constantes.rotaArgumentoTipoVoluntario] =
        widget.tipoCadastroVoluntarios;
    dados[Constantes.rotaArgumentoListaVoluntarios] =
        widget.voluntariosSelecionados;
    dados[Constantes.rotaArgumentoListaDiasSemana] = widget.diasSemanaCulto;
    dados[Constantes.rotaArgumentoListaIntervaloTrabalho] = listaDatasFinal;
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
                  title: Text(Textos.tituloTelaSelecaoInvervaloTrabalho),
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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0),
                          width: larguraTela,
                          child: Text(
                              Textos.descricaoTipoVoluntario +
                                  widget.tipoCadastroVoluntarios,
                              textAlign: TextAlign.end),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: Text(Textos.descricaoSelecaoIntervaloTrabalho,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20)),
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            selecaoPeriodoTrabalho(
                                Textos.labelPeriodoInicio, dataInicial),
                            selecaoPeriodoTrabalho(
                                Textos.labelPeriodoFinal, dataFinal),
                          ],
                        ),
                        Container(
                            margin: const EdgeInsets.all(20),
                            height: alturaTela * 0.5,
                            width: larguraTela * 0.8,
                            child: Visibility(
                              visible: exibirListagemIntervalo,
                              child: Card(
                                color: Colors.white,
                                shape: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: PaletaCores.corCastanho)),
                                child: ListView.builder(
                                  itemCount: listaDatasFinal.length,
                                  itemBuilder: (context, index) {
                                    return Center(
                                      child: Container(
                                        alignment: Alignment.center,
                                        transformAlignment: Alignment.center,
                                        width: larguraTela * 0.6,
                                        height: 30,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.date_range_rounded,
                                                color:
                                                    PaletaCores.corAzulEscuro),
                                            Container(
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: 10.0),
                                              width: Platform.isAndroid ||
                                                      Platform.isIOS
                                                  ? larguraTela * 0.3
                                                  : larguraTela * 0.2,
                                              child: Text(
                                                listaDatasFinal
                                                    .elementAt(index)
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )),
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
