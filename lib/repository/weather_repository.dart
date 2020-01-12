import 'package:flutter/cupertino.dart';
import 'package:the_project_down_under/model/weather.dart';
import 'package:the_project_down_under/provider/weather_api_client.dart';

class WeatherRepository {
	final WeatherApiClient weatherApiClient;

	WeatherRepository({@required this.weatherApiClient}) : assert(weatherApiClient != null);

	Future<Weather> getWeather(String city) async {
		final int locationId = await weatherApiClient.getLocationId(city);
		return await weatherApiClient.fetchWeather(locationId);
	}
}
