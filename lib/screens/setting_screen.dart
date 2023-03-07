import 'package:ai_chat/providers/model_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/text_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ModelsProvider modelsProvider = Provider.of<ModelsProvider>(context);
    double sliderValue = modelsProvider.getTemperature;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const TextWidget(label: 'Randomness : '),
                TextWidget(label: sliderValue.toString()),
                const Expanded(
                  child: SizedBox(
                    width: 0,
                  ),
                ),
                Tooltip(
                  message:
                      'Higher values will give more random output,\nwhile lower values will make bot more focused and deterministic.',
                  triggerMode: TooltipTriggerMode.tap,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(10),
                  showDuration: const Duration(seconds: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            StatefulBuilder(
              builder: ((context, setState) {
                return Slider(
                  value: sliderValue,
                  max: 2,
                  min: 0,
                  inactiveColor: Colors.grey,
                  activeColor: Colors.white,
                  thumbColor: Colors.white,
                  label: sliderValue.toString(),
                  divisions: 200,
                  onChangeEnd: (value) {
                    modelsProvider.setTemperature(value);
                  },
                  onChanged: ((value) {
                    setState(
                      () {
                        sliderValue = value;
                      },
                    );
                  }),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
