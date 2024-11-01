import 'package:flutter/material.dart';
import 'package:senturionscaleg/Uteis/paleta_cores.dart';

import '../Uteis/constantes.dart';
import '../Uteis/textos.dart';

class BarraNavegacao extends StatelessWidget {
  BarraNavegacao({Key? key}) : super(key: key);

  final Color corTextoBotao = PaletaCores.corAzulEscuro;

  Widget botoesIcones(String nomeBtn, BuildContext context, IconData icon) =>
      SizedBox(
          height: 60,
          width: 60,
          child: FloatingActionButton(
            heroTag: nomeBtn,
            onPressed: () {
              if (nomeBtn == Textos.btnTelaInicial) {
                Navigator.pushReplacementNamed(
                    context, Constantes.rotaTelaInicial);
              } else if (nomeBtn == Textos.btnListarEscalas) {
                Navigator.pushReplacementNamed(
                    context, Constantes.rotaListarEscalas);
              } else if (nomeBtn == Textos.btnConfiguracoes) {
                Navigator.pushReplacementNamed(
                    context, Constantes.rotaTelaConfiguracoes);
              }
            },
            child: Center(
              child: Icon(
                icon,
                size: 25,
                color: corTextoBotao,
              ),
            ),
          ));

  @override
  Widget build(BuildContext context) {
    double larguraTela = MediaQuery.of(context).size.width;

    return SizedBox(
      width: larguraTela,
      height: 65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          botoesIcones(Textos.btnTelaInicial, context, Icons.home_filled),
          botoesIcones(
              Textos.btnListarEscalas, context, Icons.list_alt_outlined),
          botoesIcones(Textos.btnConfiguracoes, context, Icons.settings),
        ],
      ),
    );
  }
}
