import 'package:advertiser/features/campaign_creation/bloc/campaign_creation_bloc.dart';
import 'package:advertiser/features/campaign_creation/bloc/campaign_creation_event.dart';
import 'package:advertiser/features/campaign_creation/bloc/campaign_creation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/services/ad_campaign_service.dart';

import '../widgets/wizard_step_progress.dart';
import '../widgets/campaign_info_step.dart';
import '../widgets/campaign_creative_step.dart';
import '../widgets/campaign_schedule_step.dart';
import '../widgets/campaign_summary_step.dart';

class CreateCampaignWizard extends StatelessWidget {
  final AdCampaignService campaignService;
  final VoidCallback onComplete;

  const CreateCampaignWizard({
    super.key,
    required this.campaignService,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampaignCreationBloc(campaignService),
      child: _CreateCampaignWizardView(onComplete: onComplete),
    );
  }
}

class _CreateCampaignWizardView extends StatefulWidget {
  final VoidCallback onComplete;

  const _CreateCampaignWizardView({required this.onComplete});

  @override
  State<_CreateCampaignWizardView> createState() =>
      _CreateCampaignWizardViewState();
}

class _CreateCampaignWizardViewState extends State<_CreateCampaignWizardView> {
  final _formKeyInfo = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CampaignCreationBloc, CampaignCreationState>(
      listener: (context, state) {
        if (state.status == CampaignCreationStatus.success) {
          widget.onComplete();
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent),
          );
        } else if (state.snackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.snackMessage!)),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<CampaignCreationBloc>();
        final isLoading = state.status == CampaignCreationStatus.loading;
        final screenSize = MediaQuery.of(context).size;
        final isMobile = screenSize.width < 700;

        final dialogWidth = isMobile ? screenSize.width * 0.94 : 700.0;
        final dialogHeight = isMobile ? screenSize.height * 0.88 : 600.0;
        final horizontalPadding = isMobile ? 16.0 : 32.0;

        return Dialog(
          backgroundColor: backgroundColor,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 40,
            vertical: isMobile ? 16 : 40,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: dialogWidth,
            height: dialogHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Row(
                        children: [
                          const Icon(Icons.campaign_rounded,
                              color: primaryColor, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Create Ad Campaign',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 17 : 20,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.close, color: Colors.white60),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.white.withOpacity(0.06), height: 1),

                    // Step progress
                    WizardStepProgress(
                      currentStep: state.currentStep,
                      steps: const [
                        'Details',
                        'Creative',
                        'Schedule',
                        'Summary'
                      ],
                    ),

                    // Step content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding, vertical: 16),
                        child: SingleChildScrollView(
                          child: _buildStepContent(context, state, bloc),
                        ),
                      ),
                    ),

                    Divider(color: Colors.white.withOpacity(0.06), height: 1),

                    // Footer action buttons
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (state.currentStep > 0)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.white.withOpacity(0.2)),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 16 : 24,
                                    vertical: isMobile ? 12 : 16),
                              ),
                              onPressed: () =>
                                  bloc.add(const PreviousStepEvent()),
                              child: const Text('Back'),
                            )
                          else
                            const SizedBox.shrink(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 20 : 24,
                                  vertical: isMobile ? 12 : 16),
                            ),
                            onPressed: () =>
                                _onNextPressed(context, state, bloc),
                            child: Text(state.currentStep == 3
                                ? 'Submit Request'
                                : 'Continue'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: SpinKitThreeBounce(color: primaryColor, size: 30),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onNextPressed(BuildContext context, CampaignCreationState state,
      CampaignCreationBloc bloc) {
    if (state.currentStep == 0) {
      if (_formKeyInfo.currentState!.validate()) {
        bloc.add(const NextStepEvent());
      }
    } else if (state.currentStep == 1) {
      if (state.uploadedMediaUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please upload the creative file first.')),
        );
      } else {
        bloc.add(const NextStepEvent());
      }
    } else if (state.currentStep == 2) {
      if (state.dateRange == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date range.')),
        );
      } else {
        bloc.add(const NextStepEvent());
      }
    } else {
      bloc.add(SubmitCampaignEvent(
        title: _titleController.text,
        caption: _captionController.text,
      ));
    }
  }

  Widget _buildStepContent(BuildContext context, CampaignCreationState state,
      CampaignCreationBloc bloc) {
    switch (state.currentStep) {
      case 0:
        return CampaignInfoStep(
          formKey: _formKeyInfo,
          titleController: _titleController,
          captionController: _captionController,
          selectedOrg: state.selectedOrg,
          organizations: state.organizations,
          onOrgChanged: (org) => bloc.add(SelectOrganizationEvent(org)),
        );
      case 1:
        return CampaignCreativeStep(
          pickedFile: state.pickedFile,
          mediaType: state.mediaType,
          isUploading: state.isUploading,
          uploadedMediaUrl: state.uploadedMediaUrl,
          onPickFile: () => bloc.add(const PickFileEvent()),
          onUploadMedia: () => bloc.add(const UploadMediaEvent()),
          onRemoveFile: () => bloc.add(const RemoveFileEvent()),
        );
      case 2:
        return CampaignScheduleStep(
          dateRange: state.dateRange,
          startTime: state.startTime,
          endTime: state.endTime,
          selectedDays: state.selectedDays,
          onSelectDateRange: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: primaryColor,
                    surface: cardBackgroundColor,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) bloc.add(SetDateRangeEvent(picked));
          },
          onSelectStartTime: () async {
            final time = await showTimePicker(
                context: context, initialTime: state.startTime);
            if (time != null) bloc.add(SetStartTimeEvent(time));
          },
          onSelectEndTime: () async {
            final time = await showTimePicker(
                context: context, initialTime: state.endTime);
            if (time != null) bloc.add(SetEndTimeEvent(time));
          },
          onToggleDay: (dayInt) => bloc.add(ToggleDayEvent(dayInt)),
        );
      case 3:
        return CampaignSummaryStep(
          uploadedMediaUrl: state.uploadedMediaUrl,
          mediaType: state.mediaType,
          title: _titleController.text,
          organizationName: state.selectedOrg?.name ?? '',
          dateRange: state.dateRange,
          startTime: state.startTime,
          endTime: state.endTime,
          frequencyMinutes: state.frequencyMinutes,
          displayDuration: state.displayDuration,
          calculatedBudget: state.calculatedBudget,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
