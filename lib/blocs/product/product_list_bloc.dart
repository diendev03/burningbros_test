import 'package:burningbros_test/blocs/product/product_list_event.dart';
import 'package:burningbros_test/blocs/product/product_list_state.dart';
import 'package:burningbros_test/data/api_provider.dart';
import 'package:burningbros_test/data/hive_config.dart';
import 'package:burningbros_test/utils/app_res.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  int currentPage = 1;
  final int limit = 20;

  ProductListBloc() : super(const ProductListState()) {
    on<GetProductList>((event, emit) async {
      if (state.isLoadingMore) return;
      try {
        if((await AppRes().checkInternet())==false){
          emit(state.copyWith(loadStatus:LoadStatus.failure,errorMessage: "No internet connection. Please check your wifi or mobile data."));
          return;
        }
        final isRefresh = event.isRefresh ?? false;

        if (isRefresh) {
          emit(state.copyWith(loadStatus: LoadStatus.loading));
          currentPage = 0;
        } else {
          emit(state.copyWith(isLoadingMore: true));
        }

        final response = await ApiProvider().fetchProducts(
          searchText: event.searchText,
          limit: limit,
          skip: currentPage * limit,
        );

        final newList = isRefresh
            ? response.products
            : [...state.productList, ...response.products];

        if (newList.isEmpty) {
          emit(state.copyWith(
            loadStatus: LoadStatus.noData,
            isLoadingMore: false,
            productList: newList,
          ));
        } else {
          final isEndReached = response.products.length < limit;
          emit(state.copyWith(
            loadStatus: LoadStatus.success,
            productList: newList.toSet().toList(),
            isLoadingMore: false,
          ));
          if (!isRefresh) currentPage++;

          if (isEndReached) {
            emit(state.copyWith(loadStatus: LoadStatus.endReached));
          }
        }
      } catch (e) {
        emit(state.copyWith(
          loadStatus: LoadStatus.failure,
          errorMessage: e.toString(),
          isLoadingMore: false,
        ));
      }
    });

    on<ToggleFavorite>((event, emit) {
      final updatedFavorites = List<int>.from(state.favoriteIds);
      if (updatedFavorites.contains(event.productId)) {
        updatedFavorites.remove(event.productId);
        HiveConfig.removeFavorite(event.productId);
      } else {
        updatedFavorites.add(event.productId);
        HiveConfig.addFavorite(event.productId);
      }
      emit(state.copyWith(favoriteIds: updatedFavorites));
    });
  }
}
