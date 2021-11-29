part of 'restaurant_bloc.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();
}

class FetchRestaurantEvent extends RestaurantEvent {
  //serve per richiedere la lista dei ristoranti
  @override
  List<Object> get props => [];
}
