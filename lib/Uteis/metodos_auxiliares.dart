import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:senturionscaleg/Modelo/tabelas_modelo.dart';
import 'package:senturionscaleg/Uteis/textos.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constantes.dart';

class MetodosAuxiliares {
  static removerEspacoNomeTabelas(String texto) {
    return texto.replaceAll(" ", "_");
  }

  static exibirMensagens(String msg, String tipoAlerta, BuildContext context) {
    if (tipoAlerta == Textos.tipoNotificacaoSucesso) {
      ElegantNotification.success(
        width: 360,
        title: Text(tipoAlerta),
        showProgressIndicator: false,
        animationDuration: const Duration(seconds: 1),
        toastDuration: const Duration(seconds: 3),
        description: Text(msg),
      ).show(context);
    } else {
      return ElegantNotification.error(
        width: 360,
        title: Text(tipoAlerta),
        showProgressIndicator: false,
        animationDuration: const Duration(seconds: 1),
        toastDuration: const Duration(seconds: 3),
        description: Text(msg),
      ).show(context);
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

  //metodo para ajustar o tamanho do textField com base no tamanho da tela
  static ajustarTamanhoTextField(double larguraTela) {
    double tamanho = 150;
    //verificando qual o tamanho da tela
    if (larguraTela <= 600) {
      tamanho = 190;
    } else {
      tamanho = 500;
    }
    return tamanho;
  }

  // metodo para gravar valores
  // padroes no share preferences
  gravarDadosPadrao() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final horaMudada = prefs.getString(Constantes.horarioMudado) ?? '';
    if (horaMudada != Constantes.horarioMudado) {
      prefs.setString(Constantes.shareHorarioInicialSemana,
          Constantes.horarioInicialSemana);
      prefs.setString(
          Constantes.shareHorarioTrocaSemana, Constantes.horarioTrocaSemana);
      prefs.setString(Constantes.shareHorarioInicialFSemana,
          Constantes.horarioInicialFSemana);
      prefs.setString(
          Constantes.shareHorarioTrocaFsemana, Constantes.horarioTrocaFsemana);
    }
  }

  static Future<String> recuperarValoresSharePreferences(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var horarioInicioSemana =
        prefs.getString(Constantes.shareHorarioInicialSemana) ?? '';
    var horarioInicioFSemana =
        prefs.getString(Constantes.shareHorarioInicialFSemana) ?? '';

    if (data.toString().contains(Constantes.diaSabado) ||
        data.toString().contains(Constantes.diaDomingo)) {
      return "${Textos.msgComecoHorarioEscala} $horarioInicioFSemana";
    } else {
      return "${Textos.msgComecoHorarioEscala} $horarioInicioSemana";
    }
  }
}
