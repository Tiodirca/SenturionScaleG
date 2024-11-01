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

  Widget botao(
    String nomeBtn,
  ) =>
      Container(
        margin: const EdgeInsets.all(10),
        width: 200,
        height: 50,
        child: ElevatedButton(
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
            } else {
              Navigator.pushReplacementNamed(
                  arguments: Constantes.fireBaseDocumentoCooperadores,
                  context,
                  Constantes.rotaTelaCadastroVoluntarios);
            }
          },
          child: Text(nomeBtn),
        ),
      );

  @override
  Widget build(BuildContext context) {
    double larguraTela = MediaQuery.of(context).size.width;
    double alturaTela = MediaQuery.of(context).size.height;
    return Theme(
        data: estilo.estiloGeral,
        child: Scaffold(
          appBar: AppBar(
            title: Text(Textos.nomeApp),
          ),
          body: Container(
            width: larguraTela,
            height: alturaTela,
            color: Colors.white,
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                botao(Textos.btnCooperadores),
                botao(Textos.btnCooperadoras),
                botao(Textos.btnConfiguracoes),
                botao(Textos.btnListarEscalas)
              ],
            ),
          ),
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
