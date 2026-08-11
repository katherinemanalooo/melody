import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:melody/models/album.dart';
import 'package:melody/models/song.dart';

import 'package:melody/providers/library/favorites_provider.dart';
import 'package:melody/providers/library/imported_music_provider.dart';
import 'package:melody/providers/library/playlists_provider.dart';
import 'package:melody/providers/library/recently_played_provider.dart';
import 'package:melody/providers/player/player_provider.dart';

import 'package:melody/screens/home/home_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  final ScrollController? scrollController;

  const LibraryScreen({
    super.key,
    this.scrollController,
  });

  @override
  ConsumerState<LibraryScreen> createState() =>
      _LibraryScreenState();
}

class _LibraryScreenState
    extends ConsumerState<LibraryScreen> {
  // =========================================================
  // SECTION KEYS
  // =========================================================

  final GlobalKey _playlistsKey =
  GlobalKey();

  final GlobalKey _favoritesKey =
  GlobalKey();

  final GlobalKey _importedKey =
  GlobalKey();

  final GlobalKey _artistsKey =
  GlobalKey();

  final GlobalKey _albumsKey =
  GlobalKey();

  final GlobalKey _songsKey =
  GlobalKey();

  // =========================================================
  // ALBUMS
  // =========================================================

  static const List<Album> _albums =
  <Album>[
    HomeScreen.midnightDrive,
    HomeScreen.afterHours,
    HomeScreen.golden,
  ];

  // =========================================================
  // BUILT-IN SONGS
  // =========================================================

  List<Song> get _builtInSongs {
    return _albums
        .expand(
          (Album album) =>
      album.songs,
    )
        .toList();
  }

  // =========================================================
  // SCROLL TO SECTION
  // =========================================================

  Future<void> _scrollToSection(
      GlobalKey key,
      ) async {
    await Future<void>.delayed(
      const Duration(
        milliseconds: 20,
      ),
    );

    if (!mounted) {
      return;
    }

    BuildContext? targetContext =
        key.currentContext;

    if (targetContext == null) {
      await Future<void>.delayed(
        const Duration(
          milliseconds: 80,
        ),
      );

      if (!mounted) {
        return;
      }

      targetContext =
          key.currentContext;
    }

    if (targetContext == null ||
        !targetContext.mounted) {
      return;
    }

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(
        milliseconds: 550,
      ),
      curve:
      Curves.easeInOutCubic,
      alignment: 0.04,
    );
  }

  // =========================================================
  // CREATE PLAYLIST
  // =========================================================

  Future<void> _showCreatePlaylist(
      BuildContext context,
      PlaylistsNotifier notifier,
      ) async {
    final TextEditingController controller =
    TextEditingController();

    await showCupertinoDialog<void>(
      context: context,
      builder:
          (
          BuildContext dialogContext,
          ) {
        return CupertinoAlertDialog(
          title:
          const Text(
            'New Playlist',
          ),

          content:
          Padding(
            padding:
            const EdgeInsets.only(
              top: 14,
            ),

            child:
            CupertinoTextField(
              controller:
              controller,

              autofocus: true,

              placeholder:
              'Playlist Name',

              clearButtonMode:
              OverlayVisibilityMode
                  .editing,

              textCapitalization:
              TextCapitalization
                  .words,
            ),
          ),

          actions:
          <Widget>[
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
              isDefaultAction: true,

              onPressed: () async {
                final String name =
                controller.text
                    .trim();

                if (name.isEmpty) {
                  return;
                }

                await notifier
                    .createPlaylist(
                  name,
                );

                if (!dialogContext
                    .mounted) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop();
              },

              child:
              const Text(
                'Create',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    final bool isDarkMode =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    final favorites =
    ref.watch(
      favoritesProvider,
    );

    final recentlyPlayed =
    ref.watch(
      recentlyPlayedProvider,
    );

    final importedMusicState =
    ref.watch(
      importedMusicProvider,
    );

    final importedMusicNotifier =
    ref.read(
      importedMusicProvider.notifier,
    );

    final List<Song> importedSongs =
        importedMusicState.songs;

    final playlists =
    ref.watch(
      playlistsProvider,
    );

    final playlistsNotifier =
    ref.read(
      playlistsProvider.notifier,
    );

    final playerState =
    ref.watch(
      playerProvider,
    );

    final playerNotifier =
    ref.read(
      playerProvider.notifier,
    );

    final List<Song> allSongs =
    <Song>[
      ..._builtInSongs,
      ...importedSongs,
    ];

    final Color neutralAccent =
    colors.onSurface
        .withValues(
      alpha:
      isDarkMode
          ? 0.72
          : 0.62,
    );

    return SingleChildScrollView(
      // Required for compact bottom controls.
      controller:
      widget.scrollController,

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

        children: <Widget>[
          // ===================================================
          // LIBRARY MENU
          // ===================================================

          _LibraryCategory(
            icon:
            CupertinoIcons
                .music_note_list,
            title:
            'Playlists',
            onTap: () {
              _scrollToSection(
                _playlistsKey,
              );
            },
          ),

          _LibraryCategory(
            icon:
            CupertinoIcons
                .heart_fill,
            title:
            'Favorite Songs',
            onTap: () {
              _scrollToSection(
                _favoritesKey,
              );
            },
          ),

          _LibraryCategory(
            icon:
            CupertinoIcons
                .square_arrow_down,
            title:
            'Imported Music',
            onTap: () {
              _scrollToSection(
                _importedKey,
              );
            },
          ),

          _LibraryCategory(
            icon:
            CupertinoIcons
                .person_2_fill,
            title:
            'Artists',
            onTap: () {
              _scrollToSection(
                _artistsKey,
              );
            },
          ),

          _LibraryCategory(
            icon:
            CupertinoIcons
                .music_albums_fill,
            title:
            'Albums',
            onTap: () {
              _scrollToSection(
                _albumsKey,
              );
            },
          ),

          _LibraryCategory(
            icon:
            CupertinoIcons
                .music_note_2,
            title:
            'Songs',
            onTap: () {
              _scrollToSection(
                _songsKey,
              );
            },
          ),

          const SizedBox(
            height: 28,
          ),

          // ===================================================
          // STAT CARDS
          // ===================================================

          Row(
            children:
            <Widget>[
              Expanded(
                child:
                _LibraryStatCard(
                  icon:
                  CupertinoIcons
                      .heart_fill,

                  title:
                  'Favorites',

                  value:
                  '${favorites.length}',

                  accentColor:
                  const Color(
                    0xFFFF2D55,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                _LibraryStatCard(
                  icon:
                  CupertinoIcons
                      .clock_fill,

                  title:
                  'Recent',

                  value:
                  '${recentlyPlayed.length}',

                  accentColor:
                  neutralAccent,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 38,
          ),

          // ===================================================
          // PLAYLISTS
          // ===================================================

          Container(
            key:
            _playlistsKey,

            child:
            _SectionHeader(
              title:
              'Playlists',

              icon:
              CupertinoIcons
                  .music_note_list,

              iconColor:
              neutralAccent,

              trailing:
              '${playlists.length + 2}',
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          // ===================================================
          // NEW PLAYLIST
          // ===================================================

          _NewPlaylistTile(
            onTap: () {
              _showCreatePlaylist(
                context,
                playlistsNotifier,
              );
            },
          ),

          const SizedBox(
            height: 10,
          ),

          // ===================================================
          // FAVORITES PLAYLIST
          // ===================================================

          _PlaylistTile(
            title:
            'Favorite Songs',

            subtitle:
            '${favorites.length} songs',

            icon:
            CupertinoIcons
                .heart_fill,

            backgroundColor:
            const Color(
              0xFFFF2D55,
            ),

            onTap: favorites.isEmpty
                ? null
                : () {
              playerNotifier
                  .playQueue(
                favorites,
                startIndex: 0,
              );
            },
          ),

          const SizedBox(
            height: 10,
          ),

          // ===================================================
          // RECENT PLAYLIST
          // ===================================================

          _PlaylistTile(
            title:
            'Recently Played',

            subtitle:
            '${recentlyPlayed.length} songs',

            icon:
            CupertinoIcons
                .clock_fill,

            backgroundColor:
            isDarkMode
                ? const Color(
              0xFF48484A,
            )
                : const Color(
              0xFF8E8E93,
            ),

            onTap:
            recentlyPlayed.isEmpty
                ? null
                : () {
              playerNotifier
                  .playQueue(
                recentlyPlayed,
                startIndex:
                0,
              );
            },
          ),

          // ===================================================
          // CUSTOM PLAYLISTS
          // ===================================================

          if (playlists.isNotEmpty) ...[
            const SizedBox(
              height: 18,
            ),

            ...playlists.map(
                  (playlist) {
                return Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 10,
                  ),

                  child:
                  _CustomPlaylistTile(
                    title:
                    playlist.name,

                    songCount:
                    playlist
                        .songs
                        .length,

                    onTap: () {
                      context.push(
                        '/playlist/${playlist.id}',
                      );
                    },
                  ),
                );
              },
            ),
          ],

          const SizedBox(
            height: 38,
          ),

          // ===================================================
          // FAVORITES
          // ===================================================

          Container(
            key:
            _favoritesKey,

            child:
            _SectionHeader(
              title:
              'Favorite Songs',

              icon:
              CupertinoIcons
                  .heart_fill,

              iconColor:
              const Color(
                0xFFFF2D55,
              ),

              trailing:
              '${favorites.length}',
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          if (favorites.isEmpty)
            const _EmptyLibraryCard(
              icon:
              CupertinoIcons
                  .heart,
              title:
              'No Favorites Yet',
              subtitle:
              'Songs you like will appear here.',
            )
          else
            ...List<Widget>.generate(
              favorites.length,
                  (int index) {
                final Song song =
                favorites[index];

                final bool isCurrent =
                    playerState
                        .currentSong
                        ?.id ==
                        song.id;

                return _SongTile(
                  song: song,

                  isCurrent:
                  isCurrent,

                  isPlaying:
                  isCurrent &&
                      playerState
                          .isPlaying,

                  onTap: () {
                    playerNotifier
                        .playQueue(
                      favorites,
                      startIndex:
                      index,
                    );
                  },
                );
              },
            ),

          const SizedBox(
            height: 38,
          ),

          // ===================================================
          // RECENTLY PLAYED
          // ===================================================

          _SectionHeader(
            title:
            'Recently Played',

            icon:
            CupertinoIcons.clock,

            iconColor:
            neutralAccent,

            trailing:
            '${recentlyPlayed.length}',
          ),

          const SizedBox(
            height: 14,
          ),

          if (recentlyPlayed.isEmpty)
            const _EmptyLibraryCard(
              icon:
              CupertinoIcons.clock,
              title:
              'Nothing Played Yet',
              subtitle:
              'Songs you play will appear here.',
            )
          else
            SizedBox(
              height: 195,

              child:
              ListView.separated(
                scrollDirection:
                Axis.horizontal,

                itemCount:
                recentlyPlayed
                    .length,

                separatorBuilder:
                    (
                    BuildContext context,
                    int index,
                    ) {
                  return const SizedBox(
                    width: 14,
                  );
                },

                itemBuilder:
                    (
                    BuildContext context,
                    int index,
                    ) {
                  final Song song =
                  recentlyPlayed[
                  index];

                  final bool isCurrent =
                      playerState
                          .currentSong
                          ?.id ==
                          song.id;

                  return _RecentSongCard(
                    song:
                    song,

                    isCurrent:
                    isCurrent,

                    isPlaying:
                    isCurrent &&
                        playerState
                            .isPlaying,

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
            height: 38,
          ),

          // ===================================================
          // IMPORTED MUSIC
          // ===================================================

          Container(
            key:
            _importedKey,

            child: Row(
              children:
              <Widget>[
                const Expanded(
                  child:
                  _SectionHeader(
                    title:
                    'Imported Music',

                    icon:
                    CupertinoIcons
                        .square_arrow_down,

                    iconColor:
                    Color(
                      0xFFFF2D55,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                CupertinoButton(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  color:
                  const Color(
                    0xFFFF2D55,
                  ),

                  borderRadius:
                  BorderRadius
                      .circular(
                    18,
                  ),

                  onPressed:
                  importedMusicState
                      .isLoading
                      ? null
                      : () async {
                    final int
                    count =
                    await importedMusicNotifier
                        .importMusic();

                    if (!context
                        .mounted) {
                      return;
                    }

                    if (count >
                        0) {
                      ScaffoldMessenger
                          .of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content:
                          Text(
                            count ==
                                1
                                ? '1 song imported.'
                                : '$count songs imported.',
                          ),
                        ),
                      );
                    }
                  },

                  child:
                  importedMusicState
                      .isLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CupertinoActivityIndicator(
                      color:
                      Colors.white,
                    ),
                  )
                      : const Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children:
                    <Widget>[
                      Icon(
                        CupertinoIcons
                            .add,
                        color:
                        Colors.white,
                        size:
                        17,
                      ),
                      SizedBox(
                        width:
                        6,
                      ),
                      Text(
                        'Import',
                        style:
                        TextStyle(
                          color:
                          Colors.white,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          if (importedMusicState
              .errorMessage !=
              null) ...[
            Text(
              importedMusicState
                  .errorMessage!,

              style:
              const TextStyle(
                color:
                Colors.redAccent,
                fontSize: 13,
              ),
            ),

            const SizedBox(
              height: 12,
            ),
          ],

          if (importedMusicState
              .isLoading &&
              importedSongs.isEmpty)
            const _EmptyLibraryCard(
              icon:
              CupertinoIcons
                  .music_note_list,
              title:
              'Loading Imported Music',
              subtitle:
              'Restoring songs saved in Melody.',
            )
          else if (importedSongs.isEmpty)
            const _EmptyLibraryCard(
              icon:
              CupertinoIcons
                  .square_arrow_down,
              title:
              'No Imported Music',
              subtitle:
              'Tap Import to choose MP3 files from your device.',
            )
          else
            ...List<Widget>.generate(
              importedSongs.length,
                  (int index) {
                final Song song =
                importedSongs[
                index];

                final bool isCurrent =
                    playerState
                        .currentSong
                        ?.id ==
                        song.id;

                return _ImportedSongTile(
                  song:
                  song,

                  isCurrent:
                  isCurrent,

                  isPlaying:
                  isCurrent &&
                      playerState
                          .isPlaying,

                  onTap: () {
                    playerNotifier
                        .playQueue(
                      importedSongs,
                      startIndex:
                      index,
                    );
                  },

                  onRemove: () async {
                    if (isCurrent) {
                      await playerNotifier
                          .stop();
                    }

                    await importedMusicNotifier
                        .removeSong(
                      song,
                    );
                  },
                );
              },
            ),

          const SizedBox(
            height: 38,
          ),

          // ===================================================
          // ARTISTS
          // ===================================================

          Container(
            key:
            _artistsKey,

            child:
            _SectionHeader(
              title:
              'Artists',

              icon:
              CupertinoIcons
                  .person_2_fill,

              iconColor:
              neutralAccent,

              trailing:
              '${_albums.length}',
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          ..._albums.map(
                (Album album) {
              return _ArtistTile(
                artist:
                album.artist,

                artworkUrl:
                album.imageUrl,

                songCount:
                album.songs.length,

                onTap: () {
                  playerNotifier
                      .playQueue(
                    album.songs,
                    startIndex: 0,
                  );
                },
              );
            },
          ),

          const SizedBox(
            height: 38,
          ),

          // ===================================================
          // ALBUMS
          // ===================================================

          Container(
            key:
            _albumsKey,

            child:
            _SectionHeader(
              title:
              'Albums',

              icon:
              CupertinoIcons
                  .music_albums_fill,

              iconColor:
              neutralAccent,

              trailing:
              '${_albums.length}',
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          ..._albums.map(
                (Album album) {
              return _AlbumLibraryTile(
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

          const SizedBox(
            height: 38,
          ),

          // ===================================================
          // ALL SONGS
          // ===================================================

          Container(
            key:
            _songsKey,

            child:
            _SectionHeader(
              title:
              'Songs',

              icon:
              CupertinoIcons
                  .music_note_2,

              iconColor:
              neutralAccent,

              trailing:
              '${allSongs.length}',
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          ...List<Widget>.generate(
            allSongs.length,
                (int index) {
              final Song song =
              allSongs[index];

              final bool isCurrent =
                  playerState
                      .currentSong
                      ?.id ==
                      song.id;

              return _SongTile(
                song:
                song,

                isCurrent:
                isCurrent,

                isPlaying:
                isCurrent &&
                    playerState
                        .isPlaying,

                onTap: () {
                  playerNotifier
                      .playQueue(
                    allSongs,
                    startIndex:
                    index,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// LIBRARY CATEGORY
// ===========================================================

class _LibraryCategory
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LibraryCategory({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return Column(
      children:
      <Widget>[
        ListTile(
          contentPadding:
          EdgeInsets.zero,

          onTap:
          onTap,

          leading:
          SizedBox(
            width: 34,

            child:
            Icon(
              icon,
              color:
              const Color(
                0xFFFF2D55,
              ),
              size: 25,
            ),
          ),

          title:
          Text(
            title,

            style:
            TextStyle(
              color:
              colors.onSurface,
              fontSize: 18,
              fontWeight:
              FontWeight.w500,
            ),
          ),

          trailing:
          Icon(
            CupertinoIcons
                .chevron_right,

            color:
            colors.onSurface
                .withValues(
              alpha: 0.30,
            ),

            size: 18,
          ),
        ),

        Divider(
          height: 1,
          indent: 46,

          color:
          colors.onSurface
              .withValues(
            alpha: 0.10,
          ),
        ),
      ],
    );
  }
}

// ===========================================================
// NEW PLAYLIST TILE
// ===========================================================

class _NewPlaylistTile
    extends StatelessWidget {
  final VoidCallback onTap;

  const _NewPlaylistTile({
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    final bool isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    return ListTile(
      contentPadding:
      EdgeInsets.zero,

      onTap:
      onTap,

      leading:
      Container(
        width: 64,
        height: 64,

        alignment:
        Alignment.center,

        decoration:
        BoxDecoration(
          color: isDark
              ? const Color(
            0xFF2C2C2E,
          )
              : const Color(
            0xFFE9E9EE,
          ),

          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),

        child:
        const Icon(
          CupertinoIcons.add,
          color:
          Color(
            0xFFFF2D55,
          ),
          size: 30,
        ),
      ),

      title:
      Text(
        'New Playlist',

        style:
        TextStyle(
          color:
          colors.onSurface,
          fontSize: 16,
          fontWeight:
          FontWeight.w600,
        ),
      ),

      subtitle:
      Padding(
        padding:
        const EdgeInsets.only(
          top: 4,
        ),

        child:
        Text(
          'Create your own playlist',

          style:
          TextStyle(
            color:
            colors.onSurface
                .withValues(
              alpha: 0.54,
            ),
            fontSize: 13,
          ),
        ),
      ),

      trailing:
      Icon(
        CupertinoIcons
            .chevron_right,

        color:
        colors.onSurface
            .withValues(
          alpha: 0.30,
        ),

        size: 18,
      ),
    );
  }
}

// ===========================================================
// CUSTOM PLAYLIST
// ===========================================================

class _CustomPlaylistTile
    extends StatelessWidget {
  final String title;
  final int songCount;
  final VoidCallback onTap;

  const _CustomPlaylistTile({
    required this.title,
    required this.songCount,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return ListTile(
      contentPadding:
      EdgeInsets.zero,

      onTap:
      onTap,

      leading:
      Container(
        width: 64,
        height: 64,

        alignment:
        Alignment.center,

        decoration:
        BoxDecoration(
          gradient:
          const LinearGradient(
            begin:
            Alignment.topLeft,
            end:
            Alignment.bottomRight,
            colors:
            <Color>[
              Color(
                0xFF5856D6,
              ),
              Color(
                0xFFAF52DE,
              ),
            ],
          ),

          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),

        child:
        const Icon(
          CupertinoIcons
              .music_note_2,
          color:
          Colors.white,
          size: 27,
        ),
      ),

      title:
      Text(
        title,
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,

        style:
        TextStyle(
          color:
          colors.onSurface,
          fontSize: 16,
          fontWeight:
          FontWeight.w600,
        ),
      ),

      subtitle:
      Padding(
        padding:
        const EdgeInsets.only(
          top: 4,
        ),

        child:
        Text(
          '$songCount ${songCount == 1 ? 'song' : 'songs'}',

          style:
          TextStyle(
            color:
            colors.onSurface
                .withValues(
              alpha: 0.54,
            ),
            fontSize: 13,
          ),
        ),
      ),

      trailing:
      Icon(
        songCount > 0
            ? CupertinoIcons
            .play_circle_fill
            : CupertinoIcons
            .chevron_right,

        color:
        colors.onSurface
            .withValues(
          alpha: 0.38,
        ),

        size:
        songCount > 0
            ? 30
            : 18,
      ),
    );
  }
}

// ===========================================================
// STAT CARD
// ===========================================================

class _LibraryStatCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  const _LibraryStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    final bool isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    return Container(
      height: 105,

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(
        color: colors.onSurface
            .withValues(
          alpha:
          isDark
              ? 0.05
              : 0.035,
        ),

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border:
        Border.all(
          color:
          colors.onSurface
              .withValues(
            alpha:
            isDark
                ? 0.07
                : 0.06,
          ),
        ),
      ),

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children:
        <Widget>[
          Row(
            children:
            <Widget>[
              Icon(
                icon,
                color:
                accentColor,
                size: 20,
              ),

              const Spacer(),

              Text(
                value,

                style:
                TextStyle(
                  color:
                  colors.onSurface,
                  fontSize: 22,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            title,

            style:
            TextStyle(
              color:
              colors.onSurface
                  .withValues(
                alpha: 0.68,
              ),
              fontSize: 14,
              fontWeight:
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// SECTION HEADER
// ===========================================================

class _SectionHeader
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String? trailing;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.trailing,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return Row(
      children:
      <Widget>[
        Icon(
          icon,
          color:
          iconColor,
          size: 21,
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child:
          Text(
            title,

            style:
            TextStyle(
              color:
              colors.onSurface,
              fontSize: 22,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),

        if (trailing != null)
          Text(
            trailing!,

            style:
            TextStyle(
              color:
              colors.onSurface
                  .withValues(
                alpha: 0.38,
              ),
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}

// ===========================================================
// PLAYLIST TILE
// ===========================================================

class _PlaylistTile
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _PlaylistTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return ListTile(
      onTap:
      onTap,

      contentPadding:
      EdgeInsets.zero,

      leading:
      Container(
        width: 64,
        height: 64,

        alignment:
        Alignment.center,

        decoration:
        BoxDecoration(
          color:
          backgroundColor,

          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),

        child:
        Icon(
          icon,
          color:
          Colors.white,
          size: 28,
        ),
      ),

      title:
      Text(
        title,

        style:
        TextStyle(
          color:
          colors.onSurface,
          fontSize: 16,
          fontWeight:
          FontWeight.w600,
        ),
      ),

      subtitle:
      Padding(
        padding:
        const EdgeInsets.only(
          top: 4,
        ),

        child:
        Text(
          subtitle,

          style:
          TextStyle(
            color:
            colors.onSurface
                .withValues(
              alpha: 0.54,
            ),
            fontSize: 13,
          ),
        ),
      ),

      trailing:
      Icon(
        CupertinoIcons
            .play_circle_fill,

        color:
        colors.onSurface
            .withValues(
          alpha:
          onTap == null
              ? 0.20
              : 0.50,
        ),

        size: 30,
      ),
    );
  }
}

// ===========================================================
// ARTIST TILE
// ===========================================================

class _ArtistTile
    extends StatelessWidget {
  final String artist;
  final String artworkUrl;
  final int songCount;
  final VoidCallback onTap;

  const _ArtistTile({
    required this.artist,
    required this.artworkUrl,
    required this.songCount,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return Column(
      children:
      <Widget>[
        ListTile(
          onTap:
          onTap,

          contentPadding:
          const EdgeInsets
              .symmetric(
            vertical: 5,
          ),

          leading:
          ClipOval(
            child:
            Image.network(
              artworkUrl,
              width: 62,
              height: 62,
              fit:
              BoxFit.cover,

              errorBuilder:
                  (
                  BuildContext context,
                  Object error,
                  StackTrace?
                  stackTrace,
                  ) {
                return _artistPlaceholder(
                  context,
                );
              },
            ),
          ),

          title:
          Text(
            artist,

            style:
            TextStyle(
              color:
              colors.onSurface,
              fontSize: 17,
              fontWeight:
              FontWeight.w600,
            ),
          ),

          subtitle:
          Text(
            '$songCount ${songCount == 1 ? 'song' : 'songs'}',

            style:
            TextStyle(
              color:
              colors.onSurface
                  .withValues(
                alpha: 0.54,
              ),
              fontSize: 13,
            ),
          ),

          trailing:
          Icon(
            CupertinoIcons
                .play_circle_fill,

            color:
            colors.onSurface
                .withValues(
              alpha: 0.46,
            ),

            size: 28,
          ),
        ),

        Divider(
          height: 1,
          indent: 76,

          color:
          colors.onSurface
              .withValues(
            alpha: 0.10,
          ),
        ),
      ],
    );
  }

  Widget _artistPlaceholder(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    final bool isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    return Container(
      width: 62,
      height: 62,

      alignment:
      Alignment.center,

      color: isDark
          ? const Color(
        0xFF2C2C2E,
      )
          : const Color(
        0xFFE9E9EE,
      ),

      child:
      Icon(
        CupertinoIcons
            .person_fill,

        color:
        colors.onSurface
            .withValues(
          alpha: 0.38,
        ),
      ),
    );
  }
}

// ===========================================================
// EMPTY CARD
// ===========================================================

class _EmptyLibraryCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyLibraryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    final bool isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        20,
      ),

      decoration:
      BoxDecoration(
        color:
        colors.onSurface
            .withValues(
          alpha:
          isDark
              ? 0.04
              : 0.03,
        ),

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        border:
        Border.all(
          color:
          colors.onSurface
              .withValues(
            alpha: 0.05,
          ),
        ),
      ),

      child:
      Row(
        children:
        <Widget>[
          Icon(
            icon,

            color:
            colors.onSurface
                .withValues(
              alpha: 0.30,
            ),

            size: 30,
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children:
              <Widget>[
                Text(
                  title,

                  style:
                  TextStyle(
                    color:
                    colors.onSurface,
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  subtitle,

                  style:
                  TextStyle(
                    color:
                    colors.onSurface
                        .withValues(
                      alpha: 0.54,
                    ),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// SONG TILE
// ===========================================================

class _SongTile
    extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SongTile({
    required this.song,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return Column(
      children:
      <Widget>[
        ListTile(
          onTap:
          onTap,

          contentPadding:
          EdgeInsets.zero,

          leading:
          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              9,
            ),

            child:
            song.artworkUrl !=
                null &&
                song.artworkUrl!
                    .isNotEmpty
                ? Image.network(
              song.artworkUrl!,
              width: 54,
              height: 54,
              fit:
              BoxFit.cover,

              errorBuilder:
                  (
                  BuildContext
                  context,
                  Object error,
                  StackTrace?
                  stackTrace,
                  ) {
                return _songPlaceholder(
                  context,
                  54,
                );
              },
            )
                : _songPlaceholder(
              context,
              54,
            ),
          ),

          title:
          Text(
            song.title,

            maxLines: 1,

            overflow:
            TextOverflow
                .ellipsis,

            style:
            TextStyle(
              color: isCurrent
                  ? const Color(
                0xFFFF2D55,
              )
                  : colors
                  .onSurface,

              fontSize: 16,

              fontWeight:
              isCurrent
                  ? FontWeight
                  .w600
                  : FontWeight
                  .normal,
            ),
          ),

          subtitle:
          Text(
            song.artist,

            maxLines: 1,

            overflow:
            TextOverflow
                .ellipsis,

            style:
            TextStyle(
              color:
              colors.onSurface
                  .withValues(
                alpha: 0.54,
              ),

              fontSize: 13,
            ),
          ),

          trailing:
          isPlaying
              ? const Icon(
            CupertinoIcons
                .waveform,

            color:
            Color(
              0xFFFF2D55,
            ),

            size: 21,
          )
              : Icon(
            CupertinoIcons
                .chevron_right,

            color:
            colors
                .onSurface
                .withValues(
              alpha:
              0.38,
            ),

            size: 18,
          ),
        ),

        Divider(
          height: 1,
          indent: 66,

          color:
          colors.onSurface
              .withValues(
            alpha: 0.10,
          ),
        ),
      ],
    );
  }
}

// ===========================================================
// IMPORTED SONG TILE
// ===========================================================

class _ImportedSongTile
    extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;
  final Future<void> Function()
  onRemove;

  const _ImportedSongTile({
    required this.song,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return Column(
      children:
      <Widget>[
        ListTile(
          onTap:
          onTap,

          contentPadding:
          EdgeInsets.zero,

          leading:
          Container(
            width: 54,
            height: 54,

            alignment:
            Alignment.center,

            decoration:
            BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                9,
              ),

              gradient:
              const LinearGradient(
                begin:
                Alignment.topLeft,
                end:
                Alignment.bottomRight,

                colors:
                <Color>[
                  Color(
                    0xFF5E5CE6,
                  ),
                  Color(
                    0xFFAF52DE,
                  ),
                ],
              ),
            ),

            child:
            const Icon(
              CupertinoIcons
                  .music_note_2,

              color:
              Colors.white,

              size: 23,
            ),
          ),

          title:
          Text(
            song.title,

            maxLines: 1,

            overflow:
            TextOverflow
                .ellipsis,

            style:
            TextStyle(
              color: isCurrent
                  ? const Color(
                0xFFFF2D55,
              )
                  : colors
                  .onSurface,

              fontSize: 16,

              fontWeight:
              isCurrent
                  ? FontWeight
                  .w600
                  : FontWeight
                  .normal,
            ),
          ),

          subtitle:
          Text(
            'Imported Music',

            maxLines: 1,

            overflow:
            TextOverflow
                .ellipsis,

            style:
            TextStyle(
              color:
              colors.onSurface
                  .withValues(
                alpha: 0.54,
              ),

              fontSize: 13,
            ),
          ),

          trailing:
          Row(
            mainAxisSize:
            MainAxisSize.min,

            children:
            <Widget>[
              if (isPlaying)
                const Padding(
                  padding:
                  EdgeInsets.only(
                    right: 8,
                  ),

                  child:
                  Icon(
                    CupertinoIcons
                        .waveform,

                    color:
                    Color(
                      0xFFFF2D55,
                    ),

                    size: 21,
                  ),
                ),

              CupertinoButton(
                padding:
                const EdgeInsets
                    .all(
                  6,
                ),

                minimumSize:
                const Size(
                  32,
                  32,
                ),

                onPressed: () async {
                  final bool?
                  shouldRemove =
                  await showCupertinoDialog<
                      bool>(
                    context:
                    context,

                    builder:
                        (
                        BuildContext
                        dialogContext,
                        ) {
                      return CupertinoAlertDialog(
                        title:
                        const Text(
                          'Remove Song?',
                        ),

                        content:
                        Text(
                          'Remove "${song.title}" from Melody?',
                        ),

                        actions:
                        <Widget>[
                          CupertinoDialogAction(
                            onPressed:
                                () {
                              Navigator.of(
                                dialogContext,
                              ).pop(
                                false,
                              );
                            },
                            child:
                            const Text(
                              'Cancel',
                            ),
                          ),

                          CupertinoDialogAction(
                            isDestructiveAction:
                            true,

                            onPressed:
                                () {
                              Navigator.of(
                                dialogContext,
                              ).pop(
                                true,
                              );
                            },

                            child:
                            const Text(
                              'Remove',
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldRemove !=
                      true) {
                    return;
                  }

                  await onRemove();
                },

                child:
                Icon(
                  CupertinoIcons
                      .ellipsis,

                  color:
                  colors.onSurface
                      .withValues(
                    alpha: 0.54,
                  ),

                  size: 20,
                ),
              ),
            ],
          ),
        ),

        Divider(
          height: 1,
          indent: 66,

          color:
          colors.onSurface
              .withValues(
            alpha: 0.10,
          ),
        ),
      ],
    );
  }
}

// ===========================================================
// RECENT SONG CARD
// ===========================================================

class _RecentSongCard
    extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;

  const _RecentSongCard({
    required this.song,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return GestureDetector(
      onTap:
      onTap,

      child:
      SizedBox(
        width: 145,

        child:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children:
          <Widget>[
            Stack(
              children:
              <Widget>[
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),

                  child:
                  song.artworkUrl !=
                      null &&
                      song
                          .artworkUrl!
                          .isNotEmpty
                      ? Image.network(
                    song.artworkUrl!,
                    width:
                    145,
                    height:
                    145,
                    fit:
                    BoxFit.cover,

                    errorBuilder:
                        (
                        BuildContext
                        context,
                        Object
                        error,
                        StackTrace?
                        stackTrace,
                        ) {
                      return _songPlaceholder(
                        context,
                        145,
                      );
                    },
                  )
                      : _songPlaceholder(
                    context,
                    145,
                  ),
                ),

                if (isCurrent)
                  Positioned.fill(
                    child:
                    Container(
                      decoration:
                      BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),

                        // Keep dark because
                        // this is over artwork.
                        color:
                        Colors.black
                            .withValues(
                          alpha: 0.25,
                        ),
                      ),

                      alignment:
                      Alignment.center,

                      child:
                      Icon(
                        isPlaying
                            ? CupertinoIcons
                            .waveform
                            : CupertinoIcons
                            .play_fill,

                        color:
                        Colors.white,

                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              song.title,

              maxLines: 1,

              overflow:
              TextOverflow
                  .ellipsis,

              style:
              TextStyle(
                color:
                colors.onSurface,

                fontSize: 14,

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
              TextOverflow
                  .ellipsis,

              style:
              TextStyle(
                color:
                colors.onSurface
                    .withValues(
                  alpha: 0.54,
                ),

                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// ALBUM TILE
// ===========================================================

class _AlbumLibraryTile
    extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;

  const _AlbumLibraryTile({
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return Column(
      children:
      <Widget>[
        ListTile(
          onTap:
          onTap,

          contentPadding:
          const EdgeInsets
              .symmetric(
            vertical: 5,
          ),

          leading:
          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              10,
            ),

            child:
            Image.network(
              album.imageUrl,

              width: 62,
              height: 62,

              fit:
              BoxFit.cover,

              errorBuilder:
                  (
                  BuildContext context,
                  Object error,
                  StackTrace?
                  stackTrace,
                  ) {
                return _songPlaceholder(
                  context,
                  62,
                );
              },
            ),
          ),

          title:
          Text(
            album.title,

            maxLines: 1,

            overflow:
            TextOverflow
                .ellipsis,

            style:
            TextStyle(
              color:
              colors.onSurface,

              fontSize: 16,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          subtitle:
          Text(
            '${album.artist} • ${album.songs.length} songs',

            style:
            TextStyle(
              color:
              colors.onSurface
                  .withValues(
                alpha: 0.54,
              ),

              fontSize: 13,
            ),
          ),

          trailing:
          Icon(
            CupertinoIcons
                .chevron_right,

            color:
            colors.onSurface
                .withValues(
              alpha: 0.30,
            ),

            size: 18,
          ),
        ),

        Divider(
          height: 1,
          indent: 76,

          color:
          colors.onSurface
              .withValues(
            alpha: 0.10,
          ),
        ),
      ],
    );
  }
}

// ===========================================================
// SONG PLACEHOLDER
// ===========================================================

Widget _songPlaceholder(
    BuildContext context,
    double size,
    ) {
  final ColorScheme colors =
      Theme.of(context)
          .colorScheme;

  final bool isDark =
      Theme.of(context)
          .brightness ==
          Brightness.dark;

  return Container(
    width:
    size,

    height:
    size,

    alignment:
    Alignment.center,

    color: isDark
        ? const Color(
      0xFF2C2C2E,
    )
        : const Color(
      0xFFE9E9EE,
    ),

    child:
    Icon(
      CupertinoIcons
          .music_note_2,

      color:
      colors.onSurface
          .withValues(
        alpha: 0.38,
      ),

      size:
      size > 100
          ? 42
          : 22,
    ),
  );
}