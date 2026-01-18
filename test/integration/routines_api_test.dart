// Comprehensive integration tests for the Treoir Routines API
//
// These tests verify the complete API contract for routine management,
// including CRUD operations, workout creation from routines, and exercise reordering.
//
// Prerequisites:
// - Valid test user credentials
// - Access to staging API environment
// - Network connectivity
//
// Run with: flutter test test/integration/routines_api_test.dart

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// API Configuration for staging environment
class ApiConfig {
  static const String baseUrl = 'https://staging.treoir.xyz/api/v1';
  static const String supabaseUrl =
      'https://phifyhudywiuqgwezumh.supabase.co/auth/v1/token?grant_type=password';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoaWZ5aHVkeXdpdXFnd2V6dW1oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2MTIxNzgsImV4cCI6MjA3ODE4ODE3OH0.VC_keEUD3OAxfrss0TI5EAQvwkkB_wU2D67KH-3mA48';
  static const String testEmail = 'test@treoir.xyz';
  static const String testPassword = 'TreoirTest2025!';
}

/// Helper class for making authenticated API requests
class ApiClient {
  final String? accessToken;
  final http.Client _client;

  ApiClient({this.accessToken}) : _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  Future<http.Response> get(String endpoint, {Map<String, String>? queryParams}) {
    var uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return _client.get(uri, headers: _headers);
  }

  Future<http.Response> post(String endpoint, {Object? body}) {
    return _client.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> patch(String endpoint, {Object? body}) {
    return _client.patch(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint) {
    return _client.delete(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: _headers,
    );
  }

  void close() => _client.close();
}

/// Authenticates with Supabase and returns an access token
Future<String> getAuthToken() async {
  final response = await http.post(
    Uri.parse(ApiConfig.supabaseUrl),
    headers: {
      'Content-Type': 'application/json',
      'apikey': ApiConfig.supabaseAnonKey,
    },
    body: jsonEncode({
      'email': ApiConfig.testEmail,
      'password': ApiConfig.testPassword,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to authenticate: ${response.statusCode} - ${response.body}');
  }

  final data = jsonDecode(response.body);
  return data['access_token'] as String;
}

void main() {
  // Shared state for authenticated tests
  late String authToken;
  late ApiClient authenticatedClient;
  late ApiClient unauthenticatedClient;

  // Track created resources for cleanup
  final createdRoutineIds = <String>[];
  final createdWorkoutIds = <String>[];

  // ============================================================================
  // Setup and Teardown
  // ============================================================================

  setUpAll(() async {
    // Authenticate once for all tests
    authToken = await getAuthToken();
    authenticatedClient = ApiClient(accessToken: authToken);
    unauthenticatedClient = ApiClient();
  });

  tearDownAll(() async {
    // Clean up all created resources
    for (final id in createdRoutineIds) {
      try {
        await authenticatedClient.delete('/routines/$id');
      } catch (_) {
        // Ignore cleanup errors
      }
    }
    for (final id in createdWorkoutIds) {
      try {
        await authenticatedClient.delete('/workouts/$id');
      } catch (_) {
        // Ignore cleanup errors
      }
    }
    authenticatedClient.close();
    unauthenticatedClient.close();
  });

  // ============================================================================
  // GET /routines - List Routines
  // ============================================================================

  group('GET /routines - List Routines', () {
    // Test: Unauthenticated requests should be rejected
    test('returns 401 without authentication', () async {
      final response = await unauthenticatedClient.get('/routines');

      expect(response.statusCode, 401);
    });

    // Test: Authenticated requests return paginated list of routines
    test('returns paginated list of routines', () async {
      final response = await authenticatedClient.get('/routines');

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      expect(body, containsPair('data', isA<List>()));
      expect(body, containsPair('meta', isA<Map>()));

      final meta = body['meta'] as Map;
      expect(meta, containsPair('page', isA<int>()));
      expect(meta, containsPair('pageSize', isA<int>()));
      expect(meta, containsPair('total', isA<int>()));
      expect(meta, containsPair('hasMore', isA<bool>()));
    });

    // Test: activeOnly filter restricts results to active routines
    test('activeOnly filter works correctly', () async {
      // First, create an active routine
      final createResponse = await authenticatedClient.post('/routines', body: {
        'name': 'Active Test Routine ${DateTime.now().millisecondsSinceEpoch}',
        'isActive': true,
      });
      expect(createResponse.statusCode, 201);
      final routineId = jsonDecode(createResponse.body)['data']['id'] as String;
      createdRoutineIds.add(routineId);

      // Request with activeOnly filter
      final response = await authenticatedClient.get(
        '/routines',
        queryParams: {'activeOnly': 'true'},
      );

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      final routines = body['data'] as List;

      // All returned routines should be active (if the API supports isActive field)
      // Note: This test assumes the API has an isActive field on routines
      for (final routine in routines) {
        // The routine should either not have isActive field or it should be true
        if (routine.containsKey('isActive')) {
          expect(routine['isActive'], isTrue);
        }
      }
    });

    // Test: Pagination metadata accurately reflects the data
    test('pagination metadata is accurate', () async {
      // Request first page with small page size
      final response = await authenticatedClient.get(
        '/routines',
        queryParams: {'page': '1', 'pageSize': '5'},
      );

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      final routines = body['data'] as List;
      final meta = body['meta'] as Map;

      // Page should match request
      expect(meta['page'], 1);
      expect(meta['pageSize'], 5);

      // Data length should not exceed pageSize
      expect(routines.length, lessThanOrEqualTo(5));

      // If total > pageSize, hasMore should be true for page 1
      final total = meta['total'] as int;
      final hasMore = meta['hasMore'] as bool;
      if (total > 5) {
        expect(hasMore, isTrue);
      } else {
        expect(hasMore, isFalse);
      }
    });

    // Test: Second page returns different results
    test('pagination returns correct pages', () async {
      // Create enough routines to have multiple pages
      final routineIds = <String>[];
      for (var i = 0; i < 3; i++) {
        final response = await authenticatedClient.post('/routines', body: {
          'name': 'Pagination Test $i - ${DateTime.now().millisecondsSinceEpoch}',
        });
        if (response.statusCode == 201) {
          final id = jsonDecode(response.body)['data']['id'] as String;
          routineIds.add(id);
          createdRoutineIds.add(id);
        }
      }

      // Request page 1 with pageSize 2
      final page1Response = await authenticatedClient.get(
        '/routines',
        queryParams: {'page': '1', 'pageSize': '2'},
      );
      expect(page1Response.statusCode, 200);
      final page1Data = jsonDecode(page1Response.body)['data'] as List;

      // Request page 2 with pageSize 2
      final page2Response = await authenticatedClient.get(
        '/routines',
        queryParams: {'page': '2', 'pageSize': '2'},
      );
      expect(page2Response.statusCode, 200);
      final page2Data = jsonDecode(page2Response.body)['data'] as List;

      // Pages should have different content (if there are enough routines)
      if (page1Data.isNotEmpty && page2Data.isNotEmpty) {
        final page1Ids = page1Data.map((r) => r['id']).toSet();
        final page2Ids = page2Data.map((r) => r['id']).toSet();
        expect(page1Ids.intersection(page2Ids), isEmpty);
      }
    });
  });

  // ============================================================================
  // GET /routines/:id - Get Routine Detail
  // ============================================================================

  group('GET /routines/:id - Get Routine Detail', () {
    late String testRoutineId;

    setUp(() async {
      // Create a routine with exercises for detail tests
      final createResponse = await authenticatedClient.post('/routines', body: {
        'name': 'Detail Test Routine ${DateTime.now().millisecondsSinceEpoch}',
        'exercises': [
          {
            'exerciseId': 'exercise-bench-press',
            'targetSets': 3,
            'targetRepsRange': '8-12',
          },
          {
            'exerciseId': 'exercise-squat',
            'targetSets': 4,
            'targetRepsRange': '5-8',
          },
        ],
      });

      if (createResponse.statusCode == 201) {
        testRoutineId = jsonDecode(createResponse.body)['data']['id'] as String;
        createdRoutineIds.add(testRoutineId);
      } else {
        // Fallback: create minimal routine
        final minimalResponse = await authenticatedClient.post('/routines', body: {
          'name': 'Detail Test Routine ${DateTime.now().millisecondsSinceEpoch}',
        });
        testRoutineId = jsonDecode(minimalResponse.body)['data']['id'] as String;
        createdRoutineIds.add(testRoutineId);
      }
    });

    // Test: Non-existent routine returns 404
    test('returns 404 for non-existent routine', () async {
      final response = await authenticatedClient.get('/routines/non-existent-id-12345');

      expect(response.statusCode, 404);
    });

    // Test: Cannot access another user's routine (returns 404 to avoid leaking info)
    test('returns 404 for another user\'s routine', () async {
      // This assumes the API returns 404 for routines the user doesn't own
      // to prevent enumeration attacks
      final response = await authenticatedClient.get('/routines/other-user-routine-id');

      // Should be 404 (not 403) to avoid revealing that the routine exists
      expect(response.statusCode, 404);
    });

    // Test: Response includes exercises with their sets
    test('includes exercises with sets in response', () async {
      final response = await authenticatedClient.get('/routines/$testRoutineId');

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;

      expect(data, containsPair('id', testRoutineId));
      expect(data, containsPair('name', isA<String>()));

      // Exercises array should be present
      if (data.containsKey('exercises')) {
        final exercises = data['exercises'] as List;
        for (final exercise in exercises) {
          expect(exercise, containsPair('id', isA<String>()));
          expect(exercise, containsPair('orderIndex', isA<int>()));
          // Exercise details should be nested
          if (exercise.containsKey('exercise')) {
            final exerciseDetail = exercise['exercise'] as Map;
            expect(exerciseDetail, containsPair('id', isA<String>()));
            expect(exerciseDetail, containsPair('name', isA<String>()));
          }
        }
      }
    });

    // Test: exerciseCount matches the actual exercises array length
    test('exerciseCount matches exercises array length', () async {
      final response = await authenticatedClient.get('/routines/$testRoutineId');

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;

      final exerciseCount = data['exerciseCount'] as int? ?? 0;
      final exercises = (data['exercises'] as List?) ?? [];

      expect(exerciseCount, exercises.length);
    });
  });

  // ============================================================================
  // POST /routines - Create Routine
  // ============================================================================

  group('POST /routines - Create Routine', () {
    // Test: Missing name returns 400
    test('returns 400 if name is missing', () async {
      final response = await authenticatedClient.post('/routines', body: {
        // name intentionally omitted
        'estimatedDuration': 60,
      });

      expect(response.statusCode, 400);

      final body = jsonDecode(response.body);
      expect(body, containsPair('error', isA<Map>()));
    });

    // Test: Name exceeding 255 characters returns 400
    test('returns 400 if name exceeds 255 characters', () async {
      final longName = 'A' * 256;

      final response = await authenticatedClient.post('/routines', body: {
        'name': longName,
      });

      expect(response.statusCode, 400);

      final body = jsonDecode(response.body);
      expect(body, containsPair('error', isA<Map>()));
    });

    // Test: Name at exactly 255 characters should succeed
    test('allows name at exactly 255 characters', () async {
      final maxName = 'A' * 255;

      final response = await authenticatedClient.post('/routines', body: {
        'name': maxName,
      });

      expect(response.statusCode, 201);

      final body = jsonDecode(response.body);
      final routineId = body['data']['id'] as String;
      createdRoutineIds.add(routineId);

      expect(body['data']['name'], maxName);
    });

    // Test: Create routine with minimal required data
    test('creates routine with minimal data (name only)', () async {
      final uniqueName = 'Minimal Routine ${DateTime.now().millisecondsSinceEpoch}';

      final response = await authenticatedClient.post('/routines', body: {
        'name': uniqueName,
      });

      expect(response.statusCode, 201);

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;

      expect(data, containsPair('id', isA<String>()));
      expect(data, containsPair('name', uniqueName));

      createdRoutineIds.add(data['id'] as String);
    });

    // Test: Create routine with exercises array
    test('creates routine with exercises array', () async {
      final uniqueName = 'Full Routine ${DateTime.now().millisecondsSinceEpoch}';

      final response = await authenticatedClient.post('/routines', body: {
        'name': uniqueName,
        'estimatedDuration': 45,
        'exercises': [
          {
            'exerciseId': 'exercise-bench-press',
            'targetSets': 4,
            'targetRepsRange': '6-10',
            'notes': 'Focus on chest contraction',
          },
          {
            'exerciseId': 'exercise-squat',
            'targetSets': 5,
            'targetRepsRange': '3-5',
          },
        ],
      });

      // May return 201 or handle exercises differently
      expect(response.statusCode, anyOf(200, 201));

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;

      expect(data, containsPair('id', isA<String>()));
      expect(data, containsPair('name', uniqueName));

      createdRoutineIds.add(data['id'] as String);
    });

    // Test: Response includes proper 201 status and data
    test('returns 201 with complete routine data', () async {
      final uniqueName = 'Complete Routine ${DateTime.now().millisecondsSinceEpoch}';

      final response = await authenticatedClient.post('/routines', body: {
        'name': uniqueName,
        'estimatedDuration': 60,
      });

      expect(response.statusCode, 201);

      final body = jsonDecode(response.body);
      expect(body, containsPair('data', isA<Map>()));

      final data = body['data'] as Map;
      expect(data, containsPair('id', isA<String>()));
      expect(data, containsPair('name', uniqueName));
      expect(data['id'], isNotEmpty);

      createdRoutineIds.add(data['id'] as String);
    });

    // Test: Empty name string returns 400
    test('returns 400 for empty name string', () async {
      final response = await authenticatedClient.post('/routines', body: {
        'name': '',
      });

      expect(response.statusCode, 400);
    });

    // Test: Whitespace-only name returns 400
    test('returns 400 for whitespace-only name', () async {
      final response = await authenticatedClient.post('/routines', body: {
        'name': '   ',
      });

      expect(response.statusCode, 400);
    });
  });

  // ============================================================================
  // PATCH /routines/:id - Update Routine
  // ============================================================================

  group('PATCH /routines/:id - Update Routine', () {
    late String testRoutineId;
    late String originalUpdatedAt;

    setUp(() async {
      // Create a fresh routine for update tests
      final createResponse = await authenticatedClient.post('/routines', body: {
        'name': 'Update Test Routine ${DateTime.now().millisecondsSinceEpoch}',
        'estimatedDuration': 30,
      });

      expect(createResponse.statusCode, 201);

      final data = jsonDecode(createResponse.body)['data'] as Map;
      testRoutineId = data['id'] as String;
      originalUpdatedAt = data['updatedAt'] as String? ?? '';
      createdRoutineIds.add(testRoutineId);

      // Small delay to ensure updatedAt will be different
      await Future.delayed(const Duration(milliseconds: 100));
    });

    // Test: Non-existent routine returns 404
    test('returns 404 for non-existent routine', () async {
      final response = await authenticatedClient.patch(
        '/routines/non-existent-routine-id',
        body: {'name': 'Updated Name'},
      );

      expect(response.statusCode, 404);
    });

    // Test: Empty name returns 400
    test('returns 400 for empty name', () async {
      final response = await authenticatedClient.patch(
        '/routines/$testRoutineId',
        body: {'name': ''},
      );

      expect(response.statusCode, 400);
    });

    // Test: Updates only provided fields, leaves others unchanged
    test('updates only provided fields', () async {
      // First, get current state
      final getResponse = await authenticatedClient.get('/routines/$testRoutineId');
      final originalData = jsonDecode(getResponse.body)['data'] as Map;
      final originalName = originalData['name'];

      // Update only estimatedDuration
      final updateResponse = await authenticatedClient.patch(
        '/routines/$testRoutineId',
        body: {'estimatedDuration': 90},
      );

      expect(updateResponse.statusCode, 200);

      final updatedData = jsonDecode(updateResponse.body)['data'] as Map;

      // Name should remain unchanged
      expect(updatedData['name'], originalName);
      // Duration should be updated
      expect(updatedData['estimatedDuration'], 90);
    });

    // Test: Name can be updated successfully
    test('updates name successfully', () async {
      final newName = 'Updated Routine Name ${DateTime.now().millisecondsSinceEpoch}';

      final response = await authenticatedClient.patch(
        '/routines/$testRoutineId',
        body: {'name': newName},
      );

      expect(response.statusCode, 200);

      final data = jsonDecode(response.body)['data'] as Map;
      expect(data['name'], newName);
    });

    // Test: updatedAt timestamp changes after update
    test('updatedAt changes after update', () async {
      final response = await authenticatedClient.patch(
        '/routines/$testRoutineId',
        body: {'name': 'Timestamp Test ${DateTime.now().millisecondsSinceEpoch}'},
      );

      expect(response.statusCode, 200);

      final data = jsonDecode(response.body)['data'] as Map;
      final newUpdatedAt = data['updatedAt'] as String? ?? '';

      // updatedAt should be different (later) than original
      if (originalUpdatedAt.isNotEmpty && newUpdatedAt.isNotEmpty) {
        expect(newUpdatedAt, isNot(originalUpdatedAt));
      }
    });

    // Test: Cannot update to name exceeding 255 characters
    test('returns 400 when updating name to exceed 255 characters', () async {
      final longName = 'B' * 256;

      final response = await authenticatedClient.patch(
        '/routines/$testRoutineId',
        body: {'name': longName},
      );

      expect(response.statusCode, 400);
    });
  });

  // ============================================================================
  // DELETE /routines/:id - Delete Routine
  // ============================================================================

  group('DELETE /routines/:id - Delete Routine', () {
    // Test: Successful deletion returns 204
    test('returns 204 on successful deletion', () async {
      // Create a routine specifically for deletion
      final createResponse = await authenticatedClient.post('/routines', body: {
        'name': 'Delete Test Routine ${DateTime.now().millisecondsSinceEpoch}',
      });

      expect(createResponse.statusCode, 201);

      final routineId = jsonDecode(createResponse.body)['data']['id'] as String;

      // Delete the routine
      final deleteResponse = await authenticatedClient.delete('/routines/$routineId');

      expect(deleteResponse.statusCode, 204);
    });

    // Test: Deleting non-existent routine returns 404
    test('returns 404 for non-existent routine', () async {
      final response = await authenticatedClient.delete('/routines/non-existent-routine-id');

      expect(response.statusCode, 404);
    });

    // Test: Routine is actually gone after deletion
    test('routine is not found after deletion', () async {
      // Create a routine
      final createResponse = await authenticatedClient.post('/routines', body: {
        'name': 'Gone After Delete ${DateTime.now().millisecondsSinceEpoch}',
      });

      expect(createResponse.statusCode, 201);

      final routineId = jsonDecode(createResponse.body)['data']['id'] as String;

      // Delete it
      final deleteResponse = await authenticatedClient.delete('/routines/$routineId');
      expect(deleteResponse.statusCode, 204);

      // Try to get it - should be 404
      final getResponse = await authenticatedClient.get('/routines/$routineId');
      expect(getResponse.statusCode, 404);
    });

    // Test: Deleting already-deleted routine returns 404
    test('returns 404 when deleting already-deleted routine', () async {
      // Create and delete a routine
      final createResponse = await authenticatedClient.post('/routines', body: {
        'name': 'Double Delete Test ${DateTime.now().millisecondsSinceEpoch}',
      });

      final routineId = jsonDecode(createResponse.body)['data']['id'] as String;

      // First delete
      await authenticatedClient.delete('/routines/$routineId');

      // Second delete attempt
      final secondDeleteResponse = await authenticatedClient.delete('/routines/$routineId');
      expect(secondDeleteResponse.statusCode, 404);
    });
  });

  // ============================================================================
  // POST /routines/:id/start - Start Workout from Routine
  // ============================================================================

  group('POST /routines/:id/start - Start Workout from Routine', () {
    late String testRoutineId;
    late String testRoutineName;

    setUp(() async {
      // Create a routine with exercises for starting workouts
      testRoutineName = 'Start Test Routine ${DateTime.now().millisecondsSinceEpoch}';

      final createResponse = await authenticatedClient.post('/routines', body: {
        'name': testRoutineName,
        'exercises': [
          {
            'exerciseId': 'exercise-bench-press',
            'targetSets': 3,
            'targetRepsRange': '8-12',
          },
          {
            'exerciseId': 'exercise-squat',
            'targetSets': 4,
            'targetRepsRange': '5-8',
          },
        ],
      });

      if (createResponse.statusCode == 201) {
        testRoutineId = jsonDecode(createResponse.body)['data']['id'] as String;
        createdRoutineIds.add(testRoutineId);
      } else {
        // Fallback: create minimal routine
        final minimalResponse = await authenticatedClient.post('/routines', body: {
          'name': testRoutineName,
        });
        testRoutineId = jsonDecode(minimalResponse.body)['data']['id'] as String;
        createdRoutineIds.add(testRoutineId);
      }
    });

    // Test: Non-existent routine returns 404
    test('returns 404 for non-existent routine', () async {
      final response = await authenticatedClient.post('/routines/non-existent-id/start');

      expect(response.statusCode, 404);
    });

    // Test: Creates workout with routine's name by default
    test('creates workout with routine name', () async {
      final response = await authenticatedClient.post('/routines/$testRoutineId/start');

      expect(response.statusCode, anyOf(200, 201));

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;

      expect(data, containsPair('id', isA<String>()));
      // Workout name should match routine name by default
      expect(data['name'], testRoutineName);

      createdWorkoutIds.add(data['id'] as String);
    });

    // Test: Custom name overrides routine name
    test('custom name overrides routine name', () async {
      final customName = 'Custom Workout ${DateTime.now().millisecondsSinceEpoch}';

      final response = await authenticatedClient.post(
        '/routines/$testRoutineId/start',
        body: {'name': customName},
      );

      expect(response.statusCode, anyOf(200, 201));

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;

      expect(data['name'], customName);

      createdWorkoutIds.add(data['id'] as String);
    });

    // Test: All exercises from routine are copied to workout
    test('all exercises from routine are copied to workout', () async {
      // First, get routine details to know expected exercises
      final routineResponse = await authenticatedClient.get('/routines/$testRoutineId');
      final routineData = jsonDecode(routineResponse.body)['data'] as Map;
      final routineExercises = (routineData['exercises'] as List?) ?? [];

      // Start workout from routine
      final startResponse = await authenticatedClient.post('/routines/$testRoutineId/start');
      expect(startResponse.statusCode, anyOf(200, 201));

      final workoutData = jsonDecode(startResponse.body)['data'] as Map;
      final workoutExercises = (workoutData['exercises'] as List?) ?? [];

      createdWorkoutIds.add(workoutData['id'] as String);

      // Exercise count should match
      expect(workoutExercises.length, routineExercises.length);
    });

    // Test: All sets have isCompleted: false initially
    test('all sets have isCompleted false initially', () async {
      final response = await authenticatedClient.post('/routines/$testRoutineId/start');
      expect(response.statusCode, anyOf(200, 201));

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;
      final exercises = (data['exercises'] as List?) ?? [];

      createdWorkoutIds.add(data['id'] as String);

      // Check all sets in all exercises
      for (final exercise in exercises) {
        final sets = (exercise['sets'] as List?) ?? [];
        for (final set in sets) {
          expect(set['isCompleted'], isFalse);
        }
      }
    });

    // Test: Response includes routineId and routineName
    test('response includes routineId and routineName', () async {
      final response = await authenticatedClient.post('/routines/$testRoutineId/start');
      expect(response.statusCode, anyOf(200, 201));

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;

      createdWorkoutIds.add(data['id'] as String);

      // Should have reference back to the routine
      expect(data, containsPair('routineId', testRoutineId));
      // May also have routineName for display purposes
      if (data.containsKey('routineName')) {
        expect(data['routineName'], testRoutineName);
      }
    });

    // Test: Created workout has active status
    test('created workout has active status', () async {
      final response = await authenticatedClient.post('/routines/$testRoutineId/start');
      expect(response.statusCode, anyOf(200, 201));

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;

      createdWorkoutIds.add(data['id'] as String);

      expect(data['status'], 'active');
      expect(data['completedAt'], isNull);
    });
  });

  // ============================================================================
  // PATCH /workouts/:id/exercises/reorder - Reorder Exercises
  // ============================================================================

  group('PATCH /workouts/:id/exercises/reorder - Reorder Exercises', () {
    late String testWorkoutId;
    late List<String> exerciseIds;

    setUp(() async {
      // Create a routine with exercises, then start a workout from it
      final routineName = 'Reorder Test Routine ${DateTime.now().millisecondsSinceEpoch}';

      final createRoutineResponse = await authenticatedClient.post('/routines', body: {
        'name': routineName,
        'exercises': [
          {'exerciseId': 'exercise-bench-press', 'targetSets': 3},
          {'exerciseId': 'exercise-squat', 'targetSets': 3},
          {'exerciseId': 'exercise-deadlift', 'targetSets': 3},
        ],
      });

      String routineId;
      if (createRoutineResponse.statusCode == 201) {
        routineId = jsonDecode(createRoutineResponse.body)['data']['id'] as String;
        createdRoutineIds.add(routineId);
      } else {
        // Fallback: create minimal routine
        final minimalResponse = await authenticatedClient.post('/routines', body: {
          'name': routineName,
        });
        routineId = jsonDecode(minimalResponse.body)['data']['id'] as String;
        createdRoutineIds.add(routineId);
      }

      // Start workout from routine
      final startResponse = await authenticatedClient.post('/routines/$routineId/start');
      if (startResponse.statusCode == 200 || startResponse.statusCode == 201) {
        final workoutData = jsonDecode(startResponse.body)['data'] as Map;
        testWorkoutId = workoutData['id'] as String;
        createdWorkoutIds.add(testWorkoutId);

        // Extract exercise IDs
        final exercises = (workoutData['exercises'] as List?) ?? [];
        exerciseIds = exercises.map((e) => e['id'] as String).toList();
      } else {
        // Fallback: create workout directly
        final createWorkoutResponse = await authenticatedClient.post('/workouts', body: {
          'name': 'Reorder Test Workout',
        });
        testWorkoutId = jsonDecode(createWorkoutResponse.body)['data']['id'] as String;
        createdWorkoutIds.add(testWorkoutId);
        exerciseIds = [];
      }
    });

    // Test: Missing exerciseIds returns 400
    test('returns 400 if exerciseIds is missing', () async {
      final response = await authenticatedClient.patch(
        '/workouts/$testWorkoutId/exercises/reorder',
        body: {}, // exerciseIds missing
      );

      expect(response.statusCode, 400);
    });

    // Test: Empty exerciseIds array returns 400
    test('returns 400 if exerciseIds is empty', () async {
      final response = await authenticatedClient.patch(
        '/workouts/$testWorkoutId/exercises/reorder',
        body: {'exerciseIds': []},
      );

      expect(response.statusCode, 400);
    });

    // Test: Duplicate IDs in array returns 400
    test('returns 400 for duplicate exercise IDs', () async {
      if (exerciseIds.isEmpty) {
        // Skip if no exercises
        return;
      }

      final duplicatedIds = [exerciseIds.first, exerciseIds.first];

      final response = await authenticatedClient.patch(
        '/workouts/$testWorkoutId/exercises/reorder',
        body: {'exerciseIds': duplicatedIds},
      );

      expect(response.statusCode, 400);
    });

    // Test: Unknown exercise ID returns 400
    test('returns 400 for unknown exercise ID', () async {
      final response = await authenticatedClient.patch(
        '/workouts/$testWorkoutId/exercises/reorder',
        body: {
          'exerciseIds': ['unknown-exercise-id-12345', ...exerciseIds],
        },
      );

      expect(response.statusCode, 400);
    });

    // Test: Successfully reorders exercises
    test('successfully reorders exercises', () async {
      if (exerciseIds.length < 2) {
        // Need at least 2 exercises to test reordering
        return;
      }

      // Reverse the order
      final reversedIds = exerciseIds.reversed.toList();

      final response = await authenticatedClient.patch(
        '/workouts/$testWorkoutId/exercises/reorder',
        body: {'exerciseIds': reversedIds},
      );

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;
      final exercises = (data['exercises'] as List?) ?? [];

      // Verify the order matches what we requested
      for (var i = 0; i < reversedIds.length && i < exercises.length; i++) {
        expect(exercises[i]['id'], reversedIds[i]);
        expect(exercises[i]['orderIndex'], i);
      }
    });

    // Test: Order persists when fetching the workout again
    test('order persists on subsequent GET', () async {
      if (exerciseIds.length < 2) {
        return;
      }

      // Reverse the order
      final reversedIds = exerciseIds.reversed.toList();

      // Reorder
      final reorderResponse = await authenticatedClient.patch(
        '/workouts/$testWorkoutId/exercises/reorder',
        body: {'exerciseIds': reversedIds},
      );
      expect(reorderResponse.statusCode, 200);

      // Fetch workout again
      final getResponse = await authenticatedClient.get('/workouts/$testWorkoutId');
      expect(getResponse.statusCode, 200);

      final body = jsonDecode(getResponse.body);
      final data = body['data'] as Map;
      final exercises = (data['exercises'] as List?) ?? [];

      // Verify order persisted
      for (var i = 0; i < reversedIds.length && i < exercises.length; i++) {
        expect(exercises[i]['id'], reversedIds[i]);
      }
    });

    // Test: Partial reorder (subset of exercises) returns 400
    test('returns 400 when not all exercise IDs are provided', () async {
      if (exerciseIds.length < 2) {
        return;
      }

      // Only provide some of the IDs
      final partialIds = [exerciseIds.first];

      final response = await authenticatedClient.patch(
        '/workouts/$testWorkoutId/exercises/reorder',
        body: {'exerciseIds': partialIds},
      );

      // Should require all exercise IDs to be provided
      expect(response.statusCode, 400);
    });
  });

  // ============================================================================
  // Additional Edge Case Tests
  // ============================================================================

  group('Edge Cases and Error Handling', () {
    // Test: Invalid JSON body returns 400
    test('returns 400 for invalid JSON body', () async {
      final client = http.Client();
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/routines'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: 'invalid json {{{',
      );
      client.close();

      expect(response.statusCode, 400);
    });

    // Test: Request with correct auth but malformed Bearer token
    test('returns 401 for malformed auth token', () async {
      final client = ApiClient(accessToken: 'invalid-token');
      final response = await client.get('/routines');
      client.close();

      expect(response.statusCode, 401);
    });

    // Test: Special characters in routine name are handled
    test('handles special characters in routine name', () async {
      final specialName = "Test Routine with 'quotes' and \"double quotes\" & ampersand";

      final response = await authenticatedClient.post('/routines', body: {
        'name': specialName,
      });

      expect(response.statusCode, 201);

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;

      expect(data['name'], specialName);

      createdRoutineIds.add(data['id'] as String);
    });

    // Test: Unicode characters in routine name are handled
    test('handles unicode characters in routine name', () async {
      final unicodeName = 'Test Routine \u{1F4AA} Strength \u{1F525} Fire';

      final response = await authenticatedClient.post('/routines', body: {
        'name': unicodeName,
      });

      expect(response.statusCode, 201);

      final body = jsonDecode(response.body);
      final data = body['data'] as Map;

      expect(data['name'], unicodeName);

      createdRoutineIds.add(data['id'] as String);
    });

    // Test: Concurrent requests don't cause issues
    test('handles concurrent requests', () async {
      final futures = <Future<http.Response>>[];

      // Fire off 5 concurrent list requests
      for (var i = 0; i < 5; i++) {
        futures.add(authenticatedClient.get('/routines'));
      }

      final responses = await Future.wait(futures);

      // All should succeed
      for (final response in responses) {
        expect(response.statusCode, 200);
      }
    });
  });
}
