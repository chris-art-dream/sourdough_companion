class RunningTimer {
  final String recipeTitle;
  final int stepIndex;
  final int endTimestamp;

  RunningTimer({
    required this.recipeTitle,
    required this.stepIndex,
    required this.endTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipeTitle': recipeTitle,
      'stepIndex': stepIndex,
      'endTimestamp': endTimestamp,
    };
  }

  factory RunningTimer.fromJson(Map<String, dynamic> json) {
    return RunningTimer(
      recipeTitle: json['recipeTitle'],
      stepIndex: json['stepIndex'],
      endTimestamp: json['endTimestamp'],
    );
  }
}
