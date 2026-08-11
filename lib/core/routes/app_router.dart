import 'package:go_router/go_router.dart';

import 'package:melody/models/album.dart';

import 'package:melody/screens/album/album_detail_screen.dart';
import 'package:melody/screens/player/now_playing_screen.dart';
import 'package:melody/screens/playlist/playlist_detail_screen.dart';
import 'package:melody/screens/profile/profile_screen.dart';
import 'package:melody/screens/shell/main_shell.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // =====================================================
      // MAIN
      // =====================================================
      GoRoute(
        path: '/',
        builder: (
            context,
            state,
            ) {
          return const MainShell();
        },
      ),

      // =====================================================
      // ALBUM
      // =====================================================
      GoRoute(
        path: '/album',
        builder: (
            context,
            state,
            ) {
          final album =
          state.extra as Album;

          return AlbumDetailScreen(
            album: album,
          );
        },
      ),

      // =====================================================
      // NOW PLAYING
      // =====================================================
      GoRoute(
        path: '/now-playing',
        builder: (
            context,
            state,
            ) {
          return const NowPlayingScreen();
        },
      ),

      // =====================================================
      // PLAYLIST
      // =====================================================
      GoRoute(
        path: '/playlist/:id',
        builder: (
            context,
            state,
            ) {
          final playlistId =
          state.pathParameters['id']!;

          return PlaylistDetailScreen(
            playlistId: playlistId,
          );
        },
      ),

      // =====================================================
      // PROFILE
      // =====================================================
      GoRoute(
        path: '/profile',
        builder: (
            context,
            state,
            ) {
          return const ProfileScreen();
        },
      ),
    ],
  );
}