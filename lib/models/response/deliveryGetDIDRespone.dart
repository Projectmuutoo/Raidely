// To parse this JSON data, do
//
//     final deliveryAllGetDidResponse = deliveryAllGetDidResponseFromJson(jsonString);

import 'dart:convert';

DeliveryAllGetDidResponse deliveryAllGetDidResponseFromJson(String str) =>
    DeliveryAllGetDidResponse.fromJson(json.decode(str));

String deliveryAllGetDidResponseToJson(DeliveryAllGetDidResponse data) =>
    json.encode(data.toJson());

class DeliveryAllGetDidResponse {
  int did;
  int senderId;
  int receiverId;
  String itemName;
  String image;
  String status;
  String riderReceive;
  String riderSuccess;
  String senderName;
  String senderPhone;
  String senderAddress;
  String senderGps;
  String senderImageMember;
  String receiverName;
  String receiverPhone;
  String receiverAddress;
  String receiverGps;
  String receiverImageMember;

  DeliveryAllGetDidResponse({
    required this.did,
    required this.senderId,
    required this.receiverId,
    required this.itemName,
    required this.image,
    required this.status,
    required this.riderReceive,
    required this.riderSuccess,
    required this.senderName,
    required this.senderPhone,
    required this.senderAddress,
    required this.senderGps,
    required this.senderImageMember,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.receiverGps,
    required this.receiverImageMember,
  });

  factory DeliveryAllGetDidResponse.fromJson(Map<String, dynamic> json) =>
      DeliveryAllGetDidResponse(
        did: json["did"],
        senderId: json["sender_id"],
        receiverId: json["receiver_id"],
        itemName: json["item_name"],
        image: json["image"],
        status: json["status"],
        riderReceive: json["rider_receive"],
        riderSuccess: json["rider_success"],
        senderName: json["sender_name"],
        senderPhone: json["sender_phone"],
        senderAddress: json["sender_address"],
        senderGps: json["sender_gps"],
        senderImageMember: json["sender_image_member"],
        receiverName: json["receiver_name"],
        receiverPhone: json["receiver_phone"],
        receiverAddress: json["receiver_address"],
        receiverGps: json["receiver_gps"],
        receiverImageMember: json["receiver_image_member"],
      );

  Map<String, dynamic> toJson() => {
        "did": did,
        "sender_id": senderId,
        "receiver_id": receiverId,
        "item_name": itemName,
        "image": image,
        "status": status,
        "rider_receive": riderReceive,
        "rider_success": riderSuccess,
        "sender_name": senderName,
        "sender_phone": senderPhone,
        "sender_address": senderAddress,
        "sender_gps": senderGps,
        "sender_image_member": senderImageMember,
        "receiver_name": receiverName,
        "receiver_phone": receiverPhone,
        "receiver_address": receiverAddress,
        "receiver_gps": receiverGps,
        "receiver_image_member": receiverImageMember,
      };
}
