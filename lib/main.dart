import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/constants.dart';
import 'core/services/auth_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/dashboard/presentation/screens/advertiser_dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(authService),
      child: MaterialApp(
        title: 'Night Track Advertiser',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: primaryColor,
          scaffoldBackgroundColor: backgroundColor,
          fontFamily: 'Inter',
          colorScheme: const ColorScheme.dark(
            primary: primaryColor,
            secondary: accentPurple,
            surface: cardBackgroundColor,
          ),
          useMaterial3: true,
        ),
        home: const AuthFlowHandler(),
      ),
    );
  }
}

class AuthFlowHandler extends StatelessWidget {
  const AuthFlowHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const AdvertiserDashboardScreen();
        }
        // Always display AuthScreen for unauthenticated, loading, or initial states
        return const AuthScreen();
      },
    );
  }
}
