import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:verdantia/features/settings/bloc/user_cubit.dart';
import 'package:verdantia/firebase_options.dart';
// pages
import './app/app.dart';
import './features/garden/view/garden_screen.dart';
// blocs
import 'features/auth/auth_cubit.dart';
import 'package:verdantia/features/garden/bloc/garden_bloc.dart';
import 'package:verdantia/features/garden/bloc/plotgrid_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (BuildContext context) => AuthCubit(),
        ),
        BlocProvider<GardenBloc>(
          create: (BuildContext context) => GardenBloc(),
        ),
        BlocProvider<PlotsCubit>(
          create: (BuildContext context) => PlotsCubit(),
        ),
        BlocProvider<UserCubit>(
          create: (BuildContext context) => UserCubit(
              FirebaseFirestore.instance,
              FirebaseAuth.instance.currentUser!.uid)
            ..loadUser(),
        ),
      ],
      child: MyApp(),
      // child: MaterialApp(
      // title: "Test Garden",
      // home: const GardenScreen(),
      // ),
    ),
  );
}
