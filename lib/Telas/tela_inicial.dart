import 'package:flutter/material.dart';

import '../Uteis/estilo.dart';
import '../Uteis/textos.dart';
import '../Uteis/constantes.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  Estilo estilo = Estilo();

  Widget botao(String nomeBtn,) =>
      Container(
        margin: const EdgeInsets.all(10),
        width: nomeBtn != Textos.btnConfiguracoes ? 200 : 50,
        height: nomeBtn != Textos.btnConfiguracoes ? 60 : 50,
        child: FloatingActionButton(
            heroTag: nomeBtn,
            onPressed: () {
              if (nomeBtn == Textos.btnCooperadoras) {
                Navigator.pushReplacementNamed(
                    arguments: Constantes.fireBaseDocumentoCooperadoras,
                    context,
                    Constantes.rotaTelaCadastroVoluntarios);
              } else if (nomeBtn == Textos.btnConfiguracoes) {
                Navigator.pushReplacementNamed(
                    context, Constantes.rotaTelaConfiguracoes);
              } else if (nomeBtn == Textos.btnListarEscalas) {
                Navigator.pushReplacementNamed(
                    context, Constantes.rotaListarEscalas);
              } else if (nomeBtn == Textos.btnSonoplastas) {
                Navigator.pushReplacementNamed(
                    arguments: Constantes.fireBaseDocumentoSonoplastas,
                    context,
                    Constantes.rotaTelaCadastroVoluntarios);
              } else {
                Navigator.pushReplacementNamed(
                    arguments: Constantes.fireBaseDocumentoCooperadores,
                    context,
                    Constantes.rotaTelaCadastroVoluntarios);
              }
            },
            child: LayoutBuilder(builder: (context, constraints) {
              if (nomeBtn == Textos.btnConfiguracoes) {
                return Icon(Icons.settings, size: 40,);
              } else {
                return Text(
                  nomeBtn,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,),
                );
              }
            },)
        ),
      );

  @override
  Widget build(BuildContext context) {
    double larguraTela = MediaQuery
        .of(context)
        .size
        .width;
    double alturaTela = MediaQuery
        .of(context)
        .size
        .height;
    return Theme(
        data: estilo.estiloGeral,
        child: Scaffold(
          appBar: AppBar(
            title: Text(Textos.nomeApp),
            leading: const Image(
              image: AssetImage('assets/imagens/Logo.png'),
              width: 10,
              height: 10,
            ),
          ),
          body: Container(
            width: larguraTela,
            height: alturaTela,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                botao(Textos.btnConfiguracoes),
                Container(
                  width: larguraTela,
                  height: alturaTela * 0.6,
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                      Container(
                      width: larguraTela,
                      child: Text(Textos.descricaoTelaInicial,
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center)),
                botao(Textos.btnCooperadores),
                botao(Textos.btnCooperadoras),
                botao(Textos.btnSonoplastas),
                botao(Textos.btnListarEscalas),
              ],
            ),
          )
          ],
        )),
    bottomNavigationBar: Container(
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    color: Colors.white,
    width: larguraTela,
    height: 40,
    child: Text(
    Textos.versaoApp,
    textAlign: TextAlign.end,
    ),
    ),
    ));
  }
}
