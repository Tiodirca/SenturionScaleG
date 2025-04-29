import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:senturionscaleg/Modelo/tabelas_modelo.dart';
import 'package:senturionscaleg/Uteis/textos.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constantes.dart';

class MetodosAuxiliares {
  static String complementoDataDepartamento = Textos.departamentoCultoLivre;

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

  static mudarRadioButton(int valorRadioButton) {
    switch (valorRadioButton) {
      case 0:
        return complementoDataDepartamento = Textos.departamentoCultoLivre;
      case 1:
        return complementoDataDepartamento = Textos.departamentoMissao;
      case 2:
        return complementoDataDepartamento = Textos.departamentoCirculoOracao;
      case 3:
        return complementoDataDepartamento = Textos.departamentoJovens;
      case 4:
        return complementoDataDepartamento = Textos.departamentoAdolecentes;
      case 5:
        return complementoDataDepartamento = Textos.departamentoInfantil;
      case 6:
        return complementoDataDepartamento = Textos.departamentoVaroes;
      case 7:
        return complementoDataDepartamento = Textos.departamentoCampanha;
      case 8:
        return complementoDataDepartamento = Textos.departamentoEbom;
      case 9:
        return complementoDataDepartamento = Textos.departamentoSede;
      case 10:
        return complementoDataDepartamento = Textos.departamentoFamilia;
      case 11:
        return complementoDataDepartamento = Textos.departamentoDeboras;
      case 12:
        return complementoDataDepartamento = Textos.departamentoConferencia;
      case 13:
        return complementoDataDepartamento = Textos.departamentoPeriodoManha;
      case 14:
        return complementoDataDepartamento = Textos.departamentoPeriodoTarde;
      case 15:
        return complementoDataDepartamento = Textos.departamentoPeriodoNoite;
      case 16:
        return complementoDataDepartamento = Textos.departamentoPrimeiroHorario;
      case 17:
        return complementoDataDepartamento = Textos.departamentoSegundoHorario;
    }
  }

  static recuperarValorRadioButtonComplementoData(String data) {
    int valorRadioButton = 0;
    if (data.toString().contains(Textos.departamentoCultoLivre)) {
      valorRadioButton = 0;
    } else if (data.toString().contains(Textos.departamentoMissao)) {
      valorRadioButton = 1;
    } else if (data.toString().contains(Textos.departamentoCirculoOracao)) {
      valorRadioButton = 2;
    } else if (data.toString().contains(Textos.departamentoJovens)) {
      valorRadioButton = 3;
    } else if (data.toString().contains(Textos.departamentoAdolecentes)) {
      valorRadioButton = 4;
    } else if (data.toString().contains(Textos.departamentoInfantil)) {
      valorRadioButton = 5;
    } else if (data.toString().contains(Textos.departamentoVaroes)) {
      valorRadioButton = 6;
    } else if (data.toString().contains(Textos.departamentoCampanha)) {
      valorRadioButton = 7;
    } else if (data.toString().contains(Textos.departamentoEbom)) {
      valorRadioButton = 8;
    } else if (data.toString().contains(Textos.departamentoSede)) {
      valorRadioButton = 9;
    } else if (data.toString().contains(Textos.departamentoFamilia)) {
      valorRadioButton = 10;
    } else if (data.toString().contains(Textos.departamentoDeboras)) {
      valorRadioButton = 11;
    } else if (data.toString().contains(Textos.departamentoConferencia)) {
      valorRadioButton = 12;
    } else if (data.toString().contains(Textos.departamentoPeriodoManha)) {
      valorRadioButton = 13;
    } else if (data.toString().contains(Textos.departamentoPeriodoTarde)) {
      valorRadioButton = 14;
    } else if (data.toString().contains(Textos.departamentoPeriodoNoite)) {
      valorRadioButton = 15;
    } else if (data.toString().contains(Textos.departamentoPrimeiroHorario)) {
      valorRadioButton = 16;
    } else if (data.toString().contains(Textos.departamentoSegundoHorario)) {
      valorRadioButton = 17;
    } else if (data.toString().contains(Textos.departamentoPeriodoNenhum)) {
      valorRadioButton = 0;
    }
    return valorRadioButton;
  }
}
