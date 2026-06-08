import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'core/services/service_locator.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/admin/data/repositories/admin_repository.dart';
import 'features/admin/presentation/cubits/admin_cubit.dart';
import 'features/lawyer/data/repositories/lawyer_repository.dart';
import 'features/lawyer/presentation/cubits/lawyer_list_cubit.dart';
import 'features/lawyer/presentation/cubits/lawyer_detail_cubit.dart';
import 'features/lawyer/presentation/cubits/lawyer_profile_cubit.dart';
import 'features/lawyer/presentation/cubits/lawyer_availability_cubit.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/client_signup_screen.dart';
import 'features/auth/presentation/screens/lawyer_signup_screen.dart';
import 'features/auth/presentation/screens/lawyer_gateway_screen.dart';
import 'features/auth/presentation/screens/lawyer_login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/lawyer/presentation/screens/lawyers_list_screen.dart';
import 'features/lawyer/presentation/screens/lawyer_detail_screen.dart';
import 'features/lawyer/presentation/screens/lawyer_profile_edit_screen.dart';
import 'features/lawyer/presentation/screens/lawyer_availability_screen.dart';
import 'features/lawyer/presentation/screens/lawyer_notifications_screen.dart';
import 'features/booking/data/repositories/booking_repository.dart';
import 'features/booking/presentation/cubits/client_booking_cubit.dart';
import 'features/booking/presentation/cubits/client_bookings_cubit.dart';
import 'features/booking/presentation/screens/booking_screen.dart';
import 'features/booking/presentation/screens/client_bookings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  setupLocator();

  runApp(const WakeellApp());
}

class WakeellApp extends StatelessWidget {
  const WakeellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(getIt<AuthRepository>())),
        BlocProvider<AdminCubit>(create: (_) => AdminCubit(getIt<AdminRepository>())),
      ],
      child: MaterialApp(
        title: 'Wakeell',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash:         (_) => const SplashScreen(),
          AppRoutes.login:          (_) => const LoginScreen(),
          AppRoutes.register:       (_) => const ClientSignupScreen(),
          AppRoutes.lawyerGateway:  (_) => const LawyerGatewayScreen(),
          AppRoutes.lawyerLogin:    (_) => const LawyerLoginScreen(),
          AppRoutes.registerLawyer: (_) => const LawyerSignupScreen(),
          AppRoutes.home:           (_) => const HomeScreen(),
          AppRoutes.lawyers: (_) => BlocProvider(
            create: (_) => LawyerListCubit(getIt<LawyerRepository>()),
            child: const LawyersListScreen(),
          ),
          AppRoutes.lawyerDetail: (_) => BlocProvider(
            create: (_) => LawyerDetailCubit(getIt<LawyerRepository>()),
            child: const LawyerDetailScreen(),
          ),
          AppRoutes.lawyerProfileEdit: (_) => BlocProvider(
            create: (_) => LawyerProfileCubit(getIt<LawyerRepository>(), getIt<AuthRepository>()),
            child: const LawyerProfileEditScreen(),
          ),
          AppRoutes.lawyerAvailability: (_) => BlocProvider(
            create: (_) => LawyerAvailabilityCubit(getIt<LawyerRepository>()),
            child: const LawyerAvailabilityScreen(),
          ),
          AppRoutes.lawyerNotifications: (_) => const LawyerNotificationsScreen(),
          AppRoutes.booking: (_) => BlocProvider(
            create: (_) => ClientBookingCubit(getIt<BookingRepository>(), getIt<LawyerRepository>()),
            child: const BookingScreen(),
          ),
          AppRoutes.clientBookings: (_) => BlocProvider(
            create: (_) => ClientBookingsCubit(getIt<BookingRepository>())..load(),
            child: const ClientBookingsScreen(),
          ),
        },
      ),
    );
  }
}
