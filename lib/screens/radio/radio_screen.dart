import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:melody/models/song.dart';
import 'package:melody/providers/player/player_provider.dart';

class RadioScreen extends ConsumerWidget {
  final ScrollController? scrollController;

  const RadioScreen({
    super.key,
    this.scrollController,
  });

  // =========================================================
  // DEMO RADIO STATIONS
  // =========================================================

  static const List<Song> stations = <Song>[
    Song(
      id: 'radio-night-drive',
      title: 'Night Drive Radio',
      artist: 'Melody Radio',
      audioUrl:
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      artworkUrl:
      'https://picsum.photos/seed/nightdrive-radio/800/800',
    ),
    Song(
      id: 'radio-chill',
      title: 'Chill Waves',
      artist: 'Melody Radio',
      audioUrl:
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      artworkUrl:
      'https://picsum.photos/seed/chill-radio/800/800',
    ),
    Song(
      id: 'radio-focus',
      title: 'Focus Flow',
      artist: 'Melody Radio',
      audioUrl:
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      artworkUrl:
      'https://picsum.photos/seed/focus-radio/800/800',
    ),
    Song(
      id: 'radio-pop',
      title: 'Pop Central',
      artist: 'Melody Radio',
      audioUrl:
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      artworkUrl:
      'https://picsum.photos/seed/pop-radio/800/800',
    ),
    Song(
      id: 'radio-sunset',
      title: 'Sunset Sessions',
      artist: 'Melody Radio',
      audioUrl:
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      artworkUrl:
      'https://picsum.photos/seed/sunset-radio/800/800',
    ),
  ];

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    final playerState =
    ref.watch(playerProvider);

    final playerNotifier =
    ref.read(playerProvider.notifier);

    return ListView(

      controller: scrollController,

      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        190,
      ),

      children: <Widget>[
        // =====================================================
        // FEATURED
        // =====================================================

        Text(
          'Featured Station',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        _FeaturedStation(
          station: stations.first,
          isPlaying:
          playerState.currentSong?.id ==
              stations.first.id &&
              playerState.isPlaying,
          onTap: () async {
            await playerNotifier.playQueue(
              stations,
              startIndex: 0,
            );

            if (!context.mounted) {
              return;
            }

            context.push(
              '/now-playing',
            );
          },
        ),

        const SizedBox(
          height: 32,
        ),

        // =====================================================
        // STATIONS
        // =====================================================

        Text(
          'Stations',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        ...List<Widget>.generate(
          stations.length,
              (int index) {
            final Song station =
            stations[index];

            final bool isCurrent =
                playerState.currentSong?.id ==
                    station.id;

            final bool isPlaying =
                isCurrent &&
                    playerState.isPlaying;

            return _StationTile(
              station: station,
              isCurrent: isCurrent,
              isPlaying: isPlaying,
              onTap: () async {
                await playerNotifier.playQueue(
                  stations,
                  startIndex: index,
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
      ],
    );
  }
}

// ===========================================================
// FEATURED STATION
// ===========================================================

class _FeaturedStation extends StatelessWidget {
  final Song station;
  final bool isPlaying;
  final VoidCallback onTap;

  const _FeaturedStation({
    required this.station,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,

      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(
          24,
        ),

        child: SizedBox(
          height: 280,

          child: Stack(
            fit: StackFit.expand,

            children: <Widget>[
              // =================================================
              // ARTWORK
              // =================================================

              if (station.artworkUrl != null &&
                  station.artworkUrl!.isNotEmpty)
                Image.network(
                  station.artworkUrl!,
                  fit: BoxFit.cover,

                  errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                      ) {
                    return const ColoredBox(
                      color:
                      Color(
                        0xFF252527,
                      ),
                    );
                  },
                )
              else
                const ColoredBox(
                  color:
                  Color(
                    0xFF252527,
                  ),
                ),

              // =================================================
              // IMAGE OVERLAY
              //
              // Keep this dark in BOTH themes because
              // text is displayed directly over artwork.
              // =================================================

              const DecoratedBox(
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    begin:
                    Alignment.topCenter,
                    end:
                    Alignment.bottomCenter,
                    colors:
                    <Color>[
                      Colors.transparent,
                      Color(
                        0x22000000,
                      ),
                      Color(
                        0xEE000000,
                      ),
                    ],
                    stops:
                    <double>[
                      0,
                      0.45,
                      1,
                    ],
                  ),
                ),
              ),

              // =================================================
              // CONTENT
              // =================================================

              Positioned(
                left: 20,
                right: 20,
                bottom: 20,

                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,

                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children:
                        <Widget>[
                          // =====================================
                          // RADIO BADGE
                          // =====================================

                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),

                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFFFF2D55,
                              ),

                              borderRadius:
                              BorderRadius
                                  .circular(
                                20,
                              ),
                            ),

                            child:
                            const Text(
                              'RADIO',

                              style:
                              TextStyle(
                                color:
                                Colors.white,
                                fontSize:
                                10,
                                fontWeight:
                                FontWeight
                                    .w800,
                                letterSpacing:
                                1,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 9,
                          ),

                          // =====================================
                          // STATION TITLE
                          // =====================================

                          Text(
                            station.title,

                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,

                            style:
                            const TextStyle(
                              color:
                              Colors.white,
                              fontSize:
                              27,
                              fontWeight:
                              FontWeight
                                  .w700,
                              letterSpacing:
                              -0.7,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            station.artist,

                            style:
                            const TextStyle(
                              color:
                              Colors.white70,
                              fontSize:
                              15,
                              fontWeight:
                              FontWeight
                                  .w500,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          const Text(
                            'Music for late-night listening',

                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,

                            style:
                            TextStyle(
                              color:
                              Colors.white54,
                              fontSize:
                              13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 15,
                    ),

                    // ===========================================
                    // FEATURED PLAY BUTTON
                    // ===========================================

                    Container(
                      width: 52,
                      height: 52,

                      alignment:
                      Alignment.center,

                      decoration:
                      BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: 0.94,
                        ),

                        shape:
                        BoxShape.circle,

                        boxShadow:
                        <BoxShadow>[
                          BoxShadow(
                            color:
                            Colors.black
                                .withValues(
                              alpha: 0.18,
                            ),
                            blurRadius:
                            15,
                            offset:
                            const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),

                      child: Icon(
                        isPlaying
                            ? CupertinoIcons
                            .pause_fill
                            : CupertinoIcons
                            .play_fill,

                        color:
                        Colors.black,

                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// STATION TILE
// ===========================================================

class _StationTile extends StatelessWidget {
  final Song station;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;

  const _StationTile({
    required this.station,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    final bool isDarkMode =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Column(
      children: <Widget>[
        ListTile(
          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 5,
          ),

          onTap: onTap,

          // ===================================================
          // ARTWORK
          // ===================================================

          leading: ClipRRect(
            borderRadius:
            BorderRadius.circular(
              12,
            ),

            child:
            station.artworkUrl != null &&
                station
                    .artworkUrl!
                    .isNotEmpty
                ? Image.network(
              station.artworkUrl!,
              width: 64,
              height: 64,
              fit: BoxFit.cover,

              errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace?
                  stackTrace,
                  ) {
                return _placeholder(
                  context,
                );
              },
            )
                : _placeholder(
              context,
            ),
          ),

          // ===================================================
          // TITLE
          // ===================================================

          title: Text(
            station.title,

            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,

            style: TextStyle(
              color: isCurrent
                  ? const Color(
                0xFFFF2D55,
              )
                  : colors.onSurface,

              fontSize: 16,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          // ===================================================
          // SUBTITLE
          // ===================================================

          subtitle: Padding(
            padding:
            const EdgeInsets.only(
              top: 5,
            ),

            child: Row(
              children: <Widget>[
                Container(
                  width: 6,
                  height: 6,

                  decoration:
                  const BoxDecoration(
                    color:
                    Color(
                      0xFFFF2D55,
                    ),
                    shape:
                    BoxShape.circle,
                  ),
                ),

                const SizedBox(
                  width: 6,
                ),

                Expanded(
                  child: Text(
                    station.artist,

                    maxLines: 1,

                    overflow:
                    TextOverflow
                        .ellipsis,

                    style: TextStyle(
                      color:
                      colors.onSurface
                          .withValues(
                        alpha:
                        isDarkMode
                            ? 0.54
                            : 0.55,
                      ),

                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===================================================
          // PLAYING INDICATOR
          // ===================================================

          trailing: isPlaying
              ? const Icon(
            CupertinoIcons
                .waveform,

            color:
            Color(
              0xFFFF2D55,
            ),

            size: 23,
          )
              : Icon(
            CupertinoIcons
                .play_circle_fill,

            color:
            colors.onSurface
                .withValues(
              alpha:
              isDarkMode
                  ? 0.54
                  : 0.42,
            ),

            size: 29,
          ),
        ),

        // =====================================================
        // DIVIDER
        // =====================================================

        Divider(
          height: 1,
          indent: 78,

          color:
          colors.onSurface
              .withValues(
            alpha:
            isDarkMode
                ? 0.10
                : 0.08,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PLACEHOLDER
  // =========================================================

  Widget _placeholder(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    final bool isDarkMode =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(
      width: 64,
      height: 64,

      alignment:
      Alignment.center,

      decoration:
      BoxDecoration(
        color: isDarkMode
            ? const Color(
          0xFF2C2C2E,
        )
            : const Color(
          0xFFE9E9EE,
        ),
      ),

      child: Icon(
        CupertinoIcons
            .antenna_radiowaves_left_right,

        color:
        colors.onSurface
            .withValues(
          alpha: 0.38,
        ),

        size: 25,
      ),
    );
  }
}