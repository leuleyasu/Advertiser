import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';

class WizardStepProgress extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const WizardStepProgress({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length, (index) {
          final isActive = index <= currentStep;
          final isCurrent = index == currentStep;
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? primaryColor
                      : (isActive ? primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? primaryColor
                        : (isActive ? primaryColor.withOpacity(0.4) : Colors.transparent),
                  ),
                ),
                child: Text(
                  '${index + 1}. ${steps[index]}',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white60,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
              if (index < steps.length - 1)
                Container(
                  width: 20,
                  height: 1.5,
                  color: index < currentStep ? primaryColor : Colors.white.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),
            ],
          );
        }),
      ),
    );
  }
}
