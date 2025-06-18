import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      print('🔍 AuthService: Starting registration for $email');

      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        print('✅ AuthService: Firebase Auth user created');

        // Update display name
        await user.updateDisplayName(name);

        // Create user data with filled and temporary fields
        Map<String, dynamic> userData = {
          // ===== FILLED FIELDS (Data yang sudah diisi user) =====
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'profilePicture': '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'isVerified': false,
          'signInMethod': 'email',
          'isProfileComplete':
              false, // Akan jadi true setelah user melengkapi data

          // ===== MODE SIAGA SETTINGS =====
          'siagaMode': false, // Default Mode Siaga nonaktif
          'siagaSettings': {
            'enabled': false,
            'activatedAt': null,
            'lastNotificationAt': null,
            'radiusKm': 10.0, // Default radius 10 km
            'bloodTypesEnabled': [], // Will be set based on user's blood type
            'emergencyOnly': true, // Default hanya emergency
            'soundNotification': true,
            'vibrationNotification': true,
            'notificationCount': 0,
            'responsesCount': 0,
          },

          // ===== TEMPORARY FIELDS (Data yang belum diisi, akan diisi nanti) =====
          // Personal Details
          'dateOfBirth': '', // Format: YYYY-MM-DD
          'gender': '', // male, female, other
          'weight': 0, // in kg (minimal 45kg untuk donor)
          'height': 0, // in cm
          'occupation': '', // pekerjaan
          'bloodType': '', // A+, A-, B+, B-, AB+, AB-, O+, O-

          // Address (akan diisi saat onboarding/profile completion)
          'address': {
            'street': '',
            'city': '',
            'district': '', // kecamatan
            'province': '',
            'postalCode': '',
            'coordinates': {
              'latitude': 0.0,
              'longitude': 0.0,
            }
          },

          // Donor Information (default values)
          'isDonor': false,
          'donorStatus': 'inactive', // inactive, active, suspended, ineligible
          'lastDonationDate': null,
          'totalDonations': 0,
          'eligibleToDonate': false, // akan dicek setelah data medis lengkap
          'nextEligibleDate': null,

          // Medical Information (akan diisi saat screening)
          'medicalInfo': {
            'allergies': [], // List of allergies
            'medications': [], // Current medications
            'medicalConditions': [], // Diabetes, Hipertensi, dll
            'lastCheckup': null, // Tanggal medical checkup terakhir
            'emergencyContact': {
              'name': '',
              'phone': '',
              'relationship': '',
            }
          },

          // App Settings (default)
          'settings': {
            'notifications': {
              'bloodRequest': true,
              'donationReminder': true,
              'healthTips': true,
              'emergency': true,
            },
            'privacy': {
              'showLocation': true,
              'showPhone': false,
              'showEmail': false,
              'showFullName': true,
            },
            'theme': 'light', // light, dark, system
            'language': 'id', // id, en
          },

          // Statistics (akan bertambah seiring waktu)
          'stats': {
            'requestsMade': 0,
            'requestsFulfilled': 0,
            'donationsCompleted': 0,
            'livesImpacted': 0,
            'pointsEarned': 0,
          },

          // Achievements (akan didapat seiring aktivitas)
          'badges': [],
          'achievements': [],

          // History (akan terisi seiring aktivitas)
          'bloodRequestsHistory': [],
          'donationHistory': [],
          'loginHistory': [],
        };

        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set(userData);
        print('✅ AuthService: User data saved to Firestore');

        return AuthResult(success: true, user: user);
      } else {
        return AuthResult(success: false, message: 'Failed to create user');
      }
    } on FirebaseAuthException catch (e) {
      print('🔥 AuthService: FirebaseAuthException: ${e.code}');
      String message = _getAuthErrorMessage(e.code);
      return AuthResult(success: false, message: message);
    } catch (e) {
      print('💥 AuthService: General exception: $e');
      return AuthResult(
          success: false, message: 'An unexpected error occurred');
    }
  }

  // Sign in with Google - akan meminta phone number jika belum ada
  Future<AuthResult> signInWithGoogle() async {
    try {
      print('🔍 AuthService: Starting Google Sign-In');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult(
            success: false, message: 'Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          print('📝 AuthService: Creating new Google user document');

          // Create user data for Google sign-in (phone number will be requested later)
          Map<String, dynamic> userData = {
            // ===== FILLED FIELDS (dari Google) =====
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'phone': '', // KOSONG - akan diminta saat first login
            'profilePicture': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'isActive': true,
            'isVerified': user.emailVerified,
            'signInMethod': 'google',
            'isProfileComplete': false,
            'needsPhoneNumber': true, // Flag untuk meminta phone number

            // ===== MODE SIAGA SETTINGS =====
            'siagaMode': false, // Default Mode Siaga nonaktif
            'siagaSettings': {
              'enabled': false,
              'activatedAt': null,
              'lastNotificationAt': null,
              'radiusKm': 10.0,
              'bloodTypesEnabled': [],
              'emergencyOnly': true,
              'soundNotification': true,
              'vibrationNotification': true,
              'notificationCount': 0,
              'responsesCount': 0,
            },

            // ===== TEMPORARY FIELDS (sama seperti email registration) =====
            'dateOfBirth': '',
            'gender': '',
            'weight': 0,
            'height': 0,
            'occupation': '',
            'bloodType': '',

            'address': {
              'street': '',
              'city': '',
              'district': '',
              'province': '',
              'postalCode': '',
              'coordinates': {
                'latitude': 0.0,
                'longitude': 0.0,
              }
            },

            'isDonor': false,
            'donorStatus': 'inactive',
            'lastDonationDate': null,
            'totalDonations': 0,
            'eligibleToDonate': false,
            'nextEligibleDate': null,

            'medicalInfo': {
              'allergies': [],
              'medications': [],
              'medicalConditions': [],
              'lastCheckup': null,
              'emergencyContact': {
                'name': '',
                'phone': '',
                'relationship': '',
              }
            },

            'settings': {
              'notifications': {
                'bloodRequest': true,
                'donationReminder': true,
                'healthTips': true,
                'emergency': true,
              },
              'privacy': {
                'showLocation': true,
                'showPhone': false,
                'showEmail': false,
                'showFullName': true,
              },
              'theme': 'light',
              'language': 'id',
            },

            'stats': {
              'requestsMade': 0,
              'requestsFulfilled': 0,
              'donationsCompleted': 0,
              'livesImpacted': 0,
              'pointsEarned': 0,
            },

            'badges': [],
            'achievements': [],
            'bloodRequestsHistory': [],
            'donationHistory': [],
            'loginHistory': [],
          };

          await _firestore.collection('users').doc(user.uid).set(userData);
        } else {
          print('🔄 AuthService: Updating existing Google user login');
          // Update last login time
          await _firestore.collection('users').doc(user.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        return AuthResult(
            success: true, user: user, needsPhoneNumber: !userDoc.exists);
      } else {
        return AuthResult(
            success: false, message: 'Failed to sign in with Google');
      }
    } catch (e) {
      print('💥 AuthService: Google Sign-In exception: $e');
      return AuthResult(
          success: false, message: 'Google sign in failed: ${e.toString()}');
    }
  }

  // ===== MODE SIAGA METHODS =====

  // Toggle Mode Siaga on/off
  Future<AuthResult> updateUserSiagaMode(String uid, bool siagaMode) async {
    try {
      print('🔧 AuthService: Updating siaga mode for $uid to $siagaMode');

      Map<String, dynamic> updateData = {
        'siagaMode': siagaMode,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // If activating siaga mode
      if (siagaMode) {
        updateData['siagaSettings.enabled'] = true;
        updateData['siagaSettings.activatedAt'] = FieldValue.serverTimestamp();
        
        // Get user's blood type to set default enabled blood types
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String userBloodType = userData['bloodType'] ?? '';
          
          if (userBloodType.isNotEmpty) {
            // Set compatible blood types based on user's blood type
            List<String> compatibleTypes = _getCompatibleBloodTypes(userBloodType);
            updateData['siagaSettings.bloodTypesEnabled'] = compatibleTypes;
          }
        }
      } else {
        // If deactivating siaga mode
        updateData['siagaSettings.enabled'] = false;
        updateData['siagaSettings.activatedAt'] = null;
      }

      await _firestore.collection('users').doc(uid).update(updateData);
      
      print('✅ AuthService: Siaga mode updated successfully');
      return AuthResult(
        success: true, 
        message: siagaMode ? 'Mode Siaga diaktifkan' : 'Mode Siaga dinonaktifkan'
      );
    } catch (e) {
      print('💥 AuthService: Error updating siaga mode: $e');
      return AuthResult(
        success: false, 
        message: 'Gagal mengubah mode siaga: ${e.toString()}'
      );
    }
  }

  // Update siaga settings (radius, blood types, etc.)
  Future<AuthResult> updateSiagaSettings({
    required String uid,
    double? radiusKm,
    List<String>? bloodTypesEnabled,
    bool? emergencyOnly,
    bool? soundNotification,
    bool? vibrationNotification,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (radiusKm != null) {
        updateData['siagaSettings.radiusKm'] = radiusKm;
      }
      if (bloodTypesEnabled != null) {
        updateData['siagaSettings.bloodTypesEnabled'] = bloodTypesEnabled;
      }
      if (emergencyOnly != null) {
        updateData['siagaSettings.emergencyOnly'] = emergencyOnly;
      }
      if (soundNotification != null) {
        updateData['siagaSettings.soundNotification'] = soundNotification;
      }
      if (vibrationNotification != null) {
        updateData['siagaSettings.vibrationNotification'] = vibrationNotification;
      }

      await _firestore.collection('users').doc(uid).update(updateData);
      
      return AuthResult(success: true, message: 'Pengaturan siaga berhasil diperbarui');
    } catch (e) {
      print('Error updating siaga settings: $e');
      return AuthResult(
        success: false, 
        message: 'Gagal memperbarui pengaturan siaga: ${e.toString()}'
      );
    }
  }

  // Get users with active siaga mode for emergency notifications
  Future<List<Map<String, dynamic>>> getActiveSiagaUsers({
    String? bloodType,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      Query query = _firestore.collection('users')
          .where('siagaMode', isEqualTo: true)
          .where('siagaSettings.enabled', isEqualTo: true);

      if (bloodType != null) {
        query = query.where('siagaSettings.bloodTypesEnabled', arrayContains: bloodType);
      }

      QuerySnapshot snapshot = await query.get();
      
      List<Map<String, dynamic>> siagaUsers = [];
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        
        // If location filtering is needed
        if (latitude != null && longitude != null && radiusKm != null) {
          Map<String, dynamic> userAddress = userData['address'] ?? {};
          Map<String, dynamic> userCoords = userAddress['coordinates'] ?? {};
          
          double userLat = userCoords['latitude']?.toDouble() ?? 0.0;
          double userLng = userCoords['longitude']?.toDouble() ?? 0.0;
          
          if (userLat != 0.0 && userLng != 0.0) {
            double distance = _calculateDistance(latitude, longitude, userLat, userLng);
            if (distance <= radiusKm) {
              userData['distance'] = distance;
              siagaUsers.add(userData);
            }
          }
        } else {
          siagaUsers.add(userData);
        }
      }
      
      // Sort by distance if location was provided
      if (latitude != null && longitude != null) {
        siagaUsers.sort((a, b) => (a['distance'] ?? 0.0).compareTo(b['distance'] ?? 0.0));
      }
      
      return siagaUsers;
    } catch (e) {
      print('Error getting active siaga users: $e');
      return [];
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double radiusEarth = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
        math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) *
        math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return radiusEarth * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Get compatible blood types based on user's blood type
  List<String> _getCompatibleBloodTypes(String userBloodType) {
    Map<String, List<String>> compatibility = {
      'A+': ['A+', 'A-', 'O+', 'O-'],
      'A-': ['A-', 'O-'],
      'B+': ['B+', 'B-', 'O+', 'O-'],
      'B-': ['B-', 'O-'],
      'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], // Universal recipient
      'AB-': ['A-', 'B-', 'AB-', 'O-'],
      'O+': ['O+', 'O-'],
      'O-': ['O-'], // Universal donor, but can only receive O-
    };
    
    return compatibility[userBloodType] ?? [userBloodType];
  }

  // Record siaga notification sent
  Future<void> recordSiagaNotification(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'siagaSettings.lastNotificationAt': FieldValue.serverTimestamp(),
        'siagaSettings.notificationCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording siaga notification: $e');
    }
  }

  // Record siaga response
  Future<void> recordSiagaResponse(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'siagaSettings.responsesCount': FieldValue.increment(1),
        'stats.requestsFulfilled': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording siaga response: $e');
    }
  }

  // ===== END MODE SIAGA METHODS =====

  // Update phone number untuk Google users
  Future<AuthResult> updatePhoneNumber({
    required String userId,
    required String phoneNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'phone': phoneNumber,
        'needsPhoneNumber': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return AuthResult(
          success: true, message: 'Phone number updated successfully');
    } catch (e) {
      print('Error updating phone number: $e');
      return AuthResult(
          success: false, message: 'Failed to update phone number');
    }
  }

  // Check if user needs to complete profile
  Future<Map<String, dynamic>> checkProfileCompleteness(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {
          'complete': false,
          'missingFields': ['all']
        };
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> missingFields = [];

      // Check required fields
      if (userData['phone'] == null || userData['phone'] == '') {
        missingFields.add('phone');
      }
      if (userData['dateOfBirth'] == null || userData['dateOfBirth'] == '') {
        missingFields.add('dateOfBirth');
      }
      if (userData['gender'] == null || userData['gender'] == '') {
        missingFields.add('gender');
      }
      if (userData['bloodType'] == null || userData['bloodType'] == '') {
        missingFields.add('bloodType');
      }
      if (userData['weight'] == null || userData['weight'] == 0) {
        missingFields.add('weight');
      }
      if (userData['height'] == null || userData['height'] == 0) {
        missingFields.add('height');
      }

      // Check address
      Map<String, dynamic> address = userData['address'] ?? {};
      if (address['city'] == null || address['city'] == '') {
        missingFields.add('address');
      }

      bool isComplete = missingFields.isEmpty;

      // Update profile complete status if needed
      if (isComplete && userData['isProfileComplete'] != true) {
        await _firestore.collection('users').doc(userId).update({
          'isProfileComplete': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return {
        'complete': isComplete,
        'missingFields': missingFields,
        'completionPercentage': _calculateCompletionPercentage(userData),
      };
    } catch (e) {
      print('Error checking profile completeness: $e');
      return {
        'complete': false,
        'missingFields': ['error']
      };
    }
  }

  // Calculate profile completion percentage
  double _calculateCompletionPercentage(Map<String, dynamic> userData) {
    List<String> requiredFields = [
      'name',
      'email',
      'phone',
      'dateOfBirth',
      'gender',
      'bloodType',
      'weight',
      'height',
      'address.city'
    ];

    int completedFields = 0;

    for (String field in requiredFields) {
      if (field.contains('.')) {
        // Handle nested fields like address.city
        List<String> parts = field.split('.');
        var value = userData[parts[0]];
        if (value != null &&
            value[parts[1]] != null &&
            value[parts[1]] != '' &&
            value[parts[1]] != 0) {
          completedFields++;
        }
      } else {
        if (userData[field] != null &&
            userData[field] != '' &&
            userData[field] != 0) {
          completedFields++;
        }
      }
    }

    return (completedFields / requiredFields.length) * 100;
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔍 AuthService: Attempting login for $email');

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        print('✅ AuthService: Firebase Auth successful');

        // Update last login time and add to login history
        try {
          await _firestore.collection('users').doc(user.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'loginHistory': FieldValue.arrayUnion([
              {
                'timestamp': FieldValue.serverTimestamp(),
                'method': 'email',
                'deviceInfo': 'mobile', // You can get actual device info
              }
            ])
          });
          print('✅ AuthService: Login history updated');
        } catch (firestoreError) {
          print('⚠️ AuthService: Firestore update failed: $firestoreError');
        }

        return AuthResult(success: true, user: user);
      } else {
        return AuthResult(success: false, message: 'User object is null');
      }
    } on FirebaseAuthException catch (e) {
      print('🔥 AuthService: FirebaseAuthException: ${e.code}');
      String message = _getAuthErrorMessage(e.code);
      return AuthResult(success: false, message: message);
    } catch (e) {
      print('💥 AuthService: General exception: $e');
      return AuthResult(
          success: false, message: 'An unexpected error occurred');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(success: true, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
          success: false, message: 'An unexpected error occurred');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data
  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  // Get auth error message
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-not-found':
        return 'User tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'invalid-credential':
        return 'Kredensial tidak valid';
      default:
        return 'Terjadi kesalahan, silakan coba lagi';
    }
  }
}

// Enhanced Auth result class
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final bool needsPhoneNumber; // Flag untuk Google users yang belum ada phone

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.needsPhoneNumber = false,
  });
}