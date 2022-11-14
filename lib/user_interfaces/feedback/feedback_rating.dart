import '../../utils/utils.dart';
import 'package:flutter/material.dart';

import '../../styles/colors/colors.dart';

class FeedbackRating extends StatefulWidget {
  const FeedbackRating({
    super.key,
    this.initialValue,
    required this.onValueChanged,
  });

  final String? initialValue;
  final ValueChanged<String?> onValueChanged;

  @override
  State<FeedbackRating> createState() => _FeedbackRatingState();
}

class _FeedbackRatingState extends State<FeedbackRating> {
  String? value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: {'bad': '😔', 'okay': '😐', 'great': '😊'}
            .entries
            .map(
              (entry) => InkWell(
                onTap: () {
                  setState(() => value = entry.key);
                  widget.onValueChanged.call(value);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    border: entry.key == value
                        ? const Border.fromBorderSide(
                            BorderSide(color: AppColors.blueColor))
                        : null,
                  ),
                  height: 67,
                  width: 67,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(entry.value, style: const TextStyle(fontSize: 35)),
                      Text(entry.key.toCapitalized()),
                    ],
                  ),
                ),
              ),
            )
            .toList());
  }
}
