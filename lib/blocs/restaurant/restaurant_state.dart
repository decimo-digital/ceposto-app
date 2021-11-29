part of 'restaurant_bloc.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();
}

class FetchingRestaurantState extends RestaurantState {
  @override
  List<Object> get props => [];
}

class FetchedRestaurantState extends RestaurantState {
  final List<Restaurant> restaurant;

  FetchedRestaurantState(this.restaurant);

  @override
  List<Object> get props => [restaurant];
}

class NoRestaurantState extends RestaurantState {
  @override
  List<Object> get props => [];
}

class ErrorRestaurantState extends RestaurantState {
  final String error;

  ErrorRestaurantState(this.error);

  @override
  List<Object> get props => [error];
}
