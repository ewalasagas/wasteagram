import 'package:flutter/material.dart';

// ignore: missing_return, camel_case_types
class validateform{
  final formKey = new GlobalKey<FormState>();

  bool validateAndSave() {
    final form = formKey.currentState;

    if(form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
