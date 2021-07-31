import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChromecastPlayerSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const ChromecastPlayerSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _ChromecastPlayerSliderState createState() => _ChromecastPlayerSliderState();
}

class _ChromecastPlayerSliderState extends State<ChromecastPlayerSlider> {
  double? _interactionValue;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _interactionValue ?? widget.value,
      min: widget.min,
      max: widget.max,
      onChangeStart: _onChangeStart,
      onChangeEnd: _onChangeEnd,
      onChanged: _onChange,
    );
  }

  void _onChangeStart(double value) {
    setState(() => _interactionValue = value);
  }

  void _onChange(double value) {
    setState(() => _interactionValue = value);
  }

  void _onChangeEnd(double value) {
    widget.onChanged(value);
    setState(() => _interactionValue = null);
  }
}
