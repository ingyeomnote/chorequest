import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/household_provider.dart';

/// Collaborative Household Setup Screen
///
/// Part of onboarding flow. Emphasizes "together" approach:
/// 1. Choose household type (newlyweds, family, roommates)
/// 2. Enter household name
/// 3. Preview Korean chore templates
///
/// Prevents "app manager trap" by encouraging all members to participate.
class HouseholdSetupScreen extends StatefulWidget {
  const HouseholdSetupScreen({super.key});

  @override
  State<HouseholdSetupScreen> createState() => _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState extends State<HouseholdSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  HouseholdType? _selectedType;
  bool _isLoading = false;

  final List<_HouseholdTypeOption> _householdTypes = [
    _HouseholdTypeOption(
      type: HouseholdType.newlyweds,
      icon: Icons.favorite_outline,
      title: '맞벌이 신혼부부',
      description: '공평한 가사 분담으로\n행복한 시작을',
      color: Colors.pink,
      templateChores: ['설거지', '빨래 개기', '청소기 돌리기'],
    ),
    _HouseholdTypeOption(
      type: HouseholdType.family,
      icon: Icons.family_restroom,
      title: '유자녀 가정',
      description: '아이들도 함께 참여하는\n즐거운 집안일',
      color: Colors.blue,
      templateChores: ['아이 등원 준비', '장난감 정리', '분리수거'],
    ),
    _HouseholdTypeOption(
      type: HouseholdType.roommates,
      icon: Icons.people_outline,
      title: '룸메이트',
      description: '명확한 역할 분담으로\n편안한 공동생활',
      color: Colors.green,
      templateChores: ['화장실 청소', '쓰레기 버리기', '공용공간 청소'],
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가구 유형을 선택해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final householdProvider = context.read<HouseholdProvider>();

      final household = await householdProvider.createHousehold(
        name: _nameController.text.trim(),
        description: _getHouseholdDescription(),
        creatorId: authProvider.currentUser!.id,
      );

      await authProvider.joinHousehold(household.id);

      if (!mounted) return;

      // Navigate to member invitation
      Navigator.pushReplacementNamed(
        context,
        '/onboarding/invite-members',
        arguments: {
          'householdId': household.id,
          'householdType': _selectedType,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가구 생성 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getHouseholdDescription() {
    switch (_selectedType!) {
      case HouseholdType.newlyweds:
        return '맞벌이 신혼부부 가구';
      case HouseholdType.family:
        return '유자녀 가정';
      case HouseholdType.roommates:
        return '룸메이트 공동생활';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가구 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                // Header
                const Icon(
                  Icons.home_work_outlined,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  '어떤 가구인가요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '가구 유형에 맞는 집안일 템플릿을 제공해드려요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 32),

                // Household type selection
                ...List.generate(_householdTypes.length, (index) {
                  final option = _householdTypes[index];
                  return _buildHouseholdTypeCard(option);
                }),

                const SizedBox(height: 24),

                // Household name input
                if (_selectedType != null) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '가구 이름',
                      hintText: '예: 우리집, 김철수네 가족',
                      prefixIcon: const Icon(Icons.edit_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '가구 이름을 입력해주세요';
                      }
                      if (value.length < 2) {
                        return '2자 이상 입력해주세요';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Template preview
                  _buildTemplatePreview(),

                  const SizedBox(height: 32),

                  // Collaborative tip
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.group, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '다음 단계에서 가족 모두를 초대하세요!\n함께 설정하면 더 공정해요.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Next button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '다음: 멤버 초대하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHouseholdTypeCard(_HouseholdTypeOption option) {
    final isSelected = _selectedType == option.type;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = option.type;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? option.color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? option.color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? option.color.withOpacity(0.2)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  color: isSelected ? option.color : Colors.grey[600],
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? option.color : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Check icon
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: option.color,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatePreview() {
    final option = _householdTypes.firstWhere((o) => o.type == _selectedType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: option.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: option.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: option.color, size: 20),
              const SizedBox(width: 8),
              const Text(
                '미리 준비된 집안일 템플릿',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: option.templateChores
                .map((chore) => Chip(
                      label: Text(
                        chore,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: option.color.withOpacity(0.3)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            '나중에 자유롭게 수정할 수 있어요',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

enum HouseholdType {
  newlyweds,
  family,
  roommates,
}

class _HouseholdTypeOption {
  final HouseholdType type;
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<String> templateChores;

  _HouseholdTypeOption({
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.templateChores,
  });
}
