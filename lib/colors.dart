import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

List<MaterialColor> colors = [
  Colors.pink,
  Colors.red,
  Colors.deepOrange,
  Colors.orange,
  Colors.amber,
  Colors.yellow,
  Colors.lime,
  Colors.lightGreen,
  Colors.green,
  Colors.teal,
  Colors.cyan,
  Colors.lightBlue,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
  Colors.deepPurple,
  Colors.blueGrey,
  Colors.brown,
  Colors.grey
];
List<int> colorCodes = [
  50,
  100,
  200,
  300,
  400,
  600,
  700,
  800,
  900,
];

class ColorsUtility {
  int selectedColorCode = 0;
  MaterialColor selectedRandColor;
  randomColor() {
    var random = new Random();
    final rand = random.nextInt(colors.length);
    final rand2 = random.nextInt(colorCodes.length);
    selectedRandColor = colors[rand];
    final int colorCode = colorCodes[rand2];
    selectedColorCode = colorCode;
  }

  static Color getColorForString(String color, int colorCode) {
    if(color == 'white'){
      return Colors.white;
    }
    if (color == 'pink') {
      if(colorCode == 0){
           return Colors.pink;     
      }
      return Colors.pink[colorCode];
    }
    if (color == 'red') {
      if(colorCode == 0){
           return Colors.red;     
      }
      return Colors.red[colorCode];
    }
    if (color == 'deepOrange') {
      if(colorCode == 0){
           return Colors.deepOrange;     
      }
      return Colors.deepOrange[colorCode];
    }
    if (color == 'orange') {
      if(colorCode == 0){
           return Colors.orange;     
      }
      return Colors.orange[colorCode];
    }
    if (color == 'amber') {
      if(colorCode == 0){
           return Colors.amber;     
      }
      return Colors.amber[colorCode];
    }
    if (color == 'yellow') {
      if(colorCode == 0){
           return Colors.yellow;     
      }
      return Colors.yellow[colorCode];
    }
    if (color == 'lime') {
      if(colorCode == 0){
           return Colors.lime;     
      }
      return Colors.lime[colorCode];
    }
    if (color == 'lightGreen') {
      if(colorCode == 0){
           return Colors.lightGreen;     
      }
      return Colors.lightGreen[colorCode];
    }
    if (color == 'green') {
      if(colorCode == 0){
           return Colors.green;     
      }
      return Colors.green[colorCode];
    }
    if (color == 'teal') {
      if(colorCode == 0){
           return Colors.teal;     
      }
      return Colors.teal[colorCode];
    }
    if (color == 'cyan') {
      if(colorCode == 0){
           return Colors.cyan;     
      }
      return Colors.cyan[colorCode];
    }
    if (color == 'lightBlue') {
      if(colorCode == 0){
           return Colors.lightBlue;     
      }
      return Colors.lightBlue[colorCode];
    }
    if (color == 'blue') {
      if(colorCode == 0){
           return Colors.blue;     
      }
      return Colors.blue[colorCode];
    }
    if (color == 'indigo') {
      if(colorCode == 0){
           return Colors.indigo;     
      }
      return Colors.indigo[colorCode];
    }
    if (color == 'purple') {
      if(colorCode == 0){
           return Colors.purple;     
      }
      return Colors.purple[colorCode];
    }
    if (color == 'deepPurple') {
      if(colorCode == 0){
           return Colors.deepPurple;     
      }
      return Colors.deepPurple[colorCode];
    }
    if (color == 'blueGrey') {
      if(colorCode == 0){
           return Colors.blueGrey;     
      }
      return Colors.blueGrey[colorCode];
    }
    if (color == 'brown') {
      if(colorCode == 0){
           return Colors.brown;     
      }
      return Colors.brown[colorCode];
    }
    if (color == 'grey') {
      if(colorCode == 0){
           return Colors.grey;     
      }
      return Colors.grey[colorCode];
    }
    return null;
  }
  static String getStringForColor(Color color) {
    if(color == Colors.white){
      return 'white';
    }
    if (color == Colors.pink) {
      return 'pink';
    }
    if (color == Colors.red) {
      return 'red';
    }
    if (color == Colors.deepOrange) {
      return 'deepOrange';
    }
    if (color == Colors.orange) {
      return 'orange';
    }
    if (color == Colors.amber) {
      return 'amber';
    }
    if (color == Colors.yellow) {
      return 'yellow';
    }
    if (color == Colors.lime) {
      return 'lime';
    }
    if (color == Colors.lightGreen) {
      return 'lightGreen';
    }
    if (color == Colors.green) {
      return 'green';
    }
    if (color == Colors.teal) {
      return 'teal';
    }
    if (color == Colors.cyan) {
      return 'cyan';
    }
    if (color == Colors.lightBlue) {
      return 'lightBlue';
    }
    if (color == Colors.blue) {
      return 'blue';
    }
    if (color == Colors.indigo) {
      return 'indigo';
    }
    if (color == Colors.purple) {
      return 'purple';
    }
    if (color == Colors.deepPurple) {
      return 'deepPurple';
    }
    if (color == Colors.blueGrey) {
      return 'blueGrey';
    }
    if (color == Colors.brown) {
      return 'brown';
    }
    if (color == Colors.grey) {
      return 'grey';
    }
    return null;
  }
}
