import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/leave.dart';
import '../providers/leave_providers.dart';

/// "Add Leave" form (Figma "Single leave page" 76:6256): Leave Type dropdown,
/// Leave Mode radio, date picker, reason textarea, file attachments and the
/// Submit Leave button.
class CreateLeaveScreen extends ConsumerStatefulWidget {
  const CreateLeaveScreen({super.key});

  @override
  ConsumerState<CreateLeaveScreen> createState() => _CreateLeaveScreenState();
}

class _CreateLeaveScreenState extends ConsumerState<CreateLeaveScreen> {
  final _formKey = GlobalKey<FormState>();

  LeaveType? _type;
  LeaveMode _mode = LeaveMode.single;
  DateTime? _date;
  DateTime? _fromDate;
  DateTime? _toDate;
  final _reasonController = TextEditingController();
  List<String> _attachments = [];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  DateTime? get _effectiveStart => _mode == LeaveMode.single ? _date : _fromDate;
  DateTime? get _effectiveEnd => _mode == LeaveMode.single ? _date : _toDate;

  int? get _calculatedDays {
    final start = _effectiveStart;
    final end = _effectiveEnd;
    if (start == null || end == null) return null;
    return end.difference(start).inDays + 1;
  }

  static String _format(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({bool isFrom = true}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (_mode == LeaveMode.single) {
        _date = picked;
      } else if (isFrom) {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(picked)) _toDate = null;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    setState(() {
      _attachments = result.files.map((e) => e.name).toList();
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_type == null || _effectiveStart == null || _effectiveEnd == null) return;

    final controller = ref.read(createLeaveControllerProvider.notifier);
    final ok = await controller.submit(
      type: _type!,
      mode: _mode,
      startDate: _effectiveStart!,
      endDate: _effectiveEnd!,
      reason: _reasonController.text.trim(),
      attachments: _attachments,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request submitted successfully.')),
      );
      context.pop();
    } else {
      final error = ref.read(createLeaveControllerProvider.notifier).errorOrNull;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.message ?? 'Unable to submit leave request.'),
        ),
      );
    }
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF737373),
      ),
    );
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: Text(
          'Add Leave',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF161616),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(child: _buildFormView()),
              _bottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Leave Type'),
          const SizedBox(height: 8),
          _LeaveTypeDropdown(
            value: _type,
            onChanged: (v) => setState(() => _type = v),
          ),
          const SizedBox(height: 20),
          _fieldLabel('Leave Mode'),
          const SizedBox(height: 8),
          _LeaveModeSelector(
            mode: _mode,
            onChanged: (m) => setState(() => _mode = m),
          ),
          const SizedBox(height: 20),
          if (_mode == LeaveMode.single) ...[
            _fieldLabel('Date'),
            const SizedBox(height: 8),
            _DateField(
              label: _date == null ? 'mm/dd/yyyy' : _format(_date!),
              onTap: () => _pickDate(isFrom: true),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildColumnPair(
                    label: 'From Date',
                    value:
                        _fromDate == null ? 'mm/dd/yyyy' : _format(_fromDate!),
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildColumnPair(
                    label: 'To Date',
                    value: _toDate == null ? 'mm/dd/yyyy' : _format(_toDate!),
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (_calculatedDays != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$_calculatedDays Days (Calculated)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 20),
          _fieldLabel('Reason (Optional)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _reasonController,
            maxLines: 4,
            minLines: 3,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF161616),
            ),
            decoration: InputDecoration(
              hintText: 'Enter reason here...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF737373),
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFD9D9D9)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide:
                    BorderSide(color: AppTheme.primary.withValues(alpha: 0.7)),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          _fieldLabel('Attach Files'),
          const SizedBox(height: 8),
          _AttachFilesTile(
            attachments: _attachments,
            onUpload: _pickFiles,
            onRemove: (index) => setState(() => _attachments.removeAt(index)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildColumnPair({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        _DateField(label: value, onTap: onTap),
      ],
    );
  }

  Widget _bottomBar(BuildContext context) {
    final submitting =
        ref.watch(createLeaveControllerProvider.select((s) => s.isLoading));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF7F7F7))),
      ),
      child: SizedBox(
        height: 45,
        child: FilledButton(
          onPressed: submitting ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.primary,
            shape: const StadiumBorder(),
          ),
          child: submitting
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Submit Leave',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_outward_rounded,
                        size: 18, color: Colors.white),
                  ],
                ),
        ),
      ),
    );
  }
}
// ─── Leave Type dropdown (Figma "Full name" 76:6266) ──────────────────────

class _LeaveTypeDropdown extends StatelessWidget {
  const _LeaveTypeDropdown({required this.value, required this.onChanged});

  final LeaveType? value;
  final ValueChanged<LeaveType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: DropdownButtonFormField<LeaveType>(
        initialValue: value,
        isExpanded: true,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF161616),
        ),
        hint: Text(
          'Select Type',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF737373),
          ),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        items: LeaveType.values
            .map(
              (t) => DropdownMenuItem<LeaveType>(
                value: t,
                child: Text(
                  switch (t) {
                    LeaveType.casual => 'Casual Leave',
                    LeaveType.sick => 'Sick Leave',
                    LeaveType.annual => 'Annual Leave',
                    LeaveType.family => 'Family Function',
                    LeaveType.other => 'Other',
                  },
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF161616),
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Leave Mode radio selector (Figma 76:6267) ─────────────────────────────

class _LeaveModeSelector extends StatelessWidget {
  const _LeaveModeSelector({required this.mode, required this.onChanged});

  final LeaveMode mode;
  final ValueChanged<LeaveMode> onChanged;

  Widget _option({required LeaveMode value, required String label}) {
    final selected = mode == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            size: 20,
            color: selected ? AppTheme.primary : const Color(0xFF606060),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color:
                  selected ? const Color(0xFF181818) : const Color(0xFF606060),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _option(value: LeaveMode.single, label: 'Single Days'),
        const SizedBox(width: 24),
        _option(value: LeaveMode.multiple, label: 'Multiple Days'),
      ],
    );
  }
}
// ─── Date field (Figma 76:6268) ────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF737373),
                ),
              ),
            ),
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: Color(0xFF737373)),
          ],
        ),
      ),
    );
  }
}

// ─── Attach files tile (Figma "Add Images" 76:6270) ────────────────────────

class _AttachFilesTile extends StatelessWidget {
  const _AttachFilesTile({
    required this.attachments,
    required this.onUpload,
    required this.onRemove,
  });

  final List<String> attachments;
  final VoidCallback onUpload;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final hasFiles = attachments.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasFiles)
            for (var i = 0; i < attachments.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file_rounded,
                        size: 18, color: Color(0xFF737373)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attachments[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF161616),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemove(i),
                      icon: const Icon(Icons.close_rounded,
                          size: 16, color: Color(0xFF737373)),
                    ),
                  ],
                ),
              ),
          GestureDetector(
            onTap: onUpload,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                hasFiles ? 'Add More' : 'Upload',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF737373),
                ),
              ),
            ),
          ),
          if (!hasFiles) ...[
            const SizedBox(height: 8),
            Text(
              'No File Chosen',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF909090),
              ),
            ),
          ],
        ],
      ),
    );
  }
}