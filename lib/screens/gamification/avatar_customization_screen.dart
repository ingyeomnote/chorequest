import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/avatar_service.dart';
import '../../data/avatar_items_data.dart';
import '../../models/avatar_model.dart';

/// Avatar Customization Screen (Service-Connected Version)
///
/// Now connected to actual AvatarService and AvatarItemsData.
/// Displays real unlock status based on user level and achievements.
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

  final List<String> _categories = [
    '바디',
    '헤어',
    '의상',
    '액세서리',
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
              tabs: _categories.map((category) => Tab(text: category)).toList(),
            ),
          ),

          // Items grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItemGrid('body', avatar, user.level, user.achievements),
                _buildItemGrid('hair', avatar, user.level, user.achievements),
                _buildItemGrid('outfit', avatar, user.level, user.achievements),
                _buildItemGrid('accessory', avatar, user.level, user.achievements),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(
    String category,
    AvatarModel avatar,
    int userLevel,
    List<String> achievements,
  ) {
    // Get items from AvatarItemsData
    List<AvatarItem> items;
    switch (category) {
      case 'body':
        items = AvatarItemsData.getBodyTypes();
        break;
      case 'hair':
        items = AvatarItemsData.getHairStyles();
        break;
      case 'outfit':
        items = AvatarItemsData.getOutfits();
        break;
      case 'accessory':
        items = AvatarItemsData.getAccessories();
        break;
      default:
        items = [];
    }

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
        final isUnlocked = _isItemUnlocked(item, avatar, userLevel, achievements);
        final isSelected = _isItemSelected(item, avatar, category);

        return _buildItemCard(item, isUnlocked, isSelected, avatar, category);
      },
    );
  }

  bool _isItemUnlocked(
    AvatarItem item,
    AvatarModel avatar,
    int userLevel,
    List<String> achievements,
  ) {
    // Premium items require subscription (simplified: check if premium)
    if (item.isPremium) {
      return false; // TODO: Check actual subscription status
    }

    // Level-based unlock
    if (item.unlockLevel > userLevel) {
      return false;
    }

    // Achievement-based unlock
    if (item.unlockAchievement != null) {
      if (!achievements.contains(item.unlockAchievement)) {
        return false;
      }
    }

    // Check if actually unlocked in avatar model
    if (item.category == 'outfit') {
      return avatar.unlockedOutfits.contains(item.id);
    } else if (item.category == 'accessory') {
      return avatar.unlockedAccessories.contains(item.id);
    }

    // Body and hair are always unlocked once level requirement is met
    return true;
  }

  bool _isItemSelected(AvatarItem item, AvatarModel avatar, String category) {
    switch (category) {
      case 'body':
        return avatar.bodyType == item.id;
      case 'hair':
        return avatar.hairStyle == item.id;
      case 'outfit':
        return avatar.outfit == item.id;
      case 'accessory':
        return avatar.accessory == item.id;
      default:
        return false;
    }
  }

  Widget _buildItemCard(
    AvatarItem item,
    bool isUnlocked,
    bool isSelected,
    AvatarModel avatar,
    String category,
  ) {
    return InkWell(
      onTap: isUnlocked
          ? () => _selectItem(item, avatar, category)
          : () => _showLockedDialog(item),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue[50]
              : (isUnlocked ? Colors.white : Colors.grey[200]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : (isUnlocked ? Colors.grey[400]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(item.category),
                  size: 48,
                  color: isUnlocked ? Colors.blue : Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnlocked ? Colors.black87 : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isUnlocked && item.unlockLevel > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Lv.${item.unlockLevel}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
              ],
            ),
            if (!isUnlocked)
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
            if (isSelected)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'body':
        return Icons.person_outline;
      case 'hair':
        return Icons.face;
      case 'outfit':
        return Icons.checkroom;
      case 'accessory':
        return Icons.star_border;
      default:
        return Icons.help_outline;
    }
  }

  void _selectItem(AvatarItem item, AvatarModel avatar, String category) {
    // Apply customization via AvatarService
    _avatarService.customizeAvatar(
      avatar,
      bodyType: category == 'body' ? item.id : null,
      hairStyle: category == 'hair' ? item.id : null,
      outfit: category == 'outfit' ? item.id : null,
      accessory: category == 'accessory' ? item.id : null,
    );

    // TODO: Save to Firestore via UserRepository

    setState(() {}); // Refresh UI

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} 적용됨'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showLockedDialog(AvatarItem item) {
    String unlockMessage = '';
    if (item.unlockLevel > 0) {
      unlockMessage = 'Level ${item.unlockLevel}에 도달하면 잠금 해제됩니다.';
    } else if (item.unlockAchievement != null) {
      unlockMessage = '특정 업적을 달성하면 잠금 해제됩니다.';
    } else if (item.isPremium) {
      unlockMessage = '프리미엄 구독이 필요합니다.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('잠긴 아이템'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(item.description),
            const SizedBox(height: 12),
            Text(
              unlockMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('아바타 커스터마이징'),
        content: const Text(
          '레벨을 올리거나 업적을 달성하면 새로운 의상과 액세서리를 잠금 해제할 수 있어요!\n\n'
          '🔒 잠긴 아이템: 레벨 또는 업적 필요\n'
          '⭐ PRO 아이템: 프리미엄 구독 필요\n\n'
          '선택한 아이템을 탭하면 아바타에 적용됩니다.',
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
