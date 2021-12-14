import 'package:bloc/bloc.dart';
import 'package:ceposto/models/restaurant.dart';
import 'package:ceposto/models/restaurant_response.dart';
import 'package:ceposto/network/rest_client.dart';
import 'package:equatable/equatable.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestClient restClient;

  RestaurantBloc({this.restClient}) : super(FetchingRestaurantState()) {
    on<FetchRestaurantEvent>((event, emit) async {
      emit.call(FetchingRestaurantState());
      //
      RestaurantResponse response;
      try {
        response = await restClient.RestaurantRes();
      } catch (error) {
        emit.call(ErrorRestaurantState(error.toString()));
      }

      if (response != null) {
        // se la richiesta e' andata a buon fine
        if (response.restaurants.isNotEmpty) {
          emit.call(FetchedRestaurantState(response.restaurants));
        } else {
          emit.call(NoRestaurantState());
        }
      } else {
        ErrorRestaurantState('Generic error');
      }
    });
  }

  void fetchRestaurant() =>
      add(FetchRestaurantEvent()); // semplicemente lancia l'evento
}
