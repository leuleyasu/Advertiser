import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/ad_campaign_service.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final AdCampaignService _campaignService;

  DashboardCubit(this._campaignService) : super(const DashboardState());

  Future<void> loadMetrics() async {
    emit(state.copyWith(isLoading: true));
    try {
      final metrics = await _campaignService.fetchMetrics();
      emit(state.copyWith(isLoading: false, metrics: metrics));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load metrics: $e',
      ));
    }
  }
}
