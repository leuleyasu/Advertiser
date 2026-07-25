import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/organization_model.dart';
import '../../../../core/services/ad_campaign_service.dart';

class CreateCampaignWizard extends StatefulWidget {
  final AdCampaignService campaignService;
  final VoidCallback onComplete;

  const CreateCampaignWizard({
    super.key,
    required this.campaignService,
    required this.onComplete,
  });

  @override
  State<CreateCampaignWizard> createState() => _CreateCampaignWizardState();
}

class _CreateCampaignWizardState extends State<CreateCampaignWizard> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Info & Org
  final _formKeyInfo = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();
  Organization? _selectedOrg;
  List<Organization> _organizations = [];

  // Step 2: Media Creative
  PlatformFile? _pickedFile;
  bool _isUploading = false;
  String? _uploadedMediaUrl;
  String _mediaType = 'image'; // 'image' or 'video'

  // Step 3: Schedule
  DateTimeRange? _dateRange;
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 23, minute: 59);
  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // Mon = 1, Sun = 7
  int _displayDuration = 15; // 15 seconds
  int _frequencyMinutes = 15; // Every 15 mins

  // Step 4: Budget & Summary
  double _calculatedBudget = 0.0;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _loadOrganizations() {
    widget.campaignService.streamOrganizations().first.then((orgs) {
      setState(() {
        _organizations = orgs;
        if (orgs.isNotEmpty) {
          _selectedOrg = orgs.first;
        }
        _calculateBudget();
      });
    });
  }

  void _calculateBudget() {
    if (_dateRange == null) return;
    final totalDays = _dateRange!.end.difference(_dateRange!.start).inDays + 1;
    final activeDaysCount = _selectedDays.length;
    // Calculation: $0.10 per play
    // Hourly plays = 60 / frequency
    final hours = (_endTime.hour + _endTime.minute / 60) - (_startTime.hour + _startTime.minute / 60);
    final playsPerDay = (hours * 60) / _frequencyMinutes;
    final totalPlays = playsPerDay * totalDays * (activeDaysCount / 7);
    
    setState(() {
      _calculatedBudget = totalPlays * 0.10; // $0.10 per impression rate
      if (_calculatedBudget < 5.0) _calculatedBudget = 5.0; // Min budget
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
          _mediaType = _pickedFile!.extension == 'mp4' ? 'video' : 'image';
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _uploadMedia() async {
    if (_pickedFile == null || _pickedFile!.bytes == null) return;
    setState(() => _isUploading = true);

    try {
      final extension = _pickedFile!.extension ?? 'png';
      final mimeType = _mediaType == 'video' ? 'video/mp4' : 'image/$extension';
      
      final url = await widget.campaignService.uploadAdMedia(
        fileName: _pickedFile!.name,
        fileBytes: _pickedFile!.bytes!,
        mimeType: mimeType,
      );

      setState(() {
        _uploadedMediaUrl = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creative uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _submitCampaign() async {
    if (_titleController.text.isEmpty ||
        _captionController.text.isEmpty ||
        _selectedOrg == null ||
        _uploadedMediaUrl == null ||
        _dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all steps before submitting.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
      final endStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

      await widget.campaignService.createCampaign(
        title: _titleController.text.trim(),
        caption: _captionController.text.trim(),
        organizationId: _selectedOrg!.id,
        organizationName: _selectedOrg!.name,
        mediaUrl: _uploadedMediaUrl!,
        mediaType: _mediaType,
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        daysOfWeek: _selectedDays,
        startTime: startStr,
        endTime: endStr,
        displayDurationSeconds: _displayDuration,
        frequencyMinutes: _frequencyMinutes,
        budget: _calculatedBudget,
      );

      widget.onComplete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 700,
        height: 600,
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
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign_rounded, color: primaryColor, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Create Ad Campaign',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white60),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.06), height: 1),

                // Step indicators
                _buildStepProgress(),

                // Step content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: _buildStepContent(),
                  ),
                ),

                Divider(color: Colors.white.withOpacity(0.06), height: 1),
                // Footer Buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          onPressed: () => setState(() => _currentStep--),
                          child: const Text('Back'),
                        )
                      else
                        const SizedBox.shrink(),
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        onPressed: () {
                          if (_currentStep == 0) {
                            if (_formKeyInfo.currentState!.validate()) {
                              setState(() => _currentStep++);
                            }
                          } else if (_currentStep == 1) {
                            if (_uploadedMediaUrl == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please upload the creative file first.')),
                              );
                            } else {
                              setState(() => _currentStep++);
                            }
                          } else if (_currentStep == 2) {
                            if (_dateRange == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a date range.')),
                              );
                            } else {
                              _calculateBudget();
                              setState(() => _currentStep++);
                            }
                          } else {
                            _submitCampaign();
                          }
                        },
                        child: Text(_currentStep == 3 ? 'Submit Request' : 'Continue'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (_isLoading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepProgress() {
    final steps = ['Details', 'Creative', 'Schedule', 'Summary'];
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
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
                    color: isCurrent ? primaryColor : (isActive ? primaryColor.withOpacity(0.4) : Colors.transparent),
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
                  width: 30,
                  height: 1.5,
                  color: index < _currentStep ? primaryColor : Colors.white.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStepInfo();
      case 1:
        return _buildStepCreative();
      case 2:
        return _buildStepSchedule();
      case 3:
        return _buildStepSummary();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepInfo() {
    return Form(
      key: _formKeyInfo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campaign Information',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Campaign Title (e.g. Summer Special Offer)'),
            validator: (v) => v != null && v.isNotEmpty ? null : 'Title is required',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _captionController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Ad Caption / Screen Text'),
            validator: (v) => v != null && v.isNotEmpty ? null : 'Caption is required',
          ),
          const SizedBox(height: 16),
          _organizations.isEmpty
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<Organization>(
                  value: _selectedOrg,
                  dropdownColor: cardBackgroundColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Target Organization / Venue'),
                  items: _organizations.map((org) {
                    return DropdownMenuItem<Organization>(
                      value: org,
                      child: Text('${org.name} (${org.businessType.toUpperCase()})'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedOrg = val),
                ),
        ],
      ),
    );
  }

  Widget _buildStepCreative() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Advertisement Creative',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload a banner image (JPEG/PNG) or a short video (MP4) to display on signage screen.',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              if (_pickedFile != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _mediaType == 'video' ? Icons.video_collection_rounded : Icons.image_rounded,
                        color: primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pickedFile!.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Size: ${(_pickedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => setState(() {
                          _pickedFile = null;
                          _uploadedMediaUrl = null;
                        }),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_uploadedMediaUrl == null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.08),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: _isUploading ? null : _uploadMedia,
                    icon: _isUploading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(_isUploading ? 'Uploading...' : 'Upload Media to Cloud'),
                  )
                else
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                      SizedBox(width: 8),
                      Text('Media verified & ready.', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ] else
                InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.none),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_rounded, size: 48, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text('Drag & Drop or Click to Select File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Supports PNG, JPG, MP4 (Max 15MB)', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepSchedule() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Display Scheduling',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Date Range
        InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: primaryColor,
                      surface: cardBackgroundColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _dateRange = picked;
                _calculateBudget();
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, color: primaryColor),
                const SizedBox(width: 12),
                Text(
                  _dateRange == null
                      ? 'Select Start & End Date'
                      : '${dateFormat.format(_dateRange!.start)} - ${dateFormat.format(_dateRange!.end)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.white60),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Time window selection
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Start Time', style: TextStyle(color: Colors.white60, fontSize: 12)),
                subtitle: Text(_startTime.format(context), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.access_time, color: primaryColor),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _startTime);
                  if (time != null) {
                    setState(() {
                      _startTime = time;
                      _calculateBudget();
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('End Time', style: TextStyle(color: Colors.white60, fontSize: 12)),
                subtitle: Text(_endTime.format(context), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.access_time, color: primaryColor),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _endTime);
                  if (time != null) {
                    setState(() {
                      _endTime = time;
                      _calculateBudget();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Weekdays selection
        const Text('Days of Week', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayInt = index + 1;
            final dayLabel = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];
            final isSelected = _selectedDays.contains(dayInt);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDays.remove(dayInt);
                  } else {
                    _selectedDays.add(dayInt);
                  }
                  _calculateBudget();
                });
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? primaryColor : Colors.white10),
                ),
                child: Center(
                  child: Text(
                    dayLabel,
                    style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepSummary() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campaign Summary & Budget Estimation',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Preview
              if (_uploadedMediaUrl != null && _mediaType == 'image')
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _uploadedMediaUrl!,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.video_collection, color: Colors.white55, size: 40),
                  ),
                ),
              const SizedBox(width: 24),
              // Schedule text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_titleController.text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Target Organization: ${_selectedOrg?.name ?? ""}',
                      style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    if (_dateRange != null)
                      Text(
                        'Dates: ${dateFormat.format(_dateRange!.start)} to ${dateFormat.format(_dateRange!.end)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    Text(
                      'Hours: ${_startTime.format(context)} - ${_endTime.format(context)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Frequency: Every $_frequencyMinutes minutes for $_displayDuration seconds',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ESTIMATED BUDGET', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '\$${_calculatedBudget.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }
}
