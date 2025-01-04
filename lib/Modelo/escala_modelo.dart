import 'package:cloud_firestore/cloud_firestore.dart';

class EscalaModelo {
  String id;
  String porta01;
  String banheiroFeminino;
  String primeiraHoraPulpito;
  String segundaHoraPulpito;
  String primeiraHoraEntrada;
  String segundaHoraEntrada;
  String recolherOferta;
  String uniforme;
  String mesaApoio;
  String servirSantaCeia;
  String dataCulto;
  String horarioTroca;
  String irmaoReserva;


  EscalaModelo(
      {this.id = "",
      required this.porta01,
      required this.banheiroFeminino,
      required this.primeiraHoraPulpito,
      required this.segundaHoraPulpito,
      required this.primeiraHoraEntrada,
      required this.segundaHoraEntrada,
      required this.recolherOferta,
      required this.uniforme,
      required this.mesaApoio,
      required this.servirSantaCeia,
      required this.dataCulto,
      required this.horarioTroca,
      required this.irmaoReserva});

  factory EscalaModelo.fromJson(Map<dynamic, dynamic> json) {
    return EscalaModelo(
        porta01: json['porta01'] as String,
        banheiroFeminino: json['banheiroFeminino'] as String,
        primeiraHoraPulpito: json['primeiraHoraPulpito'] as String,
        segundaHoraPulpito: json['segundaHoraPulpito'] as String,
        primeiraHoraEntrada: json['primeiraHoraEntrada'] as String,
        segundaHoraEntrada: json['segundaHoraEntrada'] as String,
        recolherOferta: json['recolherOferta'] as String,
        uniforme: json['uniforme'] as String,
        mesaApoio: json['mesaApoio'] as String,
        servirSantaCeia: json['servirSantaCeia'] as String,
        dataCulto: json['dataCulto'] as String,
        horarioTroca: json['horarioTroca'] as String,
        irmaoReserva: json['irmaoReserva'] as String);
  }

  factory EscalaModelo.fromFirestore(
    DocumentSnapshot<Map<dynamic, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return EscalaModelo(
      porta01: data?['porta01'],
      banheiroFeminino: data?['banheiroFeminino'],
      primeiraHoraPulpito: data?['primeiraHoraPulpito'],
      segundaHoraPulpito: data?['segundaHoraPulpito'],
      primeiraHoraEntrada: data?['primeiraHoraEntrada'],
      segundaHoraEntrada: data?['segundaHoraEntrada'],
      recolherOferta: data?['recolherOferta'],
      uniforme: data?['uniforme'],
      mesaApoio: data?['mesaApoio'],
      servirSantaCeia: data?['servirSantaCeia'],
      dataCulto: data?['dataCulto'],
      horarioTroca: data?['horarioTroca'],
      irmaoReserva: data?['irmaoReserva'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "primeiraHoraPulpito": primeiraHoraPulpito,
      "segundaHoraPulpito": segundaHoraPulpito,
      "primeiraHoraEntrada": primeiraHoraEntrada,
      "segundaHoraEntrada": segundaHoraEntrada,
      "recolherOferta": recolherOferta,
      "mesaApoio": mesaApoio,
      "servirSantaCeia": servirSantaCeia,
      "dataCulto": dataCulto,
      "horarioTroca": horarioTroca,
      "irmaoReserva": irmaoReserva,
    };
  }
}
