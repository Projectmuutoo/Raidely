// To parse this JSON data, do
//
//     final insertDeliveryPostRequest = insertDeliveryPostRequestFromJson(jsonString);

import 'dart:convert';

InsertDeliveryPostRequest insertDeliveryPostRequestFromJson(String str) =>
    InsertDeliveryPostRequest.fromJson(json.decode(str));

String insertDeliveryPostRequestToJson(InsertDeliveryPostRequest data) =>
    json.encode(data.toJson());

class InsertDeliveryPostRequest {
  int senderId;
  int receiverId;
  String itemName;
  String image;
  String status;

  InsertDeliveryPostRequest({
    required this.senderId,
    required this.receiverId,
    required this.itemName,
    required this.image,
    required this.status,
  });

  factory InsertDeliveryPostRequest.fromJson(Map<String, dynamic> json) =>
      InsertDeliveryPostRequest(
        senderId: json["sender_id"],
        receiverId: json["receiver_id"],
        itemName: json["item_name"],
        image: json["image"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "sender_id": senderId,
        "receiver_id": receiverId,
        "item_name": itemName,
        "image": image,
        "status": status,
      };
}
