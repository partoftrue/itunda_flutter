import 'package:flutter/material.dart';
import '../marketplace/market_screen.dart';
import '../jobs/jobs_screen.dart';
import '../neighborhood/neighborhood_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '전체 메뉴',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('금융'),
            _buildFinanceSection(),
            SizedBox(height: 24),
            _buildSectionTitle('라이프'),
            _buildLifeSection(context),
            SizedBox(height: 24),
            _buildSectionTitle('투자'),
            _buildInvestmentSection(),
            SizedBox(height: 24),
            _buildSectionTitle('혜택'),
            _buildBenefitsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFinanceSection() {
    final items = [
      {'icon': Icons.account_balance_wallet, 'title': '계좌'},
      {'icon': Icons.credit_card, 'title': '카드'},
      {'icon': Icons.receipt_long, 'title': '내 소비'},
      {'icon': Icons.autorenew, 'title': '송금'},
      {'icon': Icons.payments, 'title': '대출'},
      {'icon': Icons.request_quote, 'title': '투자받기'},
    ];

    return _buildGridMenu(items);
  }

  Widget _buildLifeSection(BuildContext context) {
    final items = [
      {
        'icon': Icons.store, 
        'title': '마켓', 
        'color': Color(0xFFFF7E36),
        'onTap': () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => MarketScreen())
        )
      },
      {
        'icon': Icons.work, 
        'title': '알바', 
        'color': Color(0xFFFF7E36),
        'onTap': () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => JobsScreen())
        )
      },
      {
        'icon': Icons.people, 
        'title': '동네생활', 
        'color': Color(0xFFFF7E36),
        'onTap': () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => NeighborhoodScreen())
        )
      },
      {
        'icon': Icons.calendar_today, 
        'title': '일정', 
        'color': Color(0xFF3182F6),
      },
      {'icon': Icons.local_mall, 'title': '쇼핑'},
      {'icon': Icons.airplane_ticket, 'title': '항공권'},
      {'icon': Icons.local_play, 'title': '공연티켓'},
      {'icon': Icons.restaurant, 'title': '맛집'},
    ];

    return _buildGridMenu(items);
  }

  Widget _buildInvestmentSection() {
    final items = [
      {'icon': Icons.trending_up, 'title': '주식'},
      {'icon': Icons.currency_bitcoin, 'title': '가상자산'},
      {'icon': Icons.savings, 'title': '적금'},
      {'icon': Icons.bar_chart, 'title': '펀드'},
    ];

    return _buildGridMenu(items);
  }

  Widget _buildBenefitsSection() {
    final items = [
      {'icon': Icons.redeem, 'title': '혜택'},
      {'icon': Icons.local_offer, 'title': '쿠폰함'},
      {'icon': Icons.card_giftcard, 'title': '이벤트'},
      {'icon': Icons.volunteer_activism, 'title': '친구 초대'},
    ];

    return _buildGridMenu(items);
  }

  Widget _buildGridMenu(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: item['onTap'] ?? () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item['color'] != null 
                    ? item['color'].withOpacity(0.1) 
                    : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'],
                  color: item['color'] ?? Colors.black87,
                  size: 24,
                ),
              ),
              SizedBox(height: 8),
              Text(
                item['title'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
} 