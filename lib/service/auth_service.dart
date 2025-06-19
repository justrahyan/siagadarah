import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          'role': 'user', // DEFAULT ROLE: user
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
  Future<AuthResult> signInWithGoogle({bool isRegister = false}) async {
    try {
      print('🔍 AuthService: Starting Google Sign-In');
      // Delete login cache
      await GoogleSignIn().signOut();
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      print("🔥 googleUser: ${googleUser?.email}");

      if (googleUser == null) {
        return AuthResult(
            success: false, message: 'Login dengan Google dibatalkan');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 🔍 Cek apakah email Google sudah terdaftar
      final methods = await _auth.fetchSignInMethodsForEmail(googleUser.email);
      print('📡 Sign-in methods for ${googleUser.email}: $methods');

      if (!isRegister && methods.contains('password')) {
        // 💡 Sudah terdaftar pakai email/password
        return AuthResult(
          success: false,
          message: 'email_exists_with_password',
          user: null,
        );
      }

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
            'needsPhoneNumber': false,
            'role': 'user', // DEFAULT ROLE: user
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
          if (!user.emailVerified) {
            await user.sendEmailVerification();
          }
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
        return AuthResult(success: false, message: 'Gagal login dengan Google');
      }
    } catch (e) {
      print('💥 AuthService: Google Sign-In exception: $e');
      return AuthResult(
          success: false, message: 'Google sign in failed: ${e.toString()}');
    }
  }

  // New: Get user role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        return (userDoc.data() as Map<String, dynamic>)['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
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

  // Email Verification
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
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
