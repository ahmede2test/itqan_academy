import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/services_repository.dart';
import 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServicesRepository _servicesRepository;

  ServicesCubit(this._servicesRepository) : super(ServicesInitial());

  static ServicesCubit get(context) => BlocProvider.of(context);

  Future<void> fetchAcademyServices() async {
    emit(ServicesLoading());
    try {
      final services = await _servicesRepository.getAcademyServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> orderAcademyService(String serviceId) async {
    // We don't change global state to loading to avoid flickering the whole list
    try {
      await _servicesRepository.orderService(serviceId);
      emit(ServiceOrderSuccess("تم طلب الخدمة بنجاح"));
      // Re-fetch or just stay in success state
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }
}
