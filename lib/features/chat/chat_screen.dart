import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String content;
  final String sender;
  final DateTime time;
  final bool isMe;
  final bool isRead;
  final MessageType type;
  final Map<String, List<String>> reactions;

  ChatMessage({
    required this.content,
    required this.sender,
    required this.time,
    required this.isMe,
    this.isRead = false,
    this.type = MessageType.text,
    this.reactions = const {},
  });
}

enum MessageType { text, image, file, system }

class ChatRoom {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String imageUrl;
  final int unreadCount;
  final List<String> participants;
  final Map<String, String> participantImages;

  ChatRoom({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.imageUrl,
    this.unreadCount = 0,
    required this.participants,
    required this.participantImages,
  });
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String? recipientId;
  final String? recipientName;
  final String? recipientAvatar;
  final String? initialMessage;
  final Map<String, dynamic>? productInfo;
  
  const ChatScreen({
    super.key,
    this.chatId = '0',
    this.recipientId,
    this.recipientName,
    this.recipientAvatar,
    this.initialMessage,
    this.productInfo,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isComposing = false;
  
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<int> _searchResults = [];
  int _currentSearchIndex = -1;
  
  late ChatRoom _chatRoom;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.recipientName != null) {
      _chatRoom = ChatRoom(
        id: widget.chatId,
        name: widget.recipientName!,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        imageUrl: widget.recipientAvatar ?? '',
        participants: [widget.recipientName!, '나'],
        participantImages: {
          widget.recipientName!: widget.recipientAvatar ?? '',
          '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        },
      );
    } else {
      switch (widget.chatId) {
        case '1':
          _chatRoom = ChatRoom(
            id: widget.chatId,
            name: '친구들과의 대화',
            lastMessage: '오늘 저녁에 만나요!',
            lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
            imageUrl: 'https://images.unsplash.com/photo-1517840901100-8179e982acb7?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
            participants: ['김민준', '이지은', '박준호', '나'],
            participantImages: {
              '김민준': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '이지은': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '박준호': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
            },
          );
          break;
        case '2':
          _chatRoom = ChatRoom(
            id: widget.chatId,
            name: '가족 그룹',
            lastMessage: '주말에 뭐해?',
            lastMessageTime: DateTime.now().subtract(Duration(hours: 2)),
            imageUrl: 'https://images.unsplash.com/photo-1581579438747-104c53d7fbc0?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
            participants: ['엄마', '아빠', '동생', '나'],
            participantImages: {
              '엄마': 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '아빠': 'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '동생': 'https://images.unsplash.com/photo-1600486913747-55e5470d6f40?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
            },
          );
          break;
        case '3':
          _chatRoom = ChatRoom(
            id: widget.chatId,
            name: '동네 소모임',
            lastMessage: '다음 주 수요일에 모임 있어요',
            lastMessageTime: DateTime.now().subtract(Duration(hours: 5)),
            imageUrl: 'https://images.unsplash.com/photo-1536321115970-5dfa13356211?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
            participants: ['이웃1', '이웃2', '이웃3', '이웃4', '이웃5', '나'],
            participantImages: {
              '이웃1': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '이웃2': 'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '이웃3': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '이웃4': 'https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '이웃5': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
            },
          );
          break;
        default:
          _chatRoom = ChatRoom(
            id: widget.chatId,
            name: '채팅방 ${widget.chatId}',
            lastMessage: '최근 메시지',
            lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
            imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
            participants: ['상대방', '나'],
            participantImages: {
              '상대방': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
              '나': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
            },
          );
      }
    }
    
    _loadMessages();
    
    _searchController.addListener(() {
      _searchMessages(_searchController.text);
    });
  }
  
  void _loadMessages() {
    final now = DateTime.now();
    
    _messages.clear();
    
    switch (widget.chatId) {
      case '1':
        _messages.addAll([
          ChatMessage(
            content: '안녕하세요! 모두 잘 지내시나요?',
            sender: '나',
            time: now.subtract(Duration(minutes: 30)),
            isMe: true,
            isRead: true,
          ),
          ChatMessage(
            content: '네, 저는 잘 지내고 있어요. 오늘 저녁에 시간 되시나요?',
            sender: '김민준',
            time: now.subtract(Duration(minutes: 28)),
            isMe: false,
          ),
          ChatMessage(
            content: '저도 괜찮아요!',
            sender: '이지은',
            time: now.subtract(Duration(minutes: 26)),
            isMe: false,
          ),
          ChatMessage(
            content: '저녁 7시에 어떠세요? 강남역에서 만날까요?',
            sender: '박준호',
            time: now.subtract(Duration(minutes: 25)),
            isMe: false,
          ),
          ChatMessage(
            content: '좋아요! 7시에 강남역 2번 출구에서 봐요.',
            sender: '나',
            time: now.subtract(Duration(minutes: 20)),
            isMe: true,
          ),
          ChatMessage(
            content: '알겠어요! 그때 봐요~',
            sender: '김민준',
            time: now.subtract(Duration(minutes: 18)),
            isMe: false,
          ),
          ChatMessage(
            content: '저도 7시에 갈게요!',
            sender: '이지은',
            time: now.subtract(Duration(minutes: 15)),
            isMe: false,
          ),
          ChatMessage(
            content: '오늘 비가 올 수도 있으니 우산 챙기세요!',
            sender: '박준호',
            time: now.subtract(Duration(minutes: 10)),
            isMe: false,
          ),
          ChatMessage(
            content: '고마워요! 우산 챙길게요.',
            sender: '나',
            time: now.subtract(Duration(minutes: 5)),
            isMe: true,
          ),
        ]);
        break;
        
      case '2':
        _messages.addAll([
          ChatMessage(
            content: '주말에 다들 뭐하세요?',
            sender: '나',
            time: now.subtract(Duration(hours: 6)),
            isMe: true,
            isRead: true,
          ),
          ChatMessage(
            content: '나는 집에서 쉴 예정이야',
            sender: '엄마',
            time: now.subtract(Duration(hours: 5, minutes: 45)),
            isMe: false,
          ),
          ChatMessage(
            content: '저는 친구들 만나기로 했어요',
            sender: '동생',
            time: now.subtract(Duration(hours: 4)),
            isMe: false,
          ),
          ChatMessage(
            content: '주말에 다 같이 저녁 먹을까요?',
            sender: '나',
            time: now.subtract(Duration(hours: 3)),
            isMe: true,
          ),
          ChatMessage(
            content: '좋은 생각이네! 토요일 저녁은 어때?',
            sender: '아빠',
            time: now.subtract(Duration(hours: 2)),
            isMe: false,
          ),
          ChatMessage(
            content: '네 좋아요! 뭐 먹을까요?',
            sender: '나',
            time: now.subtract(Duration(hours: 1)),
            isMe: true,
          ),
        ]);
        break;
        
      case '3':
        _messages.addAll([
          ChatMessage(
            content: '다음 주 수요일에 모임 있어요',
            sender: '이웃1',
            time: now.subtract(Duration(hours: 12)),
            isMe: false,
          ),
          ChatMessage(
            content: '몇 시에 만날까요?',
            sender: '이웃2',
            time: now.subtract(Duration(hours: 11)),
            isMe: false,
          ),
          ChatMessage(
            content: '저녁 7시 어떠세요?',
            sender: '이웃1',
            time: now.subtract(Duration(hours: 10)),
            isMe: false,
          ),
          ChatMessage(
            content: '저는 괜찮아요!',
            sender: '나',
            time: now.subtract(Duration(hours: 8)),
            isMe: true,
          ),
          ChatMessage(
            content: '장소는 어디로 할까요?',
            sender: '이웃3',
            time: now.subtract(Duration(hours: 6)),
            isMe: false,
          ),
          ChatMessage(
            content: '동네 카페 어때요?',
            sender: '이웃4',
            time: now.subtract(Duration(hours: 5)),
            isMe: false,
          ),
        ]);
        break;
        
      default:
        _messages.addAll([
          ChatMessage(
            content: '안녕하세요!',
            sender: '나',
            time: now.subtract(Duration(hours: 1)),
            isMe: true,
            isRead: true,
          ),
          ChatMessage(
            content: '반갑습니다 :)',
            sender: _chatRoom.name,
            time: now.subtract(Duration(minutes: 30)),
            isMe: false,
          ),
        ]);
        break;
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _messageController.clear();
    setState(() {
      _isComposing = false;
      _messages.add(ChatMessage(
        content: text.trim(),
        sender: '나',
        time: DateTime.now(),
        isMe: true,
      ));
    });
    
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _searchMessages(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _currentSearchIndex = -1;
      });
      return;
    }
    
    final List<int> results = [];
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].content.toLowerCase().contains(query.toLowerCase())) {
        results.add(i);
      }
    }
    
    setState(() {
      _searchResults = results;
      _currentSearchIndex = results.isNotEmpty ? 0 : -1;
    });
    
    if (results.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 200), () {
        _scrollToSearchResult(0);
      });
    }
  }
  
  void _scrollToSearchResult(int resultIndex) {
    if (_searchResults.isEmpty || resultIndex < 0 || resultIndex >= _searchResults.length) {
      return;
    }
    
    final int messageIndex = _searchResults[resultIndex];
    if (messageIndex < 0 || messageIndex >= _messages.length) {
      return;
    }
    
    final context = _getMessageContext(messageIndex);
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: Duration(milliseconds: 300),
      );
    }
  }
  
  BuildContext? _getMessageContext(int index) {
    final itemExtent = 80.0;
    final offset = index * itemExtent;
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    return null;
  }
  
  void _addReaction(int messageIndex, String reaction, String userName) {
    if (messageIndex < 0 || messageIndex >= _messages.length) return;
    
    setState(() {
      final reactions = Map<String, List<String>>.from(_messages[messageIndex].reactions);
      
      if (reactions.containsKey(reaction)) {
        final users = List<String>.from(reactions[reaction]!);
        if (users.contains(userName)) {
          users.remove(userName);
        } else {
          users.add(userName);
        }
        
        if (users.isEmpty) {
          reactions.remove(reaction);
        } else {
          reactions[reaction] = users;
        }
      } else {
        reactions[reaction] = [userName];
      }
      
      final message = ChatMessage(
        content: _messages[messageIndex].content,
        sender: _messages[messageIndex].sender,
        time: _messages[messageIndex].time,
        isMe: _messages[messageIndex].isMe,
        isRead: _messages[messageIndex].isRead,
        type: _messages[messageIndex].type,
        reactions: reactions,
      );
      
      _messages[messageIndex] = message;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : Text(_chatRoom.name),
        leading: IconButton(
          icon: _isSearching
              ? Icon(Icons.arrow_back)
              : Icon(Icons.arrow_back),
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _searchResults = [];
                _currentSearchIndex = -1;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: _buildAppBarActions(),
      ),
      body: Column(
        children: [
          if (widget.productInfo != null)
            _buildChatHeader(),
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }
  
  Widget _buildChatHeader() {
    final theme = Theme.of(context);
    
    if (widget.productInfo == null) {
      return SizedBox.shrink();
    }
    
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.productInfo!['imageUrl'] != null && widget.productInfo!['imageUrl'].toString().isNotEmpty
                ? Image.network(
                    widget.productInfo!['imageUrl'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                      );
                    },
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey[600]),
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productInfo!['title'] ?? 'Product',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  widget.productInfo!['price'] != null 
                      ? '${formatCurrency(widget.productInfo!['price'])}원'
                      : '가격 정보 없음',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatCurrency(dynamic amount) {
    final formatter = NumberFormat('#,###');
    if (amount is int) {
      return formatter.format(amount);
    } else if (amount is String) {
      try {
        return formatter.format(int.parse(amount));
      } catch (_) {
        return amount;
      }
    }
    return '0';
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final previousMessage = index > 0 ? _messages[index - 1] : null;
        final showSender = previousMessage == null || 
                          previousMessage.sender != message.sender ||
                          message.time.difference(previousMessage.time).inMinutes > 5;
        
        final showTime = index == _messages.length - 1 || 
                        _messages[index + 1].sender != message.sender ||
                        _messages[index + 1].time.difference(message.time).inMinutes > 5;
                        
        return _buildMessageItem(message, showSender, showTime);
      },
    );
  }
  
  Widget _buildMessageItem(ChatMessage message, bool showSender, bool showTime) {
    final theme = Theme.of(context);
    final senderProfileImage = message.isMe 
        ? _chatRoom.participantImages['나'] ?? ''
        : _chatRoom.participantImages[message.sender] ?? '';
    
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            if (showSender)
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.surface,
                backgroundImage: NetworkImage(senderProfileImage),
              )
            else
              SizedBox(width: 32),
            SizedBox(width: 8),
          ],
          
          Column(
            crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!message.isMe && showSender)
                Padding(
                  padding: const EdgeInsets.only(left: 2.0, bottom: 4.0),
                  child: Text(
                    message.sender,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                ),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.isMe && showTime) ...[
                    Text(
                      _formatTime(message.time),
                      style: TextStyle(
                        fontSize: 11,
                        color: message.isMe 
                            ? Colors.white.withOpacity(0.7)
                            : theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(width: 4),
                    if (message.isRead)
                      Text(
                        '읽음',
                        style: TextStyle(
                          fontSize: 11,
                          color: message.isMe 
                              ? Colors.white.withOpacity(0.7)
                              : theme.colorScheme.onBackground.withOpacity(0.5),
                        ),
                      ),
                    SizedBox(width: 4),
                  ],
                  
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: message.isMe 
                          ? theme.colorScheme.primary
                          : theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.04),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: message.isMe 
                            ? Colors.white
                            : theme.colorScheme.onBackground,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  
                  if (!message.isMe && showTime) ...[
                    SizedBox(width: 4),
                    Text(
                      _formatTime(message.time),
                      style: TextStyle(
                        fontSize: 11,
                        color: message.isMe 
                            ? Colors.white.withOpacity(0.7)
                            : theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageComposer() {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.cardTheme.color,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              size: 24
            ),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focusNode.hasFocus ? theme.colorScheme.primary : Colors.transparent,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground,
                ),
                decoration: InputDecoration(
                  hintText: '메시지 입력...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.trim().isNotEmpty;
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: _isComposing 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onBackground.withOpacity(0.4),
              size: 24,
            ),
            onPressed: _isComposing
                ? () => _handleSubmitted(_messageController.text)
                : null,
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? '오후' : '오전';
    return '$period ${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  List<Widget> _buildAppBarActions() {
    return [
      if (!_isSearching)
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      if (_isSearching && _searchResults.isNotEmpty) ...[
        Text(
          '${_currentSearchIndex + 1}/${_searchResults.length}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        IconButton(
          icon: Icon(Icons.keyboard_arrow_up),
          onPressed: _currentSearchIndex > 0
              ? () {
                  setState(() {
                    _currentSearchIndex--;
                  });
                  _scrollToSearchResult(_currentSearchIndex);
                }
              : null,
        ),
        IconButton(
          icon: Icon(Icons.keyboard_arrow_down),
          onPressed: _currentSearchIndex < _searchResults.length - 1
              ? () {
                  setState(() {
                    _currentSearchIndex++;
                  });
                  _scrollToSearchResult(_currentSearchIndex);
                }
              : null,
        ),
      ],
    ];
  }
  
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: '메시지 검색...',
        hintStyle: TextStyle(color: Colors.white60),
        border: InputBorder.none,
      ),
      style: TextStyle(color: Colors.white),
    );
  }
} 