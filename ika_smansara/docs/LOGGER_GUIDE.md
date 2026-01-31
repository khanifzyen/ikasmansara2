# 📝 Logger Documentation for IKA SMANSARA

## Overview

Project ini menggunakan package **Logger** (`logger: ^2.0.0`) untuk logging yang terstruktur dan mudah di-debug. Logger terletak di `lib/core/utils/app_logger.dart`.

## Features

✅ **Pretty Print** - Output warna-warni dengan emoji untuk mudah dibaca  
✅ **Log Levels** - Debug, Info, Warning, Error, WTF  
✅ **Context Support** - Grouping by feature/repository/bloc  
✅ **Production Filter** - Otomatis non-aktifkan debug logs di production  
✅ **Stack Traces** - Otomatis capture stack trace untuk errors  
✅ **Helper Methods** - Extensions untuk API, BLoC, Navigation, User Actions  

## Quick Start

### Import Logger
```dart
import '../../../../core/utils/app_logger.dart';
```

### Basic Usage

```dart
// Debug level - Detailed info for development
log.debug('User data loaded successfully');

// Info level - General informational messages
log.info('Application started');

// Warning level - Potentially harmful situations
log.warning('Cache miss for user data');

// Error level - Error events
log.error('Failed to load user data', error: exception);

// WTF level - Critical failures
log.wtf('Database connection lost', error: exception);
```

### Logging with Context

```dart
// Group logs by feature/context
log.withContext(
  'AuthRepository',
  LogLevel.info,
  'User logged in successfully',
);

// With error and stack trace
log.withContext(
  'EventBooking',
  LogLevel.error,
  'Booking failed',
  error: e,
  stackTrace: stackTrace,
);
```

## Extension Methods

### 1. API Logging

```dart
// Log API request
log.apiRequest(
  method: 'POST',
  url: '/api/events',
  body: {'title': 'Reunion 2026'},
  headers: {'Authorization': 'Bearer token'},
);

// Log API response
log.apiResponse(
  url: '/api/events',
  statusCode: 200,
  body: {'id': 'evt123'},
  duration: 250, // milliseconds
);

// Log API error
log.apiError(
  url: '/api/events',
  statusCode: 500,
  message: 'Internal server error',
  error: exception,
);
```

**Example in Repository:**
```dart
Future<EventModel> getEventDetail(String id) async {
  log.withContext('EventRemoteDataSource', LogLevel.debug, 'Fetching event: $id');
  
  try {
    final record = await _pbClient.pb.collection('events').getOne(id);
    log.withContext('EventRemoteDataSource', LogLevel.info, 'Event fetched: ${record.id}');
    return EventModel.fromRecord(record);
  } catch (e) {
    log.withContext('EventRemoteDataSource', LogLevel.error, 'Failed to fetch event', error: e);
    rethrow;
  }
}
```

### 2. BLoC Logging

```dart
// Log BLoC event
log.blocEvent(
  bloc: 'AuthBloc',
  event: 'LoginRequested',
  data: {'email': 'user@example.com'},
);

// Log BLoC state change
log.blocStateChange(
  bloc: 'AuthBloc',
  from: 'AuthInitial',
  to: 'AuthLoading',
);
```

**Example in BLoC:**
```dart
Future<void> _onLoginRequested(
  AuthLoginRequested event,
  Emitter<AuthState> emit,
) async {
  log.blocEvent(
    bloc: 'AuthBloc',
    event: 'LoginRequested',
    data: {'email': event.email},
  );
  
  emit(const AuthLoading());
  
  final result = await _authRepository.login(
    email: event.email,
    password: event.password,
  );
  
  if (result.failure != null) {
    log.blocStateChange(
      bloc: 'AuthBloc',
      from: 'AuthLoading',
      to: 'AuthError(${result.failure})',
    );
    emit(AuthError(result.failure!));
  }
}
```

### 3. Navigation Logging

```dart
log.navigation(
  from: '/login',
  to: '/home',
  arguments: {'userId': 'user123'},
);
```

**Example in Router:**
```dart
GoRoute(
  path: '/event-detail',
  builder: (context, state) {
    final eventId = state.extra as String;
    
    log.navigation(
      from: state.uri.path,
      to: '/event-detail',
      arguments: {'eventId': eventId},
    );
    
    return EventDetailPage(eventId: eventId);
  },
);
```

### 4. User Action Logging

```dart
log.userAction(
  action: 'button_tapped',
  screen: 'EventDetailPage',
  properties: {
    'button': 'Buy Ticket',
    'eventId': 'EVT-001',
    'ticketType': 'VIP',
  },
);
```

**Example in UI:**
```dart
ElevatedButton(
  onPressed: () {
    log.userAction(
      action: 'buy_ticket',
      screen: 'EventDetailPage',
      properties: {
        'eventId': widget.eventId,
        'ticketType': selectedType,
      },
    );
    
    // Perform action...
    context.push('/payment');
  },
  child: const Text('Beli Tiket'),
)
```

## Log Levels

| Level | Usage | Production |
|-------|-------|------------|
| `debug` | Detailed debugging information | ❌ Hidden |
| `info` | General informational messages | ❌ Hidden |
| `warning` | Warning messages | ✅ Shown |
| `error` | Error events | ✅ Shown |
| `wtf` | Critical failures | ✅ Shown |

## Best Practices

### ✅ DO

1. **Use Context for Grouping**
   ```dart
   log.withContext('AuthRepository', LogLevel.info, 'User logged in');
   ```

2. **Log Important Events**
   - API requests/responses
   - BLoC events and state changes
   - User actions
   - Navigation
   - Errors with stack traces

3. **Use Appropriate Log Levels**
   - `debug`: Detailed data flow
   - `info`: Important milestones
   - `warning`: Non-critical issues
   - `error`: Failures and exceptions

4. **Include Context in Errors**
   ```dart
   try {
     // operation
   } catch (e, stackTrace) {
     log.withContext('Repository', LogLevel.error, 'Operation failed', 
       error: e, 
       stackTrace: stackTrace
     );
   }
   ```

### ❌ DON'T

1. **Don't Log Sensitive Information**
   ```dart
   // BAD
   log.info('User password: $password'); // ❌ Never log passwords!
   
   // GOOD
   log.info('User login attempt: ${email.replaceAll(RegExp(r'(?<=.{2}).(?=.*@)'), '*')}'); // ✅ Mask email
   ```

2. **Don't Over-log**
   ```dart
   // BAD
   for (var i = 0; i < 1000; i++) {
     log.debug('Processing item $i'); // ❌ Too many logs!
   }
   
   // GOOD
   log.debug('Processing 1000 items...'); // ✅ Summary log
   log.debug('Batch processing completed'); // ✅ Final result
   ```

3. **Don't Log in Hot Paths**
   ```dart
   // BAD
   void onUpdate() {
     log.debug('State updated'); // ❌ Called 60x per second!
   }
   
   // GOOD
   void onUpdate() {
     if (_counter % 60 == 0) {
       log.debug('1 second passed'); // ✅ Log occasionally
     }
   }
   ```

## Output Examples

### Development Mode
```
───────⚔ ────────────────────────
💙 [EventRemoteDataSource] Fetching event: EVT-001
  └─▶︎ info.dart:145 ← main()

🟢 [EventRemoteDataSource] Event fetched: EVT-001
  └─▶︎ info.dart:150 ← main()

───────⚠ ────────────────────────
💛 [AuthRepository] Email not verified for user@test.com
  └─▶︎ auth_repository_impl.dart:92 ← main()
```

### Production Mode
```
───────⚠ ────────────────────────
💛 [PaymentService] Payment failed: timeout
  └─▶︎ payment_service.dart:234 ← main()

───────❌ ────────────────────────
❤️ [API] Request failed: 500 Internal Server Error
  └─▶︎ api_client.dart:89 ← main()
```

## Advanced Usage

### Custom Logger per Feature

```dart
// Create logger specific to a feature
final authLogger = AppLogger();

class AuthRepository {
  void login() {
    authLogger.withContext('AuthRepository', LogLevel.info, 'Login attempt');
  }
}
```

### Conditional Logging

```dart
// Only log if in debug mode
if (kDebugMode) {
  log.debug('Detailed debug info');
}

// Log with condition
log.debug(
  'User data: ${shouldLogDetails ? userData : '<hidden>'}',
);
```

### Format Output

The logger uses **PrettyPrinter** with these settings:
- Method count: 2 (show 2 levels of call stack)
- Error method count: 8 (show 8 levels for errors)
- Line length: 120 characters
- Colors: enabled (in development)
- Emojis: enabled
- DateTime: time only + time since start

## Troubleshooting

### Logs Not Showing

**Problem**: Logs not appearing in console  
**Solution**:
1. Check if in release mode: `kReleaseMode` hides debug/info logs
2. Ensure you're using `log` not `debugPrint`
3. Check filter level in app_logger.dart

### Too Many Logs

**Problem**: Console flooded with logs  
**Solution**:
1. Use higher log levels (info instead of debug)
2. Log summaries instead of individual items
3. Use conditional logging

### Performance Issues

**Problem**: Logging causing app to lag  
**Solution**:
1. Reduce log frequency in hot paths
2. Remove expensive toString() calls
3. Use lazy evaluation: `log.debug(() => 'Expensive data: ${computeExpensive()}')`

## Resources

- **Logger Package**: https://pub.dev/packages/logger
- **File**: `lib/core/utils/app_logger.dart`
- **Example Usage**: See `auth_repository_impl.dart` and `event_remote_data_source.dart`

---

**Remember**: Good logging helps debug issues faster in development and understand problems in production! 🚀
