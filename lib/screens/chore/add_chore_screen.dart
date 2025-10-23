import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/chore_provider.dart';
import 'package:flutter_app/models/chore_model.dart';
import 'package:intl/intl.dart';

class AddChoreScreen extends StatefulWidget {
  final String householdId;

  const AddChoreScreen({super.key, required this.householdId});

  @override
  State<AddChoreScreen> createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  ChoreDifficulty _selectedDifficulty = ChoreDifficulty.medium;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _createChore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final choreProvider = context.read<ChoreProvider>();

      final dueDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await choreProvider.createChore(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        householdId: widget.householdId,
        difficulty: _selectedDifficulty,
        dueDate: dueDate,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('집안일이 추가되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('집안일 추가 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('집안일 추가'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Input
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '집안일 제목',
                    hintText: '예: 설거지, 청소, 빨래',
                    prefixIcon: Icon(Icons.task),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '제목을 입력해주세요';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description Input
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '설명 (선택사항)',
                    hintText: '집안일에 대한 설명',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  maxLines: 3,
                ),
                
                const SizedBox(height: 24),
                
                // Difficulty Selector
                Text(
                  '난이도',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                
                // Difficulty Cards
                Row(
                  children: [
                    Expanded(
                      child: _DifficultyCard(
                        difficulty: ChoreDifficulty.easy,
                        label: '쉬움',
                        xp: 10,
                        icon: Icons.sentiment_satisfied,
                        color: Colors.green,
                        isSelected: _selectedDifficulty == ChoreDifficulty.easy,
                        onTap: () {
                          setState(() => _selectedDifficulty = ChoreDifficulty.easy);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DifficultyCard(
                        difficulty: ChoreDifficulty.medium,
                        label: '보통',
                        xp: 25,
                        icon: Icons.sentiment_neutral,
                        color: Colors.orange,
                        isSelected: _selectedDifficulty == ChoreDifficulty.medium,
                        onTap: () {
                          setState(() => _selectedDifficulty = ChoreDifficulty.medium);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DifficultyCard(
                        difficulty: ChoreDifficulty.hard,
                        label: '어려움',
                        xp: 50,
                        icon: Icons.sentiment_very_dissatisfied,
                        color: Colors.red,
                        isSelected: _selectedDifficulty == ChoreDifficulty.hard,
                        onTap: () {
                          setState(() => _selectedDifficulty = ChoreDifficulty.hard);
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                // Date & Time Pickers
                Text(
                  '마감 날짜 및 시간',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('M월 d일 (E)', 'ko_KR').format(_selectedDate)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime.format(context)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _createChore,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('추가하기', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final ChoreDifficulty difficulty;
  final String label;
  final int xp;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.difficulty,
    required this.label,
    required this.xp,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withValues(alpha: 0.2)
              : Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+$xp XP',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
