import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/models/organization_model.dart';

enum CampaignCreationStatus { initial, loading, success, failure }

class CampaignCreationState extends Equatable {
  final int currentStep;
  final CampaignCreationStatus status;
  final String? errorMessage;
  final String? snackMessage;

  // Step 1: Info & Org
  final Organization? selectedOrg;
  final List<Organization> organizations;

  // Step 2: Media Creative
  final PlatformFile? pickedFile;
  final bool isUploading;
  final String? uploadedMediaUrl;
  final String mediaType;

  // Step 3: Schedule
  final DateTimeRange? dateRange;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> selectedDays;
  final int displayDuration;
  final int frequencyMinutes;

  // Step 4: Budget
  final double calculatedBudget;

  const CampaignCreationState({
    this.currentStep = 0,
    this.status = CampaignCreationStatus.initial,
    this.errorMessage,
    this.snackMessage,
    this.selectedOrg,
    this.organizations = const [],
    this.pickedFile,
    this.isUploading = false,
    this.uploadedMediaUrl,
    this.mediaType = 'image',
    this.dateRange,
    this.startTime = const TimeOfDay(hour: 18, minute: 0),
    this.endTime = const TimeOfDay(hour: 23, minute: 59),
    this.selectedDays = const [1, 2, 3, 4, 5, 6, 7],
    this.displayDuration = 15,
    this.frequencyMinutes = 15,
    this.calculatedBudget = 0.0,
  });

  CampaignCreationState copyWith({
    int? currentStep,
    CampaignCreationStatus? status,
    String? errorMessage,
    String? snackMessage,
    Organization? selectedOrg,
    List<Organization>? organizations,
    PlatformFile? pickedFile,
    bool? isUploading,
    String? uploadedMediaUrl,
    String? mediaType,
    DateTimeRange? dateRange,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<int>? selectedDays,
    int? displayDuration,
    int? frequencyMinutes,
    double? calculatedBudget,
    bool clearPickedFile = false,
    bool clearUploadedMediaUrl = false,
  }) {
    return CampaignCreationState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage,
      snackMessage: snackMessage,
      selectedOrg: selectedOrg ?? this.selectedOrg,
      organizations: organizations ?? this.organizations,
      pickedFile: clearPickedFile ? null : (pickedFile ?? this.pickedFile),
      isUploading: isUploading ?? this.isUploading,
      uploadedMediaUrl: clearUploadedMediaUrl ? null : (uploadedMediaUrl ?? this.uploadedMediaUrl),
      mediaType: mediaType ?? this.mediaType,
      dateRange: dateRange ?? this.dateRange,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      selectedDays: selectedDays ?? this.selectedDays,
      displayDuration: displayDuration ?? this.displayDuration,
      frequencyMinutes: frequencyMinutes ?? this.frequencyMinutes,
      calculatedBudget: calculatedBudget ?? this.calculatedBudget,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        status,
        errorMessage,
        snackMessage,
        selectedOrg,
        organizations,
        pickedFile,
        isUploading,
        uploadedMediaUrl,
        mediaType,
        dateRange,
        startTime,
        endTime,
        selectedDays,
        displayDuration,
        frequencyMinutes,
        calculatedBudget,
      ];
}
