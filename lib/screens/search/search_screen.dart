import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:melody/models/album.dart';
import 'package:melody/models/song.dart';

import 'package:melody/providers/player/player_provider.dart';
import 'package:melody/providers/search/search_history_provider.dart';

import 'package:melody/screens/home/home_screen.dart';

class SearchScreen extends ConsumerWidget {
  final String query;
  final ValueChanged<String> onRecentSearchSelected;

  const SearchScreen({
    super.key,
    required this.query,
    required this.onRecentSearchSelected,
  });

  // =========================================================
  // AVAILABLE ALBUMS
  // =========================================================
  static const List<Album> _albums = [
    HomeScreen.midnightDrive,
    HomeScreen.afterHours,
    HomeScreen.golden,
  ];

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final playerState =
    ref.watch(playerProvider);

    final playerNotifier =
    ref.read(playerProvider.notifier);

    final searchHistory =
    ref.watch(searchHistoryProvider);

    final historyNotifier =
    ref.read(
      searchHistoryProvider.notifier,
    );

    final normalizedQuery =
    query.trim().toLowerCase();

    // =======================================================
    // EMPTY SEARCH
    // =======================================================
    if (normalizedQuery.isEmpty) {
      return _buildEmptySearch(
        context,
        searchHistory,
        historyNotifier,
      );
    }

    // =======================================================
    // ARTISTS
    // =======================================================
    final artistResults = <Album>[];
    final seenArtists = <String>{};

    for (final album in _albums) {
      final artist =
      album.artist.toLowerCase();

      if (artist.contains(
        normalizedQuery,
      ) &&
          seenArtists.add(artist)) {
        artistResults.add(
          album,
        );
      }
    }

    // =======================================================
    // ALBUMS
    // =======================================================
    final albumResults =
    _albums.where(
          (album) {
        return album.title
            .toLowerCase()
            .contains(
          normalizedQuery,
        ) ||
            album.artist
                .toLowerCase()
                .contains(
              normalizedQuery,
            );
      },
    ).toList();

    // =======================================================
    // SONGS + LYRICS
    // =======================================================
    final songResults =
    <_SongResult>[];

    for (final album in _albums) {
      for (
      var index = 0;
      index < album.songs.length;
      index++
      ) {
        final song =
        album.songs[index];

        final titleMatch =
        song.title
            .toLowerCase()
            .contains(
          normalizedQuery,
        );

        final artistMatch =
        song.artist
            .toLowerCase()
            .contains(
          normalizedQuery,
        );

        final albumMatch =
        album.title
            .toLowerCase()
            .contains(
          normalizedQuery,
        );

        final lyricsMatch =
        (song.lyrics ?? '')
            .toLowerCase()
            .contains(
          normalizedQuery,
        );

        final normalMatch =
            titleMatch ||
                artistMatch ||
                albumMatch;

        if (normalMatch ||
            lyricsMatch) {
          songResults.add(
            _SongResult(
              song: song,
              album: album,
              index: index,
              matchedInLyrics:
              lyricsMatch &&
                  !normalMatch,
            ),
          );
        }
      }
    }

    final hasResults =
        artistResults.isNotEmpty ||
            songResults.isNotEmpty ||
            albumResults.isNotEmpty;

    // =======================================================
    // NO RESULTS
    // =======================================================
    if (!hasResults) {
      return _buildNoResults();
    }

    // =======================================================
    // RESULTS
    // =======================================================
    return ListView(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        190,
      ),
      children: [
        Text(
          'Results for “$query”',
          maxLines: 1,
          overflow:
          TextOverflow.ellipsis,
          style:
          const TextStyle(
            color:
            Colors.white54,
            fontSize: 14,
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        // ===================================================
        // ARTISTS
        // ===================================================
        if (artistResults.isNotEmpty) ...[
          const _ResultHeader(
            title: 'Artists',
          ),

          const SizedBox(
            height: 10,
          ),

          ...artistResults.map(
                (album) {
              return _ArtistResultTile(
                album: album,
                onTap: () async {
                  await historyNotifier
                      .addQuery(query);

                  if (!context.mounted) {
                    return;
                  }

                  context.push(
                    '/album',
                    extra: album,
                  );
                },
              );
            },
          ),

          const SizedBox(
            height: 30,
          ),
        ],

        // ===================================================
        // SONGS
        // ===================================================
        if (songResults.isNotEmpty) ...[
          const _ResultHeader(
            title: 'Songs',
          ),

          const SizedBox(
            height: 10,
          ),

          ...songResults.map(
                (result) {
              final song =
                  result.song;

              final isCurrent =
                  playerState
                      .currentSong
                      ?.id ==
                      song.id;

              return _SongResultTile(
                song: song,
                matchedInLyrics:
                result
                    .matchedInLyrics,
                isCurrent:
                isCurrent,
                isPlaying:
                isCurrent &&
                    playerState
                        .isPlaying,
                onTap: () async {
                  await historyNotifier
                      .addQuery(query);

                  await playerNotifier
                      .playQueue(
                    result.album.songs,
                    startIndex:
                    result.index,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  context.push(
                    '/now-playing',
                  );
                },
              );
            },
          ),

          const SizedBox(
            height: 30,
          ),
        ],

        // ===================================================
        // ALBUMS
        // ===================================================
        if (albumResults.isNotEmpty) ...[
          const _ResultHeader(
            title: 'Albums',
          ),

          const SizedBox(
            height: 10,
          ),

          ...albumResults.map(
                (album) {
              return _AlbumResultTile(
                album: album,
                onTap: () async {
                  await historyNotifier
                      .addQuery(query);

                  if (!context.mounted) {
                    return;
                  }

                  context.push(
                    '/album',
                    extra: album,
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }

  // =========================================================
  // EMPTY SEARCH / RECENT SEARCHES
  // =========================================================
  Widget _buildEmptySearch(
      BuildContext context,
      List<String> history,
      SearchHistoryNotifier notifier,
      ) {
    return ListView(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        190,
      ),
      children: [
        // ===================================================
        // RECENT SEARCHES
        // ===================================================
        if (history.isNotEmpty) ...[
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Searches',
                  style: TextStyle(
                    color:
                    Colors.white,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              CupertinoButton(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                onPressed: () {
                  _confirmClearHistory(
                    context,
                    notifier,
                  );
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Color(
                      0xFFFF2D55,
                    ),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          ...history.map(
                (search) {
              return _RecentSearchTile(
                query: search,

                onTap: () {
                  onRecentSearchSelected(
                    search,
                  );
                },

                onRemove: () {
                  notifier.removeQuery(
                    search,
                  );
                },
              );
            },
          ),

          const SizedBox(
            height: 36,
          ),
        ],

        // ===================================================
        // EMPTY STATE
        // ===================================================
        if (history.isEmpty) ...[
          const SizedBox(
            height: 8,
          ),

          const Center(
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.search,
                  color:
                  Colors.white24,
                  size: 52,
                ),

                SizedBox(
                  height: 14,
                ),

                Text(
                  'Search Melody',
                  style: TextStyle(
                    color:
                    Colors.white,
                    fontSize: 21,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                SizedBox(
                  height: 7,
                ),

                Text(
                  'Find artists, songs, lyrics, and albums.',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color:
                    Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 42,
          ),
        ],

        // ===================================================
        // BROWSE
        // ===================================================
        const Text(
          'Browse Albums',
          style: TextStyle(
            color:
            Colors.white,
            fontSize: 21,
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        ..._albums.map(
              (album) {
            return _AlbumResultTile(
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
      ],
    );
  }

  // =========================================================
  // CLEAR HISTORY CONFIRMATION
  // =========================================================
  void _confirmClearHistory(
      BuildContext context,
      SearchHistoryNotifier notifier,
      ) {
    showCupertinoDialog<void>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return CupertinoAlertDialog(
          title:
          const Text(
            'Clear Recent Searches?',
          ),
          content:
          const Text(
            'Your recent search history will be removed.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child:
              const Text(
                'Cancel',
              ),
            ),

            CupertinoDialogAction(
              isDestructiveAction:
              true,
              onPressed: () async {
                Navigator.of(
                  dialogContext,
                ).pop();

                await notifier
                    .clearHistory();
              },
              child:
              const Text(
                'Clear',
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // NO RESULTS
  // =========================================================
  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.fromLTRB(
          24,
          0,
          24,
          120,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.search,
              color:
              Colors.white24,
              size: 52,
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'No Results',
              style: TextStyle(
                color:
                Colors.white,
                fontSize: 20,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              'Nothing found for “$query”.',
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                color:
                Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// RECENT SEARCH TILE
// ===========================================================
class _RecentSearchTile
    extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchTile({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      children: [
        ListTile(
          contentPadding:
          EdgeInsets.zero,

          onTap: onTap,

          leading:
          const SizedBox(
            width: 34,
            child: Icon(
              CupertinoIcons
                  .clock,
              color:
              Colors.white54,
              size: 21,
            ),
          ),

          title: Text(
            query,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              color:
              Colors.white,
              fontSize: 16,
            ),
          ),

          trailing:
          IconButton(
            onPressed:
            onRemove,
            icon:
            const Icon(
              CupertinoIcons.xmark,
              color:
              Colors.white38,
              size: 17,
            ),
          ),
        ),

        const Divider(
          height: 1,
          indent: 46,
          color:
          Colors.white12,
        ),
      ],
    );
  }
}

// ===========================================================
// RESULT HEADER
// ===========================================================
class _ResultHeader
    extends StatelessWidget {
  final String title;

  const _ResultHeader({
    required this.title,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Text(
      title,
      style:
      const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight:
        FontWeight.w700,
      ),
    );
  }
}

// ===========================================================
// SONG RESULT MODEL
// ===========================================================
class _SongResult {
  final Song song;
  final Album album;
  final int index;
  final bool matchedInLyrics;

  const _SongResult({
    required this.song,
    required this.album,
    required this.index,
    required this.matchedInLyrics,
  });
}

// ===========================================================
// ARTIST RESULT TILE
// ===========================================================
class _ArtistResultTile
    extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;

  const _ArtistResultTile({
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      children: [
        ListTile(
          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 4,
          ),
          onTap: onTap,
          leading: ClipOval(
            child: Image.network(
              album.imageUrl,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  width: 58,
                  height: 58,
                  color:
                  const Color(
                    0xFF2C2C2E,
                  ),
                  alignment:
                  Alignment.center,
                  child:
                  const Icon(
                    CupertinoIcons
                        .person_fill,
                    color:
                    Colors.white38,
                  ),
                );
              },
            ),
          ),
          title: Text(
            album.artist,
            style:
            const TextStyle(
              color:
              Colors.white,
              fontSize: 17,
              fontWeight:
              FontWeight.w600,
            ),
          ),
          subtitle:
          const Text(
            'Artist',
            style: TextStyle(
              color:
              Colors.white54,
              fontSize: 13,
            ),
          ),
          trailing:
          const Icon(
            CupertinoIcons
                .chevron_right,
            color:
            Colors.white30,
            size: 18,
          ),
        ),

        const Divider(
          height: 1,
          indent: 70,
          color:
          Colors.white12,
        ),
      ],
    );
  }
}

// ===========================================================
// SONG RESULT TILE
// ===========================================================
class _SongResultTile
    extends StatelessWidget {
  final Song song;
  final bool matchedInLyrics;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SongResultTile({
    required this.song,
    required this.matchedInLyrics,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      children: [
        ListTile(
          contentPadding:
          EdgeInsets.zero,
          onTap: onTap,

          leading: ClipRRect(
            borderRadius:
            BorderRadius.circular(
              8,
            ),
            child:
            song.artworkUrl !=
                null &&
                song.artworkUrl!
                    .isNotEmpty
                ? Image.network(
              song.artworkUrl!,
              width: 52,
              height: 52,
              fit:
              BoxFit.cover,
              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {
                return _songPlaceholder();
              },
            )
                : _songPlaceholder(),
          ),

          title: Text(
            song.title,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color:
              isCurrent
                  ? const Color(
                0xFFFF2D55,
              )
                  : Colors.white,
              fontSize: 16,
              fontWeight:
              isCurrent
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),

          subtitle: Text(
            matchedInLyrics
                ? '${song.artist} • Lyrics match'
                : song.artist,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color:
              matchedInLyrics
                  ? const Color(
                0xFFFF2D55,
              ).withValues(
                alpha: 0.75,
              )
                  : Colors.white54,
              fontSize: 13,
            ),
          ),

          trailing:
          isPlaying
              ? const Icon(
            CupertinoIcons
                .waveform,
            color: Color(
              0xFFFF2D55,
            ),
            size: 20,
          )
              : const Icon(
            CupertinoIcons
                .play_fill,
            color:
            Colors.white54,
            size: 18,
          ),
        ),

        const Divider(
          height: 1,
          indent: 64,
          color:
          Colors.white12,
        ),
      ],
    );
  }

  Widget _songPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      color:
      const Color(
        0xFF2C2C2E,
      ),
      alignment:
      Alignment.center,
      child:
      const Icon(
        CupertinoIcons
            .music_note_2,
        color:
        Colors.white38,
        size: 22,
      ),
    );
  }
}

// ===========================================================
// ALBUM RESULT TILE
// ===========================================================
class _AlbumResultTile
    extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;

  const _AlbumResultTile({
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      children: [
        ListTile(
          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 3,
          ),
          onTap: onTap,

          leading: ClipRRect(
            borderRadius:
            BorderRadius.circular(
              9,
            ),
            child: Image.network(
              album.imageUrl,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  width: 58,
                  height: 58,
                  color:
                  const Color(
                    0xFF2C2C2E,
                  ),
                  alignment:
                  Alignment.center,
                  child:
                  const Icon(
                    CupertinoIcons
                        .music_albums_fill,
                    color:
                    Colors.white38,
                  ),
                );
              },
            ),
          ),

          title: Text(
            album.title,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              color:
              Colors.white,
              fontSize: 16,
              fontWeight:
              FontWeight.w600,
            ),
          ),

          subtitle: Text(
            '${album.artist} • ${album.songs.length} songs',
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              color:
              Colors.white54,
              fontSize: 13,
            ),
          ),

          trailing:
          const Icon(
            CupertinoIcons
                .chevron_right,
            color:
            Colors.white30,
            size: 18,
          ),
        ),

        const Divider(
          height: 1,
          indent: 70,
          color:
          Colors.white12,
        ),
      ],
    );
  }
}