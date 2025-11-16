import 'dart:io';
import 'dart:typed_data';

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
  final UserService _UserProfileService = UserService();
  File? _selectedImage;

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
      setState(() {
        _selectedImage = File(image.path);
        _hasUnsavedChanges = true;
      });
    }
  }

  _checkExistingImage({String? image}) {
    if (image != null) {
      final Uint8List dbImage = ImageHelper.base64ToBytes(image);
      return Image.memory(dbImage).image;
    } else if (_selectedImage != null) {
      return Image.file(_selectedImage!).image;
    } else {
      return Image.asset("assets/images/defaultUserImage.jpg").image;
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForChanges);
    _genreController.removeListener(_checkForChanges);
    _movieController.removeListener(_checkForChanges);
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
    await _UserProfileService.updateUser(
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

    ref.invalidate(userProfilesProvider);
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
                                  image: DecorationImage(
                                    image: _checkExistingImage(
                                      image: data.imageUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
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
                          'Dati',
                          style: TextStyle(
                            color: CustomColors.mainYellow,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nome Utente:',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
                        const Text(
                          'Genere preferito:',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
                            hintText: "genere preferito",
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          'Film preferito',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onTapOutside: (PointerDownEvent event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          controller: _movieController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Film preferito',
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

                        if (_hasUnsavedChanges)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              border: Border.all(
                                color: Colors.orange,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: <Widget>[
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Modifiche non salvate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: <Widget>[
                              Expanded(
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
                                          const SnackBar(
                                            content: Text(
                                              'Profilo aggiornato!',
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
                                  ),
                                  child: const Text(
                                    'Conferma',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
