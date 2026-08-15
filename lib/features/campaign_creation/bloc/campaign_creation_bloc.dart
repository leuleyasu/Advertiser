import 'dart:async';
import 'package:flutter/material.dart';
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
  final Organization? initialOrg;
  final List<Organization>? initialOrgs;
  StreamSubscription<List<Organization>>? _orgSubscription;

  CampaignCreationBloc(
    this._campaignService, {
    this.initialOrg,
    this.initialOrgs,
  }) : super(CampaignCreationState(
          selectedOrgs: initialOrgs ?? (initialOrg != null ? [initialOrg] : const []),
        )) {
    on<LoadOrganizationsEvent>(_onLoadOrganizations);
    on<OrganizationsUpdatedEvent>(_onOrganizationsUpdated);
    on<SelectOrganizationEvent>(_onSelectOrganization);
    on<ToggleOrganizationEvent>(_onToggleOrganization);
    on<SelectAllOrganizationsEvent>(_onSelectAllOrganizations);
    on<DeselectAllOrganizationsEvent>(_onDeselectAllOrganizations);
    on<SelectOrganizationsListEvent>(_onSelectOrganizationsList);
    on<PickFileEvent>(_onPickFile);
    on<RemoveFileEvent>(_onRemoveFile);
    on<UploadMediaEvent>(_onUploadMedia);
    on<SelectPackageTierEvent>(_onSelectPackageTier);
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
    List<Organization> updatedSelected = [];

    if (state.selectedOrgs.isNotEmpty) {
      for (final selected in state.selectedOrgs) {
        final match = event.organizations.where((o) => o.id == selected.id).firstOrNull;
        if (match != null) {
          updatedSelected.add(match);
        }
      }
    }

    // Default to first org if none selected and orgs available
    if (updatedSelected.isEmpty && event.organizations.isNotEmpty) {
      updatedSelected = [event.organizations.first];
    }

    TimeOfDay? start;
    TimeOfDay? end;
    if (updatedSelected.isNotEmpty) {
      final firstOrg = updatedSelected.first;
      start = _parseTimeString(firstOrg.effectiveStartTime, state.startTime);
      end = _parseTimeString(firstOrg.effectiveEndTime, state.endTime);
    }

    final newState = state.copyWith(
      organizations: event.organizations,
      selectedOrgs: updatedSelected,
      startTime: start ?? state.startTime,
      endTime: end ?? state.endTime,
    );
    emit(_recalculateBudget(newState));
  }

  void _onSelectOrganization(SelectOrganizationEvent event, Emitter<CampaignCreationState> emit) {
    final selected = event.organization != null ? [event.organization!] : <Organization>[];
    TimeOfDay? start;
    TimeOfDay? end;
    if (selected.isNotEmpty) {
      start = _parseTimeString(selected.first.effectiveStartTime, state.startTime);
      end = _parseTimeString(selected.first.effectiveEndTime, state.endTime);
    }

    final newState = state.copyWith(
      selectedOrgs: selected,
      startTime: start ?? state.startTime,
      endTime: end ?? state.endTime,
    );
    emit(_recalculateBudget(newState));
  }

  void _onToggleOrganization(ToggleOrganizationEvent event, Emitter<CampaignCreationState> emit) {
    final currentList = List<Organization>.from(state.selectedOrgs);
    final existsIndex = currentList.indexWhere((o) => o.id == event.organization.id);

    if (existsIndex >= 0) {
      currentList.removeAt(existsIndex);
    } else {
      currentList.add(event.organization);
    }

    TimeOfDay? start;
    TimeOfDay? end;
    if (currentList.isNotEmpty) {
      start = _parseTimeString(currentList.first.effectiveStartTime, state.startTime);
      end = _parseTimeString(currentList.first.effectiveEndTime, state.endTime);
    }

    final newState = state.copyWith(
      selectedOrgs: currentList,
      startTime: start ?? state.startTime,
      endTime: end ?? state.endTime,
    );
    emit(_recalculateBudget(newState));
  }

  void _onSelectAllOrganizations(SelectAllOrganizationsEvent event, Emitter<CampaignCreationState> emit) {
    final newState = state.copyWith(selectedOrgs: List.from(state.organizations));
    emit(_recalculateBudget(newState));
  }

  void _onDeselectAllOrganizations(DeselectAllOrganizationsEvent event, Emitter<CampaignCreationState> emit) {
    final newState = state.copyWith(selectedOrgs: const []);
    emit(_recalculateBudget(newState));
  }

  void _onSelectOrganizationsList(SelectOrganizationsListEvent event, Emitter<CampaignCreationState> emit) {
    final newState = state.copyWith(selectedOrgs: event.organizations);
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

  void _onSelectPackageTier(SelectPackageTierEvent event, Emitter<CampaignCreationState> emit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTimeRange? newRange;

    switch (event.packageTier) {
      case 'weekly':
        newRange = DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 7)),
        );
        break;
      case 'monthly':
        newRange = DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 30)),
        );
        break;
      case 'quarterly':
        newRange = DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 90)),
        );
        break;
      case 'custom':
      default:
        newRange = state.dateRange ??
            DateTimeRange(
              start: today,
              end: today.add(const Duration(days: 14)),
            );
        break;
    }

    final newState = state.copyWith(
      packageTier: event.packageTier,
      dateRange: newRange,
    );
    emit(_recalculateBudget(newState));
  }

  void _onSetDateRange(SetDateRangeEvent event, Emitter<CampaignCreationState> emit) {
    final newState = state.copyWith(
      dateRange: event.dateRange,
      packageTier: 'custom',
    );
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
        state.selectedOrgs.isEmpty ||
        state.uploadedMediaUrl == null ||
        state.dateRange == null) {
      emit(state.copyWith(errorMessage: 'Please complete all steps and select at least one venue before submitting.'));
      return;
    }

    emit(state.copyWith(status: CampaignCreationStatus.loading));

    try {
      final startStr = FormatUtils.formatTimeOfDay24(state.startTime);
      final endStr = FormatUtils.formatTimeOfDay24(state.endTime);

      await _campaignService.createMultiVenueCampaign(
        title: event.title.trim(),
        caption: event.caption.trim(),
        targetOrganizations: state.selectedOrgs,
        mediaUrl: state.uploadedMediaUrl!,
        mediaType: state.mediaType,
        packageTier: state.packageTier,
        startDate: state.dateRange!.start,
        endDate: state.dateRange!.end,
        daysOfWeek: state.selectedDays,
        startTime: startStr,
        endTime: endStr,
        displayDurationSeconds: state.displayDuration,
        frequencyMinutes: state.frequencyMinutes,
        totalBudget: state.calculatedBudget,
      );

      emit(state.copyWith(status: CampaignCreationStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: CampaignCreationStatus.failure,
        errorMessage: 'Submission failed: $e',
      ));
    }
  }

  TimeOfDay _parseTimeString(String timeStr, TimeOfDay fallback) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0].trim()),
        minute: int.parse(parts[1].trim()),
      );
    } catch (_) {
      return fallback;
    }
  }

  CampaignCreationState _recalculateBudget(CampaignCreationState stateToUpdate) {
    final budget = CampaignCalculatorUtils.calculateBudget(
      dateRange: stateToUpdate.dateRange,
      startTime: stateToUpdate.startTime,
      endTime: stateToUpdate.endTime,
      selectedDays: stateToUpdate.selectedDays,
      frequencyMinutes: stateToUpdate.frequencyMinutes,
      selectedOrgs: stateToUpdate.selectedOrgs,
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
