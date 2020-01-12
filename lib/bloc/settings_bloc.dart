import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class SettingsEvent extends Equatable{
	const SettingsEvent();
}

class TempUnitsToggled extends SettingsEvent{
  @override
  List<Object> get props => [];
}

enum TempUnits{celsius, fahrenheit}

class SettingsState extends Equatable{
	final TempUnits tempUnits;

	SettingsState({@required this.tempUnits}) : assert(tempUnits != null);

	@override
	List<Object> get props => [tempUnits];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
	@override
	SettingsState get initialState =>
			SettingsState(tempUnits: TempUnits.celsius);

	@override
	Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
		if (event is TempUnitsToggled) {
			yield SettingsState(
				tempUnits: state.tempUnits == TempUnits.celsius
						? TempUnits.fahrenheit
						: TempUnits.celsius,
			);
		}
	}
}
