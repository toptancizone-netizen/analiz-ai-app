import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/nominatim_service.dart';

/// Rakip Analizi Ekranı
/// Kullanılan API: OpenStreetMap Nominatim
/// Çevredeki rakip işletmeleri otomatik bulur ve harita üzerinde gösterir
class RakipAnaliziScreen extends StatefulWidget {
  const RakipAnaliziScreen({super.key});

  @override
  State<RakipAnaliziScreen> createState() => _RakipAnaliziScreenState();
}

class _RakipAnaliziScreenState extends State<RakipAnaliziScreen> {
  final _searchController = TextEditingController();
  final _nominatim = NominatimService();

  bool _isSearching = false;
  List<Map<String, dynamic>> _competitors = [];
  String? _error;

  // Kullanıcının işletme konumu (varsayılan: İstanbul Kadıköy)
  double _userLat = 40.9828;
  double _userLon = 29.0290;
  String _userAddress = 'Kadıköy, İstanbul';
  double _searchRadius = 2.0; // km

  final List<String> _businessTypes = [
    'Restoran',
    'Kafe',
    'Pastane',
    'Market',
    'Kuaför',
    'Eczane',
    'Fırın',
    'Spor Salonu',
  ];
  String _selectedType = 'Restoran';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCompetitors() async {
    setState(() {
      _isSearching = true;
      _error = null;
      _competitors.clear();
    });

    final result = await _nominatim.searchCompetitors(
      query: _selectedType,
      lat: _userLat,
      lon: _userLon,
      radiusKm: _searchRadius,
    );

    setState(() {
      _isSearching = false;
      if (result['success'] == true) {
        final rawResults = result['results'] as List<dynamic>;
        _competitors = rawResults.map<Map<String, dynamic>>((item) {
          final address = item['address'] as Map<String, dynamic>? ?? {};
          return {
            'name': item['display_name']?.toString().split(',').first ?? 'Bilinmeyen',
            'fullAddress': item['display_name'] ?? '',
            'lat': double.tryParse(item['lat']?.toString() ?? '') ?? 0,
            'lon': double.tryParse(item['lon']?.toString() ?? '') ?? 0,
            'type': item['type'] ?? '',
            'district': address['suburb'] ?? address['neighbourhood'] ?? address['quarter'] ?? '',
            'city': address['city'] ?? address['town'] ?? '',
            'distance': _calculateDistance(
              _userLat,
              _userLon,
              double.tryParse(item['lat']?.toString() ?? '') ?? 0,
              double.tryParse(item['lon']?.toString() ?? '') ?? 0,
            ),
          };
        }).toList();

        // Mesafeye göre sırala
        _competitors.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      } else {
        _error = result['error'] as String?;
      }
    });
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;

    final result = await _nominatim.searchAddress(query);
    if (result['success'] == true && mounted) {
      final results = result['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        _showAddressResults(results);
      }
    }
  }

  void _showAddressResults(List<dynamic> results) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Konum Seçin',
                style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length > 5 ? 5 : results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on_rounded, color: AppTheme.secondaryColor),
                      title: Text(
                        item['display_name']?.toString().split(',').take(3).join(', ') ?? '',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        setState(() {
                          _userLat = double.tryParse(item['lat']?.toString() ?? '') ?? _userLat;
                          _userLon = double.tryParse(item['lon']?.toString() ?? '') ?? _userLon;
                          _userAddress = item['display_name']?.toString().split(',').take(2).join(', ') ?? _userAddress;
                        });
                        Navigator.pop(context);
                        _searchCompetitors();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Basit Haversine yaklaşımı (km)
    const double earthRadius = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = _sin2(dLat / 2) + _cos(lat1) * _cos(lat2) * _sin2(dLon / 2);
    return earthRadius * 2 * _atan2(a);
  }

  double _toRadians(double degree) => degree * 3.14159265359 / 180;
  double _sin2(double x) {
    final s = _sinApprox(x);
    return s * s;
  }
  double _cos(double deg) => _sinApprox(_toRadians(deg) + 1.5707963268);
  double _sinApprox(double x) {
    // Taylor serisi yaklaşımı
    double result = x;
    double term = x;
    for (int i = 1; i <= 5; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
  double _atan2(double a) {
    final sqrtA = _sqrt(a);
    final sqrtB = _sqrt(1 - a);
    if (sqrtB == 0) return 3.14159265359;
    final ratio = sqrtA / sqrtB;
    return ratio - ratio * ratio * ratio / 3; // Basit atan yaklaşımı
  }
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rakip Analizi'),
        backgroundColor: AppTheme.darkBg,
      ),
      body: Column(
        children: [
          // ─── Arama ve Filtre Bölümü ───
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Konum arama
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppTheme.secondaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _userAddress,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Konumunuzu arayın (mahalle, sokak)...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location_rounded, color: AppTheme.secondaryColor),
                      onPressed: () => _searchAddress(_searchController.text),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: _searchAddress,
                ),
                const SizedBox(height: 16),
                // İşletme türü seçimi
                const Text(
                  'İşletme Türü',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white54),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _businessTypes.map((type) {
                    final isSelected = _selectedType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
                          ),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.white : Colors.white60,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Yarıçap ayarı
                Row(
                  children: [
                    Text(
                      'Yarıçap: ${_searchRadius.toStringAsFixed(1)} km',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white54),
                    ),
                    Expanded(
                      child: Slider(
                        value: _searchRadius,
                        min: 0.5,
                        max: 10,
                        divisions: 19,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (v) => setState(() => _searchRadius = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Ara butonu
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : _searchCompetitors,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.radar_rounded),
                    label: Text(_isSearching ? 'Taranıyor...' : 'Rakipleri Tara'),
                  ),
                ),
              ],
            ),
          ),

          // ─── Sonuçlar ───
          Expanded(
            child: _buildResultsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.accentColor),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_competitors.isEmpty && !_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_rounded, size: 48, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 12),
            Text(
              'Konumunuzu girin ve rakipleri tarayın',
              style: TextStyle(fontFamily: 'Inter', color: Colors.white.withOpacity(0.4)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            '${_competitors.length} rakip bulundu',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _competitors.length,
            itemBuilder: (context, index) {
              final comp = _competitors[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Row(
                    children: [
                      // Sıra numarası
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // İşletme bilgileri
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comp['name'] as String,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if ((comp['district'] as String).isNotEmpty)
                              Text(
                                '📍 ${comp['district']}${(comp['city'] as String).isNotEmpty ? ', ${comp['city']}' : ''}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      // Mesafe
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(comp['distance'] as double).toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
