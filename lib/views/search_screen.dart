import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../models/location_model.dart';
import '../core/theme.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/error_state_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    // load favorit dari storage saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 8),

            // Search input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchInput(context),
            ),
            const SizedBox(height: 16),

            // Body
            Expanded(
              child: Consumer<SearchViewModel>(
                builder: (context, vm, _) {
                  if (_showSearch) {
                    return _buildSearchResults(context, vm);
                  }
                  return _buildFavorites(context, vm);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.canvasSoft,
              foregroundColor: AppColors.ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.hairline),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Lokasi',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  // search input textfield
  Widget _buildSearchInput(BuildContext context) {
    return TextField(
      controller: _searchController,
      style: Theme.of(context).textTheme.bodyMedium,
      onChanged: (query) {
        setState(() => _showSearch = query.isNotEmpty);
        context.read<SearchViewModel>().searchLocations(query);
      },
      onSubmitted: (query) {
        if (query.isNotEmpty) {
          context.read<SearchViewModel>().searchLocations(query);
        }
      },
      decoration: InputDecoration(
        hintText: 'Cari nama kota...',
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.inkMute2, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _showSearch = false);
                  context.read<SearchViewModel>().clearSearch();
                },
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.inkMute2, size: 18),
              )
            : null,
      ),
    );
  }

  // build search results list
  Widget _buildSearchResults(BuildContext context, SearchViewModel vm) {
    if (vm.state == SearchState.loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
            SizedBox(height: 12),
            Text(
              'Mencari lokasi...',
              style: TextStyle(color: AppColors.inkMute, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (vm.state == SearchState.error) {
      return ErrorStateWidget(
        message: vm.errorMessage ?? 'Gagal mencari lokasi.',
        onRetry: () =>
            context.read<SearchViewModel>().searchLocations(_searchController.text),
      );
    }

    if (vm.state == SearchState.empty || vm.searchResults.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.location_searching_rounded,
        title: 'Kota Tidak Ditemukan',
        subtitle:
            'Coba nama kota lain atau periksa ejaan yang Anda masukkan.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vm.searchResults.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.hairlineCool),
      itemBuilder: (context, index) {
        final location = vm.searchResults[index];
        return _buildLocationTile(
          context: context,
          vm: vm,
          location: location,
          showFavoriteToggle: true,
        );
      },
    );
  }

  Widget _buildFavorites(BuildContext context, SearchViewModel vm) {
    final favorites = vm.favorites;

    if (favorites.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.favorite_border_rounded,
        title: 'Belum Ada Favorit',
        subtitle:
            'Cari kota lalu tekan ikon bintang untuk menyimpan ke favorit.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Lokasi Favorit',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: favorites.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.hairlineCool),
            itemBuilder: (context, index) {
              final location = favorites[index];
              return _buildLocationTile(
                context: context,
                vm: vm,
                location: location,
                showFavoriteToggle: true,
                isFavoriteList: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTile({
    required BuildContext context,
    required SearchViewModel vm,
    required LocationModel location,
    bool showFavoriteToggle = false,
    bool isFavoriteList = false,
  }) {
    final isFav = vm.isFavorite(location);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.canvasSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.hairline),
        ),
        child: const Icon(
          Icons.location_city_rounded,
          color: AppColors.inkMute2,
          size: 20,
        ),
      ),
      title: Text(
        location.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        [
          if (location.admin1 != null) location.admin1!,
          if (location.country != null) location.country!,
        ].join(', '),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.inkMute,
            ),
      ),
      trailing: showFavoriteToggle
          ? IconButton(
              onPressed: () => vm.toggleFavorite(location),
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFav ? AppColors.accentYellow : AppColors.inkMute2,
                size: 22,
              ),
              tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
            )
          : null,
      onTap: () => _selectLocation(context, location),
    );
  }

  Future<void> _selectLocation(
      BuildContext context, LocationModel location) async {
    // Panggil WeatherViewModel untuk load cuaca kota baru
    await context.read<WeatherViewModel>().selectLocation(location);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
