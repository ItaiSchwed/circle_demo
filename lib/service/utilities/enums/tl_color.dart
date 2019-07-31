import 'dart:ui';

import 'package:flutter/material.dart';

enum TLColorEnum{
  GREEN, RED
}

class TLColor{
  TLColorEnum value;
  TLColor(this.value);
  Color getColor(){
    switch(value){
      case TLColorEnum.GREEN:
        return Color.fromARGB(100, 52, 185, 57);
      case TLColorEnum.RED:
        return Colors.red;
    }
  }
}