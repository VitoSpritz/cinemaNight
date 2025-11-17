import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../consts/custom_colors.dart';
import '../helpers/image_converter.dart';
import '../l10n/app_localizations.dart';
import '../model/user_profile.dart';
import '../providers/user_profiles.dart';
import '../services/user_service.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_dropdown_menu.dart';
import '../widget/custom_icon_button.dart';
import 'login.dart';

class Account extends ConsumerStatefulWidget {
  static String path = '/account';

  const Account({super.key});

  @override
  ConsumerState<Account> createState() => _AccountState();
}

class _AccountState extends ConsumerState<Account> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _movieController = TextEditingController();
  final UserService _userProfileService = UserService();
  File? _selectedImage;
  ImageProvider? _cachedImageProvider;

  final List<String> _genres = <String>[
    'Azione',
    'Avventura',
    'Animazione',
    'Biografico',
    'Commedia',
    'Documentario',
    'Drammatico',
    'Fantascienza',
    'Fantasy',
    'Guerra',
    'Horror',
    'Musical',
    'Noir',
    'Romantico',
    'Storico',
    'Thriller',
    'Western',
  ];

  bool _hasUnsavedChanges = false;
  String? _originalName;
  String? _originalGenre;
  String? _originalMovie;
  String? _selectedGenere;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkForChanges);
    _movieController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {
      _hasUnsavedChanges =
          _nameController.text != (_originalName ?? '') ||
          _genreController.text != (_originalGenre ?? '') ||
          _movieController.text != (_originalMovie ?? '') ||
          _selectedImage != null;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File newImageFile = File(image.path);
      setState(() {
        _selectedImage = newImageFile;
        _cachedImageProvider = FileImage(newImageFile);
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genreController.dispose();
    _movieController.dispose();
    _nameController.dispose();
    _genreController.dispose();
    _movieController.dispose();
    super.dispose();
  }

  void _updateUserProfile({
    required String userId,
    required String name,
    int? age,
    String? imageUrl,
    String? preferredFilm,
    String? preferredGenre,
  }) async {
    await _userProfileService.updateUser(
      userId: userId,
      name: name,
      age: age,
      imageUrl: imageUrl,
      preferredFilm: preferredFilm,
      preferredGenre: preferredGenre,
    );

    setState(() {
      _hasUnsavedChanges = false;
      _selectedImage = null;
      _originalName = name;
      _originalGenre = preferredGenre;
      _originalMovie = preferredFilm;
    });

    ref.refresh(userProfilesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserProfile> userProvider = ref.watch(
      userProfilesProvider,
    );

    return Stack(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: <double>[0, 0.19, 0.41, 1.0],
              colors: <Color>[
                Color(0xFF5264DE),
                Color(0xFF212C77),
                Color(0xFF050031),
                Color(0xFF050031),
              ],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            title: AppLocalizations.of(context)!.account,
            actionButton: CustomIconButton(
              icon: Icons.logout,
              onTap: () async {
                final bool? isLoggingOut = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.confirmLogout),
                      content: Text(
                        AppLocalizations.of(context)!.areYouSureYouWantToQuit,
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(AppLocalizations.of(context)!.no),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(AppLocalizations.of(context)!.yes),
                        ),
                      ],
                    );
                  },
                );
                if (isLoggingOut == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    context.go(LoginScreen.path);
                  }
                }
              },
            ),
          ),
          body: userProvider.when(
            data: (UserProfile data) {
              setState(() {
                _cachedImageProvider = data.imageUrl != null
                    ? MemoryImage(ImageHelper.base64ToBytes(data.imageUrl!))
                    : const AssetImage("assetsimagesdefaultUserImage.jpg");
              });
              if (_originalName == null) {
                _originalName = data.firstLastName ?? "";
                _originalGenre = data.preferredGenre ?? "";
                _originalMovie = data.preferredFilm ?? "";

                _nameController.text = _originalName!;
                _genreController.text = _originalGenre!;
                _movieController.text = _originalMovie!;
              }

              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: <double>[0, 0.19, 0.41, 1.0],
                    colors: <Color>[
                      Color(0xFF5264DE),
                      Color(0xFF212C77),
                      Color(0xFF050031),
                      Color(0xFF050031),
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  image: _cachedImageProvider != null
                                      ? DecorationImage(
                                          image: _cachedImageProvider!,
                                          fit: BoxFit.cover,
                                        )
                                      : null,

                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 4),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _pickImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(16),
                                ),
                                child: const Icon(Icons.camera_alt),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.userData,
                          style: const TextStyle(
                            color: CustomColors.mainYellow,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.firstAndLastName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onTapOutside: (PointerDownEvent event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          controller: _nameController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.favouriteGenre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),

                        TextField(
                          onTapOutside: (PointerDownEvent event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          controller: _genreController,
                          style: const TextStyle(color: Colors.black),
                          readOnly: true,

                          onTap: () async {
                            _genreController.text =
                                (await CustomDropdownMenu.showModal(
                                  values: _genres,
                                  onSelectedItem: () {},
                                  context: context,
                                ))!;
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.favouriteGenre,
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.favouriteMovie,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onTapOutside: (PointerDownEvent event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          controller: _movieController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.favouriteMovie,
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              final bool? isLoggingOut = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.confirmLogout,
                                    ),
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.areYouSureYouWantToQuit,
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text(
                                          AppLocalizations.of(context)!.no,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text(
                                          AppLocalizations.of(context)!.yes,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (isLoggingOut == true) {
                                await FirebaseAuth.instance.signOut();
                                if (context.mounted) {
                                  context.go(LoginScreen.path);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                            child: const Icon(Icons.logout, size: 28),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  border: _hasUnsavedChanges
                                      ? Border.all(color: Colors.red, width: 2)
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (userProvider.value != null) {
                                      _updateUserProfile(
                                        userId: userProvider.value!.userId,
                                        name: _nameController.text,
                                        imageUrl: _selectedImage != null
                                            ? await ImageHelper.fileToBase64(
                                                _selectedImage!,
                                              )
                                            : userProvider.value!.imageUrl,
                                        preferredGenre:
                                            _genreController.text.isNotEmpty
                                            ? _genreController.text
                                            : null,
                                        preferredFilm:
                                            _movieController.text.isNotEmpty
                                            ? _movieController.text
                                            : null,
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.profileUpdated,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomColors.mainYellow,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: const Size(double.infinity, 0),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.confirmLabel,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (_hasUnsavedChanges)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.unsavedChanges,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
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
            },
            error: (_, __) => const Center(child: Text("error")),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
