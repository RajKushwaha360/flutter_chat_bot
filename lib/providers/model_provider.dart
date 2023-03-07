import 'package:flutter/cupertino.dart';

class ModelsProvider with ChangeNotifier {
  String modelId = 'gpt-3.5-turbo';


  double temperature = 0.8;

  double get getTemperature {
    return temperature;
  }

  void setTemperature(double newValue) {
    temperature = newValue;
    notifyListeners();
  }

}
