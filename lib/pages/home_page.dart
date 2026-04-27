import 'package:flutter/material.dart';

// ignore_for_file: unused_element, unused_field

import 'cart_page.dart';
import '../models/app_car.dart';
import 'profile_page.dart';
import 'sign_in_page.dart';
import 'favorites_page.dart';
import 'product_detail_page.dart';
import '../services/auth_service.dart';
import '../services/app_database.dart';
import '../widgets/hover_tap.dart';
import '../widgets/car_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _featuredPageController = PageController(viewportFraction: 0.88);
  late Future<List<AppCar>> _carsFuture;
  late Future<Set<int>> _favoriteIdsFuture;
  String _selectedBrand = 'All Brands';
  String _selectedModernFilter = 'All Brands';
  int _modernBottomIndex = 0;
  int _featuredIndex = 0;
  final Set<int> _compareCarIds = <int>{};

  bool get _isFiltering {
    return _searchController.text.trim().isNotEmpty || _selectedBrand != 'All Brands';
  }

  @override
  void initState() {
    super.initState();
    _carsFuture = AppDatabase.instance.getCars();
    _favoriteIdsFuture = AppDatabase.instance.getFavoriteCarIds();
    _refreshCars();
  }

  Future<void> _refreshCars() async {
    setState(() {
      _carsFuture = AppDatabase.instance.getCars();
      _favoriteIdsFuture = AppDatabase.instance.getFavoriteCarIds();
    });
  }

  Future<void> _toggleFavorite(AppCar car) async {
    if (car.id == null) return;
    await AppDatabase.instance.toggleFavoriteCar(car.id!);
    if (!mounted) return;
    setState(() {
      _favoriteIdsFuture = AppDatabase.instance.getFavoriteCarIds();
    });
  }

  void _toggleCompare(AppCar car) {
    if (car.id == null) return;
    setState(() {
      if (_compareCarIds.contains(car.id)) {
        _compareCarIds.remove(car.id);
      } else {
        if (_compareCarIds.length >= 2) {
          _compareCarIds.remove(_compareCarIds.first);
        }
        _compareCarIds.add(car.id!);
      }
    });
  }

  void _openCompareSheet(List<AppCar> allCars) {
    final selected =
        allCars.where((car) => car.id != null && _compareCarIds.contains(car.id)).toList();
    if (selected.length < 2) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Compare Cars',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _compareRow(
                'Model',
                '${selected[0].brand} ${selected[0].model}',
                '${selected[1].brand} ${selected[1].model}',
              ),
              _compareRow(
                'Price',
                '\$${selected[0].price.toStringAsFixed(0)}',
                '\$${selected[1].price.toStringAsFixed(0)}',
              ),
              _compareRow('Stock', '${selected[0].stock}', '${selected[1].stock}'),
              _compareRow(
                'Featured',
                selected[0].isFeatured ? 'Yes' : 'No',
                selected[1].isFeatured ? 'Yes' : 'No',
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _compareRow(String title, String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(left)),
          Expanded(child: Text(right)),
        ],
      ),
    );
  }

  final List<String> brands = [
    'All Brands',
    'Tesla',
    'BMW',
    'Mercedes',
    'Audi',
    'Porsche',
    'Ferrari',
    'Lamborghini',
    'Toyota',
    'Honda',
  ];

  final List<Map<String, String>> popularCars = [
    {
      'title': 'C-Class',
      'brand': 'Mercedes',
      'price': '\$54,200',
    },
    {
      'title': 'R8 Spyder',
      'brand': 'Audi',
      'price': '\$201,200',
    },
    {
      'title': '911 Turbo',
      'brand': 'Porsche',
      'price': '\$184,300',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppCar>>(
      future: _carsFuture,
      builder: (context, carsSnapshot) {
        return FutureBuilder<Set<int>>(
          future: _favoriteIdsFuture,
          builder: (context, favSnapshot) {
            final cars = carsSnapshot.data ?? <AppCar>[];
            final favoriteIds = favSnapshot.data ?? <int>{};
            final filtered = _applyModernFilters(cars);
            final featured = filtered.where((c) => c.isFeatured).toList();

            return Scaffold(
              backgroundColor: const Color(0xFF0F172A),
              bottomNavigationBar: _buildModernBottomNav(),
              floatingActionButton: _compareCarIds.length >= 2
                  ? FloatingActionButton.extended(
                      backgroundColor: const Color(0xFF2563EB),
                      onPressed: () => _openCompareSheet(cars),
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text('Compare'),
                    )
                  : null,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildModernHeader(),
                    const SizedBox(height: 10),
                    _buildModernSearchBar(),
                    const SizedBox(height: 10),
                    _buildModernFilterChips(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _buildModernCarList(
                        allCars: filtered,
                        featuredCars: featured,
                        favoriteIds: favoriteIds,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Car Dealer',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
                },
                icon: const Icon(Icons.favorite_border, color: Colors.white),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
                },
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search cars...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: _searchController.text.trim().isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildModernFilterChips() {
    const filters = [
      'All Brands',
      'BMW',
      'Mercedes',
      'Audi',
      'Proche',
      'Tesla',
      'Volkswagen',
      'Amborghini',
      'Ferrari',
    ];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _selectedModernFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedModernFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2563EB) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(filter, style: const TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }

  List<AppCar> _applyModernFilters(List<AppCar> cars) {
    final q = _searchController.text.trim().toLowerCase();
    return cars.where((car) {
      final text = '${car.brand} ${car.model} ${car.description}'.toLowerCase();
      final searchOk = q.isEmpty || text.contains(q);
      final selectedBrand = _normalizedBrandFilter(_selectedModernFilter);
      final brandOk = selectedBrand == 'all brands' ||
          car.brand.toLowerCase() == selectedBrand;
      return searchOk && brandOk;
    }).toList();
  }

  String _normalizedBrandFilter(String value) {
    final key = value.trim().toLowerCase();
    if (key == 'proche') return 'porsche';
    if (key == 'amborghini') return 'lamborghini';
    return key;
  }

  String _inferType(AppCar car) {
    final text = '${car.brand} ${car.model} ${car.description}'.toLowerCase();
    if (text.contains('suv') || text.contains('crossover')) return 'SUV';
    if (text.contains('electric') || text.contains('ev') || car.brand.toLowerCase() == 'tesla') {
      return 'Electric';
    }
    if (car.price >= 100000 || car.isFeatured) return 'Luxury';
    return 'Sedan';
  }

  Widget _buildModernCarList({
    required List<AppCar> allCars,
    required List<AppCar> featuredCars,
    required Set<int> favoriteIds,
  }) {
    return RefreshIndicator(
      onRefresh: _refreshCars,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Featured Cars',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (featuredCars.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'No featured cars for this filter.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else ...[
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _featuredPageController,
                itemCount: featuredCars.length,
                onPageChanged: (index) => setState(() => _featuredIndex = index),
                itemBuilder: (context, index) {
                  final car = featuredCars[index];
                  final isFavorite = car.id != null && favoriteIds.contains(car.id);
                  final isCompared = car.id != null && _compareCarIds.contains(car.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildModernCarCard(
                      car,
                      isFavorite: isFavorite,
                      isCompared: isCompared,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProductDetailPage(car: car)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _featuredIndex > 0
                      ? () {
                          _featuredPageController.previousPage(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left, color: Colors.white70),
                ),
                IconButton(
                  onPressed: _featuredIndex < featuredCars.length - 1
                      ? () {
                          _featuredPageController.nextPage(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right, color: Colors.white70),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'All Cars',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (allCars.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('No cars match your search.', style: TextStyle(color: Colors.white70)),
            )
          else
            ...allCars.map((car) {
              final isFavorite = car.id != null && favoriteIds.contains(car.id);
              final isCompared = car.id != null && _compareCarIds.contains(car.id);
              return _buildModernCarCard(
                car,
                isFavorite: isFavorite,
                isCompared: isCompared,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailPage(car: car)),
                  );
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _buildModernCarCard(
    AppCar car, {
    required bool isFavorite,
    required bool isCompared,
    required VoidCallback onTap,
  }) {
    final imagePath = (car.imageUrl ?? '').trim();
    final hasImage = imagePath.isNotEmpty;
    final isNetworkImage = imagePath.startsWith('http://') || imagePath.startsWith('https://');
    return HoverTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      hoverScale: 1.015,
      hoverColor: Colors.white.withOpacity(0.05),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                CarImage(
                  source: imagePath,
                  fit: BoxFit.cover,
                  placeholder: const SizedBox.shrink(),
                ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.72), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.brand} ${car.model}',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '\$${car.price.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _toggleFavorite(car),
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _toggleCompare(car),
                          icon: Icon(Icons.compare_arrows, color: isCompared ? Colors.yellowAccent : Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return BottomNavigationBar(
      currentIndex: _modernBottomIndex,
      onTap: (index) async {
        setState(() => _modernBottomIndex = index);
        if (index == 1) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
        } else if (index == 2) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
        } else if (index == 3) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AuthService.isSignedIn ? const ProfilePage() : const SignInPage(),
            ),
          );
        }
        if (!mounted) return;
        await _refreshCars();
      },
      backgroundColor: const Color(0xFF020617),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }

  Widget _buildFixedBackgroundDecoration() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 360,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2C5C), Color(0xFF184A93), Color(0xFF2D7FF9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: -40,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 24,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.directions_car, color: Colors.white, size: 34),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.16),
            Colors.white.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -14,
              top: -18,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 14,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.directions_car, color: Colors.white, size: 38),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        child: const Text(
                          'Premium Collection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: const Text(
                      'Exclusive deals and premium rides',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Find Your Next Ride',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Browse premium models, compare prices and book a test drive instantly.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _buildStatCard('120+', 'Models'),
                      _buildStatCard('4.9', 'Rating'),
                      _buildStatCard('24h', 'Support'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.search, color: Color(0xFF4A90E2)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Search for cars',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Find a brand, model or style instantly.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F8FC),
              hintText: 'Search by brand, model or type',
              prefixIcon: const Icon(Icons.manage_search_outlined),
              suffixIcon: _searchController.text.trim().isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : const Icon(Icons.tune),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Popular brands',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final isSelected = _selectedBrand == brand;
                return Padding(
                  padding: EdgeInsets.only(right: index == brands.length - 1 ? 0 : 8),
                  child: ChoiceChip(
                    label: Text(brand),
                    selected: isSelected,
                    backgroundColor: const Color(0xFFF4F7FB),
                    selectedColor: const Color(0xFF1E64D6),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF1E64D6) : Colors.transparent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedBrand = brand;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildFeaturedPicksSection() {
    return FutureBuilder<List<AppCar>>(
      future: _getFeaturedCars(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final featuredCars = snapshot.data!;

        if (featuredCars.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text('No featured cars yet. Admin can mark cars as featured.'),
          );
        }

        if (_featuredIndex >= featuredCars.length) {
          _featuredIndex = 0;
        }

        return FutureBuilder<Set<int>>(
          future: _favoriteIdsFuture,
          builder: (context, favSnapshot) {
            final favoriteIds = favSnapshot.data ?? <int>{};
            return Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _featuredPageController,
                    scrollDirection: Axis.horizontal,
                    physics: const PageScrollPhysics(),
                    itemCount: featuredCars.length,
                    onPageChanged: (index) {
                      setState(() {
                        _featuredIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final car = featuredCars[index];
                      final isFavorite = car.id != null && favoriteIds.contains(car.id);
                      final isCompared = car.id != null && _compareCarIds.contains(car.id);
                      return _buildFeaturedCarCard(
                        car,
                        isFavorite: isFavorite,
                        isCompared: isCompared,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Previous featured car',
                        onPressed: _featuredIndex > 0
                            ? () {
                                _featuredPageController.previousPage(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOut,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        tooltip: 'Next featured car',
                        onPressed: _featuredIndex < featuredCars.length - 1
                            ? () {
                                _featuredPageController.nextPage(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOut,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            );
          },
        );
      },
    );
  }

  List<AppCar> _filterCars(List<AppCar> cars) {
    final query = _searchController.text.trim().toLowerCase();
    return cars.where((car) {
      final matchesBrand = _selectedBrand == 'All Brands' || car.brand.toLowerCase() == _selectedBrand.toLowerCase();
      final matchesSearch = query.isEmpty ||
          car.brand.toLowerCase().contains(query) ||
          car.model.toLowerCase().contains(query) ||
          car.description.toLowerCase().contains(query);
      return matchesBrand && matchesSearch;
    }).toList();
  }

  Widget _buildSearchResultsSection(
    List<AppCar> cars, {
    required List<AppCar> allCars,
    required Set<int> favoriteIds,
  }) {
    final title = _searchController.text.trim().isNotEmpty
        ? 'Search Results'
        : 'Brand Results';

    final subtitle = _searchController.text.trim().isNotEmpty
        ? 'Matching cars found on this page'
        : 'All cars for $_selectedBrand';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedBrand = 'All Brands';
                    _compareCarIds.clear();
                  });
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_searchController.text.trim().isNotEmpty)
                InputChip(
                  label: Text('Search: ${_searchController.text.trim()}'),
                  onDeleted: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              if (_selectedBrand != 'All Brands')
                InputChip(
                  label: Text('Brand: $_selectedBrand'),
                  onDeleted: () {
                    setState(() {
                      _selectedBrand = 'All Brands';
                    });
                  },
                ),
              Chip(
                label: Text('${cars.length} found'),
                avatar: const Icon(Icons.filter_alt_outlined, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_compareCarIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBDD3FF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.compare_arrows, color: Color(0xFF1E64D6)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _compareCarIds.length < 2
                          ? 'Select 2 cars to compare'
                          : 'Ready to compare ${_compareCarIds.length} cars',
                    ),
                  ),
                  TextButton(
                    onPressed: _compareCarIds.length >= 2
                        ? () => _openCompareSheet(allCars)
                        : null,
                    child: const Text('Compare now'),
                  ),
                ],
              ),
            ),
          ),
        if (cars.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Text('No cars match your search.'),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cars.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final car = cars[index];
              final isFavorite = car.id != null && favoriteIds.contains(car.id);
              final isCompared = car.id != null && _compareCarIds.contains(car.id);
              return _buildSearchResultCard(
                car,
                isFavorite: isFavorite,
                isCompared: isCompared,
              );
            },
          ),
      ],
    );
  }

  Widget _buildSearchResultCard(
    AppCar car, {
    required bool isFavorite,
    required bool isCompared,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.directions_car, color: Color(0xFF4A90E2), size: 42),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.brand,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  car.model,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  car.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '\$${car.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF4A90E2),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _toggleFavorite(car),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey.shade600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _toggleCompare(car),
                      icon: Icon(
                        Icons.compare_arrows,
                        color: isCompared ? Colors.deepPurple : Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: car.stock > 0 ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        car.stock > 0 ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          color: car.stock > 0 ? Colors.green.shade700 : Colors.red.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<AppCar>> _getFeaturedCars() async {
    final cars = await AppDatabase.instance.getCars();
    return cars.where((car) => car.isFeatured).toList();
  }

  Widget _buildFeaturedCarCard(
    AppCar car, {
    required bool isFavorite,
    required bool isCompared,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF4075D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    car.stock > 0 ? 'In Stock' : 'Out of Stock',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  car.model,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  car.brand,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${car.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _toggleFavorite(car),
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _toggleCompare(car),
                          icon: Icon(
                            Icons.compare_arrows,
                            color: isCompared ? Colors.yellowAccent : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 24,
            bottom: 24,
            width: 140,
            child: Stack(
              children: [
                Positioned(
                  right: 16,
                  top: 0,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCarCard(Map<String, String> car) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car,
                color: Color(0xFF4A90E2),
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            car['title'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            car['brand'] ?? '',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            car['price'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF4A90E2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.local_offer,
                color: Color(0xFF4A90E2),
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Get 10% off on your first purchase',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use code NEWDRIVE at checkout and secure your favorite car today.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoritesPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AuthService.isSignedIn
                  ? const ProfilePage()
                  : const SignInPage(),
            ),
          );
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4A90E2),
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  @override
  void dispose() {
    _featuredPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
