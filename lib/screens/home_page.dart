import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project_down_under/bloc/authentication_bloc.dart';
import 'package:the_project_down_under/bloc/settings_bloc.dart';
import 'package:the_project_down_under/bloc/theme_bloc.dart';
import 'package:the_project_down_under/bloc/weather_bloc.dart';
import 'package:the_project_down_under/model/weather.dart';
import 'package:the_project_down_under/repository/weather_repository.dart';
import 'package:the_project_down_under/screens/settings_page.dart';

class HomePage extends StatefulWidget {
  final WeatherRepository weatherRepository;

  HomePage({@required this.weatherRepository})
      : assert(weatherRepository != null);

  @override
  _HomePageState createState() =>
      _HomePageState(weatherRepository: weatherRepository);
}

class _HomePageState extends State<HomePage> {
  final WeatherRepository weatherRepository;
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  _HomePageState({@required this.weatherRepository})
      : assert(weatherRepository != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final city = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CitySelection(),
                ),
              );
              if (city != null) {
                BlocProvider.of<WeatherBloc>(context)
                    .add(FetchWeather(city: city));
              }
            },
          ),
//					IconButton(
//						icon: Icon(Icons.settings),
//						onPressed: () {
//							Navigator.push(
//								context,
//								MaterialPageRoute(
//									builder: (context) => Settings(),
//								),
//							);
//						},
//					),
					IconButton(
						icon: Icon(Icons.power_settings_new),
						onPressed: () {
							BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
						},
					),
        ],
      ),
      body: Center(
        child: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            if (state is WeatherEmpty) {
              return Center(
                child: Text('Please select a location'),
              );
            }
            if (state is WeatherLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is WeatherLoaded) {
              final weather = state.weather;

              return BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                return GradientContainer(
                  color: themeState.color,
                  child: RefreshIndicator(
                    onRefresh: () {
                      BlocProvider.of<WeatherBloc>(context).add(
                        RefreshWeather(city: state.weather.location),
                      );
                      return _refreshCompleter.future;
                    },
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 150.0),
                          child: Center(
                            child: Location(location: weather.location),
                          ),
                        ),
                        Center(
                          child: LastUpdated(dateTime: weather.lastUpdated),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 50.0),
                          child: Center(
                            child: CombinedWeatherTemperature(
                              weather: weather,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }
            return Text(
              'Something went wrong!',
              style: TextStyle(color: Colors.red),
            );
          },
        ),
      ),
    );
  }
}

class Location extends StatelessWidget {
  final String location;

  Location({Key key, @required this.location})
      : assert(location != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      location,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class LastUpdated extends StatelessWidget {
  final DateTime dateTime;

  LastUpdated({Key key, @required this.dateTime})
      : assert(dateTime != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Updated: ${TimeOfDay.fromDateTime(dateTime).format(context)}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w200,
        color: Colors.white,
      ),
    );
  }
}

class CombinedWeatherTemperature extends StatelessWidget {
  final Weather weather;

  CombinedWeatherTemperature({
    Key key,
    @required this.weather,
  })  : assert(weather != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: WeatherConditions(condition: weather.condition),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Temperature(
                temperature: weather.temp,
                high: weather.maxTemp,
                low: weather.minTemp,
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            weather.formattedCondition,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class WeatherConditions extends StatelessWidget {
  final WeatherCondition condition;

  WeatherConditions({Key key, @required this.condition})
      : assert(condition != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => _mapConditionToImage(condition);

  Image _mapConditionToImage(WeatherCondition condition) {
    Image image;
    switch (condition) {
      case WeatherCondition.clear:
      case WeatherCondition.lightCloud:
        image = Image.asset('assets/clear.png');
        break;
      case WeatherCondition.hail:
      case WeatherCondition.snow:
      case WeatherCondition.sleet:
        image = Image.asset('assets/snow.png');
        break;
      case WeatherCondition.heavyCloud:
        image = Image.asset('assets/cloudy.png');
        break;
      case WeatherCondition.heavyRain:
      case WeatherCondition.lightRain:
      case WeatherCondition.showers:
        image = Image.asset('assets/rainy.png');
        break;
      case WeatherCondition.thunderstorm:
        image = Image.asset('assets/thunderstorm.png');
        break;
      case WeatherCondition.unknown:
        image = Image.asset('assets/clear.png');
        break;
    }
    return image;
  }
}

class Temperature extends StatelessWidget {
	final double temperature;
	final double low;
	final double high;
	final TempUnits units;

	Temperature({
		Key key,
		this.temperature,
		this.low,
		this.high,
		this.units,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Padding(
					padding: EdgeInsets.only(right: 20.0),
					child: Text(
						'${_formattedTemperature(temperature)}°',
						style: TextStyle(
							fontSize: 32,
							fontWeight: FontWeight.w600,
							color: Colors.white,
						),
					),
				),
				Column(
					children: [
						Text(
							'max: ${_formattedTemperature(high)}°',
							style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.w100,
								color: Colors.white,
							),
						),
						Text(
							'min: ${_formattedTemperature(low)}°',
							style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.w100,
								color: Colors.white,
							),
						)
					],
				)
			],
		);
	}

	int _toFahrenheit(double celsius) => ((celsius * 9 / 5) + 32).round();

	int _formattedTemperature(double t) =>
			units == TempUnits.fahrenheit ? _toFahrenheit(t) : t.round();
}

class CitySelection extends StatefulWidget {
  @override
  State<CitySelection> createState() => _CitySelectionState();
}

class _CitySelectionState extends State<CitySelection> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('City'),
      ),
      body: Form(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: TextFormField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    hintText: 'Chicago',
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.pop(context, _textController.text);
              },
            )
          ],
        ),
      ),
    );
  }
}

class GradientContainer extends StatelessWidget {
	final MaterialColor color;
  final Widget child;

  const GradientContainer({
    Key key,
    @required this.color,
    @required this.child,
  })  : assert(color != null, child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.6, 0.8, 1.0],
          colors: [
            color[700],
            color[500],
            color[300],
          ],
        ),
      ),
      child: child,
    );
  }
}
