import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/services/ad_campaign_service.dart';
import '../../../core/utils/campaign_calculator_utils.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/media_utils.dart';
import 'campaign_creation_event.dart';
import 'campaign_creation_state.dart';

class CampaignCreationBloc extends Bloc<CampaignCreationEvent, CampaignCreationState> {
  final AdCampaignService _campaignService;
  StreamSubscription<List<Organization>>? _orgSubscription;

  CampaignCreationBloc(this._campaignService) : super(const CampaignCreationState()) {
    on<LoadOrganizationsEvent>(_onLoadOrganizations);
    on<OrganizationsUpdatedEvent>(_onOrganizationsUpdated);
    on<SelectOrganizationEvent>(_onSelectOrganization);
    on<PickFileEvent>(_onPickFile);
    on<RemoveFileEvent>(_onRemoveFile);
    on<UploadMediaEvent>(_onUploadMedia);
    on<SetDateRangeEvent>(_onSetDateRange);
    on<SetStartTimeEvent>(_onSetStartTime);
    on<SetEndTimeEvent>(_onSetEndTime);
    on<ToggleDayEvent>(_onToggleDay);
    on<NextStepEvent>(_onNextStep);
    on<PreviousStepEvent>(_onPreviousStep);
    on<SubmitCampaignEvent>(_onSubmitCampaign);

    add(const LoadOrganizationsEvent());
  }

  void _onLoadOrganizations(LoadOrganizationsEvent event, Emitter<CampaignCreationState> emit) {
    _orgSubscription?.cancel();
    _orgSubscription = _campaignService.streamOrganizations().listen((orgs) {
      add(OrganizationsUpdatedEvent(orgs));
    });
  }

  void _onOrganizationsUpdated(OrganizationsUpdatedEvent event, Emitter<CampaignCreationState> emit) {
    final selected = state.selectedOrg ?? (event.organizations.isNotEmpty ? event.organizations.first : null);
    final newState = state.copyWith(
      organizations: event.organizations,
      selectedOrg: selected,
    );
    emit(_recalculateBudget(newState));
  }

  void _onSelectOrganization(SelectOrganizationEvent event, Emitter<CampaignCreationState> emit) {
    final newState = state.copyWith(selectedOrg: event.organization);
    emit(_recalculateBudget(newState));
  }

  Future<void> _onPickFile(PickFileEvent event, Emitter<CampaignCreationState> emit) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final mediaType = MediaUtils.resolveMediaType(file.extension);
        emit(state.copyWith(
          pickedFile: file,
          mediaType: mediaType,
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error picking file: $e'));
    }
  }

  void _onRemoveFile(RemoveFileEvent event, Emitter<CampaignCreationState> emit) {
    emit(state.copyWith(
      clearPickedFile: true,
      clearUploadedMediaUrl: true,
    ));
  }

  Future<void> _onUploadMedia(UploadMediaEvent event, Emitter<CampaignCreationState> emit) async {
    if (state.pickedFile == null || state.pickedFile!.bytes == null) return;
    emit(state.copyWith(isUploading: true));

    try {
      final mimeType = MediaUtils.resolveMimeType(state.mediaType, state.pickedFile!.extension);

      final url = await _campaignService.uploadAdMedia(
        fileName: state.pickedFile!.name,
        fileBytes: state.pickedFile!.bytes!,
        mimeType: mimeType,
      );

      emit(state.copyWith(
        uploadedMediaUrl: url,
        isUploading: false,
        snackMessage: 'Creative uploaded successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isUploading: false,
        errorMessage: 'Upload failed: $e',
      ));
    }
  }

  void _onSetDateRange(SetDateRangeEvent event, Emitter<CampaignCreationState> emit) {
    final newState = state.copyWith(dateRange: event.dateRange);
    emit(_recalculateBudget(newState));
  }

  void _onSetStartTime(SetStartTimeEvent event, Emitter<CampaignCreationState> emit) {
    final newState = state.copyWith(startTime: event.startTime);
    emit(_recalculateBudget(newState));
  }

  void _onSetEndTime(SetEndTimeEvent event, Emitter<CampaignCreationState> emit) {
    final newState = state.copyWith(endTime: event.endTime);
    emit(_recalculateBudget(newState));
  }

  void _onToggleDay(ToggleDayEvent event, Emitter<CampaignCreationState> emit) {
    final updatedDays = List<int>.from(state.selectedDays);
    if (updatedDays.contains(event.dayInt)) {
      updatedDays.remove(event.dayInt);
    } else {
      updatedDays.add(event.dayInt);
    }
    final newState = state.copyWith(selectedDays: updatedDays);
    emit(_recalculateBudget(newState));
  }

  void _onNextStep(NextStepEvent event, Emitter<CampaignCreationState> emit) {
    if (state.currentStep < 3) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPreviousStep(PreviousStepEvent event, Emitter<CampaignCreationState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> _onSubmitCampaign(SubmitCampaignEvent event, Emitter<CampaignCreationState> emit) async {
    if (event.title.isEmpty ||
        event.caption.isEmpty ||
        state.selectedOrg == null ||
        state.uploadedMediaUrl == null ||
        state.dateRange == null) {
      emit(state.copyWith(errorMessage: 'Please complete all steps before submitting.'));
      return;
    }

    emit(state.copyWith(status: CampaignCreationStatus.loading));

    try {
      final startStr = FormatUtils.formatTimeOfDay24(state.startTime);
      final endStr = FormatUtils.formatTimeOfDay24(state.endTime);

      await _campaignService.createCampaign(
        title: event.title.trim(),
        caption: event.caption.trim(),
        organizationId: state.selectedOrg!.id,
        organizationName: state.selectedOrg!.name,
        mediaUrl: state.uploadedMediaUrl!,
        mediaType: state.mediaType,
        startDate: state.dateRange!.start,
        endDate: state.dateRange!.end,
        daysOfWeek: state.selectedDays,
        startTime: startStr,
        endTime: endStr,
        displayDurationSeconds: state.displayDuration,
        frequencyMinutes: state.frequencyMinutes,
        budget: state.calculatedBudget,
      );

      emit(state.copyWith(status: CampaignCreationStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: CampaignCreationStatus.failure,
        errorMessage: 'Submission failed: $e',
      ));
    }
  }

  CampaignCreationState _recalculateBudget(CampaignCreationState stateToUpdate) {
    final budget = CampaignCalculatorUtils.calculateBudget(
      dateRange: stateToUpdate.dateRange,
      startTime: stateToUpdate.startTime,
      endTime: stateToUpdate.endTime,
      selectedDays: stateToUpdate.selectedDays,
      frequencyMinutes: stateToUpdate.frequencyMinutes,
      mediaType: stateToUpdate.mediaType,
      displayDurationSeconds: stateToUpdate.displayDuration,
    );
    return stateToUpdate.copyWith(calculatedBudget: budget);
  }

  @override
  Future<void> close() {
    _orgSubscription?.cancel();
    return super.close();
  }
}
