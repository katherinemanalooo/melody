import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:melody/providers/app/theme_provider.dart';
import 'package:melody/providers/library/favorites_provider.dart';
import 'package:melody/providers/library/recently_played_provider.dart';
import 'package:melody/providers/profile/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
  });

  // ===========================================================
  // AVATAR OPTIONS
  // ===========================================================

  static const List<IconData> _avatarIcons = [
    CupertinoIcons.person_fill,
    CupertinoIcons.music_note_2,
    CupertinoIcons.headphones,
    CupertinoIcons.heart_fill,
    CupertinoIcons.star_fill,
    CupertinoIcons.bolt_fill,
    CupertinoIcons.game_controller_solid,
    CupertinoIcons.smiley_fill,
  ];

  static const List<Color> _avatarColors = [
    Color(0xFF5C4B9B),
    Color(0xFFFF2D55),
    Color(0xFF007AFF),
    Color(0xFF34C759),
    Color(0xFFFF9500),
    Color(0xFFAF52DE),
    Color(0xFF00C7BE),
    Color(0xFF636366),
  ];

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final ProfileState profile =
    ref.watch(profileProvider);

    final favorites =
    ref.watch(favoritesProvider);

    final recentlyPlayed =
    ref.watch(recentlyPlayedProvider);

    final ThemeMode themeMode =
    ref.watch(themeProvider);

    final bool isDarkMode =
        themeMode == ThemeMode.dark;

    final int safeIconIndex =
        profile.avatarIconIndex %
            _avatarIcons.length;

    final int safeColorIndex =
        profile.avatarColorIndex %
            _avatarColors.length;

    final IconData avatarIcon =
    _avatarIcons[safeIconIndex];

    final Color avatarColor =
    _avatarColors[safeColorIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // =================================================
              // TOP BAR
              // =================================================

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 48,
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              // =================================================
              // AVATAR
              // =================================================

              Center(
                child: GestureDetector(
                  behavior:
                  HitTestBehavior.opaque,
                  onTap: () {
                    _showAvatarCustomizer(
                      context,
                      ref,
                      profile,
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration:
                        const Duration(
                          milliseconds: 250,
                        ),
                        width: 96,
                        height: 96,
                        decoration:
                        BoxDecoration(
                          color: avatarColor,
                          shape:
                          BoxShape.circle,
                        ),
                        child: Icon(
                          avatarIcon,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),

                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFFFF2D55,
                            ),
                            shape:
                            BoxShape.circle,
                            border:
                            Border.all(
                              color:
                              Colors.black,
                              width: 3,
                            ),
                          ),
                          child:
                          const Icon(
                            CupertinoIcons
                                .pencil,
                            color:
                            Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // =================================================
              // NAME
              // =================================================

              Center(
                child: Text(
                  profile.name,
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              const Center(
                child: Text(
                  'Melody Listener',
                  style: TextStyle(
                    color:
                    Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // =================================================
              // EDIT NAME
              // =================================================

              Center(
                child: TextButton.icon(
                  onPressed: () {
                    _showEditNameDialog(
                      context,
                      ref,
                      profile.name,
                    );
                  },
                  icon: const Icon(
                    CupertinoIcons.pencil,
                    color:
                    Color(
                      0xFFFF2D55,
                    ),
                    size: 18,
                  ),
                  label:
                  const Text(
                    'Edit Name',
                    style: TextStyle(
                      color:
                      Color(
                        0xFFFF2D55,
                      ),
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // =================================================
              // STATS
              // =================================================

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      icon:
                      CupertinoIcons
                          .heart_fill,
                      iconColor:
                      Colors.pink,
                      title:
                      'Favorites',
                      value:
                      favorites.length
                          .toString(),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: _infoCard(
                      icon:
                      CupertinoIcons
                          .clock_fill,
                      iconColor:
                      Colors.grey,
                      title:
                      'Recently Played',
                      value:
                      recentlyPlayed
                          .length
                          .toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 24,
              ),

              // =================================================
              // APPEARANCE
              // =================================================

              _sectionLabel(
                'APPEARANCE',
              ),

              const SizedBox(
                height: 10,
              ),

              _tileCard(
                child: Row(
                  children: [
                    _leadingIconBox(
                      icon:
                      CupertinoIcons
                          .moon_fill,
                      color:
                      const Color(
                        0xFF6C63FF,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    const Expanded(
                      child: Text(
                        'Dark Mode',
                        style:
                        TextStyle(
                          color:
                          Colors.white,
                          fontSize: 16,
                          fontWeight:
                          FontWeight
                              .w500,
                        ),
                      ),
                    ),

                    CupertinoSwitch(
                      value: isDarkMode,
                      activeTrackColor: const Color(
                        0xFFFF2D55,
                      ),
                      onChanged: (bool value) {
                        ref
                            .read(themeProvider.notifier)
                            .setDarkMode(value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // =================================================
              // PLAYBACK
              // =================================================

              _sectionLabel(
                'PLAYBACK',
              ),

              const SizedBox(
                height: 10,
              ),

              _tileCard(
                child: Column(
                  children: [
                    _settingsRow(
                      icon:
                      CupertinoIcons
                          .speaker_2_fill,
                      iconColor:
                      Colors.blue,
                      title:
                      'Audio Quality',
                      subtitle:
                      'Standard',
                      trailing:
                      const Icon(
                        CupertinoIcons
                            .chevron_right,
                        color:
                        Colors.white38,
                        size: 18,
                      ),
                    ),

                    const Divider(
                      color:
                      Colors.white10,
                      height: 20,
                    ),

                    _settingsRow(
                      icon:
                      CupertinoIcons
                          .waveform,
                      iconColor:
                      Colors.green,
                      title:
                      'Sound Check',
                      subtitle:
                      'Normalize volume',
                      trailing:
                      CupertinoSwitch(
                        value: false,
                        activeTrackColor:
                        const Color(
                          0xFFFF2D55,
                        ),
                        onChanged:
                            (_) {},
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // =================================================
              // MELODY
              // =================================================

              _sectionLabel(
                'MELODY',
              ),

              const SizedBox(
                height: 10,
              ),

              _tileCard(
                child: _settingsRow(
                  icon:
                  CupertinoIcons
                      .info_circle_fill,
                  iconColor:
                  Colors.grey,
                  title:
                  'About Melody',
                  subtitle:
                  'Version 1.0.0',
                  trailing:
                  const Icon(
                    CupertinoIcons
                        .chevron_right,
                    color:
                    Colors.white38,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // EDIT NAME
  // ===========================================================
  //
  // No TextEditingController is used here.
  //
  // This avoids the controller/dialog lifecycle issue that
  // previously caused the red Flutter assertion screen.
  // ===========================================================

  static Future<void> _showEditNameDialog(
      BuildContext context,
      WidgetRef ref,
      String currentName,
      ) async {
    String editedName =
        currentName;

    final String? result =
    await showDialog<String>(
      context: context,
      builder: (
          BuildContext dialogContext,
          ) {
        return AlertDialog(
          backgroundColor:
          const Color(
            0xFF1C1C1E,
          ),
          title: const Text(
            'Edit Name',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content:
          TextFormField(
            initialValue:
            currentName,
            autofocus: true,
            textCapitalization:
            TextCapitalization.words,
            style:
            const TextStyle(
              color: Colors.white,
            ),
            decoration:
            InputDecoration(
              hintText:
              'Enter your name',
              hintStyle:
              const TextStyle(
                color:
                Colors.white38,
              ),
              filled: true,
              fillColor:
              const Color(
                0xFF2C2C2E,
              ),
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
                borderSide:
                BorderSide.none,
              ),
            ),
            onChanged: (
                String value,
                ) {
              editedName =
                  value;
            },
            onFieldSubmitted: (
                String value,
                ) {
              final String cleanName =
              value.trim();

              if (cleanName.isEmpty) {
                return;
              }

              Navigator.of(
                dialogContext,
              ).pop(
                cleanName,
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child:
              const Text(
                'Cancel',
                style: TextStyle(
                  color:
                  Colors.white54,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                final String cleanName =
                editedName.trim();

                if (cleanName.isEmpty) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(
                  cleanName,
                );
              },
              child:
              const Text(
                'Save',
                style: TextStyle(
                  color:
                  Color(
                    0xFFFF2D55,
                  ),
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    final String cleanName =
    result.trim();

    if (cleanName.isEmpty ||
        cleanName == currentName) {
      return;
    }

    // Dialog is already closed here.
    // Update Riverpod afterwards.
    await ref
        .read(
      profileProvider.notifier,
    )
        .updateName(
      cleanName,
    );
  }

  // ===========================================================
  // AVATAR CUSTOMIZER
  // ===========================================================

  static Future<void> _showAvatarCustomizer(
      BuildContext context,
      WidgetRef ref,
      ProfileState profile,
      ) async {
    int selectedIcon =
        profile.avatarIconIndex %
            _avatarIcons.length;

    int selectedColor =
        profile.avatarColorIndex %
            _avatarColors.length;

    final Map<String, int>? result =
    await showModalBottomSheet<
        Map<String, int>>(
      context: context,
      backgroundColor:
      const Color(
        0xFF1C1C1E,
      ),
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top:
          Radius.circular(
            28,
          ),
        ),
      ),
      builder: (
          BuildContext sheetContext,
          ) {
        return StatefulBuilder(
          builder: (
              BuildContext context,
              StateSetter setModalState,
              ) {
            return SafeArea(
              top: false,
              child: Padding(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  20,
                  18,
                  20,
                  24,
                ),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white24,
                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    const Text(
                      'Customize Profile',
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // =======================================
                    // PREVIEW
                    // =======================================

                    AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds:
                        200,
                      ),
                      width: 92,
                      height: 92,
                      decoration:
                      BoxDecoration(
                        shape:
                        BoxShape.circle,
                        color:
                        _avatarColors[
                        selectedColor],
                      ),
                      child: Icon(
                        _avatarIcons[
                        selectedIcon],
                        color:
                        Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    const Align(
                      alignment:
                      Alignment
                          .centerLeft,
                      child: Text(
                        'Choose Icon',
                        style:
                        TextStyle(
                          color:
                          Colors.white70,
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment:
                      WrapAlignment
                          .center,
                      children:
                      List.generate(
                        _avatarIcons.length,
                            (
                            int index,
                            ) {
                          final bool
                          selected =
                              selectedIcon ==
                                  index;

                          return GestureDetector(
                            onTap: () {
                              setModalState(
                                    () {
                                  selectedIcon =
                                      index;
                                },
                              );
                            },
                            child:
                            AnimatedContainer(
                              duration:
                              const Duration(
                                milliseconds:
                                180,
                              ),
                              width: 54,
                              height: 54,
                              decoration:
                              BoxDecoration(
                                shape:
                                BoxShape
                                    .circle,
                                color:
                                selected
                                    ? Colors
                                    .white24
                                    : Colors
                                    .white10,
                                border:
                                Border.all(
                                  color:
                                  selected
                                      ? const Color(
                                    0xFFFF2D55,
                                  )
                                      : Colors
                                      .transparent,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _avatarIcons[
                                index],
                                color:
                                Colors.white,
                                size: 23,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    const Align(
                      alignment:
                      Alignment
                          .centerLeft,
                      child: Text(
                        'Choose Color',
                        style:
                        TextStyle(
                          color:
                          Colors.white70,
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment:
                      WrapAlignment
                          .center,
                      children:
                      List.generate(
                        _avatarColors.length,
                            (
                            int index,
                            ) {
                          final bool
                          selected =
                              selectedColor ==
                                  index;

                          return GestureDetector(
                            onTap: () {
                              setModalState(
                                    () {
                                  selectedColor =
                                      index;
                                },
                              );
                            },
                            child:
                            Container(
                              width: 46,
                              height: 46,
                              decoration:
                              BoxDecoration(
                                shape:
                                BoxShape
                                    .circle,
                                color:
                                _avatarColors[
                                index],
                                border:
                                Border.all(
                                  color:
                                  selected
                                      ? Colors
                                      .white
                                      : Colors
                                      .transparent,
                                  width: 3,
                                ),
                              ),
                              child:
                              selected
                                  ? const Icon(
                                CupertinoIcons
                                    .check_mark,
                                color:
                                Colors
                                    .white,
                                size: 19,
                              )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    SizedBox(
                      width:
                      double.infinity,
                      height: 50,
                      child:
                      FilledButton(
                        onPressed: () {
                          Navigator.of(
                            sheetContext,
                          ).pop(
                            <String, int>{
                              'icon':
                              selectedIcon,
                              'color':
                              selectedColor,
                            },
                          );
                        },
                        style:
                        FilledButton
                            .styleFrom(
                          backgroundColor:
                          const Color(
                            0xFFFF2D55,
                          ),
                          foregroundColor:
                          Colors.white,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                        child:
                        const Text(
                          'Save Avatar',
                          style:
                          TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    await ref
        .read(
      profileProvider.notifier,
    )
        .updateAvatar(
      iconIndex:
      result['icon'] ?? 0,
      colorIndex:
      result['color'] ?? 0,
    );
  }

  // ===========================================================
  // INFO CARD
  // ===========================================================

  static Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(
        16,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFF111111,
        ),
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        border:
        Border.all(
          color:
          Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 16,
              ),

              const Spacer(),

              Text(
                value,
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 22,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            title,
            style:
            const TextStyle(
              color:
              Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // SECTION LABEL
  // ===========================================================

  static Widget _sectionLabel(
      String text,
      ) {
    return Text(
      text,
      style:
      const TextStyle(
        color:
        Colors.white38,
        fontSize: 11,
        fontWeight:
        FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  // ===========================================================
  // TILE CARD
  // ===========================================================

  static Widget _tileCard({
    required Widget child,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFF111111,
        ),
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        border:
        Border.all(
          color:
          Colors.white10,
        ),
      ),
      child: child,
    );
  }

  // ===========================================================
  // SETTINGS ROW
  // ===========================================================

  static Widget _settingsRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        _leadingIconBox(
          icon: icon,
          color: iconColor,
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                subtitle,
                style:
                const TextStyle(
                  color:
                  Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        trailing,
      ],
    );
  }

  // ===========================================================
  // LEADING ICON BOX
  // ===========================================================

  static Widget _leadingIconBox({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 30,
      height: 30,
      decoration:
      BoxDecoration(
        color: color,
        borderRadius:
        BorderRadius.circular(
          8,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}