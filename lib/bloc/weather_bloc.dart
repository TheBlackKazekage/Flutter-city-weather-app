import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:the_project_down_under/model/weather.dart';
import 'package:the_project_down_under/repository/weather_repository.dart';

abstract class WeatherEvent extends Equatable{
	const WeatherEvent();
}

class FetchWeather extends WeatherEvent {
	final String city;

	const FetchWeather({@required this.city}) : assert(city != null);

	@override
	List<Object> get props => [city];
}

class RefreshWeather extends WeatherEvent {
	final String city;

	const RefreshWeather({@required this.city}) : assert(city != null);

	@override
	List<Object> get props => [city];
}

abstract class WeatherState extends Equatable {
	const WeatherState();
}

class WeatherEmpty extends WeatherState{
  @override
  List<Object> get props => [];
}

class WeatherLoading extends WeatherState{
  @override
  List<Object> get props => [];
}

class WeatherLoaded extends WeatherState{
	final Weather weather;

	const WeatherLoaded({@required this.weather}) : assert(weather != null);

	@override
	List<Object> get props => [];
}

class WeatherError extends WeatherState{
	@override
	List<Object> get props => [];
}

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
	final WeatherRepository weatherRepository;

	WeatherBloc({@required this.weatherRepository}) : assert(weatherRepository != null);

	@override
	WeatherState get initialState => WeatherEmpty();

	@override
	Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
		if (event is FetchWeather) {
			yield WeatherLoading();
			try {
				final Weather weather = await weatherRepository.getWeather(event.city);
				yield WeatherLoaded(weather: weather);
			} catch (_) {
				print(_);
				yield WeatherError();
			}
		}

		if (event is RefreshWeather) {
			try {
				final Weather weather = await weatherRepository.getWeather(event.city);
				yield WeatherLoaded(weather: weather);
			} catch (_) {
				print(_);
				yield state;
			}
		}
	}
}
