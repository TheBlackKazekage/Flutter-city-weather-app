import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:the_project_down_under/bloc/authentication_bloc.dart';
import 'package:the_project_down_under/service/auth_repository.dart';

///
/// Login Event
///
abstract class LoginEvent extends Equatable {
	const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
	final String username;
	final String password;

	const LoginButtonPressed({
		@required this.username,
		@required this.password,
	});

	@override
	List<Object> get props => [username, password];

	@override
	String toString() =>
			'LoginButtonPressed { username: $username, password: $password }';
}

///
/// Login state
///
abstract class LoginState extends Equatable {
	const LoginState();

	@override
	List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
	final String error;

	const LoginFailure({@required this.error});

	@override
	List<Object> get props => [error];

	@override
	String toString() => 'LoginFailure { error: $error }';
}

///
/// Login Bloc
///
class LoginBloc extends Bloc<LoginEvent, LoginState> {
	final AuthRepository authRepo;
	final AuthenticationBloc authBloc;

	LoginBloc({
		@required this.authRepo,
		@required this.authBloc,
	})  : assert(authRepo != null),
				assert(authBloc != null);

	LoginState get initialState => LoginInitial();

	@override
	Stream<LoginState> mapEventToState(LoginEvent event) async* {
		if (event is LoginButtonPressed) {
			yield LoginLoading();

			try {
				final token = await authRepo.authenticate(
					username: event.username,
					password: event.password,
				);

				authBloc.add(LoggedIn(token: token));
				yield LoginInitial();
			} catch (error) {
				yield LoginFailure(error: error.toString());
			}
		}
	}
}

