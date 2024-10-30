import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String id;
  String message;
  String senderId;
  DateTime sendingTime;

  MessageModel({
    required this.id,
    required this.message,
    required this.senderId,
    required this.sendingTime,
  });


  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      message: data['message'],
      senderId: data['senderId'],
      sendingTime: (data['sendingTime'] as Timestamp).toDate(),
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderId': senderId,
      'sendingTime': Timestamp.fromDate(sendingTime),
    };
  }
}
