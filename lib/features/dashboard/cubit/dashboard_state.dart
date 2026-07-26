import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  final bool isLoading;
  final Map<String, dynamic> metrics;
  final String? errorMessage;

  const DashboardState({
    this.isLoading = false,
    this.metrics = const {
      'totalCampaigns': 0,
      'activeCampaigns': 0,
      'budgetSpent': 0.0,
      'totalImpressions': 0,
    },
    this.errorMessage,
  });

  DashboardState copyWith({
    bool? isLoading,
    Map<String, dynamic>? metrics,
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      metrics: metrics ?? this.metrics,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, metrics, errorMessage];
}
