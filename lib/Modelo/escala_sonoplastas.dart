import 'package:cloud_firestore/cloud_firestore.dart';

class EscalaSonoplatasModelo {
  String id;
  String dataCulto;
  String notebook;
  String horarioTroca;
  String mesaSom;
  String videos;
  String irmaoReserva;

  EscalaSonoplatasModelo({
    this.id = "",
    required this.dataCulto,
    required this.notebook,
    required this.mesaSom,
    required this.videos,
    required this.horarioTroca,
    required this.irmaoReserva,
  });

  factory EscalaSonoplatasModelo.fromFirestore(
    DocumentSnapshot<Map<dynamic, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return EscalaSonoplatasModelo(
      notebook: data?['notebook'],
      mesaSom: data?['mesaSom'],
      videos: data?["videos"],
      horarioTroca: data?['horarioTroca'],
      dataCulto: data?['dataCulto'],
      irmaoReserva: data?['irmaoReserva'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "notebook": notebook,
      "mesaSom": mesaSom,
      "videos" : videos,
      "horarioTroca" : horarioTroca,
      "dataCulto": dataCulto,
      "irmaoReserva": irmaoReserva,
    };
  }
}
