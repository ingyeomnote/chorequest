import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/avatar_service.dart';

/// Avatar Customization Screen
///
/// Allows users to customize their avatar:
/// - Body type
/// - Hairstyle
/// - Outfit (unlock via level/achievements)
/// - Accessories (unlock via level/achievements)
/// - Skin tone
///
/// Gamification feature from Phase 2 (P1).
class AvatarCustomizationScreen extends StatefulWidget {
  const AvatarCustomizationScreen({super.key});

  @override
  State<AvatarCustomizationScreen> createState() =>
      _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState extends State<AvatarCustomizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AvatarService _avatarService = AvatarService();

  // Categories
  final List<String> _categories = [
    '체형',
    '헤어',
    '의상',
    '액세서리',
    '피부톤',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final avatar = user?.avatar;

    if (user == null || avatar == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('아바타 커스터마이징')),
        body: const Center(child: Text('사용자 정보를 불러올 수 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('아바타 커스터마이징'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Avatar preview
          Container(
            height: 250,
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar placeholder (actual avatar rendering would go here)
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${user.level} • ${user.xp} XP',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: _categories
                  .map((category) => Tab(text: category))
                  .toList(),
            ),
          ),

          // Items grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBodyTypeGrid(avatar, user.level),
                _buildHairstyleGrid(avatar, user.level),
                _buildOutfitGrid(avatar, user.level),
                _buildAccessoryGrid(avatar, user.level),
                _buildSkinToneGrid(avatar),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTypeGrid(avatar, int userLevel) {
    final bodyTypes = [
      _AvatarItem('체형 1', Icons.person_outline, isLocked: false),
      _AvatarItem('체형 2', Icons.person, isLocked: false),
      _AvatarItem('체형 3', Icons.person_outline, isLocked: userLevel < 5),
    ];

    return _buildItemGrid(bodyTypes);
  }

  Widget _buildHairstyleGrid(avatar, int userLevel) {
    final hairstyles = [
      _AvatarItem('짧은 머리', Icons.face, isLocked: false),
      _AvatarItem('긴 머리', Icons.face_6, isLocked: false),
      _AvatarItem('곱슬머리', Icons.face_3, isLocked: userLevel < 3),
      _AvatarItem('단발머리', Icons.face_4, isLocked: userLevel < 5),
      _AvatarItem('포니테일', Icons.face_2, isLocked: userLevel < 10),
    ];

    return _buildItemGrid(hairstyles);
  }

  Widget _buildOutfitGrid(avatar, int userLevel) {
    final outfits = [
      _AvatarItem('기본 의상', Icons.checkroom, isLocked: false),
      _AvatarItem('캐주얼', Icons.checkroom_outlined, isLocked: userLevel < 3),
      _AvatarItem('정장', Icons.business_center, isLocked: userLevel < 5),
      _AvatarItem('운동복', Icons.sports_soccer, isLocked: userLevel < 7),
      _AvatarItem('파티복', Icons.celebration, isLocked: userLevel < 10, isPremium: true),
    ];

    return _buildItemGrid(outfits);
  }

  Widget _buildAccessoryGrid(avatar, int userLevel) {
    final accessories = [
      _AvatarItem('없음', Icons.block, isLocked: false),
      _AvatarItem('안경', Icons.remove_red_eye, isLocked: userLevel < 2),
      _AvatarItem('모자', Icons.mood, isLocked: userLevel < 5),
      _AvatarItem('목걸이', Icons.favorite, isLocked: userLevel < 8),
      _AvatarItem('왕관', Icons.workspace_premium, isLocked: userLevel < 15, isPremium: true),
    ];

    return _buildItemGrid(accessories);
  }

  Widget _buildSkinToneGrid(avatar) {
    final skinTones = [
      _SkinTone('밝은 톤', Color(0xFFFDE7D6)),
      _SkinTone('기본 톤', Color(0xFFF9D5B8)),
      _SkinTone('황갈색', Color(0xFFF0C19A)),
      _SkinTone('어두운 톤', Color(0xFFD9A372)),
      _SkinTone('진한 톤', Color(0xFFA87C5A)),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: skinTones.length,
      itemBuilder: (context, index) {
        final tone = skinTones[index];
        return InkWell(
          onTap: () {
            // TODO: Apply skin tone
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${tone.name} 적용됨')),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: tone.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tone.name,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemGrid(List<_AvatarItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(_AvatarItem item) {
    return InkWell(
      onTap: item.isLocked
          ? null
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} 적용됨')),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: item.isLocked ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isLocked ? Colors.grey[300]! : Colors.grey[400]!,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 48,
                  color: item.isLocked ? Colors.grey[400] : Colors.blue,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: item.isLocked ? Colors.grey[600] : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (item.isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.lock, size: 20, color: Colors.grey[600]),
              ),
            if (item.isPremium)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('아바타 커스터마이징'),
        content: const Text(
          '레벨을 올리거나 업적을 달성하면 새로운 의상과 액세서리를 잠금 해제할 수 있어요!\n\n'
          '🔒 잠긴 아이템: 레벨 또는 업적 필요\n'
          '⭐ PRO 아이템: 프리미엄 구독 필요',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

class _AvatarItem {
  final String name;
  final IconData icon;
  final bool isLocked;
  final bool isPremium;

  _AvatarItem(
    this.name,
    this.icon, {
    this.isLocked = false,
    this.isPremium = false,
  });
}

class _SkinTone {
  final String name;
  final Color color;

  _SkinTone(this.name, this.color);
}
