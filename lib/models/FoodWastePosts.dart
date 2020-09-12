import 'package:flutter/material.dart';

class Posts{
  //specify db keys
  // ignore: non_constant_identifier_names
  String date, time, quantity, image, latitude, longitude;
  //double quantity;

  Posts(
      this.date,
      this.time,
      this.image,
      this.quantity,
      this.latitude,
      this.longitude
      );
}