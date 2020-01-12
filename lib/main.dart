import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:the_project_down_under/provider/weather_api_client.dart';
import 'package:the_project_down_under/repository/weather_repository.dart';
import 'package:the_project_down_under/screens/home_page.dart';
import 'package:the_project_down_under/screens/login_page.dart';
import 'package:the_project_down_under/screens/splash_page.dart';
import 'package:the_project_down_under/service/auth_repository.dart';
import 'package:http/http.dart' as http;

import 'bloc/authentication_bloc.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/theme_bloc.dart';
import 'bloc/weather_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final authRepository = AuthRepository();
  final WeatherRepository weatherRepository = WeatherRepository(
      weatherApiClient: WeatherApiClient(
    httpClient: http.Client(),
  ));

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
//        BlocProvider<SettingsBloc>(
//          create: (context) => SettingsBloc(),
//        ),
        BlocProvider<AuthenticationBloc>(
          create: (context) {
            return AuthenticationBloc(authRepository: authRepository)
              ..add(AppStarted());
          },
        ),
        BlocProvider<WeatherBloc>(
          create: (context) =>
              WeatherBloc(weatherRepository: weatherRepository),
        ),
      ],
      child: App(
        authRepo: authRepository,
        weatherRepository: weatherRepository,
      ),
    ),
  );
}

class App extends StatelessWidget {
  final AuthRepository authRepo;
  final WeatherRepository weatherRepository;

  App({Key key, @required this.authRepo, @required this.weatherRepository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, themeState) {
      return MaterialApp(
        theme: themeState.theme,
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationUninitialized) {
              return SplashPage();
            }
            if (state is AuthenticationAuthenticated) {
              return HomePage(weatherRepository: weatherRepository);
            }
            if (state is AuthenticationUnauthenticated) {
              return LoginPage(authRepo: authRepo);
            }
            return LoadingIndicator();
          },
        ),
      );
    });
  }
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(),
      );
}
