import 'package:burningbros_test/models/product_response.dart';
import 'package:equatable/equatable.dart';

enum LoadStatus { initial, loading, success, failure, noData, endReached }

class ProductListState extends Equatable {
  final List<Product> productList;
  final List<int> favoriteIds;
  final LoadStatus loadStatus;
  final bool isLoadingMore;
  final String? errorMessage;

  const ProductListState({
    this.productList = const [],
    this.favoriteIds = const [],
    this.loadStatus = LoadStatus.initial,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  ProductListState copyWith({
    List<Product>? productList,
    List<int>? favoriteIds,
    LoadStatus? loadStatus,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return ProductListState(
      productList: productList ?? this.productList,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      loadStatus: loadStatus ?? this.loadStatus,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    productList,
    favoriteIds,
    loadStatus,
    isLoadingMore,
    errorMessage,
  ];
}
