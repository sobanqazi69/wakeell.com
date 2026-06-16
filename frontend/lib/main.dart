import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'core/services/service_locator.dart';
import 'core/services/push_notification_service.dart';
import 'core/network/socket_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/cubits/auth_state.dart';
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
import 'features/booking/data/repositories/booking_repository.dart';
import 'features/booking/presentation/cubits/client_booking_cubit.dart';
import 'features/booking/presentation/cubits/client_bookings_cubit.dart';
import 'features/booking/presentation/screens/booking_screen.dart';
import 'features/booking/presentation/screens/client_bookings_screen.dart';
import 'features/session/data/repositories/session_repository.dart';
import 'features/session/presentation/cubits/session_cubit.dart';
import 'features/session/presentation/screens/session_screen.dart';
import 'features/notifications/data/repositories/notification_repository.dart';
import 'features/notifications/presentation/cubits/notifications_cubit.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/review/data/repositories/review_repository.dart';
import 'features/review/presentation/cubits/review_cubit.dart';
import 'features/review/presentation/screens/review_screen.dart';
import 'features/chat/data/repositories/chat_repository.dart';
import 'features/chat/presentation/cubits/chat_cubit.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/client/presentation/screens/client_profile_screen.dart';
import 'features/session/presentation/screens/advice_summary_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  setupLocator();

  // Wire notification tap → navigate to notifications screen
  PushNotificationService.notificationNavCallback = () {
    navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
  };

  runApp(const WakeellApp());
}

class WakeellApp extends StatelessWidget {
  const WakeellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(getIt<AuthRepository>()),
        ),
        BlocProvider<AdminCubit>(
          create: (_) => AdminCubit(getIt<AdminRepository>()),
        ),
        BlocProvider<NotificationsCubit>(
          create: (_) => NotificationsCubit(getIt<NotificationRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Wakeell',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const ClientSignupScreen(),
          AppRoutes.lawyerGateway: (_) => const LawyerGatewayScreen(),
          AppRoutes.lawyerLogin: (_) => const LawyerLoginScreen(),
          AppRoutes.registerLawyer: (_) => const LawyerSignupScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.lawyers: (_) => BlocProvider(
            create: (_) => LawyerListCubit(getIt<LawyerRepository>()),
            child: const LawyersListScreen(),
          ),
          AppRoutes.lawyerDetail: (_) => BlocProvider(
            create: (_) => LawyerDetailCubit(getIt<LawyerRepository>()),
            child: const LawyerDetailScreen(),
          ),
          AppRoutes.lawyerProfileEdit: (_) => BlocProvider(
            create: (_) => LawyerProfileCubit(
              getIt<LawyerRepository>(),
              getIt<AuthRepository>(),
            ),
            child: const LawyerProfileEditScreen(),
          ),
          AppRoutes.lawyerAvailability: (_) => BlocProvider(
            create: (_) => LawyerAvailabilityCubit(getIt<LawyerRepository>()),
            child: const LawyerAvailabilityScreen(),
          ),
          AppRoutes.lawyerNotifications: (_) => const NotificationsScreen(),
          AppRoutes.notifications: (_) => const NotificationsScreen(),
          AppRoutes.review: (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>;
            return BlocProvider(
              create: (_) => ReviewCubit(getIt<ReviewRepository>()),
              child: ReviewScreen(
                bookingId: args['bookingId'] as int,
                lawyerName: args['lawyerName'] as String? ?? 'Lawyer',
              ),
            );
          },
          AppRoutes.chat: (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>;
            final authState = ctx.read<AuthCubit>().state;
            final userId = authState is AuthAuthenticated
                ? authState.user.id
                : 0;
            final userName = authState is AuthAuthenticated
                ? authState.user.name
                : 'Me';
            return BlocProvider(
              create: (_) => ChatCubit(
                repo: getIt<ChatRepository>(),
                socket: getIt<SocketService>(),
                bookingId: args['bookingId'] as int,
                currentUserId: userId,
                currentUserName: userName,
              ),
              child: ChatScreen(
                otherPartyName: args['otherPartyName'] as String? ?? 'Consultant',
                otherPartyAvatar: args['otherPartyAvatar'] as String?,
              ),
            );
          },
          AppRoutes.clientProfile: (_) => const ClientProfileScreen(),
          AppRoutes.adviceSummary: (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>;
            return AdviceSummaryScreen(
              bookingId: args['bookingId'] as int,
              clientName: args['clientName'] as String? ?? 'Client',
            );
          },
          AppRoutes.booking: (_) => BlocProvider(
            create: (_) => ClientBookingCubit(
              getIt<BookingRepository>(),
              getIt<LawyerRepository>(),
            ),
            child: const BookingScreen(),
          ),
          AppRoutes.clientBookings: (_) => BlocProvider(
            create: (_) =>
                ClientBookingsCubit(getIt<BookingRepository>())..load(),
            child: const ClientBookingsScreen(),
          ),
          AppRoutes.session: (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>;
            return BlocProvider(
              create: (_) => SessionCubit(getIt<SessionRepository>(), getIt<SocketService>()),
              child: SessionScreen(
                bookingId: args['bookingId'] as int,
                otherPartyName: args['otherPartyName'] as String,
                sessionType: args['sessionType'] as String? ?? 'video',
                isClient: args['isClient'] as bool? ?? false,
              ),
            );
          },
        },
      ),
    );
  }
}
