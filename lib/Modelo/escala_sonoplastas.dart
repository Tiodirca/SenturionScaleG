import 'package:cloud_firestore/cloud_firestore.dart';

class EscalaSonoplatasModelo {
  String id;
  String dataCulto;
  String notebook;
  String mesaSom;
  String irmaoReserva;

  EscalaSonoplatasModelo({
    this.id = "",
    required this.dataCulto,
    required this.notebook,
    required this.mesaSom,
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
      dataCulto: data?['dataCulto'],
      irmaoReserva: data?['irmaoReserva'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "notebook": notebook,
      "mesaSom": mesaSom,
      "dataCulto": dataCulto,
      "irmaoReserva": irmaoReserva,
    };
  }
}
