import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../utils/constants.dart';

class RestaurantController extends ChangeNotifier {
  bool _isLoading = true;
  List<Restaurant> _restaurants = [];
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  bool get isLoading => _isLoading;
  List<Restaurant> get restaurants => _restaurants;
  String get searchQuery => _searchQuery;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  List<Restaurant> get filteredRestaurants {
    if (_searchQuery.isEmpty && _selectedCategoryIndex == 0) {
      return _restaurants;
    }

    return _restaurants.where((restaurant) {
      final matchesSearch = _searchQuery.isEmpty ||
          restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          restaurant.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategoryIndex == 0 ||
          restaurant.category == EatsConstants.categories[_selectedCategoryIndex];

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> loadRestaurants() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(EatsConstants.loadingDelay);

    _restaurants = [
      Restaurant(
        id: '1',
        name: '맛있는 비빔밥',
        category: '한식',
        imageUrl: 'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=800',
        imageAttribution: 'Photo by Jakub Kapusnak on Unsplash',
        rating: 4.8,
        reviewCount: 512,
        deliveryTime: '15-30분',
        deliveryFee: '3,000원',
        distance: 1.2,
        isPromoted: true,
        tags: ['신규', '할인'],
        description: '신선한 재료로 만드는 정통 한식 전문점입니다. 특히 비빔밥과 된장찌개가 인기 메뉴입니다.',
        address: '서울시 강남구 역삼동 123-45',
        phone: '02-123-4567',
        businessHours: ['월-금: 10:00 - 22:00', '주말: 11:00 - 22:00'],
        menuCategories: {
          '인기 메뉴': [
            MenuItem(
              id: 'm1',
              name: '고기 듬뿍 비빔밥',
              description: '국내산 소고기가 듬뿍 들어간 비빔밥',
              price: 12000,
              imageUrl: 'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=400',
              isPopular: true,
            ),
            MenuItem(
              id: 'm2',
              name: '돌솥 비빔밥',
              description: '뜨거운 돌솥에 비빔밥을 담아 드립니다',
              price: 13000,
              imageUrl: 'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=400',
              isPopular: true,
            ),
          ],
          '식사 메뉴': [
            MenuItem(
              id: 'm3',
              name: '된장찌개',
              description: '구수한 된장으로 맛을 낸 전통 된장찌개',
              price: 8000,
              imageUrl: 'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=400',
            ),
            MenuItem(
              id: 'm4',
              name: '김치찌개',
              description: '묵은지로 맛을 낸 얼큰한 김치찌개',
              price: 8000,
              imageUrl: 'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=400',
            ),
          ],
        },
      ),
      Restaurant(
        id: '2',
        name: '모던 스시',
        category: '일식',
        imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800',
        imageAttribution: 'Photo by Leon Bublitz on Unsplash',
        rating: 4.9,
        reviewCount: 821,
        deliveryTime: '20-35분',
        deliveryFee: '4,000원',
        distance: 2.1,
        isPromoted: true,
        tags: ['프리미엄', '신규'],
        description: '신선한 해산물로 만드는 프리미엄 스시. 특급 호텔 출신 셰프가 직접 만듭니다.',
        address: '서울시 강남구 청담동 456-78',
        phone: '02-234-5678',
        businessHours: ['매일: 11:30 - 22:00', '브레이크타임: 15:00 - 17:00'],
        menuCategories: {
          '인기 메뉴': [
            MenuItem(
              id: 's1',
              name: '모던 스시 특선 10pc',
              description: '셰프가 엄선한 10가지 스시',
              price: 35000,
              imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
              isPopular: true,
            ),
            MenuItem(
              id: 's2',
              name: '연어 스시 5pc',
              description: '노르웨이산 프리미엄 연어로 만든 스시',
              price: 18000,
              imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
              isPopular: true,
            ),
          ],
          '사시미': [
            MenuItem(
              id: 's3',
              name: '모둠 사시미',
              description: '신선한 회 모둠',
              price: 45000,
              imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
            ),
          ],
        },
      ),
      Restaurant(
        id: '3',
        name: '화덕피자 공방',
        category: '피자',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800',
        imageAttribution: 'Photo by Ivan Torres on Unsplash',
        rating: 4.7,
        reviewCount: 1243,
        deliveryTime: '25-40분',
        deliveryFee: '3,000원',
        distance: 1.8,
        tags: ['할인', '인기'],
        description: '나폴리 정통 화덕피자 전문점. 이탈리아산 밀가루와 토마토로 만듭니다.',
        address: '서울시 강남구 삼성동 789-10',
        phone: '02-345-6789',
        businessHours: ['매일: 11:00 - 22:00'],
        menuCategories: {
          '인기 메뉴': [
            MenuItem(
              id: 'p1',
              name: '마르게리타 피자',
              description: '토마토 소스, 모짜렐라, 바질',
              price: 18000,
              imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
              isPopular: true,
            ),
            MenuItem(
              id: 'p2',
              name: '디아볼라 피자',
              description: '매운 살라미가 올라간 화덕피자',
              price: 20000,
              imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
              isPopular: true,
            ),
          ],
        },
      ),
      Restaurant(
        id: '4',
        name: '홍콩반점',
        category: '중식',
        imageUrl: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=800',
        imageAttribution: 'Photo by Mgg Vitchakorn on Unsplash',
        rating: 4.5,
        reviewCount: 2891,
        deliveryTime: '15-30분',
        deliveryFee: '2,000원',
        distance: 0.8,
        tags: ['할인', '베스트'],
        description: '30년 전통의 중화요리 전문점. 신선한 재료로 정성껏 만듭니다.',
        address: '서울시 강남구 역삼동 345-67',
        phone: '02-456-7890',
        businessHours: ['매일: 11:00 - 21:30'],
        menuCategories: {
          '인기 메뉴': [
            MenuItem(
              id: 'c1',
              name: '짜장면',
              description: '춘장과 돼지고기로 만든 정통 짜장면',
              price: 7000,
              imageUrl: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=400',
              isPopular: true,
            ),
            MenuItem(
              id: 'c2',
              name: '짬뽕',
              description: '해산물이 듬뿍 들어간 얼큰한 짬뽕',
              price: 8000,
              imageUrl: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=400',
              isPopular: true,
            ),
          ],
          '식사 메뉴': [
            MenuItem(
              id: 'c3',
              name: '탕수육',
              description: '바삭한 튀김과 새콤달콤한 소스의 조화',
              price: 20000,
              imageUrl: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=400',
            ),
          ],
        },
      ),
      Restaurant(
        id: '5',
        name: '스타벅스 강남점',
        category: '카페',
        imageUrl: 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?w=800',
        imageAttribution: 'Photo by Fahmi Fakhrudin on Unsplash',
        rating: 4.6,
        reviewCount: 3421,
        deliveryTime: '10-20분',
        deliveryFee: '3,500원',
        distance: 0.3,
        isPromoted: true,
        tags: ['신규', '프리미엄'],
        description: '편안한 분위기에서 즐기는 프리미엄 커피와 디저트',
        address: '서울시 강남구 역삼동 234-56',
        phone: '02-567-8901',
        businessHours: ['매일: 07:00 - 21:00'],
        menuCategories: {
          '인기 메뉴': [
            MenuItem(
              id: 'sb1',
              name: '아메리카노',
              description: '깊고 진한 에스프레소와 뜨거운 물의 조화',
              price: 4500,
              imageUrl: 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?w=400',
              isPopular: true,
            ),
            MenuItem(
              id: 'sb2',
              name: '카페 라떼',
              description: '에스프레소와 스팀 밀크가 어우러진 클래식 라떼',
              price: 5000,
              imageUrl: 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?w=400',
              isPopular: true,
            ),
          ],
          '디저트': [
            MenuItem(
              id: 'sb3',
              name: '티라미수',
              description: '커피 향이 가득한 이탈리안 디저트',
              price: 6500,
              imageUrl: 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?w=400',
            ),
          ],
        },
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSelectedCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  Restaurant? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      return null;
    }
  }
} 