import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:melody/providers/library/imported_music_provider.dart';
import 'package:melody/providers/library/recently_played_provider.dart';
import 'package:melody/models/album.dart';
import 'package:melody/models/song.dart';
import 'package:melody/providers/player/player_provider.dart';
import 'package:melody/widgets/cards/album_card.dart';

class HomeScreen extends ConsumerWidget {
  final ScrollController? scrollController;

  const HomeScreen({
    super.key,
    this.scrollController,
  });

  // =========================================================
  // BRUNO MARS
  // =========================================================

  static const Album midnightDrive = Album(
    id: 'bruno-thats-what-i-like',
    title: 'That\'s What I Like',
    artist: 'Bruno Mars',
    imageUrl:
    'https://picsum.photos/seed/brunomars/600/600',
    songs: [
      Song(
        id: 'bruno-thats-what-i-like',
        title: 'That\'s What I Like',
        artist: 'Bruno Mars',
        audioUrl:
        'assets/audio/bruno_thats_what_i_like.mp3',
        artworkUrl:
        'https://picsum.photos/seed/brunomars/600/600',
      ),
    ],
  );

  // =========================================================
  // KEHLANI - UNFOLDED
  // =========================================================

  static const Album afterHours = Album(
    id: 'kehlani-unfolded',
    title: '(un)Folded',
    artist: 'Kehlani',
    imageUrl:
    'https://picsum.photos/seed/kehlaniunfolded/600/600',
    songs: [
      Song(
        id: 'kehlani-unfolded',
        title: '(un)Folded',
        artist: 'Kehlani',
        audioUrl:
        'assets/audio/kehlani_unfolded.mp3',
        artworkUrl:
        'https://picsum.photos/seed/kehlaniunfolded/600/600',
      ),
    ],
  );

  // =========================================================
  // KEHLANI - NIGHTS LIKE THIS
  // =========================================================

  static const Album golden = Album(
    id: 'kehlani-nights-like-this',
    title: 'Nights Like This',
    artist: 'Kehlani ft. Ty Dolla \$ign',
    imageUrl:
    'https://picsum.photos/seed/kehlaninights/600/600',
    songs: [
      Song(
        id: 'kehlani-nights-like-this',
        title: 'Nights Like This',
        artist: 'Kehlani ft. Ty Dolla \$ign',
        audioUrl:
        'assets/audio/kehlani_nights_like_this.mp3',
        artworkUrl:
        'https://picsum.photos/seed/kehlaninights/600/600',
      ),
    ],
  );

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final ThemeData theme =
    Theme.of(context);

    final ColorScheme colors =
        theme.colorScheme;

    final bool isDarkMode =
        theme.brightness ==
            Brightness.dark;

    // =========================================================
    // RECENTLY PLAYED
    // =========================================================

    final List<Song> rawRecentlyPlayed =
    ref.watch(
      recentlyPlayedProvider,
    );

    // =========================================================
    // IMPORTED MUSIC
    // =========================================================

    final importedMusicState =
    ref.watch(
      importedMusicProvider,
    );

    final Set<String> importedSongIds =
    importedMusicState.songs
        .map(
          (song) => song.id,
    )
        .toSet();

    // =========================================================
    // REMOVE STALE IMPORTED SONGS
    // =========================================================
    //
    // Asset and network songs remain valid.
    //
    // Local/file/content songs must still exist
    // inside Imported Music.
    //
    // =========================================================

    final List<Song> recentlyPlayed =
    rawRecentlyPlayed.where(
          (song) {
        final String source =
        song.audioUrl.trim();

        final bool isBuiltInAsset =
        source.startsWith(
          'assets/',
        );

        final bool isNetworkSong =
            source.startsWith(
              'http://',
            ) ||
                source.startsWith(
                  'https://',
                );

        if (isBuiltInAsset ||
            isNetworkSong) {
          return true;
        }

        return importedSongIds.contains(
          song.id,
        );
      },
    ).toList();

    if (!importedMusicState.isLoading) {
      final Set<String> visibleIds =
      recentlyPlayed
          .map(
            (song) => song.id,
      )
          .toSet();

      final List<String> staleIds =
      rawRecentlyPlayed
          .where(
            (song) =>
        !visibleIds.contains(
          song.id,
        ),
      )
          .map(
            (song) => song.id,
      )
          .toList();

      if (staleIds.isNotEmpty) {
        WidgetsBinding.instance
            .addPostFrameCallback(
              (_) async {
            final notifier =
            ref.read(
              recentlyPlayedProvider.notifier,
            );

            for (final String songId
            in staleIds) {
              await notifier.removeSong(
                songId,
              );
            }
          },
        );
      }
    }

    // =========================================================
    // PLAYER
    // =========================================================

    final playerNotifier =
    ref.read(
      playerProvider.notifier,
    );

    // =========================================================
    // SCREEN
    // =========================================================

    return SingleChildScrollView(
      controller: scrollController,
      padding:
      const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        190,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ===================================================
          // RECENTLY PLAYED
          // ===================================================

          Text(
            'Recently Played',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 22,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          if (recentlyPlayed.isEmpty)
            Container(
              height: 105,
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              decoration:
              BoxDecoration(
                color: isDarkMode
                    ? Colors.white
                    .withValues(
                  alpha: 0.05,
                )
                    : Colors.black
                    .withValues(
                  alpha: 0.04,
                ),
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white
                      .withValues(
                    alpha: 0.05,
                  )
                      : Colors.black
                      .withValues(
                    alpha: 0.05,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.clock,
                    color: colors
                        .onSurfaceVariant,
                    size: 30,
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: Text(
                      'Songs you play will appear here.',
                      style: TextStyle(
                        color: colors
                            .onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 205,
              child:
              ListView.separated(
                scrollDirection:
                Axis.horizontal,
                itemCount:
                recentlyPlayed.length,
                separatorBuilder: (
                    context,
                    index,
                    ) {
                  return const SizedBox(
                    width: 14,
                  );
                },
                itemBuilder: (
                    context,
                    index,
                    ) {
                  final Song song =
                  recentlyPlayed[
                  index];

                  return _RecentlyPlayedCard(
                    song: song,
                    onTap: () {
                      playerNotifier
                          .playQueue(
                        recentlyPlayed,
                        startIndex:
                        index,
                      );
                    },
                  );
                },
              ),
            ),

          const SizedBox(
            height: 30,
          ),

          // ===================================================
          // FEATURED MUSIC
          // ===================================================

          _buildAlbumSection(
            context,
            title:
            'Featured Music',
            albums: const [
              midnightDrive,
              afterHours,
              golden,
            ],
          ),

          const SizedBox(
            height: 30,
          ),

          // ===================================================
          // POPULAR
          // ===================================================

          _buildAlbumSection(
            context,
            title: 'Popular',
            albums: const [
              golden,
              midnightDrive,
              afterHours,
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ALBUM SECTION
  // =========================================================

  Widget _buildAlbumSection(
      BuildContext context, {
        required String title,
        required List<Album> albums,
      }) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 22,
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        SizedBox(
          height: 205,
          child:
          ListView.separated(
            scrollDirection:
            Axis.horizontal,
            itemCount:
            albums.length,
            separatorBuilder: (
                context,
                index,
                ) {
              return const SizedBox(
                width: 14,
              );
            },
            itemBuilder: (
                context,
                index,
                ) {
              final Album album =
              albums[index];

              return AlbumCard(
                album: album,
                onTap: () {
                  context.push(
                    '/album',
                    extra: album,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ===========================================================
// RECENTLY PLAYED CARD
// ===========================================================

class _RecentlyPlayedCard
    extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _RecentlyPlayedCard({
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ThemeData theme =
    Theme.of(context);

    final ColorScheme colors =
        theme.colorScheme;

    final bool isDarkMode =
        theme.brightness ==
            Brightness.dark;

    return GestureDetector(
      behavior:
      HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              BorderRadius.circular(
                16,
              ),
              child: song.artworkUrl !=
                  null &&
                  song.artworkUrl!
                      .isNotEmpty
                  ? Image.network(
                song.artworkUrl!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return _placeholder(
                    context,
                    isDarkMode,
                  );
                },
              )
                  : _placeholder(
                context,
                isDarkMode,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              song.title,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                color:
                colors.onSurface,
                fontSize: 15,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 2,
            ),

            Text(
              song.artist,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                color: colors
                    .onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(
      BuildContext context,
      bool isDarkMode,
      ) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Container(
      width: 150,
      height: 150,
      alignment:
      Alignment.center,
      color: isDarkMode
          ? const Color(
        0xFF252527,
      )
          : const Color(
        0xFFE9E9EE,
      ),
      child: Icon(
        CupertinoIcons.music_note_2,
        color:
        colors.onSurfaceVariant,
        size: 48,
      ),
    );
  }
}