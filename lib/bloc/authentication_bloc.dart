import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:the_project_down_under/service/auth_repository.dart';

///
/// Authentication Events
///
abstract class AuthenticationEvent extends Equatable {
	const AuthenticationEvent();

	@override
	List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {
	@override
	String toString() => 'AppStarted';
}

class LoggedIn extends AuthenticationEvent {
	final String token;

	LoggedIn({@required this.token});

	@override
	String toString() => 'LoggedIn { token: $token }';
}

class LoggedOut extends AuthenticationEvent {
	@override
	String toString() => 'LoggedOut';
}

///
/// Authentication States
///
abstract class AuthenticationState extends Equatable {
	const AuthenticationState();

	@override
	List<Object> get props => [];
}

class AuthenticationUninitialized extends AuthenticationState {
	@override
	String toString() => 'AuthenticationUninitialized';
}

class AuthenticationAuthenticated extends AuthenticationState {
	@override
	String toString() => 'AuthenticationAuthenticated';
}

class AuthenticationUnauthenticated extends AuthenticationState {
	@override
	String toString() => 'AuthenticationUnauthenticated';
}

class AuthenticationLoading extends AuthenticationState {
	@override
	String toString() => 'AuthenticationLoading';
}

///
/// Authentication Bloc
///
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
	final AuthRepository authRepository;

	AuthenticationBloc({@required this.authRepository}) : assert(authRepository != null);

	@override
	AuthenticationState get initialState => AuthenticationUninitialized();

	@override
	Stream<AuthenticationState> mapEventToState(AuthenticationEvent event,) async* {
		if (event is AppStarted) {
			final bool hasToken = await authRepository.hasToken();

			if (hasToken) {
				yield AuthenticationAuthenticated();
			} else {
				yield AuthenticationUnauthenticated();
			}
		}

		if (event is LoggedIn) {
			yield AuthenticationLoading();
			await authRepository.persistToken(event.token);
			yield AuthenticationAuthenticated();
		}

		if (event is LoggedOut) {
			yield AuthenticationLoading();
			await authRepository.deleteToken();
			yield AuthenticationUnauthenticated();
		}
	}
}
