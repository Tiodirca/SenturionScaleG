import 'package:flutter/material.dart';
import 'package:senturionscaleg/Telas/Escala/tela_cadastro_item.dart';
import 'package:senturionscaleg/Telas/Escala/tela_escala_detalhada.dart';
import 'package:senturionscaleg/Telas/Escala/tela_listagem_escala_banco_dados.dart';
import 'package:senturionscaleg/Telas/GeracaoEscala/tela_cadastro_selecao_voluntarios.dart';
import 'package:senturionscaleg/Telas/GeracaoEscala/tela_gerar_escala.dart';
import 'package:senturionscaleg/Telas/GeracaoEscala/tela_selecao_dias_especifico.dart';
import 'package:senturionscaleg/Telas/GeracaoEscala/tela_selecao_dias_semana.dart';
import 'package:senturionscaleg/Telas/GeracaoEscala/tela_selecao_intervalo_trabalho.dart';
import 'package:senturionscaleg/Telas/Escala/tela_atualizar.dart';
import 'package:senturionscaleg/Telas/tela_configuracoes.dart';
import 'package:senturionscaleg/Telas/tela_splash.dart';

import '../Telas/tela_inicial.dart';
import 'constantes.dart';

class Rotas {
  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Recebe os parâmetros na chamada do Navigator.
    final args = settings.arguments;
    switch (settings.name) {
      case Constantes.rotaTelaSplash:
        return MaterialPageRoute(builder: (_) => const TelaSplashScreen());
      case Constantes.rotaTelaInicial:
        return MaterialPageRoute(builder: (_) => const TelaInicial());
      case Constantes.rotaTelaConfiguracoes:
        return MaterialPageRoute(builder: (_) => const TelaConfiguracoes());
      // case Constantes.rotaTelaDividirLetraTexto:
      //   return MaterialPageRoute(builder: (_) => const TelaDividirLetraTexto());
      case Constantes.rotaTelaCadastroVoluntarios:
        if (args is String) {
          return MaterialPageRoute(
              builder: (_) => TelaCadastroSelecaoVoluntarios(
                    tipoCadastroVoluntarios: args,
                  ));
        } else {
          return erroRota(settings);
        }
      case Constantes.rotaSelecaoDiasSemana:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => TelaSelecaoDiasSemana(
              tipoCadastroVoluntarios:
                  args[Constantes.rotaArgumentoTipoVoluntario],
              voluntariosSelecionados:
                  args[Constantes.rotaArgumentoListaVoluntarios],
            ),
          );
        } else {
          return erroRota(settings);
        }
      case Constantes.rotaSelecaoInvervaloTrabalho:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => TelaSelecaoIntervaloTrabalho(
              tipoCadastroVoluntarios:
                  args[Constantes.rotaArgumentoTipoVoluntario],
              voluntariosSelecionados:
                  args[Constantes.rotaArgumentoListaVoluntarios],
              diasSemanaCulto: args[Constantes.rotaArgumentoListaDiasSemana],
            ),
          );
        } else {
          return erroRota(settings);
        }
      case Constantes.rotaSelecaoDiasEspecifico:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => TelaSelecaoDiasEspecifico(
              intervaloTrabalho:
                  args[Constantes.rotaArgumentoListaIntervaloTrabalho],
              tipoCadastroVoluntarios:
                  args[Constantes.rotaArgumentoTipoVoluntario],
              voluntariosSelecionados:
                  args[Constantes.rotaArgumentoListaVoluntarios],
              diasSemanaCulto: args[Constantes.rotaArgumentoListaDiasSemana],
            ),
          );
        } else {
          return erroRota(settings);
        }
      case Constantes.rotaGerarEscala:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => TelaGerarEscala(
              intervaloTrabalho:
                  args[Constantes.rotaArgumentoListaIntervaloTrabalho],
              tipoCadastroVoluntarios:
                  args[Constantes.rotaArgumentoTipoVoluntario],
              voluntariosSelecionados:
                  args[Constantes.rotaArgumentoListaVoluntarios],
              diasSemanaCulto: args[Constantes.rotaArgumentoListaDiasSemana],
            ),
          );
        } else {
          return erroRota(settings);
        }
      case Constantes.rotaListarEscalas:
        return MaterialPageRoute(
            builder: (_) => const TelaListagemTabelasBancoDados());
      case Constantes.rotaEscalaDetalhada:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => TelaEscalaDetalhada(
              nomeTabela: args[Constantes.rotaArgumentoNomeEscala],
              idTabelaSelecionada:
                  args[Constantes.rotaArgumentoIDEscalaSelecionada],
            ),
          );
        } else {
          return erroRota(settings);
        }
      case Constantes.rotaCadastroItemEscala:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => TelaCadastroItem(
              nomeTabela: args[Constantes.rotaArgumentoNomeEscala],
              idTabelaSelecionada:
                  args[Constantes.rotaArgumentoIDEscalaSelecionada],
            ),
          );
        } else {
          return erroRota(settings);
        }
      case Constantes.rotaAtualizarItemEscala:
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => TelaAtualizar(
              nomeTabela: args[Constantes.rotaArgumentoNomeEscala],
              idTabelaSelecionada:
                  args[Constantes.rotaArgumentoIDEscalaSelecionada],
              escalaModelo: args[Constantes.escalaModelo],
            ),
          );
        } else {
          return erroRota(settings);
        }
    }
    // Se o argumento não é do tipo correto, retorna erro
    return erroRota(settings);
  }

  //metodo para exibir tela de erro
  static Route<dynamic> erroRota(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text("Telas não encontrada!"),
        ),
        body: Container(
          color: Colors.red,
          child: const Center(
            child: Text("Erro de Rota"),
          ),
        ),
      );
    });
  }
}
