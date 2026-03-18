import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../repositories/habit_repository.dart';

class CreateEditHabitScreen extends StatefulWidget {
  const CreateEditHabitScreen({
    super.key,
    required this.repository,
    this.habit,
  });

  final HabitRepository repository;
  final Habit? habit;

  @override
  State<CreateEditHabitScreen> createState() => _CreateEditHabitScreenState();
}

class _CreateEditHabitScreenState extends State<CreateEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String _frequency = 'Daily';
  bool _saving = false;

  bool get _isEdit => widget.habit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _descriptionController = TextEditingController(text: widget.habit?.description ?? '');
    _frequency = widget.habit?.frequency ?? 'Daily';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final newHabit = Habit(
      id: widget.habit?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      frequency: _frequency,
      createdDate: widget.habit?.createdDate ?? DateTime.now(),
    );

    if (_isEdit) {
      await widget.repository.updateHabit(newHabit);
    } else {
      await widget.repository.createHabit(newHabit);
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Habit' : 'Create Habit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Habit name',
                hintText: 'e.g. Read 20 minutes',
                prefixIcon: Icon(Icons.checklist),
              ),
              validator: (String? value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Habit name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Add details to keep the habit clear and measurable.',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'Daily', child: Text('Daily')),
                DropdownMenuItem<String>(value: 'Weekly', child: Text('Weekly')),
                DropdownMenuItem<String>(value: 'Custom', child: Text('Custom')),
              ],
              onChanged: (String? value) {
                setState(() {
                  _frequency = value ?? 'Daily';
                });
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isEdit ? 'Update Habit' : 'Save Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
