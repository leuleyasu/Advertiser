import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../core/models/organization_model.dart';

abstract class CampaignCreationEvent extends Equatable {
  const CampaignCreationEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrganizationsEvent extends CampaignCreationEvent {
  const LoadOrganizationsEvent();
}

class OrganizationsUpdatedEvent extends CampaignCreationEvent {
  final List<Organization> organizations;
  const OrganizationsUpdatedEvent(this.organizations);

  @override
  List<Object?> get props => [organizations];
}

class SelectOrganizationEvent extends CampaignCreationEvent {
  final Organization? organization;
  const SelectOrganizationEvent(this.organization);

  @override
  List<Object?> get props => [organization];
}

class PickFileEvent extends CampaignCreationEvent {
  const PickFileEvent();
}

class RemoveFileEvent extends CampaignCreationEvent {
  const RemoveFileEvent();
}

class UploadMediaEvent extends CampaignCreationEvent {
  const UploadMediaEvent();
}

class SetDateRangeEvent extends CampaignCreationEvent {
  final DateTimeRange dateRange;
  const SetDateRangeEvent(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

class SetStartTimeEvent extends CampaignCreationEvent {
  final TimeOfDay startTime;
  const SetStartTimeEvent(this.startTime);

  @override
  List<Object?> get props => [startTime];
}

class SetEndTimeEvent extends CampaignCreationEvent {
  final TimeOfDay endTime;
  const SetEndTimeEvent(this.endTime);

  @override
  List<Object?> get props => [endTime];
}

class ToggleDayEvent extends CampaignCreationEvent {
  final int dayInt;
  const ToggleDayEvent(this.dayInt);

  @override
  List<Object?> get props => [dayInt];
}

class NextStepEvent extends CampaignCreationEvent {
  const NextStepEvent();
}

class PreviousStepEvent extends CampaignCreationEvent {
  const PreviousStepEvent();
}

class SubmitCampaignEvent extends CampaignCreationEvent {
  final String title;
  final String caption;

  const SubmitCampaignEvent({
    required this.title,
    required this.caption,
  });

  @override
  List<Object?> get props => [title, caption];
}
