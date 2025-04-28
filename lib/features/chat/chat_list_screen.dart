import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../../core/components/ids_app_bar.dart';
import '../../core/components/itunda_app_bar.dart';

class ChatRoom {
  final String id;
  final String name;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String imageUrl;
  final Map<String, String> participantImages;

  ChatRoom({
    required this.id,
    required this.name,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.imageUrl,
    required this.participantImages,
  });
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<ChatRoom> _chatRooms = [];
  
  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }
  
  void _loadChatRooms() {
    final now = DateTime.now();
    
    _chatRooms.addAll([
      ChatRoom(
        id: '1',
        name: '친구들과의 대화',  // Chat with friends
        lastMessage: '오늘 저녁에 만나요!',  // Let's meet this evening!
        lastMessageTime: now.subtract(Duration(minutes: 5)),
        imageUrl: 'https://images.unsplash.com/photo-1517840901100-8179e982acb7?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        unreadCount: 0,
        participants: ['김민준', '이지은', '박준호', '나'],
        participantImages: {
          '김민준': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '이지은': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '박준호': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '2',
        name: '가족 그룹',  // Family group
        lastMessage: '주말에 뭐해?',  // What are you doing this weekend?
        lastMessageTime: now.subtract(Duration(hours: 2)),
        imageUrl: 'https://images.unsplash.com/photo-1581579438747-104c53d7fbc0?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        unreadCount: 3,
        participants: ['엄마', '아빠', '동생', '나'],
        participantImages: {
          '엄마': 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '아빠': 'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '동생': 'https://images.unsplash.com/photo-1600486913747-55e5470d6f40?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '3',
        name: '동네 소모임',  // Neighborhood group
        lastMessage: '다음 주 수요일에 모임 있어요',  // We have a meeting next Wednesday
        lastMessageTime: now.subtract(Duration(hours: 5)),
        imageUrl: 'https://images.unsplash.com/photo-1536321115970-5dfa13356211?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        unreadCount: 12,
        participants: ['이웃1', '이웃2', '이웃3', '이웃4', '이웃5', '나'],
        participantImages: {
          '이웃1': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '이웃2': 'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '이웃3': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '이웃4': 'https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '이웃5': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '4',
        name: '회사 프로젝트',  // Company project
        lastMessage: '회의록 공유드립니다',  // Sharing the meeting minutes
        lastMessageTime: now.subtract(Duration(days: 1)),
        imageUrl: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        unreadCount: 0,
        participants: ['팀장님', '디자이너', '개발자1', '개발자2', '나'],
        participantImages: {
          '팀장님': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '디자이너': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '개발자1': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '개발자2': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '5',
        name: '김민준',  // Individual chat
        lastMessage: '다음 주에 만나서 얘기해요',  // Let's talk when we meet next week
        lastMessageTime: now.subtract(Duration(days: 2)),
        imageUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        unreadCount: 0,
        participants: ['김민준', '나'],
        participantImages: {
          '김민준': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '6',
        name: '이지은',  // Individual chat
        lastMessage: '프로젝트 자료 확인해줘',  // Please check the project materials
        lastMessageTime: now.subtract(Duration(days: 3)),
        imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        unreadCount: 1,
        participants: ['이지은', '나'],
        participantImages: {
          '이지은': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '7',
        name: '장서연',  // Individual chat
        lastMessage: '이번주 금요일 회식 참석하시나요?',
        lastMessageTime: now.subtract(Duration(hours: 8)),
        imageUrl: 'assets/images/person3_avatar.png',
        unreadCount: 2,
        participants: ['장서연', '나'],
        participantImages: {
          '장서연': 'assets/images/person3_avatar.png',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '8',
        name: '동네 장터',  // Marketplace group
        lastMessage: '새 상품 올렸습니다. 관심 있으신 분?',
        lastMessageTime: now.subtract(Duration(hours: 12)),
        imageUrl: 'assets/images/market_avatar.png',
        unreadCount: 5,
        participants: ['판매자1', '판매자2', '구매자1', '구매자2', '나'],
        participantImages: {
          '판매자1': 'assets/images/default_avatar.png',
          '판매자2': 'assets/images/default_avatar.png',
          '구매자1': 'assets/images/default_avatar.png',
          '구매자2': 'assets/images/default_avatar.png',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '9',
        name: '운동 모임',  // Exercise group
        lastMessage: '내일 아침 6시에 공원에서 만나요',
        lastMessageTime: now.subtract(Duration(hours: 3)),
        imageUrl: 'assets/images/exercise_avatar.png',
        unreadCount: 0,
        participants: ['코치', '회원1', '회원2', '회원3', '나'],
        participantImages: {
          '코치': 'assets/images/default_avatar.png',
          '회원1': 'assets/images/default_avatar.png',
          '회원2': 'assets/images/default_avatar.png',
          '회원3': 'assets/images/default_avatar.png',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '10',
        name: '스터디 그룹',  // Study group
        lastMessage: '오늘 발표자료 업로드했습니다',
        lastMessageTime: now.subtract(Duration(days: 1, hours: 6)),
        imageUrl: 'assets/images/study_avatar.png',
        unreadCount: 0,
        participants: ['리더', '멤버1', '멤버2', '멤버3', '나'],
        participantImages: {
          '리더': 'assets/images/default_avatar.png',
          '멤버1': 'assets/images/default_avatar.png',
          '멤버2': 'assets/images/default_avatar.png',
          '멤버3': 'assets/images/default_avatar.png',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '11',
        name: '이동훈',  // Individual chat
        lastMessage: '다음 주 일정 조율했습니다',
        lastMessageTime: now.subtract(Duration(days: 4)),
        imageUrl: 'assets/images/person4_avatar.png',
        unreadCount: 0,
        participants: ['이동훈', '나'],
        participantImages: {
          '이동훈': 'assets/images/person4_avatar.png',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
      ChatRoom(
        id: '12',
        name: '취미 동아리',  // Hobby club
        lastMessage: '이번 주 모임은 비가 예상되어 실내로 변경됩니다',
        lastMessageTime: now.subtract(Duration(hours: 20)),
        imageUrl: 'assets/images/hobby_avatar.png',
        unreadCount: 3,
        participants: ['동아리장', '회원1', '회원2', '회원3', '나'],
        participantImages: {
          '동아리장': 'assets/images/default_avatar.png',
          '회원1': 'assets/images/default_avatar.png',
          '회원2': 'assets/images/default_avatar.png',
          '회원3': 'assets/images/default_avatar.png',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      ),
    ]);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ItundaAppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              size: 22,
            ),
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              size: 22,
            ),
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _buildChatList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.chat_bubble_outline,
          color: theme.colorScheme.onPrimary,
          size: 30,
        ),
        onPressed: () {},
      ),
    );
  }
  
  Widget _buildChatList() {
    if (_chatRooms.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: _chatRooms.length,
      itemBuilder: (context, index) {
        return _buildChatItem(_chatRooms[index]);
      },
    );
  }
  
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: theme.colorScheme.onBackground.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            '채팅방이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '새로운 대화를 시작해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onBackground.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatItem(ChatRoom chatRoom) {
    final formattedTime = _formatLastMessageTime(chatRoom.lastMessageTime);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatId: chatRoom.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 이미지
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(chatRoom.imageUrl),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chatRoom.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chatRoom.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  
                  // 그룹채팅일 경우 참여자 프로필 이미지 표시
                  if (chatRoom.participants.length > 2) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 24,
                      child: Row(
                        children: [
                          // 참여자 프로필 이미지 (최대 4명까지만 표시)
                          ...chatRoom.participants
                              .where((p) => p != '나') // 자신 제외
                              .take(4) // 최대 4명
                              .map((participant) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundImage: NetworkImage(
                                          chatRoom.participantImages[participant] ?? ''),
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                  )),
                          
                          // 추가 참여자가 있는 경우 +N 표시
                          if (chatRoom.participants.length > 5) // 자신 제외 4명 이상
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+${chatRoom.participants.length - 5}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 읽지 않은 메시지 수 표시
            if (chatRoom.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chatRoom.unreadCount}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  String _formatLastMessageTime(DateTime time) {
    // 오늘인 경우 시:분 형식으로 표시
    // 어제인 경우 '어제'로 표시
    // 그 외의 경우 월/일 형식으로 표시
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);
    final difference = today.difference(messageDay).inDays;
    
    if (difference == 0) {
      // 오늘
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      // 어제
      return '어제';
    } else if (difference < 7) {
      // 일주일 이내
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return weekdays[time.weekday - 1];
    } else {
      // 일주일 이상
      return '${time.month}/${time.day}';
    }
  }
} 