import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:verdantia/core/services/plant_service.dart';
import 'package:verdantia/features/garden/bloc/plot_bloc.dart';
import 'package:verdantia/features/onboarding/selected_plants_cubit.dart';
import 'package:verdantia/features/plant_detail/bloc/plant_bloc.dart';
import 'package:verdantia/features/settings/bloc/user_cubit.dart';
import 'package:verdantia/firebase_options.dart';
// pages
import './app/app.dart';
// import './features/garden/view/garden_screen.dart';
// blocs
import 'features/auth/auth_cubit.dart';
import 'package:verdantia/features/garden/bloc/garden_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final plantService = PlantService();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (BuildContext context) => AuthCubit(),
        ),
        BlocProvider<GardenBloc>(
          create: (BuildContext context) => GardenBloc(),
        ),
        BlocProvider<UserCubit>(
          create: (BuildContext context) => UserCubit(
              FirebaseFirestore.instance,
              FirebaseAuth.instance.currentUser!.uid)
            ..loadUser(),
        ),
        BlocProvider<PlantBloc>(
          create: (BuildContext context) => PlantBloc(plantService),
        ),
      ],
      child: MyApp(),
    ),
  );
}
